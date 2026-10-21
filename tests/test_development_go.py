"""Mocked Go/Git lifecycle tests; never compiles, downloads or enters WSL."""
from contextlib import redirect_stdout
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import stat
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
with mock.patch.object(sys, "path", [str(ROOT / "scripts/tools/helpers"), *sys.path]):
    spec = importlib.util.spec_from_file_location("development_go", ROOT / "scripts/tools/helpers/development_go.py")
    go = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(go)


class DevelopmentGoTests(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.root = Path(tmp.name) / "private"
        self.commands = []
        self.output = io.StringIO()
        capture = redirect_stdout(self.output)
        capture.__enter__()
        self.addCleanup(capture.__exit__, None, None, None)
        patch = mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(self.root),
                                ANTHROPIC_API_KEY="not-inherit", GOFLAGS="-malicious",
                                GOTOOLCHAIN="auto", GOPRIVATE="not-inherit")
        patch.start()
        self.addCleanup(patch.stop)

    def fetch(self, base, source, spec):
        for name in spec["files"]:
            path = source / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("fixture", encoding="utf-8")

    def process(self, command, cwd, env, capture=False, timeout=1800):
        self.commands.append(command)
        self.assertNotIn("ANTHROPIC_API_KEY", env)
        self.assertEqual(env["GOTOOLCHAIN"], "local")
        self.assertEqual(env["GOENV"], "off")
        self.assertEqual(env["GOFLAGS"], "")
        self.assertEqual(env["GOPRIVATE"], "")
        self.assertEqual(env["CGO_ENABLED"], "0")
        if command[1:] == ["version"]:
            return SimpleNamespace(stdout="go version go1.99.0 fixture/amd64\n")
        if command[1:3] == ["version", "-m"]:
            return SimpleNamespace(stdout="fixture:\n\tpath\tfixture/main\n")
        if "build" in command:
            self.assertIn("-mod=readonly", command)
            self.assertIn("-p=2", command)
            self.assertIn("-buildvcs=false", command)
            Path(command[command.index("-o") + 1]).write_bytes(b"mock-Go-binary-not-executable")
        return SimpleNamespace(stdout="")

    def invoke(self, tool="kubeconform", action="install", *args):
        with mock.patch.object(go, "fetch", side_effect=self.fetch), \
                mock.patch.object(go, "verify"), mock.patch.object(go, "budget"), \
                mock.patch.object(go.shutil, "which", return_value="fake-go"), \
                mock.patch.object(go, "run", side_effect=self.process):
            return go.main([tool, action, *args])

    def test_all_seven_recipes_install_then_unregister_owned_binary(self):
        self.assertEqual(len(go.TOOLS), 7)
        for key, spec in go.TOOLS.items():
            self.assertEqual(self.invoke(key), 0)
            base, source, marker = go.paths(key)
            binary = go.installed(base, marker, spec)
            self.assertTrue(binary.is_file())
            self.assertFalse(json.loads(marker.read_text())["application_tested"])
            self.assertFalse(list(base.glob("build-job-*")))
            self.assertFalse(list(base.glob("marker-*")))
            self.assertFalse((base / "operation.lock").exists())
            self.invoke(key, "uninstall")
            self.assertFalse(binary.exists())
            self.assertFalse(marker.exists())
            self.assertTrue(source.exists())
        self.assertTrue(list((self.root / "install_logs").glob("*.log")))
        self.assertNotIn("not-inherit", self.output.getvalue())

    def test_dry_runs_are_write_free_without_go_or_git(self):
        with mock.patch.object(go, "run") as process, mock.patch.object(go, "fetch") as fetch:
            for key in go.TOOLS:
                for action in ("install", "update", "repair", "uninstall"):
                    self.assertEqual(go.main([key, action, "--dry-run"]), 0)
            process.assert_not_called()
            fetch.assert_not_called()
        self.assertFalse(self.root.exists())

    def test_read_only_status_never_builds_or_downloads(self):
        for key in go.TOOLS:
            self.assertEqual(self.invoke(key, "status"), 0)
            self.assertEqual(self.invoke(key, "doctor"), 1)
        self.assertFalse(self.root.exists())
        self.assertEqual(self.commands, [])

    def test_idempotent_update_never_rebuilds(self):
        self.invoke()
        self.commands.clear()
        self.invoke(action="update")
        self.assertEqual(self.commands, [])

    def test_modified_binary_is_not_deleted_or_repaired(self):
        self.invoke()
        base, _, marker = go.paths("kubeconform")
        binary = go.installed(base, marker, go.TOOLS["kubeconform"])
        binary.write_bytes(b"user-modified")
        for action in ("uninstall", "repair"):
            with self.assertRaisesRegex(ValueError, "veraendert"):
                self.invoke(action=action)
        self.assertEqual(binary.read_bytes(), b"user-modified")
        self.assertTrue(marker.exists())

    def test_binary_without_marker_is_preserved(self):
        base, _, _ = go.paths("kubeconform")
        base.mkdir(parents=True)
        binary = base / ("kubeconform.exe" if os.name == "nt" else "kubeconform")
        binary.write_bytes(b"foreign")
        with self.assertRaisesRegex(ValueError, "Besitznachweis"):
            self.invoke()
        self.assertEqual(binary.read_bytes(), b"foreign")

    def test_build_failure_removes_only_new_job_and_writes_current_log(self):
        original = self.process

        def fail_build(command, *args, **kwargs):
            if "build" in command:
                raise ValueError("fixture build failure")
            return original(command, *args, **kwargs)

        with mock.patch.object(go, "fetch", side_effect=self.fetch), \
                mock.patch.object(go, "verify"), mock.patch.object(go, "budget"), \
                mock.patch.object(go.shutil, "which", return_value="fake-go"), \
                mock.patch.object(go, "run", side_effect=fail_build):
            with self.assertRaisesRegex(ValueError, "build failure"):
                go.main(["kubeconform"])
        base, source, marker = go.paths("kubeconform")
        self.assertTrue(source.exists())
        self.assertFalse(marker.exists())
        self.assertFalse(list(base.glob("build-job-*")))
        log, = (self.root / "install_logs").glob("*.log")
        self.assertIn("Ergebnis: failed", log.read_text())
        self.assertIn("Rollback", log.read_text())

    def test_marker_failure_rolls_back_new_binary(self):
        with mock.patch.object(go.os, "replace", side_effect=OSError("marker fixture")):
            with self.assertRaises(OSError):
                self.invoke()
        base, _, marker = go.paths("kubeconform")
        self.assertFalse(marker.exists())
        self.assertFalse(list(base.glob("kubeconform*")))
        self.assertFalse(list(base.glob("build-job-*")))

    def test_heavy_opt_in_is_enforced_before_build(self):
        spec = go.TOOLS["golangci_lint"]
        with mock.patch.object(go, "resources"), mock.patch.dict(os.environ, INSTALL_HEAVY_TOOLS="0"):
            with self.assertRaisesRegex(ValueError, "INSTALL_HEAVY_TOOLS"):
                go.budget(self.root, spec)

    def test_low_disk_error_is_not_success(self):
        with mock.patch.object(go, "resources"), \
                mock.patch.object(go.shutil, "disk_usage", return_value=SimpleNamespace(free=1)):
            with self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
                go.budget(self.root, go.TOOLS["delve"])

    def test_old_go_rejected_before_fetch(self):
        with mock.patch.object(go, "budget"), mock.patch.object(go.shutil, "which", return_value="fake-go"), \
                mock.patch.object(go, "run", return_value=SimpleNamespace(stdout="go version go1.20.0 linux/amd64")), \
                mock.patch.object(go, "fetch") as fetch:
            with self.assertRaisesRegex(ValueError, "zu alt"):
                go.main(["tflint"])
            fetch.assert_not_called()

    def test_registry_wrappers_menu_and_catalog_have_all_pins(self):
        registry = json.loads((ROOT / "config/tools.yml").read_text())["tools"]
        catalog = json.loads((ROOT / "config/development_toolchains.json").read_text())["tools"]
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        native = (ROOT / "scripts/helpers/native_tool_status.sh").read_text()
        for key, spec in go.TOOLS.items():
            row, = [row for row in registry if row["id"] == key]
            self.assertEqual(row["source_commit"], spec["pin"])
            self.assertFalse(row["auto_install"])
            self.assertEqual(row["ports"], [])
            self.assertEqual(len([r for r in catalog if r.get("registry_id") == key]), 1)
            self.assertIn(f'TOOL_SCRIPT_NAMES["{spec["name"]}"]="{key}"', menu)
            self.assertIn(f'{spec["name"]}) marker={key}/build-ready.json', native)
            for action in ("install", "update", "uninstall", "check", "doctor", "status"):
                text = (ROOT / f"scripts/tools/{key}_{action}.sh").read_text()
                self.assertIn(f'development_go.py" {key} {action} "$@"', text)

    def test_relative_and_repository_workspaces_rejected(self):
        for raw in ("relative", str(ROOT)):
            with mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=raw), self.assertRaises(ValueError):
                go.paths("delve")

    def test_subprocess_failure_is_bounded(self):
        with mock.patch.object(go.subprocess, "run", side_effect=subprocess.TimeoutExpired("fake", 10)):
            with self.assertRaisesRegex(ValueError, "Zeitlimit"):
                go.run(["fake"], self.root, {}, capture=True)

    def test_path_guard_needs_only_one_lstat_per_component(self):
        target = self.root / "not-created"
        info = SimpleNamespace(st_mode=stat.S_IFDIR, st_file_attributes=0)
        with mock.patch.object(Path, "lstat", return_value=info) as lstat:
            self.assertEqual(go.checked(target), target)
        self.assertEqual(lstat.call_count, len(target.parents) + 1)

    def test_path_guard_still_rejects_links_and_windows_reparse_points(self):
        for info in (SimpleNamespace(st_mode=stat.S_IFLNK, st_file_attributes=0),
                     SimpleNamespace(st_mode=stat.S_IFDIR, st_file_attributes=0x400)):
            with mock.patch.object(Path, "lstat", return_value=info), self.assertRaisesRegex(ValueError, "Symlink/Junction"):
                go.checked(self.root)


if __name__ == "__main__":
    unittest.main()
