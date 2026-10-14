"""Synthetic fixtures, mocked inference/Docker; never access real HR documents."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import MagicMock, patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("personnel_pipeline", ROOT / "tools/personnel_documents/pipeline.py")
pipeline = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(pipeline)
BASH = Path('C:/Program Files/Git/bin/bash.exe') if os.name == 'nt' else shutil.which('bash')


class PersonnelTests(unittest.TestCase):
    def setUp(self):
        self.data = json.loads((ROOT / 'examples/personnel_documents/proposal.json').read_text())

    def test_metadata_always_needs_review(self):
        result = pipeline.validate(self.data)
        self.assertTrue(result['human_review_required'])
        self.assertFalse(result['applied'])

    def test_sensitive_and_unknown_fields_rejected(self):
        for field in ('name', 'salary', 'diagnosis', 'tags', 'owner', 'set_permissions', 'command'):
            with self.subTest(field=field), self.assertRaises(ValueError):
                pipeline.validate({**self.data, field: 'synthetic-test'})

    def test_dates_and_types_rejected(self):
        for changed in ({'document_date': '2026-02-30'}, {'document_date': True},
                        {'contract_end_date': '2030-1-2'}, {'document_type': 'unknown'}):
            with self.subTest(changed=changed), self.assertRaises(ValueError):
                pipeline.validate({**self.data, **changed})

    def test_absence_flag(self):
        result = pipeline.validate({**self.data, 'document_type': 'absence_document'})
        self.assertTrue(result['special_access_review'])

    def test_opt_in_checked_before_file_or_network(self):
        with patch.object(pipeline, 'read_input') as read, patch.object(pipeline, 'infer') as infer:
            with contextlib.redirect_stderr(io.StringIO()):
                code = pipeline.main(['infer', '--input', 'not-read', '--model', 'test'])
        self.assertEqual(code, 1)
        read.assert_not_called()
        infer.assert_not_called()

    def test_cloud_model_refused_before_network(self):
        with patch.object(pipeline.urllib.request, 'build_opener') as opener:
            with self.assertRaises(ValueError):
                pipeline.infer('synthetic', 'test:cloud')
        opener.assert_not_called()

    def test_local_request_mock(self):
        response = MagicMock()
        response.__enter__.return_value.read.return_value = json.dumps(
            {'done': True, 'response': json.dumps(self.data)}).encode()
        opener = MagicMock()
        opener.open.return_value = response
        with patch.object(pipeline.urllib.request, 'build_opener', return_value=opener):
            result = pipeline.infer('synthetic', 'local-test')
        request = opener.open.call_args.args[0]
        self.assertEqual(request.full_url, 'http://127.0.0.1:11434/api/generate')
        self.assertFalse(json.loads(request.data)['stream'])
        self.assertEqual(opener.open.call_args.kwargs['timeout'], 60)
        self.assertFalse(result['applied'])

    def test_bad_model_response_not_disclosed(self):
        response = MagicMock()
        response.__enter__.return_value.read.return_value = json.dumps(
            {'done': True, 'response': '{"name":"synthetic-not-for-logs"}'}).encode()
        opener = MagicMock()
        opener.open.return_value = response
        path = ROOT / 'examples/personnel_documents/synthetic-document.txt'
        out, err = io.StringIO(), io.StringIO()
        with patch.object(pipeline.urllib.request, 'build_opener', return_value=opener), \
                contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            code = pipeline.main(['infer', '--input', str(path), '--model', 'local-test', '--allow-local-inference'])
        self.assertEqual(code, 1)
        self.assertNotIn('synthetic-not-for-logs', out.getvalue() + err.getvalue())

    def test_redirect_blocked(self):
        with self.assertRaises(ValueError):
            pipeline.NoRedirect().redirect_request(None, None, 302, '', {}, 'https://example.tld')

    def test_large_input_refused(self):
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp) / 'synthetic.txt'
            path.write_bytes(b'x' * (pipeline.MAX_INPUT + 1))
            with self.assertRaises(ValueError):
                pipeline.read_input(path)

    def test_local_documentation_links(self):
        for relative in ('docs/tools/personnel-documents.md', 'docs/Profile/Personalakten_Local_First.md',
                         'tools/personnel_documents/README.md'):
            doc = ROOT / relative
            for link in re.findall(r'\]\(([^)]+)\)', doc.read_text(encoding='utf-8')):
                if '://' not in link and not link.startswith('#'):
                    self.assertTrue((doc.parent / link).exists(), link)

    def test_registry_and_compose(self):
        entries = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        for name in ('paperless_ngx', 'personnel_documents'):
            entry, = [item for item in entries if item['id'] == name]
            for field in ('install_script', 'uninstall_script', 'doc'):
                self.assertTrue((ROOT / entry[field]).is_file())
        compose = (ROOT / 'stacks/paperless_ngx/compose.yml').read_text()
        self.assertIn('127.0.0.1:8010:8000', compose)
        self.assertIn('./database:/var/lib/postgresql/data', compose)
        self.assertNotIn('PASSWORD: paperless', compose)
        self.assertNotIn('privileged:', compose)
        helper = (ROOT / 'scripts/tools/helpers/paperless_safe_common.sh').read_text()
        self.assertNotIn('down -v', helper)
        self.assertNotIn('rm -rf', helper)

    def test_unencrypted_backup_excludes_hr_paths(self):
        backup = (ROOT / 'scripts/operations/backup_run.sh').read_text(encoding='utf-8')
        self.assertIn('--exclude "/tools/paperless_ngx/"', backup)
        self.assertIn('--exclude "/personnel_documents/"', backup)
        self.assertIn('NICHT gesichert', backup)


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Git Bash/bash unavailable')
class PaperlessGuardTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / 'runtime'
        value = str(self.root).replace('\\', '/')
        self.shell_root = '/' + value[0].lower() + value[2:] if os.name == 'nt' else value

    def run_shell(self, code):
        preamble = ('source scripts/tools/helpers/paperless_safe_common.sh\n'
                    f'export OPENCLAW_USER_DATA_DIR="{self.shell_root}"\n')
        return subprocess.run([str(BASH), '--noprofile', '--norc', '-c', preamble + code],
                              cwd=ROOT, text=True, capture_output=True, timeout=30)

    def mocks(self):
        return '''
docker() { :; }
python3() { :; }
curl() { :; }
paperless_validate_env() { :; }
require_ram_mb() { :; }
require_disk_mb() { :; }
run_docker_compose_tool() { :; }
init_tool_tracking() { :; }
mark_current_tool_installed() { echo INSTALLED; }
mark_current_tool_removed() { echo REMOVED; }
paperless_compose() { echo "COMPOSE $*"; }
sleep() { :; }
export PAPERLESS_ENABLE_DOCKER=1
'''

    def test_plan_and_opt_in_no_side_effects(self):
        result = self.run_shell('paperless_main --dry-run')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.root.exists())
        result = self.run_shell('unset PAPERLESS_ENABLE_DOCKER; paperless_main install')
        self.assertEqual(result.returncode, 2, result.stderr)
        self.assertFalse(self.root.exists())

    def test_repeated_mock_install_and_preserving_uninstall(self):
        result = self.run_shell(self.mocks() + 'paperless_main install\npaperless_main install\npaperless_main uninstall')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.count('INSTALLED'), 2)
        self.assertIn('COMPOSE down\n', result.stdout)
        self.assertTrue((self.root / 'tools/paperless_ngx/compose.yml').exists())

    def test_failed_pull_does_not_start(self):
        result = self.run_shell(self.mocks() + '''
paperless_compose() { echo "COMPOSE $*"; [[ "$*" != '--parallel 1 pull' ]]; }
paperless_main install
''')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('COMPOSE up', result.stdout)
        self.assertNotIn('INSTALLED', result.stdout)

    def test_failed_ping_never_marks_success(self):
        result = self.run_shell(self.mocks() + 'curl() { return 1; }; paperless_main install')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('INSTALLED', result.stdout)


if __name__ == '__main__':
    unittest.main()
