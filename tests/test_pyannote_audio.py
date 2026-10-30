"""Offline GitHub/CPU installer contracts; no packages, audio, models, WSL or network."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = Path('C:/Program Files/Git/bin/bash.exe') if os.name == 'nt' else shutil.which('bash')
HELPER = ROOT / 'scripts/tools/helpers/pyannote_audio_common.sh'


def shell_path(path):
    text = str(path).replace('\\', '/')
    return '/' + text[0].lower() + text[2:] if os.name == 'nt' else text


class PyannoteContract(unittest.TestCase):
    def test_registry_menu_and_pin(self):
        tool = next(t for t in json.loads((ROOT / 'config/tools.yml').read_text())['tools']
                    if t['id'] == 'pyannote_audio')
        self.assertEqual(tool['status'], 'experimental')
        self.assertEqual(tool['install_mode'], 'source')
        self.assertFalse(tool['auto_install'])
        self.assertEqual(tool['ports'], [])
        self.assertIn(tool['source_commit'], HELPER.read_text())
        for field in ('doc', 'install_script', 'update_script', 'uninstall_script', 'doctor_script'):
            self.assertTrue((ROOT / tool[field]).is_file())
            self.assertNotIn('audio_review_candidate', tool[field])
        self.assertIn('TOOL_SCRIPT_NAMES["Pyannote_Audio"]="pyannote_audio"',
                      (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8'))

    def test_cpu_pins_and_privacy(self):
        text = HELPER.read_text()
        for token in ('https://github.com/pyannote/pyannote-audio.git', 'PA_TAG=4.0.4',
                      'refs/tags/$PA_TAG^{}', 'INSTALL_HEAVY_TOOLS', 'require_ram_mb 8192',
                      'require_disk_mb 10240', 'flock -n 9', 'GIT_TERMINAL_PROMPT=0',
                      'torch==2.10.0', 'torchaudio==2.10.0', 'torchcodec==0.10.0',
                      'https://download.pytorch.org/whl/cpu', 'PYANNOTE_METRICS_ENABLED=0',
                      'HF_HUB_OFFLINE=1', 'HF_HUB_DISABLE_TELEMETRY=1', 'OTEL_SDK_DISABLED=true'):
            self.assertIn(token, text)
        for forbidden in ('docker compose', 'Pipeline.from_pretrained', 'snapshot_download',
                          'import torch', 'from pyannote.audio import', 'rm -rf', 'sudo apt'):
            self.assertNotIn(forbidden, text)
        runtime = text[text.index('pa_install_runtime()'):text.index('pa_deactivate()')]
        self.assertLess(runtime.index('pip --isolated check'), re.search(r'>\s*"\$PA_RUNTIME_MARKER"', runtime).start())

    def test_document_links(self):
        doc = ROOT / 'docs/tools/pyannote-audio.md'
        for link in re.findall(r'\]\(([^)]+)\)', doc.read_text(encoding='utf-8')):
            if '://' not in link and not link.startswith('#'):
                self.assertTrue((doc.parent / link.split('#')[0]).exists())


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Git Bash/bash unavailable')
class PyannoteOffline(unittest.TestCase):
    def invoke(self, script):
        with tempfile.TemporaryDirectory() as temp:
            folder = Path(temp)
            prefix = f'''
source scripts/tools/helpers/pyannote_audio_common.sh
export OPENCLAW_USER_DATA_DIR='{shell_path(folder / 'private')}'
python3() {{ '{shell_path(Path(sys.executable))}' "$@"; }}
PA_PYTHON=python3
pa_paths
'''
            return subprocess.run([str(BASH), '--noprofile', '--norc', '-c', prefix + script],
                                  cwd=ROOT, capture_output=True, text=True, timeout=40)

    def fixture(self):
        return '''
mkdir -p "$PA_SOURCE/src/pyannote/audio/core"
printf 'raise AssertionError("NEVER IMPORT")\\n' > "$PA_SOURCE/src/pyannote/audio/__init__.py"
printf 'raise AssertionError("NEVER IMPORT")\\n' > "$PA_SOURCE/src/pyannote/audio/core/pipeline.py"
touch "$PA_SOURCE/pyproject.toml"
pa_source_ok() { return 0; }
'''

    def test_plan_status_no_creation(self):
        result = self.invoke('''
git() { echo UNEXPECTED_NETWORK; return 99; }
pyannote_audio_main --dry-run
pyannote_audio_main status
test ! -e "$PA_BASE"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('UNEXPECTED_NETWORK', result.stdout)
        self.assertIn('"authenticity_verdict":null', result.stdout)

    def test_doctor_missing_fails(self):
        result = self.invoke('pyannote_audio_main doctor')
        self.assertEqual(result.returncode, 1)

    def test_source_check_never_imports(self):
        result = self.invoke(self.fixture() + 'pa_syntax')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_source_ready_not_runtime(self):
        result = self.invoke(self.fixture() + '''
pa_fetch_source
test "$(cat "$PA_MARKER")" = "$PA_COMMIT"
test ! -e "$PA_RUNTIME_MARKER"
test ! -e "$PA_VENV"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_foreign_source_preserved(self):
        result = self.invoke('''
mkdir -p "$PA_SOURCE"
printf keep > "$PA_SOURCE/own-file"
if pa_fetch_source; then exit 99; fi
test "$(cat "$PA_SOURCE/own-file")" = keep
test ! -e "$PA_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_wrong_release_tag_blocked(self):
        result = self.invoke('''
mkdir -p "$PA_BASE"
git() { if [[ "$*" == *rev-parse* ]]; then echo wrong-commit; fi; return 0; }
if pa_fetch_source; then exit 99; fi
test ! -e "$PA_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_heavy_opt_in_required(self):
        result = self.invoke('INSTALL_HEAVY_TOOLS=0; pa_runtime_preflight')
        self.assertEqual(result.returncode, 1)
        self.assertIn('INSTALL_HEAVY_TOOLS=1', result.stderr)

    def test_mock_cpu_install_sequence(self):
        result = self.invoke('''
mkdir -p "$PA_SOURCE" "$PA_VENV/bin"
touch "$PA_VENV/pyvenv.cfg"
fake_python() { :; }; PA_PYTHON=fake_python
printf '#!/usr/bin/env bash\nprintf "%%s\\n" "$*" >> "$OPENCLAW_USER_DATA_DIR/pip-args"\n' > "$PA_VENV/bin/python"
chmod +x "$PA_VENV/bin/python"
pa_install_runtime
test "$(cat "$PA_RUNTIME_MARKER")" = "$PA_COMMIT cpu"
grep -q 'https://download.pytorch.org/whl/cpu' "$OPENCLAW_USER_DATA_DIR/pip-args"
grep -q -- '-c ' "$OPENCLAW_USER_DATA_DIR/pip-args"
grep -q 'pip --isolated check' "$OPENCLAW_USER_DATA_DIR/pip-args"
test "$PYANNOTE_METRICS_ENABLED" = 0
test "$HF_HUB_OFFLINE" = 1
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_mock_failure_no_runtime_marker(self):
        result = self.invoke('''
mkdir -p "$PA_SOURCE" "$PA_VENV/bin"
touch "$PA_VENV/pyvenv.cfg"
printf old > "$PA_RUNTIME_MARKER"
fake_python() { :; }; PA_PYTHON=fake_python
printf '#!/usr/bin/env bash\nexit 42\n' > "$PA_VENV/bin/python"
chmod +x "$PA_VENV/bin/python"
set +e
(set -e; pa_install_runtime)
rc=$?
test "$rc" = 42 && test ! -e "$PA_RUNTIME_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_deactivation_preserves_audio_and_source(self):
        result = self.invoke(self.fixture() + '''
pa_fetch_source
printf keep > "$PA_BASE/own-audio.wav"
pa_deactivate
test ! -e "$PA_MARKER"
test ! -e "$PA_RUNTIME_MARKER"
test -f "$PA_SOURCE/pyproject.toml"
test "$(cat "$PA_BASE/own-audio.wav")" = keep
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_start_and_unsafe_path_blocked(self):
        result = self.invoke('pyannote_audio_main start')
        self.assertEqual(result.returncode, 2)
        result = self.invoke('OPENCLAW_USER_DATA_DIR=/; pa_paths')
        self.assertEqual(result.returncode, 1)


if __name__ == '__main__':
    unittest.main()
