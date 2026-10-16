"""Offline AudioSeal lifecycle tests; no pip/network/model/audio/WSL calls."""
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
HELPER = 'scripts/tools/helpers/audioseal_common.sh'


class Contract(unittest.TestCase):
    def test_registry_source_and_guards(self):
        tool, = [t for t in json.loads((ROOT / 'config/tools.yml').read_text())['tools']
                 if t['id'] == 'audioseal']
        self.assertEqual(tool['status'], 'experimental')
        self.assertFalse(tool['auto_install'])
        self.assertEqual(tool['install_mode'], 'source')
        self.assertEqual(tool['ports'], [])
        for key in ('doc', 'install_script', 'update_script', 'uninstall_script', 'doctor_script'):
            self.assertTrue((ROOT / tool[key]).is_file())
        text = (ROOT / HELPER).read_text()
        self.assertIn('AS_COMMIT=' + tool['source_commit'], text)
        for token in ('--index-url https://download.pytorch.org/whl/cpu',
                      'torch==2.10.0+cpu', '"$AS_SOURCE"', 'as_prepare_python',
                      'af_prepare_venv', 'AUDIOSEAL_AUTO_VENV', 'flock -n 9',
                      'require_ram_mb 6144', '-ge 4096', 'require_disk_mb 8192',
                      'REQUIRE_WINDOWS_HOST_FREE_MB=8192', 'pip --isolated check'):
            self.assertIn(token, text)
        for forbidden in ('import torch', 'from audioseal import', 'load_detector(',
                          'load_generator(', 'from_pretrained(', 'docker compose',
                          'pip install audioseal', 'rm -rf'):
            self.assertNotIn(forbidden, text)
        main = text.split('audioseal_main() (', 1)[1]
        self.assertLess(main.index('as_resources'), main.index('as_prepare_python\n'))
        self.assertLess(main.index('as_prepare_python\n'), main.index('as_fetch\n'))

    def test_docs_links_and_checkpoint_warning(self):
        doc = ROOT / 'docs/tools/audioseal.md'
        text = doc.read_text()
        self.assertIn('weights_only=False', text)
        self.assertIn('kein Modelltest', text)
        for link in re.findall(r'\]\(([^)]+)\)', text):
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

    def test_dry_run_without_tools_or_creation(self):
        result = self.shell('''
git() { exit 99; }; python3() { exit 99; }; sudo() { exit 99; }
audioseal_main --dry-run
test ! -e "$HOME/.openclaw_ultimate_user_data"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Dry-Run ohne Download', result.stdout)

    def test_status_missing_offline(self):
        result = self.shell('audioseal_main status; test ! -e "$HOME/.openclaw_ultimate_user_data"')
        self.assertEqual(result.returncode, 0, result.stderr)
        state = json.loads(result.stdout)
        self.assertFalse(state['installed'])
        self.assertIsNone(state['authenticity_verdict'])

    def test_doctor_missing_and_start_rejected(self):
        for mode, rc in (('doctor', 1), ('start', 2), ('detect', 2)):
            result = self.shell('audioseal_main ' + mode)
            self.assertEqual(result.returncode, rc, result.stderr)

    def test_invalid_paths_rejected(self):
        for path in ('/', '$AS_ROOT/data', '$HOME/../other'):
            result = self.shell(f'export OPENCLAW_USER_DATA_DIR="{path}"; audioseal_main --dry-run')
            self.assertNotEqual(result.returncode, 0, result.stderr)

    def test_foreign_source_preserved(self):
        result = self.shell('''
as_paths
mkdir -p "$AS_SOURCE"
echo keep > "$AS_SOURCE/own-file"
if as_fetch; then exit 99; fi
test "$(cat "$AS_SOURCE/own-file")" = keep
test ! -e "$AS_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_existing_clean_source_not_fetched(self):
        result = self.shell('''
as_paths
mkdir -p "$AS_SOURCE/src/audioseal"
touch "$AS_SOURCE/pyproject.toml" "$AS_SOURCE/src/audioseal/__init__.py"
as_source_ok() { return 0; }
git() { exit 99; }
as_fetch
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def runtime_fixture(self, failure=0):
        return '''
as_paths
mkdir -p "$AS_BASE" "$AS_VENV/bin"
touch "$AS_VENV/pyvenv.cfg"
AS_PYTHON=mock_python
mock_python() { return 0; }
printf '#!/usr/bin/env bash\\nprintf "%%s\\n" "$*" >> "$HOME/pip-calls"\\nexit ''' + str(failure) + '''\\n' > "$AS_VENV/bin/python"
chmod +x "$AS_VENV/bin/python"
'''

    def test_mock_install_marks_after_checks(self):
        result = self.shell(self.runtime_fixture() + '''
as_install_cpu
test "$(cat "$AS_MARKER")" = "$AS_COMMIT cpu"
grep -q 'download.pytorch.org/whl/cpu torch==2.10.0+cpu' "$HOME/pip-calls"
grep -q 'constraints.txt.*source' "$HOME/pip-calls"
grep -q 'pip --isolated check' "$HOME/pip-calls"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_failed_pip_removes_old_marker(self):
        result = self.shell(self.runtime_fixture(42) + '''
echo old > "$AS_MARKER"
set +e
(set -e; as_install_cpu)
rc=$?
test "$rc" = 42 && test ! -e "$AS_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_deactivate_preserves_files(self):
        result = self.shell(self.runtime_fixture() + '''
touch "$AS_MARKER" "$AS_BASE/own-audio.wav"
as_deactivate
test ! -e "$AS_MARKER"
test -f "$AS_BASE/own-audio.wav" && test -f "$AS_VENV/bin/python"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_probe_metadata_only_and_rejects_wrong_marker(self):
        result = self.shell(self.runtime_fixture() + '''
as_source_ok() { return 0; }
printf '%s cpu\\n' "$AS_COMMIT" > "$AS_MARKER"
as_probe
grep -q 'importlib.metadata' "$HOME/pip-calls"
echo wrong > "$AS_MARKER"
if as_probe; then exit 99; fi
''')
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
