"""Synthetic metrics fixtures; no user workspace, service, model or WSL access."""
import contextlib
import hashlib
import importlib.util
import io
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('literal_metrics_test', ROOT / 'scripts/security/metrics_config.py')
metrics = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(metrics)
SETUP = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
BASH = str(Path('C:/Program Files/Git/bin/bash.exe')) if os.name == 'nt' else shutil.which('bash')
DEFAULT = re.search(r"<<'EOF'\n(.*?)\nEOF", SETUP[SETUP.index('ensure_metrics_config()'):], re.S).group(1).encode()


class LiteralParser(unittest.TestCase):
    def test_actual_default_template_remains_compatible(self):
        rows = metrics.parse(DEFAULT)
        self.assertGreater(len(rows), 60)
        self.assertEqual(rows['TARGET_DEVICE_NAME'], 'Letsung MiniPC')
        self.assertEqual(rows['PROGRAMMIERER_REQUIRED_GB'], '8-20')
        self.assertEqual(rows['STRICT_GITHUB_TOOL_SOURCES'], 'false')

    def test_quotes_comments_unicode_and_empty_values(self):
        data = 'NOTES="Groesse: 2 GB # Hinweis" # outside\nCUSTOM_TOOL_DURATION_ESTIMATE=\'5-10 min\'\nTARGET_HOST_OS=""\n'
        rows = metrics.parse(data.encode())
        self.assertEqual(rows['NOTES'], 'Groesse: 2 GB # Hinweis')
        self.assertEqual(rows['CUSTOM_TOOL_DURATION_ESTIMATE'], '5-10 min')
        self.assertEqual(rows['TARGET_HOST_OS'], '')

    def test_executable_content_and_shell_environment_keys_are_rejected(self):
        for data in (b'NOTES="$(touch SHOULD_NOT_EXIST)"', b'NOTES="`id`"', b'NOTES=x; touch marker',
                     b'PATH=/untrusted', b'BASH_ENV=/untrusted', b'IFS=bad', b'NOTES[0]=bad',
                     b'source /payload', b'export NOTES=x', b'NOTES=x\nNOTES=y',
                     b'NOTES="incomplete', b'NOTES="a\tb"', b'NOTES="a\x00b"'):
            with self.subTest(data=data), self.assertRaises(ValueError):
                metrics.parse(data)

    def test_numeric_consumers_cannot_receive_expressions(self):
        for key in ('LAST_TOOL_X_DURATION_SECONDS', 'LAST_TOOL_X_FREE_KB_BEFORE',
                    'MIN_FREE_GB_RECOMMENDED', 'OVERVIEW_METRICS_MAX_ITEMS', 'DEMO_REQUIRED_GB'):
            with self.assertRaises(ValueError):
                metrics.parse(f'{key}="array[1+2]"'.encode())
        self.assertEqual(metrics.parse(b'LAST_TOOL_X_DELTA_KB="-1024"')['LAST_TOOL_X_DELTA_KB'], '-1024')

    def test_merge_preserves_settings_and_unrelated_history(self):
        old = DEFAULT + b'\nLAST_TOOL_A_STATUS="success"\nLAST_TOOL_B_STATUS="failed"\n'
        result = metrics.parse(metrics.merge(old, b'LAST_TOOL_A_STATUS="failed"\n'))
        self.assertEqual(result['LAST_TOOL_A_STATUS'], 'failed')
        self.assertEqual(result['LAST_TOOL_B_STATUS'], 'failed')
        self.assertEqual(result['TARGET_DEVICE_NAME'], 'Letsung MiniPC')
        with self.assertRaises(ValueError):
            metrics.merge(old, b'TARGET_DEVICE_NAME="replace"')

    def test_size_limit_and_bom(self):
        with self.assertRaises(ValueError):
            metrics.parse(b'x' * (metrics.LIMIT + 1))
        self.assertEqual(metrics.parse(b'\xef\xbb\xbfNOTES="legacy"')['NOTES'], 'legacy')

    def test_plan_does_not_open_store_or_read_stdin(self):
        with patch.object(metrics, 'store') as store, patch.object(sys, 'stdin') as stdin, \
                contextlib.redirect_stdout(io.StringIO()):
            for args in ([], ['--dry-run'], ['edit'], ['init'], ['merge', '--apply', '--dry-run']):
                self.assertEqual(metrics.main(args), 0)
            store.assert_not_called()
            stdin.read.assert_not_called()
            stdin.buffer.read.assert_not_called()

    def test_no_source_fixed_editor_path_or_direct_metrics_replacement(self):
        self.assertNotIn('source "$METRICS_CONFIG_FILE"', SETUP)
        self.assertNotIn('/tmp/metrics_config_edit', SETUP)
        self.assertNotIn('mv "$tmp_metrics_file" "$METRICS_CONFIG_FILE"', SETUP)
        status = (ROOT / 'scripts/helpers/status_tracking.sh').read_text(encoding='utf-8')
        self.assertIn('STATUS_HELPER_INSTALL_DIR=', status)
        self.assertIn('merge --file "$STATUS_HELPER_METRICS_CONFIG_FILE" --apply', status)


@unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash required; no WSL fallback')
class LoaderFixtures(unittest.TestCase):
    def bash(self, source):
        env = os.environ.copy()
        env.update(BASH_ENV=os.devnull, ENV=os.devnull)
        result = subprocess.run([BASH, '--noprofile', '--norc', '-s'], input=source,
                                capture_output=True, text=True, env=env, timeout=20)
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_loader_assigns_literal_data_without_eval(self):
        loader = SETUP[SETUP.index('load_metrics_config()'):SETUP.index('is_preference_enabled()')]
        payload = '$(printf BAD)'
        self.bash('set -euo pipefail\n' + loader + '\n' +
                  'ensure_metrics_config() { :; }\nINSTALL_DIR=/fixture\nMETRICS_CONFIG_FILE=/fixture/unused\n' +
                  'python3() { printf "NOTES\\t%s\\nSETUP_INSTALL_TIME_ESTIMATE\\t20 min\\n" ' +
                  shlex.quote(payload) + '; }\nload_metrics_config\n[[ "$NOTES" == ' +
                  shlex.quote(payload) + ' ]]\n[[ "$SETUP_INSTALL_TIME_ESTIMATE" == "20 min" ]]\n')

    def test_parser_failure_does_not_partially_assign_globals(self):
        loader = SETUP[SETUP.index('load_metrics_config()'):SETUP.index('is_preference_enabled()')]
        self.bash('set -euo pipefail\n' + loader + '\n' +
                  'ensure_metrics_config() { :; }\nINSTALL_DIR=/fixture\nMETRICS_CONFIG_FILE=/fixture/unused\n' +
                  'NOTES=preserved\npython3() { printf "NOTES\\tbad\\n"; return 1; }\n' +
                  'if load_metrics_config; then exit 99; fi\n[[ "$NOTES" == preserved ]]\n')

    def test_editor_cancel_never_reaches_write_action(self):
        editor = SETUP[SETUP.index('show_metrics_editor()'):SETUP.index('load_metrics_config()')]
        self.bash('set -euo pipefail\n' + editor + '\n' +
                  'ensure_metrics_config() { :; }\nINSTALL_DIR=/fixture\nMETRICS_CONFIG_FILE=/fixture/unused\n' +
                  'APP_TITLE=fixture\n' +
                  'python3() { [[ "$4" == check ]] || return 99; printf "%064d\\n" 1; }\n' +
                  'dialog() { return 1; }\nshow_metrics_editor\n')


@unittest.skipUnless(os.name == 'posix', 'Native POSIX dirfd/flock required; no WSL fallback')
class PrivateStore(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.path = self.root / 'setup_metrics.conf'

    def invoke(self, action, data=b'', *args):
        with patch.object(sys, 'stdin', io.TextIOWrapper(io.BytesIO(data))), \
                contextlib.redirect_stdout(io.StringIO()) as out, \
                contextlib.redirect_stderr(io.StringIO()) as err:
            status = metrics.main([action, '--file', str(self.path), *args])
        return status, out.getvalue(), err.getvalue()

    def init(self):
        self.assertEqual(self.invoke('init', DEFAULT, '--apply')[0], 0)
        self.assertEqual(self.path.stat().st_mode & 0o777, 0o600)

    def test_init_preserves_existing_and_read_never_executes(self):
        self.init()
        old = self.path.read_bytes()
        self.assertEqual(self.invoke('init', b'NOTES="not adopted"', '--apply')[0], 0)
        self.assertEqual(self.path.read_bytes(), old)
        self.assertEqual(self.invoke('read')[0], 0)

    def test_read_and_check_do_not_create_lock_or_change_legacy_mode(self):
        self.path.write_bytes(DEFAULT)
        self.path.chmod(0o644)
        self.assertEqual(self.invoke('read')[0], 0)
        self.assertEqual(self.invoke('check')[0], 0)
        self.assertEqual(self.path.stat().st_mode & 0o777, 0o644)
        self.assertFalse((self.root / '.setup-metrics.lock').exists())

    def test_editor_updates_atomically_and_rejects_stale_revision(self):
        self.init()
        revision = hashlib.sha256(self.path.read_bytes()).hexdigest()
        updated = b'NOTES="edited"\n'
        self.assertEqual(self.invoke('edit', updated, '--apply', '--expected-sha', revision)[0], 0)
        self.assertEqual(self.path.read_bytes(), updated)
        self.assertEqual(self.invoke('edit', DEFAULT, '--apply', '--expected-sha', revision)[0], 1)
        self.assertEqual(self.path.read_bytes(), updated)
        self.assertFalse(list(self.root.glob('.metrics-pending-*')))

    def test_bad_input_never_changes_original_or_leaks_payload(self):
        self.init()
        old = self.path.read_bytes()
        status, out, err = self.invoke('merge', b'NOTES="$(synthetic-secret)"', '--apply')
        self.assertEqual(status, 1)
        self.assertNotIn('synthetic-secret', out + err)
        self.assertEqual(self.path.read_bytes(), old)

    def test_file_links_and_unsafe_modes_are_rejected(self):
        peer = self.root / 'peer'
        peer.write_bytes(DEFAULT)
        peer.chmod(0o600)
        self.path.symlink_to(peer)
        self.assertEqual(self.invoke('read')[0], 1)
        self.path.unlink()
        os.link(peer, self.path)
        self.assertEqual(self.invoke('read')[0], 1)
        self.path.unlink()
        self.init()
        self.path.chmod(0o666)
        self.assertEqual(self.invoke('read')[0], 1)
        self.assertEqual(self.path.stat().st_mode & 0o777, 0o666)
        self.assertEqual(peer.read_bytes(), DEFAULT)

    def test_busy_lock_rejects_without_overwrite_then_merges(self):
        self.init()
        old = self.path.read_bytes()
        with metrics.store(self.path):
            self.assertEqual(self.invoke('merge', b'LAST_TOOL_A_STATUS="success"\n', '--apply')[0], 1)
            self.assertEqual(self.path.read_bytes(), old)
        self.assertEqual(self.invoke('merge', b'LAST_TOOL_A_STATUS="success"\n', '--apply')[0], 0)
        self.assertEqual(self.invoke('merge', b'LAST_TOOL_B_STATUS="success"\n', '--apply')[0], 0)
        rows = metrics.parse(self.path.read_bytes())
        self.assertIn('LAST_TOOL_A_STATUS', rows)
        self.assertIn('LAST_TOOL_B_STATUS', rows)


if __name__ == '__main__':
    unittest.main()
