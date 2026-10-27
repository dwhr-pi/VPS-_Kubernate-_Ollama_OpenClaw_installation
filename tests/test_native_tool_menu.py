"""Exercise actual menu registration with Bash, without starting the setup."""
import json
from pathlib import Path
import re
import shlex
import shutil
import subprocess
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
BASH = "C:/Program Files/Git/bin/bash.exe" if sys.platform == "win32" else shutil.which("bash")
REQUESTED = ("Appsmith", "ArchiveBox", "Argilla", "Budibase", "Caddy", "Changedetection_IO",
             "CrowdSec", "Directus", "Forgejo", "Nextcloud", "NocoDB", "Penpot", "Promtail",
             "Rhasspy", "SearXNG", "Vikunja", "Watchtower")


@unittest.skipUnless(BASH and Path(BASH).is_file(), "Native Bash unavailable")
class NativeToolMenuTests(unittest.TestCase):
    def setUp(self):
        self.setup = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.specs = json.loads((ROOT / "config/docker_to_github.json").read_text(encoding="utf-8"))["tools"]

    def shell(self, command):
        result = subprocess.run([BASH, "--noprofile", "--norc", "-s"], input="set -euo pipefail\n" + command,
                                cwd=ROOT, capture_output=True, text=True, timeout=60)
        self.assertEqual(result.returncode, 0, result.stderr)
        return result.stdout.splitlines()

    def menu(self):
        names = []
        for array in re.findall(r"^TOOL_KEYS\+?=\(([^\n]*)\)", self.setup, re.M):
            names.extend(shlex.split(array))
        # These entries are assigned in the real metadata block below.
        names = [name for name in names if name not in ("PyAirbyte", "GitOps_Bootstrap")]
        block = self.setup.split("# Native migration metadata overrides older Docker descriptions only.\n", 1)[1].split("# Hauptschleife", 1)[0]
        sort = re.search(r"^sort_tool_menu_keys\(\) \{\n.*?^\}", self.setup, re.M | re.S).group()
        return ('source scripts/helpers/native_github_menu.sh\n'
                'declare -A TOOLS=() TOOL_SCRIPT_NAMES=()\n'
                'TOOL_KEYS=(' + " ".join(map(shlex.quote, names)) + ')\n' + block + '\n' + sort + '\nsort_tool_menu_keys\n')

    def test_all_native_recipes_are_really_selectable_with_dispatch_and_description(self):
        command = self.menu() + 'for key in "${TOOL_KEYS[@]}"; do printf "%s\\n" "$key"; done\n'
        result = self.shell(command)
        self.assertEqual(len(result), len(set(result)))
        self.assertTrue(set(REQUESTED).issubset(result))
        self.assertIn("Zigbee2MQTT", result)
        self.assertTrue({spec["tool_key"] for spec in self.specs}.issubset(result))
        command = self.menu() + 'for key in "${NATIVE_GITHUB_TOOL_KEYS[@]}"; do printf "%s\\t%s\\t%s\\n" "$key" "${TOOL_SCRIPT_NAMES[$key]}" "${TOOLS[$key]}"; done\n'
        rows = [line.split("\t", 2) for line in self.shell(command)]
        self.assertEqual(len(rows), len(self.specs))
        aliases = {spec["tool_key"]: spec["id"] for spec in self.specs}
        for key, slug, description in rows:
            self.assertEqual(aliases[key], slug)
            self.assertTrue(description)
            for action in ("install", "uninstall", "update", "status", "doctor", "check"):
                self.assertTrue((ROOT / "scripts/tools" / (slug + "_" + action + ".sh")).is_file())

    def test_registration_is_idempotent_and_preserves_existing_order_and_selection(self):
        command = ('source scripts/helpers/native_github_menu.sh\n'
                   'TOOL_KEYS=(Ollama OpenClaw Ruflo Rhasspy Caddy PyAirbyte)\n'
                   'register_native_github_tool_keys\n'
                   'before="$(printf "%s\\n" "${TOOL_KEYS[@]}")"\n'
                   'register_native_github_tool_keys\n'
                   '[[ "$before" == "$(printf "%s\\n" "${TOOL_KEYS[@]}")" ]]\n'
                   'printf "%s\\n" "${TOOL_KEYS[@]}"')
        result = self.shell(command)
        self.assertEqual(result[:6], ["Ollama", "OpenClaw", "Ruflo", "Rhasspy", "Caddy", "PyAirbyte"])
        self.assertEqual(len(result), len(set(result)))
        self.assertEqual(len(result), len(self.specs) + 3)

    def test_status_allowlist_and_direct_script_normalization_use_same_keys(self):
        result = self.shell('source scripts/helpers/native_tool_status.sh\nprintf "%s\\n" "${NATIVE_GITHUB_TOOL_KEYS[@]}"')
        self.assertCountEqual(result, [spec["tool_key"] for spec in self.specs])
        tracking = (ROOT / "scripts/helpers/status_tracking.sh").read_text(encoding="utf-8")
        self.assertIn('/native_github_menu.sh"', tracking)
        self.assertLess(tracking.index("register_native_github_tool_keys"), tracking.index("normalize_status_file()"))

    def test_labels_preserve_blockers_and_ordering(self):
        result = self.shell(self.menu() + 'printf "%s\\n" "${TOOL_KEYS[@]}"')
        self.assertEqual(result[:3], ["Ollama", "OpenClaw", "Ruflo"])
        self.assertLess(result.index("Caddy"), result.index("CrowdSec"))
        labels = self.shell(self.menu() + 'printf "%s\\n" "${TOOLS[Rhasspy]}" "${TOOLS[Promtail]}" "${TOOLS[Watchtower]}"')
        self.assertIn("OFFEN", labels[0])
        self.assertIn("EOL", labels[1])
        self.assertIn("Docker-API", labels[2])
        native_status = (ROOT / "scripts/helpers/native_tool_status.sh").read_text(encoding="utf-8")
        self.assertIn('NATIVE_TOOL_STATUS_KEYS+=("${NATIVE_GITHUB_TOOL_KEYS[@]}")', native_status)


if __name__ == "__main__":
    unittest.main()
