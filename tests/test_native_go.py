"""Private Go prerequisite contracts; no archive downloads or compilers."""
from contextlib import redirect_stdout
import io
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts/tools/helpers"))
import native_go as go
import native_github_tools as tools


class NativeGoTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.spec = tools.TOOLS["node_exporter"]
        for mocked in (patch.object(go.shutil, "which", return_value=None),
                       patch.object(go.private_go, "target", return_value=("linux-amd64", "fixture.tar.gz", ("fixture", 1))),
                       patch.object(go.sys, "stdin", Mock(isatty=Mock(return_value=False)))):
            mocked.start()
            self.addCleanup(mocked.stop)

    def test_version_contract_rejects_old_development_and_invalid_versions(self):
        for text, expected in (("go version go1.26.0 linux/amd64", True), ("go version go1.27.3 linux/arm64", True),
                               ("go version go1.25.9 linux/amd64", False), ("go version devel linux/amd64", False), ("garbage", False)):
            self.assertEqual(go.version_ok(text, [1, 26, 0]), expected)

    def test_existing_suitable_go_never_downloads_or_changes_environment(self):
        env = dict(os.environ)
        with patch.object(go.shutil, "which", return_value="/existing/go"), patch.object(go.common, "run", return_value="go version go1.26.1 linux/amd64") as run, patch.object(go.private_go, "ensure") as ensure, redirect_stdout(io.StringIO()):
            binary, root = go.select(self.base, self.spec)
        self.assertEqual((binary, root), ("/existing/go", None))
        self.assertEqual(run.call_args.args[2]["GOTOOLCHAIN"], "local")
        self.assertEqual(dict(os.environ), env)
        ensure.assert_not_called()

    def test_missing_or_old_go_requires_consent_before_download(self):
        for binary in (None, "/old/go"):
            with self.subTest(binary=binary), patch.object(go.shutil, "which", return_value=binary), patch.object(go.common, "run", return_value="go version go1.24.0 linux/amd64"), patch.object(go.private_go, "ensure") as ensure, redirect_stdout(io.StringIO()):
                with self.assertRaisesRegex(ValueError, "nicht freigegeben"):
                    go.prepare(self.base, self.spec)
            ensure.assert_not_called()

    def test_interactive_refusal_does_not_download(self):
        with patch.object(go.sys.stdin, "isatty", return_value=True), patch("builtins.input", return_value="n"), patch.object(go.private_go, "ensure") as ensure, redirect_stdout(io.StringIO()):
            with self.assertRaises(ValueError):
                go.prepare(self.base, self.spec)
        ensure.assert_not_called()

    def test_explicit_consent_uses_existing_verified_bootstrap(self):
        root = self.base / "toolchain/go"
        def ensure(base, validate):
            validate(root / "bin/go", root, "linux-amd64")
            return str(root / "bin/go"), root
        with patch.object(go.private_go, "ensure", side_effect=ensure) as bootstrap, patch.object(go.common, "run", return_value="go version " + go.private_go.VERSION + " linux/amd64") as run, patch.dict(os.environ, {"OPENAI_API_KEY": "fixture"}), redirect_stdout(io.StringIO()):
            go.prepare(self.base, self.spec, approved=True)
        bootstrap.assert_called_once()
        self.assertNotIn("OPENAI_API_KEY", run.call_args.args[2])

    def test_private_go_wrong_version_or_architecture_is_rejected(self):
        def ensure(base, validate):
            validate(self.base / "bin/go", self.base, "linux-amd64")
        with patch.object(go.private_go, "ensure", side_effect=ensure), patch.object(go.common, "run", return_value="go version go1.25.0 linux/arm64"), redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Version/Architektur"):
                go.prepare(self.base, self.spec, approved=True)

    def test_build_phase_cannot_silently_download_go(self):
        with patch.object(go.private_go, "ensure") as ensure, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "nicht freigegeben"):
                go.activate(self.base, self.spec, {})
        ensure.assert_not_called()

    def test_existing_private_go_updates_only_child_environment(self):
        slot = self.base / "toolchain" / (go.private_go.VERSION + "-linux-amd64")
        slot.mkdir(parents=True)
        root = slot / "go"
        before = dict(os.environ)
        env = {"PATH": "original", "GOTOOLCHAIN": "local"}
        with patch.object(go.private_go, "ensure", return_value=(str(root / "bin/go"), root)) as ensure, redirect_stdout(io.StringIO()):
            go.activate(self.base, self.spec, env)
        ensure.assert_called_once()
        self.assertTrue(env["PATH"].startswith(str(root / "bin") + os.pathsep))
        self.assertEqual(env["GOROOT"], str(root))
        self.assertEqual(dict(os.environ), before)

    def test_other_tools_do_not_trigger_go_download(self):
        with patch.object(go.private_go, "ensure") as ensure:
            go.prepare(self.base, tools.TOOLS["mosquitto"], approved=True)
        ensure.assert_not_called()

    def test_low_disk_fails_before_any_toolchain_or_source_download(self):
        with patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.base)}), patch.object(tools.platform, "system", return_value="Linux"), patch.object(tools.common, "reserve", side_effect=ValueError("Speicherplatzmangel")), patch.object(go.private_go, "ensure") as ensure, patch.object(tools.common, "install") as fetch, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
                tools.main(["node_exporter", "install", "--install-build-deps"])
            self.assertFalse(tools.paths("node_exporter")[2].exists())
            log = list((self.base / "install_logs").glob("*.log"))[0]
            self.assertIn("Speicherplatzmangel", log.read_text())
        ensure.assert_not_called()
        fetch.assert_not_called()

    def test_private_download_error_is_logged_without_build_success(self):
        with patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.base)}), patch.object(tools.platform, "system", return_value="Linux"), patch.object(tools.common, "reserve"), patch.object(tools.common, "executable"), patch.object(go.private_go, "ensure", side_effect=ValueError("Offizieller Go-Download fehlgeschlagen")), patch.object(tools.common, "install") as fetch, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Go-Download"):
                tools.main(["node_exporter", "install", "--install-build-deps"])
            self.assertFalse(tools.paths("node_exporter")[2].exists())
            log = list((self.base / "install_logs").glob("*.log"))[0]
            self.assertIn("Go-Download fehlgeschlagen", log.read_text())
        fetch.assert_not_called()

    def test_watchtower_contract_checks_go_mod_minimum_and_help_not_version(self):
        recipe = tools.TOOLS["watchtower"]["recipe"]
        self.assertEqual(recipe["go_min"], [1, 20, 0])
        self.assertEqual(recipe["package"], ".")
        self.assertEqual(recipe["probe"], ["--help"])
        self.assertEqual(go.CONTRACTS["watchtower"], ([1, 20, 0], "docs/tools/watchtower.md"))
        self.assertIn("Archiviertes", recipe["note"])

    def test_watchtower_missing_go_logs_own_command_without_fetch_or_marker(self):
        with patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.base)}), patch.object(tools.platform, "system", return_value="Linux"), patch.object(tools.common, "reserve"), patch.object(tools.common, "executable"), patch.object(go.private_go, "ensure") as ensure, patch.object(tools.common, "install") as fetch, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Watchtower: Go >=1.20.0"):
                tools.main(["watchtower", "install"])
            self.assertFalse(tools.paths("watchtower")[2].exists())
            log = list((self.base / "install_logs").glob("*.log"))[0]
            self.assertIn("watchtower_install.sh --install-build-deps", log.read_text())
        ensure.assert_not_called()
        fetch.assert_not_called()

    def test_watchtower_suitable_existing_go_is_preferred(self):
        with patch.object(go.shutil, "which", return_value="/existing/go"), patch.object(go.common, "run", return_value="go version go1.20.14 linux/amd64"), patch.object(go.private_go, "ensure") as ensure, redirect_stdout(io.StringIO()):
            self.assertEqual(go.select(self.base, tools.TOOLS["watchtower"]), ("/existing/go", None))
        ensure.assert_not_called()

    def test_watchtower_acceptance_activates_verified_private_go_only_for_child(self):
        spec = tools.TOOLS["watchtower"]
        slot = self.base / "toolchain" / (go.private_go.VERSION + "-linux-amd64")
        root = slot / "go"
        def ensure(base, validate):
            slot.mkdir(parents=True, exist_ok=True)
            validate(root / "bin/go", root, "linux-amd64")
            return str(root / "bin/go"), root
        before = dict(os.environ)
        env = {"PATH": "original", "GOTOOLCHAIN": "local"}
        with patch.object(go.private_go, "ensure", side_effect=ensure), patch.object(go.common, "run", return_value="go version " + go.private_go.VERSION + " linux/amd64"), redirect_stdout(io.StringIO()):
            go.prepare(self.base, spec, approved=True)
            go.activate(self.base, spec, env)
        self.assertEqual(env["GOROOT"], str(root))
        self.assertEqual(env["GOTOOLCHAIN"], "local")
        self.assertEqual(dict(os.environ), before)

    def test_watchtower_dry_run_never_downloads_or_creates_workspace(self):
        with patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.base)}), patch.object(go.private_go, "ensure") as ensure, patch.object(tools.common, "install") as fetch, redirect_stdout(io.StringIO()):
            self.assertEqual(tools.main(["watchtower", "install", "--install-build-deps", "--dry-run"]), 0)
            self.assertFalse(list(self.base.iterdir()))
        ensure.assert_not_called()
        fetch.assert_not_called()

    def test_caddy_contract_uses_same_checked_go_minimum_and_version_only_probe(self):
        recipe = tools.TOOLS["caddy"]["recipe"]
        self.assertEqual(recipe["go_min"], [1, 26, 0])
        self.assertEqual(recipe["package"], "./cmd/caddy")
        self.assertEqual(recipe["probe"], ["version"])
        self.assertEqual(go.CONTRACTS["caddy"][1], "docs/tools/caddy.md")

    def test_caddy_refusal_is_logged_with_its_own_repair_command(self):
        output = io.StringIO()
        with patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.base)}), patch.object(tools.platform, "system", return_value="Linux"), patch.object(tools.common, "reserve"), patch.object(tools.common, "executable"), patch.object(go.private_go, "ensure") as ensure, patch.object(tools.common, "install") as fetch, redirect_stdout(output):
            with self.assertRaisesRegex(ValueError, "Caddy: Go >=1.26.0"):
                tools.main(["caddy", "install"])
            self.assertFalse(tools.paths("caddy")[2].exists())
            log = list((self.base / "install_logs").glob("*.log"))[0]
            self.assertIn("caddy_install.sh --install-build-deps", log.read_text())
        ensure.assert_not_called()
        fetch.assert_not_called()
        self.assertNotIn("Node Exporter", output.getvalue())

    def test_caddy_acceptance_validates_private_go_and_changes_only_child_path(self):
        spec = tools.TOOLS["caddy"]
        slot = self.base / "toolchain" / (go.private_go.VERSION + "-linux-amd64")
        root = slot / "go"
        def ensure(base, validate):
            slot.mkdir(parents=True, exist_ok=True)
            validate(root / "bin/go", root, "linux-amd64")
            return str(root / "bin/go"), root
        before = dict(os.environ)
        env = {"PATH": "original", "GOTOOLCHAIN": "local"}
        with patch.object(go.private_go, "ensure", side_effect=ensure) as bootstrap, patch.object(go.common, "run", return_value="go version " + go.private_go.VERSION + " linux/amd64"), redirect_stdout(io.StringIO()):
            go.prepare(self.base, spec, approved=True)
            go.activate(self.base, spec, env)
        self.assertEqual(bootstrap.call_count, 2)
        self.assertEqual(env["GOROOT"], str(root))
        self.assertEqual(env["GOTELEMETRY"], "off")
        self.assertEqual(dict(os.environ), before)

    def test_caddy_existing_suitable_go_never_downloads(self):
        with patch.object(go.shutil, "which", return_value="/existing/go"), patch.object(go.common, "run", return_value="go version go1.26.1 linux/amd64"), patch.object(go.private_go, "ensure") as ensure, redirect_stdout(io.StringIO()):
            self.assertEqual(go.select(self.base, tools.TOOLS["caddy"]), ("/existing/go", None))
        ensure.assert_not_called()

    def test_caddy_dry_run_flag_does_not_download_or_modify_workspace(self):
        with patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.base)}), patch.object(go.private_go, "ensure") as ensure, patch.object(tools.common, "install") as fetch, redirect_stdout(io.StringIO()):
            self.assertEqual(tools.main(["caddy", "install", "--install-build-deps", "--dry-run"]), 0)
            self.assertFalse(list(self.base.iterdir()))
        ensure.assert_not_called()
        fetch.assert_not_called()


if __name__ == "__main__":
    unittest.main()
