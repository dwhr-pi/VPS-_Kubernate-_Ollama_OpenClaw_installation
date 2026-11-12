"""Public-format synthetic bytes only; no actual signing keys or credentials."""
import base64
import hashlib
import importlib.util
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("public_import", ROOT / "scripts/security/import_release_public_key.py")
keys = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(keys)


class PublicKeyImportTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.source = self.root / "fixture.pub"
        self.data = b"untrusted comment: synthetic fixture, not a real key\n" + base64.b64encode(b"Ed" + b"\x01" * 40) + b"\n"
        self.source.write_bytes(self.data)
        self.digest = hashlib.sha256(self.data).hexdigest()
        self.destination = self.root / "trust/release.pub"

    def test_import_and_repeat_preserve_both_files(self):
        keys.import_key(self.source, self.destination, self.digest)
        stamp = self.destination.stat().st_mtime_ns
        keys.import_key(self.source, self.destination, self.digest)
        self.assertEqual(self.data, self.source.read_bytes())
        self.assertEqual(self.data, self.destination.read_bytes())
        self.assertEqual(stamp, self.destination.stat().st_mtime_ns)

    def test_existing_different_file_never_overwritten(self):
        self.destination.parent.mkdir()
        self.destination.write_bytes(b"existing")
        with self.assertRaises(ValueError):
            keys.import_key(self.source, self.destination, self.digest)
        self.assertEqual(self.destination.read_bytes(), b"existing")

    def test_wrong_hash_or_private_extension_never_creates_destination(self):
        with self.assertRaises(ValueError):
            keys.import_key(self.source, self.destination, "0" * 64)
        with self.assertRaises(ValueError):
            keys.import_key(self.root / "release.key", self.destination, self.digest)
        self.assertFalse(self.destination.exists())

    def test_default_does_not_read_missing_source(self):
        self.assertEqual(keys.main(["--source", str(self.root / "missing.pub")]), 0)
        self.assertFalse(self.destination.exists())

    def test_symlink_refused_where_supported(self):
        linked = self.root / "linked.pub"
        try:
            linked.symlink_to(self.source)
        except OSError:
            self.skipTest("Symlink privilege unavailable")
        with self.assertRaises(ValueError):
            keys.import_key(linked, self.destination, self.digest)


if __name__ == "__main__":
    unittest.main()
