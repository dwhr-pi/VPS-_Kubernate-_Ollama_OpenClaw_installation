"""Pinned GitHub skill installer; never launches an agent, npm or skill commands."""
import argparse
from contextlib import contextmanager, redirect_stdout
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time

REPO = Path(__file__).resolve().parents[3]
SOURCE = "https://github.com/vercel-labs/skills.git"
COMMIT = "a80e4c9d12d607631249d4d7d059f835d4b2f13a"
FILES = {"SKILL.md": "skills/find-skills/SKILL.md", "LICENSE": "LICENSE"}
AGENTS = {"claude-code": ".claude", "qwen-code": ".qwen"}


def checked(path):
    path = Path(os.path.abspath(path))
    for item in (path, *path.parents):
        if item.is_symlink() or (item.exists() and
                getattr(item.stat(), "st_file_attributes", 0) & 0x400):
            raise ValueError("Symlink/Junction im Zielpfad; nichts veraendert.")
    if path == REPO or REPO in path.parents:
        raise ValueError("Nutzerdaten/Skills duerfen nicht im Setup-Repository liegen.")
    return path


def layout():
    raw = Path(os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data")))
    if not raw.is_absolute() or raw == Path(raw.anchor):
        raise ValueError("Absoluten externen User-Workspace angeben, nicht Dateisystemwurzel.")
    base = checked(raw / "tools/find_skills")
    return base, checked(base / "source-ready.json")


def target_for(agent):
    return checked(Path.home() / AGENTS[agent] / "skills/find-skills")


def read_record(marker):
    if not marker.exists():
        return None
    data = json.loads(marker.read_text(encoding="utf-8"))
    if data.get("agent") not in AGENTS or data.get("commit") != COMMIT:
        raise ValueError("Unbekannter Status/Pin; zuerst manuell pruefen, kein Ueberschreiben.")
    if set(data.get("hashes", {})) != set(FILES):
        raise ValueError("Unvollstaendiger Besitznachweis; nichts loeschen.")
    return data


def digest(path):
    checked(path)
    return hashlib.sha256(path.read_bytes()).hexdigest()


def git(source, *args):
    result = subprocess.run(["git", "-c", "core.hooksPath=" + os.devnull,
                             "-c", "credential.helper=", "-C", str(source), *args], check=True,
                            capture_output=True, text=True, timeout=180,
                            env={**os.environ, "GIT_TERMINAL_PROMPT": "0", "GIT_LFS_SKIP_SMUDGE": "1"})
    return result.stdout.strip()


def verify_source(source):
    checked(source / ".git")
    if (git(source, "rev-parse", "HEAD") != COMMIT or
            git(source, "remote", "get-url", "origin") != SOURCE or
            git(source, "status", "--porcelain", "--untracked-files=all")):
        raise ValueError("GitHub-Quelle fremd/veraendert; kein Reset oder latest-Upgrade.")
    for name in FILES.values():
        path = checked(source / name)
        if not path.is_file() or path.stat().st_size == 0:
            raise ValueError("Quell-Skill/Lizenz fehlt.")
    if "name: find-skills" not in (source / FILES["SKILL.md"]).read_text(encoding="utf-8"):
        raise ValueError("Unerwarteter Skill-Name.")


def fetch(base):
    source = checked(base / "source")
    if source.exists():
        verify_source(source)
        return source
    stage = Path(tempfile.mkdtemp(prefix="download-", dir=base))
    try:
        git(stage, "init", "--initial-branch=main")
        git(stage, "remote", "add", "origin", SOURCE)
        git(stage, "fetch", "--depth=1", "origin", COMMIT)
        git(stage, "checkout", "--detach", "FETCH_HEAD")
        verify_source(stage)
        stage.rename(source)
    finally:
        # Only this invocation's newly created staging directory is disposable.
        if stage.exists() and checked(stage).parent == checked(base):
            shutil.rmtree(stage)
    return source


def resources(base, target):
    for location in (base, target):
        while not location.exists():
            location = location.parent
        free = shutil.disk_usage(location).free
        print("Freie Disk vor Start (MiB):", free // 1024**2)
        if free < 256 * 1024**2:
            raise ValueError("Speicherplatzmangel: mindestens 256 MiB Reserve erforderlich.")
    if Path("/proc/meminfo").is_file():
        info = dict(line.split(":", 1) for line in Path("/proc/meminfo").read_text().splitlines())
        if int(info["MemAvailable"].split()[0]) < 256 * 1024:
            raise ValueError("Zu wenig verfuegbarer RAM: mindestens 256 MiB Reserve.")
    if os.environ.get("WSL_DISTRO_NAME") and Path("/mnt/c").is_dir():
        free = shutil.disk_usage("/mnt/c").free
        print("Freier Windows-Host-Speicher C: (MiB):", free // 1024**2)
        if free < 512 * 1024**2:
            raise ValueError("Windows-Host-Speicherplatzmangel: mindestens 512 MiB Reserve.")


class Tee:
    def __init__(self, terminal, log):
        self.terminal, self.log = terminal, log

    def write(self, text):
        self.terminal.write(text)
        self.log.write(text)
        self.log.flush()

    def flush(self):
        self.terminal.flush()
        self.log.flush()


@contextmanager
def operation(base, mode, tool="Find_Skills"):
    base.mkdir(parents=True, exist_ok=True, mode=0o700)
    logs = checked(base.parent.parent / "install_logs")
    logs.mkdir(parents=True, exist_ok=True, mode=0o700)
    fd, path = tempfile.mkstemp(prefix=tool.lower() + "_" + mode + "_", suffix=".log", dir=logs)
    with os.fdopen(fd, "w", encoding="utf-8") as log, redirect_stdout(Tee(sys.stdout, log)):
        print(tool + ":", mode, "Log:", path)
        lock = checked(base / "operation.lock")
        locked = False
        started = time.monotonic()
        try:
            lock.mkdir(mode=0o700)
            locked = True
            yield
            print("Ergebnis: success; Dauer(s):", round(time.monotonic() - started))
        except Exception as exc:
            print("Ergebnis: failed;", str(exc))
            raise
        finally:
            if locked:
                lock.rmdir()
            print("Freie Disk nachher (MiB):", shutil.disk_usage(base).free // 1024**2)


def verify_owned(target, record, allow_missing=False):
    if target.exists() and set(p.name for p in target.iterdir()) - set(FILES):
        raise ValueError("Zusaetzliche Skill-Dateien vorhanden; nichts ueberschrieben/geloescht.")
    for name, expected in record["hashes"].items():
        path = checked(target / name)
        if allow_missing and not path.exists():
            continue
        if not path.is_file() or digest(path) != expected:
            raise ValueError("Skill lokal veraendert/unvollstaendig; vor Reparatur sichern.")


def install(base, marker, agent, record):
    target = target_for(agent)
    resources(base, target)
    if record:
        if record["agent"] != agent:
            raise ValueError("Anderer Agent registriert; zuerst bewusst deinstallieren.")
        verify_source(base / "source")
        verify_owned(target, record)
        print("Bereits unveraendert installiert; kein Download/Upgrade.")
        return
    if target.exists() and any(target.iterdir()):
        raise ValueError("Vorhandenen fremden Skill nicht ueberschreiben; manuell pruefen.")
    source = fetch(base)
    print((source / "LICENSE").read_text(encoding="utf-8"))
    print((source / FILES["SKILL.md"]).read_text(encoding="utf-8"))
    print("Ziel:", target)
    print("Skill-Anweisungen koennen Agenten zu Netzwerk-/npx-Aufrufen auffordern.")
    print("Kein technischer Sicherheitsfilter; weitere Skills nur nach Einzelpruefung.")
    policy = os.environ.get("FIND_SKILLS_ACCEPT", "ask")
    if policy == "ask":
        accepted = sys.stdin.isatty() and input("Diesen Skill aktivieren? [(j)a/(N)ein]: ").strip().lower() == "j"
    elif policy in ("0", "1"):
        accepted = policy == "1"
    else:
        raise ValueError("FIND_SKILLS_ACCEPT: nur ask, 0 oder 1.")
    if not accepted:
        raise ValueError("Nicht akzeptiert; keine Agentenaktivierung, Quelle bleibt zur Pruefung.")
    created = []
    made_target = not target.exists()
    try:
        target.mkdir(parents=True, exist_ok=True, mode=0o700)
        for name, relative in FILES.items():
            destination = checked(target / name)
            with destination.open("xb") as stream:
                created.append(destination)
                stream.write((source / relative).read_bytes())
            destination.chmod(0o600)
        data = {"commit": COMMIT, "agent": agent,
                "hashes": {name: digest(target / name) for name in FILES}}
        with marker.open("x", encoding="utf-8") as stream:
            created.append(marker)
            json.dump(data, stream)
        marker.chmod(0o600)
    except Exception:
        for path in reversed(created):
            path.unlink()
        if made_target and target.exists():
            target.rmdir()
        print("Rollback: nur in diesem Versuch neu angelegte Skill-Dateien entfernt.")
        raise
    print("Find_Skills aus GitHub installiert. Agent neu laden; keine CLI/Agentenausfuehrung getestet.")


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", nargs="?", default="install",
                        choices=("install", "update", "repair", "uninstall",
                                 "doctor", "check", "status", "plan"))
    parser.add_argument("--agent", choices=AGENTS, default=os.environ.get("FIND_SKILLS_AGENT"))
    args = list(sys.argv[1:] if argv is None else argv)
    aliases = {"--dry-run": "plan", "--repair": "repair", "--uninstall": "uninstall",
               "--check": "check", "--status": "status"}
    if "--dry-run" in args:
        args.remove("--dry-run")
        if args and args[0] in ("install", "update", "repair", "uninstall", "check", "status", "doctor", "--uninstall", "--repair"):
            args.pop(0)
        args.insert(0, "plan")
    if args:
        args[0] = aliases.get(args[0], args[0])
    opts = parser.parse_args(args)
    base, marker = layout()
    if opts.mode == "plan":
        print("GitHub:", SOURCE, "Commit:", COMMIT)
        print("Installiert nur SKILL.md + MIT-Lizenz nach Zustimmung; kein Node/npm/Docker.")
        print("Ziel:", target_for(opts.agent or "claude-code"))
        print("Workspace:", base, "Reserve: Disk/RAM 256 MiB; WSL C: 512 MiB.")
        return 0
    record = read_record(marker)
    agent = opts.agent or (record["agent"] if record else "claude-code")
    if opts.mode in ("doctor", "check", "status"):
        installed = False
        if record and record["agent"] == agent:
            try:
                verify_source(base / "source")
                verify_owned(target_for(record["agent"]), record)
                installed = True
            except (ValueError, OSError, subprocess.SubprocessError):
                pass
        print(json.dumps({"installed": installed, "agent": agent, "cli_built": False}))
        return 0 if installed or opts.mode == "status" else 1
    with operation(base, opts.mode.replace("--", "")):
        print("GitHub-Pin:", COMMIT)
        if opts.mode == "uninstall":
            if record:
                target = target_for(record["agent"])
                verify_owned(target, record, allow_missing=True)
                for name in FILES:
                    path = target / name
                    if path.exists():
                        path.unlink()
                if target.exists():
                    target.rmdir()
                marker.unlink()
            print("Skill entfernt. GitHub-Quelle und Logs bleiben; keine Node-/Agenten-/Basiswerkzeuge entfernt.")
        else:
            install(base, marker, agent, record)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print("Find_Skills-Fehler:", error, file=sys.stderr)
        sys.exit(1)
