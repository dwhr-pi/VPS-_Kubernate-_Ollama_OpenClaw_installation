"""Read-only static comparison of documentation, menu and installation catalogs.

Does not import installers, source shell files, inspect user data or use network.
"""
import argparse
from collections import Counter, defaultdict
import json
from pathlib import Path
import re
import shlex


ROOT = Path(__file__).resolve().parents[1]
REPORT = "docs/TOOL_SETUP_AUDIT.md"
STUBS = {
    "planned_tool_stub_install.sh", "hybrid_media_candidate_install.sh",
    "social_media_candidate_install.sh", "video_dataset_candidate_install.sh",
    "media_candidate_install.sh", "audio_review_candidate_install.sh",
}


def norm(value):
    return re.sub(r"[^a-z0-9]", "", str(value).lower())


def repos(text):
    result = set()
    for owner, name in re.findall(
            r"(?<![\w.-])(?:https?://)?github\.com/([\w.-]+)/([\w.-]+)", text, re.I):
        name = name.rstrip(".").removesuffix(".git")
        if owner.lower() not in {"topics", "orgs", "settings", "features"}:
            result.add(f"{owner}/{name}".lower())
    return result


def local_file(root, relative):
    if not relative:
        return False
    path = root / relative
    return path.resolve().is_relative_to(root.resolve()) and path.is_file()


def menu_inventory(text):
    names = []
    for match in re.finditer(r"^TOOL_KEYS\+?=\(([^\n]*)\)", text, re.M):
        names.extend(shlex.split(match[1]))
    mappings = dict(re.findall(
        r'^TOOL_SCRIPT_NAMES\["([^"\n]+)"\]="([^"\n]+)"', text, re.M))
    return names, mappings


def script_state(root, path):
    if not local_file(root, path):
        return "fehlt"
    if Path(path).name in STUBS:
        return "Platzhalter"
    return "Skript vorhanden; Runtime ungeprueft"


def audit(root=ROOT):
    registry = json.loads((root / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
    setup = (root / "setup_ultimate.sh").read_text(encoding="utf-8")
    names, mappings = menu_inventory(setup)
    chains = json.loads((root / "config/development_toolchains.json").read_text(encoding="utf-8"))["tools"]
    recipes = json.loads((root / "config/development_installers.json").read_text(encoding="utf-8"))["recipes"]
    documented = defaultdict(set)
    doc_count = 0
    for path in sorted((root / "docs").rglob("*.md")):
        if path.is_symlink() or any(p.is_symlink() for p in path.parents):
            continue
        relative = path.relative_to(root).as_posix()
        if relative == REPORT:
            continue
        doc_count += 1
        for repo in repos(path.read_text(encoding="utf-8")):
            documented[repo].add(relative)

    rows, matched_menu = [], set()
    source_matches = defaultdict(set)
    for tool in registry:
        path = tool.get("install_script", "")
        menu = [name for name in names if
                norm(name) in {norm(tool["id"]), norm(tool.get("name", ""))}
                or (mappings.get(name) and
                    path == f"scripts/tools/{mappings[name]}_install.sh")]
        matched_menu.update(menu)
        for repo in repos(json.dumps({k: tool.get(k, "") for k in ("source", "github", "url")})):
            source_matches[repo].add("Registry: " + tool["id"])
        lifecycle_missing = [key for key in ("install_script", "uninstall_script", "update_script", "doctor_script")
                             if tool.get(key) and not local_file(root, tool[key])]
        rows.append({"id": tool["id"], "name": tool.get("name", tool["id"]),
                     "menu": menu, "script": path, "script_state": script_state(root, path),
                     "status": tool.get("status", "nicht angegeben"),
                     "mode": tool.get("install_mode", "nicht angegeben"),
                     "doc": tool.get("doc", ""), "missing_files": lifecycle_missing,
                     "doc_missing": bool(tool.get("doc") and not local_file(root, tool["doc"]))})
    menu_only = []
    for name in names:
        path = f"scripts/tools/{mappings[name]}_install.sh" if name in mappings else ""
        # Direct literal URLs in menu installers supply additional provenance.
        if local_file(root, path):
            for repo in repos((root / path).read_text(encoding="utf-8")):
                source_matches[repo].add("Menue: " + name)
        if name not in matched_menu:
            menu_only.append({"name": name, "script": path,
                              "script_state": script_state(root, path)})
    chain_rows = []
    for tool in chains:
        recipe = recipes.get(tool["id"])
        for repo in repos(tool.get("source", "")):
            source_matches[repo].add("62er-Katalog: " + tool["id"])
        missing = []
        if recipe and recipe.get("mode") == "existing":
            missing = [p for p in recipe.get("scripts", {}).values() if not local_file(root, p)]
        chain_rows.append({"id": tool["id"], "name": tool["name"],
                           "mode": recipe.get("mode", "Rezept fehlt") if recipe else "Rezept fehlt",
                           "missing_files": missing})
    refs = [{"repo": repo, "docs": sorted(paths), "matches": sorted(source_matches.get(repo, set()))}
            for repo, paths in sorted(documented.items())]
    counts = {"docs": doc_count, "registry": len(rows), "menu": len(names),
              "registry_without_menu": sum(not t["menu"] for t in rows),
              "menu_without_registry": len(menu_only),
              "registry_placeholders": sum(t["script_state"] == "Platzhalter" for t in rows),
              "chain_recipes": sum(t["mode"] != "Rezept fehlt" for t in chain_rows),
              "chain_total": len(chain_rows), "documented_repositories": len(refs),
              "unmatched_repositories": sum(not t["matches"] for t in refs)}
    return {"counts": counts, "registry": rows, "menu_only": menu_only,
            "development_catalog": chain_rows, "documentation_repositories": refs,
            "duplicate_registry_ids": sorted(k for k, v in Counter(t["id"] for t in rows).items() if v > 1),
            "duplicate_menu_keys": sorted(k for k, v in Counter(names).items() if v > 1)}


def cell(value):
    return str(value).replace("|", "\\|").replace("\n", " ")


def markdown(data):
    lines = ["# Dokumentation und Setup: Vollstaendigkeitsabgleich", "",
             "Statischer Repository-Abgleich, Stand 22.10.2026. Neu erzeugen:", "",
             "```text", "python -B scripts/audit_tool_coverage.py --output docs/TOOL_SETUP_AUDIT.md", "```", "",
             "**Nein, nicht alle dokumentierten Werkzeuge sind als installierbare Tools integriert.**",
             "Dieser Bericht liest nur Repository-Dateien, startet weder Setup noch WSL und prueft",
             "keine tatsaechlich installierte Software, Downloads, Builds, Provider oder Dienste.", "",
             "## Ergebnis", "", "| Messwert | Anzahl |", "|---|---|"]
    labels = {"docs": "Gelesene Markdown-Dateien (Bericht selbst ausgenommen)",
              "registry": "Registry-Eintraege", "menu": "Explizite Tools-Menueeintraege",
              "registry_without_menu": "Registry ohne Tools-Menueeintrag",
              "menu_without_registry": "Tools-Menue ohne Registry-Zuordnung",
              "registry_placeholders": "Registry mit bekanntem Installationsplatzhalter",
              "chain_recipes": "Rezepte im separaten Entwicklungskatalog",
              "chain_total": "Quellen im Entwicklungskatalog",
              "documented_repositories": "Eindeutige GitHub-Repositories in der Dokumentation",
              "unmatched_repositories": "GitHub-Referenzen ohne direkte Quellenzuordnung"}
    lines += [f"| {labels[k]} | {v} |" for k, v in data["counts"].items()]
    lines += ["", "## So sind die Ergebnisse zu lesen", "",
              "- Hauptmenue 8 zeigt die explizite Tools-Liste aus setup_ultimate.sh, nicht automatisch die Registry.",
              "- Die 62 Entwicklungsquellen sind separat ueber Hauptmenue 16 bzw. die Zusatzschaltflaeche im Tools-Menue erreichbar.",
              "- Registry-only bedeutet nicht automatisch fehlender Installer: alternative Skripte/Projektwege separat pruefen.",
              "- Ein vorhandenes Skript beweist weder eine vollstaendige Installation noch eine nutzbare Runtime. Source-only, VSIX, manuelle Downloads und optionale Builds bleiben unterschiedliche Modi.",
              "- Ein bekannter Platzhalter ist kein Installer. Status planned kann aber auch bei einem echten Skript veraltet sein.",
              "- GitHub-Referenzen umfassen Bibliotheken, Actions, Modelle, Mirrors und Beispiele. Nicht zugeordnete Referenzen sind Pruefkandidaten, keine automatische Liste fehlender Programme.",
              "- Verglichen werden explizite Bash-Arrays/Mappings und direkte Quellen-URLs. Textnennungen ohne GitHub-Link, historische Umbenennungen und indirekte Helper-URLs sind nicht vollstaendig semantisch aufloesbar.",
              "- Keine Installationsbereitschaft aus einem Dateinamen ableiten; diesen Bericht nicht als Live-Abnahme verwenden.", "",
              "## Registry ohne Eintrag im Tools-Menue", "", "| ID | Installationsweg | Umfang |", "|---|---|---|"]
    lines += [f"| {cell(t['id'])} | {cell(t['script'])} | {cell(t['script_state'])} |"
              for t in data["registry"] if not t["menu"]]
    lines += ["", "## Tools-Menue ohne Registry-Zuordnung", "", "| Menueeintrag | Tatsaechliches Skript | Umfang |", "|---|---|---|"]
    lines += [f"| {cell(t['name'])} | {cell(t['script'])} | {cell(t['script_state'])} |" for t in data["menu_only"]]
    lines += ["", "## Alle Registry-Eintraege", "", "| ID | Tools-Menue | Status / Modus | Installationsskript / Umfang |", "|---|---|---|---|"]
    for t in data["registry"]:
        notes = "; fehlende Dateien: " + ", ".join(t["missing_files"]) if t["missing_files"] else ""
        if t["doc_missing"]:
            notes += "; Dokumentationsdatei fehlt"
        lines.append(f"| {cell(t['id'])} | {cell(', '.join(t['menu']) or 'nein')} | {cell(t['status'] + ' / ' + t['mode'])} | {cell(t['script'] + ': ' + t['script_state'] + notes)} |")
    lines += ["", "## Separater Entwicklungskatalog", "", "Nur Rezept-/Dateizuordnung, keine Build-Abnahme. workflow-package aktiviert keine CI und editor-package keinen Editor.", "", "| Quelle | ID | Rezeptmodus | Dateiverweise |", "|---|---|---|---|"]
    lines += [f"| {cell(t['name'])} | {cell(t['id'])} | {cell(t['mode'])} | {cell(', '.join(t['missing_files']) or 'keine fehlenden Adapter-Dateien')} |" for t in data["development_catalog"]]
    lines += ["", "## Dokumentierte GitHub-Quellen", "",
              "Vollstaendige Liste der erkannten Repository-URLs. Bis zu drei Fundstellen pro Quelle;",
              "mit --format json sind alle Fundstellen verfuegbar. Leere Zuordnung ist keine Installationszusage.", "",
              "| Quelle | Zuordnung | Dokumentationsfundstellen |", "|---|---|---|"]
    for t in data["documentation_repositories"]:
        docs = ", ".join(f"[{p}]({Path(p).relative_to('docs').as_posix()})" for p in t["docs"][:3])
        lines.append(f"| [{t['repo']}](https://github.com/{t['repo']}) | {cell('; '.join(t['matches']) or 'Keine direkte Zuordnung; manuell pruefen')} | {docs} |")
    lines += ["", "## Strukturfehler", "",
              "Doppelte Registry-IDs: " + (", ".join(data["duplicate_registry_ids"]) or "keine"),
              "", "Doppelte Menue-Keys: " + (", ".join(data["duplicate_menu_keys"]) or "keine"), ""]
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--format", choices=("markdown", "json"), default="markdown")
    parser.add_argument("--output", type=Path, help="Explizit erzeugte Berichtsdatei; Standard ist stdout.")
    args = parser.parse_args()
    result = audit()
    output = json.dumps(result, ensure_ascii=True, indent=2) + "\n" if args.format == "json" else markdown(result)
    if args.output:
        args.output.write_text(output, encoding="utf-8")
        print(json.dumps(result["counts"], ensure_ascii=True))
    else:
        print(output, end="")


if __name__ == "__main__":
    main()
