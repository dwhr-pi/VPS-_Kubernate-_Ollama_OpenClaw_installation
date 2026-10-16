"""Offline GitHub-VSIX contracts. Synthetic ZIPs only, no editor or WSL calls."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[1]
BASH = Path('C:/Program Files/Git/bin/bash.exe') if os.name == 'nt' else shutil.which('bash')


def shell_path(path):
    value = str(path).replace('\\', '/')
    return '/' + value[0].lower() + value[2:] if os.name == 'nt' else value


class ClineContract(unittest.TestCase):
    def test_registry_wired_to_github_release(self):
        tool = next(t for t in json.loads((ROOT / 'config/tools.yml').read_text())['tools'] if t['id'] == 'cline')
        self.assertEqual(tool['status'], 'experimental')
        self.assertEqual(tool['install_mode'], 'github-release')
        self.assertFalse(tool['auto_install'])
        self.assertEqual(tool['ports'], [])
        self.assertTrue(tool['check_value'].endswith('/release-ready'))
        for field in ('doc', 'install_script', 'update_script', 'uninstall_script', 'doctor_script'):
            self.assertTrue((ROOT / tool[field]).is_file())
            self.assertNotIn('hybrid_media_candidate', tool[field])
        self.assertIn('TOOL_SCRIPT_NAMES["Cline"]="cline"', (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8'))

    def test_safety_and_pin(self):
        helper = (ROOT / 'scripts/tools/helpers/cline_common.sh').read_text()
        for value in ('v4.1.25/cline-4.1.25.vsix',
                      'aac83af0513f5168372905c02a72eee3835d32a53b9d635d3b055ed4a7bd71fc',
                      'flock -n 9', 'require_disk_mb 256', 'require_disk_mb',
                      '--proto-redir', '--max-filesize', "'saoudrizwan'", 'package_ready'):
            self.assertIn(value, helper)
        for forbidden in ('docker compose', 'npm install', 'code --install-extension', 'rm -rf'):
            self.assertNotIn(forbidden, helper)


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Git Bash/bash unavailable')
class ClineOffline(unittest.TestCase):
    def invoke(self, body, publisher='saoudrizwan', version='4.1.25'):
        with tempfile.TemporaryDirectory() as temp:
            folder = Path(temp)
            archive = folder / 'synthetic.vsix'
            with zipfile.ZipFile(archive, 'w') as out:
                out.writestr('extension/package.json', json.dumps({
                    'name': 'claude-dev', 'publisher': publisher, 'version': version}))
                out.writestr('extension/dist/extension.js', 'throw new Error("NEVER EXECUTE");')
            checksum = hashlib.sha256(archive.read_bytes()).hexdigest()
            python = shell_path(Path(os.sys.executable))
            prefix = f'''
source scripts/tools/helpers/cline_common.sh
export OPENCLAW_USER_DATA_DIR='{shell_path(folder / 'private')}'
python3() {{ '{python}' "$@"; }}
cline_paths
fixture='{shell_path(archive)}'
fixture_hash='{checksum}'
'''
            return subprocess.run([str(BASH), '--noprofile', '--norc', '-c', prefix + body],
                                  cwd=ROOT, capture_output=True, text=True, timeout=40)

    def test_plan_status_no_mutation_network(self):
        result = self.invoke('''
curl() { echo UNEXPECTED_NETWORK; return 99; }
cline_main --dry-run
cline_main status
test ! -e "$OPENCLAW_USER_DATA_DIR"
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('UNEXPECTED_NETWORK', result.stdout)
        self.assertIn('"package_ready":false', result.stdout)

    def test_doctor_missing_fails(self):
        result = self.invoke('cline_main doctor')
        self.assertEqual(result.returncode, 1)

    def test_pinned_hash_rejects_fixture(self):
        result = self.invoke('cline_verify "$fixture"')
        self.assertNotEqual(result.returncode, 0)

    def test_synthetic_archive_metadata_valid(self):
        result = self.invoke('CLINE_SHA256="$fixture_hash"; cline_verify "$fixture"')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_wrong_publisher_rejected(self):
        result = self.invoke('CLINE_SHA256="$fixture_hash"; cline_verify "$fixture"', publisher='fake')
        self.assertNotEqual(result.returncode, 0)

    def test_wrong_version_rejected(self):
        result = self.invoke('CLINE_SHA256="$fixture_hash"; cline_verify "$fixture"', version='0.0.0')
        self.assertNotEqual(result.returncode, 0)

    def test_mock_fetch_and_idempotence(self):
        result = self.invoke('''
CLINE_SHA256="$fixture_hash"
mkdir -p "$CLINE_BASE"
curl() { cp -- "$fixture" "${@: -1}"; }
cline_fetch
test "$(cat "$CLINE_MARKER")" = "$fixture_hash"
curl() { echo UNEXPECTED_NETWORK; return 98; }
cline_fetch
cline_ready
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('UNEXPECTED_NETWORK', result.stdout)
        self.assertIn('Noch NICHT im Editor installiert', result.stdout)

    def test_bad_download_no_marker(self):
        result = self.invoke('''
mkdir -p "$CLINE_BASE"
curl() { printf invalid > "${@: -1}"; }
if cline_fetch; then exit 99; fi
test ! -e "$CLINE_MARKER"
test ! -e "$CLINE_PACKAGE"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_bad_existing_package_preserved(self):
        result = self.invoke('''
mkdir -p "$CLINE_BASE"
printf keep > "$CLINE_PACKAGE"
if cline_fetch; then exit 99; fi
test "$(cat "$CLINE_PACKAGE")" = keep
test ! -e "$CLINE_MARKER"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_start_rejected(self):
        result = self.invoke('cline_main start')
        self.assertEqual(result.returncode, 2)


if __name__ == '__main__':
    unittest.main()
