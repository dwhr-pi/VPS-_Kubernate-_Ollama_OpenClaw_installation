"""Offline regressions for shell tool interfaces; never execute an installer."""

import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
BASH = "C:/Program Files/Git/bin/bash.exe" if os.name == "nt" else shutil.which("bash")


@unittest.skipUnless(BASH and Path(BASH).is_file(), "Bash is required")
class ShellToolContracts(unittest.TestCase):
    def bash(self, script, *args):
        return subprocess.run(
            [BASH, "--noprofile", "--norc", "-c", script, "fixture", *args],
            cwd=ROOT,
            text=True,
            encoding="utf-8",
            capture_output=True,
            timeout=45,
            env={key: value for key, value in os.environ.items()
                 if key not in ("BASH_ENV", "ENV", "SHELLOPTS", "BASHOPTS")},
        )

    def tool(self, name):
        return (ROOT / "scripts" / "tools" / name).read_text(encoding="utf-8")

    def test_command_failure_branches(self):
        # Execute only the real command/error blocks, with every command mocked.
        cases = {
            "flowise_install.sh": ["pnpm install", "pnpm build"],
            "openclaw_install.sh": [
                'run_with_retry "$OPENCLAW_NETWORK_RETRY_ATTEMPTS" '
                '"$OPENCLAW_NETWORK_RETRY_DELAY_SECONDS" pnpm install',
                "pnpm build",
            ],
            "zenbot_trader_install.sh": ["pnpm install", "pnpm build"],
            "kimi2_install.sh": ['git clone "$KIMI2_REPO" "$KIMI2_DIR"'],
            "kimi2_uninstall.sh": ['sudo rm -rf "$KIMI2_DIR"'],
        }
        mocks = """
set -eu
RED= YELLOW= NC= KIMI2_REPO=fixture KIMI2_DIR=unused
OPENCLAW_NETWORK_RETRY_ATTEMPTS=2 OPENCLAW_NETWORK_RETRY_DELAY_SECONDS=0
pnpm() { return "$fixture_rc"; }
git() { return "$fixture_rc"; }
sudo() { return "$fixture_rc"; }
run_with_retry() { shift 2; "$@"; }
"""
        for name, commands in cases.items():
            for command in commands:
                match = re.search(
                    r"(?m)^\s*if ! " + re.escape(command) + r"; then\n.*?^\s*fi$",
                    self.tool(name), re.S,
                )
                self.assertIsNotNone(match, (name, command))
                block = match.group(0)
                for rc in (0, 9):
                    with self.subTest(tool=name, command=command, rc=rc):
                        result = self.bash(
                            mocks + f"\nfixture_rc={rc}\n" + block
                            + "\nprintf 'fixture-reached-end\\n'\n"
                        )
                        optional = name == "zenbot_trader_install.sh" and command == "pnpm build"
                        expected = 0 if rc == 0 or optional else 1
                        self.assertEqual(result.returncode, expected, result.stderr)
                        self.assertEqual("fixture-reached-end" in result.stdout, expected == 0)
                        self.assertEqual("Fehler" in result.stdout or "fehlgeschlagen" in result.stdout, rc != 0)

    def test_llama_build_command_is_deferred(self):
        metadata = self.tool("llama_cpp_toolchain_install.sh").split("\nsource ", 1)[0]
        result = self.bash(
            "set -eu\nnproc() { echo 'unexpected-nproc' >&2; return 99; }\n"
            + metadata + '\nprintf "%s" "$TOOL_POST_INSTALL"\n'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, "")
        self.assertEqual(
            result.stdout,
            'cmake -S . -B build -G Ninja && cmake --build build --parallel "$(nproc)"',
        )

    def test_mysql_identifier_escaping_is_literal(self):
        function = re.search(
            r"^prepare_mysql_database_for_huginn\(\) \{\n.*?^\}",
            self.tool("huginn_install.sh"), re.M | re.S,
        )
        self.assertIsNotNone(function)
        lines = function.group().splitlines()
        assignments = "\n".join(
            line for line in lines
            if line.strip().startswith(("db_name_ident=", "db_user_ident="))
        )
        self.assertTrue(assignments)
        identifier = "a`b``c$(not_a_command)"
        result = self.bash(
            'set -eu\ndb_name="$1"; db_user="$1"\n' + assignments
            + '\nprintf "%s\\n" "$db_name_ident" "$db_user_ident"', identifier,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), [identifier.replace("`", "``")] * 2)

    def test_queue_status_is_read_only_and_tolerates_cat_failure(self):
        script = (ROOT / "scripts/tools/queue_manager_install.sh").as_posix()
        with tempfile.TemporaryDirectory(prefix="shell-queue-fixture-") as directory:
            queue = Path(directory) / "queue"
            for state in ("absent", "readable", "read-error"):
                with self.subTest(state=state):
                    if state != "absent":
                        queue.mkdir(exist_ok=True)
                        (queue / "queue-policy.json").write_text('{"fixture": true}\n')
                    prefix = "cat() { return 7; }; " if state == "read-error" else ""
                    result = self.bash(
                        prefix + 'QUEUE_MANAGER_DIR="$1"; export QUEUE_MANAGER_DIR; source "$2" --status',
                        queue.as_posix(), script,
                    )
                    self.assertEqual(result.returncode, 0, result.stderr)
                    self.assertIn("Queue Manager Status", result.stdout)
                    if state == "absent":
                        self.assertFalse(queue.exists())
                    else:
                        self.assertEqual((queue / "queue-policy.json").read_text(), '{"fixture": true}\n')
                    if state == "readable":
                        self.assertIn('"fixture": true', result.stdout)

    def test_browser_use_delegates_without_losing_arguments(self):
        for action in ("install", "uninstall"):
            with self.subTest(action=action):
                wrapper = (ROOT / f"scripts/tools/browser_use_{action}.sh").as_posix()
                # A shell function intercepts exec before Python can run.
                result = self.bash(
                    'set -eu\nexec() { printf "%s\\n" "$@"; }\n'
                    'GAP_TOOLS_PYTHON_BIN=fixture-python source "$1" --dry-run "two words"',
                    wrapper,
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                lines = result.stdout.splitlines()
                self.assertEqual(lines[:2], ["fixture-python", "-B"])
                self.assertTrue(lines[2].endswith("/scripts/tools/helpers/gap_tools.py"))
                self.assertEqual(lines[3:], ["browser_use", action, "--dry-run", "two words"])


if __name__ == "__main__":
    unittest.main()
