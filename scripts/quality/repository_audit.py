"""Read-only repository audit: no imports of project code, services or network."""
import argparse
import ast
from collections import Counter
import json
import os
from pathlib import Path
import posixpath
import re
import sys
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[2]
SKIP = {".git", "node_modules", ".venv", "venv", "__pycache__", "dist", "build",
        ".codex-build", ".pytest_cache", ".ruff_cache"}
STATUSES = {"planned", "optional", "experimental", "stable", "beta", "heavy", "manual", "documentation-first"}


class Audit:
    def __init__(self, root):
        self.root = Path(root).resolve()
        self.issues = []
        self.counts = {}
        self.directory_names = {}

    def exact_path_case(self, value):
        # Use real directory entries even on case-insensitive Windows volumes.
        relative = Path(posixpath.normpath(value))
        if relative.is_absolute() or relative.drive or '..' in relative.parts:
            return False
        parent = self.root
        for part in relative.parts:
            try:
                if parent not in self.directory_names:
                    self.directory_names[parent] = {entry.name for entry in parent.iterdir()}
            except OSError:
                return False
            if part not in self.directory_names[parent]:
                return False
            parent = parent / part
        return True

    def issue(self, level, code, path):
        # Never print document contents, environment variables or secret values.
        self.issues.append({"level": level, "code": code, "path": str(path)})

    def registry(self):
        tables = {}
        for name in ("tools", "profiles", "ports"):
            file = f"config/{name}.yml"
            try:
                data = json.loads((self.root / file).read_text(encoding="utf-8-sig"))
                rows = data[name]
                if not isinstance(rows, list) or any(not isinstance(row, dict) for row in rows):
                    raise ValueError
            except (OSError, UnicodeError, ValueError, KeyError, TypeError):
                self.issue("error", "invalid-registry", file)
                continue
            tables[name] = rows
            self.counts[name] = len(rows)
        for name in ("tools", "profiles"):
            rows = tables.get(name, [])
            seen = set()
            for i, row in enumerate(rows):
                where = f"config/{name}.yml#{i + 1}"
                ident = row.get("id")
                if not isinstance(ident, str) or not re.fullmatch(r"[A-Za-z0-9_-]+", ident):
                    self.issue("error", "invalid-id", where)
                elif ident in seen:
                    self.issue("error", "duplicate-id", where)
                else:
                    seen.add(ident)
                status = row.get("status")
                if status is None:
                    self.issue("warning", "missing-status", where)
                elif not isinstance(status, str) or status not in STATUSES:
                    self.issue("error", "invalid-status", where)
                if "auto_install" in row and not isinstance(row["auto_install"], bool):
                    self.issue("error", "invalid-auto-install", where)
                fields = ("doc", "install_script", "uninstall_script", "update_script", "doctor_script") if name == "tools" else ("doc", "install", "uninstall")
                for field in fields:
                    value = row.get(field)
                    if not value:
                        if name == "profiles" and field == "doc":
                            self.issue("error", "missing-doc", where)
                        elif field in ("doc", "update_script", "doctor_script"):
                            self.issue("warning", "missing-" + field, where)
                        elif name == "tools":
                            self.issue("error", "missing-" + field, where)
                        continue
                    if not isinstance(value, str):
                        self.issue("error", "invalid-path", where + "/" + field)
                        continue
                    candidate = self.root / value
                    if (Path(value).is_absolute() or re.match(r"^[A-Za-z]:", value) or "\\" in value or
                            not candidate.resolve().is_relative_to(self.root)):
                        self.issue("error", "unsafe-path", where + "/" + field)
                    elif not candidate.is_file():
                        self.issue("error", "missing-file", where + "/" + field)
                    elif not self.exact_path_case(value):
                        self.issue("error", "registry-path-case-mismatch", where + "/" + field)
                if name == "tools":
                    if not row.get("check_type") or not row.get("check_value"):
                        self.issue("error", "missing-install-check", where)
                    if "source_commit" in row and not re.fullmatch(r"[0-9a-f]{40}", str(row["source_commit"])):
                        self.issue("error", "invalid-source-pin", where)
                    if row.get("install_mode") == "github-source-only" and (row.get("auto_install") is not False or row.get("ports") != []):
                        self.issue("error", "source-only-policy", where)
                    for field in ("source", "github"):
                        if row.get(field):
                            try:
                                url = urlsplit(str(row[field]))
                                if url.username or url.password:
                                    self.issue("error", "credential-in-source-url", where)
                            except ValueError:
                                self.issue("error", "invalid-source-url", where)
                else:
                    refs = row.get("tools", [])
                    if not isinstance(refs, list) or any(not isinstance(ref, str) for ref in refs):
                        self.issue("error", "invalid-tool-references", where)
                    else:
                        known = {r["id"] for r in tables.get("tools", []) if isinstance(r.get("id"), str)}
                        for ref in refs:
                            if ref not in known:
                                self.issue("error", "unknown-tool-reference", where)
        seen_ports = set()
        for i, row in enumerate(tables.get("ports", [])):
            port = row.get("port")
            where = f"config/ports.yml#{i + 1}"
            if type(port) is not int or not 1 <= port <= 65535:
                self.issue("error", "invalid-port", where)
            elif port in seen_ports:
                self.issue("error", "duplicate-port", where)
            else:
                seen_ports.add(port)

    def files(self):
        for directory, dirs, names in os.walk(self.root, followlinks=False):
            dirs[:] = sorted(d for d in dirs if d not in SKIP and not (Path(directory) / d).is_symlink()
                             and not (hasattr(Path(directory) / d, 'is_junction')
                                      and (Path(directory) / d).is_junction()))
            for name in sorted(names):
                file = Path(directory) / name
                if not file.is_symlink():
                    yield file

    def code(self):
        files = [p for p in self.files() if p.suffix == ".py"]
        self.counts["python_files"] = len(files)
        self.counts["python_test_modules"] = sum(p.parent == self.root / "tests" and p.name.startswith("test_") for p in files)
        for file in files:
            try:
                ast.parse(file.read_text(encoding="utf-8-sig"), filename=str(file))
            except (SyntaxError, UnicodeError, OSError):
                self.issue("error", "python-syntax-or-encoding", file.relative_to(self.root))

    def links(self):
        files = list(self.files())
        paths = {p.relative_to(self.root).as_posix() for p in files}
        directories = {"."}
        for path in paths:
            directories.update(parent.as_posix() for parent in Path(path).parents)
        paths.update(directories)
        folded = {p.casefold() for p in paths}
        markdown = [p for p in files if p.suffix.lower() == ".md"]
        self.counts["markdown_files"] = len(markdown)
        for file in markdown:
            rel = file.relative_to(self.root)
            try:
                text = file.read_text(encoding="utf-8-sig")
            except (OSError, UnicodeError):
                self.issue("error", "markdown-encoding", rel)
                continue
            fence = None
            for lineno, line in enumerate(text.splitlines(), 1):
                match = re.match(r"^\s{0,3}(`{3,}|~{3,})", line)
                if match:
                    token = match[1]
                    if fence is None:
                        fence = token
                    elif token[0] == fence[0] and len(token) >= len(fence):
                        fence = None
                    continue
                if fence:
                    continue
                line = re.sub(r"`+[^`]*`+", "", line)
                for target in re.findall(r"\]\((<[^>]+>|[^\s)]+)(?:\s+[^)]*)?\)", line):
                    target = target.strip("<>")
                    if re.match(r"^/?[A-Za-z]:[/\\]", target):
                        self.issue("warning", "nonportable-local-link", f"{rel.as_posix()}:{lineno}")
                        continue
                    # Only local file links, not HTTP, mailto, anchors or examples.
                    if re.match(r"^[A-Za-z][A-Za-z0-9+.-]*:", target) or target.startswith(("#", "//")):
                        continue
                    target = unquote(target.split("#", 1)[0].split("?", 1)[0])
                    if not target or any(c in target for c in ("$", "{", "}", "*")):
                        continue
                    key = posixpath.normpath(target.lstrip("/") if target.startswith("/") else posixpath.join(rel.parent.as_posix(), target))
                    where = f"{rel.as_posix()}:{lineno}"
                    if key == ".." or key.startswith("../"):
                        self.issue("warning", "link-outside-repository", where)
                        continue
                    if key not in paths:
                        self.issue("warning", "link-case-mismatch" if key.casefold() in folded else "missing-local-link", where)
            if fence:
                self.issue("warning", "unclosed-code-fence", rel)

    def result(self):
        totals = Counter(item["code"] for item in self.issues)
        return {"scope": "offline-repository-only", "counts": self.counts,
                "errors": sum(i["level"] == "error" for i in self.issues),
                "warnings": sum(i["level"] == "warning" for i in self.issues),
                "issue_counts": dict(sorted(totals.items())), "issues": self.issues}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--section", choices=("all", "registry", "code", "links"), default="all")
    parser.add_argument("--json", action="store_true", help="JSON only on stdout; no report file is written")
    parser.add_argument("--strict", action="store_true", help="Treat legacy metadata/link warnings as failures")
    args = parser.parse_args(argv)
    audit = Audit(ROOT)
    for section in ("registry", "code", "links"):
        if args.section in ("all", section):
            getattr(audit, section)()
    result = audit.result()
    if args.json:
        print(json.dumps(result, ensure_ascii=True, indent=2))
    else:
        print("Offline-Projektcheck: keine Installation, Netzwerk-, WSL- oder Dienstabfrage.")
        print(json.dumps(result["counts"], ensure_ascii=True))
        print(f'Fehler: {result["errors"]}; Hinweise: {result["warnings"]}')
        for code, count in result["issue_counts"].items():
            print(f"  {code}: {count}")
        print("Dateipositionen: --json; Altlasten streng pruefen: --strict")
    return 1 if result["errors"] or (args.strict and result["warnings"]) else 0


if __name__ == "__main__":
    sys.exit(main())
