import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

REPO = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("env_vault", REPO / "scripts/security/env_vault.py")
vault = importlib.util.module_from_spec(spec)
spec.loader.exec_module(vault)


class EnvVaultTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / "user-data"
        self.workspace = vault.Workspace(self.root)
        self.data = {"version": 1, "values": {"demo_token": "fixture-value-$literal"},
                     "bindings": {"demo": {"TOKEN": "demo_token"}}}

    def test_render_never_expands_or_executes(self):
        result, fields = vault.render_env("# Example\nTOKEN=\nHOST=127.0.0.1\n", self.data, "demo")
        self.assertEqual(fields, ["TOKEN"])
        self.assertIn("TOKEN='fixture-value-$literal'", result)
        self.assertIn("HOST=127.0.0.1", result)

    def test_invalid_templates_and_values(self):
        for template in ("TOKEN=\nTOKEN=\n", "echo invalid\n", "OTHER=\n"):
            with self.assertRaises(vault.VaultError):
                vault.render_env(template, self.data, "demo")
        for value in ("a'b", "a\\b", "a\nb", "a\x00b", ""):
            self.data["values"]["demo_token"] = value
            with self.assertRaises(vault.VaultError):
                vault.render_env("TOKEN=", self.data, "demo")
        with self.assertRaises(vault.VaultError):
            vault.render_env("TOKEN=", self.data, "unmapped")

    def test_workspace_and_identifier_boundaries(self):
        with self.assertRaises(vault.VaultError):
            vault.Workspace(REPO / "temporary-vault")
        for name in ("../outside", "a/b", "", "-bad"):
            with self.assertRaises(vault.VaultError):
                vault.identifier(name)
        try:
            link = Path(self.temp.name) / "link"
            link.symlink_to(REPO, target_is_directory=True)
        except (OSError, NotImplementedError):
            return  # Windows often lacks the privilege to create symlinks.
        with self.assertRaises(vault.VaultError):
            vault.Workspace(link)

    def test_exclusive_lock(self):
        with self.workspace.locked():
            with self.assertRaises(vault.VaultError):
                with self.workspace.locked():
                    self.fail("Concurrent writer allowed")
        self.assertFalse((self.workspace.directory / ".vault.lock").exists())

    def test_only_ciphertext_saved_and_failure_preserves_file(self):
        ciphertext = b"age-encryption.org/v1\nMOCK-CIPHERTEXT"
        with self.workspace.locked(), patch.object(vault, "age_run", return_value=ciphertext):
            self.workspace.save(self.data)
        self.assertEqual(self.workspace.vault.read_bytes(), ciphertext)
        self.assertNotIn(b"fixture-value", self.workspace.vault.read_bytes())
        with patch.object(vault, "age_run", side_effect=vault.VaultError("mock failure")):
            with self.assertRaises(vault.VaultError):
                self.workspace.save(self.data)
        self.assertEqual(self.workspace.vault.read_bytes(), ciphertext)
        self.assertFalse(list(self.workspace.directory.glob(".vault-write-*")))

    def test_decrypt_schema(self):
        self.workspace.private_dir(self.workspace.directory)
        self.workspace.vault.write_bytes(b"mock cipher")
        with patch.object(vault, "age_run", return_value=json.dumps(self.data).encode()):
            self.assertEqual(self.workspace.load(), self.data)
        with patch.object(vault, "age_run", return_value=b'{"version": 999}'):
            with self.assertRaises(vault.VaultError):
                self.workspace.load()

    def test_preview_apply_and_explicit_replace(self):
        template = Path(self.temp.name) / "demo.env.example"
        template.write_text("TOKEN=\nHOST=127.0.0.1\n", encoding="utf-8")
        target = self.root / "env/demo/.env"
        output = io.StringIO()
        base = ["render", "demo", "--template", str(template)]
        with patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(self.root)}), \
             patch.object(vault, "catalog", return_value={"demo": "Demo"}), \
             patch.object(vault.Workspace, "load", return_value=self.data), \
             contextlib.redirect_stdout(output):
            vault.execute(vault.parser().parse_args(base))
            self.assertFalse(target.exists())
            vault.execute(vault.parser().parse_args(base + ["--apply"]))
            self.assertIn("fixture-value-$literal", target.read_text())
            if os.name == "posix":
                self.assertEqual(target.stat().st_mode & 0o777, 0o600)
            with self.assertRaises(vault.VaultError):
                vault.execute(vault.parser().parse_args(base + ["--apply"]))
            vault.execute(vault.parser().parse_args(base + ["--apply", "--replace"]))
        self.assertNotIn("fixture-value", output.getvalue())
        self.assertFalse(list(target.parent.glob(".vault-write-*")))

    def test_template_filename_guard_and_catalog(self):
        template = Path(self.temp.name) / ".env"
        template.write_text("TOKEN=", encoding="utf-8")
        with self.assertRaises(vault.VaultError):
            vault.template_for("demo", str(template))
        self.assertIn("openclaw", vault.catalog())

    def test_noninteractive_secrets_refused(self):
        with patch.object(vault.sys.stdin, "isatty", return_value=False):
            with self.assertRaises(vault.VaultError):
                vault.read_secret()
            with self.assertRaises(vault.VaultError):
                vault.age_run(["--passphrase"], b"fixture")


if __name__ == "__main__":
    unittest.main()
