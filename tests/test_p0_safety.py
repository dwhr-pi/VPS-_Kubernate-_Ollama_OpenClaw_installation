"""P0 regressions: temporary Git repositories and mocked Docker only, no network."""
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('repo_safety', ROOT / 'scripts/lib/repo_safety.py')
safety = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(safety)
GIT = 'C:/Program Files/Git/cmd/git.exe' if os.name == 'nt' else shutil.which('git')
BASH = ('C:/Program Files/Git/usr/bin/bash.exe' if os.name == 'nt' else shutil.which('bash'))


@unittest.skipUnless(GIT, 'Git required; never installed by these tests')
class RepositorySafety(unittest.TestCase):
    seed = None

    @classmethod
    def setUpClass(cls):
        # Use the native Git binary, never a WindowsApps/WSL launcher or host hooks.
        cls.environment = patch.dict(os.environ, {
            'PATH': str(Path(GIT).parent) + os.pathsep + os.environ.get('PATH', ''),
            'GIT_CONFIG_NOSYSTEM': '1', 'GIT_CONFIG_GLOBAL': os.devnull,
        })
        cls.environment.start()
        cls.addClassCleanup(cls.environment.stop)

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.repo = self.root / 'repo'
        self.backups = self.root / 'backups'
        if type(self).seed is not None:
            shutil.copytree(type(self).seed, self.repo)
            self.target = type(self).seed_target
            self.local_head = type(self).seed_head
            return
        self.repo.mkdir()
        self.git('init', '-b', 'main')
        self.git('config', 'user.email', 'fixture@example.invalid')
        self.git('config', 'user.name', 'Fixture')
        self.git('config', 'core.autocrlf', 'false')
        (self.repo / 'tracked.txt').write_text('base\n')
        (self.repo / '.gitignore').write_text('*.cache\n')
        self.git('add', '.')
        self.git('commit', '-m', 'base')
        base = self.git('rev-parse', 'HEAD').strip()
        (self.repo / 'tracked.txt').write_text('target\n')
        (self.repo / 'remote-only.txt').write_text('target only\n')
        self.git('add', '.')
        self.git('commit', '-m', 'target')
        self.target = self.git('rev-parse', 'HEAD').strip()
        self.git('update-ref', 'refs/remotes/origin/main', self.target)
        self.git('checkout', '-b', 'local-work', base)
        (self.repo / 'local-commit.txt').write_text('local commit\n')
        self.git('add', '.')
        self.git('commit', '-m', 'local commit')
        self.local_head = self.git('rev-parse', 'HEAD').strip()
        (self.repo / 'tracked.txt').write_text('staged\n')
        self.git('add', 'tracked.txt')
        (self.repo / 'tracked.txt').write_text('unstaged\n')
        (self.repo / 'untracked.txt').write_text('keep untracked\n')
        (self.repo / 'ignored.cache').write_text('keep ignored\n')
        # Clone an immutable fixture seed, not a live checkout, for later tests.
        seed_temp = tempfile.TemporaryDirectory()
        type(self).addClassCleanup(seed_temp.cleanup)
        type(self).seed = Path(seed_temp.name).resolve() / 'repo'
        type(self).seed_target = self.target
        type(self).seed_head = self.local_head
        shutil.copytree(self.repo, type(self).seed)

    def git(self, *args, repo=None):
        env = dict(os.environ, GIT_OPTIONAL_LOCKS='0', GIT_TERMINAL_PROMPT='0')
        result = subprocess.run([GIT, '-c', 'core.hooksPath=' + os.devnull,
                                 '-c', 'core.fsmonitor=false', '-c', 'commit.gpgsign=false',
                                 '-C', str(repo or self.repo), *args],
                                env=env, capture_output=True, text=True, timeout=20)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout

    def test_backup_restore_recovers_index_worktree_untracked_ignored_and_commits(self):
        before = safety.entries(self.repo)
        snapshot = safety.backup(self.repo, self.backups)
        restored = safety.restore(snapshot, self.root / 'restored')
        self.assertEqual(safety.entries(restored), before)
        self.assertEqual(self.git('show', ':tracked.txt', repo=restored), 'staged\n')
        self.assertEqual((restored / 'tracked.txt').read_text(), 'unstaged\n')
        self.assertEqual(self.git('rev-parse', 'local-work', repo=restored).strip(), self.local_head)
        self.assertEqual((restored / 'ignored.cache').read_text(), 'keep ignored\n')
        if os.name == 'posix':
            self.assertEqual(snapshot.stat().st_mode & 0o777, 0o700)
            self.assertEqual((snapshot / 'repository.tar').stat().st_mode & 0o777, 0o600)

    def test_sync_preserves_local_branch_and_untracked_files_and_is_idempotent(self):
        first = safety.sync(self.repo, self.backups, 'origin/main')
        self.assertEqual(first['status'], 'updated')
        self.assertEqual(self.git('rev-parse', 'HEAD').strip(), self.target)
        self.assertEqual(self.git('rev-parse', 'local-work').strip(), self.local_head)
        self.assertTrue((self.repo / 'untracked.txt').is_file())
        self.assertTrue((self.repo / 'ignored.cache').is_file())
        before = safety.entries(self.repo)
        snapshots = list(self.backups.glob('*/VERIFIED'))
        second = safety.sync(self.repo, self.backups, 'origin/main')
        self.assertEqual(second['status'], 'unchanged')
        self.assertEqual(safety.entries(self.repo), before)
        self.assertEqual(list(self.backups.glob('*/VERIFIED')), snapshots)

    def test_untracked_target_collision_refuses_mutation(self):
        (self.repo / 'remote-only.txt').write_text('user data\n')
        before = safety.entries(self.repo)
        with self.assertRaises(safety.SafetyError):
            safety.sync(self.repo, self.backups, 'origin/main')
        self.assertEqual(safety.entries(self.repo), before)
        self.assertFalse(list(self.backups.glob('*/VERIFIED')))

    def test_disk_failure_never_reaches_checkout(self):
        before = safety.entries(self.repo)
        with patch.object(safety.shutil, 'disk_usage', return_value=SimpleNamespace(free=0)):
            with self.assertRaises(safety.SafetyError):
                safety.sync(self.repo, self.backups, 'origin/main')
        self.assertEqual(safety.entries(self.repo), before)
        self.assertFalse(list(self.backups.glob('*/VERIFIED')))

    def test_corrupt_archive_is_rejected_before_restore_target_creation(self):
        snapshot = safety.backup(self.repo, self.backups)
        with (snapshot / 'repository.tar').open('ab') as stream:
            stream.write(b'corruption')
        destination = self.root / 'restore-must-not-exist'
        with self.assertRaises(safety.SafetyError):
            safety.restore(snapshot, destination)
        self.assertFalse(destination.exists())

    def test_existing_restore_target_is_never_overwritten(self):
        snapshot = safety.backup(self.repo, self.backups)
        with self.assertRaises(safety.SafetyError):
            safety.restore(snapshot, self.repo)

    def test_backup_inside_checkout_is_rejected_without_lock_file(self):
        before = safety.entries(self.repo)
        with self.assertRaises(safety.SafetyError):
            safety.sync(self.repo, self.repo / 'unsafe-backups', 'origin/main')
        self.assertEqual(safety.entries(self.repo), before)

    def test_credentialed_remote_is_refused_without_disclosing_value(self):
        token = 'p0-dummy'
        self.git('remote', 'add', 'origin', 'https://' + token + '@github.com/example/repo.git')
        with self.assertRaises(safety.SafetyError) as result:
            safety.repository(self.repo)
        self.assertNotIn(token, str(result.exception))

    def test_checkout_failure_retains_verified_snapshot(self):
        original = safety.git

        def failing_git(repo, *args, **kwargs):
            if args and args[0] == 'checkout':
                raise safety.SafetyError('fixture checkout failure')
            return original(repo, *args, **kwargs)

        with patch.object(safety, 'git', side_effect=failing_git):
            with self.assertRaises(safety.SafetyError):
                safety.sync(self.repo, self.backups, 'origin/main')
        snapshots = list(self.backups.glob('*/VERIFIED'))
        self.assertEqual(len(snapshots), 1)
        safety.verify(snapshots[0].parent)

    def test_cli_dry_run_creates_no_backup_or_lock(self):
        before = safety.entries(self.repo)
        result = subprocess.run([sys.executable, '-I', '-B', str(ROOT / 'scripts/lib/repo_safety.py'),
                                 'sync', '--repo', str(self.repo), '--backup-root', str(self.backups), '--dry-run'],
                                capture_output=True, text=True, timeout=20)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.backups.exists())
        self.assertEqual(safety.entries(self.repo), before)

    def test_archive_path_traversal_is_rejected(self):
        for name in ('../escape', '/absolute', 'C:/escape', 'a/../escape', 'a\\escape'):
            with self.assertRaises(safety.SafetyError):
                safety.checked_name(name)

    def test_apply_requires_confirmation_before_backup_or_checkout(self):
        before = safety.entries(self.repo)
        result = subprocess.run([sys.executable, '-I', '-B', str(ROOT / 'scripts/lib/repo_safety.py'),
                                 'sync', '--repo', str(self.repo), '--backup-root', str(self.backups), '--apply'],
                                capture_output=True, text=True, timeout=20)
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.backups.exists())
        self.assertEqual(safety.entries(self.repo), before)


@unittest.skipUnless(BASH and Path(BASH).exists(), 'Native Bash required')
class ShellSafety(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.work = Path(self.temp.name).resolve()
        self.log = self.work / 'calls'
        self.env = dict(os.environ, HOME=str(self.work), TMPDIR=str(self.work),
                        FIXTURE_LOG=str(self.log), INSTALL_SOURCE=str(ROOT / 'install.sh'),
                        FIXTURE_ROOT=str(self.work / 'managed'))
        package = self.work / 'package/scripts/tools/helpers'
        package.mkdir(parents=True)
        helper = ROOT / 'scripts/tools/helpers/docker_compose_tool_common.sh'
        (package / helper.name).write_bytes(helper.read_bytes())
        status = self.work / 'package/scripts/helpers'
        status.mkdir()
        (status / 'status_tracking.sh').write_text('# offline fixture; no status initialization\n')
        self.env['COMPOSE_SOURCE'] = str(package / helper.name)
        managed = self.work / 'managed'
        managed.mkdir(mode=0o700)
        self.tool = managed / 'fixture'
        self.tool.mkdir(mode=0o700)
        (self.tool / 'docker-compose.yml').write_text('services: {}\n')
        (self.tool / '.env').write_text('FIXTURE=true\n')
        (self.tool / 'keep.data').write_text('persistent fixture\n')

    def bash(self, code):
        return subprocess.run([BASH, '--noprofile', '--norc', '-c', 'export PATH=/usr/bin:/bin:$PATH\n' + code],
                              env=self.env, capture_output=True, text=True, timeout=30)

    def compose_prelude(self):
        return '''set -euo pipefail
TOOL_NAME=Fixture
TOOL_KEY=Fixture
TOOL_SLUG=fixture
source "$COMPOSE_SOURCE"
COMPOSE_TOOL_ROOT=$(cd "$FIXTURE_ROOT" && pwd)
TOOL_DIR="$COMPOSE_TOOL_ROOT/fixture"
init_tool_tracking() { printf 'init\\n' >> "$FIXTURE_LOG"; }
mark_current_tool_removed() { printf 'removed\\n' >> "$FIXTURE_LOG"; }
docker() { return 0; }
run_docker_compose_tool() {
    printf '%s\\n' "$@" >> "$FIXTURE_LOG"
    return "${FIXTURE_DOCKER_EXIT:-0}"
}
'''

    def test_uninstall_retains_files_and_never_removes_volumes(self):
        code = self.compose_prelude() + 'compose_tool_write_owner\nuninstall_docker_compose_tool\nuninstall_docker_compose_tool\n'
        result = self.bash(code)
        self.assertEqual(result.returncode, 0, result.stderr)
        calls = self.log.read_text()
        self.assertIn('down\n', calls)
        self.assertNotIn('-v\n', calls)
        self.assertNotIn('--volumes', calls)
        self.assertEqual((self.tool / 'keep.data').read_text(), 'persistent fixture\n')
        self.assertEqual((self.tool / '.env').read_text(), 'FIXTURE=true\n')
        self.assertTrue((self.tool / 'docker-compose.yml').is_file())

    def test_legacy_uninstall_requires_explicit_adoption(self):
        result = self.bash(self.compose_prelude() + 'uninstall_docker_compose_tool\n')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())
        result = self.bash(self.compose_prelude() + 'uninstall_docker_compose_tool --adopt-legacy\n')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((self.tool / 'keep.data').exists())

    def test_dry_run_does_not_call_docker_or_change_status(self):
        result = self.bash(self.compose_prelude() + 'uninstall_docker_compose_tool --dry-run --adopt-legacy\n')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.log.exists())
        self.assertFalse((self.tool / '.openclaw-compose-owner').exists())

    def test_unsafe_tool_path_is_refused_before_side_effects(self):
        result = self.bash(self.compose_prelude() + 'TOOL_DIR=/\nuninstall_docker_compose_tool --adopt-legacy\n')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())

    def test_wrong_owner_marker_is_refused(self):
        result = self.bash(self.compose_prelude() + 'compose_tool_write_owner\nTOOL_KEY=Different\nuninstall_docker_compose_tool --adopt-legacy\n')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())

    def test_docker_failure_does_not_clear_installed_status(self):
        self.env['FIXTURE_DOCKER_EXIT'] = '17'
        result = self.bash(self.compose_prelude() + 'uninstall_docker_compose_tool --adopt-legacy\n')
        self.assertEqual(result.returncode, 17, result.stderr)
        self.assertNotIn('removed', self.log.read_text())
        self.assertTrue((self.tool / 'keep.data').exists())

    def test_pat_never_appears_in_git_arguments_and_temp_files_are_cleaned(self):
        result = self.bash('''set -euo pipefail
source "$INSTALL_SOURCE"
GITHUB_PAT=p0-dummy
export GITHUB_PAT
set -x
git_auth_init
auth_dir="$GIT_AUTH_DIR"
git() {
    printf '%s\\n' "$@" > "$FIXTURE_LOG"
    [[ -z ${GITHUB_PAT+x} ]]
    [[ -z ${GIT_TRACE_CURL+x} ]]
    local received
    received=$("$GIT_ASKPASS" "Password for 'https://x-access-token@github.com': ")
    [[ "$received" == p0-dummy ]]
}
export GIT_TRACE_CURL=1
git_auth_run clone https://github.com/example/repo.git fixture
if "$GIT_AUTH_DIR/askpass" "Password for 'https://evil.invalid': "; then exit 91; fi
git_auth_cleanup
[[ ! -e "$auth_dir" ]]
''')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('p0-dummy', self.log.read_text())
        self.assertNotIn('p0-dummy', result.stdout + result.stderr)
        self.assertIn('credential.helper=', self.log.read_text())

    def test_bootstrap_dry_run_does_not_start_interactive_installer(self):
        result = self.bash('bash "$INSTALL_SOURCE" --dry-run\n')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Dry-run', result.stdout)
        self.assertFalse(self.log.exists())

    def test_auth_tempfiles_are_removed_on_failure_exit(self):
        result = self.bash('''set -euo pipefail
source "$INSTALL_SOURCE"
trap git_auth_cleanup EXIT
GITHUB_PAT=p0-dummy
git_auth_init
exit 23
''')
        self.assertEqual(result.returncode, 23, result.stderr)
        self.assertFalse(list(self.work.glob('openclaw-git-auth.*')))

    @unittest.skipUnless(os.name == 'posix', 'POSIX symlink acceptance in Ubuntu CI')
    def test_symlink_escape_is_refused_before_docker(self):
        outside = self.work / 'outside'
        outside.mkdir()
        (outside / 'keep').write_text('outside data\n')
        moved = self.tool.with_name('original')
        self.tool.rename(moved)
        self.tool.symlink_to(outside, target_is_directory=True)
        result = self.bash(self.compose_prelude() + 'uninstall_docker_compose_tool --adopt-legacy\n')
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(self.log.exists())
        self.assertEqual((outside / 'keep').read_text(), 'outside data\n')


if __name__ == '__main__':
    unittest.main()
