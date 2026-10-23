"""Packaging adapter contracts without downloads, compilers or service starts."""
from contextlib import redirect_stdout
import hashlib
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts/tools/helpers"))
import native_github_adapters as adapters
import native_github_tools as tools


class AdapterTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.prefix = Path(self.temp.name)
        (self.prefix / "_build").mkdir()

    def test_nocodb_changes_only_owned_configuration_and_private_generator(self):
        checkout = self.prefix / "source"
        generator = checkout / "packages/nocodb/build-utils/registerIntegrations.js"
        generator.parent.mkdir(parents=True)
        original = "await registerIntegrations(true);"
        generator.write_text(original)
        npmrc = checkout / ".npmrc"
        npmrc.write_text("engine-strict=true\nuse-node-version=24.14.0\n")
        with redirect_stdout(io.StringIO()):
            adapters.prepare(self.prefix, tools.TOOLS["nocodb"], {})
        self.assertNotIn("use-node-version=", npmrc.read_text())
        self.assertIn("use-node-version=", (self.prefix / "upstream.npmrc.original").read_text())
        self.assertEqual(generator.read_text(), original)
        self.assertIn("registerIntegrations(false)", generator.with_name("registerIntegrations.native.cjs").read_text())
        self.assertFalse(json.loads((self.prefix / "packaging-adapter.json").read_text())["runtime_started"])

    def test_nocodb_unknown_node_contract_is_rejected(self):
        checkout = self.prefix / "source"
        checkout.mkdir()
        (checkout / ".npmrc").write_text("use-node-version=other")
        with self.assertRaisesRegex(ValueError, "Node-Vertrag"):
            adapters.prepare(self.prefix, tools.TOOLS["nocodb"], {})
        self.assertFalse((self.prefix / "run-native.cjs").exists())

    def test_nocodb_build_avoids_server_start_and_installs_build_dependencies(self):
        recipe = tools.TOOLS["nocodb"]["recipe"]
        for step in recipe["steps"]:
            self.assertNotIn("rspack.dev.config.js", step["args"])
            if step["args"][:2] == ["pnpm", "install"]:
                self.assertIn("--prod=false", step["args"])
        starter = (adapters.ASSETS / "nocodb_run_native.cjs").read_text()
        self.assertIn("NOCODB_ACCEPT_INITIALIZATION", starter)
        self.assertIn("127.0.0.1", starter)

    def asset(self, payload):
        return dict(url="https://github.com/penpot/skia-binaries/releases/download/test/asset.tar.gz",
                    sha256=hashlib.sha256(payload).hexdigest(), bytes=len(payload))

    def test_asset_is_verified_before_available_to_compiler(self):
        payload = b"offline fixture"
        opener = unittest.mock.Mock()
        opener.open.return_value = io.BytesIO(payload)
        with patch.object(adapters, "build_opener", return_value=opener), redirect_stdout(io.StringIO()):
            target = adapters.download_asset(self.prefix, self.asset(payload))
        self.assertEqual(target.read_bytes(), payload)
        self.assertTrue((self.prefix / "github-build-assets.json").is_file())

    def test_wrong_asset_digest_or_size_never_creates_provenance(self):
        for body in (b"wrong", b"too much data"):
            with self.subTest(body=body):
                (self.prefix / "_build/skia-verified.tar.gz").unlink(missing_ok=True)
                opener = unittest.mock.Mock()
                opener.open.return_value = io.BytesIO(body)
                with patch.object(adapters, "build_opener", return_value=opener), redirect_stdout(io.StringIO()):
                    with self.assertRaises(ValueError):
                        adapters.download_asset(self.prefix, self.asset(b"valid"))
                self.assertFalse((self.prefix / "github-build-assets.json").exists())

    def test_unapproved_asset_and_redirect_host_are_rejected(self):
        asset = self.asset(b"fixture")
        asset["url"] = "https://example.org/asset"
        with self.assertRaises(ValueError):
            adapters.download_asset(self.prefix, asset)
        with self.assertRaisesRegex(ValueError, "Redirect"):
            adapters.GithubRedirects().redirect_request(None, None, 302, "", {}, "https://example.org/asset")

    def test_penpot_missing_sdk_fails_preflight_without_download(self):
        with patch.dict(os.environ, {"PENPOT_EMSDK_ENV": str(self.prefix / "absent")}), patch.object(adapters, "download_asset") as download:
            with self.assertRaisesRegex(ValueError, "SDK"):
                adapters.preflight(tools.TOOLS["penpot"])
        download.assert_not_called()

    def test_penpot_wrong_rust_is_rejected_before_asset_download(self):
        with patch.object(adapters.common, "run", return_value="rustc 1.80.0 fixture"), patch.object(adapters, "download_asset") as download:
            with self.assertRaisesRegex(ValueError, "1.99.0"):
                adapters.prepare(self.prefix, tools.TOOLS["penpot"], {})
        download.assert_not_called()

    def test_penpot_only_selects_existing_target_and_verified_local_asset(self):
        asset = self.prefix / "fixture.tar.gz"
        asset.write_bytes(b"fixture")
        env = {"RUSTUP_TOOLCHAIN": str(self.prefix)}
        with patch.object(adapters.common, "run", side_effect=["rustc 1.99.0 fixture", "wasm32-unknown-emscripten\n"]), patch.object(adapters, "emsdk_path", return_value=self.prefix / "emsdk_env.sh"), patch.object(adapters, "download_asset", return_value=asset):
            adapters.prepare(self.prefix, tools.TOOLS["penpot"], env)
        self.assertTrue(env["SKIA_BINARIES_URL"].startswith("file:"))
        self.assertEqual(env["FORCE_SKIA_BINARIES_DOWNLOAD"], "1")
        wrapper = (self.prefix / "penpot-native-wasm.sh").read_text()
        self.assertNotIn("rustup default", wrapper)
        self.assertNotIn("rustup target add", wrapper)
        self.assertIn("--locked", wrapper)

    def test_pyairbyte_is_not_airbyte_core(self):
        self.assertIsNone(tools.TOOLS["airbyte"]["recipe"])
        recipe = tools.TOOLS["pyairbyte"]["recipe"]
        self.assertEqual(recipe["repo"], "airbytehq/PyAirbyte")
        self.assertEqual(recipe["distribution"], "airbyte")
        self.assertEqual(recipe["python_max"], [3, 13, 0])

    def test_nocodb_manual_starter_defaults_to_help_and_rejects_unsafe_requests(self):
        node = shutil.which("node")
        if not node:
            self.skipTest("Node unavailable for starter validation")
        starter = self.prefix / "run-native.cjs"
        shutil.copy2(adapters.ASSETS / "nocodb_run_native.cjs", starter)
        env = {k: v for k, v in os.environ.items() if not k.startswith("NOCODB_")}
        result = subprocess.run([node, str(starter)], env=env, capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(list(self.prefix.iterdir())), 2)
        cases = [{}, {"NOCODB_ACCEPT_INITIALIZATION": "1", "NOCODB_BIND_HOST": "0.0.0.0"},
                 {"NOCODB_ACCEPT_INITIALIZATION": "1", "NOCODB_PORT": "22"},
                 {"NOCODB_ACCEPT_INITIALIZATION": "1", "NOCODB_DATA_DIR": str(self.prefix)}]
        for extra in cases:
            with self.subTest(env=extra):
                result = subprocess.run([node, str(starter), "--run"], env={**env, **extra}, capture_output=True, text=True, timeout=30)
                self.assertEqual(result.returncode, 1)
                self.assertNotIn("listening", result.stdout)

    def test_penpot_wrapper_calls_build_not_global_setup(self):
        bash = "C:/Program Files/Git/usr/bin/bash.exe" if os.name == "nt" else shutil.which("bash")
        if not bash or not Path(bash).is_file():
            self.skipTest("Bash unavailable")
        checkout = self.prefix / "source"
        wasm = checkout / "render-wasm"
        wasm.mkdir(parents=True)
        sdk = self.prefix / "emsdk_env.sh"
        sdk.write_text("emcc() { :; }\n")
        (wasm / "_build_env").write_text(
            'export RUST_VERSION=1.99.0 CARGO_BUILD_TARGET=wasm32-unknown-emscripten\n'
            'setup() { exit 91; }\nsetup_rust() { exit 92; }\n'
            'build() { [[ "$EM_CACHE" == "$prefix/_build/emscripten-cache" ]]; '
            '[[ "$2" == "--locked" ]]; printf built > "$prefix/built"; }\n'
            'copy_target_artifacts() { printf copied > "$prefix/copied"; }\n')
        # The sourced fixture captures its arguments before the wrapper calls build.
        contents = (wasm / "_build_env").read_text().replace('build() {', 'locked="$2"\nbuild() {').replace('[[ "$2" == "--locked" ]]', '[[ "$locked" == "--locked" ]]')
        (wasm / "_build_env").write_text(contents)
        env = {**os.environ, "PENPOT_EMSDK_ENV": sdk.as_posix(), "SKIA_BINARIES_URL": "file:///verified-fixture.tar.gz", "RUSTUP_TOOLCHAIN": self.prefix.as_posix()}
        result = subprocess.run([bash, "--noprofile", "--norc", str(adapters.ASSETS / "penpot_native_wasm.sh"), checkout.as_posix(), self.prefix.as_posix(), "frontend"], env=env, capture_output=True, text=True, timeout=45)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.prefix / "built").read_text(), "built")
        self.assertEqual((self.prefix / "copied").read_text(), "copied")


if __name__ == "__main__":
    unittest.main()
