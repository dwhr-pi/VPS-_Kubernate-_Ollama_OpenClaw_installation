"""Isolierte Helper-Fixtures mit Git-Mocks; keine Installer oder echten Quellen."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')
HELPER = ROOT / 'scripts/tools/helpers/simple_tool_common.sh'


@unittest.skipUnless(BASH and Path(BASH).is_file(), 'Natives Bash erforderlich')
class SourcePreservation(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.target = self.root / 'source'
        self.trace = self.root / 'trace'
        text = HELPER.read_text(encoding='utf-8')
        start = text.index('clone_or_update_github_source() {')
        self.function = text[start:text.index('\ninstall_git_docker_tool() {', start)]

    def run_helper(self, **settings):
        env = dict(os.environ, FIXTURE_TARGET=str(self.target), FIXTURE_TRACE=str(self.trace),
                   FETCH_EXIT='0', PULL_EXIT='0', CLONE_EXIT='0', ORIGIN='https://github.com/example/fixture.git')
        env.update({k: str(v) for k, v in settings.items()})
        convert = ('target=$(cygpath -u "$FIXTURE_TARGET"); trace=$(cygpath -u "$FIXTURE_TRACE")\n'
                   if os.name == 'nt' else 'target=$FIXTURE_TARGET; trace=$FIXTURE_TRACE\n')
        code = '''set -euo pipefail
log_info() { printf '%s\\n' "$*"; }
log_warn() { printf '%s\\n' "$*" >&2; }
rm() { printf 'UNEXPECTED REMOVE\\n' >> "$trace"; return 99; }
mv() { printf 'UNEXPECTED MOVE\\n' >> "$trace"; return 99; }
git() {
  printf '%s\\n' "$*" >> "$trace"
  case "$*" in
    *'remote get-url origin') printf '%s\\n' "$ORIGIN" ;;
    *'fetch origin --prune') return "$FETCH_EXIT" ;;
    *'pull --ff-only') return "$PULL_EXIT" ;;
    'clone '*) mkdir -p "$target"; printf 'partial\\n' > "$target/partial"; return "$CLONE_EXIT" ;;
    *) return 98 ;;
  esac
}
''' + convert + self.function + '\nclone_or_update_github_source https://github.com/example/fixture.git "$target"\n'
        result = subprocess.run([BASH, '--noprofile', '--norc', '-s'], input=code, env=env,
                                capture_output=True, text=True, timeout=30)
        trace = self.trace.read_text() if self.trace.exists() else ''
        self.assertNotIn('UNEXPECTED', trace)
        return result, trace

    def repository_fixture(self):
        (self.target / '.git').mkdir(parents=True)
        (self.target / 'keep.txt').write_text('local work')

    def test_fetch_failure_preserves_existing_source_without_reclone(self):
        self.repository_fixture()
        result, trace = self.run_helper(FETCH_EXIT=17)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('pull', trace)
        self.assertNotIn('clone ', trace)
        self.assertEqual((self.target / 'keep.txt').read_text(), 'local work')

    def test_pull_failure_preserves_existing_source_without_reclone(self):
        self.repository_fixture()
        result, trace = self.run_helper(PULL_EXIT=18)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('clone ', trace)
        self.assertEqual((self.target / 'keep.txt').read_text(), 'local work')

    def test_partial_or_non_git_target_is_not_replaced(self):
        self.target.mkdir()
        (self.target / 'keep.txt').write_text('partial local work')
        result, trace = self.run_helper()
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(trace, '')
        self.assertEqual((self.target / 'keep.txt').read_text(), 'partial local work')

    def test_origin_mismatch_is_not_moved_or_fetched(self):
        self.repository_fixture()
        result, trace = self.run_helper(ORIGIN='https://github.com/example/different.git')
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn('fetch', trace)
        self.assertEqual((self.target / 'keep.txt').read_text(), 'local work')

    def test_failed_first_clone_keeps_partial_files_without_retry(self):
        result, trace = self.run_helper(CLONE_EXIT=19)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(trace.count('clone '), 1)
        self.assertEqual((self.target / 'partial').read_text(), 'partial\n')

    def test_successful_existing_update_keeps_local_files(self):
        self.repository_fixture()
        result, trace = self.run_helper()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('pull --ff-only', trace)
        self.assertEqual((self.target / 'keep.txt').read_text(), 'local work')


if __name__ == '__main__':
    unittest.main()
