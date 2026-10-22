"""Offline OpenMontage installer checks: never install packages or run media."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch


ROOT = Path(__file__).resolve().parents[1]
HELPERS = ROOT / "scripts/tools/helpers"
sys.path.insert(0, str(HELPERS))
try:
    spec = importlib.util.spec_from_file_location("openmontage_installer", HELPERS / "openmontage.py")
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
finally:
    sys.path.pop(0)


def fake_source(base, source):
    source.mkdir()
    for name in m.FILES:
        file = source / name
        file.parent.mkdir(parents=True, exist_ok=True)
        file.write_text("# synthetic\n", encoding="utf-8")
    return True


def fake_command(args, cwd, timeout=900):
    args = list(map(str, args))
    if "venv" in args:
        venv = Path(args[-1])
        python = m.python_at(venv)
        python.parent.mkdir(parents=True)
        python.write_bytes(b"synthetic-python")


class OpenMontageTests(unittest.TestCase):
    def test_missing_ensurepip_offers_matching_venv_without_fetch(self):
        details = subprocess.CompletedProcess([], 0, '["/usr/bin/python3.12", [3,12]]', "")
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"OPENMONTAGE_INSTALL_PYTHON_VENV": "0"}), \
                patch.object(m, "command", side_effect=subprocess.CalledProcessError(1, "probe")) as command, \
                patch.object(m.subprocess, "run", return_value=details), \
                patch.object(m.Path, "is_file", return_value=True), \
                patch.object(m.Path, "read_text", return_value="ID=ubuntu\n"), \
                contextlib.redirect_stdout(io.StringIO()) as out:
            with self.assertRaisesRegex(ValueError, "nicht freigegeben"):
                m.prepare_python("/usr/bin/python3", Path(tmp))
            self.assertIn("python3.12-venv", out.getvalue())
            self.assertIn("Kein Austausch des System-Python-Befehls", out.getvalue())
            self.assertIn("System-Abhaengigkeiten aktualisieren", out.getvalue())
            self.assertEqual(command.call_count, 1)

    def test_approved_venv_repair_waits_for_apt_lock_and_rechecks(self):
        details = subprocess.CompletedProcess([], 0, '["/usr/bin/python3.12", [3,12]]', "")
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"OPENMONTAGE_INSTALL_PYTHON_VENV": "1"}), \
                patch.object(m, "command", side_effect=[subprocess.CalledProcessError(1, "probe"), None, None]) as command, \
                patch.object(m.subprocess, "run", return_value=details), \
                patch.object(m.Path, "is_file", return_value=True), \
                patch.object(m.Path, "read_text", return_value="ID=ubuntu\n"), \
                contextlib.redirect_stdout(io.StringIO()):
            m.prepare_python("/usr/bin/python3", Path(tmp))
            apt = command.call_args_list[1].args[0]
            self.assertEqual(apt, ["sudo", "apt-get", "-o", "DPkg::Lock::Timeout=300", "install",
                                   "--no-remove", "--no-install-recommends", "-y", "python3.12-venv"])
            self.assertIn("ensurepip", command.call_args_list[2].args[0][-1])

    def test_custom_python_never_triggers_system_apt_repair(self):
        details = subprocess.CompletedProcess([], 0, '["/opt/custom/bin/python3", [3,12]]', "")
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"OPENMONTAGE_INSTALL_PYTHON_VENV": "1"}), \
                patch.object(m, "command", side_effect=subprocess.CalledProcessError(1, "probe")) as command, \
                patch.object(m.subprocess, "run", return_value=details):
            with self.assertRaisesRegex(ValueError, "fremde Python"):
                m.prepare_python("/opt/custom/bin/python3", Path(tmp))
            self.assertEqual(command.call_count, 1)

    def test_plan_never_fetches_or_creates_files(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": tmp}), \
                patch.object(m, "command", side_effect=AssertionError("execute")), \
                patch.object(m, "fetch", side_effect=AssertionError("network")), contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(m.main(["install", "--dry-run", "--with-remotion"]), 0)
            self.assertEqual(list(Path(tmp).iterdir()), [])

    def test_install_core_records_actual_dependency_check(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": tmp}), \
                patch.object(m, "reserve"), patch.object(m, "fetch", side_effect=fake_source), \
                patch.object(m, "command", side_effect=fake_command) as command, \
                patch.object(m.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, "pydantic==2.0.0\n", "")), \
                contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(m.main(["install"]), 0)
            base, source, venv, marker = m.paths()
            record = json.loads(marker.read_text())
            self.assertTrue(record["core_dependencies_ready"])
            self.assertFalse(record["remotion_ready"])
            self.assertFalse(record["render_ready"])
            self.assertEqual(record["commit"], m.PIN)
            self.assertEqual(record["resolved_python_packages"], ["pydantic==2.0.0"])
            commands = [list(map(str, call.args[0])) for call in command.call_args_list]
            pip = next(c for c in commands if "--only-binary=:all:" in c)
            self.assertIn("--isolated", pip)
            self.assertIn(str(source / "requirements.txt"), pip)
            self.assertTrue(any(m.IMPORTS in c for c in commands))
            self.assertTrue(any("check" in c and "pip" in c for c in commands))
            self.assertFalse(any("make" in c or "npx" in c for c in commands))
            self.assertEqual(m.main(["status"]), 0)

    def test_failed_import_rolls_back_new_source_and_environment(self):
        with tempfile.TemporaryDirectory() as tmp, contextlib.redirect_stdout(io.StringIO()):
            base = Path(tmp)
            keep = base / "keep.txt"
            keep.write_text("preserve")
            def fail(args, cwd, timeout=900):
                fake_command(args, cwd, timeout)
                if m.IMPORTS in args:
                    raise subprocess.CalledProcessError(1, "dependency-check")
            with patch.object(m, "reserve"), patch.object(m, "fetch", side_effect=fake_source), patch.object(m, "command", side_effect=fail):
                with self.assertRaises(subprocess.CalledProcessError):
                    m.install(base, base / "source", base / "venv", base / "core-ready.json")
            self.assertEqual(list(base.iterdir()), [keep])

    def test_existing_source_survives_failed_venv(self):
        with tempfile.TemporaryDirectory() as tmp, contextlib.redirect_stdout(io.StringIO()):
            base = Path(tmp)
            source = base / "source"
            source.mkdir()
            (source / "user-project.txt").write_text("preserve")
            def fail(args, cwd, timeout=900):
                if "venv" in args:
                    raise OSError("full disk")
            with patch.object(m, "reserve"), patch.object(m, "fetch", return_value=False), patch.object(m, "command", side_effect=fail):
                with self.assertRaises(OSError):
                    m.install(base, source, base / "venv", base / "core-ready.json")
            self.assertEqual((source / "user-project.txt").read_text(), "preserve")
            self.assertFalse((base / "core-ready.json").exists())

    def test_license_gate_before_package_actions_and_current_log(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": tmp}), \
                patch.object(m, "install") as install, contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Remotion-Lizenz"):
                m.main(["install", "--with-remotion"])
            install.assert_not_called()
            log = next((Path(tmp) / "install_logs").glob("openmontage_install_*.log"))
            self.assertIn("Remotion-Lizenz", log.read_text(encoding="utf-8"))
            self.assertIn("failed", log.read_text(encoding="utf-8"))

    def test_unmanaged_environment_never_replaced(self):
        with tempfile.TemporaryDirectory() as tmp, patch.object(m, "reserve"):
            base = Path(tmp)
            (base / "venv").mkdir()
            with self.assertRaisesRegex(ValueError, "Unverwaltete"):
                m.install(base, base / "source", base / "venv", base / "core-ready.json")

    def test_marker_without_environment_not_installed(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": tmp}), contextlib.redirect_stdout(io.StringIO()) as output:
            base, source, venv, marker = m.paths()
            base.mkdir(parents=True)
            marker.write_text(json.dumps({"commit": m.PIN, "core_dependencies_ready": True}))
            self.assertEqual(m.main(["check"]), 1)
            self.assertFalse(json.loads(output.getvalue())["installed"])

    def test_uninstall_preserves_sources_projects_and_unmanaged_modules(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": tmp}), contextlib.redirect_stdout(io.StringIO()):
            base, source, venv, marker = m.paths()
            source.mkdir(parents=True)
            (source / "AGENT_GUIDE.md").write_text("guide")
            (source / "user-video.mp4").write_bytes(b"user-data")
            python = m.python_at(venv)
            python.parent.mkdir(parents=True)
            python.write_bytes(b"fake")
            modules = base / "remotion/node_modules"
            modules.mkdir(parents=True)
            (modules / "keep.txt").write_text("unmanaged")
            marker.write_text(json.dumps({"commit": m.PIN, "core_dependencies_ready": True, "remotion_ready": False}))
            self.assertEqual(m.main(["uninstall"]), 0)
            self.assertFalse(marker.exists())
            self.assertFalse(venv.exists())
            self.assertTrue((source / "user-video.mp4").exists())
            self.assertTrue((modules / "keep.txt").exists())

    def test_source_origin_pin_and_dirty_guard(self):
        with tempfile.TemporaryDirectory() as tmp:
            source = Path(tmp) / "source"
            fake_source(Path(tmp), source)
            for values in (("https://evil.example/repo", m.PIN, ""), (m.URL, "bad", ""), (m.URL, m.PIN, " M config.yaml")):
                with patch.object(m, "git", side_effect=values), self.assertRaises(ValueError):
                    m.verify_source(source)

    def test_remotion_missing_node_no_target_or_download(self):
        with tempfile.TemporaryDirectory() as tmp, patch.object(m.shutil, "which", return_value=None):
            with self.assertRaisesRegex(ValueError, "Node/npm fehlt"):
                m.install_remotion(Path(tmp), Path(tmp) / "source")
            self.assertEqual(list(Path(tmp).iterdir()), [])

    def test_remotion_uses_ci_lock_and_disables_scripts(self):
        with tempfile.TemporaryDirectory() as tmp:
            base = Path(tmp)
            source = base / "source"
            composer = source / "remotion-composer"
            composer.mkdir(parents=True)
            (composer / "package.json").write_text('{}')
            (composer / "package-lock.json").write_text(json.dumps({"packages": {"node_modules/remotion": {"version": "4.0.484"}}}))
            def npm(args, cwd, timeout=900):
                self.assertIn("ci", args)
                self.assertIn("--ignore-scripts", args)
                package = cwd / "node_modules/remotion/package.json"
                package.parent.mkdir(parents=True)
                package.write_text('{"version":"4.0.484"}')
            with patch.object(m.shutil, "which", side_effect=lambda name: name), \
                    patch.object(m.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, "22\n", "")), \
                    patch.object(m, "command", side_effect=npm):
                self.assertEqual(m.install_remotion(base, source), "4.0.484")
            self.assertFalse((composer / "node_modules").exists())

    def test_registry_menu_wrappers_and_native_status(self):
        registry = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))
        entries = [t for t in registry["tools"] if t["id"] == "openmontage"]
        self.assertEqual(len(entries), 1)
        self.assertEqual(entries[0]["source_commit"], m.PIN)
        self.assertEqual(entries[0]["ports"], [])
        for action in ("install", "update", "uninstall", "check", "status", "doctor"):
            wrapper = ROOT / ("scripts/tools/openmontage_" + action + ".sh")
            self.assertIn('openmontage.py" ' + action, wrapper.read_text())
        setup = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_SCRIPT_NAMES["OpenMontage"]="openmontage"', setup)
        native = (ROOT / "scripts/helpers/native_tool_status.sh").read_text(encoding="utf-8")
        self.assertIn("OpenMontage) marker=openmontage/core-ready.json", native)
        self.assertIn('openmontage/venv/bin/python', native)

    def test_docs_references_and_readiness_boundaries(self):
        import re
        docpath = ROOT / "docs/tools/openmontage.md"
        doc = docpath.read_text(encoding="utf-8")
        for link in re.findall(r"\]\(([^)]+)\)", doc):
            if not link.startswith(("http://", "https://", "#")):
                self.assertTrue((docpath.parent / link.split("#")[0]).is_file(), link)
        for term in (m.PIN, "render_ready=false", "nicht automatisch installiert", "QWEN.md", "warn", "Remotion-Lizenz"):
            self.assertIn(term, doc)


if __name__ == "__main__":
    unittest.main()
