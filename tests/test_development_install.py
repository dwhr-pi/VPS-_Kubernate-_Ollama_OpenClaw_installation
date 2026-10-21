"""Synthetic lifecycle tests. No network, real builds, Docker, WSL or installations."""
from contextlib import redirect_stdout
from copy import deepcopy
import importlib.util
import io
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("development_install", ROOT / "scripts/quality/development_install.py")
dev = importlib.util.module_from_spec(spec)
spec.loader.exec_module(dev)


class DevelopmentInstallTests(unittest.TestCase):
    def row(self):
        return {"id": "fixture", "repo": "official/fixture", "source": "https://github.com/official/fixture",
                "disk_mb": 1, "ram_mb": 1,
                "recipe": {"mode": "native-build", "ref": "v1", "requirements": [["git"]],
                           "steps": [{"argv": ["fake-build"], "cwd": "source"}],
                           "artifacts": [["payload/bin/fixture"]]}}

    def fake_run(self, argv, cwd, env, log, capture=False, timeout=7200):
        if argv[:2] == ["git", "init"]:
            Path(argv[2]).mkdir()
        if argv[:2] == ["git", "rev-parse"]:
            return "a" * 40
        if argv[0] == "fake-build":
            (cwd.parent / "payload/bin/fixture").write_bytes(b"synthetic build")
        return ""

    def do_install(self, base, row=None, ref=None, fake=None):
        with mock.patch.object(dev, "budget"), mock.patch.object(dev, "build_host_supported", return_value=True), \
                mock.patch.object(dev.shutil, "which", return_value="fixture-command"), \
                mock.patch.object(dev, "run", side_effect=fake or self.fake_run), redirect_stdout(io.StringIO()):
            dev.install(base, row or self.row(), ref, True, io.StringIO())

    def test_all_62_have_non_placeholder_paths_or_executable_build_recipes(self):
        rows = dev.catalog()
        self.assertEqual(len(rows), 62)
        self.assertEqual(sum(row["recipe"]["mode"] == "existing" for row in rows.values()), 10)
        for row in rows.values():
            recipe = row["recipe"]
            if recipe["mode"] == "existing":
                for action in ("install", "update", "uninstall", "status"):
                    self.assertTrue(dev.existing_script(row, action).is_file())
            else:
                self.assertTrue(recipe["artifacts"])
                self.assertTrue(recipe["steps"] or recipe["mode"] == "workflow-package")
                for step in recipe["steps"]:
                    self.assertNotIn(step["argv"][0], ("docker", "sudo", "wsl", "wsl.exe"))
                    for arg in step["argv"]:
                        arg.format_map(dict(source="source", prefix="prefix", job="job", python="python"))

    def test_list_and_plan_never_run_tools_or_create_workspace(self):
        with tempfile.TemporaryDirectory() as folder:
            target = Path(folder) / "not-created"
            with mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=str(target)), \
                    mock.patch.object(dev.subprocess, "Popen", side_effect=AssertionError("No subprocess")), \
                    redirect_stdout(io.StringIO()):
                self.assertEqual(dev.main(["list"]), 0)
                self.assertEqual(dev.main(["plan", "--tool", "llvm"]), 0)
                self.assertEqual(dev.main(["status", "--tool", "llvm"]), 0)
            self.assertFalse(target.exists())

    def test_build_receipt_only_after_artifact_and_reinstall_is_idempotent(self):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder)
            self.do_install(base)
            receipt = dev.verify(base, "fixture")
            self.assertEqual(receipt["commit"], "a" * 40)
            self.assertFalse(receipt["runtime_tested"])
            self.do_install(base, fake=lambda *a, **kw: self.fail("No second build"))
            binary = base / "fixture" / receipt["generation"] / "payload/bin/fixture"
            binary.unlink()
            with self.assertRaises(ValueError):
                dev.verify(base, "fixture")

    def test_failed_build_rolls_back_only_new_generation_preserves_previous(self):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder)
            self.do_install(base)
            before = (base / "fixture/installed.json").read_bytes()
            def failed(argv, *args, **kwargs):
                if argv[0] == "fake-build":
                    raise ValueError("Speicherplatzmangel waehrend Build")
                return self.fake_run(argv, *args, **kwargs)
            with self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
                self.do_install(base, ref="v2", fake=failed)
            self.assertEqual((base / "fixture/installed.json").read_bytes(), before)
            self.assertEqual(len(list((base / "fixture").glob("generation-*"))), 1)
            dev.verify(base, "fixture")

    def test_missing_artifact_and_failed_first_install_leave_no_marker(self):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder)
            def no_artifact(argv, *args, **kwargs):
                if argv[0] == "fake-build":
                    return ""
                return self.fake_run(argv, *args, **kwargs)
            with self.assertRaisesRegex(ValueError, "Buildartefakt fehlt"):
                self.do_install(base, fake=no_artifact)
            self.assertFalse((base / "fixture/installed.json").exists())
            self.assertEqual(list((base / "fixture").glob("generation-*")), [])

    def test_low_disk_blocks_before_fetch_and_current_failure_is_logged(self):
        with tempfile.TemporaryDirectory() as folder:
            with mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=folder), \
                    mock.patch.object(dev, "build_host_supported", return_value=True), \
                    mock.patch.object(dev, "budget", side_effect=ValueError("Speicherplatzmangel")), \
                    mock.patch.object(dev, "run", side_effect=AssertionError("No download")), \
                    redirect_stdout(io.StringIO()), self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
                dev.main(["install", "--tool", "bashdb", "--accept-build-risk"])
            logs = list((Path(folder) / "development-tools/logs").glob("*.log"))
            self.assertEqual(len(logs), 1)
            self.assertIn("failed; Speicherplatzmangel", logs[0].read_text())
            self.assertFalse((Path(folder) / "development-tools/bashdb").exists())

    def test_global_lock_no_parallel_build_and_does_not_remove_foreign_lock(self):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder)
            with dev.lock(base):
                with self.assertRaises(ValueError):
                    with dev.lock(base):
                        self.fail("Parallel build")
                self.assertTrue((base / ".operation.lock").exists())
            self.assertFalse((base / ".operation.lock").exists())

    def test_wrong_owner_and_modified_binary_prevent_deletion(self):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder)
            self.do_install(base)
            receipt = dev.verify(base, "fixture")
            generation = base / "fixture" / receipt["generation"]
            (generation / "payload/bin/fixture").write_bytes(b"changed")
            with self.assertRaises(ValueError):
                dev.verify(base, "fixture")
            (generation / "owner.json").write_text('{}')
            with self.assertRaises(ValueError):
                dev.remove_generation(base, "fixture", generation.name)
            self.assertTrue(generation.exists())

    def test_successful_update_and_uninstall_only_remove_active_owned_generation(self):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder) / "development-tools"
            base.mkdir()
            self.do_install(base)
            first = dev.verify(base, "fixture")["generation"]
            self.do_install(base, ref="v2")
            second = dev.verify(base, "fixture")["generation"]
            self.assertNotEqual(first, second)
            with mock.patch.object(dev, "catalog", return_value={"fixture": self.row()}), \
                    mock.patch.dict(os.environ, OPENCLAW_USER_DATA_DIR=folder), redirect_stdout(io.StringIO()):
                self.assertEqual(dev.main(["uninstall", "--tool", "fixture"]), 0)
            self.assertTrue((base / "fixture" / first).is_dir())
            self.assertFalse((base / "fixture" / second).exists())
            self.assertFalse((base / "fixture/installed.json").exists())

    def test_marker_write_failure_preserves_old_receipt(self):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder)
            self.do_install(base)
            before = (base / "fixture/installed.json").read_bytes()
            write = dev.atomic_json
            def fail_marker(path, value):
                if path.name == "installed.json":
                    raise OSError("disk full")
                write(path, value)
            with mock.patch.object(dev, "atomic_json", side_effect=fail_marker), self.assertRaises(OSError):
                self.do_install(base, ref="v2")
            self.assertEqual((base / "fixture/installed.json").read_bytes(), before)
            self.assertEqual(len(list((base / "fixture").glob("generation-*"))), 1)

    def test_verified_private_node_is_available_only_in_build_process_path(self):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder)
            row = self.row()
            row["id"] = "node_js"
            row["recipe"]["artifacts"] = [["payload/bin/node"]]
            def node_build(argv, cwd, env, log, **kwargs):
                result = self.fake_run(argv, cwd, env, log, **kwargs)
                if argv[0] == "fake-build":
                    (cwd.parent / "payload/bin/node").write_bytes(b"synthetic node")
                return result
            self.do_install(base, row=row, fake=node_build)
            original = os.environ.get("PATH", "")
            receipt = dev.verify(base, "node_js")
            expected = base / "node_js" / receipt["generation"] / "payload/bin"
            self.assertTrue(dev.private_tool_path(base).startswith(str(expected)))
            self.assertEqual(os.environ.get("PATH", ""), original)
            (expected / "node").write_bytes(b"changed")
            self.assertEqual(dev.private_tool_path(base), original)

    def test_path_traversal_and_symlink_rejected(self):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder)
            for value in ("../outside", "/outside", "..\\outside"):
                with self.assertRaises(ValueError):
                    dev.safe_relative(base, value)
            with self.assertRaises(ValueError):
                dev.remove_generation(base, "fixture", "../../outside")

    def test_workflow_is_only_pinned_package_not_active_workflow(self):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder)
            row = self.row()
            row["recipe"].update(mode="workflow-package", steps=[], artifacts=[
                ["source/action.yml"], ["payload/workflow-reference.json"]])
            def workflow(argv, cwd, env, log, **kwargs):
                value = self.fake_run(argv, cwd, env, log, **kwargs)
                if argv[:2] == ["git", "init"]:
                    (Path(argv[2]) / "action.yml").write_text("name: fixture\nruns:\n  using: node20\n")
                return value
            self.do_install(base, row=row, fake=workflow)
            receipt = dev.verify(base, "fixture")
            reference = dev.read_json(base / "fixture" / receipt["generation"] / "payload/workflow-reference.json")
            self.assertFalse(reference["enabled"])
            self.assertEqual(reference["uses"], "official/fixture@" + "a" * 40)
            self.assertEqual(list(base.rglob(".github/workflows")), [])

    def test_windows_never_launches_wsl_and_confirmation_required(self):
        with tempfile.TemporaryDirectory() as folder:
            base = Path(folder)
            with self.assertRaisesRegex(ValueError, "accept-build-risk"):
                dev.install(base, self.row(), None, False, io.StringIO())
            with mock.patch.object(dev, "build_host_supported", return_value=False), \
                    mock.patch.object(dev, "run", side_effect=AssertionError("No WSL")), \
                    self.assertRaisesRegex(ValueError, "kein automatischer WSL"):
                dev.install(base, self.row(), None, True, io.StringIO())


if __name__ == "__main__":
    unittest.main()
