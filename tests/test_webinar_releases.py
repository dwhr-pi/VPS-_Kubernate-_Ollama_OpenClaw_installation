"""Offline lifecycle and archive security checks for native webinar packages."""
import contextlib
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile
import unittest
from unittest.mock import patch
import zipfile


ROOT = Path(__file__).resolve().parents[1]
HELPERS = ROOT / "scripts/tools/helpers"
sys.path.insert(0, str(HELPERS))
try:
    spec = importlib.util.spec_from_file_location("webinar_releases", HELPERS / "webinar_releases.py")
    w = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(w)
finally:
    sys.path.pop(0)


class WebinarReleaseTests(unittest.TestCase):
    def test_marp_loader_stderr_reaches_current_operation_log(self):
        failure = subprocess.CompletedProcess([], 127, "", "marp: error while loading shared libraries: libatomic.so.1: cannot open shared object file: No such file or directory\n")
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {
                "OPENCLAW_USER_DATA_DIR": tmp, "MARP_INSTALL_RUNTIME_LIBS": "0"}), \
                patch.object(w, "host_key", return_value="linux-amd64"), patch.object(w, "reserve"), \
                patch.object(w, "download"), patch.object(w.platform, "system", return_value="Linux"), \
                patch.object(w.subprocess, "run", return_value=failure) as run, \
                contextlib.redirect_stdout(io.StringIO()):
            distro = Path(tmp) / "os-release"
            distro.write_text("ID=ubuntu\n")
            def unpack(archive, dest):
                (dest / "marp").write_bytes(b"synthetic-binary")
            with patch.object(w, "OS_RELEASE", distro), patch.object(w, "unpack", side_effect=unpack):
                with self.assertRaisesRegex(ValueError, "Exit 127"):
                    w.main(["marp", "install"])
            self.assertEqual(run.call_count, 1)
            base, app, marker = w.paths("marp")
            self.assertFalse(app.exists())
            self.assertFalse(marker.exists())
            self.assertFalse(list(base.glob("release-stage-*")))
            log = next((Path(tmp) / "install_logs").glob("marp_install_*.log"))
            text = log.read_text(encoding="utf-8")
            self.assertIn("libatomic.so.1", text)
            self.assertIn("libatomic1", text)
            self.assertIn("Programm-stderr", text)
            self.assertIn("Rollback", text)

    def test_approved_marp_repair_installs_only_recognized_package_then_rechecks(self):
        failed = subprocess.CompletedProcess([], 127, "", "error while loading shared libraries: libatomic.so.1: cannot open shared object file")
        fixed = subprocess.CompletedProcess([], 0, "Marp CLI v4.5.1", "")
        apt = subprocess.CompletedProcess([], 0, "library installed", "")
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"MARP_INSTALL_RUNTIME_LIBS": "1"}), \
                patch.object(w.platform, "system", return_value="Linux"), \
                patch.object(w.subprocess, "run", side_effect=[failed, apt, fixed]) as run, \
                contextlib.redirect_stdout(io.StringIO()) as output:
            distro = Path(tmp) / "os-release"
            distro.write_text('ID="ubuntu"\n')
            with patch.object(w, "OS_RELEASE", distro):
                w.verify_binary_version(Path(tmp) / "marp", "marp", w.SPECS["marp"])
            commands = [call.args[0] for call in run.call_args_list]
            self.assertEqual(commands[0][-1], "--version")
            self.assertEqual(commands[2][-1], "--version")
            self.assertIn("DPkg::Lock::Timeout=300", commands[1])
            self.assertIn("--no-remove", commands[1])
            self.assertEqual(commands[1][-1], "libatomic1")
            self.assertNotIn("nodejs", commands[1])
            self.assertIn("Versionspruefung erfolgreich", output.getvalue())

    def test_unknown_library_glibc_or_nonloader_error_never_installs_packages(self):
        for code, diagnostic in ((127, "error while loading shared libraries: libunknown.so.9: cannot open shared object file"),
                                 (127, "version `GLIBC_2.99' not found"),
                                 (1, "a JavaScript application error")):
            with self.subTest(diagnostic=diagnostic), tempfile.TemporaryDirectory() as tmp, \
                    patch.dict(os.environ, {"MARP_INSTALL_RUNTIME_LIBS": "1"}), \
                    patch.object(w.subprocess, "run", return_value=subprocess.CompletedProcess([], code, "", diagnostic)) as run, \
                    contextlib.redirect_stdout(io.StringIO()):
                with self.assertRaises(ValueError):
                    w.verify_binary_version(Path(tmp) / "marp", "marp", w.SPECS["marp"])
                self.assertEqual(run.call_count, 1)

    def test_marp_repair_is_bounded_and_never_marks_wrong_version_success(self):
        failed = subprocess.CompletedProcess([], 127, "", "error while loading shared libraries: libatomic.so.1: cannot open shared object file")
        with tempfile.TemporaryDirectory() as tmp, patch.object(w.subprocess, "run", return_value=failed) as run, \
                patch.object(w, "repair_marp_runtime", return_value=True) as repair, \
                contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaises(ValueError):
                w.verify_binary_version(Path(tmp) / "marp", "marp", w.SPECS["marp"])
            self.assertEqual(run.call_count, 2)
            self.assertEqual(repair.call_count, 1)
        with tempfile.TemporaryDirectory() as tmp, \
                patch.object(w.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, "4.0.0", "")), \
                contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Version"):
                w.verify_binary_version(Path(tmp) / "marp", "marp", w.SPECS["marp"])

    def test_other_tools_do_not_trigger_marp_apt_repair(self):
        with tempfile.TemporaryDirectory() as tmp, \
                patch.object(w.subprocess, "run", return_value=subprocess.CompletedProcess([], 127, "", "loader failure")), \
                patch.object(w, "repair_marp_runtime") as repair, contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaises(ValueError):
                w.verify_binary_version(Path(tmp) / "listmonk", "listmonk", w.SPECS["listmonk"])
            repair.assert_not_called()

    def test_failed_apt_does_not_report_repaired(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"MARP_INSTALL_RUNTIME_LIBS": "1"}), \
                patch.object(w.platform, "system", return_value="Linux"), \
                patch.object(w.subprocess, "run", return_value=subprocess.CompletedProcess([], 100, "", "apt failed")), \
                contextlib.redirect_stdout(io.StringIO()) as output:
            distro = Path(tmp) / "os-release"
            distro.write_text("ID=debian\n")
            with patch.object(w, "OS_RELEASE", distro), self.assertRaisesRegex(ValueError, "apt Exit 100"):
                w.repair_marp_runtime("error while loading shared libraries: libstdc++.so.6: cannot open shared object file", Path(tmp))
            self.assertIn("apt failed", output.getvalue())

    def test_registry_and_menu(self):
        registry = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        for key, entry in w.SPECS.items():
            tools = [t for t in registry["tools"] if t["id"] == key]
            self.assertEqual(len(tools), 1)
            self.assertEqual(tools[0]["version"], entry["version"])
            self.assertEqual(tools[0]["ports"], [])
            self.assertIn('TOOL_SCRIPT_NAMES["' + entry["name"] + '"]="' + key + '"', menu)
            for action in ("install", "update", "uninstall", "status", "check", "doctor"):
                path = ROOT / ("scripts/tools/" + key + "_" + action + ".sh")
                self.assertTrue(path.is_file())
                self.assertIn(key + " " + action, path.read_text())

    def test_pinned_assets_valid_and_no_beta(self):
        for spec in w.SPECS.values():
            self.assertNotRegex(spec["tag"], "beta|latest|nightly")
            for name, size, digest in spec["artifacts"].values():
                self.assertGreater(size, 0)
                self.assertRegex(digest, r"^[a-f0-9]{64}$")
        self.assertEqual(w.SPECS["mautic"]["artifacts"]["any"][0], "7.2.1.zip")

    def test_plan_no_writes_network_or_processes(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": tmp}), \
                patch.object(w, "host_key", return_value="windows-amd64"), \
                patch.object(w, "download", side_effect=AssertionError("network")), \
                patch.object(w.subprocess, "run", side_effect=AssertionError("execution")), \
                contextlib.redirect_stdout(io.StringIO()):
            for tool in w.SPECS:
                self.assertEqual(w.main([tool, "install", "--dry-run"]), 0)
            self.assertEqual(list(Path(tmp).iterdir()), [])

    def test_platform_selection_and_rejection(self):
        with patch.object(w, "host_key", return_value="windows-amd64"):
            self.assertTrue(w.artifact(w.SPECS["marp"])[0].endswith("win.zip"))
        with patch.object(w, "host_key", return_value="unsupported"):
            with self.assertRaises(ValueError):
                w.artifact(w.SPECS["marp"])

    def test_setup_flag_aliases_and_conflicts(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": tmp}), \
                contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(w.main(["marp", "install", "--status"]), 0)
            self.assertEqual(w.main(["marp", "install", "--check"]), 1)
            with self.assertRaises(SystemExit):
                w.main(["marp", "update", "--uninstall"])

    def test_redirect_allowlist(self):
        for url in ("http://github.com/file", "https://evil.test/file", "https://github.com.evil.test/file", "https://user:pass@github.com/file"):
            with self.assertRaises(ValueError):
                w.ReleaseRedirect().redirect_request(None, None, 302, "", {}, url)

    def test_unsafe_archive_paths(self):
        with tempfile.TemporaryDirectory() as tmp:
            for name in ("../outside", "/root", "a/../../b", "a\\b", "C:/bad", ""):
                with self.assertRaises(ValueError):
                    w.entry_path(Path(tmp), name)

    def test_zip_extract_and_traversal_duplicate_rejection(self):
        for names, success in ((["folder/data.txt"], True), (["../bad"], False), (["A", "a"], False)):
            with tempfile.TemporaryDirectory() as tmp:
                archive, dest = Path(tmp) / "archive.zip", Path(tmp) / "out"
                dest.mkdir()
                with zipfile.ZipFile(archive, "w") as z:
                    for name in names:
                        z.writestr(name, b"data")
                if success:
                    w.unpack(archive, dest)
                    self.assertEqual((dest / "folder/data.txt").read_bytes(), b"data")
                else:
                    with self.assertRaises(ValueError):
                        w.unpack(archive, dest)

    def test_tar_links_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            archive = Path(tmp) / "archive.tar.gz"
            with tarfile.open(archive, "w:gz") as tar:
                entry = tarfile.TarInfo("link")
                entry.type = tarfile.SYMTYPE
                entry.linkname = "/etc/passwd"
                tar.addfile(entry)
            with self.assertRaises(ValueError):
                w.unpack(archive, Path(tmp) / "out")

    def test_download_hash_and_length_enforced(self):
        raw = b"sample release"
        for size, digest, valid in ((len(raw), hashlib.sha256(raw).hexdigest(), True),
                                    (1, hashlib.sha256(raw).hexdigest(), False),
                                    (len(raw), "0" * 64, False)):
            class FakeOpener:
                def open(self, url, timeout):
                    return io.BytesIO(raw)
            with tempfile.TemporaryDirectory() as tmp, patch.object(w, "build_opener", return_value=FakeOpener()):
                if valid:
                    w.download("https://github.com/test", Path(tmp) / "file", size, digest)
                else:
                    with self.assertRaises(ValueError):
                        w.download("https://github.com/test", Path(tmp) / "file", size, digest)

    def test_failed_install_rolls_back_only_new_stage(self):
        with tempfile.TemporaryDirectory() as tmp, contextlib.redirect_stdout(io.StringIO()):
            base = Path(tmp)
            keep = base / "keep.txt"
            keep.write_text("preserve")
            with patch.object(w, "reserve"), patch.object(w, "host_key", return_value="linux-amd64"), \
                    patch.object(w, "download", side_effect=OSError("disk full")):
                with self.assertRaises(OSError):
                    w.install("marp", base, base / "app", base / "release-ready.json", w.SPECS["marp"])
            self.assertEqual(list(base.iterdir()), [keep])

    def test_missing_runtime_entry_no_success_marker(self):
        with tempfile.TemporaryDirectory() as tmp, contextlib.redirect_stdout(io.StringIO()):
            base = Path(tmp)
            with patch.object(w, "reserve"), patch.object(w, "download"), patch.object(w, "unpack"), \
                    patch.object(w, "host_key", return_value="linux-amd64"):
                with self.assertRaises(ValueError):
                    w.install("mautic", base, base / "app", base / "release-ready.json", w.SPECS["mautic"])
            self.assertEqual(list(base.iterdir()), [])

    def test_install_binary_status_and_guarded_uninstall(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": tmp}), \
                contextlib.redirect_stdout(io.StringIO()):
            base, app, marker = w.paths("marp")
            base.mkdir(parents=True)
            def extract(archive, dest):
                (dest / "marp").write_bytes(b"fake binary")
            with patch.object(w, "reserve"), patch.object(w, "download"), patch.object(w, "unpack", side_effect=extract), \
                    patch.object(w, "host_key", return_value="linux-amd64"), patch.object(w.platform, "system", return_value="Linux"), \
                    patch.object(w.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, "4.5.1", "")):
                w.install("marp", base, app, marker, w.SPECS["marp"])
            self.assertTrue(w.validate_record(app, marker, w.SPECS["marp"], full=True)["runtime_ready"])
            (app / "extra.txt").write_text("user data")
            with self.assertRaises(ValueError):
                w.main(["marp", "uninstall"])
            self.assertTrue((app / "extra.txt").exists())
            (app / "extra.txt").unlink()
            self.assertEqual(w.main(["marp", "uninstall"]), 0)
            self.assertFalse(marker.exists())
            self.assertFalse(app.exists())

    def test_current_resource_failure_logged(self):
        with tempfile.TemporaryDirectory() as tmp, patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": tmp}), \
                patch.object(w, "reserve", side_effect=ValueError("Speicherplatzmangel")), \
                contextlib.redirect_stdout(io.StringIO()):
            with self.assertRaises(ValueError):
                w.main(["mautic", "install"])
            logs = list((Path(tmp) / "install_logs").glob("mautic_install_*.log"))
            self.assertEqual(len(logs), 1)
            self.assertIn("Speicherplatzmangel", logs[0].read_text(encoding="utf-8"))
            self.assertIn("failed", logs[0].read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
