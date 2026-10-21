"""Read-only local preflight for the 62 development sources; never installs tools."""
import argparse
from collections import Counter
import ctypes
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import sys

ROOT = Path(__file__).resolve().parents[2]
LABELS = {
    "preflight-ok": "VORPRUEFUNG OK",
    "blocked": "VORAUSSETZUNGEN FEHLEN",
    "no-installer": "KEIN SETUP-INSTALLER",
    "registered-review": "INSTALLER VORHANDEN / PRUEFEN",
    "project": "PROJEKTABHAENGIGKEIT",
    "workflow": "CI-WORKFLOW-BAUSTEIN",
    "extension": "EDITOR-ERWEITERUNG",
    "build-recipe": "BUILD-/PAKETREZEPT VORHANDEN",
}
REVIEWED = {"sqlfluff", "bats_core", "invoke_build", "golang_tools", "delve",
            "golangci_lint", "kubeconform", "kubelinter", "tflint", "terraform_docs"}


def load_catalog(root=ROOT):
    data = json.loads((root / "config/development_toolchains.json").read_text(encoding="utf-8"))
    tools = data["tools"]
    ids = set()
    for row in tools:
        if (not re.fullmatch(r"[a-z0-9_]+", row["id"]) or row["id"] in ids or
                not re.fullmatch(r"https://github.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", row["source"]) or
                row["kind"] not in ("cli", "toolchain", "runtime", "project", "workflow", "extension") or
                not isinstance(row["disk_mb"], int) or row["disk_mb"] < 0 or
                not isinstance(row["ram_mb"], int) or row["ram_mb"] < 0):
            raise ValueError("Ungueltiger oder doppelter Pruefkatalogeintrag.")
        ids.add(row["id"])
        if not all(isinstance(group, list) and group and
                   all(isinstance(name, str) and re.fullmatch(r"[A-Za-z0-9+_.-]+", name) for name in group)
                   for group in row["requirements"]):
            raise ValueError("Ungueltige Voraussetzung im Pruefkatalog.")
    return tools


def resources():
    raw = Path(os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data")))
    if not raw.is_absolute() or raw == Path(raw.anchor):
        raise ValueError("OPENCLAW_USER_DATA_DIR muss ein absoluter User-Pfad sein, nicht die Dateisystemwurzel.")
    target = raw
    while not target.exists():
        target = target.parent
    free = shutil.disk_usage(target).free // 1024**2
    ram = None
    if os.name == "nt":
        class MemoryStatus(ctypes.Structure):
            _fields_ = [("length", ctypes.c_ulong), ("load", ctypes.c_ulong)] + [
                (name, ctypes.c_ulonglong) for name in
                ("total_physical", "available_physical", "total_page", "available_page",
                 "total_virtual", "available_virtual", "available_extended")]
        status = MemoryStatus()
        status.length = ctypes.sizeof(status)
        if ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(status)):
            ram = status.available_physical // 1024**2
    elif Path("/proc/meminfo").is_file():
        for line in Path("/proc/meminfo").read_text().splitlines():
            if line.startswith("MemAvailable:"):
                ram = int(line.split()[1]) // 1024
    host = None
    if os.environ.get("WSL_DISTRO_NAME") and Path("/mnt/c").is_dir():
        host = shutil.disk_usage("/mnt/c").free // 1024**2
    return {"disk_mb": free, "ram_mb": ram, "windows_c_mb": host,
            "wsl_detected": bool(os.environ.get("WSL_DISTRO_NAME"))}


def executable_present(name):
    overrides = {"go": "DEV_GO_BIN", "bash": "BATS_BASH_BIN", "pwsh": "INVOKE_BUILD_PWSH_BIN"}
    variable = overrides.get(name)
    path = shutil.which(os.environ.get(variable, name) if variable else name)
    if not path:
        return False
    # Do not mistake Windows' compatibility launcher for native Bash.
    if os.name == "nt" and name == "bash":
        location = Path(path).resolve()
        system = os.environ.get("SystemRoot")
        if (location.name.lower() == "wsl.exe" or
                "windowsapps" in {part.lower() for part in location.parts} or
                (system and location.parent in (Path(system) / "System32", Path(system) / "Sysnative"))):
            return False
    return True


def adapter_for(row, registry, root=ROOT):
    recipes_path = root / "config/development_installers.json"
    if recipes_path.is_file():
        recipe = json.loads(recipes_path.read_text(encoding="utf-8"))["recipes"].get(row["id"])
        if recipe and recipe["mode"] != "existing":
            return {"path": "scripts/install_development_toolchain.sh", "mode": recipe["mode"],
                    "reviewed": False, "recipe": recipe}
    registered = next((tool for tool in registry if tool.get("id") == row.get("registry_id")), None)
    if not registered:
        return None
    value = registered.get("install_script", "")
    path = root / value
    if (not value or path.is_symlink() or not path.resolve().is_relative_to(root.resolve()) or
            not path.is_file() or "stub" in path.name or registered.get("status") in ("planned", "documentation-first")):
        return None
    return {"path": value, "mode": registered.get("install_mode", "nicht klassifiziert"),
            "reviewed": row["id"] in REVIEWED}


def inspect(row, registry, budget, available, root=ROOT):
    adapter = adapter_for(row, registry, root)
    recipe = adapter.get("recipe") if adapter else None
    requirements = recipe["requirements"] if recipe else row["requirements"]
    missing = [" oder ".join(group) for group in requirements
               if not any(available(name) for name in group)]
    warnings = ["Versionen, transitive Pakete, Lizenz und echter Build noch ungeprueft."]
    blockers = []
    if row["id"] in REVIEWED:
        if sys.version_info < (3, 10):
            blockers.append("Setup-Pruefer/Installer benoetigt Python >=3.10.")
        if row["id"] == "sqlfluff":
            if sys.version_info[:2] > (3, 13):
                blockers.append("SQLFluff-Pin: vorhandenes Python 3.10-3.13 waehlen.")
            for name in ("venv", "ensurepip", "ssl"):
                if importlib.util.find_spec(name) is None:
                    blockers.append("Python-Modul fehlt: " + name)
        # The installer is already executed with this interpreter, so it does
        # not need another Python found through PATH.
        missing = [value for value in missing if value != "python3 oder python"]
    if row["kind"] not in ("project", "workflow", "extension") or recipe:
        disk = max(row["disk_mb"], recipe.get("disk_mb", 1024) if recipe else 0)
        ram = max(row["ram_mb"], recipe.get("ram_mb", 512) if recipe else 0)
        if budget["disk_mb"] < disk:
            blockers.append("Ziel-Disk unter Reserve: " + str(disk) + " MiB.")
        if budget["ram_mb"] is not None and budget["ram_mb"] < ram:
            blockers.append("Verfuegbarer RAM unter Richtwert: " + str(ram) + " MiB.")
        if budget["windows_c_mb"] is not None and budget["windows_c_mb"] < disk:
            blockers.append("Windows-C: unter Reserve; WSL-Zahl allein reicht nicht.")
    if budget["ram_mb"] is None:
        warnings.append("Verfuegbarer RAM nicht ermittelt.")
    if row.get("go_min"):
        warnings.append("Go-Version >= " + row["go_min"] + " wird erst im echten Installer geprueft.")
    if (row.get("heavy") or recipe and recipe.get("heavy")) and os.environ.get("INSTALL_HEAVY_TOOLS") != "1":
        blockers.append("Schwerer Build: INSTALL_HEAVY_TOOLS=1 fehlt.")
    if budget["wsl_detected"]:
        warnings.append("Tatsaechlicher VHDX-Speicherort unbekannt; /mnt/c ist nur ein konservativer Hinweis.")
    if recipe:
        warnings.append("Neues privates Rezept; noch kein echter Upstream-Build-/Runtime-Nachweis. Ausfuehrung auf Linux/macOS.")
        if os.name == "nt":
            blockers.append("Neue Buildrezepte nicht nativ unter Windows ausfuehren; WSL wird nicht gestartet.")
        status = "blocked" if missing or blockers else "build-recipe"
    elif row["kind"] in ("project", "workflow", "extension"):
        status = row["kind"]
    elif not adapter:
        status = "no-installer"
    elif not adapter["reviewed"]:
        status = "registered-review"
        warnings.append("Bestehender Adapter: Installationsweg/Versionen separat pruefen; keine GitHub-only-Zusage.")
    else:
        status = "blocked" if missing or blockers else "preflight-ok"
    return {**row, "status": status, "label": LABELS[status], "missing": missing,
            "blockers": blockers, "warnings": warnings, "adapter": adapter,
            "installation_tested": False, "can_attempt_setup": status in ("preflight-ok", "build-recipe")}


def report(rows, budget, registry, root=ROOT):
    cache = {}

    def available(name):
        if name not in cache:
            cache[name] = executable_present(name)
        return cache[name]

    results = [inspect(row, registry, budget, available, root) for row in rows]
    return {"scope": "offline-preflight", "network_accessed": False, "installed": False,
            "resources": budget, "counts": dict(Counter(row["status"] for row in results)),
            "tools": results}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tool", help="Katalog-ID, z.B. sqlfluff oder delve")
    parser.add_argument("--group", help="Exakter Gruppenname aus --list")
    parser.add_argument("--list", action="store_true")
    parser.add_argument("--json", action="store_true")
    parser.add_argument("--strict", action="store_true", help="Exit 1 bei fehlendem Adapter/offenen Voraussetzungen")
    args = parser.parse_args(argv)
    rows = load_catalog()
    if args.tool:
        rows = [row for row in rows if row["id"] == args.tool]
    if args.group:
        rows = [row for row in rows if row["group"] == args.group]
    if not rows:
        parser.error("Keine passende Quelle; --list zeigt IDs und Gruppen.")
    if args.list:
        for row in rows:
            print(row["id"], "|", row["group"], "|", row["name"])
        return 0
    registry = json.loads((ROOT / "config/tools.yml").read_text(encoding="utf-8"))["tools"]
    result = report(rows, resources(), registry)
    if args.json:
        print(json.dumps(result, ensure_ascii=True, indent=2))
    else:
        print("SPRACHEN, SHELLS UND INFRASTRUKTUR:", len(rows), "Quellen pruefen")
        print("Nur lokale Vorpruefung: kein Download, Toolstart, WSL-Aufruf oder Installed-Marker.")
        print("Ein OK ist KEIN erfolgreicher Build und keine Installationsgarantie.")
        print("Disk frei (MiB):", result["resources"]["disk_mb"], "| RAM frei (MiB):", result["resources"]["ram_mb"])
        for row in result["tools"]:
            print("\n[" + row["label"] + "]", row["name"], "(" + row["id"] + ")")
            print("  GitHub:", row["source"])
            print("  Zweck:", row["purpose"])
            if row["adapter"]:
                print("  Vorhandener Installer:", row["adapter"]["path"])
            if row["missing"]:
                print("  Fehlende lokale Werkzeuge:", ", ".join(row["missing"]))
            for item in row["blockers"]:
                print("  Hinderungsgrund:", item)
            for item in row["warnings"]:
                print("  Hinweis:", item)
            print("  Grenze:", row["note"])
        print("\nZusammenfassung:", json.dumps(result["counts"], ensure_ascii=True))
        print("Anleitung: docs/tools/development-toolchain-check.md")
        print("Praesentation: docs/presentations/technology-tooling-overview.pptx")
    return int(args.strict and any(not row["can_attempt_setup"] for row in result["tools"]
                                  if row["kind"] not in ("project", "workflow", "extension")))


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, TypeError) as exc:
        print("Pruefkatalog nicht auswertbar:", str(exc), file=sys.stderr)
        sys.exit(2)
