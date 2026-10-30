"""Offline shell fragments only: no installer, dependency, service or network start."""
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


@unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash required; never launch WSL')
class ShellErrorContracts(unittest.TestCase):
    def run_fragment(self, text, *args):
        return subprocess.run(
            [BASH, '--noprofile', '--norc', '-c', text, 'fixture', *map(str, args)],
            cwd=ROOT, text=True, encoding='utf-8', capture_output=True, timeout=15,
            env={key: value for key, value in os.environ.items()
                 if key not in ('BASH_ENV', 'ENV', 'SHELLOPTS', 'BASHOPTS')},
        )

    def test_exit_handlers_preserve_success_failure_and_interrupt_status(self):
        handlers = []
        for path in sorted((ROOT / 'scripts/tools/helpers').glob('*.sh')):
            text = path.read_text(encoding='utf-8')
            handlers.extend((path.name, match.group(1)) for match in re.finditer(
                r"^  local rc\n  (trap 'rc=\$\?;[^\n]+' EXIT)$", text, re.MULTILINE))
        self.assertGreaterEqual(len(handlers), 36)
        for name, handler in handlers:
            fragment = '\n'.join((
                'set -u', 'df() { :; }', 'scenario() (', 'set -eu',
                'local rc log=fixture started=0 before=0 mount=/', handler,
                'exit "$1"', ')',
                'for expected in 0 17 130; do',
                'scenario "$expected"', 'actual=$?',
                '[[ "$actual" == "$expected" ]] || exit 99',
                'printf "\\nCHECK:%s\\n" "$actual"', 'done',
            ))
            with self.subTest(helper=name):
                result = self.run_fragment(fragment)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(re.findall(r'^CHECK:(\d+)$', result.stdout, re.MULTILINE), ['0', '17', '130'])
                self.assertNotIn('unbound variable', result.stderr)

    def test_qwen_build_and_source_checks_both_gate_status(self):
        source = (ROOT / 'scripts/tools/helpers/qwen_code_common.sh').read_text(encoding='utf-8')
        predicate = re.search(
            r'^\s*(\{ qwen_code_is_built && qwen_code_verify_source; \}) \|\| \{',
            source, re.MULTILINE)
        self.assertIsNotNone(predicate)
        fragment = '\n'.join((
            'set -eu',
            'qwen_code_is_built() { printf first; return "$FIRST"; }',
            'qwen_code_verify_source() { printf second; return "$SECOND"; }',
            'FIRST=$1 SECOND=$2', predicate.group(1) + ' || { printf denied; exit 1; }',
            'printf allowed',
        ))
        for first, second, expected, status in (
            (0, 0, 'firstsecondallowed', 0),
            (17, 0, 'firstdenied', 1),
            (0, 17, 'firstseconddenied', 1),
            (17, 17, 'firstdenied', 1),
        ):
            with self.subTest(first=first, second=second):
                result = self.run_fragment(fragment, first, second)
                self.assertEqual((result.stdout, result.returncode), (expected, status), result.stderr)

    def test_binary_wheel_package_list_is_one_argument(self):
        for name in ('basic_pitch', 'whisperx'):
            text = (ROOT / 'scripts/tools/helpers' / (name + '_common.sh')).read_text(encoding='utf-8')
            line = next(line.strip() for line in text.splitlines() if 'options=(--constraint ' in line)
            args = shlex.split(line.removeprefix('options=(').removesuffix(')'))
            self.assertEqual(len(args), 3)
            self.assertTrue(args[-1].startswith('--only-binary='))
            self.assertIn(',', args[-1])

    def test_failed_directory_change_cannot_continue_build_or_mark_success(self):
        files = ('clawbake', 'activepieces', 'openclaw_rl', 'clawhub_cli', 'langflow', 'zenbot_trader')
        paths = [ROOT / 'scripts/tools' / (name + '_install.sh') for name in files]
        paths.append(ROOT / 'scripts/base_install.sh')
        for path in paths:
            text = path.read_text(encoding='utf-8')
            guards = re.findall(r'^\s*(cd (?:"\$[A-Z_]+"|/) \|\| exit 1)$', text, re.MULTILINE)
            self.assertTrue(guards, path.name)
            with self.subTest(installer=path.name):
                fragment = '\n'.join((
                    'set -eu', 'cd() { return 17; }',
                    'TARGET=/nonexistent',
                    re.sub(r'"\$[A-Z_]+"', '"$TARGET"', guards[0]),
                    'printf unexpected-success',
                ))
                result = self.run_fragment(fragment)
                self.assertEqual((result.returncode, result.stdout), (1, ''), result.stderr)

    def test_pause_input_preserves_literal_backslashes(self):
        source = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        self.assertNotRegex(source, r'(?m)^\s*read -p ')
        result = subprocess.run(
            [BASH, '--noprofile', '--norc', '-c', 'read -r value; printf "%s" "$value"'],
            input=b'a\\b\n', capture_output=True, timeout=15,
            env={key: value for key, value in os.environ.items() if key not in ('BASH_ENV', 'ENV')},
        )
        self.assertEqual((result.returncode, result.stdout), (0, b'a\\b'), result.stderr)


if __name__ == '__main__':
    unittest.main()
