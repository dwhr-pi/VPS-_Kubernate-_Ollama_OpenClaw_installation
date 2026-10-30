"""Large offline fixture reports must not fail because a display limit closes a pipe."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


@unittest.skipUnless(BASH and Path(BASH).is_file(), 'Native Bash required; never start WSL')
class LifecycleReportLimit(unittest.TestCase):
    def test_large_report_is_truncated_without_hiding_strict_failure(self):
        with tempfile.TemporaryDirectory(prefix='lifecycle-report-') as directory:
            root = Path(directory)
            tools = root / 'scripts/tools'
            tools.mkdir(parents=True)
            checker = root / 'scripts/check_tool_lifecycle.sh'
            shutil.copyfile(ROOT / 'scripts/check_tool_lifecycle.sh', checker)
            for index in range(500):
                (tools / (f'fixture_{index:04d}_' + 'x' * 50 + '_install.sh')).touch()
            env = {key: value for key, value in os.environ.items()
                   if key not in ('BASH_ENV', 'ENV', 'SHELLOPTS', 'BASHOPTS')}
            env['MAX_REPORT'] = '3'
            for args, expected in (([], 0), (['--strict'], 1)):
                with self.subTest(args=args):
                    result = subprocess.run(
                        [BASH, '--noprofile', '--norc', checker.as_posix(), *args],
                        cwd=root, env=env, capture_output=True, text=True,
                        encoding='utf-8', timeout=90,
                    )
                    self.assertEqual(result.returncode, expected, result.stderr)
                    self.assertIn('2500 Lifecycle-Dateien fehlen', result.stdout)
                    self.assertEqual(sum(line.startswith('FEHLT ') for line in result.stdout.splitlines()), 3)
                    self.assertIn('weitere Eintraege ausgeblendet', result.stdout)


if __name__ == '__main__':
    unittest.main()
