"""Offline fixtures: no checkout, compiler, package installation or agent."""
from contextlib import redirect_stdout
import io
import json
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts/tools/helpers"))
import gap_tools as tool


class GapToolTests(unittest.TestCase):
    def fake_git(self, directory, *args):
        directory = Path(directory)
        if args[0] == "init":
            (directory / ".git").mkdir()
            (directory / ".git/HEAD").write_text("fixture-head")
            (directory / "README.md").write_text("fixture source")
        if args[:2] == ("rev-parse", "HEAD"):
            return self.spec["pin"]
        if args[:3] == ("remote", "get-url", "origin"):
            return "https://github.com/" + self.spec["repo"] + ".git"
        return ""

    def fixture(self, parent, key="musetalk"):
        self.spec = tool.SPECS[key]
        base = Path(parent) / key
        base.mkdir()
        return base, base / "runtime", base / "ready.json"

    def test_plan_and_status_are_read_only(self):
        with tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": temporary}), patch.object(tool, "git") as git, patch.object(tool, "run") as run:
            with redirect_stdout(io.StringIO()):
                self.assertEqual(tool.main(["qwen_desktop_build", "plan"]), 0)
                self.assertEqual(tool.main(["hermes_agent_jarvis", "status"]), 0)
            self.assertEqual(list(Path(temporary).iterdir()), [])
            git.assert_not_called()
            run.assert_not_called()

    def test_source_install_has_honest_scope(self):
        with tempfile.TemporaryDirectory() as temporary:
            base, runtime, marker = self.fixture(temporary)
            with patch.object(tool, "git", side_effect=self.fake_git), patch.object(tool, "reserve"), redirect_stdout(io.StringIO()) as output:
                tool.install(runtime, marker, base, self.spec)
                record = tool.validate(runtime, marker, self.spec, full=True)
                self.assertEqual(record["mode"], "source")
                self.assertFalse(record["runtime_tested"])
                self.assertIn("NUR QUELLEN", output.getvalue())
                self.assertIn("README.md", record["entries"])

    def test_failed_build_removes_only_new_files(self):
        with tempfile.TemporaryDirectory() as temporary:
            base, runtime, marker = self.fixture(temporary, "qwen_desktop_build")
            other = base / "keep.log"
            other.write_text("keep")
            with patch.object(tool, "git", side_effect=self.fake_git), patch.object(tool, "reserve"), patch.object(tool, "qwen_build", side_effect=ValueError("disk full")), redirect_stdout(io.StringIO()):
                with self.assertRaisesRegex(ValueError, "disk full"):
                    tool.install(runtime, marker, base, self.spec)
            self.assertFalse(runtime.exists())
            self.assertFalse(marker.exists())
            self.assertEqual(other.read_text(), "keep")

    def test_storage_failure_never_fetches(self):
        with tempfile.TemporaryDirectory() as temporary:
            base, runtime, marker = self.fixture(temporary)
            with patch.object(tool, "git") as git, patch.object(tool, "reserve", side_effect=ValueError("Speicherplatzmangel")):
                with self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
                    tool.install(runtime, marker, base, self.spec)
                git.assert_not_called()
            self.assertFalse(runtime.exists())

    def test_marker_write_failure_rolls_back_without_partial_status(self):
        with tempfile.TemporaryDirectory() as temporary:
            base, runtime, marker = self.fixture(temporary)
            with patch.object(tool, "git", side_effect=self.fake_git), patch.object(tool, "reserve"), patch.object(tool.os, "replace", side_effect=OSError("disk full marker")), redirect_stdout(io.StringIO()):
                with self.assertRaisesRegex(OSError, "disk full marker"):
                    tool.install(runtime, marker, base, self.spec)
            self.assertFalse(marker.exists())
            self.assertFalse(runtime.exists())
            self.assertEqual(list(base.iterdir()), [])

    def test_unmanaged_existing_directory_is_preserved(self):
        with tempfile.TemporaryDirectory() as temporary:
            base, runtime, marker = self.fixture(temporary)
            runtime.mkdir()
            (runtime / "user.txt").write_text("keep")
            with self.assertRaisesRegex(ValueError, "Besitznachweis"):
                tool.install(runtime, marker, base, self.spec)
            self.assertEqual((runtime / "user.txt").read_text(), "keep")

    def test_changed_files_block_removal_validation(self):
        with tempfile.TemporaryDirectory() as temporary:
            base, runtime, marker = self.fixture(temporary)
            with patch.object(tool, "git", side_effect=self.fake_git), patch.object(tool, "reserve"), redirect_stdout(io.StringIO()):
                tool.install(runtime, marker, base, self.spec)
                (runtime / "extra.txt").write_text("private")
                with self.assertRaisesRegex(ValueError, "ergaenzt"):
                    tool.validate(runtime, marker, self.spec, full=True)
                self.assertTrue((runtime / "extra.txt").is_file())
                (runtime / "README.md").write_text("changed")
                with self.assertRaisesRegex(ValueError, "artefakt"):
                    tool.validate(runtime, marker, self.spec)

    def test_uninstall_removes_owned_source_keeps_logs(self):
        with tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": temporary}):
            base, runtime, marker = tool.paths("musetalk")
            self.spec = tool.SPECS["musetalk"]
            with patch.object(tool, "git", side_effect=self.fake_git), patch.object(tool, "reserve"), redirect_stdout(io.StringIO()):
                self.assertEqual(tool.main(["musetalk", "install", "--source-only"]), 0)
                self.assertEqual(tool.main(["musetalk", "uninstall", "--source-only"]), 0)
            self.assertFalse(marker.exists())
            self.assertFalse(runtime.exists())
            self.assertEqual(len(list((Path(temporary) / "install_logs").glob("*.log"))), 2)

    def test_current_failure_log_contains_disk_error(self):
        with tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": temporary}), patch.object(tool, "reserve", side_effect=ValueError("Speicherplatzmangel fixture")), redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
                tool.main(["musetalk", "install", "--source-only"])
            logs = list((Path(temporary) / "install_logs").glob("*.log"))
            self.assertEqual(len(logs), 1)
            self.assertIn("Speicherplatzmangel fixture", logs[0].read_text())

    def test_build_environment_excludes_provider_secrets(self):
        with tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {"OPENAI_API_KEY": "fixture", "ANTHROPIC_API_KEY": "fixture"}):
            env = tool.build_env(Path(temporary))
            self.assertNotIn("OPENAI_API_KEY", env)
            self.assertNotIn("ANTHROPIC_API_KEY", env)
            self.assertEqual(env["QWEN_DESKTOP_DISABLE_UPDATES"], "1")

    def test_hermes_frozen_core_without_agent_start(self):
        with tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {"HERMES_PYTHON_BIN": "fake-python"}), patch.object(tool, "executable", return_value="uv"), patch.object(tool, "run", return_value="") as run:
            entries = tool.hermes_build(Path(temporary), {})
            command = run.call_args_list[1].args[0]
            for arg in ("--frozen", "--no-dev", "--no-default-groups", "--no-python-downloads"):
                self.assertIn(arg, command)
            self.assertNotIn("--all-extras", command)
            self.assertTrue(any("hermes" in name for name in entries))
            self.assertFalse(any(str(call.args[0][0]).endswith("/hermes") for call in run.call_args_list))

    def test_hermes_missing_python_declined_before_checkout(self):
        with tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {"HERMES_PYTHON_BIN": "", "HERMES_INSTALL_PYTHON": "0"}), patch.object(tool.shutil, "which", return_value=None), patch.object(tool, "executable", return_value="uv"), patch.object(tool, "reserve"), patch.object(tool, "git") as git, patch.object(tool, "run") as run, redirect_stdout(io.StringIO()):
            base, runtime, marker = self.fixture(temporary, "hermes_agent_jarvis")
            with self.assertRaisesRegex(ValueError, "Kein Hermes-Quellcode"):
                tool.install(runtime, marker, base, self.spec)
            git.assert_not_called()
            run.assert_not_called()
            self.assertFalse(runtime.exists())
            self.assertFalse(marker.exists())

    def test_hermes_private_python_download_is_explicit_and_contained(self):
        with tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {"HERMES_PYTHON_BIN": "", "HERMES_INSTALL_PYTHON": "1"}), patch.object(tool.shutil, "which", return_value=None), patch.object(tool, "executable", return_value="uv"), redirect_stdout(io.StringIO()):
            runtime = Path(temporary)
            python = runtime / ".python/cpython/bin/python"
            python.parent.mkdir(parents=True)
            python.write_bytes(b"fixture")
            env = {}
            with patch.object(tool, "run", side_effect=["", str(python), ""]) as run:
                self.assertEqual(tool.hermes_python(runtime, env), str(python))
            self.assertEqual(env["UV_PYTHON_INSTALL_DIR"], str(runtime / ".python"))
            self.assertIn("--no-bin", run.call_args_list[0].args[0])
            self.assertIn("--no-python-downloads", run.call_args_list[1].args[0])

    def test_hermes_private_python_rejects_external_result(self):
        with tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {"HERMES_PYTHON_BIN": "", "HERMES_INSTALL_PYTHON": "1"}), patch.object(tool.shutil, "which", return_value=None), patch.object(tool, "executable", return_value="uv"), patch.object(tool, "run", side_effect=["", sys.executable]), redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "privaten Python-Pfad"):
                tool.hermes_python(Path(temporary), {})

    def test_hermes_noninteractive_never_implicitly_downloads(self):
        with tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {"HERMES_PYTHON_BIN": "", "HERMES_INSTALL_PYTHON": "ask"}), patch.object(tool.shutil, "which", return_value=None), patch.object(tool, "executable", return_value="uv"), patch.object(tool.sys.stdin, "isatty", return_value=False), patch.object(tool, "run") as run, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Python 3.14 fehlt"):
                tool.hermes_python(Path(temporary), {})
            run.assert_not_called()

    def test_hermes_prompt_decline_or_eof_never_downloads(self):
        for answer in ("n", EOFError()):
            with self.subTest(answer=answer), tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {"HERMES_PYTHON_BIN": "", "HERMES_INSTALL_PYTHON": "ask"}), patch.object(tool.shutil, "which", return_value=None), patch.object(tool, "executable", return_value="uv"), patch.object(tool.sys.stdin, "isatty", return_value=True), patch("builtins.input", side_effect=[answer]), patch.object(tool, "run") as run, redirect_stdout(io.StringIO()) as output:
                with self.assertRaisesRegex(ValueError, "Python 3.14 fehlt"):
                    tool.hermes_python(Path(temporary), {})
                run.assert_not_called()
                self.assertIn("[(j)a/(N)ein]\n", output.getvalue())
                self.assertIn("nicht freigegeben", output.getvalue())

    def test_hermes_failed_python_download_rolls_back_new_runtime(self):
        with tempfile.TemporaryDirectory() as temporary, patch.dict(os.environ, {"HERMES_PYTHON_BIN": "", "HERMES_INSTALL_PYTHON": "1"}), patch.object(tool.shutil, "which", return_value=None), patch.object(tool, "executable", return_value="uv"), patch.object(tool, "reserve"), patch.object(tool, "git") as git, redirect_stdout(io.StringIO()):
            base, runtime, marker = self.fixture(temporary, "hermes_agent_jarvis")
            keep = base / "keep.log"
            keep.write_text("existing")
            def broken_download(*args):
                (runtime / ".python").mkdir()
                (runtime / ".python/partial").write_bytes(b"partial")
                raise ValueError("download interrupted")
            with patch.object(tool, "run", side_effect=broken_download):
                with self.assertRaisesRegex(ValueError, "download interrupted"):
                    tool.install(runtime, marker, base, self.spec)
            git.assert_not_called()
            self.assertFalse(runtime.exists())
            self.assertFalse(marker.exists())
            self.assertEqual(keep.read_text(), "existing")

    def test_qwen_build_uses_native_unsigned_package_commands(self):
        with tempfile.TemporaryDirectory() as temporary, patch.object(tool, "executable", side_effect=lambda name: name), patch.object(tool, "node_command", side_effect=lambda name: [name]), patch.object(tool.platform, "system", return_value="Windows"), patch.object(tool, "run", return_value="v22.0.0") as run:
            runtime = Path(temporary)
            bundle = "nsis" if os.name == "nt" else "appimage"
            package = runtime / "packages/desktop/src-tauri/target/release/bundle" / bundle / ("test.exe" if os.name == "nt" else "test.AppImage")
            package.parent.mkdir(parents=True)
            package.write_bytes(b"fixture")
            entries = tool.qwen_build(runtime, {})
            commands = [call.args[0] for call in run.call_args_list]
            self.assertTrue(any("--frozen-lockfile" in command for command in commands))
            self.assertTrue(any("build:runtime" in command for command in commands))
            self.assertIn("--bundles", commands[-1])
            self.assertEqual(json.loads(commands[-1][-1]), {"bundle": {"createUpdaterArtifacts": False}})
            self.assertIn(package.relative_to(runtime).as_posix(), entries)
            self.assertFalse(any("dev" in command or "serve" in command for command in commands))

    def test_registry_pins_wrappers_and_documentation_match(self):
        registry = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
        names = [entry["name"] for entry in registry]
        setup = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        for key, spec in tool.SPECS.items():
            self.assertRegex(spec["pin"], r"^[a-f0-9]{40}$")
            self.assertEqual(names.count(spec["name"]), 1, spec["name"])
            entry = next(item for item in registry if item["name"] == spec["name"])
            self.assertEqual(entry["source_commit"], spec["pin"])
            marker = "runtime-ready.json" if key == "musetalk" else "ready.json"
            self.assertEqual(entry["check_value"], "~/.openclaw_ultimate_user_data/tools/" + key + "/" + marker)
            self.assertIn('TOOL_SCRIPT_NAMES["' + spec["name"] + '"]="' + key + '"', setup)
            for action in ("install", "update", "uninstall", "status", "check", "doctor"):
                wrapper = (ROOT / "scripts/tools" / (key + "_" + action + ".sh")).read_text()
                self.assertIn("github.com/" + spec["repo"], wrapper)
                expected = (key + '.py" ' if key in ('browseros_study', 'enki_browser_study') else 'gap_tools.py" ' + key + ' ')
                self.assertIn(expected + action, wrapper)
        doc = (ROOT / "docs/tools/github-gap-tools.md").read_text(encoding="utf-8")
        for target in re.findall(r"\]\(([^)]+)\)", doc):
            if not target.startswith(("https://", "#")):
                self.assertTrue((ROOT / "docs/tools" / target.split("#")[0]).resolve().exists(), target)


BASH = "C:/Program Files/Git/bin/bash.exe" if os.name == "nt" else shutil.which("bash")


@unittest.skipUnless(BASH and Path(BASH).is_file(), "Native Bash unavailable")
class GapStorageMenuTests(unittest.TestCase):
    def shell(self, functions, command):
        source = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        selected = [re.search(r"^" + name + r"\(\) \{\n.*?^\}", source, re.M | re.S).group()
                    for name in functions]
        return subprocess.run([BASH, "--noprofile", "--norc", "-c", "\n".join(selected) + "\n" + command],
                              capture_output=True, text=True, timeout=30)

    def test_menu_fallbacks_match_all_gap_tool_reserves(self):
        command = ""
        for spec in tool.SPECS.values():
            command += "get_tool_install_fallback_min_free_mb " + shlex.quote(spec["name"]) + "\nprintf '\\n'\n"
        result = self.shell(["get_tool_install_fallback_min_free_mb"], command)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.splitlines(), [str(spec["reserve_mb"]) for spec in tool.SPECS.values()])

    def test_qwen_host_shortage_is_rejected_by_menu_before_installer(self):
        result = self.shell(["get_tool_install_fallback_min_free_mb", "get_tool_install_min_free_mb",
                             "get_tool_install_windows_min_free_mb", "preflight_tool_install_storage"], """
get_tool_install_measured_mb() { printf 0; }
get_free_disk_kb() { printf 1000268416; }
get_windows_host_free_kb() { printf '%s' "$((13251 * 1024))"; }
is_wsl_environment() { return 0; }
format_kb_human() { printf '%s KiB' "$1"; }
if preflight_tool_install_storage Qwen_Desktop_Build; then
    printf 'BAD-INSTALLER-STARTED\\n'
    exit 99
else
    printf 'PREFLIGHT-REJECTED\\n'
fi
""")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("20480 MB", result.stdout)
        self.assertIn("PREFLIGHT-REJECTED", result.stdout)
        self.assertNotIn("BAD-INSTALLER-STARTED", result.stdout)


if __name__ == "__main__":
    unittest.main()
