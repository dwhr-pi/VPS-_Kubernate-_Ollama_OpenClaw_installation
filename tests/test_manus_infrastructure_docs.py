"""Offline source-catalogue checks; no infrastructure, package or network access."""
from pathlib import Path
import re
from doc_assertions import assert_prose_in, assert_prose_not_in
import unittest

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs/tutorials/manus-language-infrastructure-sources.md"
GROUPS = {
    "JavaScript und TypeScript": ("nodejs/node", "microsoft/TypeScript", "prettier/prettier",
        "eslint/eslint", "vitest-dev/vitest", "vitejs/vite", "microsoft/playwright", "pnpm/pnpm"),
    "Go": ("golang/go", "golang/tools", "go-delve/delve", "golangci/golangci-lint",
        "actions/checkout", "actions/setup-go"),
    "C und C++": ("gcc-mirror/gcc", "llvm/llvm-project", "kitware/cmake", "google/googletest", "catchorg/Catch2"),
    "Rust": ("rust-lang/rustup", "rust-lang/cargo", "rust-lang/rustfmt",
        "rust-lang/rust-clippy", "rust-lang/rust-analyzer"),
    "Bash": ("koalaman/shellcheck", "mvdan/sh", "bats-core/bats-core", "Trepan-Debuggers/bashdb"),
    "PowerShell": ("PowerShell/PowerShell", "PowerShell/vscode-powershell",
        "PowerShell/PSScriptAnalyzer", "pester/Pester", "nightroman/Invoke-Build"),
    "SQL und Datenbanken": ("postgres/postgres", "flyway/flyway", "sqlfluff/sqlfluff",
        "dbt-labs/dbt-core", "theory/pgtap"),
    "Docker und Container: Referenz, keine Installation": ("docker/cli", "docker/compose",
        "docker/buildx", "moby/buildkit", "hadolint/hadolint", "docker/setup-buildx-action",
        "docker/build-push-action", "docker/login-action"),
    "Kubernetes": ("kubernetes/kubectl", "kubernetes-sigs/kind", "helm/helm",
        "kubernetes-sigs/kustomize", "yannh/kubeconform", "stackrox/kube-linter",
        "GoogleContainerTools/skaffold", "argoproj/argo-cd", "fluxcd/flux2"),
    "Terraform und IaC": ("hashicorp/terraform", "hashicorp/terraform-ls", "terraform-linters/tflint",
        "bridgecrewio/checkov", "terraform-docs/terraform-docs", "gruntwork-io/terratest",
        "hashicorp/setup-terraform"),
}


class ManusInfrastructureDocs(unittest.TestCase):
    def setUp(self):
        self.text = DOC.read_text(encoding="utf-8")

    def test_all_62_sources_have_a_thematic_row(self):
        self.assertEqual(sum(map(len, GROUPS.values())), 62)
        rows = re.findall(r"^\| \[.*$", self.text, re.MULTILINE)
        self.assertEqual(len(rows), 62)
        for section, repos in GROUPS.items():
            body = self.text.split("## " + section + "\n", 1)[1].split("\n## ", 1)[0]
            for repo in repos:
                self.assertIn(f"](https://github.com/{repo})", body)
        self.assertIn("https://github.com/golang/tools/tree/master/gopls", self.text)

    def test_tables_include_purpose_and_limit(self):
        for row in re.findall(r"^\| \[.*$", self.text, re.MULTILINE):
            self.assertEqual(row.count("|"), 4)
            self.assertTrue(all(part.strip() for part in row.split("|")[1:-1]))

    def test_license_mirror_and_redirect_corrections_remain(self):
        for phrase in ("Business Source License 1.1", "Boost Software License 1.0",
                       "https://github.com/opentofu/opentofu", "MPL-2.0",
                       "GCC GitHub-Mirror", "PostgreSQL GitHub-Mirror",
                       "Issue-Tracker/Code-Mirror", "https://github.com/dbt-labs/dbt",
                       "https://gcc.gnu.org/git.html", "https://www.postgresql.org/docs/current/git.html"):
            assert_prose_in(self, phrase, self.text)

    def test_side_effects_and_no_install_boundaries_are_clear(self):
        for phrase in ("Keine neuen Installer", "kein Docker-/WSL-Zugriff",
                       "EXPLAIN ANALYZE", "fuehrt die SQL-Anweisung aus",
                       "kontaktiert den API-Server", "kein Docker-freier Kubernetes-Ersatz",
                       "GitHub statt Docker", "Kosten", "bash -x", "Keine pauschale",
                       "HTTP 403", "nicht vollstaendig verifiziert", "21.10.2026"):
            self.assertIn(phrase, self.text)

    def test_local_links_exist_and_catalog_is_discoverable(self):
        for target in re.findall(r"\]\(([^)]+)\)", self.text):
            if "://" not in target and not target.startswith("#"):
                self.assertTrue((DOC.parent / target.split("#")[0]).is_file(), target)
        for path in ("docs/TOOL_INDEX.md", "docs/tutorials/manus-development-sources.md",
                     "docs/tutorials/manus-development-workflow.md"):
            self.assertIn(DOC.name, (ROOT / path).read_text(encoding="utf-8"))

    def test_no_active_install_or_deploy_command_blocks(self):
        blocks = re.findall(r"```[^\n]*\n(.*?)```", self.text, re.DOTALL)
        self.assertEqual(blocks, [])
        self.assertNotIn("uses: docker/", self.text)
        self.assertNotIn("uses: hashicorp/", self.text)


if __name__ == "__main__":
    unittest.main()
