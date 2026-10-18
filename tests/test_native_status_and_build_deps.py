"""Offline fixtures and mocked package manager only; never accesses WSL."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')


@unittest.skipUnless(BASH, 'Bash unavailable')
class NativeStatus(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            path = tmp.replace('\\', '/')
            if os.name == 'nt':
                path = '/' + path[0].lower() + path[2:]
            return subprocess.run([BASH, '--noprofile', '--norc', '-c',
                                   'set -e\nexport HOME="' + path + '"\n' + code],
                                  cwd=ROOT, capture_output=True, text=True, timeout=40)

    def test_markers_repair_both_files_and_deactivation_does_not_resurrect(self):
        result = self.shell('''
source scripts/helpers/native_tool_status.sh
root="$HOME/private"
mkdir -p "$root/tools/wan21" "$root/tools/windmill" "$root/status"
printf 'Wan21\nOther\n' > "$root/installed_tools.txt"
printf 'Wan21\nOther\n' > "$root/status/installed_tools.txt"
echo synthetic > "$root/tools/windmill/source-ready"
native_tool_sync_status Wan21 "$root"
native_tool_sync_status Windmill "$root"
for file in "$root/installed_tools.txt" "$root/status/installed_tools.txt"; do
    ! grep -Fxq Wan21 "$file"
    grep -Fxq Windmill "$file"
    grep -Fxq Other "$file"
done
rm "$root/tools/windmill/source-ready"
native_tool_sync_status Windmill "$root"
native_tool_sync_status Windmill "$root"
! grep -Fxq Windmill "$root/status/installed_tools.txt"
! grep -Fxq Windmill "$root/installed_tools.txt"
test -d "$root/tools/windmill"
''')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_no_legacy_import_for_existing_empty_primary(self):
        menu = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        self.assertIn('if [ ! -f "$TOOL_STATUS_FILE" ] &&', menu)
        self.assertNotIn('if [ ! -s "$TOOL_STATUS_FILE" ] &&', menu)
        self.assertIn('native_tool_sync_status "$TOOL_KEY"', menu)
        self.assertIn('remove_exact_line "$USER_STATUS_DIR/installed_tools.txt" "$TOOL_KEY"', menu)

    def deps(self, body):
        return self.shell('''
source scripts/tools/helpers/deepfilternet_common.sh
installed=0
command() {
    if [[ "$1" == -v ]]; then
        case "$2" in cargo|rustc) [[ "$installed" == 1 ]]; return $? ;; esac
        return 0
    fi
    builtin command "$@"
}
df_install_base_packages() {
    [[ "$*" == 'cargo rustc' ]] || return 98
    installed=1
}
''' + body)

    def test_explicit_consent_installs_only_missing_packages(self):
        result = self.deps('DEEPFILTERNET_INSTALL_BUILD_DEPS=1 df_prepare_build_tools; test "$installed" == 1')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_disabled_never_installs(self):
        result = self.deps('if DEEPFILTERNET_INSTALL_BUILD_DEPS=0 df_prepare_build_tools; then exit 97; fi; test "$installed" == 0')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_noninteractive_default_does_not_install(self):
        result = self.deps('if df_prepare_build_tools </dev/null; then exit 97; fi; test "$installed" == 0')
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_package_failure_propagates(self):
        result = self.deps('df_install_base_packages() { return 23; }; DEEPFILTERNET_INSTALL_BUILD_DEPS=1 df_prepare_build_tools')
        self.assertEqual(result.returncode, 23, result.stderr)

    def test_existing_rustup_path_is_recognized_without_install(self):
        result = self.shell('''
source scripts/tools/helpers/deepfilternet_common.sh
mkdir -p "$HOME/.cargo/bin"
printf '#!/usr/bin/env bash\\nexit 99\\n' > "$HOME/.cargo/bin/cargo"
printf '#!/usr/bin/env bash\\nexit 99\\n' > "$HOME/.cargo/bin/rustc"
chmod +x "$HOME/.cargo/bin/cargo" "$HOME/.cargo/bin/rustc"
command() { [[ "$1" == -v ]] && return 0; builtin command "$@"; }
df_install_base_packages() { exit 99; }
df_prepare_build_tools
[[ "$PATH" == "$HOME/.cargo/bin:"* ]]
''')
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == '__main__':
    unittest.main()
