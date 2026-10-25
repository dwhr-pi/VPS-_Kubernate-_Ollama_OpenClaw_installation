"""Offline Node-RED prerequisite fixtures; no downloads, npm or flow execution."""
from contextlib import redirect_stdout
import io
import json
import os
from pathlib import Path
import sys
import tarfile
import tempfile
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts/tools/helpers"))
import native_node_npm as helper
import native_github_tools as tools


class NodeNpmTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.spec = tools.TOOLS["node_red"]
        for mocked in (patch.object(helper.shutil, "which", return_value=None),
                       patch.object(helper.releases, "host_key", return_value="linux-amd64"),
                       patch.object(helper.node.sys, "stdin", Mock(isatty=Mock(return_value=False)))):
            mocked.start()
            self.addCleanup(mocked.stop)

    def versions(self, args, *ignored):
        return "v" + helper.node.NODE if Path(args[0]).name == "node" else helper.NPM

    def unpack(self, archive, payload, arch):
        (payload / "node").write_bytes(b"node fixture")
        (payload / "npm").write_bytes(b"npm fixture")

    def bootstrap(self):
        with patch.object(helper.node, "download_node") as download, \
             patch.object(helper, "unpack", side_effect=self.unpack), \
             patch.object(helper.releases, "reserve") as reserve, \
             patch.object(helper.common, "run", side_effect=self.versions), redirect_stdout(io.StringIO()):
            helper.prepare(self.base, self.spec, True)
        return download, reserve

    def test_bootstrap_hash_reserve_reuse_and_child_environment(self):
        download, reserve = self.bootstrap()
        self.assertEqual(download.call_args.args[2:], helper.node.ASSETS["linux-amd64"][1:3])
        reserve.assert_called_once_with(self.base, {"reserve_mb": 9216})
        before = dict(os.environ)
        env = {"PATH": "original"}
        with patch.object(helper.common, "run", side_effect=self.versions), \
             patch.object(helper.node, "download_node") as fetch, redirect_stdout(io.StringIO()):
            helper.activate(self.base, self.spec, env)
        fetch.assert_not_called()
        self.assertEqual(dict(os.environ), before)
        self.assertTrue(env["PATH"].endswith(os.pathsep + "original"))

    def test_missing_pair_requires_consent(self):
        with patch.object(helper.node, "download_node") as download, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "nicht freigegeben"):
                helper.prepare(self.base, self.spec)
        download.assert_not_called()
        self.assertEqual(list(self.base.iterdir()), [])

    def test_existing_pair_preferred(self):
        with patch.object(helper.shutil, "which", side_effect=lambda name: "/existing/" + name), \
             patch.object(helper.common, "run", side_effect=self.versions), \
             patch.object(helper.node, "download_node") as download, redirect_stdout(io.StringIO()):
            helper.select(self.base, self.spec)
        download.assert_not_called()

    def test_download_and_version_failure_leave_no_ready_marker(self):
        for fail_download in (True, False):
            with self.subTest(download=fail_download), \
                 patch.object(helper.releases, "reserve"), \
                 patch.object(helper.node, "download_node", side_effect=ValueError("hash") if fail_download else None), \
                 patch.object(helper, "unpack", side_effect=self.unpack), \
                 patch.object(helper.common, "run", return_value="wrong"), redirect_stdout(io.StringIO()):
                with self.assertRaises(ValueError):
                    helper.prepare(self.base, self.spec, True)
            self.assertEqual(list(self.base.iterdir()), [])

    def test_low_disk_never_downloads(self):
        with patch.object(helper.releases, "reserve", side_effect=ValueError("Speicherplatzmangel")), \
             patch.object(helper.node, "download_node") as download, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
                helper.prepare(self.base, self.spec, True)
        download.assert_not_called()

    def test_tampered_cached_file_is_rejected(self):
        self.bootstrap()
        next((self.base / "toolchain").rglob("npm")).write_bytes(b"modified")
        with patch.object(helper.node, "download_node") as download:
            with self.assertRaises(ValueError):
                helper.select(self.base, self.spec)
        download.assert_not_called()

    def test_dry_run_never_prepares_node(self):
        with patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.base)}), \
             patch.object(helper, "prepare") as prepare, redirect_stdout(io.StringIO()):
            self.assertEqual(tools.main(["node_red", "install", "--dry-run", "--install-build-deps"]), 0)
        prepare.assert_not_called()
        self.assertEqual(list(self.base.iterdir()), [])

    def test_only_node_red_contract_allowed(self):
        with self.assertRaisesRegex(ValueError, "Nicht freigegebener"):
            helper.select(self.base, {"id": "other", "recipe": {"private_node_npm": helper.node.NODE}})

    def archive(self, malicious=None):
        archive = self.base / "node.tar.gz"
        prefix = "node-v" + helper.node.NODE + "-linux-x64/"
        entries = {prefix + "bin/node": b"node", prefix + "lib/node_modules/npm/package.json":
                   json.dumps({"version": helper.NPM}).encode(),
                   prefix + "lib/node_modules/npm/bin/npm-cli.js": b"fixture"}
        if malicious:
            entries[prefix + "lib/node_modules/npm/../../outside"] = b"bad"
        with tarfile.open(archive, "w:gz") as bundle:
            for name, data in entries.items():
                member = tarfile.TarInfo(name)
                member.size = len(data)
                bundle.addfile(member, io.BytesIO(data))
        return archive

    def test_unpack_regular_files_and_portable_launcher(self):
        payload = self.base / "app"
        payload.mkdir()
        helper.unpack(self.archive(), payload, "x64")
        self.assertIn('"${0%/*}/npm-package/bin/npm-cli.js"', (payload / "npm").read_text())
        self.assertEqual((payload / "node").read_bytes(), b"node")

    def test_unpack_rejects_path_traversal(self):
        payload = self.base / "app"
        payload.mkdir()
        with self.assertRaisesRegex(ValueError, "Archivpfad"):
            helper.unpack(self.archive(malicious=True), payload, "x64")
        self.assertFalse((self.base / "outside").exists())

    def test_unpack_rejects_archive_links(self):
        archive = self.archive()
        # Recreate the small fixture with an npm-package symlink.
        with tarfile.open(archive, "r:gz") as source:
            records = [(entry, source.extractfile(entry).read()) for entry in source]
        with tarfile.open(archive, "w:gz") as output:
            for entry, data in records:
                output.addfile(entry, io.BytesIO(data))
            link = tarfile.TarInfo("node-v" + helper.node.NODE + "-linux-x64/lib/node_modules/npm/linked")
            link.type, link.linkname = tarfile.SYMTYPE, "/outside"
            output.addfile(link)
        payload = self.base / "app"
        payload.mkdir()
        with self.assertRaisesRegex(ValueError, "Nicht regulaerer"):
            helper.unpack(archive, payload, "x64")

    def test_preflight_defers_node_and_npm_to_private_bootstrap(self):
        with patch.object(tools.platform, "system", return_value="Linux"), \
             patch.object(tools.common, "reserve"), \
             patch.object(tools.common, "executable") as executable, \
             patch.object(tools.adapters, "preflight"), \
             patch.object(helper, "prepare") as prepare:
            tools.preflight(self.base, self.spec, install_build_deps=True)
        names = [call.args[0] for call in executable.call_args_list]
        self.assertIn("git", names)
        self.assertNotIn("node", names)
        self.assertNotIn("npm", names)
        prepare.assert_called_once_with(self.base, self.spec, approved=True)


if __name__ == "__main__":
    unittest.main()
