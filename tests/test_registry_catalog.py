"""Registry drift and readiness evidence, synthetic repository files only."""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


def load(name, file):
    spec = importlib.util.spec_from_file_location(name, ROOT / file)
    item = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(item)
    return item


catalog = load('catalog_fixture', 'scripts/quality/registry_catalog.py')
audit = load('catalog_audit', 'scripts/quality/repository_audit.py')
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


class RegistryCatalog(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        (self.root / 'config').mkdir()
        (self.root / 'docs').mkdir()
        (self.root / 'fixture.sh').write_text('# fixture\n')
        (self.root / 'docs/tool.md').write_text('fixture\n')
        row = dict(id='demo', install_script='fixture.sh', uninstall_script='fixture.sh',
                   check_type='path', check_value='fixture.sh', status='planned', doc='docs/tool.md')
        for kind, rows in [('tools', [row]), ('profiles', []), ('ports', [{'port': 1234, 'service': 'demo'}])]:
            (self.root / f'config/{kind}.yml').write_text(json.dumps({kind: rows}))

    def test_default_checks_only_and_write_is_idempotent(self):
        self.assertEqual(len(catalog.artifacts(self.root)), 3)
        self.assertFalse((self.root / 'docs/generated').exists())
        self.assertEqual(len(catalog.artifacts(self.root, True)), 3)
        self.assertEqual(catalog.artifacts(self.root), [])
        self.assertEqual(catalog.artifacts(self.root, True), [])
        path = self.root / 'docs/generated/TOOL_MATRIX.md'
        self.assertIn('| unknown |', path.read_text())
        path.write_text('drift')
        self.assertEqual(catalog.artifacts(self.root), ['TOOL_MATRIX.md'])

    def test_legacy_maturity_is_not_runtime_readiness(self):
        self.assertTrue(audit.readiness_valid(self.root, {'status': 'stable'}))
        for state in ('runtime-verified', 'source-ready'):
            self.assertFalse(audit.readiness_valid(self.root, {'readiness': state, 'source_commit': 'a' * 40}))
        self.assertFalse(audit.readiness_valid(self.root, {'readiness': 'stable'}))

    def test_evidence_binds_identity_pin_platform_scope_and_log(self):
        folder = self.root / 'docs/evidence'
        folder.mkdir()
        log = folder / 'fixture.log'
        log.write_bytes(b'synthetic successful runtime test\n')
        receipt = dict(id='demo', source_commit='a' * 40, platform='fixture-linux-amd64',
                       scope='runtime', result='passed', tested_at='2026-11-01T00:00:00Z',
                       log='docs/evidence/fixture.log', log_sha256=hashlib.sha256(log.read_bytes()).hexdigest())
        path = folder / 'fixture.json'
        path.write_text(json.dumps(receipt))
        row = dict(id='demo', source_commit='a' * 40, readiness='runtime-verified',
                   readiness_evidence='docs/evidence/fixture.json')
        self.assertTrue(audit.readiness_valid(self.root, row))
        for key, value in [('id', 'other'), ('source_commit', 'b' * 40), ('scope', 'fixture'),
                           ('platform', ''), ('result', 'failed'), ('tested_at', 'yesterday'),
                           ('log', '../outside'), ('log_sha256', '0' * 64)]:
            path.write_text(json.dumps(dict(receipt, **{key: value})))
            self.assertFalse(audit.readiness_valid(self.root, row), key)
        path.write_text(json.dumps(receipt))
        log.write_text('tampered')
        self.assertFalse(audit.readiness_valid(self.root, row))

    def test_bad_registry_blocks_generation(self):
        (self.root / 'config/tools.yml').write_text('{broken')
        with self.assertRaises(ValueError):
            catalog.artifacts(self.root, True)
        self.assertFalse((self.root / 'docs/generated').exists())

    @unittest.skipUnless(BASH, 'Bash required')
    def test_registry_wrapper_propagates_child_failure(self):
        for wrapper, required, child in (
                ('tool_registry_check.sh', ['config/tools.yml', 'docs/TOOL_INDEX.md', 'docs/TOOL_DEPLOYMENT_MATRIX.md'], 'check_tools.sh'),
                ('profile_matrix_check.sh', ['docs/PROFILE_INDEX.md', 'docs/PROFILE_TOOL_MAPPING.md', 'docs/Profile/Next_Level_Profile_Backlog.md'], 'check_profile_registry_sync.sh')):
            with self.subTest(wrapper=wrapper), tempfile.TemporaryDirectory() as directory:
                root = Path(directory)
                (root / 'scripts').mkdir()
                shutil.copyfile(ROOT / 'scripts' / wrapper, root / 'scripts' / wrapper)
                for relative in required:
                    target = root / relative
                    target.parent.mkdir(parents=True, exist_ok=True)
                    target.write_text('synthetic fixture\n')
                (root / 'scripts' / child).write_text('#!/usr/bin/env bash\nexit 17\n')
                result = subprocess.run([BASH, str(root / 'scripts' / wrapper)],
                    env=dict(os.environ, BASH_ENV=''), text=True, capture_output=True, timeout=20)
                self.assertEqual(result.returncode, 17, result.stderr)

    @unittest.skipUnless(BASH, 'Bash required')
    def test_setup_dry_run_precedes_any_workspace_helpers(self):
        text = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        self.assertLess(text.index('"${1:-}" == --dry-run'), text.index('load_setup_language'))
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'scripts/quality').mkdir(parents=True)
            # Execute the real early entry with an isolated Python spy.
            (root / 'scripts/quality/repository_audit.py').write_text('# fixture\n')
            shutil.copyfile(ROOT / 'setup_ultimate.sh', root / 'setup_ultimate.sh')
            (root / 'bin').mkdir()
            shim = root / 'bin/python3'
            shim.write_text('#!/usr/bin/env bash\nprintf "SPY:%s\\n" "$@"\nexit 0\n')
            shim.chmod(0o700)
            env = dict(os.environ, FIXTURE=root.as_posix(), BASH_ENV='', HOME=str(root / 'never-created'))
            result = subprocess.run([BASH, '-c', 'cd "$FIXTURE"; export PATH="$PWD/bin:$PATH"; bash setup_ultimate.sh --dry-run'],
                                    env=env, input='', text=True, capture_output=True, timeout=20)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('SPY:--section\nSPY:registry', result.stdout)
            self.assertFalse((root / 'never-created').exists())


if __name__ == '__main__':
    unittest.main()
