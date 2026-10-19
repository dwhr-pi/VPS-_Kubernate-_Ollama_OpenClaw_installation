"""Temporary marker/status fixtures only; no real installer or WSL."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')
REPORTED = ('ChatTTS', 'AudioLDM2', 'AudioGen', 'Moshi', 'MOSS_TTS', 'YuE',
            'ACE_Step_15', 'WhisperX', 'Aegisub', 'Basic_Pitch', 'Sfizz',
            'AIDA_X', 'Kiwi_Edit', 'VOID_Model', 'Just_Dub_It', 'Claude_Code', 'Gemini_CLI')


@unittest.skipUnless(BASH, 'Bash unavailable')
class MediaStatus(unittest.TestCase):
    def shell(self, code):
        with tempfile.TemporaryDirectory() as tmp:
            path = str(Path(tmp) / 'private').replace('\\', '/')
            if os.name == 'nt':
                path = '/' + path[0].lower() + path[2:]
            script = 'set -euo pipefail\nsource scripts/helpers/native_tool_status.sh\nroot="' + path + '"\n' + code
            return subprocess.run([BASH, '--noprofile', '--norc', '-c', script], cwd=ROOT,
                                  capture_output=True, text=True, encoding='utf-8', timeout=180)

    def test_registry_and_marker_mapping_agree(self):
        r = self.shell('for tool in "${NATIVE_TOOL_STATUS_KEYS[@]}"; do native_tool_marker "$tool" >/dev/null; printf "%s|%s\\n" "$tool" "$NATIVE_TOOL_MARKER"; done')
        self.assertEqual(r.returncode, 0, r.stderr)
        mappings = dict(line.split('|', 1) for line in r.stdout.splitlines())
        registry = {t['name']: t for t in json.loads((ROOT / 'config/tools.yml').read_text())['tools']}
        for name in REPORTED:
            self.assertIn(name, mappings)
        for name, marker in mappings.items():
            self.assertEqual(registry[name]['check_value'], '~/.openclaw_ultimate_user_data/tools/' + marker, name)

    def test_all_markers_enable_uninstall_and_removed_markers_stay_removed(self):
        r = self.shell('''
mkdir -p "$root/status"
printf 'Other\n\n' > "$root/installed_tools.txt"
printf 'Other\n' > "$root/status/installed_tools.txt"
git() { exit 99; }; curl() { exit 99; }; pip() { exit 99; }
markers=(); dirs=()
for tool in "${NATIVE_TOOL_STATUS_KEYS[@]}"; do
    native_tool_marker "$tool" >/dev/null
    marker="$root/tools/$NATIVE_TOOL_MARKER"
    markers+=("$marker"); dirs+=("${marker%/*}")
done
mkdir -p "${dirs[@]}"
for marker in "${markers[@]}"; do printf 'synthetic-pin\n' > "$marker"; done
native_tool_sync_all "$root"
for file in "$root/installed_tools.txt" "$root/status/installed_tools.txt"; do
    mapfile -t entries < "$file"
    for tool in Other "${NATIVE_TOOL_STATUS_KEYS[@]}"; do
        count=0
        for entry in "${entries[@]}"; do if [[ "$entry" == "$tool" ]]; then count=$((count + 1)); fi; done
        test "$count" = 1
    done
done
rm -- "${markers[@]}"
native_tool_sync_all "$root"
native_tool_sync_all "$root"
for file in "$root/installed_tools.txt" "$root/status/installed_tools.txt"; do
    mapfile -t entries < "$file"
    other=0
    for entry in "${entries[@]}"; do
        if [[ "$entry" == Other ]]; then other=1; else test -z "$entry"; fi
    done
    test "$other" = 1
done
test -d "$root/tools/chattts"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_coding_sources_register_in_both_lists_and_deactivate(self):
        r = self.shell('''
mkdir -p "$root/tools/claude_code" "$root/tools/gemini_cli/source" "$root/status"
printf 'Other\\n"Claude_Code"\\r\\nClaude_Code\\nGemini_CLI\\n' > "$root/installed_tools.txt"
printf 'Other\\n' > "$root/status/installed_tools.txt"
printf '{"commit":"fixture","runtime_ready":false}\\n' > "$root/tools/claude_code/source-ready.json"
# An incomplete clone without marker must not count as installed.
native_tool_sync_all "$root"
for file in "$root/installed_tools.txt" "$root/status/installed_tools.txt"; do
    test "$(grep -Fxc Claude_Code "$file")" = 1
    ! grep -Fxq Gemini_CLI "$file"
    grep -Fxq Other "$file"
done
printf '{"commit":"fixture","runtime_ready":false}\\n' > "$root/tools/gemini_cli/source-ready.json"
native_tool_sync_status Gemini_CLI "$root"
for file in "$root/installed_tools.txt" "$root/status/installed_tools.txt"; do
    test "$(grep -Fxc Gemini_CLI "$file")" = 1
done
rm -- "$root/tools/claude_code/source-ready.json" "$root/tools/gemini_cli/source-ready.json"
native_tool_sync_all "$root"
for file in "$root/installed_tools.txt" "$root/status/installed_tools.txt"; do
    ! grep -Fxq Claude_Code "$file"
    ! grep -Fxq Gemini_CLI "$file"
    grep -Fxq Other "$file"
done
test -d "$root/tools/gemini_cli/source"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_empty_marker_or_folder_does_not_mean_installed(self):
        r = self.shell('''
mkdir -p "$root/tools/chattts" "$root/tools/just_dub_it"
touch "$root/tools/chattts/source-built"
printf '"ChatTTS"\\r\\nJust_Dub_It\\n' > "$root/installed_tools.txt"
JUST_DUB_IT_ACCEPT_LICENSE=1 native_tool_sync_all "$root"
! grep -Fxq ChatTTS "$root/installed_tools.txt"
! grep -Fxq Just_Dub_It "$root/installed_tools.txt"
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_batch_writes_at_most_two_files_and_preserves_unchanged_files(self):
        r = self.shell('''
writes=0
mv() { writes=$((writes + 1)); command mv "$@"; }
native_tool_sync_all "$root"
test "$writes" = 2
native_tool_sync_all "$root"
test "$writes" = 2
''')
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_menu_refreshes_before_each_map_load(self):
        menu = (ROOT / 'setup_ultimate.sh').read_text(encoding='utf-8')
        for name in ('show_tool_group_checklist', 'toggle_tool_group_bulk'):
            body = menu.split(name + '() {', 1)[1].split('\n}', 1)[0]
            self.assertLess(body.index('native_tool_sync_all'), body.index('load_installed_map'))
        install = menu.split('install_tool() {', 1)[1].split('uninstall_tool() {', 1)[0]
        self.assertIn('native_tool_marker "$TOOL_KEY"', install)

    def test_unknown_name_is_not_silently_aliased(self):
        r = self.shell('if native_tool_sync_status MoshiTTS "$root"; then exit 99; fi; test ! -e "$root/installed_tools.txt"')
        self.assertEqual(r.returncode, 0, r.stderr)


if __name__ == '__main__':
    unittest.main()
