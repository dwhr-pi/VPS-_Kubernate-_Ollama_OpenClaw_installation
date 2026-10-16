"""Offline tests for the setup integration; no upstream runtime is imported."""
import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("automaton_review", ROOT / "tools/automaton/review.py")
review = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(review)


class AutomatonTests(unittest.TestCase):
    def setUp(self):
        self.proposal = json.loads((ROOT / "examples/automaton/review-proposal.json").read_text())

    def invoke(self, args):
        stdout, stderr = io.StringIO(), io.StringIO()
        with contextlib.redirect_stdout(stdout), contextlib.redirect_stderr(stderr):
            code = review.main(args)
        return code, stdout.getvalue(), stderr.getvalue()

    def test_valid_proposal_never_authorizes_execution(self):
        result = review.validate(self.proposal)
        self.assertFalse(result["approved_for_execution"])
        self.assertFalse(result["executed"])
        self.assertEqual(result["decision"], "manual_review_required")

    def test_write_signing_and_network_rejected(self):
        for flag in ("requires_network", "requires_signing", "requires_write"):
            with self.subTest(flag=flag), self.assertRaises(ValueError):
                review.validate({**self.proposal, flag: True})

    def test_string_false_is_not_false(self):
        with self.assertRaises(ValueError):
            review.validate({**self.proposal, "requires_signing": "false"})

    def test_turn_and_retry_limits(self):
        for field, value in (("max_turns", 11), ("max_turns", 0), ("max_turns", True),
                             ("retry_limit", 3), ("retry_limit", -1)):
            with self.subTest(field=field, value=value), self.assertRaises(ValueError):
                review.validate({**self.proposal, field: value})

    def test_no_generic_command_or_key_input(self):
        for extra in ({"command": "not-executed"}, {"private_key": "fixture-not-a-key"}):
            with self.assertRaises(ValueError):
                review.validate({**self.proposal, **extra})

    def test_trade_or_provisioning_rejected(self):
        for action in ("trade", "transfer", "sign", "spawn", "flash_firmware"):
            with self.subTest(action=action), self.assertRaises(ValueError):
                review.validate({**self.proposal, "action": action})

    def test_all_runtime_actions_blocked_no_home_created(self):
        with tempfile.TemporaryDirectory() as temp:
            home = Path(temp) / "isolated-home"
            with patch.dict(os.environ, {"HOME": str(home)}):
                for mode in ("install", "update", "uninstall", "repair", "run"):
                    self.assertEqual(self.invoke([mode])[0], 2)
            self.assertFalse(home.exists())

    def test_check_scope_does_not_claim_installed(self):
        for mode in ("plan", "status", "check", "doctor"):
            code, output, _ = self.invoke([mode])
            self.assertEqual(code, 0)
            result = json.loads(output)
            self.assertFalse(result["installed"])
            self.assertFalse(result["runtime_enabled"])
            self.assertEqual(result["check_scope"], "integration_assets_only")

    def test_cli_rejects_without_disclosing_contents(self):
        with tempfile.TemporaryDirectory() as temp:
            proposal = Path(temp) / "proposal.json"
            proposal.write_text('{"private_key":"fixture-do-not-print"}')
            code, out, err = self.invoke(["review", str(proposal)])
        self.assertEqual(code, 1)
        self.assertNotIn("fixture-do-not-print", out + err)

    def test_review_example(self):
        code, output, _ = self.invoke(["review", str(ROOT / "examples/automaton/review-proposal.json")])
        self.assertEqual(code, 0)
        self.assertFalse(json.loads(output)["executed"])

    def test_registry_and_menu(self):
        tools = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
        tool, = [entry for entry in tools if entry["id"] == "automaton"]
        self.assertEqual(tool["status"], "experimental")
        self.assertEqual(tool["install_mode"], "source")
        self.assertEqual(tool["check_type"], "path")
        self.assertEqual(tool["risk"], "high")
        self.assertEqual(tool["source_commit"], review.SOURCE_COMMIT)
        self.assertEqual(tool["ports"], [])
        for key in ("install_script", "uninstall_script", "update_script", "doctor_script", "doc"):
            self.assertTrue((ROOT / tool[key]).is_file())
        menu = (ROOT / "setup_ultimate.sh").read_text(encoding="utf-8")
        self.assertIn('TOOL_KEYS+=("Automaton")', menu)
        self.assertIn('TOOL_SCRIPT_NAMES["Automaton"]="automaton"', menu)
        profiles = json.loads((ROOT / "config/profiles.yml").read_text(encoding="utf-8"))["profiles"]
        self.assertFalse(any("automaton" in entry.get("tools", []) for entry in profiles))

    def test_documentation_links(self):
        doc = ROOT / "docs/tools/automaton.md"
        for link in re.findall(r'\]\(([^)]+)\)', doc.read_text(encoding="utf-8")):
            if "://" not in link and not link.startswith("#"):
                self.assertTrue((doc.parent / link.split("#")[0]).exists(), link)


class AutomatonSourceTests(unittest.TestCase):
    def shell(self, script, workspace):
        bash = 'C:/Program Files/Git/bin/bash.exe' if os.name == 'nt' else shutil.which('bash')
        if not bash or not Path(bash).exists():
            self.skipTest('Bash unavailable')
        path = str(workspace).replace('\\', '/')
        if os.name == 'nt':
            path = '/' + path[0].lower() + path[2:]
        prefix = ('source scripts/tools/helpers/automaton_common.sh\n'
                  f'export OPENCLAW_USER_DATA_DIR="{path}"\n')
        return subprocess.run([bash, '--noprofile', '--norc', '-c', prefix + script],
                              cwd=ROOT, capture_output=True, text=True, timeout=120)

    def mocks(self):
        return r'''
automaton_require_user() { :; }
automaton_runtime_check() { :; }
automaton_resources() { :; }
flock() { :; }
df() { printf 'Filesystem Blocks Used Available Capacity Mount\nfixture 100 1 99 1%% /\n'; }
docker() { echo FORBIDDEN_DOCKER; return 99; }
node() {
    case "$*" in --check*|-e*) return 0 ;; *) echo FORBIDDEN_ENTRY; return 99 ;; esac
}
git() {
    case "$*" in
        init*) mkdir -p "$AUTOMATON_SOURCE_DIR/.git"; echo INIT ;;
        *'remote add origin'*) : ;;
        *'fetch --depth 1'*) [[ "${FAIL_FETCH:-0}" == 0 ]] ;;
        *'checkout --detach'*)
            printf '{}' > "$AUTOMATON_SOURCE_DIR/package.json"
            printf 'fixture' > "$AUTOMATON_SOURCE_DIR/pnpm-lock.yaml"
            printf 'fixture' > "$AUTOMATON_SOURCE_DIR/pnpm-workspace.yaml" ;;
        *'remote get-url origin') echo "$AUTOMATON_SOURCE_URL" ;;
        *'rev-parse HEAD') echo "${MOCK_COMMIT:-$AUTOMATON_SOURCE_COMMIT}" ;;
        *'status --porcelain'*) if [[ "${DIRTY:-0}" == 1 ]]; then echo ' M file'; fi ;;
        *) echo UNEXPECTED_GIT; return 99 ;;
    esac
}
pnpm() {
    echo "PNPM $*"
    [[ "${FAIL_PNPM:-0}" == 0 ]] || return 1
    if [[ "$*" == 'run build' ]]; then
        mkdir -p dist packages/cli/dist
        printf '// fixture' > dist/index.js
        printf '// fixture' > packages/cli/dist/index.js
    fi
}
'''

    def test_plan_and_start_guard_have_no_side_effects(self):
        with tempfile.TemporaryDirectory() as temp:
            workspace = Path(temp) / 'private'
            result = self.shell('automaton_main --dry-run', workspace)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertIn('ohne Docker', result.stdout)
            self.assertFalse(workspace.exists())
            result = self.shell('automaton_main --run', workspace)
            self.assertEqual(result.returncode, 2)
            self.assertFalse(workspace.exists())

    def test_mocked_install_rebuild_failure_and_preserving_uninstall(self):
        with tempfile.TemporaryDirectory() as temp:
            workspace = Path(temp) / 'private'
            data = workspace / 'tools/automaton/runtime-data'
            data.mkdir(parents=True)
            (data / 'fixture.txt').write_text('preserve')
            script = self.mocks() + r'''
automaton_main install
automaton_main install
automaton_main status
export DIRTY=1
if automaton_main update; then exit 90; fi
unset DIRTY
export FAIL_PNPM=1
if automaton_main update; then exit 91; fi
[[ ! -f "$OPENCLAW_USER_DATA_DIR/tools/automaton/source-built" ]] || exit 92
unset FAIL_PNPM
automaton_main install
automaton_main uninstall
'''
            result = self.shell(script, workspace)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(result.stdout.count('INIT'), 1)
            self.assertEqual(result.stdout.count('PNPM run build'), 2)
            self.assertNotIn('FORBIDDEN', result.stdout)
            base = workspace / 'tools/automaton'
            self.assertFalse((base / 'source-built').exists())
            self.assertFalse((base / 'source').exists())
            self.assertEqual(len(list(base.glob('source.disabled.*'))), 1)
            self.assertEqual((data / 'fixture.txt').read_text(), 'preserve')
            self.assertTrue(list((workspace / 'install_logs').glob('*.log')))

    def test_failed_fetch_never_invokes_pnpm(self):
        with tempfile.TemporaryDirectory() as temp:
            workspace = Path(temp) / 'private'
            result = self.shell(self.mocks() + 'export FAIL_FETCH=1; automaton_main install', workspace)
            self.assertNotEqual(result.returncode, 0)
            self.assertNotIn('PNPM ', result.stdout)
            self.assertFalse((workspace / 'tools/automaton/source-built').exists())

    def test_commit_mismatch_never_invokes_pnpm(self):
        with tempfile.TemporaryDirectory() as temp:
            result = self.shell(self.mocks() + 'export MOCK_COMMIT=wrong; automaton_main install', Path(temp) / 'private')
            self.assertNotEqual(result.returncode, 0)
            self.assertNotIn('PNPM ', result.stdout)


if __name__ == "__main__":
    unittest.main()
