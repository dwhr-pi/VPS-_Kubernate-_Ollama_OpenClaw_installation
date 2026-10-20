"""Private queue fixtures only; real flock concurrency tests run on Linux CI."""
import os
from contextlib import closing
from pathlib import Path
import shlex
import shutil
import sqlite3
import subprocess
import sys
import tempfile
import time
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = "C:/Program Files/Git/bin/bash.exe" if os.name == "nt" else shutil.which("bash")


def shell_path(path):
    value = str(path).replace("\\", "/")
    return "/" + value[0].lower() + value[2:] if os.name == "nt" else value


@unittest.skipUnless(BASH, "Bash unavailable")
class QueueSafety(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.home = Path(temp.name)
        self.queue = self.home / "queue"
        self.env = {**os.environ, "HOME": str(self.home), "QUEUE_HOME": shell_path(self.queue),
                    "QUEUE_FILE": shell_path(self.queue / "jobs.tsv"), "QUEUE_MODE": "tsv"}

    def shell(self, script, args=(), prelude=""):
        command = prelude + "\nbash " + shlex.quote("scripts/queue/" + script) + " " + " ".join(shlex.quote(a) for a in args)
        return subprocess.run([BASH, "--noprofile", "--norc", "-c", command], cwd=ROOT,
                              env=self.env, capture_output=True, text=True, timeout=60)

    def configure(self):
        self.queue.mkdir()
        (self.queue / "config.env").write_text(
            "QUEUE_MODE=tsv\nMAX_PARALLEL_JOBS=1\nMIN_MEM_AVAILABLE_MB=0\n"
            "MAX_LOAD_AVG=99999\nMIN_DISK_FREE_MB=0\nDEFAULT_TIMEOUT_SECONDS=15\n", encoding="utf-8")

    def test_status_does_not_create_anything(self):
        result = self.shell("queue_status.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.queue.exists())

    def test_status_never_executes_config_or_prints_commands(self):
        self.configure()
        sentinel = self.home / "config-executed"
        with (self.queue / "config.env").open("a", encoding="utf-8") as stream:
            stream.write("touch " + shlex.quote(shell_path(sentinel)) + "\n")
        (self.queue / "jobs.tsv").write_text("job\tqueued\tnormal\t0\t1\t15\tDO_NOT_REPORT\n", encoding="utf-8")
        result = self.shell("queue_status.sh")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(sentinel.exists())
        self.assertNotIn("DO_NOT_REPORT", result.stdout)

    def test_failed_worker_lock_never_runs_job(self):
        self.configure()
        result = self.shell("queue_run_next.sh", prelude="flock() { return 1; }; export -f flock;")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("bereits aktiv", result.stdout)
        self.assertFalse((self.queue / "jobs.tsv").exists())

    def test_invalid_priority_rejected_before_sqlite(self):
        self.configure()
        result = self.shell("queue_submit.sh", ("--priority", "bad' SQL", "--", "echo test"),
                            "sqlite3() { exit 99; }; export -f sqlite3;")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertIn("Prioritaet", result.stderr)
        self.assertFalse((self.queue / "queue.sqlite").exists())

    def test_cancel_only_marks_waiting_jobs(self):
        self.configure()
        file = self.queue / "jobs.tsv"
        file.write_text("waiting\tqueued\tnormal\t0\t1\t15\techo one\n"
                        "active\trunning\tnormal\t1\t1\t15\techo two\n", encoding="utf-8")
        lock = "flock() { :; }; export -f flock;"
        result = self.shell("queue_cancel.sh", ("waiting",), lock)
        self.assertEqual(result.returncode, 0, result.stderr)
        result = self.shell("queue_cancel.sh", ("active",), lock)
        self.assertEqual(result.returncode, 1, result.stderr)
        rows = file.read_text().splitlines()
        self.assertEqual([row.split("\t")[1] for row in rows], ["cancelled", "running"])

    def test_timeouts_escalate_and_do_not_inherit_locks(self):
        for script in ("queue_worker.sh", "queue_run_next.sh"):
            text = (ROOT / "scripts/queue" / script).read_text(encoding="utf-8")
            self.assertIn("timeout --kill-after=10", text)
            self.assertIn("8>&- 9>&-", text)

    def test_multiline_commands_do_not_inject_rows(self):
        self.configure()
        result = self.shell("queue_add.sh", ("--", "echo one\necho two"),
                            "flock() { :; }; export -f flock;")
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertEqual((self.queue / "jobs.tsv").read_text(), "")

    def test_tsv_pause_resume_exit_code_and_submit_routing(self):
        self.configure()
        mock_lock = "flock() { :; }; export -f flock;"
        result = self.shell("queue_submit.sh", ("--", "exit 7"), mock_lock)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.queue / "queue.sqlite").exists())
        for script, expected in (("queue_pause.sh", "paused"), ("queue_resume.sh", "queued")):
            result = self.shell(script, prelude=mock_lock)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual((self.queue / "jobs.tsv").read_text().split("\t")[1], expected)
        result = self.shell("queue_run_next.sh", prelude=mock_lock)
        self.assertEqual(result.returncode, 7, result.stderr)
        row = (self.queue / "jobs.tsv").read_text().strip().split("\t")
        self.assertEqual((row[1], row[7]), ("failed", "7"))

    def test_sqlite_migration_preserves_data_and_records_exit_code(self):
        self.configure()
        self.env["QUEUE_MODE"] = "sqlite"
        config = self.queue / "config.env"
        config.write_text(config.read_text().replace("QUEUE_MODE=tsv", "QUEUE_MODE=sqlite"), encoding="utf-8")
        database = self.queue / "queue.sqlite"
        with closing(sqlite3.connect(database)) as connection, connection:
            connection.executescript("""
                create table jobs(id integer primary key autoincrement, command text not null,
                    priority text default 'normal', status text default 'queued',
                    attempts integer default 0, max_attempts integer default 1,
                    timeout_seconds integer default 15, log_path text,
                    created_at text default current_timestamp, updated_at text default current_timestamp);
                insert into jobs(command,status) values('preserve existing job','done');
            """)
        # A tiny sqlite CLI fixture uses only Python's local stdlib database.
        shim = self.home / "sqlite_cli.py"
        shim.write_text("""import os,sys,sqlite3
args=sys.argv[1:]; sep='|'
if args[0]=='-separator': sep=args[1]; args=args[2:]
db=args[0]
if os.name=='nt' and len(db)>2 and db[0]=='/' and db[2]=='/': db=db[1]+':'+db[2:]
sql=args[1] if len(args)>1 else sys.stdin.read()
with sqlite3.connect(db) as c:
 if sql.lstrip().lower().startswith('select'):
  for row in c.execute(sql): print(sep.join('' if x is None else str(x) for x in row))
 else: c.executescript(sql)
""", encoding="utf-8")
        prelude = ("flock() { :; }; export -f flock;\nsqlite3() { " + shlex.quote(shell_path(sys.executable)) +
                   " -B " + shlex.quote(shell_path(shim)) + ' "$@"; }; export -f sqlite3;')
        result = self.shell("queue_submit.sh", ("--", "printf 'a|b'; exit 9"), prelude)
        self.assertEqual(result.returncode, 0, result.stderr)
        result = self.shell("queue_worker.sh", prelude=prelude)
        self.assertEqual(result.returncode, 9, result.stderr)
        with closing(sqlite3.connect(database)) as connection:
            rows = connection.execute("select command,status,exit_code from jobs order by id").fetchall()
        self.assertEqual(rows[0], ("preserve existing job", "done", None))
        self.assertEqual(rows[1][1:], ("failed", 9))
        self.assertNotIn("printf", result.stdout)

    def test_all_entrypoint_dry_runs_are_write_free(self):
        for action in ("add", "submit", "run_next", "worker", "cancel", "pause", "resume", "status"):
            result = self.shell("queue_" + action + ".sh", ("--dry-run",))
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertFalse(self.queue.exists(), action)

    @unittest.skipUnless(os.name == "posix" and shutil.which("flock"), "Real flock concurrency requires Linux CI")
    def test_parallel_workers_and_submit_during_running_job(self):
        self.configure()
        started, runs = self.home / "started", self.home / "runs"
        command = "touch " + shlex.quote(str(started)) + "; sleep 2; echo ran >> " + shlex.quote(str(runs))
        self.assertEqual(self.shell("queue_add.sh", ("--", command)).returncode, 0)
        first = subprocess.Popen([BASH, "--noprofile", "--norc", "scripts/queue/queue_run_next.sh"],
                                 cwd=ROOT, env=self.env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        try:
            deadline = time.monotonic() + 10
            while not started.exists() and time.monotonic() < deadline:
                time.sleep(0.02)
            self.assertTrue(started.exists())
            self.assertEqual(self.shell("queue_add.sh", ("--", "echo later")).returncode, 0)
            second = self.shell("queue_worker.sh")
            self.assertEqual(second.returncode, 0, second.stderr)
            self.assertIn("bereits aktiv", second.stdout)
            _, err = first.communicate(timeout=15)
            self.assertEqual(first.returncode, 0, err)
            self.assertEqual(runs.read_text().splitlines(), ["ran"])
            rows = (self.queue / "jobs.tsv").read_text().splitlines()
            self.assertEqual([r.split("\t")[1] for r in rows], ["done", "queued"])
        finally:
            if first.poll() is None:
                first.terminate()
                first.communicate(timeout=15)


if __name__ == "__main__":
    unittest.main()
