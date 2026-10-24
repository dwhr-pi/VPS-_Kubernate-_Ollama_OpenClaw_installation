"""Private Go-cache cleanup regression tests; no builds, downloads or sudo."""
from contextlib import redirect_stdout
import io
import os
from pathlib import Path
import stat
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts/tools/helpers"))
import native_github_tools as tool


class NativeCleanupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.outer = self.base / "tools/caddy"
        self.prefix = self.outer / "native-github"
        self.cache = self.prefix / "_build/.build-home/go-mod"
        self.readonly = []
        self.addCleanup(self.restore_modes)

    def restore_modes(self):
        for path in self.readonly:
            if path.exists() and not path.is_symlink():
                path.chmod(0o700)

    def cache_fixture(self):
        module = self.cache / "example.test/module@v1"
        module.mkdir(parents=True)
        file = module / "go.sum"
        file.write_text("fixture checksum")
        for path, mode in ((file, 0o444), (module, 0o555)):
            path.chmod(mode)
            self.readonly.append(path)
        return module, file

    def test_readonly_cache_is_unlocked_before_removal_without_touching_source(self):
        module, cached = self.cache_fixture()
        source = self.prefix / "source/go.sum"
        source.parent.mkdir()
        source.write_text("original source")
        source.chmod(0o444)
        self.readonly.append(source)
        original_mode = stat.S_IMODE(source.stat().st_mode)
        original_remove = tool.shutil.rmtree

        def remove(path):
            self.assertTrue(module.stat().st_mode & stat.S_IWUSR)
            self.assertTrue(cached.stat().st_mode & stat.S_IWUSR)
            self.assertEqual(path, self.prefix / "_build")
            original_remove(path)

        with patch.object(tool.shutil, "rmtree", side_effect=remove), redirect_stdout(io.StringIO()):
            tool.remove_native_tree(self.prefix, cache_only=True)
        self.assertFalse((self.prefix / "_build").exists())
        self.assertEqual(source.read_text(), "original source")
        self.assertEqual(stat.S_IMODE(source.stat().st_mode), original_mode)

    def test_rollback_removes_only_native_prefix_and_preserves_toolchain_and_data(self):
        self.cache_fixture()
        basis = self.outer / "toolchain/go/bin"
        basis.mkdir(parents=True)
        keep = self.outer / "legacy.env"
        keep.write_text("preserve")
        with redirect_stdout(io.StringIO()):
            tool.remove_native_tree(self.prefix)
        self.assertFalse(self.prefix.exists())
        self.assertTrue(basis.is_dir())
        self.assertEqual(keep.read_text(), "preserve")

    def test_non_native_root_is_refused(self):
        self.outer.mkdir(parents=True)
        with self.assertRaisesRegex(ValueError, "privaten nativen"):
            tool.remove_native_tree(self.outer)
        self.assertTrue(self.outer.exists())

    def test_cache_symlink_target_is_never_chmodded_or_deleted(self):
        self.cache.mkdir(parents=True)
        outside = self.base / "external"
        outside.mkdir()
        keep = outside / "go.sum"
        keep.write_text("external")
        keep.chmod(0o444)
        self.readonly.append(keep)
        before = stat.S_IMODE(keep.stat().st_mode)
        try:
            (self.cache / "linked-module").symlink_to(outside, target_is_directory=True)
        except OSError as error:
            self.skipTest("Symlink creation unavailable: " + str(error))
        with redirect_stdout(io.StringIO()):
            tool.remove_native_tree(self.prefix, cache_only=True)
        self.assertEqual(keep.read_text(), "external")
        self.assertEqual(stat.S_IMODE(keep.stat().st_mode), before)

    def test_link_in_cache_root_is_refused_without_touching_external_tree(self):
        self.cache.parent.mkdir(parents=True)
        outside = self.base / "external"
        outside.mkdir()
        try:
            self.cache.symlink_to(outside, target_is_directory=True)
        except OSError as error:
            self.skipTest("Symlink creation unavailable: " + str(error))
        with self.assertRaisesRegex(ValueError, "Symlink"):
            tool.remove_native_tree(self.prefix, cache_only=True)
        self.assertTrue(outside.exists())

    def test_hardlinked_file_is_not_chmodded(self):
        self.cache.mkdir(parents=True)
        outside = self.base / "external.sum"
        outside.write_text("external")
        try:
            os.link(outside, self.cache / "go.sum")
        except OSError as error:
            self.skipTest("Hardlink creation unavailable: " + str(error))
        before = stat.S_IMODE(outside.stat().st_mode)
        with redirect_stdout(io.StringIO()), self.assertRaisesRegex(ValueError, "Mehrfach"):
            tool.remove_native_tree(self.prefix, cache_only=True)
        self.assertEqual(stat.S_IMODE(outside.stat().st_mode), before)
        self.assertEqual(outside.read_text(), "external")

    def test_rollback_failure_does_not_mask_original_build_error(self):
        self.outer.mkdir(parents=True)
        marker = self.prefix / "build-ready.json"
        original = subprocess.CalledProcessError(42, "go build")
        output = io.StringIO()
        with patch.object(tool, "preflight"), patch.object(tool, "fetch_source"), \
             patch.object(tool, "build", side_effect=original), \
             patch.object(tool, "remove_native_tree", side_effect=PermissionError("locked cache")), \
             redirect_stdout(output):
            with self.assertRaises(subprocess.CalledProcessError) as result:
                tool.install(self.outer, self.prefix, marker, tool.TOOLS["caddy"])
        self.assertIs(result.exception, original)
        self.assertIn("Rollback unvollstaendig", output.getvalue())
        self.assertIn("locked cache", output.getvalue())
        self.assertTrue(self.prefix.exists())
        self.assertFalse(marker.exists())

    def test_build_failure_rolls_back_readonly_cache_without_losing_original_error(self):
        self.outer.mkdir(parents=True)
        marker = self.prefix / "build-ready.json"

        def fail(prefix, spec):
            self.cache_fixture()
            raise ValueError("original build failure")

        with patch.object(tool, "preflight"), patch.object(tool, "fetch_source"), \
             patch.object(tool, "build", side_effect=fail), redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "original build failure"):
                tool.install(self.outer, self.prefix, marker, tool.TOOLS["caddy"])
        self.assertFalse(self.prefix.exists())

    def test_success_after_readonly_cache_cleanup_gets_a_valid_build_marker(self):
        self.outer.mkdir(parents=True)
        marker = self.prefix / "build-ready.json"
        spec = tool.TOOLS["caddy"]

        def build(prefix, spec):
            self.cache_fixture()
            binary = prefix / "bin/caddy"
            binary.parent.mkdir()
            binary.write_bytes(b"built fixture")
            tool.remove_native_tree(prefix, cache_only=True)
            return ["bin/caddy"]

        def git(path, *args):
            return spec["recipe"]["pin"] if args == ("rev-parse", "HEAD") else tool.source_origin(spec["recipe"])

        with patch.object(tool, "preflight"), patch.object(tool, "fetch_source"), \
             patch.object(tool, "build", side_effect=build), patch.object(tool.common, "git", side_effect=git), \
             redirect_stdout(io.StringIO()):
            tool.install(self.outer, self.prefix, marker, spec)
            record = tool.validate(self.prefix, marker, spec, full=True)
        self.assertEqual(record["artifacts"], ["bin/caddy"])
        self.assertFalse(record["application_tested"])
        self.assertFalse((self.prefix / "_build").exists())


if __name__ == "__main__":
    unittest.main()
