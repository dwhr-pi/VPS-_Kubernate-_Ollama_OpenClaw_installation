"""Offline-Speicherwaeche mit simulierten Kapazitaeten, ohne Installer oder WSL."""
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if sys.platform == 'win32' else shutil.which('bash')


@unittest.skipUnless(BASH and Path(BASH).is_file(), 'Bash erforderlich')
class TraefikStorageTests(unittest.TestCase):
    def run_functions(self, script):
        setup = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        names = ('get_tool_install_fallback_min_free_mb', 'get_tool_install_min_free_mb',
                 'get_tool_install_windows_min_free_mb', 'preflight_tool_install_storage')
        functions = '\n'.join(re.search(r'^' + name + r'\(\) \{\n.*?^\}', setup, re.M | re.S).group()
                              for name in names)
        stubs = '''
YELLOW= RED= GREEN= NC= WINDOWS_HOST_DRIVE=C
MEASURED=0
get_tool_install_measured_mb() { printf '%s' "$MEASURED"; }
get_free_disk_kb() { printf '1000000000'; }
is_wsl_environment() { return 0; }
get_windows_host_free_kb() { printf '%s' "$((HOST_MB * 1024))"; }
format_kb_human() { printf '%s KiB' "$1"; }
'''
        # Git-Bash-Forks sind unter Windows deutlich langsamer als unter Linux.
        timeout = 120 if sys.platform == 'win32' else 30
        result = subprocess.run([BASH, '--noprofile', '--norc', '-s'],
                                input='set -euo pipefail\n' + functions + stubs + script,
                                cwd=ROOT, capture_output=True, text=True, encoding='utf-8', timeout=timeout)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout

    def test_menu_reserves_match_native_recipes(self):
        output = self.run_functions('''
for key in Traefik OpenTelemetry; do
  printf '%s:%s\\n' "$key" "$(get_tool_install_fallback_min_free_mb "$key")"
done
''')
        values = dict(line.split(':') for line in output.splitlines())
        manifest = json.loads((ROOT / 'config/docker_to_github.json').read_text(encoding='utf-8'))
        for spec in manifest['tools']:
            if spec['tool_key'] in values:
                self.assertEqual(int(values[spec['tool_key']]), spec['recipe']['disk_mb'])
        self.assertEqual(values, {'Traefik': '16384', 'OpenTelemetry': '8192'})

    def test_traefik_rejects_reported_host_space_and_checks_exact_boundary(self):
        output = self.run_functions('''
for HOST_MB in 10146 16383 16384; do
  rc=0
  preflight_tool_install_storage Traefik || rc=$?
  printf 'RESULT:%s:%s\\n' "$HOST_MB" "$rc"
done
''')
        self.assertIn('Fehlend: mindestens 6238 MiB', output)
        self.assertIn('RESULT:10146:1', output)
        self.assertIn('RESULT:16383:1', output)
        self.assertIn('RESULT:16384:0', output)

    def test_opentelemetry_uses_same_host_reserve_as_its_native_recipe(self):
        output = self.run_functions('''
for HOST_MB in 8191 8192; do
  rc=0
  preflight_tool_install_storage OpenTelemetry || rc=$?
  printf 'RESULT:%s:%s\\n' "$HOST_MB" "$rc"
done
''')
        self.assertIn('RESULT:8191:1', output)
        self.assertIn('RESULT:8192:0', output)

    def test_measurements_never_lower_the_native_minimum(self):
        output = self.run_functions('''
for MEASURED in 0 1 20000; do
  printf 'MIN:%s:%s\\n' "$MEASURED" "$(get_tool_install_min_free_mb Traefik)"
done
''')
        self.assertEqual(output.splitlines(), ['MIN:0:16384', 'MIN:1:16384', 'MIN:20000:31024'])


if __name__ == '__main__':
    unittest.main()
