"""Offline migration contracts; no source fetches, compiler, packages or Docker."""
from contextlib import redirect_stdout
import io
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts/tools/helpers"))
import native_github_tools as tool


class NativeGithubTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.env = patch.dict(os.environ, {"OPENCLAW_USER_DATA_DIR": self.temp.name})
        self.env.start()
        self.addCleanup(self.env.stop)
        self.spec = tool.TOOLS["node_exporter"]
        self.outer, self.prefix, self.marker = tool.paths("node_exporter")

    def git(self, path, *args):
        if args == ("rev-parse", "HEAD"):
            return self.spec["recipe"]["pin"]
        if args == ("remote", "get-url", "origin"):
            return "https://github.com/" + self.spec["repo"] + ".git"
        raise AssertionError(args)

    def source(self, checkout, marker, base, spec):
        checkout.mkdir()
        (checkout / "README.md").write_text("fixture source")
        marker.write_text("source fixture")

    def build(self, prefix, spec):
        (prefix / "bin").mkdir()
        (prefix / "bin/program").write_text("fixture binary")
        return ["bin/program"]

    def installed(self):
        self.outer.mkdir(parents=True, exist_ok=True)
        with patch.object(tool, "preflight"), patch.object(tool.common, "install", side_effect=self.source), patch.object(tool, "build", side_effect=self.build), redirect_stdout(io.StringIO()):
            tool.install(self.outer, self.prefix, self.marker, self.spec)

    def test_inventory_has_43_paths_and_37_honest_build_recipes(self):
        self.assertEqual(len(tool.TOOLS), 43)
        self.assertEqual(sum(bool(s["recipe"]) for s in tool.TOOLS.values()), 37)
        for key, spec in tool.TOOLS.items():
            self.assertEqual(key, spec["id"])
            if spec["recipe"]:
                self.assertRegex(spec["recipe"]["pin"], r"^[a-f0-9]{40}$")
                self.assertIsNone(spec["blocked_reason"])
            else:
                self.assertTrue(spec["blocked_reason"])

    def test_every_plan_and_status_are_read_only(self):
        with patch.object(tool.common, "run") as run, patch.object(tool.common, "git") as git, redirect_stdout(io.StringIO()):
            for key in tool.TOOLS:
                self.assertEqual(tool.main([key, "install", "--dry-run"]), 0)
                self.assertEqual(tool.main([key, "status"]), 0)
        self.assertEqual(list(Path(self.temp.name).iterdir()), [])
        run.assert_not_called()
        git.assert_not_called()

    def test_blocked_install_fails_and_logs_without_fetch_or_marker(self):
        with patch.object(tool.common, "install") as install, patch.object(tool, "build") as build, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "noch OFFEN"):
                tool.main(["airbyte", "install"])
        install.assert_not_called()
        build.assert_not_called()
        _, prefix, marker = tool.paths("airbyte")
        self.assertFalse(prefix.exists())
        self.assertFalse(marker.exists())
        logs = list((Path(self.temp.name) / "install_logs").glob("*.log"))
        self.assertEqual(len(logs), 1)
        self.assertIn("Kein Docker-Fallback", logs[0].read_text())

    def test_low_disk_fails_before_sources_and_keeps_legacy_data(self):
        self.outer.mkdir(parents=True)
        legacy = self.outer / "existing-data"
        legacy.write_text("keep")
        with patch.object(tool.platform, "system", return_value="Linux"), patch.object(tool.common, "reserve", side_effect=ValueError("Windows-Host-Speicherplatzmangel")), patch.object(tool.common, "install") as install, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Speicherplatzmangel"):
                tool.main(["node_exporter", "install"])
        install.assert_not_called()
        self.assertFalse(self.prefix.exists())
        self.assertEqual(legacy.read_text(), "keep")
        logs = list((Path(self.temp.name) / "install_logs").glob("*.log"))
        self.assertIn("Speicherplatzmangel", logs[0].read_text())

    def test_success_and_second_install_are_idempotent(self):
        self.installed()
        with patch.object(tool.common, "git", side_effect=self.git), patch.object(tool, "preflight") as preflight, patch.object(tool, "build") as build, redirect_stdout(io.StringIO()):
            tool.install(self.outer, self.prefix, self.marker, self.spec)
            result = tool.validate(self.prefix, self.marker, self.spec, full=True)
        preflight.assert_not_called()
        build.assert_not_called()
        self.assertFalse(result["application_tested"])
        self.assertEqual(result["scope"], "native-github-build")

    def test_build_failure_removes_only_new_prefix(self):
        self.outer.mkdir(parents=True)
        keep = self.outer / "legacy.env"
        keep.write_text("keep")
        with patch.object(tool, "preflight"), patch.object(tool.common, "install", side_effect=self.source), patch.object(tool, "build", side_effect=OSError("ENOSPC")), redirect_stdout(io.StringIO()):
            with self.assertRaises(OSError):
                tool.install(self.outer, self.prefix, self.marker, self.spec)
        self.assertFalse(self.prefix.exists())
        self.assertEqual(keep.read_text(), "keep")

    def test_mosquitto_example_is_loopback_denies_anonymous_and_keeps_old_config(self):
        self.spec = tool.TOOLS["mosquitto"]
        self.outer, self.prefix, self.marker = tool.paths("mosquitto")
        self.outer.mkdir(parents=True)
        old = self.outer / "mosquitto.conf"
        old.write_text("operator config")
        self.installed()
        example = (self.prefix / "mosquitto.conf.example").read_text()
        self.assertIn("listener 1883 127.0.0.1", example)
        self.assertIn("allow_anonymous false", example)
        self.assertEqual(old.read_text(), "operator config")

    def test_atomic_marker_failure_never_leaves_success(self):
        self.outer.mkdir(parents=True)
        with patch.object(tool, "preflight"), patch.object(tool.common, "install", side_effect=self.source), patch.object(tool, "build", side_effect=self.build), patch.object(tool.os, "replace", side_effect=OSError("marker full")), redirect_stdout(io.StringIO()):
            with self.assertRaises(OSError):
                tool.install(self.outer, self.prefix, self.marker, self.spec)
        self.assertFalse(self.prefix.exists())
        self.assertFalse(self.marker.exists())

    def test_unmanaged_directory_is_preserved(self):
        self.prefix.mkdir(parents=True)
        keep = self.prefix / "private"
        keep.write_text("keep")
        with self.assertRaisesRegex(ValueError, "ohne Buildnachweis"):
            tool.install(self.outer, self.prefix, self.marker, self.spec)
        self.assertEqual(keep.read_text(), "keep")

    def test_added_files_block_uninstall(self):
        self.installed()
        keep = self.prefix / "database"
        keep.write_text("keep")
        with patch.object(tool.common, "git", side_effect=self.git), redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "ergaenzt"):
                tool.main(["node_exporter", "uninstall"])
        self.assertTrue(self.marker.exists())
        self.assertEqual(keep.read_text(), "keep")

    def test_uninstall_does_not_touch_sibling_legacy_data(self):
        self.installed()
        keep = self.outer / "old-container-data"
        keep.write_text("keep")
        with patch.object(tool.common, "git", side_effect=self.git), redirect_stdout(io.StringIO()):
            self.assertEqual(tool.main(["node_exporter", "uninstall"]), 0)
            self.assertEqual(tool.main(["node_exporter", "uninstall"]), 0)
        self.assertFalse(self.prefix.exists())
        self.assertEqual(keep.read_text(), "keep")

    def test_foreign_commit_is_rejected(self):
        self.installed()
        with patch.object(tool.common, "git", return_value="different"):
            with self.assertRaisesRegex(ValueError, "Quellidentitaet"):
                tool.validate(self.prefix, self.marker, self.spec)

    def test_unsafe_artifact_marker_is_rejected(self):
        self.installed()
        record = json.loads(self.marker.read_text())
        record["artifacts"] = ["../legacy.env"]
        self.marker.write_text(json.dumps(record))
        with patch.object(tool.common, "git", side_effect=self.git):
            with self.assertRaisesRegex(ValueError, "Artefaktpfad"):
                tool.validate(self.prefix, self.marker, self.spec)

    def test_all_build_kinds_only_compile_and_probe_in_fixtures(self):
        for spec in tool.TOOLS.values():
            if not spec["recipe"]:
                continue
            with self.subTest(tool=spec["id"]), tempfile.TemporaryDirectory() as temporary:
                prefix = Path(temporary)
                checkout = prefix / "source"
                checkout.mkdir()
                recipe = spec["recipe"]
                (checkout / "package.json").write_text(json.dumps({"packageManager": "pnpm@" + recipe.get("package_manager", "11.26.0")}))
                (checkout / "Makefile.common").write_text("PROMU_VERSION ?= 0.20.0")
                commands = []
                def run(args, cwd, env):
                    command = list(map(str, args))
                    commands.append(command)
                    if command[:3] == ["rustc", "--print", "sysroot"]:
                        return str(prefix)
                    if command == ["pnpm", "--version"]:
                        return recipe.get("package_manager", recipe.get("manager", ["pnpm", "11.26.0"])[1])
                    if recipe.get("manager") and command == [recipe["manager"][0], "--version"]:
                        return recipe["manager"][1]
                    expected = []
                    if recipe.get("binary"):
                        expected += ["bin/" + recipe["binary"], "source/target/release/" + recipe["binary"]]
                    if recipe.get("artifact"):
                        expected.append(recipe["artifact"])
                    for key in ("entry", "assets"):
                        if recipe.get(key):
                            expected.append("source/" + recipe[key])
                    expected += recipe.get("artifacts", [])
                    expected += [pattern.replace("*", "fixture") for pattern in recipe.get("artifact_globs", [])]
                    expected += ["venv/pyvenv.cfg"]
                    for name in expected:
                        path = prefix / name
                        path.parent.mkdir(parents=True, exist_ok=True)
                        path.write_text("built fixture")
                    return "fixture==1"
                with patch.object(tool, "run", side_effect=run):
                    artifacts = tool.build(prefix, spec)
                self.assertTrue(artifacts)
                for command in commands:
                    self.assertNotIn(command[0], ("docker", "podman", "sudo"))
                    self.assertFalse(any(arg in command for arg in ("start", "serve", "up", "setup", "publish", "push")))
                if spec["id"] == "prometheus":
                    self.assertIn(["go", "install", "github.com/prometheus/promu@v0.20.0"], commands)
                if spec["id"] == "open_webui":
                    self.assertLess(commands.index(["npm", "ci", "--no-audit", "--no-fund"]),
                                    next(i for i, args in enumerate(commands) if args[:3] == ["uv", "pip", "install"]))
                if spec["id"] == "argilla":
                    self.assertIn(["npm", "exec", "--", "nuxt", "generate"], commands)
                    self.assertTrue(any(str(checkout / "argilla-server") + "[postgresql]" in args for args in commands))

    def test_environment_excludes_credentials_and_blocks_container_fallback(self):
        self.prefix.mkdir(parents=True)
        with patch.dict(os.environ, {"OPENAI_API_KEY": "fixture", "AWS_SECRET_ACCESS_KEY": "fixture"}):
            env = tool.environment(self.prefix)
        self.assertNotIn("OPENAI_API_KEY", env)
        self.assertNotIn("AWS_SECRET_ACCESS_KEY", env)
        self.assertEqual(env["GOTOOLCHAIN"], "local")
        for name in ("docker", "podman", "sudo"):
            self.assertIn("exit 126", (self.prefix / "_build/guards" / name).read_text())
        with self.assertRaisesRegex(ValueError, "Fallback"):
            tool.run(["docker", "pull", "fixture"], self.prefix, env)

    def test_every_lifecycle_wrapper_uses_native_dispatcher(self):
        for key in tool.TOOLS:
            for action in ("install", "update", "uninstall", "status", "doctor", "check"):
                text = (ROOT / "scripts/tools" / (key + "_" + action + ".sh")).read_text()
                self.assertIn('native_github_tools.py" ' + key + " " + action, text)
                for forbidden in ("install_git_docker_tool", "install_docker_compose_tool", "docker pull", "docker compose"):
                    self.assertNotIn(forbidden, text)

    def test_registry_uses_build_markers_and_never_calls_blocked_recipe_ready(self):
        entries = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
        self.assertTrue(set(tool.TOOLS).issubset({item["id"] for item in entries}))
        for item in entries:
            spec = tool.TOOLS.get(item["id"])
            if not spec:
                continue
            self.assertEqual(item["check_value"], "~/.openclaw_ultimate_user_data/tools/" + spec["id"] + "/native-github/build-ready.json")
            self.assertEqual(item["status"], "experimental" if spec["recipe"] else "planned")

    def test_eol_archive_requires_explicit_ack_before_fetch(self):
        with patch.object(tool.platform, "system", return_value="Linux"), patch.object(tool.common, "reserve"), patch.object(tool.common, "install") as install, patch.dict(os.environ, {"NATIVE_ALLOW_EOL_PROMTAIL": "0"}), redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "EOL-Archivbuild"):
                tool.main(["promtail", "install"])
        install.assert_not_called()
        self.assertFalse(tool.paths("promtail")[1].exists())

    def test_python_version_check_is_before_fetch_and_does_not_expose_keys(self):
        with patch.object(tool.platform, "system", return_value="Linux"), patch.object(tool.common, "reserve"), patch.object(tool.common, "executable"), patch.object(tool.common, "install") as install, patch.object(tool.common, "run", side_effect=ValueError("Python-Version")) as run, patch.dict(os.environ, {"OPENAI_API_KEY": "fixture-secret"}), redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Python-Version"):
                tool.main(["home_assistant", "install"])
        install.assert_not_called()
        self.assertNotIn("OPENAI_API_KEY", run.call_args.args[2])

    def test_submodule_pin_mismatch_rolls_back_without_fetching_dependency(self):
        spec = tool.TOOLS["nextcloud"]
        outer, prefix, marker = tool.paths("nextcloud")
        outer.mkdir(parents=True)
        keep = outer / "legacy-data"
        keep.write_text("preserve")
        with patch.object(tool, "preflight"), patch.object(tool.common, "install", side_effect=self.source) as install, patch.object(tool.common, "git", return_value="160000 commit " + "0" * 40 + "\t3rdparty"), patch.object(tool, "build") as build, redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Submodul-Pin"):
                tool.install(outer, prefix, marker, spec)
        self.assertEqual(install.call_count, 1)
        build.assert_not_called()
        self.assertFalse(prefix.exists())
        self.assertEqual(keep.read_text(), "preserve")

    def test_missing_pipeline_output_is_failure_not_source_only_success(self):
        self.prefix.mkdir(parents=True)
        (self.prefix / "source").mkdir()
        spec = tool.TOOLS["apache_tika"]
        with patch.object(tool, "run", return_value=""):
            with self.assertRaisesRegex(ValueError, "Buildartefakt fehlt"):
                tool.build(self.prefix, spec)
        self.assertFalse(self.marker.exists())

    def test_every_recipe_declares_its_toolchain_without_key_errors(self):
        for spec in tool.TOOLS.values():
            if spec["recipe"]:
                self.assertTrue(tool.requirements(spec), spec["id"])

    def test_official_codeberg_exception_does_not_mark_a_clone_as_installed(self):
        self.prefix.mkdir(parents=True)
        spec = tool.TOOLS["forgejo"]
        source_marker = self.prefix / "source-ready.json"
        with patch.object(tool.common, "git", return_value=spec["recipe"]["pin"]) as git, patch.object(tool.common, "install") as github, redirect_stdout(io.StringIO()):
            tool.fetch_source(self.prefix / "source", source_marker, self.prefix, {}, spec["recipe"])
        github.assert_not_called()
        self.assertTrue(any(call.args[1:] == ("remote", "add", "origin", "https://codeberg.org/forgejo/forgejo.git") for call in git.call_args_list))
        record = json.loads(source_marker.read_text())
        self.assertFalse(record["installed"])
        self.assertEqual(record["scope"], "source-only")
        self.assertFalse(self.marker.exists())


if __name__ == "__main__":
    unittest.main()
