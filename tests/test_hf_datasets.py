"""Offline source-installer tests; no pip, HF, data, training, or WSL calls."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')
HELPER = 'scripts/tools/helpers/hf_datasets_common.sh'


class Contract(unittest.TestCase):
    def test_source_registry_and_safety(self):
        tool, = [t for t in json.loads((ROOT / 'config/tools.yml').read_text())['tools']
                 if t['id'] == 'hf_datasets']
        self.assertEqual(tool['status'], 'experimental')
        self.assertFalse(tool['auto_install'])
        self.assertEqual(tool['install_mode'], 'source')
        self.assertEqual(tool['ports'], [])
        for field in ('doc', 'install_script', 'update_script', 'uninstall_script', 'doctor_script'):
            self.assertTrue((ROOT / tool[field]).is_file())
        text = (ROOT / HELPER).read_text()
        self.assertIn('HFD_COMMIT=' + tool['source_commit'], text)
        for token in ('--only-binary=pyarrow,numpy,pandas "$HFD_SOURCE"',
                      'require_ram_mb 2048', '-ge 1024', 'require_disk_mb 4096',
                      'REQUIRE_WINDOWS_HOST_FREE_MB=4096', 'HF_DATASETS_AUTO_VENV',
                      'af_prepare_venv', 'flock -n 9', 'pip --isolated check'):
            self.assertIn(token, text)
        for forbidden in ('load_dataset(', 'snapshot_download(', 'import datasets',
                          'pip install datasets', 'rm -rf', '[audio]', '[dev]', 'docker compose'):
            self.assertNotIn(forbidden, text)
        main = text.split('hf_datasets_main() (', 1)[1]
        self.assertLess(main.index('hfd_resources'), main.index('hfd_prepare_python\n'))
        self.assertLess(main.index('hfd_prepare_python\n'), main.index('hfd_fetch\n'))

    def test_documentation_links(self):
        doc = ROOT / 'docs/tools/hf-datasets.md'
        for link in re.findall(r'\]\(([^)]+)\)', doc.read_text()):
            if '://' not in link and not link.startswith('#'):
                self.assertTrue((doc.parent / link.split('#')[0]).exists(), link)


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Bash unavailable')
class OfflineBehavior(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as temp:
            home = temp.replace('\\', '/')
            if os.name == 'nt':
                home = '/' + home[0].lower() + home[2:]
            prefix = f'export HOME="{home}"\nunset OPENCLAW_USER_DATA_DIR\nsource {HELPER}\n'
            return subprocess.run([BASH, '--noprofile', '--norc', '-c', prefix + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=40)

    def test_dry_run_no_tools_or_files(self):
        result = self.shell('''
git() { exit 99; }; python3() { exit 99; }; sudo() { exit 99; }
hf_datasets_main --dry-run
test ! -e "$HOME/.openclaw_ultimate_user_data"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Dry-Run ohne Download', result.stdout)

    def test_status_missing_without_creation(self):
        result = self.shell('hf_datasets_main status; test ! -e "$HOME/.openclaw_ultimate_user_data"')
        self.assertEqual(result.returncode, 0, result.stderr)
        state = json.loads(result.stdout)
        self.assertFalse(state['installed'])
        self.assertFalse(state['training_enabled'])

    def test_doctor_missing_and_invalid_actions(self):
        for mode, rc in (('doctor', 1), ('download', 2), ('train', 2), ('login', 2)):
            result = self.shell('hf_datasets_main ' + mode)
            self.assertEqual(result.returncode, rc, result.stderr)

    def test_invalid_paths(self):
        for path in ('/', '$HFD_ROOT/data', '$HOME/../other'):
            result = self.shell(f'export OPENCLAW_USER_DATA_DIR="{path}"; hf_datasets_main --dry-run')
            self.assertNotEqual(result.returncode, 0, result.stderr)

    def test_foreign_source_preserved(self):
        result = self.shell('''
hfd_paths
mkdir -p "$HFD_SOURCE"
echo keep > "$HFD_SOURCE/own-file"
if hfd_fetch; then exit 99; fi
test "$(cat "$HFD_SOURCE/own-file")" = keep
test ! -e "$HFD_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def fixture(self, failure=0):
        return '''
hfd_paths
mkdir -p "$HFD_BASE" "$HFD_VENV/bin"
touch "$HFD_VENV/pyvenv.cfg"
HFD_PYTHON=mock_python
mock_python() { return 0; }
hfd_source_ok() { return 0; }
printf '#!/usr/bin/env bash\\nprintf "%%s\\n" "$*" >> "$HOME/pip-calls"\\nexit ''' + str(failure) + '''\\n' > "$HFD_VENV/bin/python"
chmod +x "$HFD_VENV/bin/python"
'''

    def test_mock_install_success(self):
        result = self.shell(self.fixture() + '''
hfd_install_package
test "$(cat "$HFD_MARKER")" = "$HFD_COMMIT base"
grep -q 'only-binary=pyarrow,numpy,pandas.*source' "$HOME/pip-calls"
grep -q 'pip --isolated check' "$HOME/pip-calls"
grep -q 'importlib.metadata' "$HOME/pip-calls"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_mock_failure_has_no_success_marker(self):
        result = self.shell(self.fixture(42) + '''
echo old > "$HFD_MARKER"
set +e
(set -e; hfd_install_package)
rc=$?
test "$rc" = 42 && test ! -e "$HFD_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_deactivate_preserves_data(self):
        result = self.shell(self.fixture() + '''
touch "$HFD_MARKER" "$HFD_BASE/private-data.parquet"
hfd_deactivate
test ! -e "$HFD_MARKER"
test -f "$HFD_BASE/private-data.parquet" && test -f "$HFD_VENV/bin/python"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_probe_metadata_only_rejects_bad_marker(self):
        result = self.shell(self.fixture() + '''
printf '%s base\\n' "$HFD_COMMIT" > "$HFD_MARKER"
hfd_probe
grep -q 'importlib.metadata' "$HOME/pip-calls"
echo wrong > "$HFD_MARKER"
if hfd_probe; then exit 99; fi
''')
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
