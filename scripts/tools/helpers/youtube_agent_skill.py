"""Install upstream YouTube skills from a pinned GitHub checkout; never run them."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys

from find_skills import checked, operation, resources
from offload_sources import fetch, verify

URL = "https://github.com/Jakeschincariol/youtube-agent-skill.git"
PIN = "a2feb2104981a375ffd4f87ee04f4f5344ac43c6"
SKILLS = ("yt-script", "yt-package", "yt-edit", "yt-comment", "yt-plan", "yt-viral",
          "yt-retention", "yt-shorts", "yt-seo", "yt-chapters", "yt-audit")
HELPERS = ("yt-script/hookscore.py", "yt-package/title.py", "yt-edit/deadair.py",
           "yt-chapters/chapters.py", "yt-retention/retention.py", "yt-viral/swipe.py")
FILES = tuple(name + "/SKILL.md" for name in SKILLS) + HELPERS + ("yt-script/hooks.json",)
SPEC = {"url": URL, "pin": PIN, "module": "skills/yt-script/SKILL.md",
        "files": ("LICENSE", "README.md", "templates/voice.md") +
        tuple("skills/" + name for name in FILES)}


def layout():
    raw = Path(os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data")))
    if not raw.is_absolute() or raw == Path(raw.anchor):
        raise ValueError("Absoluten externen User-Workspace angeben.")
    base = checked(raw / "tools/youtube_agent_skill")
    return base, checked(base / "source"), checked(base / "skills-ready.json")


def target_for(project, require_existing=False):
    root = Path(project) if project else Path.home()
    if not root.is_absolute() or root == Path(root.anchor):
        raise ValueError("Projektpfad muss absolut sein und darf nicht die Dateisystemwurzel sein.")
    if project and require_existing and not checked(root).is_dir():
        raise ValueError("Projektordner muss bereits existieren.")
    return checked(root / ".claude/skills")


def digest(path):
    return hashlib.sha256(checked(path).read_bytes()).hexdigest()


def source_ok(source):
    verify(source, SPEC)
    for name in SKILLS:
        if not re.search(r"(?m)^name:\s*" + re.escape(name) + r"\s*$",
                         (source / "skills" / name / "SKILL.md").read_text(encoding="utf-8")):
            raise ValueError("Unerwarteter Skill-Name in GitHub-Quelle.")
    for name in SPEC["files"]:
        if (source / name).stat().st_size == 0:
            raise ValueError("Leere GitHub-Quelldatei.")


def read_record(marker):
    if not marker.exists():
        return None
    data = json.loads(marker.read_text(encoding="utf-8"))
    if (not isinstance(data, dict) or data.get("commit") != PIN or
            data.get("scope") != "claude-skills" or data.get("runtime_tested") is not False or
            "project" not in data or (data["project"] is not None and not isinstance(data["project"], str)) or
            not isinstance(data.get("hashes"), dict) or set(data["hashes"]) != set(FILES) or
            not all(re.fullmatch(r"[a-f0-9]{64}", str(value)) for value in data["hashes"].values())):
        raise ValueError("Unbekannter Besitznachweis; keine Dateien ueberschreiben/loeschen.")
    target_for(data["project"])
    return data


def verify_owned(target, record, allow_missing=False):
    for skill in SKILLS:
        folder = checked(target / skill)
        expected = {Path(name).name for name in FILES if name.startswith(skill + "/")}
        if folder.exists():
            if not folder.is_dir():
                raise ValueError("Fremder Skill-Pfad; bleibt erhalten.")
            for item in folder.iterdir():
                checked(item)
                if item.name not in expected or not item.is_file():
                    raise ValueError("Zusaetzliche Skill-Dateien; vor Deinstallation/Reparatur sichern.")
    for name, checksum in record["hashes"].items():
        path = checked(target / name)
        if allow_missing and not path.exists():
            continue
        if not path.is_file() or digest(path) != checksum:
            raise ValueError("Skill lokal veraendert/unvollstaendig; keine persoenlichen Dateien ersetzen.")


def consent(source, target, accepted):
    print((source / "LICENSE").read_text(encoding="utf-8"))
    print("Skills:", ", ".join(SKILLS), "Ziel:", target)
    print("Pruefbare Anweisungen:", source / "skills")
    print("Fremde Skill-Anweisungen koennen Agenten zu Werkzeug-/Netzwerkaufrufen auffordern.")
    print("Keine Sandbox oder MCP-Anbindung. Installer fuehrt keine Python-Helfer/Agenten aus.")
    policy = "1" if accepted else os.environ.get("YOUTUBE_AGENT_SKILL_ACCEPT", "ask")
    if policy not in ("ask", "0", "1"):
        raise ValueError("YOUTUBE_AGENT_SKILL_ACCEPT: nur ask, 0 oder 1.")
    if policy == "ask":
        accepted = sys.stdin.isatty() and input("Diese elf Skills aktivieren? [(j)a/(N)ein]: ").strip().lower() == "j"
    else:
        accepted = policy == "1"
    if not accepted:
        raise ValueError("Nicht akzeptiert; nur Quelle zur Pruefung erhalten, keine Aktivierung.")


def activate(source, target, marker, project, record):
    created, directories = [], []
    voice = checked(Path.home() / ".claude/youtube/voice.md")
    try:
        target.mkdir(parents=True, exist_ok=True, mode=0o700)
        for skill in SKILLS:
            folder = checked(target / skill)
            if not folder.exists():
                folder.mkdir(mode=0o700)
                directories.append(folder)
        for name in FILES:
            path = checked(target / name)
            if record and path.exists():
                continue
            with path.open("xb") as stream:
                created.append(path)
                stream.write((source / "skills" / name).read_bytes())
            path.chmod(0o600)
        if not voice.exists():
            voice.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
            with voice.open("xb") as stream:
                created.append(voice)
                stream.write((source / "templates/voice.md").read_bytes())
            voice.chmod(0o600)
            print("voice.md-Vorlage angelegt; bitte selbst ausfuellen:", voice)
        else:
            print("Vorhandene voice.md bleibt unveraendert.")
        if not record:
            data = {"commit": PIN, "scope": "claude-skills", "runtime_tested": False,
                    "project": project, "hashes": {name: digest(target / name) for name in FILES}}
            with marker.open("x", encoding="utf-8") as stream:
                created.append(marker)
                json.dump(data, stream)
            marker.chmod(0o600)
    except Exception:
        for path in reversed(created):
            path.unlink()
        for folder in reversed(directories):
            folder.rmdir()
        print("Rollback: nur neue Dateien dieses Versuchs entfernt; Quelle/Logs bleiben.")
        raise


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", nargs="?", default="install",
                        choices=("install", "update", "repair", "uninstall", "status", "check", "doctor", "plan"))
    parser.add_argument("--project", help="Vorhandener absoluter Projektordner statt globaler Skills")
    parser.add_argument("--accept", action="store_true", help="Gepruefte Skill-Aktivierung bewusst bestaetigen")
    parser.add_argument("--source-only", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    modes = parser.add_mutually_exclusive_group()
    for mode in ("repair", "uninstall", "check", "status"):
        modes.add_argument("--" + mode, dest="override", action="store_const", const=mode)
    opts = parser.parse_args(argv)
    if opts.override:
        if opts.action not in ("install", opts.override):
            parser.error("Widerspruechliche Aktionen.")
        opts.action = opts.override
    base, source, marker = layout()
    if opts.dry_run or opts.action == "plan":
        print("YouTube_Agent_Skill:", opts.action, URL, PIN, "Ziel:", target_for(opts.project))
        print("11 Skills, 6 Python-Helfer; nur Quellen" if opts.source_only else "11 Skills, 6 Python-Helfer; Aktivierung nach Zustimmung.")
        print("Kein Docker/pip/MCP/Login/Upload/Agentenstart; vorhandene voice.md bleibt erhalten.")
        return 0
    record = read_record(marker)
    project = opts.project if opts.project is not None else (record["project"] if record else None)
    target_for(project, require_existing=not record and not opts.source_only and
               opts.action in ("install", "update", "repair"))
    project = str(checked(Path(project))) if project else None
    target = target_for(project)
    if record and project != record["project"]:
        raise ValueError("Anderes Ziel registriert; zuerst bewusst deinstallieren.")
    if opts.action in ("status", "check", "doctor"):
        ready = False
        try:
            if record:
                source_ok(source)
                verify_owned(target, record)
                ready = True
        except (ValueError, OSError, subprocess.SubprocessError):
            pass
        print(json.dumps({"installed": ready, "scope": "claude-skills", "runtime_tested": False}))
        return 0 if ready or opts.action == "status" else 1
    with operation(base, opts.action, tool="YouTube_Agent_Skill"):
        print("GitHub:", URL, "Pin:", PIN)
        if record:
            verify_owned(target, record, allow_missing=opts.action in ("repair", "uninstall"))
        if opts.action == "uninstall":
            if record:
                for name in FILES:
                    path = checked(target / name)
                    if path.exists():
                        path.unlink()
                for skill in SKILLS:
                    folder = target / skill
                    if folder.exists():
                        folder.rmdir()
                marker.unlink()
            print("Nur eigene unveraenderte Skills entfernt; voice.md, andere Skills, Quellen, Logs und CLIs bleiben.")
            return 0
        if record and opts.action != "repair":
            source_ok(source)
            print("Gepinnte Skills bereits installiert; kein Download/Upgrade.")
            return 0
        if not record and not opts.source_only:
            for skill in SKILLS:
                if checked(target / skill).exists():
                    raise ValueError("Vorhandenen fremden Skill nicht ueberschreiben: " + skill)
        resources(base, target)
        fetch(base, source, SPEC)
        source_ok(source)
        if opts.source_only:
            print("Nur GitHub-Quelle vorbereitet; kein installierter Skill, kein Marker.")
            return 0
        if record and any(digest(source / "skills" / name) != checksum for name, checksum in record["hashes"].items()):
            raise ValueError("Quelle stimmt nicht mit Besitznachweis ueberein; keine Reparatur.")
        consent(source, target, opts.accept)
        activate(source, target, marker, project, record)
        print("11 YouTube-Skills aus GitHub installiert. Claude Code neu laden und /yt-script manuell pruefen.")
        print("Kein Funktionsnachweis fuer Claude, Qwen, Hermes, Ollama, OpenClaw oder Open WebUI.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print("YouTube_Agent_Skill:", error, file=sys.stderr)
        sys.exit(1)
