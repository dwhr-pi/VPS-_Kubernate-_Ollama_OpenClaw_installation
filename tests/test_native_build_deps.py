"""Offline consent/package contracts; never executes apt, sudo or a build."""
from contextlib import redirect_stdout
import io
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts/tools/helpers"))
import native_build_deps as deps
import native_github_tools as tools


class BuildDependencies(unittest.TestCase):
    def setUp(self):
        self.spec = tools.TOOLS["mosquitto"]
        self.ubuntu = patch.object(deps, "ubuntu_release", return_value=True)
        self.which = patch.object(deps.shutil, "which", return_value="fixture")
        self.stdin = patch.object(deps.sys, "stdin", Mock(isatty=Mock(return_value=False)))
        for mocked in (self.ubuntu, self.which, self.stdin):
            mocked.start()
            self.addCleanup(mocked.stop)

    def test_recipe_has_required_compilers_and_library_headers(self):
        self.assertEqual(tuple(self.spec["recipe"]["apt_build_deps"]), deps.MOSQUITTO_PACKAGES)
        self.assertIn("c++", tools.requirements(self.spec))
        for name in ("cmake", "libssl-dev", "libcjson-dev", "libsqlite3-dev"):
            self.assertIn(name, deps.MOSQUITTO_PACKAGES)

    def test_installed_packages_are_idempotent_without_prompt_or_apt(self):
        with patch.object(deps, "installed", return_value=True), patch.object(deps.common, "run") as run, patch("builtins.input") as ask, redirect_stdout(io.StringIO()):
            deps.prepare(self.spec)
        run.assert_not_called()
        ask.assert_not_called()

    def test_noninteractive_missing_packages_fail_without_system_changes(self):
        output = io.StringIO()
        with patch.object(deps, "installed", side_effect=lambda name: name != "cmake"), patch.object(deps.common, "run") as run, redirect_stdout(output):
            with self.assertRaisesRegex(ValueError, "Zustimmung"):
                deps.prepare(self.spec)
        run.assert_not_called()
        self.assertIn("--install-build-deps", output.getvalue())
        self.assertIn("cmake", output.getvalue())

    def test_interactive_decline_never_runs_apt(self):
        with patch.object(deps.sys.stdin, "isatty", return_value=True), patch.object(deps, "installed", return_value=False), patch("builtins.input", return_value="n"), patch.object(deps.common, "run") as run, redirect_stdout(io.StringIO()):
            with self.assertRaises(ValueError):
                deps.prepare(self.spec)
        run.assert_not_called()

    def test_explicit_or_interactive_consent_installs_only_missing_build_packages(self):
        for explicit in (True, False):
            state = {"done": False}
            def installed(package):
                return package != "cmake" or state["done"]
            def run(args, cwd, env):
                self.assertNotIn("OPENAI_API_KEY", env)
                if "install" in args:
                    self.assertEqual(args[-1], "cmake")
                    self.assertIn("--no-remove", args)
                    self.assertIn("--no-install-recommends", args)
                    self.assertNotIn("mosquitto", args)
                    state["done"] = True
            with self.subTest(explicit=explicit), patch.object(deps, "installed", side_effect=installed), patch.object(deps.common, "run", side_effect=run) as call, patch.object(deps.os, "geteuid", return_value=1000, create=True), patch.object(deps.sys.stdin, "isatty", return_value=True), patch("builtins.input", return_value="j"), patch.dict(os.environ, {"OPENAI_API_KEY": "fixture"}), redirect_stdout(io.StringIO()):
                deps.prepare(self.spec, approved=explicit)
            self.assertEqual(call.call_count, 2)
            self.assertEqual(call.call_args.args[0][:2], ["fixture", "--"])

    def test_apt_failure_propagates_instead_of_starting_build(self):
        with patch.object(deps, "installed", return_value=False), patch.object(deps.os, "geteuid", return_value=0, create=True), patch.object(deps.common, "run", side_effect=subprocess.CalledProcessError(100, "apt-get")), redirect_stdout(io.StringIO()):
            with self.assertRaises(subprocess.CalledProcessError):
                deps.prepare(self.spec, approved=True)

    def test_package_status_must_be_fully_installed(self):
        for status, expected in (("install ok installed", True), ("deinstall ok config-files", False), ("install ok unpacked", False)):
            result = Mock(returncode=0, stdout=status)
            with patch.object(deps.subprocess, "run", return_value=result):
                self.assertEqual(deps.installed("cmake"), expected)

    def test_other_tools_cannot_enable_arbitrary_apt_packages(self):
        spec = {"id": "fixture", "recipe": {"apt_build_deps": ["mosquitto"]}}
        with patch.object(deps.common, "run") as run:
            with self.assertRaisesRegex(ValueError, "Nicht freigegebene"):
                deps.prepare(spec, approved=True)
        run.assert_not_called()

    def test_non_ubuntu_explicit_apt_is_refused_but_manual_build_is_allowed(self):
        with patch.object(deps, "ubuntu_release", return_value=False), patch.object(deps.common, "run") as run, redirect_stdout(io.StringIO()):
            deps.prepare(self.spec)
            with self.assertRaisesRegex(ValueError, "Keine Systemaenderung"):
                deps.prepare(self.spec, approved=True)
        run.assert_not_called()

    def test_dry_run_with_explicit_flag_does_not_prepare_anything(self):
        with tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": temporary}), patch.object(deps, "prepare") as prepare, patch.object(tools.common, "operation") as operation, redirect_stdout(io.StringIO()):
            self.assertEqual(tools.main(["mosquitto", "install", "--dry-run", "--install-build-deps"]), 0)
            self.assertFalse(list(Path(temporary).iterdir()))
        prepare.assert_not_called()
        operation.assert_not_called()

    def test_storage_failure_is_logged_before_dependency_install_and_fetch(self):
        with tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": temporary}), patch.object(tools.platform, "system", return_value="Linux"), patch.object(tools.common, "reserve", side_effect=ValueError("Speicherplatzmangel")), patch.object(deps, "prepare") as prepare, patch.object(tools.common, "install") as fetch, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
                tools.main(["mosquitto", "install", "--install-build-deps"])
            logs = list((Path(temporary) / "install_logs").glob("*.log"))
            self.assertIn("Speicherplatzmangel", logs[0].read_text())
            self.assertFalse(tools.paths("mosquitto")[2].exists())
        prepare.assert_not_called()
        fetch.assert_not_called()


if __name__ == "__main__":
    unittest.main()
