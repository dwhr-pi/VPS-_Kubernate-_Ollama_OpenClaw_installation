"""Source-gate fixtures: no downloads, services, production paths or credentials."""
import contextlib
import hashlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')
SPEC = importlib.util.spec_from_file_location('core_source_fixture', ROOT / 'scripts/security/core_source_gate.py')
gate = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(gate)


class SourceGate(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.payload = self.root / 'source.tar.gz'
        self.payload.write_bytes(b'Synthetic source bytes, deliberately not executed or unpacked.\n')
        self.lock = self.root / 'reviewed.json'
        self.contract = dict(schema=1, tool='ollama', source_commit='a' * 40,
            url='https://github.com/ollama/ollama/archive/' + 'a' * 40 + '.tar.gz',
            sha256=hashlib.sha256(self.payload.read_bytes()).hexdigest(), size=self.payload.stat().st_size)
        self.lock.write_text(json.dumps(self.contract))

    def test_plan_never_opens_inputs_or_reports_installation(self):
        output = io.StringIO()
        with patch.object(gate, 'regular_input', side_effect=AssertionError('No source reads')), contextlib.redirect_stdout(output):
            self.assertEqual(gate.main(['ollama']), 3)
        result = json.loads(output.getvalue().splitlines()[0])
        self.assertFalse(result['installed'])
        self.assertFalse(result['network_calls'])
        self.assertFalse(result['writes'])

    def test_valid_hash_proves_only_bytes_not_installation_or_authenticity(self):
        result = gate.verify('ollama', self.lock, self.payload)
        self.assertTrue(result['verified'])
        for key in ('installed', 'service_started', 'authenticity_verified', 'archive_contents_verified'):
            self.assertFalse(result[key])
        self.assertEqual(sorted(path.name for path in self.root.iterdir()), ['reviewed.json', 'source.tar.gz'])

    def test_successful_cli_verification_still_cannot_mark_tool_installed(self):
        with contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(gate.main(['ollama', '--verify-source', '--manifest', str(self.lock),
                                       '--artifact', str(self.payload)]), 3)

    def test_offline_missing_payload_and_bad_hash_fail_closed(self):
        self.payload.write_bytes(b'x' * self.contract['size'])
        with self.assertRaises(ValueError):
            gate.verify('ollama', self.lock, self.payload)
        self.payload.unlink()
        with contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(gate.main(['ollama', '--verify-source', '--manifest', str(self.lock),
                                       '--artifact', str(self.payload)]), 1)

    def test_wrong_tool_branch_foreign_source_and_malformed_contracts_rejected(self):
        for key, value in [('tool', 'k3s'), ('source_commit', 'main'), ('source_commit', '0' * 40),
                ('url', 'https://github.com/ollama/ollama/archive/main.tar.gz'),
                ('url', 'https://evil.example/source.tar.gz'), ('sha256', '0' * 64),
                ('size', True), ('size', 0), ('size', gate.MAX_ARTIFACT + 1), ('schema', True)]:
            with self.subTest(key=key, value=value):
                self.lock.write_text(json.dumps(dict(self.contract, **{key: value})))
                with self.assertRaises(ValueError):
                    gate.verify('ollama', self.lock, self.payload)

    def test_k3s_requires_its_own_official_repository(self):
        contract = dict(self.contract, tool='k3s')
        self.lock.write_text(json.dumps(contract))
        with self.assertRaises(ValueError):
            gate.verify('k3s', self.lock, self.payload)
        contract['url'] = 'https://github.com/k3s-io/k3s/archive/' + 'a' * 40 + '.tar.gz'
        self.lock.write_text(json.dumps(contract))
        self.assertTrue(gate.verify('k3s', self.lock, self.payload)['verified'])

    def test_openclaw_requires_its_own_pinned_contract_and_never_installs(self):
        contract = dict(self.contract, tool='openclaw')
        self.lock.write_text(json.dumps(contract))
        with self.assertRaises(ValueError):
            gate.verify('openclaw', self.lock, self.payload)
        contract['url'] = 'https://github.com/openclaw/openclaw/archive/' + 'a' * 40 + '.tar.gz'
        self.lock.write_text(json.dumps(contract))
        result = gate.verify('openclaw', self.lock, self.payload)
        self.assertTrue(result['verified'])
        self.assertFalse(result['installed'])
        with contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(gate.main(['openclaw', '--verify-source', '--manifest', str(self.lock),
                                       '--artifact', str(self.payload)]), 3)

    def test_duplicate_extra_fields_and_input_size_rejected(self):
        for text in ('{"schema":1,"schema":1}', json.dumps(dict(self.contract, command='never execute')),
                     '[]', 'x' * 65537):
            self.lock.write_text(text)
            with self.assertRaises(ValueError):
                gate.verify('ollama', self.lock, self.payload)

    def test_relative_paths_and_hardlinks_are_not_inputs(self):
        with self.assertRaises(ValueError):
            gate.verify('ollama', Path('reviewed.json'), self.payload)
        link = self.root / 'hardlink'
        try:
            os.link(self.payload, link)
        except OSError:
            self.skipTest('Hardlink support unavailable')
        with self.assertRaises(ValueError):
            gate.verify('ollama', self.lock, self.payload)

    def test_explicit_apply_and_force_have_no_implementation(self):
        for option in ('--apply', '--force', '--legacy-unsigned'):
            with contextlib.redirect_stderr(io.StringIO()), self.assertRaises(SystemExit) as failure:
                gate.main(['ollama', option])
            self.assertEqual(failure.exception.code, 2)

    def test_input_changed_during_read_is_not_verified(self):
        with self.assertRaises(ValueError):
            with gate.regular_input(self.payload, gate.MAX_ARTIFACT):
                self.payload.write_bytes(b'changed synthetic source')

    def test_symlink_input_or_parent_is_rejected(self):
        link = self.root / 'source-link'
        try:
            link.symlink_to(self.payload)
        except OSError:
            self.skipTest('Native symlink privileges unavailable')
        with self.assertRaises(ValueError):
            gate.verify('ollama', self.lock, link)
        folder = self.root / 'linked-folder'
        folder.symlink_to(self.root, target_is_directory=True)
        with self.assertRaises(ValueError):
            gate.verify('ollama', self.lock, folder / self.payload.name)

    def test_failures_never_echo_payload_or_manifest_contents(self):
        secret = 'synthetic-sensitive-canary'
        self.lock.write_text(secret)
        output = io.StringIO()
        with contextlib.redirect_stderr(output):
            self.assertEqual(gate.main(['ollama', '--verify-source', '--manifest', str(self.lock),
                                       '--artifact', str(self.payload)]), 1)
        self.assertNotIn(secret, output.getvalue())

    def test_ci_includes_this_fixture_and_both_wrappers(self):
        workflow = (ROOT / '.github/workflows/p0-safety.yml').read_text(encoding='utf-8')
        self.assertIn('test_core_source_gate.py', workflow)
        for tool in ('ollama', 'k3s', 'openclaw'):
            self.assertIn(f'scripts/tools/{tool}_install.sh', workflow)

    def test_no_core_vendor_pipe_remains_in_four_legacy_entries(self):
        for relative in ('scripts/base_install.sh', 'scripts/vps_standalone.sh',
                         'scripts/tools/ollama_install.sh', 'scripts/tools/k3s_install.sh'):
            text = (ROOT / relative).read_text(encoding='utf-8')
            self.assertNotIn('https://ollama.com/install.sh', text)
            self.assertNotIn('https://get.k3s.io', text)

    def test_openclaw_wrapper_has_no_legacy_mutation_or_tracking(self):
        text = (ROOT / 'scripts/tools/openclaw_install.sh').read_text(encoding='utf-8')
        for forbidden in ('git clone', 'git pull', 'pnpm install', 'pnpm build', 'sudo ',
                          '/opt/openclaw', 'status_tracking.sh', 'mark_current_tool_installed',
                          'get_custom_repo_url'):
            self.assertNotIn(forbidden, text)


@unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash required, never WSL')
class SourceGateWrappers(unittest.TestCase):
    def test_real_wrappers_forward_to_fixed_helper_without_workspace_or_status(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / 'scripts/security').mkdir(parents=True)
            (root / 'scripts/tools').mkdir()
            (root / 'bin').mkdir()
            helper = root / 'scripts/security/core_source_gate.py'
            helper.write_text('# fixture, not executed\n')
            spy = root / 'bin/python3'
            spy.write_text('#!/usr/bin/env bash\nprintf "ARG:%s\\n" "$@"\nexit 3\n', newline='\n')
            spy.chmod(0o700)
            for tool in ('ollama', 'k3s', 'openclaw'):
                shutil.copyfile(ROOT / f'scripts/tools/{tool}_install.sh', root / f'scripts/tools/{tool}_install.sh')
                env = dict(os.environ, BASH_ENV='', FIXTURE=root.as_posix(), HOME=str(root / 'untouched'),
                           INSTALL_DIR='/must-not-be-used', OPENCLAW_USER_DATA_DIR='/must-not-be-used')
                command = f'cd "$FIXTURE"; export PATH="$PWD/bin:$PATH"; bash scripts/tools/{tool}_install.sh --plan'
                result = subprocess.run([BASH, '-c', command], env=env, input='', text=True, capture_output=True, timeout=20)
                self.assertEqual(result.returncode, 3, result.stderr)
                self.assertIn(f'ARG:{tool}\nARG:--plan', result.stdout)
                self.assertIn('ARG:-I\nARG:-B', result.stdout)
                self.assertNotIn('/must-not-be-used', result.stdout)
                self.assertFalse((root / 'untouched').exists())
            for name, tool in [('base_install.sh', 'ollama'), ('vps_standalone.sh', 'k3s')]:
                shutil.copyfile(ROOT / 'scripts' / name, root / 'scripts' / name)
                command = f'cd "$FIXTURE"; export PATH="$PWD/bin:$PATH"; bash scripts/{name} --plan'
                result = subprocess.run([BASH, '-c', command], env=env, input='', text=True, capture_output=True, timeout=20)
                self.assertEqual(result.returncode, 3, result.stderr)
                self.assertIn(f'ARG:{tool}\nARG:--plan', result.stdout)
                self.assertFalse((root / 'untouched').exists())
            helper.unlink()
            result = subprocess.run([BASH, '-c', command], env=env, input='', text=True, capture_output=True, timeout=20)
            self.assertEqual(result.returncode, 1)
            self.assertNotIn('ARG:', result.stdout)

    def test_actual_menu_stops_before_cleanup_locks_measurement_and_status(self):
        text = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        function = text[text.index('install_tool() {'):text.index('uninstall_tool() {')]
        stubs = r'''
set -euo pipefail
INSTALL_DIR='/fixture-repo'
bash() { printf 'GUARD:%s:%s\n' "$1" "$2"; return "$FIXTURE_RC"; }
show_tool_action_intro() { printf 'UNEXPECTED-INTRO\n'; exit 90; }
maybe_cleanup_logs_before_operation() { printf 'UNEXPECTED-CLEANUP\n'; exit 90; }
begin_operation_measurement() { printf 'UNEXPECTED-MEASUREMENT\n'; exit 90; }
run_tool_script() { printf 'UNEXPECTED-INSTALL\n'; exit 90; }
'''
        for tool in ('Ollama', 'K3s', 'OpenClaw'):
            for code in (0, 1, 2, 3):
                # Large real functions exceed reliable Windows bash -c quoting boundaries.
                with tempfile.TemporaryDirectory() as directory:
                    fixture = Path(directory) / 'menu-fixture.sh'
                    fixture.write_text(stubs + function + f'\nFIXTURE_RC={code}\ninstall_tool {tool}\n', encoding='utf-8', newline='\n')
                    result = subprocess.run([BASH, str(fixture)], env=dict(os.environ, BASH_ENV=''),
                                            text=True, capture_output=True, timeout=20)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn(f'GUARD:/fixture-repo/scripts/tools/{tool.lower()}_install.sh:--plan', result.stdout)
                self.assertNotIn('UNEXPECTED-', result.stdout)
                self.assertIn('keine Installation' if code == 3 else 'nicht freigegeben', result.stdout)


if __name__ == '__main__':
    unittest.main()
