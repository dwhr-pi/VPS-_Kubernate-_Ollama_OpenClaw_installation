"""Networkless tests. Never install, build, authenticate, or execute an agent."""

from contextlib import nullcontext, redirect_stdout, redirect_stderr
import importlib.util
import io
import json
import os
from pathlib import Path
import stat
import tempfile
from types import SimpleNamespace
import unittest
from unittest.mock import Mock, patch


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("native_cli", ROOT / "scripts/agents/install_cli.py")
cli = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(cli)


class NativeCliTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.tools = cli.catalog()
        self.env = cli.environment(self.root / "home")

    def invoke(self, *argv):
        out, err = io.StringIO(), io.StringIO()
        with redirect_stdout(out), redirect_stderr(err):
            code = cli.main(list(argv))
        return code, json.loads(out.getvalue() or err.getvalue())

    def test_catalog_fixed_full_pins_and_licenses(self):
        expected = {
            "opencode": ("f023f7c36c090260a49c6e4da0ff69cbbd10c168", "MIT"),
            "aider": ("5dc9490bb35f9729ef2c95d00a19ccd30c26339c", "Apache-2.0"),
            "codex_cli": ("8fdf6472955749a731fd9e4b8ffc218e8e80c51d", "Apache-2.0"),
            "openhands": ("47bbc5e8392c4c75b7f77a1da38bed4a9f53d6a5", "MIT"),
        }
        self.assertEqual(set(self.tools), set(expected))
        for tool, (commit, license_name) in expected.items():
            self.assertEqual(self.tools[tool]["commit"], commit)
            self.assertEqual(self.tools[tool]["license"], license_name)
            self.assertIn(self.tools[tool]["license_file"], self.tools[tool]["contracts"])
            self.assertGreaterEqual(self.tools[tool]["disk_gib"], 10)

    def test_default_plan_has_no_side_effects(self):
        with patch.object(cli, "prepare", side_effect=AssertionError("build")), patch.object(cli, "run", side_effect=AssertionError("execution")):
            for tool in self.tools:
                code, data = self.invoke(tool, "--data-dir", str(self.root / "missing"))
                self.assertEqual(code, 0)
                self.assertFalse(data["executes"])
                self.assertFalse(data["runtime_ready"])
                self.assertEqual(data["action"], "plan")
        self.assertFalse((self.root / "missing").exists())

    def test_plan_overrides_every_action(self):
        with patch.object(cli, "prepare", side_effect=AssertionError("build")):
            for tool in self.tools:
                for action in cli.ACTIONS:
                    code, data = self.invoke(tool, action, "--plan")
                    self.assertEqual(code, 0)
                    self.assertEqual(data["requested_action"], action)
                    self.assertEqual(data["action"], "plan")

    def test_wrapper_matrix_quoted_and_no_scaffold(self):
        for tool in self.tools:
            for action in cli.ACTIONS[1:]:
                text = (ROOT / f"scripts/tools/{tool}_{action}.sh").read_text()
                self.assertIn(f'install_cli.py" {tool} {action} "$@"', text)
                self.assertIn('"${script_dir}/../agents/install_cli.py"', text)
                self.assertIn("exec python3 -I -B ", text)
                self.assertIn("# Source: " + self.tools[tool]["origin"], text)
                for forbidden in ("scaffold", "sudo", "rm -", "eval ", "source ", "${1:-"):
                    self.assertNotIn(forbidden, text)

    def test_legacy_data_root_default_plan_and_state(self):
        expected = self.root / ".openclaw_ultimate_user_data/tools/opencode/native-coding"
        with patch.dict(os.environ, {}, clear=True), patch.object(Path, "home", return_value=self.root):
            code, data = self.invoke("opencode")
            self.assertEqual(code, 0)
            self.assertEqual(Path(data["root"]), expected)
            with patch.object(cli, "guarded", side_effect=lambda p: Path(p)), patch.object(Path, "exists", return_value=False):
                self.assertEqual(cli.roots("opencode"), expected)

    def test_dry_run_alias_overrides_all_wrapper_actions_on_windows(self):
        with patch.object(cli.sys, "platform", "win32"), patch.object(cli, "prepare", side_effect=AssertionError("build")), patch.object(cli, "roots", side_effect=AssertionError("must not inspect junctions")):
            for tool in self.tools:
                for action in cli.ACTIONS:
                    code, data = self.invoke(tool, action, "--dry-run")
                    self.assertEqual(code, 0)
                    self.assertEqual(data["action"], "plan")
                    self.assertFalse(data["executes"])

    def test_roots_reject_repository_and_descendants_for_every_tool(self):
        repository = cli.CATALOG.parents[2]
        self.assertEqual(repository, ROOT)
        for tool in self.tools:
            for data in (repository, repository / "config", repository / "new-native-data/deep"):
                with self.subTest(tool=tool, data=str(data)), patch.object(cli, "guarded", side_effect=lambda p: Path(p)), self.assertRaisesRegex(cli.Refused, "outside the repository"):
                    cli.roots(tool, str(data))

    def test_roots_reject_repository_data_from_environment(self):
        with patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": str(ROOT / "native-data")}), patch.object(cli, "guarded", side_effect=lambda p: Path(p)), self.assertRaisesRegex(cli.Refused, "outside the repository"):
            cli.roots("opencode")

    def test_roots_allow_external_sibling_without_prefix_false_positive(self):
        data = ROOT.with_name(ROOT.name + "-external-data")
        with patch.object(cli, "guarded", side_effect=lambda p: Path(p)), patch.object(Path, "exists", return_value=False):
            self.assertEqual(cli.roots("opencode", str(data)), data / "tools/opencode/native-coding")

    def test_repository_data_refused_before_any_lifecycle_action(self):
        for action in cli.ACTIONS[1:]:
            with self.subTest(action=action), patch.object(cli.sys, "platform", "linux"), patch.object(cli.os, "getuid", return_value=1000, create=True), patch.object(cli, "guarded", side_effect=lambda p: Path(p)), patch.object(cli, "prepare", side_effect=AssertionError("no build")), patch.object(cli, "evidence", side_effect=AssertionError("no state access")), patch.object(cli, "locked", side_effect=AssertionError("no lock")), patch.object(Path, "mkdir", side_effect=AssertionError("no writes")):
                code, data = self.invoke("opencode", action, "--data-dir", str(ROOT / "native-data"))
                self.assertEqual(code, 2)
                self.assertEqual(data["state"], "refused")
                self.assertIn("outside the repository", data["error"])

    def test_windows_actions_refused_before_path_handling(self):
        with patch.object(cli.sys, "platform", "win32"), patch.object(cli, "roots", side_effect=AssertionError("must not inspect junctions")):
            for action in cli.ACTIONS[1:]:
                code, data = self.invoke("opencode", action)
                self.assertEqual(code, 2)
                self.assertEqual(data["state"], "refused")

    def test_environment_drops_credentials_and_hooks(self):
        with patch.dict(os.environ, {"OPENAI_API_KEY": "secret", "GIT_TRACE": "1", "BASH_ENV": "evil", "PYTHONPATH": "evil", "CARGO_BUILD_RUSTC_WRAPPER": "evil"}):
            env = cli.environment(self.root)
        for key in ("OPENAI_API_KEY", "GIT_TRACE", "BASH_ENV", "PYTHONPATH", "CARGO_BUILD_RUSTC_WRAPPER", "SSH_AUTH_SOCK"):
            self.assertNotIn(key, env)
        self.assertEqual(env["GIT_CONFIG_GLOBAL"], "/dev/null")
        self.assertEqual(env["GIT_TERMINAL_PROMPT"], "0")
        self.assertEqual(env["HOME"], str(self.root))

    def test_git_disables_hooks_credentials_and_file_transport(self):
        with patch.object(cli, "executable", return_value="/usr/bin/git"), patch.object(cli, "run", return_value="") as run:
            cli.git(["fetch", "origin", "abc"], self.root, self.env)
        args = run.call_args.args[0]
        for option in ("core.hooksPath=/dev/null", "credential.helper=", "core.fsmonitor=false", "protocol.file.allow=never"):
            self.assertIn(option, args)

    def test_preflight_restrictions(self):
        spec = self.tools["opencode"]
        with patch.object(cli.sys, "platform", "linux"), patch.object(cli.os, "getuid", return_value=1000, create=True), patch.object(cli.platform, "machine", return_value="x86_64"), patch.object(cli.platform, "libc_ver", return_value=("glibc", "2.39")), patch.dict(os.environ, {}, clear=True), patch.object(cli.shutil, "disk_usage", return_value=SimpleNamespace(free=30 * 1024**3)):
            for release in ("microsoft-standard-WSL2", "linux-wsl"):
                with patch.object(cli.platform, "release", return_value=release), self.assertRaisesRegex(cli.Refused, "WSL"):
                    cli.preflight(spec, self.root)
            with patch.object(cli.platform, "release", return_value="native-linux"):
                cli.preflight(spec, self.root)
                with patch.dict(os.environ, {"WSL_INTEROP": "yes"}), self.assertRaisesRegex(cli.Refused, "WSL"):
                    cli.preflight(spec, self.root)
                with patch.object(cli.shutil, "disk_usage", return_value=SimpleNamespace(free=19 * 1024**3)), self.assertRaisesRegex(cli.Refused, "20 GiB"):
                    cli.preflight(spec, self.root)
                with patch.object(cli.os, "getuid", return_value=0), self.assertRaisesRegex(cli.Refused, "nonroot"):
                    cli.preflight(spec, self.root)
                with patch.object(cli.platform, "machine", return_value="aarch64"), self.assertRaisesRegex(cli.Refused, "x86_64"):
                    cli.preflight(spec, self.root)

    def test_lock_required_and_no_invented_hashes(self):
        with self.assertRaisesRegex(cli.Refused, "needs --hashed-lock"):
            cli.hashed_lock(None, None)
        lock = self.root / "lock.txt"
        invalid = ["", "pkg==1.0", "-r other.txt", "--index-url https://evil", "pkg @ https://evil", "pkg>=1 --hash=sha256:" + "a" * 64]
        for text in invalid:
            lock.write_text(text)
            with self.assertRaises(cli.Refused):
                cli.hashed_lock(lock, cli.digest(lock))
        lock.write_text("pkg==1.0 " + "\\" + "\n    --hash=sha256:" + "a" * 64 + "\n")
        self.assertEqual(cli.hashed_lock(lock, cli.digest(lock)), lock)
        with self.assertRaisesRegex(cli.Refused, "digest mismatch"):
            cli.hashed_lock(lock, "0" * 64)

    def test_unknown_contract_refused(self):
        spec = self.tools["aider"]
        source = self.root / "source"
        source.mkdir()
        for name in spec["contracts"]:
            (source / name).write_text("wrong")
        with patch.object(cli, "git", side_effect=[spec["origin"], spec["commit"]]), patch.object(cli, "private_path", side_effect=lambda p, b: p), self.assertRaisesRegex(cli.Refused, "Unknown contract"):
            cli.verify_source(source, spec, self.env)

    def test_wrong_origin_and_pin_refused(self):
        spec = self.tools["opencode"]
        for answers, message in ((["https://evil"], "Origin"), ([spec["origin"], "0" * 40], "Commit")):
            with patch.object(cli, "git", side_effect=answers), self.assertRaisesRegex(cli.Refused, message):
                cli.verify_source(self.root, spec, self.env)

    def test_cargo_locked_existing_toolchain(self):
        spec = self.tools["codex_cli"]
        with patch.object(cli, "executable", side_effect=lambda n, e: "/tools/" + n), patch.object(cli, "run", side_effect=["cargo 1.95.0 (abc)", "rustc 1.95.0 (abc)", ""]) as run:
            artifact = cli.build("codex_cli", spec, self.root, self.env)
        args, cwd, env = run.call_args.args
        self.assertEqual(args, ["/tools/cargo", "build", "--locked", "--release", "--bin", "codex"])
        self.assertEqual(cwd, self.root / "source/codex-rs")
        self.assertEqual(env["RUSTC"], "/tools/rustc")
        self.assertEqual(artifact, self.root / "source" / spec["artifact"])

    def test_cargo_wrong_toolchain_fails_before_build(self):
        with patch.object(cli, "executable", return_value="/tools/cargo"), patch.object(cli, "run", return_value="cargo 1.90.0 (abc)") as run, self.assertRaisesRegex(cli.Refused, "Existing Rust"):
            cli.build("codex_cli", self.tools["codex_cli"], self.root, self.env)
        self.assertEqual(run.call_count, 1)

    def test_bun_frozen_real_build_and_prepared_dependencies(self):
        for name, version in (("@opentui/core", "0.7.0"), ("@opencode-ai/pty", "0.3.1")):
            package = self.root / "source/packages/cli/node_modules" / name / "package.json"
            package.parent.mkdir(parents=True)
            package.write_text(json.dumps({"version": version}))
        with patch.object(cli, "executable", return_value="/tools/bun"), patch.object(cli, "run", side_effect=["1.4.4", "", ""]) as run:
            cli.build("opencode", self.tools["opencode"], self.root, self.env)
        self.assertEqual(run.call_args_list[1].args[0], ["/tools/bun", "install", "--frozen-lockfile", "--ignore-scripts"])
        self.assertEqual(run.call_args.args[0], ["/tools/bun", "run", "--cwd", "packages/cli", "build", "--single", "--skip-install"])

    def test_bun_missing_prepared_dependencies_fails(self):
        with patch.object(cli, "executable", return_value="/tools/bun"), patch.object(cli, "run", side_effect=["1.4.4", ""]) as run, self.assertRaisesRegex(cli.Refused, "did not prepare"):
            cli.build("opencode", self.tools["opencode"], self.root, self.env)
        self.assertEqual(run.call_count, 2)

    def test_bun_version_mismatch(self):
        with patch.object(cli, "executable", return_value="/tools/bun"), patch.object(cli, "run", return_value="1.3.0") as run, self.assertRaisesRegex(cli.Refused, "Bun version"):
            cli.build("opencode", self.tools["opencode"], self.root, self.env)
        self.assertEqual(run.call_count, 1)

    def test_aider_private_venv_hashed_wheel_no_dependency_resolution(self):
        wheels = self.root / "wheels"
        wheels.mkdir()
        (wheels / "aider_chat-1.0-py3-none-any.whl").write_text("mock wheel")
        with patch.object(cli, "executable", return_value="/usr/bin/python3"), patch.object(cli, "run", return_value="") as run:
            artifact = cli.build("aider", self.tools["aider"], self.root, self.env, self.root / "reviewed.txt")
        commands = [call.args[0] for call in run.call_args_list]
        self.assertIn("venv", commands[0])
        self.assertIn("--require-hashes", commands[1])
        self.assertIn("--only-binary=:all:", commands[1])
        self.assertIn("--no-isolation", commands[2])
        self.assertIn("--wheel", commands[2])
        self.assertIn("--no-index", commands[3])
        self.assertIn("--no-deps", commands[3])
        self.assertEqual(commands[4][-1], "check")
        self.assertEqual(Path(os.path.normpath(artifact)), self.root / "venv/bin/aider")

    def test_openhands_source_only_never_runs_build(self):
        with patch.object(cli, "run", side_effect=AssertionError("SDK is not a built runtime")):
            result = cli.build("openhands", self.tools["openhands"], self.root, self.env)
        self.assertEqual(result, self.root / "source/LICENSE")
        self.assertFalse(self.tools["openhands"]["runtime_ready"])

    def test_tree_hash_detects_sdk_changes(self):
        (self.root / "sdk.py").write_text("source")
        before = cli.tree_hash(self.root)
        (self.root / "sdk.py").write_text("changed")
        self.assertNotEqual(before, cli.tree_hash(self.root))

    def test_guard_rejects_mocked_ancestor_symlink(self):
        with patch.object(Path, "is_symlink", side_effect=lambda: True), self.assertRaisesRegex(cli.Refused, "Symlink"):
            cli.guarded(self.root / "child")

    def test_private_path_refuses_escape(self):
        with self.assertRaisesRegex(cli.Refused, "escaped"):
            cli.private_path(self.root.parent / "other", self.root)

    def test_unowned_current_never_deactivated(self):
        (self.root / "current").mkdir()
        with self.assertRaisesRegex(cli.Refused, "Unowned activation"):
            cli.evidence(self.root, "openhands", self.tools["openhands"])

    def test_unsafe_current_targets_refused(self):
        for target in ("../escape", "/opt/legacy", "versions/../../escape", "versions/a/b"):
            with patch.object(Path, "is_symlink", return_value=True), patch.object(cli.os, "readlink", return_value=target), self.assertRaisesRegex(cli.Refused, "Unsafe activation"):
                cli.evidence(self.root, "openhands", self.tools["openhands"])

    def test_advisory_lock_contention_closes_descriptor(self):
        fake = SimpleNamespace(LOCK_EX=2, LOCK_NB=4, flock=Mock(side_effect=BlockingIOError()))
        info = SimpleNamespace(st_mode=stat.S_IFREG | 0o600, st_uid=1000, st_nlink=1)
        with patch.dict(cli.sys.modules, {"fcntl": fake}), patch.object(cli, "private_path", side_effect=lambda p, b: p), patch.object(cli.os, "getuid", return_value=1000, create=True), patch.object(cli.os, "O_NOFOLLOW", 0, create=True), patch.object(cli.os, "open", return_value=42), patch.object(cli.os, "fstat", return_value=info), patch.object(cli.os, "close") as close:
            with self.assertRaisesRegex(cli.Refused, "holds the lock"), cli.locked(self.root):
                self.fail("must not enter")
        close.assert_called_once_with(42)

    def test_aider_missing_lock_refused_before_creating_directories(self):
        args = SimpleNamespace(hashed_lock=None, lock_sha256=None)
        base = self.root / "not-created"
        with patch.object(cli, "preflight"), self.assertRaisesRegex(cli.Refused, "needs --hashed-lock"):
            cli.prepare("aider", self.tools["aider"], base, args)
        self.assertFalse(base.exists())

    def test_failed_build_retains_existing_activation(self):
        base = self.root / "native-coding"
        base.mkdir()
        active = base / "current"
        active.write_text("previous owned activation")
        args = SimpleNamespace(hashed_lock=None, lock_sha256=None, toolchain_bin=None)
        with patch.object(cli, "preflight"), patch.object(cli, "private_path", side_effect=lambda p, b: p), patch.object(cli, "locked", return_value=nullcontext()), patch.object(cli, "evidence", return_value={"state": "built"}), patch.object(cli, "git"), patch.object(cli, "verify_source"), patch.object(cli, "build", side_effect=cli.Refused("mock failure")), patch.object(cli.os, "replace") as replace:
            with self.assertRaisesRegex(cli.Refused, "mock failure"):
                cli.prepare("opencode", self.tools["opencode"], base, args, rebuild=True)
        replace.assert_not_called()
        self.assertEqual(active.read_text(), "previous owned activation")
        self.assertEqual(len(list((base / "versions").iterdir())), 1)

    def test_install_reuses_verified_same_pin_without_build_prerequisites(self):
        for tool, spec in self.tools.items():
            state = "source-prepared" if spec["kind"] == "source-only" else "built"
            current = {"state": state, "commit": spec["commit"], "runtime_ready": state == "built"}
            with self.subTest(tool=tool), patch.object(cli, "private_path", side_effect=lambda p, b: p), patch.object(cli, "locked", return_value=nullcontext()) as locked, patch.object(cli, "evidence", return_value=current) as evidence, patch.object(cli, "preflight", side_effect=AssertionError("no rebuild preflight")), patch.object(cli, "hashed_lock", side_effect=AssertionError("reuse retained lock evidence")), patch.object(cli, "build", side_effect=AssertionError("no build")), patch.object(cli, "run", side_effect=AssertionError("no subprocess")):
                result = cli.prepare(tool, spec, self.root, SimpleNamespace())
                self.assertEqual(result, current)
                locked.assert_called_once_with(self.root)
                evidence.assert_called_once_with(self.root, tool, spec)
        self.assertFalse((self.root / "versions").exists())

    def test_install_rejects_invalid_evidence_instead_of_rebuilding(self):
        with patch.object(cli, "private_path", side_effect=lambda p, b: p), patch.object(cli, "locked", return_value=nullcontext()), patch.object(cli, "evidence", side_effect=cli.Refused("Ownership/pin evidence mismatch")), patch.object(cli, "preflight", side_effect=AssertionError("no rebuild")), self.assertRaisesRegex(cli.Refused, "Ownership/pin"):
            cli.prepare("opencode", self.tools["opencode"], self.root, SimpleNamespace())

    def test_install_rechecks_evidence_after_build_preflight_race(self):
        current = {"state": "built", "commit": self.tools["opencode"]["commit"]}
        args = SimpleNamespace(hashed_lock=None, lock_sha256=None)
        with patch.object(cli, "private_path", side_effect=lambda p, b: p), patch.object(cli, "locked", side_effect=lambda b: nullcontext()), patch.object(cli, "evidence", side_effect=[{"state": "absent"}, current]), patch.object(cli, "preflight"), patch.object(cli, "build", side_effect=AssertionError("concurrent install already completed")):
            self.assertEqual(cli.prepare("opencode", self.tools["opencode"], self.root, args), current)
        self.assertFalse((self.root / "versions").exists())

    def test_main_install_and_update_select_reuse_or_rebuild(self):
        with patch.object(cli.sys, "platform", "linux"), patch.object(cli.os, "getuid", return_value=1000, create=True), patch.object(cli, "roots", return_value=self.root), patch.object(cli, "prepare", return_value={"state": "built"}) as prepare:
            for action in ("install", "update"):
                code, data = self.invoke("opencode", action)
                self.assertEqual(code, 0)
                self.assertEqual(data["state"], "built")
                self.assertEqual(prepare.call_args.kwargs["rebuild"], action == "update")

    def test_run_discards_build_output_and_sets_timeout(self):
        with patch.object(cli.subprocess, "run") as run:
            self.assertEqual(cli.run(["mock-build"], self.root, self.env), "")
        options = run.call_args.kwargs
        self.assertEqual(options["timeout"], 3600)
        self.assertEqual(options["stdin"], cli.subprocess.DEVNULL)
        self.assertEqual(options["stdout"], cli.subprocess.DEVNULL)
        self.assertEqual(options["stderr"], cli.subprocess.DEVNULL)
        self.assertTrue(options["check"])

    def test_run_metadata_is_bounded_without_pipe_buffers(self):
        env = dict(self.env, TMPDIR=str(self.root))

        def write_metadata(args, **options):
            self.assertEqual(options["timeout"], 3600)
            self.assertNotEqual(options["stdout"], cli.subprocess.PIPE)
            self.assertEqual(options["stderr"], cli.subprocess.DEVNULL)
            options["stdout"].write(b" 1.4.4\n")

        with patch.object(cli.subprocess, "run", side_effect=write_metadata):
            self.assertEqual(cli.run(["mock-version"], self.root, env, capture=True), "1.4.4")
        with patch.object(cli.subprocess, "run", side_effect=lambda args, **options: options["stdout"].write(b"x" * (cli.METADATA_OUTPUT_LIMIT + 1))), self.assertRaisesRegex(cli.Refused, "exceeds limit"):
            cli.run(["mock-version"], self.root, env, capture=True)

    def test_subprocess_failures_and_timeouts_are_redacted_and_do_not_activate(self):
        for error in (
            cli.subprocess.TimeoutExpired(["secret-command"], 3600, output="secret-stdout", stderr="secret-stderr"),
            cli.subprocess.CalledProcessError(1, ["secret-command"], output="secret-stdout", stderr="secret-stderr"),
        ):
            base = self.root / "native-coding"
            base.mkdir(exist_ok=True)
            active = base / "current"
            active.write_text("previous owned activation")
            with self.subTest(error=type(error).__name__), patch.object(cli.sys, "platform", "linux"), patch.object(cli.os, "getuid", return_value=1000, create=True), patch.object(cli, "roots", return_value=base), patch.object(cli, "preflight"), patch.object(cli, "private_path", side_effect=lambda p, b: p), patch.object(cli, "locked", side_effect=lambda b: nullcontext()), patch.object(cli, "evidence", return_value={"state": "built"}), patch.object(cli, "executable", return_value="/mock/git"), patch.object(cli.subprocess, "run", side_effect=error), patch.object(cli.os, "replace") as replace:
                code, data = self.invoke("opencode", "update")
            self.assertEqual(code, 2)
            self.assertEqual(data["state"], "refused")
            self.assertFalse(data["runtime_ready"])
            self.assertIn("no activation performed", data["error"])
            if isinstance(error, cli.subprocess.TimeoutExpired):
                self.assertIn("timed out", data["error"])
            self.assertNotIn("secret", json.dumps(data))
            self.assertNotIn("Traceback", json.dumps(data))
            replace.assert_not_called()
            self.assertEqual(active.read_text(), "previous owned activation")

    def test_sdk_source_prepare_records_false_readiness_before_activation(self):
        base = self.root / "native-coding"
        args = SimpleNamespace(hashed_lock=None, lock_sha256=None, toolchain_bin=None)
        spec = dict(self.tools["openhands"])
        text = "mock SDK source license"
        license_fixture = self.root / "license-fixture"
        license_fixture.write_text(text)
        spec["contracts"] = {"LICENSE": cli.digest(license_fixture)}

        def fake_git(args, cwd, env):
            if args[0] == "init":
                source = Path(args[-1])
                source.mkdir()
                (source / "LICENSE").write_text(text)
            if args[0] == "config":
                return spec["origin"]
            if args[0] == "rev-parse":
                return spec["commit"]
            return ""

        def check_activation(pending, active):
            version = next((base / "versions").iterdir())
            marker = json.loads((version / "OWNED.json").read_text())
            self.assertFalse(marker["runtime_ready"])
            self.assertEqual(marker["artifact"], "source/LICENSE")
            self.assertEqual(marker["tree_sha256"], cli.tree_hash(version / "source"))

        with patch.object(cli, "preflight"), patch.object(cli.os, "getuid", return_value=1000, create=True), patch.object(cli, "private_path", side_effect=lambda p, b: p), patch.object(cli, "locked", return_value=nullcontext()), patch.object(cli, "git", side_effect=fake_git), patch.object(Path, "symlink_to"), patch.object(cli.os, "replace", side_effect=check_activation) as replace, patch.object(cli, "run", side_effect=AssertionError("no SDK build")):
            cli.prepare("openhands", spec, base, args)
        replace.assert_called_once()

    def test_absent_status_does_not_create_state(self):
        with patch.object(cli.sys, "platform", "linux"), patch.object(cli.os, "getuid", return_value=1000, create=True), patch.object(cli, "roots", return_value=self.root / "missing"):
            code, data = self.invoke("openhands", "status")
            self.assertEqual(code, 0)
            self.assertEqual(data["state"], "absent")
            self.assertFalse(data["runtime_ready"])
            code, _ = self.invoke("openhands", "check")
            self.assertEqual(code, 1)
        self.assertFalse((self.root / "missing").exists())

    def test_uninstall_only_deactivates_owned_pointer(self):
        active = self.root / "current"
        active.write_text("mock owned pointer")
        retained = self.root / "retained"
        retained.write_text("keep")
        with patch.object(cli.sys, "platform", "linux"), patch.object(cli.os, "getuid", return_value=1000, create=True), patch.object(cli, "roots", return_value=self.root), patch.object(cli, "locked", return_value=nullcontext()), patch.object(cli, "evidence", return_value={"state": "source-prepared", "runtime_ready": False}):
            code, data = self.invoke("openhands", "uninstall")
        self.assertEqual(code, 0)
        self.assertEqual(data["state"], "deactivated")
        self.assertFalse(active.exists())
        self.assertEqual(retained.read_text(), "keep")

    def test_source_and_built_states_integrity(self):
        for tool, kind in (("openhands", "source-only"), ("opencode", "bun")):
            with self.subTest(tool=tool):
                version = self.root / tool / "versions/test"
                source = version / "source"
                source.mkdir(parents=True)
                artifact = source / "LICENSE"
                artifact.write_text("mock artifact")
                spec = dict(self.tools[tool], kind=kind, artifact="LICENSE", contracts={"LICENSE": cli.digest(artifact)})
                marker = {"owner": cli.OWNER, "uid": 1000, "tool": tool, "commit": spec["commit"], "origin": spec["origin"], "contracts": spec["contracts"], "runtime_ready": kind != "source-only", "artifact": "source/LICENSE", "sha256": cli.digest(artifact)}
                if kind == "source-only":
                    marker["tree_sha256"] = cli.tree_hash(source)
                (version / "OWNED.json").write_text(json.dumps(marker))
                with patch.object(cli.os, "getuid", return_value=1000, create=True), patch.object(cli, "private_path", side_effect=lambda p, b: p):
                    data = cli.evidence(self.root / tool, tool, spec, Path("versions/test"))
                    self.assertEqual(data["state"], "source-prepared" if kind == "source-only" else "built")
                    marker["owner"] = "other"
                    (version / "OWNED.json").write_text(json.dumps(marker))
                    with self.assertRaisesRegex(cli.Refused, "Ownership"):
                        cli.evidence(self.root / tool, tool, spec, Path("versions/test"))
                    marker["owner"] = cli.OWNER
                    (version / "OWNED.json").write_text(json.dumps(marker))
                    artifact.write_text("tampered")
                    with self.assertRaisesRegex(cli.Refused, "Artifact hash"):
                        cli.evidence(self.root / tool, tool, spec, Path("versions/test"))

    def test_no_recursive_removal_or_legacy_cleanup(self):
        text = Path(cli.__file__).read_text()
        self.assertNotIn("shutil.rmtree", text)
        self.assertNotIn("rm -rf", text)
        self.assertIn('(base / "current").unlink()', text)


if __name__ == "__main__":
    unittest.main()
