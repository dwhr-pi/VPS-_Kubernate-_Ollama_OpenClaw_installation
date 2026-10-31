"""Offline dependency fixtures; no real sudo, APT, network or signature operations."""
from pathlib import Path
import shutil
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[1]
BASH = shutil.which('bash')
if Path('C:/Program Files/Git/bin/bash.exe').exists():
    BASH = 'C:/Program Files/Git/bin/bash.exe'


@unittest.skipUnless(BASH, 'Bash required for isolated fixtures')
class MinisignBootstrap(unittest.TestCase):
    def run_fixture(self, consent='1', installed='0', fail='0'):
        script = r'''
installed=$1
fail=$2
command() {
  if [[ "$*" == '-v minisign' ]]; then
    [[ "$installed" == 1 ]]
  else
    builtin command "$@"
  fi
}
uname() { printf 'Linux\n'; }
sed() { printf 'ubuntu\n'; }
minisign() { printf 'VERSION-CHECK\n'; }
apt-get() {
  printf 'APT %s\n' "$*"
  [[ "$fail" == 0 ]] || return 19
  if [[ " $* " == *' install '* ]]; then installed=1; fi
}
sudo() { "$@"; }
ensure_minisign "$3"
'''
        helper = (ROOT / 'scripts/security/ensure_minisign.sh').read_text(encoding='utf-8')
        # Git Bash lacks /etc/os-release; simulate only its readability in this fixture.
        helper = helper.split('if [[ "${BASH_SOURCE[0]}" == "$0" ]]', 1)[0]
        helper = helper.replace('-r /etc/os-release', '-r /dev/null')
        return subprocess.run(
            [BASH, '-c', helper + script, 'fixture', installed, fail, consent],
            cwd=ROOT, input='', capture_output=True, text=True, timeout=15)

    def test_existing_minisign_never_runs_apt(self):
        result = self.run_fixture(installed='1')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('VERSION-CHECK', result.stdout)
        self.assertNotIn('APT ', result.stdout)

    def test_noninteractive_default_denies_install(self):
        result = self.run_fixture(consent='0')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('APT ', result.stdout)

    def test_explicit_consent_installs_only_verifier_and_checks_it(self):
        result = self.run_fixture()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('APT -o DPkg::Lock::Timeout=300 update', result.stdout)
        self.assertIn('install --no-remove --no-install-recommends -y minisign', result.stdout)
        self.assertIn('VERSION-CHECK', result.stdout)

    def test_apt_failure_stops_before_install_or_version_check(self):
        result = self.run_fixture(fail='1')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn(' install ', result.stdout)
        self.assertNotIn('VERSION-CHECK', result.stdout)

    def test_verifier_dependency_gate_precedes_download_and_verification(self):
        text = (ROOT / 'verify_release_and_install.sh').read_text(encoding='utf-8')
        self.assertLess(text.index('ensure_minisign "$install_minisign"'), text.index('if ((download))'))
        self.assertIn('release_manifest.py', text)
