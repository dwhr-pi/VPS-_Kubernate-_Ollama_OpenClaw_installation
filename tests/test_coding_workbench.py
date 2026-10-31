"""Offline security regressions; no Docker, WSL, real Git, keys or model required."""

from contextlib import ExitStack, redirect_stderr, redirect_stdout
import hashlib
import http.client
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import importlib.util
import io
import json
import os
from pathlib import Path
import socket
import stat
import subprocess
import sys
import tempfile
import threading
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch


ROOT = Path(__file__).resolve().parents[1]
with patch.object(sys, "path", [str(ROOT / "scripts/agents"), *sys.path]):
    SPEC = importlib.util.spec_from_file_location("coding_workbench_under_test", ROOT / "scripts/agents/workbench.py")
    wb = importlib.util.module_from_spec(SPEC)
    SPEC.loader.exec_module(wb)
broker_module = sys.modules[wb.Broker.__module__]
worker = sys.modules[wb.configurations.__module__]
AGENTS = ("opencode", "qwen_code", "aider", "codex_cli", "openhands")
MODEL = "qwen2.5-coder:7b"
IMAGE = "local/worker@sha256:" + "a" * 64
DIGEST = "b" * 64


class OfflineCase(unittest.TestCase):
    def setUp(self):
        stack = self.enterContext(ExitStack())
        self.root = Path(stack.enter_context(tempfile.TemporaryDirectory())).resolve()
        stack.enter_context(patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.root / "private")}))
        self.process = stack.enter_context(patch.object(subprocess, "run", side_effect=AssertionError("Unexpected subprocess")))
        stack.enter_context(patch.object(subprocess, "Popen", side_effect=AssertionError("Unexpected process")))
        self.http = stack.enter_context(patch.object(http.client, "HTTPConnection", side_effect=AssertionError("Unexpected HTTP")))
        stack.enter_context(patch.object(socket, "create_connection", side_effect=AssertionError("Unexpected network")))
        stack.enter_context(patch.object(socket.socket, "connect", side_effect=AssertionError("Unexpected socket connect")))
        self.git = stack.enter_context(patch.object(wb, "git", side_effect=AssertionError("Unexpected Git")))

    def args(self, **changes):
        values = dict(agent="opencode", role="plan", model=MODEL, image=IMAGE,
                      worktree=str(self.root / "tree"), ollama_url="http://127.0.0.1:11434",
                      run=False, confirm=False, prompt_file=str(self.root / "prompt.txt"))
        values.update(changes)
        return SimpleNamespace(**values)

    def invoke(self, *argv):
        out, err = io.StringIO(), io.StringIO()
        with redirect_stdout(out), redirect_stderr(err):
            code = wb.main(list(argv))
        return code, out.getvalue(), err.getvalue()


class PlanTests(OfflineCase):
    def test_all_five_configure_and_worker_plans_are_inert(self):
        self.assertEqual(set(wb.catalog()["agents"]), set(AGENTS))
        with patch.object(Path, "mkdir", side_effect=AssertionError("Plan mkdir")), \
                patch.object(wb, "write_new", side_effect=AssertionError("Plan write")), \
                patch.object(os, "open", side_effect=AssertionError("Plan open for write")), \
                patch.object(wb, "validate_worktree", side_effect=AssertionError("Plan probes tree")), \
                patch.object(wb, "start", side_effect=AssertionError("Plan starts broker")), \
                patch.object(wb, "Broker", side_effect=AssertionError("Plan probes model")):
            for agent in AGENTS:
                with self.subTest(agent=agent):
                    code, out, err = self.invoke("configure", "--agent", agent, "--model", MODEL)
                    self.assertEqual((code, err), (0, ""))
                    data = json.loads(out)
                    self.assertEqual(data["action"], "configure-only")
                    self.assertFalse(data["runtime_started"])
                    self.assertFalse(data["model_verified"])
                    for role in ("plan", "review", "test", "implement"):
                        result = wb.run_worker(self.args(agent=agent, role=role))
                        self.assertEqual(result["action"], "offline-plan")
                        self.assertEqual(result["network"], "none")
        self.assertEqual(list(self.root.iterdir()), [])

    def test_native_windows_plan_never_needs_unix_identity(self):
        with patch.object(wb.platform, "system", return_value="Windows"), \
                patch.object(os, "geteuid", side_effect=AssertionError("Unix identity"), create=True), \
                patch.object(os, "getuid", side_effect=AssertionError("Unix identity"), create=True):
            code, out, err = self.invoke("worker", "--agent", "codex_cli", "--model", MODEL,
                                         "--image", IMAGE, "--worktree", str(self.root / "missing"))
        self.assertEqual((code, err), (0, ""))
        self.assertEqual(json.loads(out)["action"], "offline-plan")

    def test_run_without_confirm_refused_before_platform_git_or_docker(self):
        with patch.object(wb.platform, "system", side_effect=AssertionError("Too early")):
            with self.assertRaisesRegex(ValueError, "--confirm"):
                wb.run_worker(self.args(run=True))
            code, out, err = self.invoke("worker", "--agent", "opencode", "--model", MODEL,
                                         "--image", IMAGE, "--worktree", str(self.root / "tree"), "--run")
        self.assertEqual(code, 2)
        self.assertEqual(out, "")
        self.assertIn("refused", err)
        self.process.assert_not_called()
        self.git.assert_not_called()

    def test_actual_execution_requires_nonroot_linux(self):
        for system, uid in (("Windows", 1000), ("Darwin", 1000), ("Linux", 0)):
            with self.subTest(system=system, uid=uid), \
                    patch.object(wb.platform, "system", return_value=system), \
                    patch.object(os, "geteuid", return_value=uid, create=True), \
                    self.assertRaisesRegex(ValueError, "nonroot Linux"):
                wb.run_worker(self.args(run=True, confirm=True))
        self.git.assert_not_called()
        self.process.assert_not_called()


class ValidationTests(OfflineCase):
    def test_bad_endpoints(self):
        for url in ("https://127.0.0.1", "http://localhost", "http://example.invalid", "http://0.0.0.0",
                    "http://127.0.0.2", "http://127.0.0.1.evil.invalid", "http://user:pass@127.0.0.1",
                    "http://127.0.0.1/api", "http://127.0.0.1?x=1", "http://127.0.0.1#x",
                    "http://[::1]:99999", "http://127.0.0.1:bad", "file:///tmp/model"):
            with self.subTest(url=url), self.assertRaises(ValueError):
                broker_module.endpoint(url)
        self.assertEqual(broker_module.endpoint("http://[::1]:11435/"), ("::1", 11435))
        self.assertEqual(broker_module.endpoint("http://127.0.0.1"), ("127.0.0.1", 11434))

    def test_bad_models_and_image_digests(self):
        for model in ("", "-flag", "a b", "a\nb", "a;id", "a\\b", "qwen-cloud", "CLOUD", "a" * 201):
            with self.subTest(model=model), self.assertRaises(ValueError):
                broker_module.model_name(model)
        for image in ("local/worker:latest", "local/worker", "--privileged", IMAGE[:-1],
                      IMAGE.upper(), IMAGE + ",readonly", IMAGE + "\n"):
            with self.subTest(image=image), self.assertRaises(ValueError):
                wb.image(image)
        self.assertEqual(wb.image(IMAGE), IMAGE)

    def test_bad_paths_and_linked_ancestors(self):
        for path in (Path("relative"), Path(self.root.anchor), self.root / ".." / "escape",
                     self.root / "bad,option", self.root / "bad\nname", self.root / "bad\rname",
                     self.root / "bad\x00name"):
            with self.subTest(path=repr(str(path))), self.assertRaises(ValueError):
                wb.safe(path)
        with patch.object(Path, "is_symlink", return_value=True), self.assertRaisesRegex(ValueError, "Symlink"):
            wb.safe(self.root / "child")
        if hasattr(Path, "is_junction"):
            with patch.object(Path, "is_junction", return_value=True), self.assertRaisesRegex(ValueError, "junction"):
                wb.safe(self.root / "child")

    def test_private_root_cannot_be_home_or_repository(self):
        for root in (Path.home().resolve(), wb.ROOT, wb.ROOT / "private"):
            with patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(root)}), self.assertRaises(ValueError):
                wb.private_root()

    def test_unknown_agent_or_role_refused(self):
        for changes in ({"agent": "unknown"}, {"role": "admin"}):
            with self.subTest(changes=changes), self.assertRaises(ValueError):
                wb.run_worker(self.args(**changes))
        with self.assertRaises(ValueError):
            wb.configure("unknown", MODEL, "http://127.0.0.1")


class ConfigurationTests(OfflineCase):
    def test_apply_readback_idempotence_and_modified_file_preservation(self):
        for agent in AGENTS:
            with self.subTest(agent=agent):
                result = wb.configure(agent, MODEL, "http://127.0.0.1:11434/", apply=True)
                target = Path(result["target"])
                client = target / ("config.toml" if agent == "codex_cli" else "client.json")
                expected = worker.configurations(agent, MODEL, "plan", base="http://127.0.0.1:11434")
                content = client.read_bytes()
                self.assertEqual(content, expected.encode() if isinstance(expected, str) else wb.encode(expected))
                self.assertEqual(json.loads((target / "configured.json").read_text()), result)
                before = {p.name: (p.read_bytes(), p.stat().st_mtime_ns) for p in target.iterdir()}
                wb.configure(agent, MODEL, "http://127.0.0.1:11434/", apply=True)
                self.assertEqual(before, {p.name: (p.read_bytes(), p.stat().st_mtime_ns) for p in target.iterdir()})
                client.write_bytes(b"user-modified")
                with self.assertRaisesRegex(ValueError, "preserved"):
                    wb.configure(agent, MODEL, "http://127.0.0.1:11434", apply=True)
                self.assertEqual(client.read_bytes(), b"user-modified")
                self.assertFalse((target / ".operation-lock").exists())

    def test_hardlinked_configuration_refused_even_if_bytes_match(self):
        original, alias = self.root / "original", self.root / "alias"
        wb.write_new(original, b"same")
        try:
            os.link(original, alias)
        except (OSError, NotImplementedError) as error:
            self.skipTest("Hardlinks unavailable: " + str(error))
        with self.assertRaisesRegex(ValueError, "linked"):
            wb.write_new(alias, b"same")
        self.assertEqual(original.read_bytes(), b"same")

    @unittest.skipUnless(os.name == "posix", "POSIX symlinks and permission modes")
    def test_real_symlink_and_unsafe_permissions_refused(self):
        original = self.root / "original"
        wb.write_new(original, b"same")
        alias = self.root / "alias"
        alias.symlink_to(original)
        with self.assertRaises(ValueError):
            wb.write_new(alias, b"same")
        directory = self.root / "directory"
        directory.mkdir(mode=0o755)
        with self.assertRaisesRegex(ValueError, "0700"):
            wb.private_directory(directory)
        self.assertEqual(stat.S_IMODE(original.stat().st_mode), 0o600)
        original.chmod(0o644)
        with self.assertRaisesRegex(ValueError, "unsafe"):
            wb.write_new(original, b"same")

    def test_existing_operation_lock_is_not_removed(self):
        lock = self.root / ".operation-lock"
        lock.mkdir()
        with self.assertRaises(FileExistsError):
            with wb.locked(self.root):
                self.fail("Acquired another operation's lock")
        self.assertTrue(lock.is_dir())


class WorktreeTests(OfflineCase):
    def make_tree(self):
        tree = self.root / "tree"
        tree.mkdir()
        (tree / ".git").write_bytes(b"gitdir: confined-test-fixture\n")
        return tree

    def answers(self, tree, branch=b"agents/unit", dirty=b"", top=None):
        return [SimpleNamespace(stdout=value) for value in
                (str(top or tree).encode(), branch, dirty)]

    def test_worktree_plan_reads_only_and_apply_calls_exact_local_git(self):
        repo, destination = self.root / "source", self.root / "new"
        for apply in (False, True):
            with patch.object(wb, "git", side_effect=[SimpleNamespace(stdout=b"a" * 40),
                                                     SimpleNamespace(stdout=b""), SimpleNamespace(stdout=b"")]) as git:
                result = wb.create_worktree(repo, destination, "agents/unit", apply=apply)
            self.assertEqual(result["created"], apply)
            self.assertEqual(git.call_count, 3 if apply else 2)
            if apply:
                self.assertEqual(git.call_args.args, (repo, "worktree", "add", "-b", "agents/unit", str(destination), "a" * 40))
        self.assertFalse(destination.exists())

    def test_worktree_creation_rejects_unsafe_branch_dest_commit_and_dirty(self):
        repo = self.root / "source"
        for branch in ("main", "agents/../main", "agents/-flag", "agents/a/b", "agents/" + "a" * 65):
            with self.subTest(branch=branch), self.assertRaises(ValueError):
                wb.create_worktree(repo, self.root / "new", branch)
        for destination in (self.root, repo / "nested", repo):
            with self.subTest(destination=destination), self.assertRaises(ValueError):
                wb.create_worktree(repo, destination, "agents/unit")
        for answers in ((b"short",), (b"a" * 40, b" M source.py")):
            with patch.object(wb, "git", side_effect=[SimpleNamespace(stdout=x) for x in answers]), self.assertRaises(ValueError):
                wb.create_worktree(repo, self.root / "new", "agents/unit", apply=True)

    def test_valid_linked_tree_hash_and_git_reads(self):
        tree = self.make_tree()
        (tree / "ordinary-directory").mkdir()
        (tree / "ordinary-directory/source.py").write_bytes(b"# synthetic source\n")
        with patch.object(wb, "git", side_effect=self.answers(tree)) as git:
            self.assertEqual(wb.validate_worktree(tree), hashlib.sha256((tree / ".git").read_bytes()).hexdigest())
        self.assertEqual([call.args[1:] for call in git.call_args_list],
                         [("rev-parse", "--show-toplevel"), ("branch", "--show-current"), ("status", "--porcelain")])

    def test_main_checkout_wrong_branch_top_and_dirty_rejected(self):
        tree = self.make_tree()
        for changes in ({"branch": b"main"}, {"branch": b""}, {"dirty": b"?? secret"}, {"top": self.root}):
            with self.subTest(changes=changes), patch.object(wb, "git", side_effect=self.answers(tree, **changes)), self.assertRaises(ValueError):
                wb.validate_worktree(tree)
        (tree / ".git").unlink()
        (tree / ".git").mkdir()
        with self.assertRaisesRegex(ValueError, "Linked Git worktree"):
            wb.validate_worktree(tree)

    def test_credential_filenames_rejected_without_reading_contents(self):
        tree = self.make_tree()
        for name in (".ssh", ".aws", ".kube", ".gnupg", "secrets", "auth.json", "wallet.json",
                     "id.pem", "id.key", "id.p12", "id.age", ".env", ".env.local"):
            item = tree / name
            item.write_bytes(b"synthetic-not-a-credential")
            with self.subTest(name=name), patch.object(wb, "git", side_effect=self.answers(tree)), self.assertRaisesRegex(ValueError, "credential"):
                wb.validate_worktree(tree)
            item.unlink()
        for name in (".env.example", ".env.template"):
            (tree / name).write_bytes(b"example")
        with patch.object(wb, "git", side_effect=self.answers(tree)):
            wb.validate_worktree(tree)

    def test_worktree_rejects_sockets_and_other_special_types_without_real_sockets(self):
        tree = self.make_tree()
        item = tree / "innocent-ignored-entry"
        item.write_bytes(b"synthetic placeholder; never opened as a socket")
        original_stat, original_lstat = Path.stat, Path.lstat

        for kind in (stat.S_IFSOCK, stat.S_IFIFO, stat.S_IFCHR, stat.S_IFBLK):
            def metadata(method, path, *args, **kwargs):
                info = method(path, *args, **kwargs)
                if path == item:
                    fields = list(info)
                    fields[0] = kind | 0o600
                    return os.stat_result(fields)
                return info

            with self.subTest(kind=kind), \
                    patch.object(Path, "stat", autospec=True, side_effect=lambda p, *a, **kw: metadata(original_stat, p, *a, **kw)), \
                    patch.object(Path, "lstat", autospec=True, side_effect=lambda p, *a, **kw: metadata(original_lstat, p, *a, **kw)), \
                    patch.object(wb, "git", side_effect=self.answers(tree)), self.assertRaises(ValueError):
                wb.validate_worktree(tree)
        self.assertEqual(item.read_bytes(), b"synthetic placeholder; never opened as a socket")
        self.process.assert_not_called()

    def test_worktree_rejects_hardlink_to_file_outside_tree(self):
        tree = self.make_tree()
        external = self.root / "outside-tree.txt"
        external.write_bytes(b"synthetic host file; must remain unchanged")
        alias = tree / "ordinary-source.txt"
        try:
            os.link(external, alias)
        except (OSError, NotImplementedError) as error:
            self.skipTest("Hardlinks unavailable: " + str(error))
        self.assertGreater(alias.stat().st_nlink, 1)
        with patch.object(wb, "git", side_effect=self.answers(tree)), self.assertRaises(ValueError):
            wb.validate_worktree(tree)
        self.assertEqual(external.read_bytes(), b"synthetic host file; must remain unchanged")
        self.assertEqual(alias.read_bytes(), external.read_bytes())
        self.process.assert_not_called()


class DockerTests(OfflineCase):
    def command(self, role):
        with patch.object(os, "getuid", return_value=1000, create=True), patch.object(os, "getgid", return_value=1001, create=True):
            return wb.docker_command("opencode", role, MODEL, self.root / "tree", IMAGE, self.root / "run", "llmops-agent-test")

    def test_security_flags_and_exact_mount_allowlist_for_every_role(self):
        for role in ("plan", "review", "test", "implement"):
            with self.subTest(role=role):
                argv = self.command(role)
                for flag in ("--rm", "--pull=never", "--read-only", "--cap-drop=ALL", "--security-opt=no-new-privileges:true", "--init"):
                    self.assertIn(flag, argv)
                for flag, value in (("--network", "none"), ("--user", "1000:1001"), ("--cpus", "2"),
                                    ("--memory", "2g"), ("--memory-swap", "2g"), ("--pids-limit", "128"),
                                    ("--ulimit", "nofile=256:256"), ("--log-driver", "none"), ("--entrypoint", "python3")):
                    self.assertEqual(argv[argv.index(flag) + 1], value)
                self.assertEqual(argv[:3], ["docker", "--host", "unix:///var/run/docker.sock"])
                mounts = [argv[i + 1] for i, value in enumerate(argv) if value == "--mount"]
                expected = [(self.root / "tree", "/workspace", role != "implement"),
                            (self.root / "tree/.git", "/workspace/.git", True),
                            (wb.ROOT / "scripts/agents", "/runner", True),
                            (self.root / "run/policy", "/policy", True),
                            (self.root / "run/broker", "/broker", True),
                            (self.root / "run/result.txt", "/result.txt", False)]
                self.assertEqual(mounts, ["type=bind,src=" + str(src) + ",dst=" + dst + (",readonly" if ro else "") for src, dst, ro in expected])
                self.assertEqual(argv[-4:], ["python3", IMAGE, "-B", "/runner/worker_entry.py"])
                self.assertIn("fsize=8388608:8388608", argv)
                for forbidden in ("--privileged", "--env-file", "--env", "-e", "-v", "--volume", "--pid=host"):
                    self.assertNotIn(forbidden, argv)
                for mount in mounts:
                    for forbidden in ("docker.sock", ".ssh", ".aws", "auth.json", ".env"):
                        self.assertNotIn(forbidden, mount)

    def test_catalog_json_cannot_grant_write_to_readonly_roles(self):
        tampered = json.loads(json.dumps(wb.catalog()))
        for role in ("plan", "review", "test"):
            tampered["roles"][role]["workspace_write"] = True
        tampered["limits"] = {"memory": "999g", "pids": 999999}
        with patch.object(wb, "catalog", return_value=tampered):
            for role in ("plan", "review", "test", "arbitrary"):
                argv = self.command(role)
                self.assertIn("type=bind,src=" + str(self.root / "tree") + ",dst=/workspace,readonly", argv)
                self.assertEqual(argv[argv.index("--memory") + 1], "2g")

    def execute_fake(self, label="own", timeout=False, tamper=False, inspect_status=0,
                     listed_ids="", list_status=0, cleanup_error=None, worker_status=0,
                     inspect_error=None, list_error=None):
        tree = self.root / "tree"
        tree.mkdir(exist_ok=True)
        (tree / ".git").write_bytes(b"original-control")
        prompt = self.root / "prompt.txt"
        prompt.write_text("Synthetic task", encoding="utf-8")
        self.calls = []
        self.run_id = None

        def process(argv, **kwargs):
            self.calls.append((argv, kwargs))
            if "run" in argv:
                self.run_id = argv[argv.index("--name") + 1]
                mounts = [argv[i + 1] for i, value in enumerate(argv) if value == "--mount"]
                report_mount = next(m for m in mounts if m.endswith(",dst=/result.txt"))
                report = Path(report_mount.split(",src=", 1)[1].split(",dst=", 1)[0])
                report.write_bytes(b"synthetic untrusted transcript\n")
                self.assertEqual(sorted(p.name for p in (report.parent / "broker").iterdir()), [])
                if tamper:
                    (tree / ".git").write_bytes(b"tampered")
                if timeout:
                    raise subprocess.TimeoutExpired(argv, 900)
                return SimpleNamespace(returncode=worker_status)
            if argv[3:5] == ["container", "ls"]:
                if list_error is not None:
                    raise list_error
                return SimpleNamespace(returncode=list_status, stdout=listed_ids)
            if "--format" in argv:
                if inspect_error is not None:
                    raise inspect_error
                labels = {"llmops.run": self.run_id if label == "own" else "another-run"}
                return SimpleNamespace(returncode=inspect_status, stdout=json.dumps(labels) if inspect_status == 0 else "")
            if "rm" in argv and cleanup_error is not None:
                raise cleanup_error
            return SimpleNamespace(returncode=0)

        server = Mock()
        fake_broker = Mock(remaining=15)
        fake_broker.local_model.return_value = DIGEST
        with ExitStack() as stack:
            stack.enter_context(patch.object(wb.platform, "system", return_value="Linux"))
            for name in ("geteuid", "getuid", "getgid"):
                stack.enter_context(patch.object(os, name, return_value=1000, create=True))
            # Real POSIX directory ownership is checked separately, not against the fake UID.
            stack.enter_context(patch.object(wb, "private_directory", side_effect=lambda p: (p.mkdir(parents=True, exist_ok=True), p)[1]))
            stack.enter_context(patch.object(wb, "validate_worktree", return_value=hashlib.sha256(b"original-control").hexdigest()))
            factory = stack.enter_context(patch.object(wb, "Broker", return_value=fake_broker))
            start = stack.enter_context(patch.object(wb, "start", return_value=server))
            stack.enter_context(patch.object(wb.shutil, "disk_usage", return_value=SimpleNamespace(free=1024**3)))
            stack.enter_context(patch.object(subprocess, "run", side_effect=process))
            stack.enter_context(patch.dict(os.environ, {"OPENAI_API_KEY": "synthetic", "AWS_SECRET_ACCESS_KEY": "synthetic",
                                                       "SSH_AUTH_SOCK": "/synthetic/agent", "DOCKER_HOST": "tcp://evil.invalid",
                                                       "DOCKER_CONFIG": "/synthetic/config", "PYTHONPATH": "/synthetic/hook"}))
            try:
                return wb.run_worker(self.args(run=True, confirm=True))
            finally:
                self.server = server
                factory.assert_called_once_with("http://127.0.0.1:11434", MODEL, 16, 900)
                start.assert_called_once()
                socket_path, supplied_broker = start.call_args.args
                self.assertEqual(socket_path.name, "model.sock")
                self.assertEqual(socket_path.parent.name, "broker")
                self.assertIs(supplied_broker, fake_broker)

    def test_execution_environment_scrubbed_and_only_model_socket_exposed(self):
        result = self.execute_fake()
        self.assertEqual(result["action"], "completed")
        self.assertFalse(result["committed"])
        self.assertFalse(result["published"])
        for argv, kwargs in self.calls:
            self.assertLessEqual(set(kwargs["env"]), {"PATH", "LANG", "LC_ALL", "HOME", "DOCKER_CONFIG"})
            self.assertTrue(Path(kwargs["env"]["HOME"]).is_relative_to(self.root))
            self.assertEqual(kwargs["env"]["DOCKER_CONFIG"], str(Path(kwargs["env"]["HOME"]) / "docker-config"))
        self.server.shutdown.assert_called_once()
        self.server.server_close.assert_called_once()
        base = self.root / "private/coding_workbench"
        self.assertEqual(sorted(p.name for p in base.iterdir()), ["reports"])
        self.assertEqual(Path(result["report"]).read_bytes(), b"synthetic untrusted transcript\n")
        for argv, kwargs in self.calls:
            if "run" in argv:
                self.assertEqual(kwargs["stdout"], subprocess.DEVNULL)
                self.assertEqual(kwargs["stderr"], subprocess.DEVNULL)

    def test_timeout_removes_only_own_labelled_container_and_closes_broker(self):
        with self.assertRaises(subprocess.TimeoutExpired):
            self.execute_fake(timeout=True)
        removals = [argv for argv, _ in self.calls if "rm" in argv]
        self.assertEqual(removals, [["docker", "--host", "unix:///var/run/docker.sock", "rm", "--force", self.run_id]])
        self.assertTrue(self.run_id.startswith("llmops-agent-"))
        self.server.shutdown.assert_called_once()
        self.server.server_close.assert_called_once()

    def test_timeout_never_removes_container_with_foreign_label(self):
        with self.assertRaises(wb.CleanupUnconfirmed):
            self.execute_fake(label="foreign", timeout=True)
        self.assertFalse(any("rm" in argv for argv, _ in self.calls))
        self.server.shutdown.assert_called_once()
        self.server.server_close.assert_called_once()
        self.assert_quarantined_and_restart_blocked()

    def assert_container_list_scoped_to_own_run(self):
        listings = [argv for argv, _ in self.calls if argv[3:5] == ["container", "ls"]]
        self.assertEqual(listings, [["docker", "--host", "unix:///var/run/docker.sock", "container", "ls",
                                    "--all", "--filter", "name=^/" + self.run_id + "$", "--format", "{{.ID}}"]])

    def assert_quarantined_and_restart_blocked(self):
        self.assertTrue(issubclass(wb.CleanupUnconfirmed, ValueError))
        base = Path(os.environ["OPENCLAW_USER_DATA_DIR"]) / "coding_workbench"
        marker = base / ".cleanup-review-required"
        self.assertTrue(marker.exists(), "Cleanup failure must leave a persistent quarantine marker")
        self.assertFalse(marker.is_symlink())
        before = marker.stat()
        contents = marker.read_bytes() if marker.is_file() else None
        self.server.shutdown.assert_called_once()
        self.server.server_close.assert_called_once()
        with patch.object(wb.platform, "system", return_value="Linux"), \
                patch.object(os, "geteuid", return_value=1000, create=True), \
                patch.object(wb, "locked", side_effect=AssertionError("Quarantine must precede lock")), \
                patch.object(wb, "validate_worktree", side_effect=AssertionError("Quarantine must precede Git")), \
                patch.object(wb, "Broker", side_effect=AssertionError("Quarantine must precede model")), \
                patch.object(wb, "start", side_effect=AssertionError("Quarantine must precede broker")), \
                patch.object(wb, "private_directory", side_effect=AssertionError("Quarantine must precede mkdir")), \
                self.assertRaises(wb.CleanupUnconfirmed):
            wb.run_worker(self.args(run=True, confirm=True))
        self.assertTrue(marker.exists())
        self.assertEqual(marker.stat().st_mtime_ns, before.st_mtime_ns)
        if contents is not None:
            self.assertEqual(marker.read_bytes(), contents)
        self.process.assert_not_called()
        self.git.assert_not_called()

    def test_inspect_failure_confirmed_absent_by_exact_empty_listing(self):
        result = self.execute_fake(inspect_status=1, listed_ids="", list_status=0)
        self.assertEqual(result["action"], "completed")
        self.assert_container_list_scoped_to_own_run()
        self.assertFalse(any("rm" in argv for argv, _ in self.calls))
        self.assertFalse((self.root / "private/coding_workbench/.cleanup-review-required").exists())

    def test_timeout_confirmed_absent_does_not_quarantine(self):
        with self.assertRaises(subprocess.TimeoutExpired):
            self.execute_fake(timeout=True, inspect_status=1, listed_ids="", list_status=0)
        self.assert_container_list_scoped_to_own_run()
        self.assertFalse(any("rm" in argv for argv, _ in self.calls))
        self.assertFalse((self.root / "private/coding_workbench/.cleanup-review-required").exists())
        self.server.shutdown.assert_called_once()
        self.server.server_close.assert_called_once()

    def test_inspect_failure_present_or_failed_listing_persists_quarantine(self):
        cases = (("present", "synthetic-container-id\n", 0, False, 0),
                 ("listing-failed", "", 1, False, 0),
                 ("timeout-present", "synthetic-container-id\n", 0, True, 0),
                 ("worker-failed-present", "synthetic-container-id\n", 0, False, 1))
        for name, ids, status, timeout, worker_status in cases:
            with self.subTest(case=name), patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.root / name)}):
                with self.assertRaises(wb.CleanupUnconfirmed):
                    self.execute_fake(inspect_status=1, listed_ids=ids, list_status=status,
                                      timeout=timeout, worker_status=worker_status)
                self.assert_container_list_scoped_to_own_run()
                self.assertFalse(any("rm" in argv for argv, _ in self.calls))
                self.assert_quarantined_and_restart_blocked()

    def test_remove_errors_persist_quarantine_after_success_or_timeout(self):
        for timeout in (False, True):
            for kind in ("exit", "timeout", "oserror"):
                name = kind + ("-worker-timeout" if timeout else "-worker-success")
                error = {"exit": subprocess.CalledProcessError(1, ["docker", "rm"]),
                         "timeout": subprocess.TimeoutExpired(["docker", "rm"], 20),
                         "oserror": OSError("synthetic daemon failure")}[kind]
                with self.subTest(case=name), patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.root / name)}):
                    with self.assertRaises(wb.CleanupUnconfirmed):
                        self.execute_fake(timeout=timeout, cleanup_error=error)
                    removals = [argv for argv, _ in self.calls if "rm" in argv]
                    self.assertEqual(removals, [["docker", "--host", "unix:///var/run/docker.sock",
                                                "rm", "--force", self.run_id]])
                    self.assert_quarantined_and_restart_blocked()

    def test_inspect_and_listing_exceptions_persist_quarantine(self):
        for name, changes in (
                ("inspect-timeout", {"inspect_error": subprocess.TimeoutExpired(["docker", "inspect"], 15)}),
                ("inspect-oserror", {"inspect_error": OSError("synthetic inspect failure")}),
                ("listing-timeout", {"inspect_status": 1, "list_error": subprocess.TimeoutExpired(["docker", "container", "ls"], 15)}),
                ("listing-oserror", {"inspect_status": 1, "list_error": OSError("synthetic listing failure")})):
            with self.subTest(case=name), patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.root / name)}):
                with self.assertRaises(wb.CleanupUnconfirmed):
                    self.execute_fake(**changes)
                self.assertFalse(any("rm" in argv for argv, _ in self.calls))
                self.assert_quarantined_and_restart_blocked()

    def test_git_control_tamper_refuses_success_without_git_repair(self):
        with self.assertRaisesRegex(ValueError, "Git control file changed"):
            self.execute_fake(tamper=True)
        self.git.assert_not_called()


class BrokerTests(OfflineCase):
    def broker(self, **kwargs):
        return broker_module.Broker("http://127.0.0.1:11434", MODEL, **kwargs)

    def test_local_inventory_guard_with_fake_http_connection(self):
        good = {"name": MODEL, "digest": DIGEST}
        cases = [([], False), ([good], True), ([dict(good, digest="sha256:" + DIGEST)], True),
                 ([dict(good, remote_host="https://evil.invalid")], False),
                 ([dict(good, remote_model="remote")], False), ([good, good], False),
                 ([dict(good, name="other")], False), ([dict(good, digest="latest")], False),
                 ([dict(good, digest=None)], False), ([None], False), ({}, False)]
        for rows, allowed in cases:
            with self.subTest(rows=rows):
                connection = Mock()
                connection.getresponse.return_value = Mock(status=200, read=Mock(return_value=json.dumps({"models": rows}).encode()))
                with patch.object(http.client, "HTTPConnection", return_value=connection) as factory:
                    if allowed:
                        self.assertEqual(self.broker().local_model(), rows[0]["digest"])
                    else:
                        with self.assertRaises(ValueError):
                            self.broker().local_model()
                factory.assert_called_once_with("127.0.0.1", 11434, timeout=10)
                connection.request.assert_called_once_with("GET", "/api/tags")
                connection.close.assert_called_once()

    def test_inventory_bad_status_oversize_and_invalid_json_close_connection(self):
        for status, raw in ((503, b"{}"), (200, b"x" * (broker_module.MAX_BODY + 1)),
                            (200, b"not-json"), (200, b"[]"), (200, b'{"models":null}')):
            connection = Mock()
            connection.getresponse.return_value = Mock(status=status, read=Mock(return_value=raw))
            with patch.object(http.client, "HTTPConnection", return_value=connection), self.assertRaises(ValueError):
                self.broker().local_model()
            connection.close.assert_called_once()

    def test_switch_pull_delete_and_path_tricks_rejected_without_budget_consumption(self):
        broker = self.broker()
        cases = [("POST", "/api/pull"), ("DELETE", "/api/delete"), ("POST", "/api/delete"),
                 ("POST", "/api/create"), ("PUT", "/api/show"), ("GET", "/api/tags?x=1"),
                 ("GET", "/api/tags#x"), ("GET", "http://evil.invalid/api/tags"),
                 ("POST", "/v1/chat/completions/")]
        for method, path in cases:
            with self.subTest(method=method, path=path), self.assertRaises(ValueError):
                broker.authorize(method, path, json.dumps({"model": MODEL}).encode())
        for body in ({"model": "other"}, {}, [], {"model": MODEL + "-cloud"}):
            with self.assertRaises(ValueError):
                broker.authorize("POST", "/v1/chat/completions", json.dumps(body).encode())
        self.assertEqual(broker.remaining, 16)
        self.http.assert_not_called()

    def test_output_token_limits_and_default_caps(self):
        for path, default in (("/v1/chat/completions", "max_tokens"), ("/v1/responses", "max_output_tokens")):
            body = json.loads(self.broker().authorize("POST", path, json.dumps({"model": MODEL}).encode()))
            self.assertEqual(body[default], 2048)
            for field in ("max_tokens", "max_completion_tokens", "max_output_tokens"):
                for value in (0, -1, 2049, True, False, 1.5, "100", None):
                    with self.subTest(path=path, field=field, value=value), self.assertRaises(ValueError):
                        self.broker().authorize("POST", path, json.dumps({"model": MODEL, field: value}).encode())
                body = json.loads(self.broker().authorize("POST", path, json.dumps({"model": MODEL, field: 1}).encode()))
                self.assertEqual(body[field], 1)

    def test_body_request_and_wallclock_budgets(self):
        broker = self.broker(requests=2)
        with self.assertRaises(ValueError):
            broker.authorize("GET", "/api/tags", b"body")
        with self.assertRaises(ValueError):
            broker.authorize("POST", "/api/show", b"x" * (broker_module.MAX_BODY + 1))
        self.assertEqual(broker.remaining, 2)
        self.assertIsNone(broker.authorize("GET", "/api/version", b""))
        broker.authorize("POST", "/api/show", json.dumps({"model": MODEL}).encode())
        with self.assertRaisesRegex(ValueError, "budget"):
            broker.authorize("GET", "/api/tags", b"")
        with self.assertRaisesRegex(ValueError, "budget"):
            self.broker(seconds=0).authorize("GET", "/api/tags", b"")

    def test_concurrent_requests_cannot_overdraw_budget(self):
        broker = self.broker(requests=3)
        outcomes = []
        def request():
            try:
                broker.authorize("GET", "/api/version", b"")
                outcomes.append(True)
            except ValueError:
                outcomes.append(False)
        threads = [threading.Thread(target=request) for _ in range(12)]
        for thread in threads:
            thread.start()
        for thread in threads:
            thread.join(timeout=2)
            self.assertFalse(thread.is_alive())
        self.assertEqual(sum(outcomes), 3)
        self.assertEqual(broker.remaining, 0)

    def fake_handler(self, body, headers=None, response_status=200, response_body=b"{}"):
        broker = self.broker()
        handler = broker_module.handler(broker).__new__(broker_module.handler(broker))
        handler.command = "POST"
        handler.path = "/v1/chat/completions"
        handler.headers = {"Content-Length": str(len(body)), **(headers or {})}
        handler.connection = Mock()
        handler.rfile = io.BytesIO(body)
        handler.wfile = io.BytesIO()
        for name in ("send_response", "send_header", "end_headers", "send_error"):
            setattr(handler, name, Mock())
        connection = Mock()
        connection.getresponse.return_value = Mock(status=response_status, read=Mock(return_value=response_body))
        connection.getresponse.return_value.getheader.return_value = "application/json"
        with patch.object(http.client, "HTTPConnection", return_value=connection) as factory:
            handler.forward()
        return handler, connection, factory

    def test_forward_strips_credentials_and_preserves_bounded_body(self):
        raw = json.dumps({"model": MODEL, "messages": []}).encode()
        handler, connection, factory = self.fake_handler(raw, {"Authorization": "Bearer synthetic", "Cookie": "synthetic"})
        factory.assert_called_once_with("127.0.0.1", 11434, timeout=60)
        method, path, body, headers = connection.request.call_args.args
        self.assertEqual((method, path), ("POST", "/v1/chat/completions"))
        self.assertEqual(headers, {"Content-Type": "application/json"})
        self.assertEqual(json.loads(body)["max_tokens"], 2048)
        handler.send_response.assert_called_once_with(200)
        handler.send_error.assert_not_called()
        connection.getresponse.return_value.read.assert_called_once_with(broker_module.MAX_RESPONSE + 1)
        connection.close.assert_called_once()

    def test_forward_refuses_bad_framing_without_contacting_backend(self):
        for body, headers in ((b"", {"Transfer-Encoding": "chunked"}),
                              (b"", {"Content-Length": "-1"}),
                              (b"", {"Content-Length": "invalid"}),
                              (b"", {"Content-Length": str(broker_module.MAX_BODY + 1)}),
                              (b"{}", {"Content-Length": "5"})):
            with self.subTest(headers=headers):
                handler, _, factory = self.fake_handler(body, headers)
                factory.assert_not_called()
                self.assertEqual(handler.send_error.call_args.args[0], 403)

    def test_forward_refuses_redirects_and_oversized_responses(self):
        raw = json.dumps({"model": MODEL}).encode()
        for status, body in ((302, b"redirect"), (200, b"x" * (broker_module.MAX_RESPONSE + 1))):
            with self.subTest(status=status):
                handler, connection, _ = self.fake_handler(raw, response_status=status, response_body=body)
                self.assertEqual(handler.send_error.call_args.args[0], 403)
                handler.send_response.assert_not_called()
                self.assertEqual(handler.wfile.getvalue(), b"")
                connection.close.assert_called_once()


class WorkerAdapterTests(OfflineCase):
    def test_adapter_config_permissions_and_local_endpoint(self):
        for role in ("plan", "review", "test", "implement", "untrusted"):
            config = worker.configurations("opencode", MODEL, role)
            self.assertEqual(config["permission"]["*"], "deny")
            self.assertEqual(config["permission"]["edit"], "allow" if role == "implement" else "deny")
            self.assertEqual(config["enabled_providers"], ["ollama"])
            codex = worker.configurations("codex_cli", MODEL, role)
            self.assertIn('sandbox_mode = "' + ("workspace-write" if role == "implement" else "read-only") + '"', codex)
            self.assertIn("requires_openai_auth = false", codex)
            self.assertIn('base_url = "http://127.0.0.1:8123/v1"', codex)
        aider = worker.configurations("aider", MODEL, "implement")
        self.assertFalse(aider["auto-commits"])
        self.assertFalse(aider["analytics"])

    def test_commands_are_argv_not_shell_and_test_role_never_runs_agent(self):
        prompt = "synthetic; $(do-not-execute) & --flag"
        with patch.object(Path, "read_text", return_value=prompt):
            for agent in AGENTS:
                argv = worker.command(agent, "plan", MODEL)
                self.assertIsInstance(argv, list)
                self.assertNotIn("sh", argv)
                self.assertNotIn("bash", argv)
                self.assertEqual(worker.command(agent, "test", MODEL),
                                 ["python3", "-B", "-m", "unittest", "discover", "-s", "tests", "-v"])
                if agent != "openhands":
                    self.assertIn("Aufgabe: " + prompt, argv)
            with self.assertRaises(ValueError):
                worker.command("unknown", "plan", MODEL)
        self.process.assert_not_called()

    def test_worker_connects_only_to_broker_model_socket(self):
        fake = Mock()
        with patch.object(worker.socket, "AF_UNIX", 1, create=True), \
                patch.object(worker.socket, "socket", return_value=fake) as factory:
            connection = worker.UnixConnection("localhost")
            connection.connect()
        factory.assert_called_once_with(1, socket.SOCK_STREAM)
        fake.connect.assert_called_once_with("/broker/model.sock")
        fake.settimeout.assert_called_once_with(90)

    def test_missing_unix_server_never_falls_back_to_tcp(self):
        with patch.object(broker_module, "socketserver", Mock(spec=[])), \
                patch.object(broker_module, "UnixHTTPServer") as server, \
                self.assertRaisesRegex(ValueError, "no TCP fallback"):
            broker_module.start(self.root / "model.sock", Mock())
        server.assert_not_called()


@unittest.skipUnless(os.name == "posix" and hasattr(socket, "AF_UNIX"), "POSIX-only short AF_UNIX integration")
class UnixBrokerIntegrationTests(unittest.TestCase):
    def test_fake_loopback_ollama_over_unix_socket(self):
        seen = []
        class Ollama(BaseHTTPRequestHandler):
            def log_message(self, *_args):
                pass
            def do_GET(self):
                self.reply()
            def do_POST(self):
                self.reply()
            def reply(self):
                body = self.rfile.read(int(self.headers.get("Content-Length", "0")))
                seen.append((self.command, self.path, dict(self.headers), body))
                payload = json.dumps({"models": [{"name": MODEL, "digest": DIGEST}]}).encode()
                self.send_response(200)
                self.send_header("Content-Length", str(len(payload)))
                self.end_headers()
                self.wfile.write(payload)

        with tempfile.TemporaryDirectory(prefix="wb-", dir="/tmp") as temporary, \
                patch.object(subprocess, "run", side_effect=AssertionError("No processes")):
            backend = ThreadingHTTPServer(("127.0.0.1", 0), Ollama)
            thread = threading.Thread(target=backend.serve_forever, daemon=True)
            thread.start()
            broker = broker_module.Broker("http://127.0.0.1:" + str(backend.server_port), MODEL, requests=8)
            server = None
            try:
                self.assertEqual(broker.local_model(), DIGEST)
                path = Path(temporary) / "model.sock"
                server = broker_module.start(path, broker)
                self.assertEqual(stat.S_IMODE(path.stat().st_mode), 0o600)
                self.assertEqual(sorted(p.name for p in Path(temporary).iterdir()), ["model.sock"])
                def request(method, route, body=None, headers=None):
                    connection = http.client.HTTPConnection("localhost", timeout=3)
                    connection.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
                    connection.sock.settimeout(3)
                    connection.sock.connect(str(path))
                    try:
                        connection.request(method, route, body, headers or {})
                        response = connection.getresponse()
                        return response.status, response.read()
                    finally:
                        connection.close()
                status, _ = request("POST", "/v1/chat/completions", json.dumps({"model": MODEL}),
                                    {"Authorization": "Bearer synthetic-not-a-key", "X-Api-Key": "synthetic"})
                self.assertEqual(status, 200)
                headers = {key.lower(): value for key, value in seen[-1][2].items()}
                self.assertNotIn("authorization", headers)
                self.assertNotIn("x-api-key", headers)
                self.assertEqual(json.loads(seen[-1][3])["max_tokens"], 2048)
                count = len(seen)
                for method, route, body, headers in (
                        ("POST", "/api/pull", json.dumps({"model": MODEL}), {}),
                        ("POST", "/v1/chat/completions", json.dumps({"model": "other"}), {}),
                        ("POST", "/api/show", "", {"Content-Length": str(broker_module.MAX_BODY + 1)}),
                        ("POST", "/api/show", "", {"Transfer-Encoding": "chunked"})):
                    self.assertEqual(request(method, route, body, headers)[0], 403)
                self.assertEqual(len(seen), count)
            finally:
                if server is not None:
                    server.shutdown()
                    server.server_close()
                backend.shutdown()
                backend.server_close()
                thread.join(timeout=3)


if __name__ == "__main__":
    unittest.main()
