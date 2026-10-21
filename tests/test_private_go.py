"""Private Go bootstrap fixtures: no real download, toolchain execution or WSL."""
import hashlib
import errno
import importlib.util
import io
import json
import os
import socket
import ssl
from pathlib import Path
import stat
import sys
import tarfile
import tempfile
import unittest
from unittest import mock
from urllib.error import HTTPError, URLError
from urllib.request import Request
import zipfile

ROOT = Path(__file__).resolve().parents[1]
with mock.patch.object(sys, "path", [str(ROOT / "scripts/tools/helpers"), *sys.path]):
    spec = importlib.util.spec_from_file_location("private_go", ROOT / "scripts/tools/helpers/private_go.py")
    go = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(go)


class PrivateGo(unittest.TestCase):
    def setUp(self):
        temp = tempfile.TemporaryDirectory()
        self.addCleanup(temp.cleanup)
        self.base = Path(temp.name) / "private"
        self.base.mkdir()
        self.capture = mock.patch.object(go, "print", create=True)
        self.capture.start()
        self.addCleanup(self.capture.stop)
        env = mock.patch.dict(os.environ, {"ANTHROPIC_CLI_GO_ARCHIVE": "", "ANTHROPIC_CLI_GO_PROXY_MODE": "auto"})
        env.start()
        self.addCleanup(env.stop)
        proxies = mock.patch.object(go, "getproxies", return_value={})
        proxies.start()
        self.addCleanup(proxies.stop)

    def tar_bytes(self, entries=None):
        entries = entries if entries is not None else [
            ("go/VERSION", go.VERSION.encode() + b"\ntime fixture\n", tarfile.REGTYPE),
            ("go/bin/go", b"not an executable, fixture only", tarfile.REGTYPE),
            ("go/src/runtime/runtime.go", b"synthetic source", tarfile.REGTYPE),
        ]
        output = io.BytesIO()
        with tarfile.open(fileobj=output, mode="w:gz") as archive:
            for name, content, kind in entries:
                item = tarfile.TarInfo(name)
                item.mode = 0o755
                item.type = kind
                item.size = len(content) if kind == tarfile.REGTYPE else 0
                if kind in (tarfile.SYMTYPE, tarfile.LNKTYPE):
                    item.linkname = "../../outside"
                archive.addfile(item, io.BytesIO(content) if item.size else None)
        return output.getvalue()

    def response(self, content, filename):
        response = io.BytesIO(content)
        response.status = 200
        response.geturl = lambda: "https://dl.google.com/go/" + filename
        return response

    def bootstrap(self, content=None, validate=None):
        data = self.tar_bytes() if content is None else content
        filename = go.VERSION + ".linux-amd64.tar.gz"
        checksum = hashlib.sha256(data).hexdigest()
        opener = mock.Mock()
        opener.open.return_value = self.response(data, filename)
        with mock.patch.object(go, "target", return_value=("linux-amd64", filename, (checksum, len(data)))), \
                mock.patch.object(go, "build_opener", return_value=opener), \
                mock.patch.object(go.shutil, "disk_usage", return_value=mock.Mock(free=8 * 1024**3)):
            return go.ensure(self.base, validate or mock.Mock())

    def test_platform_mapping_and_pinned_archive_metadata(self):
        for system, machine, expected in (("Linux", "x86_64", "linux-amd64"),
                                          ("Linux", "aarch64", "linux-arm64"),
                                          ("Windows", "AMD64", "windows-amd64"),
                                          ("Windows", "ARM64", "windows-arm64"),
                                          ("Darwin", "x86_64", "darwin-amd64"),
                                          ("Darwin", "arm64", "darwin-arm64")):
            with mock.patch.object(go.platform, "system", return_value=system), mock.patch.object(go.platform, "machine", return_value=machine):
                key, filename, (checksum, size) = go.target()
                self.assertEqual(key, expected)
                self.assertTrue(filename.startswith(go.VERSION + "." + key))
                self.assertRegex(checksum, r"^[a-f0-9]{64}$")
                self.assertGreater(size, 50 * 1024**2)
                self.assertLess(size, 100 * 1024**2)
        with mock.patch.object(go.platform, "system", return_value="Linux"), mock.patch.object(go.platform, "machine", return_value="armv7l"):
            with self.assertRaisesRegex(ValueError, "unterstuetzt"):
                go.target()

    def test_download_checks_size_hash_and_only_official_url(self):
        data, filename = b"archive fixture", "go-fixture.tar.gz"
        opener = mock.Mock()
        opener.open.return_value = self.response(data, filename)
        with mock.patch.object(go, "build_opener", return_value=opener):
            go.download(filename, self.base / "file", hashlib.sha256(data).hexdigest(), len(data))
        request = opener.open.call_args.args[0]
        self.assertEqual(request.full_url, "https://dl.google.com/go/" + filename)
        self.assertNotIn("Authorization", request.headers)
        self.assertEqual((self.base / "file").read_bytes(), data)

    def test_wrong_hash_short_and_oversize_downloads_fail(self):
        for number, (checksum, expected) in enumerate((("0" * 64, 3), (hashlib.sha256(b"abc").hexdigest(), 4),
                                                       (hashlib.sha256(b"abc").hexdigest(), 2))):
            opener = mock.Mock()
            opener.open.return_value = self.response(b"abc", "fixture")
            with mock.patch.object(go, "build_opener", return_value=opener), self.assertRaises(ValueError):
                go.download("fixture", self.base / str(number), checksum, expected)

    def test_timeout_uses_second_official_url_once(self):
        data, filename = b"fixture", "fixture.tar.gz"
        opener = mock.Mock()
        opener.open.side_effect = [URLError(TimeoutError("private detail")), self.response(data, filename)]
        with mock.patch.object(go, "build_opener", return_value=opener):
            go.download(filename, self.base / "file", hashlib.sha256(data).hexdigest(), len(data))
        self.assertEqual(opener.open.call_count, 2)
        self.assertEqual(opener.open.call_args.args[0].full_url, "https://go.dev/dl/" + filename)
        self.assertLessEqual(opener.open.call_args.kwargs["timeout"], 30)

    def test_dns_failure_is_explicit_and_bounded(self):
        opener = mock.Mock()
        opener.open.side_effect = URLError(socket.gaierror(-2, "private detail"))
        with mock.patch.object(go, "build_opener", return_value=opener), self.assertRaisesRegex(ValueError, "DNS-Aufloesung") as error:
            go.download("fixture", self.base / "file", "0" * 64, 10)
        self.assertEqual(opener.open.call_count, 2)
        self.assertNotIn("private detail", str(error.exception))
        self.assertFalse((self.base / "file").exists())

    def test_tls_and_http_auth_failures_are_terminal(self):
        failures = [(URLError(ssl.SSLCertVerificationError(1, "secret")), "TLS-Zertifikatspruefung"),
                    (HTTPError("https://private.invalid", 403, "secret", {}, None), "HTTP 403"),
                    (HTTPError("https://private.invalid", 407, "secret", {}, None), "HTTP 407")]
        for error, category in failures:
            opener = mock.Mock()
            opener.open.side_effect = error
            with mock.patch.object(go, "build_opener", return_value=opener), self.assertRaisesRegex(ValueError, category) as caught:
                go.download("fixture", self.base / "file", "0" * 64, 10)
            self.assertEqual(opener.open.call_count, 1)
            self.assertNotIn("secret", str(caught.exception))

    def test_http_404_can_try_second_official_entry(self):
        data, filename = b"fixture", "fixture"
        opener = mock.Mock()
        opener.open.side_effect = [HTTPError("https://dl.google.com", 404, "", {}, None), self.response(data, filename)]
        with mock.patch.object(go, "build_opener", return_value=opener):
            go.download(filename, self.base / "file", hashlib.sha256(data).hexdigest(), len(data))
        self.assertEqual(opener.open.call_count, 2)

    def test_partial_read_failure_cleans_own_file_before_retry(self):
        data, filename = b"fixture", "fixture"
        first = mock.MagicMock()
        first.__enter__.return_value = first
        first.status = 200
        first.geturl.return_value = "https://dl.google.com/go/" + filename
        first.read.side_effect = [b"partial", ConnectionResetError("private")]
        opener = mock.Mock()
        opener.open.side_effect = [first, self.response(data, filename)]
        with mock.patch.object(go, "build_opener", return_value=opener):
            go.download(filename, self.base / "file", hashlib.sha256(data).hexdigest(), len(data))
        self.assertEqual((self.base / "file").read_bytes(), data)

    def test_existing_download_target_never_overwritten(self):
        path = self.base / "file"
        path.write_bytes(b"personal data")
        with mock.patch.object(go, "build_opener") as opener, self.assertRaisesRegex(ValueError, "ueberschreiben"):
            go.download("fixture", path, "0" * 64, 10)
        opener.assert_not_called()
        self.assertEqual(path.read_bytes(), b"personal data")

    def test_redirect_allows_only_exact_official_archive_urls(self):
        urls = ("https://dl.google.com/go/fixture", "https://go.dev/dl/fixture")
        handler = go.OfficialRedirect(urls)
        redirected = handler.redirect_request(Request(urls[1]), None, 302, "", {}, urls[0])
        self.assertEqual(redirected.full_url, urls[0])
        for url in ("https://untrusted.invalid/fixture", "http://dl.google.com/go/fixture",
                    "https://dl.google.com/go/other", "https://user:secret@dl.google.com/go/fixture"):
            with self.assertRaisesRegex(ValueError, "gesperrt"):
                handler.redirect_request(Request(urls[1]), None, 302, "", {}, url)

    def test_proxy_auto_direct_and_credential_rejection(self):
        with mock.patch.object(go, "getproxies", return_value={"https": "http://localhost:3128", "no": "localhost"}):
            self.assertEqual(go.network_environment(), {"HTTPS_PROXY": "http://localhost:3128", "NO_PROXY": "localhost"})
            with mock.patch.dict(os.environ, {"ANTHROPIC_CLI_GO_PROXY_MODE": "direct"}):
                self.assertEqual(go.network_environment(), {})
        for proxy in ("http://user:secret@localhost:3128", "socks5://localhost:1080", "https://localhost/?key=secret"):
            with mock.patch.object(go, "getproxies", return_value={"https": proxy}), self.assertRaises(ValueError) as caught:
                go.proxy_settings()
            self.assertNotIn("secret", str(caught.exception))
        with mock.patch.dict(os.environ, {"ANTHROPIC_CLI_GO_PROXY_MODE": "invalid"}), self.assertRaises(ValueError):
            go.proxy_settings()

    def test_local_archive_is_verified_without_network(self):
        data = b"fixture"
        source = self.base / "user-archive"
        source.write_bytes(data)
        with mock.patch.dict(os.environ, {"ANTHROPIC_CLI_GO_ARCHIVE": str(source)}), mock.patch.object(go, "build_opener") as opener:
            go.download("fixture", self.base / "copy", hashlib.sha256(data).hexdigest(), len(data))
            with self.assertRaisesRegex(ValueError, "Pruefsumme"):
                go.download("fixture", self.base / "bad", "0" * 64, len(data))
            opener.assert_not_called()
        self.assertEqual(source.read_bytes(), data)
        self.assertEqual((self.base / "copy").read_bytes(), data)
        self.assertFalse((self.base / "bad").exists())

    def test_relative_local_archive_is_refused(self):
        with mock.patch.dict(os.environ, {"ANTHROPIC_CLI_GO_ARCHIVE": "relative.tar.gz"}), self.assertRaisesRegex(ValueError, "absolute"):
            go.download("fixture", self.base / "copy", "0" * 64, 10)

    def test_network_error_is_sanitized(self):
        opener = mock.Mock()
        opener.open.side_effect = URLError("synthetic credential-bearing proxy detail")
        with mock.patch.object(go, "build_opener", return_value=opener), self.assertRaisesRegex(ValueError, "Download fehlgeschlagen") as error:
            go.download("fixture", self.base / "file", "0" * 64, 10)
        self.assertNotIn("credential-bearing", str(error.exception))

    def test_full_disk_during_download_is_explicit_not_reported_as_network_error(self):
        opener = mock.Mock()
        opener.open.return_value = self.response(b"abc", "fixture")
        with mock.patch.object(go, "build_opener", return_value=opener), \
                mock.patch.object(go.Path, "open", side_effect=OSError(errno.ENOSPC, "synthetic disk full")), \
                self.assertRaisesRegex(ValueError, "Speicherplatzmangel beim Go-Download"):
            go.download("fixture", self.base / "file", "0" * 64, 3)

    def test_safe_tar_and_zip_extraction_preserves_contents(self):
        tar = self.base / "fixture.tar.gz"
        tar.write_bytes(self.tar_bytes())
        folder = self.base / "tar"
        folder.mkdir()
        go.extract(tar, folder)
        self.assertEqual((folder / "go/VERSION").read_text().splitlines()[0], go.VERSION)
        zip_path = self.base / "fixture.zip"
        with zipfile.ZipFile(zip_path, "w") as bundle:
            bundle.writestr("go/VERSION", go.VERSION + "\n")
            bundle.writestr("go/bin/go.exe", b"not executable fixture")
        destination = self.base / "zip"
        destination.mkdir()
        go.extract(zip_path, destination)
        self.assertTrue((destination / "go/bin/go.exe").is_file())

    def test_archive_path_traversal_links_and_special_files_are_rejected(self):
        cases = (("../outside", tarfile.REGTYPE), ("/outside", tarfile.REGTYPE),
                 ("go/../../outside", tarfile.REGTYPE), ("go\\outside", tarfile.REGTYPE),
                 ("go/file:stream", tarfile.REGTYPE), ("not-go/file", tarfile.REGTYPE),
                 ("go/link", tarfile.SYMTYPE), ("go/hard", tarfile.LNKTYPE),
                 ("go/device", tarfile.CHRTYPE))
        for index, (name, kind) in enumerate(cases):
            archive = self.base / (str(index) + ".tar.gz")
            archive.write_bytes(self.tar_bytes([(name, b"fixture", kind)]))
            destination = self.base / str(index)
            destination.mkdir()
            with self.assertRaises(ValueError):
                go.extract(archive, destination)
        self.assertFalse((self.base / "outside").exists())

    def test_zip_symlink_is_refused(self):
        archive = self.base / "link.zip"
        with zipfile.ZipFile(archive, "w") as bundle:
            item = zipfile.ZipInfo("go/link")
            item.create_system = 3
            item.external_attr = (stat.S_IFLNK | 0o777) << 16
            bundle.writestr(item, "../../outside")
        with self.assertRaisesRegex(ValueError, "Spezialdateien"):
            go.extract(archive, self.base)

    def test_unpacked_limit_and_duplicate_files_are_refused(self):
        archive = self.base / "large.tar.gz"
        archive.write_bytes(self.tar_bytes())
        with mock.patch.object(go, "MAX_UNPACKED", 1), self.assertRaises(ValueError):
            go.extract(archive, self.base)
        duplicate = self.base / "duplicate.tar.gz"
        duplicate.write_bytes(self.tar_bytes([("go/a", b"a", tarfile.REGTYPE), ("go/a", b"b", tarfile.REGTYPE)]))
        with self.assertRaisesRegex(ValueError, "Dateiliste"):
            go.extract(duplicate, self.base)

    def test_bootstrap_publishes_only_verified_private_bundle(self):
        validate = mock.Mock()
        binary, root = self.bootstrap(validate=validate)
        self.assertEqual(Path(binary), root / "bin/go")
        self.assertEqual(root.parent.parent, self.base / "toolchain")
        self.assertTrue((root.parent / "toolchain-ready.json").is_file())
        validate.assert_called_once()
        self.assertEqual(list(self.base.glob("go-bootstrap-*")), [])
        marker = json.loads((root.parent / "toolchain-ready.json").read_text())
        self.assertIn("src/runtime/runtime.go", marker["hashes"])

    def test_reuse_verifies_all_files_without_network(self):
        _, root = self.bootstrap()
        filename = go.VERSION + ".linux-amd64.tar.gz"
        marker = json.loads((root.parent / "toolchain-ready.json").read_text())
        metadata = ("linux-amd64", filename, (marker["archive_sha256"], 1))
        with mock.patch.object(go, "target", return_value=metadata), mock.patch.object(go, "download") as download:
            self.assertEqual(go.ensure(self.base, mock.Mock())[1], root)
            download.assert_not_called()
            (root / "src/runtime/runtime.go").write_text("local edits")
            with self.assertRaisesRegex(ValueError, "veraendert"):
                go.ensure(self.base, mock.Mock())
            download.assert_not_called()

    def test_failed_validation_cleans_only_current_staging(self):
        keep = self.base / "my-data"
        keep.write_text("keep")
        with self.assertRaisesRegex(ValueError, "version fixture"):
            self.bootstrap(validate=mock.Mock(side_effect=ValueError("version fixture")))
        self.assertFalse((self.base / "toolchain").exists())
        self.assertEqual(list(self.base.glob("go-bootstrap-*")), [])
        self.assertEqual(keep.read_text(), "keep")

    def test_failed_download_or_marker_write_leaves_no_half_toolchain(self):
        with mock.patch.object(go, "download", side_effect=ValueError("checksum fixture")):
            with self.assertRaisesRegex(ValueError, "checksum"):
                self.bootstrap()
        self.assertEqual(list(self.base.glob("go-bootstrap-*")), [])
        self.assertFalse((self.base / "toolchain").exists())
        with mock.patch.object(go.json, "dump", side_effect=OSError(errno.ENOSPC, "full marker fixture")):
            with self.assertRaises(OSError):
                self.bootstrap()
        self.assertEqual(list(self.base.glob("go-bootstrap-*")), [])
        self.assertFalse((self.base / "toolchain").exists())

    def test_wrong_version_archive_is_not_activated(self):
        data = self.tar_bytes([("go/VERSION", b"go0.0.0\n", tarfile.REGTYPE),
                               ("go/bin/go", b"fixture", tarfile.REGTYPE)])
        with self.assertRaisesRegex(ValueError, "Version"):
            self.bootstrap(data)
        self.assertFalse((self.base / "toolchain").exists())

    def test_low_disk_prevents_download(self):
        with mock.patch.object(go.platform, "system", return_value="Linux"), \
                mock.patch.object(go.platform, "machine", return_value="x86_64"), \
                mock.patch.object(go.shutil, "disk_usage", return_value=mock.Mock(free=1)), \
                mock.patch.object(go, "download") as download, self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
            go.ensure(self.base, mock.Mock())
        download.assert_not_called()

    def test_unowned_private_directory_is_not_replaced(self):
        slot = self.base / "toolchain" / (go.VERSION + "-linux-amd64")
        slot.mkdir(parents=True)
        foreign = slot / "personal.txt"
        foreign.write_text("keep")
        with mock.patch.object(go.platform, "system", return_value="Linux"), \
                mock.patch.object(go.platform, "machine", return_value="x86_64"), \
                mock.patch.object(go, "download") as download, self.assertRaises(OSError):
            go.ensure(self.base, mock.Mock())
        self.assertEqual(foreign.read_text(), "keep")
        download.assert_not_called()


if __name__ == "__main__":
    unittest.main()
