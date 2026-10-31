"""Offline helper contracts: all installers and SDK interfaces are fixture-only."""

import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
BASH = "C:/Program Files/Git/bin/bash.exe" if os.name == "nt" else shutil.which("bash")


@unittest.skipUnless(BASH and Path(BASH).is_file(), "Native Bash required; never launch WSL")
class ShellHelperContracts(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="shell-helper-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        helpers = self.root / "scripts/tools/helpers"
        helpers.mkdir(parents=True)
        for name in ("apt_tool", "python_tool", "node_tool", "scaffold_tool"):
            source = ROOT / f"scripts/tools/helpers/{name}_common.sh"
            shutil.copyfile(source, helpers / source.name)
        status = self.root / "scripts/helpers/status_tracking.sh"
        status.parent.mkdir(parents=True)
        status.write_text(
            'init_tool_tracking() { :; }\n'
            'mark_current_tool_installed() { echo installed >>"$LOG"; }\n'
            'mark_current_tool_removed() { echo removed >>"$LOG"; }\n',
            encoding="utf-8",
        )
        (self.root / "tool/venv/bin").mkdir(parents=True)
        (self.root / "tool/venv/bin/activate").write_text(
            "deactivate() { :; }\n", encoding="utf-8"
        )
        for name in ("pkg-one", "pkgE"):
            (self.root / name).touch()
            (self.root / "tool" / name).touch()

    def run_fixture(self, body):
        env = {key: value for key, value in os.environ.items()
               if key not in ("BASH_ENV", "ENV", "SHELLOPTS", "BASHOPTS")}
        env.update(HOME=str(self.root), USER="fixture", OPENCLAW_USER_DATA_DIR=str(self.root / "data"))
        setup = r'''
set -euo pipefail
export LOG="$PWD/calls"
TOOL_DIR="$PWD/tool"
TOOL_NAME=fixture TOOL_KEY=fixture TOOL_SLUG=fixture TOOL_DESCRIPTION=fixture
record() { printf '<%s>' "$@" >>"$LOG"; printf '\n' >>"$LOG"; }
sudo() { record "$@"; }
apt-get() { record apt-get "$@"; }
pip() { record pip "$@"; }
npm() { record npm "$@"; }
# Keep fixture plumbing builtin-only on slow Windows process launches.
dirname() { printf '%s\n' "${1%/*}"; }
cat() { local line; while IFS= read -r line; do printf '%s\n' "$line"; done; }
'''
        result = subprocess.run(
            [BASH, "--noprofile", "--norc", "-c", setup + body],
            cwd=self.root, env=env, capture_output=True, text=True,
            encoding="utf-8", timeout=60 if os.name == "nt" else 20,
        )
        log = self.root / "calls"
        return result, log.read_text(encoding="utf-8") if log.exists() else ""

    def test_package_lists_preserve_arguments_without_globbing(self):
        cases = (
            ("apt_tool", "APT_PACKAGES", "install_apt_tool\nuninstall_apt_tool", "apt-get", "-y"),
            ("python_tool", "TOOL_PACKAGES", "install_python_tool", "pip", ""),
            ("node_tool", "TOOL_NPM_PACKAGES", "install_node_tool", "npm", "--engine-strict"),
            ("scaffold_tool", "TOOL_APT_PACKAGES", "install_scaffold_tool", "apt-get", "-y"),
        )
        for helper, variable, action, command, flag in cases:
            with self.subTest(helper=helper):
                (self.root / "calls").unlink(missing_ok=True)
                result, calls = self.run_fixture(
                    f'source scripts/tools/helpers/{helper}_common.sh\n'
                    'node() { printf "v22.0.0\\n"; }\n'
                    f"{variable}=$'pkg*\\t pkg[extra]\\nlast==1.*'\n{action}\n"
                )
                self.assertEqual(result.returncode, 0, result.stderr)
                prefix = f"<{command}><install>" + (f"<{flag}>" if flag else "")
                self.assertIn(prefix + "<pkg*><pkg[extra]><last==1.*>\n", calls)
                self.assertIn("installed\n", calls)
                if helper == "apt_tool":
                    self.assertIn("<apt-get><remove><-y><pkg*><pkg[extra]><last==1.*>\n", calls)
                    self.assertTrue(calls.endswith("removed\n"), calls)

    def test_failed_npm_install_never_marks_success(self):
        result, calls = self.run_fixture(r'''
source scripts/tools/helpers/node_tool_common.sh
node() { printf 'v22.0.0\n'; }
TOOL_NPM_PACKAGES='pkg*'
# Isolate the failure mock in a subshell; do not shadow a later declaration.
(
  npm() { [[ "$1" != install ]]; }
  install_node_tool
)
''')
        self.assertEqual(result.returncode, 1, result.stderr)
        self.assertNotIn("installed", calls)

    def test_exit_traps_keep_elapsed_time_and_exit_status(self):
        for helper in ("automaton", "freellmapi", "qwen_code"):
            source = (ROOT / f"scripts/tools/helpers/{helper}_common.sh").read_text(encoding="utf-8")
            trap = re.search(r"^  (trap 'rc=\$\?;[^\n]+' EXIT)$", source, re.MULTILINE)
            self.assertIsNotNone(trap)
            for status in (0, 17, 130):
                with self.subTest(helper=helper, status=status):
                    result, _ = self.run_fixture(
                        'df() { :; }\nscenario() (\n'
                        'local rc started=0 before=123 mount=/\n'
                        + trap.group(1) + f'\nexit {status}\n)\nscenario\n'
                    )
                    self.assertEqual(result.returncode, status, result.stderr)
                    self.assertRegex(result.stdout, rf"Exit={status} Dauer=\d+s Disk-vorher-KiB=123")

    def test_penpot_external_source_contract(self):
        render = self.root / "checkout/render-wasm"
        render.mkdir(parents=True)
        sdk = self.root / "sdk.sh"
        sdk.write_text("emcc() { :; }\n", encoding="utf-8")
        build_env = render / "_build_env"
        for version, expected in (("1.99.0", 0), ("0.0.0", 1)):
            with self.subTest(version=version):
                (self.root / "calls").unlink(missing_ok=True)
                build_env.write_text(
                    '[[ "$1" == frontend && "$2" == --locked ]] || exit 99\n'
                    f'RUST_VERSION={version}\n'
                    'CARGO_BUILD_TARGET=wasm32-unknown-emscripten\n'
                    'build() { printf "build:%s:%s\\n" "$BUILD_MODE" "$EM_CACHE" >>"$LOG"; }\n'
                    'copy_target_artifacts() { echo copied >>"$LOG"; }\n',
                    encoding="utf-8",
                )
                shutil.copyfile(ROOT / "scripts/tools/assets/penpot_native_wasm.sh", self.root / "penpot.sh")
                result, calls = self.run_fixture(r'''
export PENPOT_EMSDK_ENV="$PWD/sdk.sh" SKIA_BINARIES_URL=file:///fixture/skia
export RUSTUP_TOOLCHAIN=/fixture/rust
source penpot.sh "$PWD/checkout" "$PWD/prefix" frontend
''')
                self.assertEqual(result.returncode, expected, result.stderr)
                if expected == 0:
                    self.assertIn("build:release:", calls)
                    self.assertIn("/prefix/_build/emscripten-cache\ncopied\n", calls)
                else:
                    self.assertEqual(calls, "")

    def test_paperless_retry_budget_and_status(self):
        source = (ROOT / "scripts/tools/helpers/paperless_safe_common.sh").read_text(encoding="utf-8")
        retry = re.search(r"(  local attempt\n.*)\n}\s*$", source, re.DOTALL)
        self.assertIsNotNone(retry)
        result, _ = self.run_fixture(
            'curl() { probes=$((probes + 1)); ((probes >= success_at)); }\n'
            'sleep() { [[ "$1" == 5 ]] || exit 99; sleeps=$((sleeps + 1)); }\n'
            'mark_current_tool_installed() { marked=$((marked + 1)); }\n'
            'probe() {\n' + retry.group(1) + '\n}\n'
            'for success_at in 1 6 7; do\n'
            'probes=0 sleeps=0 marked=0\n'
            'if probe; then rc=0; else rc=$?; fi\n'
            'printf "CHECK:%s:%s:%s:%s\\n" "$rc" "$probes" "$sleeps" "$marked"\n'
            'done\n'
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(re.findall(r"^CHECK:.*$", result.stdout, re.MULTILINE),
                         ["CHECK:0:1:0:1", "CHECK:0:6:5:1", "CHECK:1:6:6:0"])


if __name__ == "__main__":
    unittest.main()
