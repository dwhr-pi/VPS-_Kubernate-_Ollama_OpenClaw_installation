"""Pinned ant build fixtures: no real Git, Go, CLI execution, keys or network."""
from contextlib import redirect_stdout
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
with mock.patch.object(sys, "path", [str(ROOT / "scripts/tools/helpers"), *sys.path]):
    spec = importlib.util.spec_from_file_location("anthropic_cli", ROOT / "scripts/tools/helpers/anthropic_cli.py")
    cli = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(cli)


class AnthropicCLI(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name) / "private"
        patch = mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(self.root),
                                ANTHROPIC_API_KEY="DO_NOT_INHERIT", AWS_SECRET_ACCESS_KEY="DO_NOT_INHERIT")
        patch.start()
        self.addCleanup(patch.stop)
        self.output = io.StringIO()
        capture = redirect_stdout(self.output)
        capture.__enter__()
        self.addCleanup(capture.__exit__, None, None, None)
        self.base, self.source, self.binary, self.marker = cli.paths()
        self.commands = []

    def fetch(self, base, source, specification):
        for name in specification["files"]:
            path = source / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("fixture", encoding="utf-8")
        (source / "go.mod").write_text("module github.com/anthropics/anthropic-cli\n\ngo 1.25\n", encoding="utf-8")

    def process(self, command, **kwargs):
        self.commands.append(command)
        env = kwargs["env"]
        for key in ("ANTHROPIC_API_KEY", "AWS_SECRET_ACCESS_KEY", "ANTHROPIC_BASE_URL", "GOOS", "GOARCH"):
            self.assertNotIn(key, env)
        self.assertEqual(env["GOTOOLCHAIN"], "local")
        self.assertEqual(env["CGO_ENABLED"], "0")
        self.assertEqual(env["TMPDIR"], str(self.base / "build-temp"))
        if command[1:] == ["version"]:
            return subprocess.CompletedProcess(command, 0, "go version go1.25.3 linux/amd64\n")
        if command[1] == "build":
            Path(command[command.index("-o") + 1]).write_bytes(b"fixture-ant-binary")
        if command[1:3] == ["version", "-m"]:
            return subprocess.CompletedProcess(command, 0, "fixture\n\tpath\t" + cli.PACKAGE + "\n")
        return subprocess.CompletedProcess(command, 0, "")

    def invoke(self, action="install", *flags):
        with mock.patch.object(cli, "fetch", side_effect=self.fetch), mock.patch.object(cli, "verify"), \
                mock.patch.object(cli, "budget"), mock.patch.object(cli.shutil, "which", return_value="fixture-go"), \
                mock.patch.object(cli.subprocess, "run", side_effect=self.process):
            return cli.main([action, *flags])

    def test_dry_runs_are_write_free_and_do_not_invoke_tools(self):
        with mock.patch.object(cli, "fetch") as fetch, mock.patch.object(cli, "go_tool") as go:
            for action in ("install", "update", "repair", "uninstall"):
                self.assertEqual(cli.main([action, "--dry-run"]), 0)
            fetch.assert_not_called()
            go.assert_not_called()
        self.assertFalse(self.root.exists())

    def test_unknown_and_conflicting_arguments_fail_before_writes(self):
        for args in (("--dry-run", "--unknown"), ("update", "--uninstall")):
            with mock.patch.object(sys, "stderr", io.StringIO()), self.assertRaises(SystemExit) as error:
                cli.main(list(args))
            self.assertEqual(error.exception.code, 2)
        self.assertFalse(self.root.exists())

    def test_native_build_records_only_after_artifact_validation(self):
        self.assertEqual(self.invoke(), 0)
        record = json.loads(self.marker.read_text())
        self.assertEqual(record["commit"], cli.PIN)
        self.assertEqual(record["binary_sha256"], cli.digest(self.binary))
        self.assertFalse(record["api_tested"])
        build, = [c for c in self.commands if c[1] == "build"]
        for argument in ("-mod=readonly", "-buildvcs=false", "-p=1", "./cmd/ant"):
            self.assertIn(argument, build)
        self.assertTrue(all(command[0] == "fixture-go" for command in self.commands))
        self.assertNotIn("DO_NOT_INHERIT", self.output.getvalue())

    def test_source_only_has_no_cli_or_installed_marker(self):
        self.assertEqual(self.invoke("install", "--source-only"), 0)
        self.assertTrue((self.source / "go.mod").is_file())
        self.assertFalse(self.marker.exists())
        self.assertFalse(self.binary.exists())
        self.assertEqual(self.commands, [])

    def test_update_is_idempotent_and_never_rebuilds_or_queries_api(self):
        self.invoke()
        before = self.marker.read_bytes()
        self.commands.clear()
        self.assertEqual(self.invoke("update"), 0)
        self.assertEqual(self.commands, [])
        self.assertEqual(self.marker.read_bytes(), before)

    def test_readonly_status_does_not_fetch_build_or_create_workspace(self):
        with mock.patch.object(cli, "fetch") as fetch, mock.patch.object(cli, "go_tool") as go:
            self.assertEqual(cli.main(["status"]), 0)
            self.assertEqual(cli.main(["doctor"]), 1)
            fetch.assert_not_called()
            go.assert_not_called()
        self.assertFalse(self.root.exists())

    def test_doctor_validates_hash_without_running_cli(self):
        self.invoke()
        with mock.patch.object(cli, "verify"), mock.patch.object(cli.subprocess, "run") as run:
            self.assertEqual(cli.main(["doctor"]), 0)
            self.binary.write_bytes(b"locally changed")
            self.assertEqual(cli.main(["doctor"]), 1)
            run.assert_not_called()

    def test_no_go_fails_before_clone_and_logs_current_attempt(self):
        with mock.patch.object(cli, "budget"), mock.patch.object(cli.shutil, "which", return_value=None), \
                mock.patch.object(cli, "fetch") as fetch, self.assertRaisesRegex(ValueError, "Go >=1.25 fehlt"):
            cli.main(["install", "--no-go-bootstrap"])
        fetch.assert_not_called()
        self.assertFalse(self.marker.exists())
        log, = (self.root / "install_logs").glob("anthropic_cli_install_*.log")
        self.assertIn("Go >=1.25 fehlt", log.read_text())

    def test_missing_go_bootstrap_builds_with_private_go_without_global_path_change(self):
        before = os.environ.get("PATH")
        root = self.base / "toolchain/fixture/go"
        go_binary = root / "bin" / ("go.exe" if os.name == "nt" else "go")
        key = "windows-amd64" if os.name == "nt" else "linux-amd64"

        def ensure(base, validate):
            root.mkdir(parents=True)
            validate(go_binary, root, key)
            return str(go_binary), root

        def process(command, **kwargs):
            if command[1:] == ["version"]:
                return subprocess.CompletedProcess(command, 0, "go version " + cli.private_go.VERSION + " " + key.replace("-", "/"))
            self.assertEqual(kwargs["env"]["GOROOT"], str(root))
            self.assertEqual(command[0], str(go_binary))
            return self.process(command, **kwargs)

        with mock.patch.object(cli, "fetch", side_effect=self.fetch), mock.patch.object(cli, "verify"), \
                mock.patch.object(cli, "budget"), mock.patch.object(cli.shutil, "which", return_value=None), \
                mock.patch.object(cli.private_go, "ensure", side_effect=ensure) as bootstrap, \
                mock.patch.object(cli.subprocess, "run", side_effect=process):
            self.assertEqual(cli.main(["install"]), 0)
        bootstrap.assert_called_once()
        self.assertEqual(os.environ.get("PATH"), before)
        self.assertTrue(self.marker.exists())

    def test_old_go_falls_back_to_private_toolchain(self):
        self.base.mkdir(parents=True)
        root = self.base / "toolchain/fixture/go"
        binary = str(root / "bin/go")
        with mock.patch.object(cli.shutil, "which", return_value="fixture-old-go"), \
                mock.patch.object(cli.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, "go version go1.24.9 linux/amd64")), \
                mock.patch.object(cli.private_go, "ensure", return_value=(binary, root)) as bootstrap:
            actual, env = cli.go_tool(self.base)
        self.assertEqual(actual, binary)
        self.assertEqual(env["GOROOT"], str(root))
        self.assertTrue(env["PATH"].startswith(str(root / "bin") + os.pathsep))
        bootstrap.assert_called_once()

    def test_failed_bootstrap_logs_current_failure_without_installed_marker(self):
        with mock.patch.object(cli, "budget"), mock.patch.object(cli.shutil, "which", return_value=None), \
                mock.patch.object(cli.private_go, "ensure", side_effect=ValueError("Go-Archiv-Pruefsumme fixture")), \
                mock.patch.object(cli, "fetch") as fetch, self.assertRaises(ValueError):
            cli.main(["install"])
        fetch.assert_not_called()
        self.assertFalse(self.marker.exists())
        log, = (self.root / "install_logs").glob("anthropic_cli_install_*.log")
        self.assertIn("Go-Archiv-Pruefsumme fixture", log.read_text())
        self.assertIn("2026-10-21-private-go-bootstrap", log.read_text())

    def test_bootstrap_can_be_disabled_by_environment(self):
        self.base.mkdir(parents=True)
        with mock.patch.dict(os.environ, ANTHROPIC_CLI_GO_BOOTSTRAP="0"), \
                mock.patch.object(cli.shutil, "which", return_value=None), \
                mock.patch.object(cli.private_go, "ensure") as bootstrap, self.assertRaisesRegex(ValueError, "deaktiviert"):
            cli.go_tool(self.base)
        bootstrap.assert_not_called()

    def test_source_only_and_dry_run_never_bootstrap(self):
        with mock.patch.object(cli.private_go, "ensure", side_effect=AssertionError("no bootstrap")):
            self.assertEqual(self.invoke("install", "--source-only"), 0)
            self.assertEqual(cli.main(["install", "--dry-run"]), 0)

    def test_unexpected_private_go_version_never_fetches_or_registers_cli(self):
        root = self.base / "toolchain/fixture/go"
        def ensure(base, validate):
            validate(root / "bin/go", root, "linux-amd64")
            raise AssertionError("Unexpected version must not be accepted")
        with mock.patch.object(cli, "budget"), mock.patch.object(cli.shutil, "which", return_value=None), \
                mock.patch.object(cli.private_go, "ensure", side_effect=ensure), \
                mock.patch.object(cli.subprocess, "run", side_effect=self.process), \
                mock.patch.object(cli, "fetch") as fetch, self.assertRaisesRegex(ValueError, "Version/Architektur"):
            cli.main(["install"])
        fetch.assert_not_called()
        self.assertFalse(self.marker.exists())

    def test_uninstall_never_bootstraps_or_removes_private_go(self):
        self.invoke()
        private = self.base / "toolchain/fixture/go/bin/go"
        private.parent.mkdir(parents=True)
        private.write_bytes(b"keep private build dependency")
        with mock.patch.object(cli.private_go, "ensure", side_effect=AssertionError("no bootstrap")):
            self.assertEqual(cli.main(["uninstall"]), 0)
        self.assertEqual(private.read_bytes(), b"keep private build dependency")
        self.assertFalse(self.marker.exists())

    def test_old_go_is_rejected_without_toolchain_download(self):
        self.base.mkdir(parents=True)
        with mock.patch.object(cli.shutil, "which", return_value="fixture-go"), \
                mock.patch.object(cli.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, "go version go1.24.9 linux/amd64")), \
                self.assertRaisesRegex(ValueError, "Go >=1.25"):
            cli.go_tool(self.base, allow_bootstrap=False)

    def test_low_disk_is_logged_before_fetch(self):
        with mock.patch.object(cli, "budget", side_effect=ValueError("Speicherplatzmangel")), \
                mock.patch.object(cli, "fetch") as fetch, self.assertRaises(ValueError):
            cli.main(["install"])
        fetch.assert_not_called()
        self.assertFalse(self.marker.exists())
        self.assertIn("Speicherplatzmangel", self.output.getvalue())

    def test_failed_build_and_info_mismatch_do_not_register_cli(self):
        for failure in (ValueError("build failed"), "wrong-package"):
            def failed_run(go, args, source, env, **kwargs):
                if isinstance(failure, Exception):
                    raise failure
                if args[0] == "build":
                    Path(args[args.index("-o") + 1]).write_bytes(b"fixture")
                return subprocess.CompletedProcess([], 0, "wrong-package")
            with mock.patch.object(cli, "fetch", side_effect=self.fetch), mock.patch.object(cli, "verify"), \
                    mock.patch.object(cli, "budget"), mock.patch.object(cli, "go_tool", return_value=("fixture-go", cli.build_env(self.base))), \
                    mock.patch.object(cli, "run", side_effect=failed_run), self.assertRaises(ValueError):
                cli.main(["install"])
            self.assertFalse(self.marker.exists())
            self.assertFalse(self.binary.exists())

    def test_actual_disk_budget_rejects_low_disk(self):
        with mock.patch.object(cli, "resources"), mock.patch.object(cli.shutil, "disk_usage", return_value=mock.Mock(free=0)):
            for source_only in (False, True):
                with self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
                    cli.budget(self.base, source_only)

    def test_unexpected_module_is_rejected(self):
        self.fetch(self.base, self.source, cli.SPEC)
        (self.source / "go.mod").write_text("module foreign\ngo 1.25\n")
        with mock.patch.object(cli, "verify"), self.assertRaises(ValueError):
            cli.source_ok(self.source)

    def test_publish_failure_rolls_back_only_new_binary(self):
        with mock.patch.object(cli.json, "dump", side_effect=OSError("disk full")), self.assertRaises(OSError):
            self.invoke()
        self.assertFalse(self.marker.exists())
        self.assertFalse(self.binary.exists())
        self.assertTrue((self.source / "go.mod").exists())
        self.assertFalse(list(self.base.glob("build-record-*")))
        self.assertFalse(list(self.base.glob("build-stage-*")))

    def test_uninstall_preserves_sources_and_never_removes_altered_binary(self):
        self.invoke()
        self.binary.write_bytes(b"foreign edits")
        with self.assertRaises(ValueError):
            cli.main(["uninstall"])
        self.assertEqual(self.binary.read_bytes(), b"foreign edits")
        self.binary.write_bytes(b"fixture-ant-binary")
        self.assertEqual(cli.main(["uninstall"]), 0)
        self.assertFalse(self.marker.exists())
        self.assertFalse(self.binary.exists())
        self.assertTrue((self.source / "go.mod").exists())

    def test_repair_missing_owned_binary(self):
        self.invoke()
        self.binary.unlink()
        self.assertEqual(self.invoke("repair"), 0)
        self.assertTrue(self.marker.exists())
        self.assertTrue(self.binary.exists())

    def test_foreign_binary_or_marker_is_not_replaced(self):
        self.binary.parent.mkdir(parents=True)
        self.binary.write_bytes(b"foreign")
        with self.assertRaises(ValueError):
            cli.main(["install"])
        self.assertEqual(self.binary.read_bytes(), b"foreign")
        self.marker.write_text('{"commit":"foreign"}')
        with self.assertRaises(ValueError):
            cli.main(["uninstall"])

    def test_registry_and_license_scope(self):
        rows = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
        row, = [r for r in rows if r["id"] == "anthropic_cli"]
        self.assertEqual(row["source_commit"], cli.PIN)
        self.assertEqual(row["ports"], [])
        self.assertFalse(row["auto_install"])
        self.assertEqual(row["install_mode"], "github-source-build")
        for field in ("install_script", "uninstall_script", "update_script", "doctor_script", "doc"):
            self.assertTrue((ROOT / row[field]).is_file())
        doc = (ROOT / row["doc"]).read_text(encoding="utf-8")
        for phrase in ("MIT", "Nicht mit Claude Code", "Go >=1.25", "api_tested=false", "Kein Docker", "proxy.golang.org"):
            self.assertIn(phrase.lower(), doc.lower())
        self.assertIn("--no-go-bootstrap", doc)
        self.assertIn(cli.private_go.VERSION[2:], doc)
        self.assertNotIn("Go >=1.25 vorhanden vorausgesetzt", row["security_note"])

    def test_empty_artifact_is_not_registered(self):
        original = self.process
        def empty(command, **kwargs):
            result = original(command, **kwargs)
            if command[1] == "build":
                Path(command[command.index("-o") + 1]).write_bytes(b"")
            return result
        with mock.patch.object(cli, "fetch", side_effect=self.fetch), mock.patch.object(cli, "verify"), \
                mock.patch.object(cli, "budget"), mock.patch.object(cli.shutil, "which", return_value="fixture-go"), \
                mock.patch.object(cli.subprocess, "run", side_effect=empty), self.assertRaises(ValueError):
            cli.main(["install"])
        self.assertFalse(self.marker.exists())
        self.assertFalse(self.binary.exists())


if __name__ == "__main__":
    unittest.main()
