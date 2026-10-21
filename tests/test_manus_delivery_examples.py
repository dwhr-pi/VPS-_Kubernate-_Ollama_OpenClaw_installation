"""Offline guards and embedded script fixtures; never builds or deploys an app."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
import xml.etree.ElementTree as ET
import zipfile

ROOT = Path(__file__).resolve().parents[1]
EXAMPLES = ROOT / "examples/manus-ci-cd"
SKILL = ROOT / "skills/agentic-project-delivery/SKILL.md"
BASH = "C:/Program Files/Git/bin/bash.exe" if os.name == "nt" else shutil.which("bash")


def run_blocks(text):
    """Extract this example's YAML block scalars, not a general YAML parser."""
    lines = text.splitlines()
    blocks = []
    for i, line in enumerate(lines):
        if line.strip() != "run: |":
            continue
        indent = len(line) - len(line.lstrip())
        body = []
        for next_line in lines[i + 1:]:
            if next_line.strip() and len(next_line) - len(next_line.lstrip()) <= indent:
                break
            body.append(next_line[indent + 2:] if next_line.strip() else "")
        blocks.append("\n".join(body) + "\n")
    return blocks


def embedded_python(filename):
    text = (EXAMPLES / filename).read_text()
    for block in run_blocks(text):
        match = re.search(r"python3 -I - <<'PY'\n(.*?)\nPY", block, re.DOTALL)
        if match:
            return match[1]
    raise AssertionError("Python fixture not found")


class ManusDeliveryExamples(unittest.TestCase):
    def test_examples_are_not_active_workflows(self):
        names = ("go-ci", "rust-ci", "go-release")
        for name in names:
            self.assertTrue((EXAMPLES / (name + ".yml.example")).is_file())
            self.assertFalse((ROOT / ".github/workflows" / (name + ".yml")).exists())

    def test_all_action_references_use_full_pins_and_checkout_does_not_persist(self):
        approved = {
            "actions/checkout": "d23441a48e516b6c34aea4fa41551a30e30af803",
            "actions/setup-go": "924ae3a1cded613372ab5595356fb5720e22ba16",
            "actions/upload-artifact": "ea165f8d65b6e75b540449e92b4886f43607fa02",
        }
        for file in EXAMPLES.glob("*.yml.example"):
            text = file.read_text()
            for name, pin in re.findall(r"uses: ([\w/-]+)@([^\s]+)", text):
                self.assertEqual(pin, approved[name])
            if "actions/checkout@" in text:
                self.assertIn("persist-credentials: false", text)
            self.assertNotIn("pull_request_target", text)
            self.assertNotIn("self-hosted", text)

    def test_ci_jobs_have_no_release_credentials_or_publish_commands(self):
        for name in ("go-ci.yml.example", "rust-ci.yml.example"):
            text = (EXAMPLES / name).read_text()
            for forbidden in ("packages: write", "secrets.", "docker login", "kubectl", "--push"):
                self.assertNotIn(forbidden, text)
            self.assertIn("contents: read", text)
            self.assertIn("timeout-minutes: 20", text)
            self.assertIn("workflow_call:", text)

    def test_release_requires_main_manual_opt_in_and_verified_ci(self):
        text = (EXAMPLES / "go-release.yml.example").read_text()
        self.assertIn("workflow_dispatch:", text)
        self.assertNotIn("\n  push:", text)
        self.assertNotIn("\n  pull_request:", text)
        self.assertIn("default: false", text)
        self.assertEqual(text.count("github.ref == 'refs/heads/main'"), 2)
        self.assertEqual(text.count("vars.ENABLE_MANUS_RELEASE == 'true'"), 2)
        self.assertIn("needs: verify", text)
        self.assertIn("uses: ./.github/workflows/go-ci.yml", text)
        self.assertIn("environment: release", text)
        self.assertIn("--password-stdin", text)
        self.assertNotIn("kubectl", text)

    @unittest.skipUnless(BASH, "Bash unavailable")
    def test_all_embedded_shell_blocks_pass_syntax_check_without_execution(self):
        blocks = []
        for file in EXAMPLES.glob("*.yml.example"):
            blocks.extend(run_blocks(file.read_text()))
        self.assertGreaterEqual(len(blocks), 5)
        for block in blocks:
            result = subprocess.run([BASH, "--noprofile", "--norc", "-n"], input=block,
                                    capture_output=True, text=True, timeout=30)
            self.assertEqual(result.returncode, 0, result.stderr)

    def run_python_fixture(self, code, files, output_env):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for name, content in files.items():
                (root / name).write_text(content)
            env = {key: os.environ[key] for key in ("SystemRoot", "SYSTEMROOT", "WINDIR", "PATH") if key in os.environ}
            env[output_env] = str(root / "result.txt")
            result = subprocess.run([sys.executable, "-I", "-c", code], cwd=root, env=env,
                                    capture_output=True, text=True, timeout=30)
            output = (root / "result.txt").read_text() if (root / "result.txt").exists() else ""
            return result.returncode, output

    def test_rust_pin_fixture_accepts_exact_version(self):
        code, output = self.run_python_fixture(embedded_python("rust-ci.yml.example"),
            {"rust-toolchain.toml": '[toolchain]\nchannel = "1.99.1"\n'}, "GITHUB_ENV")
        self.assertEqual(code, 0)
        self.assertEqual(output, "RUSTUP_TOOLCHAIN=1.99.1\n")

    def test_rust_pin_fixture_rejects_floating_or_injected_values(self):
        for value in ("stable", "nightly", "1.99.1\\nEVIL=1", "1.99.1;echo BAD"):
            code, output = self.run_python_fixture(embedded_python("rust-ci.yml.example"),
                {"rust-toolchain.toml": '[toolchain]\nchannel = "' + value + '"\n'}, "GITHUB_ENV")
            self.assertNotEqual(code, 0)
            self.assertEqual(output, "")

    def test_release_digest_fixture_only_reports_valid_sha256(self):
        code = embedded_python("go-release.yml.example")
        for digest, valid in (("sha256:" + "a" * 64, True), ("latest", False), ("sha256:short", False)):
            rc, output = self.run_python_fixture(code,
                {"image-metadata.json": json.dumps({"containerimage.digest": digest})}, "GITHUB_STEP_SUMMARY")
            self.assertEqual(rc == 0, valid)
            if valid:
                self.assertIn(digest, output)
            else:
                self.assertEqual(output, "")

    def test_skill_metadata_and_relative_references(self):
        text = SKILL.read_text()
        frontmatter = text.split("---", 2)[1]
        fields = dict(line.split(": ", 1) for line in frontmatter.strip().splitlines())
        self.assertEqual(set(fields), {"name", "description"})
        self.assertEqual(fields["name"], SKILL.parent.name)
        self.assertRegex(fields["name"], r"^[a-z0-9-]{1,63}$")
        self.assertTrue(fields["description"].strip())
        for link in re.findall(r"\]\(([^)]+)\)", text):
            self.assertTrue((SKILL.parent / link).is_file(), link)

    def test_kubernetes_example_is_private_restricted_and_not_start_ready(self):
        text = (EXAMPLES / "kubernetes.yml.example").read_text()
        for required in ("type: ClusterIP", "automountServiceAccountToken: false", "runAsNonRoot: true",
                         "readOnlyRootFilesystem: true", "allowPrivilegeEscalation: false",
                         "drop: [ALL]", "requests:", "limits:", "startupProbe:", "readinessProbe:",
                         "livenessProbe:", "egress: []", "example.invalid/review-required@sha256:"):
            self.assertIn(required, text)
        for forbidden in ("type: NodePort", "type: LoadBalancer", "hostNetwork: true", "privileged: true"):
            self.assertNotIn(forbidden, text)

    def test_presentation_content_has_sources_and_local_references(self):
        data = json.loads((ROOT / "docs/presentations/technology-tooling-overview.json").read_text(encoding="utf-8"))
        self.assertEqual(len(data["slides"]), 13)
        for slide in data["slides"]:
            self.assertTrue(slide["title"])
            self.assertTrue(slide["note"])
            self.assertTrue(slide["sources"])
            for source in slide["sources"]:
                if not source.startswith("https://"):
                    self.assertTrue((ROOT / source).is_file(), source)

    def test_pptx_has_editable_slides_and_source_notes(self):
        pptx = ROOT / "docs/presentations/technology-tooling-overview.pptx"
        with zipfile.ZipFile(pptx) as archive:
            slides = [n for n in archive.namelist() if re.fullmatch(r"ppt/slides/slide[0-9]+\.xml", n)]
            notes = [n for n in archive.namelist() if re.fullmatch(r"ppt/notesSlides/notesSlide[0-9]+\.xml", n)]
            self.assertEqual(len(slides), 13)
            self.assertEqual(len(notes), 13)
            ns = {"a": "http://schemas.openxmlformats.org/drawingml/2006/main"}
            for name in slides:
                tree = ET.fromstring(archive.read(name))
                self.assertGreater(len(tree.findall(".//a:t", ns)), 2)
            for name in notes:
                self.assertIn("Quellen:", archive.read(name).decode("utf-8"))


if __name__ == "__main__":
    unittest.main()
