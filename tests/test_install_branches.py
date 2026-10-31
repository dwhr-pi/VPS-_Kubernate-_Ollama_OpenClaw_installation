"""Offline bootstrap branch selection; Git transport, backups and setup are mocked."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')

MOCK_TRANSPORT = r'''
git_auth_run() {
    printf '%s\n' "$*" >> "$LOG"
    case "$*" in
        *'ls-remote '*)
            [[ "${MISSING:-0}" == 0 ]] || return 2
            printf '%s\trefs/heads/%s\n' "$EXPECTED" "$INSTALL_BRANCH" ;;
        *'rev-parse --show-toplevel'*) (cd "$INSTALL_DIR" && pwd -P) ;;
        *'config --get remote.origin.url'*) printf '%s\n' "${MOCK_ORIGIN:-$REPO_URL}" ;;
        *'symbolic-ref --short HEAD'*) printf '%s\n' "${MOCK_BRANCH:-$INSTALL_BRANCH}" ;;
        *'status --porcelain'*)
            [[ "${STATUS_FAIL:-0}" == 0 ]] || return 1
            printf '%s' "${MOCK_STATUS:-}" ;;
        *'rev-parse --verify '*) printf '%s\n' "${FETCHED:-$EXPECTED}" ;;
        *'rev-parse HEAD'*) printf '%s\n' "$EXPECTED" ;;
        *'clone '*) mkdir -p "$INSTALL_DIR/.git" ;;
        *'checkout '*|*'merge '*|*'fetch '*) return 0 ;;
        *) return 3 ;;
    esac
}
create_repo_update_backup() { printf 'BACKUP\n' >> "$LOG"; }
INSTALL_BRANCH='codex/optional-coding-agents-20261029'
INSTALL_DIR="$(branch_install_directory "$INSTALL_BRANCH")"
'''


@unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash required; never launch WSL')
class InstallBranches(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.installer = self.root / 'install.sh'
        self.installer.write_text((ROOT / 'install.sh').read_text(encoding='utf-8'), encoding='utf-8', newline='\n')
        self.log = self.root / 'git.log'
        self.env = dict(os.environ, HOME=self.root.as_posix(), INSTALLER=self.installer.as_posix(),
                        BASH_ENV=os.devnull, GIT_CONFIG_NOSYSTEM='1', GIT_CONFIG_GLOBAL=os.devnull,
                        GIT_TERMINAL_PROMPT='0', EXPECTED='a' * 40, LOG=self.log.as_posix())

    def run_shell(self, command, stdin='', **env):
        answers = self.root / 'answers.txt'
        answers.write_text(stdin, encoding='utf-8', newline='\n')
        return subprocess.run([BASH, '--noprofile', '--norc', '-c',
                               'source "$INSTALLER"\nTTY_DEVICE="$ANSWERS"\n' + command],
                              input=stdin, text=True, capture_output=True, timeout=30,
                              cwd=self.root, env=dict(self.env, ANSWERS=answers.as_posix(), **env))

    def test_main_feature_and_future_branch_selection(self):
        for answer, branch in (('\n', 'main'), ('1\n', 'main'),
                               ('2\n', 'codex/optional-coding-agents-20261029'),
                               ('3\nfuture/my-next-branch\n', 'future/my-next-branch')):
            result = self.run_shell('select_install_branch; printf "RESULT=%s\\n" "$INSTALL_BRANCH"', answer)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('RESULT=' + branch, result.stdout)
        self.assertFalse(self.log.exists())

    def test_cancel_empty_custom_invalid_and_eof_do_not_choose_main(self):
        for answer in ('0\n', 'no\n', '', '3\n\n', '3\n--upload-pack=evil\n', '3\n../bad\n'):
            result = self.run_shell('select_install_branch', answer)
            self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())

    def test_branch_argument_needs_explicit_unsigned_opt_in(self):
        for args in ('--branch main', '--legacy-unsigned-main --unknown',
                     '--legacy-unsigned-main --branch', '--legacy-unsigned-main --branch main --branch other',
                     '--legacy-unsigned-main --legacy-unsigned-branch'):
            self.assertNotEqual(self.run_shell('parse_legacy_options ' + args).returncode, 0)
        for flag in ('--legacy-unsigned-main', '--legacy-unsigned-branch'):
            result = self.run_shell('parse_legacy_options ' + flag + ' --branch future/next; select_install_branch')
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('future/next', result.stdout)

    def test_invalid_refs_and_reflog_expansion_are_denied(self):
        for branch in ('', '-main', '@{-1}', 'name@{0}', 'x..y', 'a b', 'a\nb', 'x*', 'HEAD'):
            result = self.run_shell('validate_install_branch "$TEST_BRANCH"', TEST_BRANCH=branch)
            self.assertNotEqual(result.returncode, 0, branch)

    def test_deterministic_isolated_directories_do_not_collide(self):
        result = self.run_shell('branch_install_directory main; branch_install_directory a/b; '
                                'branch_install_directory a_b; branch_install_directory a/b')
        self.assertEqual(result.returncode, 0, result.stderr)
        main, slash, underscore, again = result.stdout.splitlines()
        self.assertEqual(main, 'openclaw_ultimate_setup')
        self.assertEqual(slash, again)
        self.assertNotEqual(slash, underscore)
        self.assertNotIn('/', slash)

    def test_new_clone_checks_exact_head_and_never_touches_main(self):
        main = self.root / 'openclaw_ultimate_setup'
        main.mkdir()
        (main / 'keep').write_text('main unchanged')
        result = self.run_shell(MOCK_TRANSPORT + '\nprepare_feature_checkout')
        self.assertEqual(result.returncode, 0, result.stderr)
        log = self.log.read_text()
        self.assertIn('ls-remote --exit-code --heads ', log)
        self.assertIn('refs/heads/codex/optional-coding-agents-20261029', log)
        self.assertIn('clone --template= --single-branch --no-checkout --branch codex/', log)
        self.assertIn('merge --ff-only --no-edit ' + 'a' * 40, log)
        self.assertNotIn('reset', log)
        self.assertNotIn('clean ', log)
        self.assertEqual((main / 'keep').read_text(), 'main unchanged')

    def test_missing_branch_never_creates_checkout_or_falls_back(self):
        result = self.run_shell(MOCK_TRANSPORT + '\nprepare_feature_checkout', MISSING='1')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('clone ', self.log.read_text())
        self.assertEqual(list(self.root.glob('openclaw_ultimate_setup*')), [])

    def test_main_uses_exact_head_not_remote_default_or_tag(self):
        result = self.run_shell(MOCK_TRANSPORT + '\nINSTALL_BRANCH=main\nresolve_install_head main')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.strip(), 'a' * 40)
        self.assertIn('refs/heads/main', self.log.read_text())
        source = self.installer.read_text(encoding='utf-8')
        self.assertIn('clone --template= --single-branch --branch main --', source)
        self.assertIn('MAIN_EXPECTED_HEAD="$(resolve_install_head main)"', source)

    def test_wrong_remote_head_reply_is_refused(self):
        function = 'git_auth_run() { printf "%s\\trefs/tags/main\\n" "$EXPECTED"; }\n'
        result = self.run_shell(function + 'resolve_install_head main')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Unerwartete Remote-Antwort', result.stderr)

    def test_existing_feature_checkout_is_backed_up_before_fetch(self):
        result = self.run_shell(MOCK_TRANSPORT + '\nmkdir -p "$INSTALL_DIR/.git"\nprepare_feature_checkout')
        self.assertEqual(result.returncode, 0, result.stderr)
        log = self.log.read_text()
        self.assertLess(log.index('BACKUP'), log.index(' fetch --no-tags origin '))
        self.assertNotIn('clone ', log)

    def test_dirty_foreign_wrong_branch_and_failed_status_block_update(self):
        for env in ({'MOCK_STATUS': ' M important.txt'}, {'MOCK_ORIGIN': 'https://example.invalid/other.git'},
                    {'MOCK_BRANCH': 'main'}, {'STATUS_FAIL': '1'}):
            result = self.run_shell(MOCK_TRANSPORT + '\nmkdir -p "$INSTALL_DIR/.git"\nprepare_feature_checkout', **env)
            self.assertNotEqual(result.returncode, 0, env)
            self.assertNotIn(' fetch ', self.log.read_text())
            self.assertNotIn('checkout ', self.log.read_text())
            self.log.unlink()

    def test_branch_race_stops_before_checkout_and_execution(self):
        result = self.run_shell(MOCK_TRANSPORT + '\nprepare_feature_checkout', FETCHED='b' * 40)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn(' checkout ', self.log.read_text())

    def test_gate_and_shell_syntax_remain_intact(self):
        syntax = subprocess.run([BASH, '--noprofile', '--norc', '-n', self.installer.as_posix()],
                                capture_output=True, text=True, timeout=30, env=self.env)
        self.assertEqual(syntax.returncode, 0, syntax.stderr)
        blocked = subprocess.run([BASH, self.installer.as_posix()], capture_output=True, text=True,
                                 timeout=30, cwd=self.root, env=self.env)
        self.assertEqual(blocked.returncode, 2)
        self.assertIn('gesperrt', blocked.stderr)
        self.assertFalse((self.root / '.openclaw_ultimate_user_data').exists())


if __name__ == '__main__':
    unittest.main()
