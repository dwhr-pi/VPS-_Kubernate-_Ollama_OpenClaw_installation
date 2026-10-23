"""Offline Node/pnpm prerequisite contracts; no hardware or network access."""
from contextlib import redirect_stdout
import hashlib
import io
import os
from pathlib import Path
import sys
import tarfile
import tempfile
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts/tools/helpers"))
import native_node as node
import native_github_tools as tools


class NativeNodeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.spec = tools.TOOLS["zigbee2mqtt"]
        for mocked in (patch.object(node.shutil, "which", return_value=None),
                       patch.object(node.releases, "host_key", return_value="linux-amd64"),
                       patch.object(node.sys, "stdin", Mock(isatty=Mock(return_value=False)))):
            mocked.start()
            self.addCleanup(mocked.stop)

    def version(self, args, *ignored):
        return "v" + node.NODE if Path(args[0]).name == "node" else node.PNPM

    def bootstrap(self):
        def unpack_node(archive, destination, arch):
            destination.write_bytes(b"node-fixture")
        def unpack_pnpm(archive, destination):
            (destination / "pnpm").write_bytes(b"pnpm-fixture")
        with patch.object(node, "download_node") as ndownload, \
             patch.object(node.releases, "download") as pdownload, \
             patch.object(node, "unpack_node", side_effect=unpack_node), \
             patch.object(node.releases, "unpack", side_effect=unpack_pnpm), \
             patch.object(node.releases, "reserve") as reserve, \
             patch.object(node.common, "run", side_effect=self.version), redirect_stdout(io.StringIO()):
            node.prepare(self.base, self.spec, approved=True)
        return ndownload, pdownload, reserve

    def test_supported_node_versions_combine_app_and_pnpm_constraints(self):
        for version, expected in (("v22.2.0", False), ("v22.13.0", True), ("v22.23.4", True),
                                  ("v24.0.0", True), ("v23.0.0", False), ("v26.3.0", False),
                                  ("v22.23.4-dev", False)):
            self.assertEqual(node.node_ok(version), expected)

    def test_missing_tools_need_consent_without_any_download(self):
        with patch.object(node, "download_node") as download, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "nicht freigegeben"):
                node.prepare(self.base, self.spec)
        download.assert_not_called()
        self.assertFalse(list(self.base.iterdir()))

    def test_interactive_decline_never_downloads(self):
        with patch.object(node.sys.stdin, "isatty", return_value=True), patch("builtins.input", return_value="n"), \
             patch.object(node, "download_node") as download, redirect_stdout(io.StringIO()):
            with self.assertRaises(ValueError):
                node.prepare(self.base, self.spec)
        download.assert_not_called()

    def test_existing_pair_is_preferred_and_corepack_network_disabled(self):
        before = dict(os.environ)
        with patch.object(node.shutil, "which", side_effect=lambda name: "/existing/" + name), \
             patch.object(node.common, "run", side_effect=self.version) as run, \
             patch.object(node, "download_node") as download, redirect_stdout(io.StringIO()):
            self.assertEqual(node.select(self.base, self.spec), (str(Path("/existing/node").parent), str(Path("/existing/pnpm").parent)))
        self.assertEqual(run.call_args.args[2]["COREPACK_ENABLE_NETWORK"], "0")
        self.assertEqual(before, dict(os.environ))
        download.assert_not_called()

    def test_verified_bootstrap_and_full_inventory_reuse(self):
        ndownload, pdownload, reserve = self.bootstrap()
        arch, size, digest, psize, phash = node.ASSETS["linux-amd64"]
        self.assertEqual(ndownload.call_args.args[2:], (size, digest))
        self.assertEqual(pdownload.call_args.args[2:], (psize, phash))
        self.assertIn("nodejs.org/dist/v" + node.NODE, ndownload.call_args.args[0])
        self.assertIn("github.com/pnpm/pnpm/releases/download/v" + node.PNPM, pdownload.call_args.args[0])
        reserve.assert_called_once_with(self.base, {"reserve_mb": 9216})
        with patch.object(node.common, "run", side_effect=self.version), patch.object(node, "download_node") as download:
            pair = node.select(self.base, self.spec)
        self.assertTrue((Path(pair[0]) / "node").is_file())
        download.assert_not_called()

    def test_tampered_private_files_fail_without_redownload(self):
        self.bootstrap()
        next(path for path in (self.base / "toolchain").rglob("node") if path.is_file()).write_bytes(b"modified")
        with patch.object(node, "download_node") as download:
            with self.assertRaises(ValueError):
                node.select(self.base, self.spec)
        download.assert_not_called()

    def test_low_disk_aborts_before_download_and_staging(self):
        with patch.object(node.releases, "reserve", side_effect=ValueError("Speicherplatzmangel")), \
             patch.object(node, "download_node") as download, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
                node.prepare(self.base, self.spec, approved=True)
        download.assert_not_called()
        self.assertFalse(list(self.base.iterdir()))

    def test_download_failure_preserves_existing_data(self):
        existing = self.base / "keep"
        existing.write_text("data")
        with patch.object(node.releases, "reserve"), \
             patch.object(node, "download_node", side_effect=ValueError("SHA256")), redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "SHA256"):
                node.prepare(self.base, self.spec, approved=True)
        self.assertEqual(list(self.base.iterdir()), [existing])

    def test_activate_updates_only_child_path_and_has_no_download(self):
        self.bootstrap()
        before = dict(os.environ)
        env = {"PATH": "original"}
        with patch.object(node.common, "run", side_effect=self.version), patch.object(node, "download_node") as download:
            node.activate(self.base, self.spec, env)
        self.assertTrue(env["PATH"].endswith(os.pathsep + "original"))
        self.assertEqual(env["COREPACK_ENABLE_NETWORK"], "0")
        self.assertEqual(before, dict(os.environ))
        download.assert_not_called()

    def test_dry_run_with_consent_does_not_create_workspace(self):
        with patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.base)}), \
             patch.object(node, "prepare") as prepare, redirect_stdout(io.StringIO()):
            self.assertEqual(tools.main(["zigbee2mqtt", "install", "--dry-run", "--install-build-deps"]), 0)
        prepare.assert_not_called()
        self.assertFalse(list(self.base.iterdir()))

    def test_node_download_size_hash_and_host_are_checked(self):
        data = b"fixture"
        opener = Mock()
        opener.open.side_effect = lambda *a, **k: io.BytesIO(data)
        with patch.object(node, "build_opener", return_value=opener):
            node.download_node("https://nodejs.org/fixture", self.base / "valid", len(data), hashlib.sha256(data).hexdigest())
            with self.assertRaisesRegex(ValueError, "SHA256"):
                node.download_node("https://nodejs.org/fixture", self.base / "invalid", len(data), "0" * 64)
            with self.assertRaisesRegex(ValueError, "groesser"):
                node.download_node("https://nodejs.org/fixture", self.base / "oversize", 1, "0" * 64)
            with self.assertRaisesRegex(ValueError, "Downloadquelle"):
                node.download_node("https://example.com/fixture", self.base / "foreign", 1, "0" * 64)
        self.assertEqual((self.base / "valid").read_bytes(), data)

    def test_foreign_or_insecure_redirect_is_blocked(self):
        for url in ("http://nodejs.org/a", "https://example.com/a", "https://user:pass@nodejs.org/a"):
            with self.assertRaisesRegex(ValueError, "Redirect"):
                node.NodeRedirect().redirect_request(None, None, 302, "", {}, url)

    def test_node_unpack_selects_only_regular_binary(self):
        archive = self.base / "node.tar.gz"
        name = "node-v" + node.NODE + "-linux-x64/bin/node"
        with tarfile.open(archive, "w:gz") as bundle:
            member = tarfile.TarInfo(name)
            member.size = 4
            bundle.addfile(member, io.BytesIO(b"node"))
            link = tarfile.TarInfo("unrelated-npm-link")
            link.type, link.linkname = tarfile.SYMTYPE, "/outside"
            bundle.addfile(link)
        node.unpack_node(archive, self.base / "node", "x64")
        self.assertEqual((self.base / "node").read_bytes(), b"node")
        self.assertFalse((self.base / "unrelated-npm-link").exists())

    def test_symlink_in_place_of_node_is_rejected(self):
        archive = self.base / "linked.tar.gz"
        with tarfile.open(archive, "w:gz") as bundle:
            member = tarfile.TarInfo("node-v" + node.NODE + "-linux-x64/bin/node")
            member.type, member.linkname = tarfile.SYMTYPE, "/outside"
            bundle.addfile(member)
        with self.assertRaisesRegex(ValueError, "unsicher"):
            node.unpack_node(archive, self.base / "node", "x64")
        self.assertFalse((self.base / "node").exists())

    def test_extra_bootstrap_reserve_failure_is_logged_before_source_fetch(self):
        with patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.base)}), \
             patch.object(tools.platform, "system", return_value="Linux"), \
             patch.object(tools.common, "reserve"), patch.object(tools.common, "executable"), \
             patch.object(node.releases, "reserve", side_effect=ValueError("Speicherplatzmangel: 9216 MiB erforderlich")), \
             patch.object(node, "download_node") as download, patch.object(tools.common, "install") as fetch, \
             redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "9216"):
                tools.main(["zigbee2mqtt", "install", "--install-build-deps"])
            log = next((self.base / "install_logs").glob("*.log"))
            self.assertIn("9216 MiB erforderlich", log.read_text())
            self.assertFalse(tools.paths("zigbee2mqtt")[2].exists())
        download.assert_not_called()
        fetch.assert_not_called()


if __name__ == "__main__":
    unittest.main()
