"""Private uv prerequisite tests; no downloads or application execution."""
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
import native_uv as uv
import native_github_tools as tools


class NativeUvTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.spec = tools.TOOLS["searxng"]
        for mocked in (patch.object(uv.shutil, "which", return_value=None),
                       patch.object(uv.releases, "host_key", return_value="linux-amd64"),
                       patch.object(uv.sys, "stdin", Mock(isatty=Mock(return_value=False)))):
            mocked.start()
            self.addCleanup(mocked.stop)

    def unpack(self, archive, payload):
        target = payload / "uv-linux"
        target.mkdir()
        (target / "uv").write_bytes(b"fixture-binary")

    def bootstrap(self):
        with patch.object(uv.releases, "download") as download, \
             patch.object(uv.releases, "unpack", side_effect=self.unpack), \
             patch.object(uv.releases, "reserve") as reserve, \
             patch.object(uv.common, "run", return_value="uv " + uv.VERSION), \
             redirect_stdout(io.StringIO()):
            uv.prepare(self.base, self.spec, approved=True)
        return download, reserve

    def test_version_parser(self):
        for value, expected in (("uv 0.13.5", True), ("uv 0.13.6 (abc)", True),
                                ("uv 0.13.4", False), ("uv 0.13.5-dev", False), ("garbage", False)):
            self.assertEqual(uv.version_ok(value), expected)

    def test_existing_uv_preserves_parent_environment_and_never_downloads(self):
        original = dict(os.environ)
        with patch.object(uv.shutil, "which", return_value="/existing/uv"), \
             patch.object(uv.common, "run", return_value="uv 0.13.5") as run, \
             patch.object(uv.releases, "download") as download, redirect_stdout(io.StringIO()):
            self.assertEqual(uv.select(self.base, self.spec), "/existing/uv")
        self.assertEqual(dict(os.environ), original)
        self.assertEqual(run.call_args.args[2]["UV_PYTHON_DOWNLOADS"], "never")
        self.assertNotIn("OPENAI_API_KEY", run.call_args.args[2])
        download.assert_not_called()

    def test_missing_uv_requires_explicit_consent(self):
        with patch.object(uv.releases, "download") as download, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "nicht freigegeben"):
                uv.prepare(self.base, self.spec)
        download.assert_not_called()
        self.assertEqual(list(self.base.iterdir()), [])

    def test_broken_existing_uv_still_requires_consent(self):
        with patch.object(uv.shutil, "which", return_value="/broken/uv"), \
             patch.object(uv.common, "run", side_effect=subprocess.CalledProcessError(127, "uv")), \
             patch.object(uv.releases, "download") as download, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "nicht freigegeben"):
                uv.prepare(self.base, self.spec)
        download.assert_not_called()

    def test_interactive_refusal(self):
        with patch.object(uv.sys.stdin, "isatty", return_value=True), \
             patch("builtins.input", return_value="n"), \
             patch.object(uv.releases, "download") as download, redirect_stdout(io.StringIO()):
            with self.assertRaises(ValueError):
                uv.prepare(self.base, self.spec)
        download.assert_not_called()

    def test_pinned_bootstrap_and_full_inventory_reuse(self):
        download, reserve = self.bootstrap()
        args = download.call_args.args
        filename, size, digest = uv.ARTIFACTS["linux-amd64"]
        self.assertEqual(args[0], "https://github.com/astral-sh/uv/releases/download/" + uv.VERSION + "/" + filename)
        self.assertEqual(args[2:], (size, digest))
        reserve.assert_called_once_with(self.base, {"reserve_mb": 8448})
        with patch.object(uv.releases, "download") as download, \
             patch.object(uv.common, "run", return_value="uv " + uv.VERSION), redirect_stdout(io.StringIO()):
            binary = uv.select(self.base, self.spec)
        self.assertTrue(Path(binary).is_file())
        download.assert_not_called()

    def test_modified_cached_binary_is_not_activated(self):
        self.bootstrap()
        binary = next((self.base / "toolchain").rglob("uv"))
        binary.write_bytes(b"modified")
        with patch.object(uv.releases, "download") as download, redirect_stdout(io.StringIO()):
            with self.assertRaises(ValueError):
                uv.select(self.base, self.spec)
        download.assert_not_called()

    def test_low_disk_aborts_before_download_or_staging(self):
        with patch.object(uv.releases, "reserve", side_effect=ValueError("Speicherplatzmangel")), \
             patch.object(uv.releases, "download") as download, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
                uv.prepare(self.base, self.spec, approved=True)
        download.assert_not_called()
        self.assertEqual(list(self.base.iterdir()), [])

    def test_download_failure_cleans_only_new_staging(self):
        existing = self.base / "preserve.txt"
        existing.write_text("keep")
        with patch.object(uv.releases, "reserve"), \
             patch.object(uv.releases, "download", side_effect=ValueError("SHA256")), redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "SHA256"):
                uv.prepare(self.base, self.spec, approved=True)
        self.assertEqual(list(self.base.iterdir()), [existing])

    def test_wrong_downloaded_version_has_no_marker(self):
        with patch.object(uv.releases, "reserve"), patch.object(uv.releases, "download"), \
             patch.object(uv.releases, "unpack", side_effect=self.unpack), \
             patch.object(uv.common, "run", return_value="uv 0.1.0"), redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Version"):
                uv.prepare(self.base, self.spec, approved=True)
        self.assertEqual(list(self.base.iterdir()), [])

    def test_activate_only_changes_child_environment(self):
        self.bootstrap()
        original = dict(os.environ)
        child = {"PATH": "/existing"}
        with patch.object(uv.common, "run", return_value="uv " + uv.VERSION), \
             patch.object(uv.releases, "download") as download, redirect_stdout(io.StringIO()):
            uv.activate(self.base, self.spec, child)
        self.assertEqual(dict(os.environ), original)
        self.assertTrue(child["PATH"].endswith(os.pathsep + "/existing"))
        self.assertEqual(child["UV_NO_CONFIG"], "1")
        self.assertEqual(child["UV_PYTHON_DOWNLOADS"], "never")
        download.assert_not_called()

    def test_unsupported_platform_does_not_download(self):
        with patch.object(uv.releases, "host_key", return_value="windows-amd64"), \
             patch.object(uv.releases, "download") as download:
            with self.assertRaisesRegex(ValueError, "Linux"):
                uv.prepare(self.base, self.spec, approved=True)
        download.assert_not_called()

    def test_recipe_uses_checkout_settings_and_supported_python(self):
        recipe = self.spec["recipe"]
        self.assertEqual(recipe["build_env"]["SEARXNG_SETTINGS_PATH"], "{source}/searx/settings.yml")
        self.assertEqual(recipe["python_min"], [3, 10, 0])
        self.assertEqual(recipe["python_max"], [3, 14, 0])

    def test_dry_run_with_consent_still_has_no_side_effects(self):
        with patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.base)}), \
             patch.object(uv, "prepare") as prepare, \
             patch.object(tools.common, "operation") as operation, redirect_stdout(io.StringIO()):
            self.assertEqual(tools.main(["searxng", "install", "--dry-run", "--install-build-deps"]), 0)
        prepare.assert_not_called()
        operation.assert_not_called()
        self.assertEqual(list(self.base.iterdir()), [])

    def test_incompatible_python_prevents_uv_download(self):
        with patch.object(tools.platform, "system", return_value="Linux"), \
             patch.object(tools.common, "reserve"), patch.object(tools.common, "executable"), \
             patch.object(tools.build_deps, "prepare"), patch.object(tools.native_go, "prepare"), \
             patch.object(tools.adapters, "preflight"), \
             patch.object(tools.common, "run", side_effect=subprocess.CalledProcessError(1, "python")), \
             patch.object(uv, "prepare") as prepare:
            with self.assertRaises(subprocess.CalledProcessError):
                tools.preflight(self.base, self.spec, install_build_deps=True)
        prepare.assert_not_called()


class ArchiveBoxUvTests(NativeUvTests):
    """Exercise the same consent, rollback and cache contract for ArchiveBox."""

    def setUp(self):
        super().setUp()
        self.spec = tools.TOOLS["archivebox"]

    def test_incompatible_python_prevents_uv_download(self):
        with patch.object(tools.platform, "system", return_value="Linux"), \
             patch.object(tools.common, "reserve"), patch.object(tools.common, "executable"), \
             patch.object(tools.build_deps, "prepare"), patch.object(tools.native_go, "prepare"), \
             patch.object(tools.adapters, "preflight"), \
             patch.object(tools.archivebox_python, "select", side_effect=ValueError("Python nicht freigegeben")), \
             patch.object(uv, "prepare") as prepare:
            with self.assertRaisesRegex(ValueError, "Python nicht freigegeben"):
                tools.preflight(self.base, self.spec)
        prepare.assert_not_called()

    def test_recipe_uses_checkout_settings_and_supported_python(self):
        recipe = self.spec["recipe"]
        self.assertEqual(recipe["private_uv"], uv.VERSION)
        self.assertEqual(recipe["python_min"], [3, 13, 0])
        self.assertEqual(recipe["repo"], "ArchiveBox/ArchiveBox")
        self.assertEqual(recipe["kind"], "python")

    def test_dry_run_with_consent_still_has_no_side_effects(self):
        with patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.base)}), \
             patch.object(uv, "prepare") as prepare, \
             patch.object(tools.common, "operation") as operation, redirect_stdout(io.StringIO()):
            self.assertEqual(tools.main(["archivebox", "install", "--dry-run", "--install-build-deps"]), 0)
        prepare.assert_not_called()
        operation.assert_not_called()
        self.assertEqual(list(self.base.iterdir()), [])

    def test_messages_name_archivebox_not_searxng(self):
        output = io.StringIO()
        with redirect_stdout(output):
            with self.assertRaisesRegex(ValueError, "docs/tools/archivebox.md"):
                uv.prepare(self.base, self.spec)
        self.assertIn("ArchiveBox", output.getvalue())
        self.assertIn("archivebox_install.sh --install-build-deps", output.getvalue())
        self.assertNotIn("SearXNG", output.getvalue())

    def test_unapproved_recipe_cannot_enable_private_uv(self):
        with patch.object(uv.releases, "download") as download:
            with self.assertRaisesRegex(ValueError, "Nicht freigegebener"):
                uv.prepare(self.base, {"id": "unreviewed", "recipe": {"private_uv": uv.VERSION}}, True)
        download.assert_not_called()


class ChangedetectionUvTests(NativeUvTests):
    """Reuse all offline consent, rollback and inventory checks for this tool."""

    def setUp(self):
        super().setUp()
        self.spec = tools.TOOLS["changedetection_io"]

    def test_recipe_uses_checkout_settings_and_supported_python(self):
        recipe = self.spec["recipe"]
        self.assertEqual(recipe["private_uv"], uv.VERSION)
        self.assertEqual(recipe["python_min"], [3, 11, 0])
        self.assertEqual(recipe["repo"], "dgtlmoon/changedetection.io")
        self.assertEqual(recipe["kind"], "python")
        self.assertEqual(recipe["distribution"], "changedetection.io")

    def test_dry_run_with_consent_still_has_no_side_effects(self):
        with patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.base)}), \
             patch.object(uv, "prepare") as prepare, \
             patch.object(tools.common, "operation") as operation, redirect_stdout(io.StringIO()):
            self.assertEqual(tools.main(["changedetection_io", "install", "--dry-run", "--install-build-deps"]), 0)
        prepare.assert_not_called()
        operation.assert_not_called()
        self.assertEqual(list(self.base.iterdir()), [])

    def test_missing_uv_names_the_correct_tool_and_command(self):
        output = io.StringIO()
        with redirect_stdout(output):
            with self.assertRaisesRegex(ValueError, "docs/tools/changedetection_io.md"):
                uv.prepare(self.base, self.spec)
        self.assertIn("Changedetection_IO", output.getvalue())
        self.assertIn("changedetection_io_install.sh --install-build-deps", output.getvalue())
        self.assertNotIn("SearXNG", output.getvalue())
        self.assertNotIn("ArchiveBox", output.getvalue())


class LiteLLMUvTests(NativeUvTests):
    """Keep LiteLLM on the same private bootstrap safety contract."""

    def setUp(self):
        super().setUp()
        self.spec = tools.TOOLS["litellm"]

    def test_recipe_uses_checkout_settings_and_supported_python(self):
        recipe = self.spec["recipe"]
        self.assertEqual(recipe["private_uv"], uv.VERSION)
        self.assertEqual(recipe["python_min"], [3, 10, 0])
        self.assertEqual(recipe["python_max"], [3, 15, 0])
        self.assertEqual(recipe["repo"], "BerriAI/litellm")
        self.assertEqual(recipe["extras"], "proxy")
        self.assertEqual(recipe["distribution"], "litellm")

    def test_dry_run_with_consent_still_has_no_side_effects(self):
        with patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.base)}), \
             patch.object(uv, "prepare") as prepare, \
             patch.object(tools.common, "operation") as operation, redirect_stdout(io.StringIO()):
            self.assertEqual(tools.main(["litellm", "install", "--dry-run", "--install-build-deps"]), 0)
        prepare.assert_not_called()
        operation.assert_not_called()
        self.assertEqual(list(self.base.iterdir()), [])

    def test_missing_uv_names_litellm_not_other_tools(self):
        output = io.StringIO()
        with redirect_stdout(output):
            with self.assertRaisesRegex(ValueError, "docs/tools/litellm.md"):
                uv.prepare(self.base, self.spec)
        self.assertIn("LiteLLM", output.getvalue())
        self.assertIn("litellm_install.sh --install-build-deps", output.getvalue())
        self.assertNotIn("SearXNG", output.getvalue())
        self.assertNotIn("ArchiveBox", output.getvalue())


if __name__ == "__main__":
    unittest.main()
