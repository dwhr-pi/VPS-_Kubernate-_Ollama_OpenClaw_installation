"""Native Bash/stub fixtures only; no WSL, sudo, APT or package installation."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'scripts/ci/install_qa_tools.sh'
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


@unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash unavailable; no WSL fallback')
class CIBootstrap(unittest.TestCase):
    def shell(self, code, env=None):
        environment = {key: value for key, value in os.environ.items()
                       if key in ('PATH', 'SYSTEMROOT', 'WINDIR', 'TEMP', 'TMP', 'HOME')}
        environment.update(env or {})
        return subprocess.run([BASH, '--noprofile', '--norc', '-s'], input=code,
                              capture_output=True, text=True, env=environment, timeout=20)

    def test_source_render_is_read_only_signed_and_not_azure(self):
        result = self.shell(f'bash "{SCRIPT.as_posix()}" --sources\n')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(result.stdout.splitlines()), 4)
        self.assertEqual(result.stdout.count('signed-by=/usr/share/keyrings/ubuntu-archive-keyring.gpg'), 4)
        self.assertIn('https://archive.ubuntu.com/ubuntu noble ', result.stdout)
        self.assertIn('https://security.ubuntu.com/ubuntu noble-security ', result.stdout)
        self.assertNotIn('azure', result.stdout)
        self.assertNotIn('trusted=yes', result.stdout)

    def test_install_refuses_non_ci_and_self_hosted_before_mutation(self):
        for env in ({}, {'GITHUB_ACTIONS': 'true', 'RUNNER_OS': 'Windows', 'RUNNER_ENVIRONMENT': 'github-hosted'},
                    {'GITHUB_ACTIONS': 'true', 'RUNNER_OS': 'Linux', 'RUNNER_ENVIRONMENT': 'self-hosted'}):
            with self.subTest(env=env):
                result = self.shell(f'bash "{SCRIPT.as_posix()}"\n', env)
                self.assertEqual(result.returncode, 2)
                self.assertIn('GitHub-hosted Linux runner required', result.stderr)

    def fixture(self, directory, missing=False, fail=False):
        code = f'source "{SCRIPT.as_posix()}"\n'
        code += r'''
# All mutation and privilege boundaries below are controlled fixture functions.
qa_runner_guard() { :; }
shellcheck() { printf 'shellcheck fixture\n'; }
shfmt() { printf 'shfmt fixture\n'; }
python3() { printf 'python fixture\n'; }
sudo() {
  printf '%s\n' "$*" >>"$FIXTURE_LOG"
  if [[ ${FAIL_UPDATE:-0} == 1 && ${*: -1} == update ]]; then return 100; fi
}
'''
        if missing:
            code += r'''
command() {
  if [[ $1 == -v && $2 == shfmt ]]; then return 1; fi
  builtin command "$@"
}
'''
        code += 'qa_install\n'
        return self.shell(code, {'RUNNER_TEMP': directory.as_posix(),
                                 'FIXTURE_LOG': (directory / 'calls.txt').as_posix(),
                                 'FAIL_UPDATE': '1' if fail else '0'})

    def test_existing_commands_skip_apt_but_still_verify_versions(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            result = self.fixture(directory)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertFalse((directory / 'calls.txt').exists())
            self.assertIn('shfmt fixture', result.stdout)
            self.assertIn('shellcheck fixture', result.stdout)
            self.assertIn('python fixture', result.stdout)

    def test_missing_tool_uses_isolated_signed_sources_for_both_apt_calls(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            result = self.fixture(directory, missing=True)
            self.assertEqual(result.returncode, 0, result.stderr)
            calls = (directory / 'calls.txt').read_text().splitlines()
            self.assertEqual(len(calls), 2)
            for call in calls:
                self.assertIn('Dir::Etc::sourcelist=', call)
                self.assertIn('Dir::Etc::sourceparts=-', call)
                self.assertIn('APT::Update::Error-Mode=any', call)
                self.assertIn('Acquire::Retries=2', call)
            self.assertTrue(calls[0].endswith(' update'))
            self.assertTrue(calls[1].endswith(' install -y --no-install-recommends shfmt'))
            self.assertEqual([p.name for p in directory.iterdir()], ['calls.txt'])

    def test_update_failure_is_fatal_without_install_or_success_versions(self):
        with tempfile.TemporaryDirectory() as temporary:
            directory = Path(temporary)
            result = self.fixture(directory, missing=True, fail=True)
            self.assertEqual(result.returncode, 100)
            self.assertEqual(len((directory / 'calls.txt').read_text().splitlines()), 1)
            self.assertNotIn('shfmt fixture', result.stdout)
            self.assertEqual([p.name for p in directory.iterdir()], ['calls.txt'])

    def test_workflows_keep_checks_and_pin_supported_runner(self):
        for name in ('ci.yml', 'repo-health.yml'):
            text = (ROOT / '.github/workflows' / name).read_text()
            self.assertIn('runs-on: ubuntu-24.04', text)
            self.assertIn('bash scripts/ci/install_qa_tools.sh', text)
            for term in ('ShellCheck', 'shfmt check', 'Registry sync'):
                self.assertIn(term, text)
            self.assertNotIn('continue-on-error', text)
        script = SCRIPT.read_text()
        for forbidden in ('trusted=yes', 'AllowUnauthenticated', '--allow-unauthenticated',
                          'Verify-Peer=false', 'sed -i', 'rm -rf'):
            self.assertNotIn(forbidden, script)


if __name__ == '__main__':
    unittest.main()
