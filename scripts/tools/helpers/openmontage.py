"""Pinned OpenMontage core installation; no agent, models, services or renders."""
import argparse
import ast
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

from find_skills import checked, git, operation, resources

URL = "https://github.com/calesthio/OpenMontage.git"
PIN = "c8066452325cb57c8fc1ba8c2a71b6e8842e6b65"
FILES = ("LICENSE", "AGENT_GUIDE.md", "AGENTS.md", "PROJECT_CONTEXT.md", "config.yaml",
         "requirements.txt", "tools/tool_registry.py", "tools/base_tool.py",
         "remotion-composer/package.json", "remotion-composer/package-lock.json")
IMPORTS = "import yaml,pydantic,jsonschema,dotenv,PIL,numpy,requests,google.auth,google.genai,openai,fastapi,uvicorn,watchfiles"


def paths():
    raw = Path(os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data")))
    if not raw.is_absolute() or raw == Path(raw.anchor):
        raise ValueError("Absolutes externes Nutzerdatenverzeichnis erforderlich.")
    base = checked(raw / "tools/openmontage")
    return base, checked(base / "source"), checked(base / "venv"), checked(base / "core-ready.json")


def python_at(venv):
    return venv / ("Scripts/python.exe" if os.name == "nt" else "bin/python")


def command(args, cwd, timeout=900):
    # No user site-packages, pip config or implicit browser-download hooks.
    env = {**os.environ, "PYTHONNOUSERSITE": "1", "PYTHONDONTWRITEBYTECODE": "1",
           "PIP_CONFIG_FILE": os.devnull, "PIP_DISABLE_PIP_VERSION_CHECK": "1",
           "PUPPETEER_SKIP_DOWNLOAD": "1", "PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD": "1"}
    subprocess.run(list(map(str, args)), cwd=cwd, env=env, check=True, timeout=timeout)


def verify_source(source):
    checked(source)
    if (git(source, "remote", "get-url", "origin") != URL or git(source, "rev-parse", "HEAD") != PIN
            or git(source, "status", "--porcelain", "--untracked-files=all")):
        raise ValueError("Quellen fremd oder veraendert; kein Reset/latest-Pull.")
    for name in FILES:
        if not checked(source / name).is_file():
            raise ValueError("Quellbestand unvollstaendig: " + name)
    for name in ("tools/tool_registry.py", "tools/base_tool.py"):
        ast.parse((source / name).read_text(encoding="utf-8"))


def fetch(base, source):
    if source.exists():
        verify_source(source)
        return False
    stage = Path(tempfile.mkdtemp(prefix="source-stage-", dir=base))
    try:
        git(stage, "init", "--initial-branch=main")
        git(stage, "remote", "add", "origin", URL)
        git(stage, "fetch", "--depth=1", "origin", PIN)
        git(stage, "checkout", "--detach", "FETCH_HEAD")
        verify_source(stage)
        stage.rename(source)
        return True
    finally:
        if stage.exists():
            shutil.rmtree(checked(stage))


def reserve(base):
    resources(base, base)
    if shutil.disk_usage(base).free < 4 * 1024**3:
        raise ValueError("Speicherplatzmangel: mindestens 4 GiB vor der Installation erforderlich.")
    if os.environ.get("WSL_DISTRO_NAME") and Path("/mnt/c").exists():
        if shutil.disk_usage("/mnt/c").free < 4 * 1024**3:
            raise ValueError("Windows-C:-Speicherplatzmangel: mindestens 4 GiB erforderlich.")


def verify_core(base, source, venv, marker, deep=False):
    data = json.loads(checked(marker).read_text(encoding="utf-8"))
    if not isinstance(data, dict) or data.get("commit") != PIN or data.get("core_dependencies_ready") is not True:
        raise ValueError("Unbekannter Installationsnachweis.")
    checked(venv)
    # POSIX venv Python is a legitimate interpreter symlink inside the owned venv.
    if not python_at(venv).is_file() or not (source / "AGENT_GUIDE.md").is_file():
        raise ValueError("Python-Umgebung oder Quellen fehlen.")
    if data.get("remotion_ready") and not checked(base / "remotion/node_modules/remotion/package.json").is_file():
        raise ValueError("Remotion-Paket fehlt.")
    if deep:
        verify_source(source)
        command([python_at(venv), "-I", "-B", "-c", IMPORTS], base, 60)
    return data


def write_marker(marker, data):
    fd, name = tempfile.mkstemp(prefix="core-status-", dir=marker.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as stream:
            json.dump(data, stream, indent=2)
        os.replace(name, marker)
    finally:
        if Path(name).exists():
            Path(name).unlink()


def install_remotion(base, source):
    node, npm = shutil.which("node"), shutil.which("npm.cmd" if os.name == "nt" else "npm")
    if not node or not npm:
        raise ValueError("Node/npm fehlt fuer optionales Remotion; Basisinstallation ohne --with-remotion moeglich.")
    probe = subprocess.run([node, "-p", "process.versions.node.split('.')[0]"], capture_output=True, text=True, check=True, timeout=15)
    if int(probe.stdout.strip()) < 22:
        raise ValueError("Fuer diesen Remotion-Installationspfad vorhandenes Node >=22 verwenden.")
    target = checked(base / "remotion")
    if target.exists():
        raise ValueError("Remotion-Ziel vorhanden; nicht automatisch ueberschrieben.")
    try:
        shutil.copytree(source / "remotion-composer", target, symlinks=False)
        command([npm, "ci", "--ignore-scripts", "--no-audit", "--no-fund"], target)
        package = checked(target / "node_modules/remotion/package.json")
        version = json.loads(package.read_text(encoding="utf-8"))["version"]
        lock = json.loads((source / "remotion-composer/package-lock.json").read_text(encoding="utf-8"))
        if version != lock["packages"]["node_modules/remotion"]["version"]:
            raise ValueError("Remotion stimmt nicht mit dem GitHub-Lockfile ueberein.")
        return version
    except Exception:
        if target.exists():
            shutil.rmtree(checked(target))
        raise


def prepare_python(interpreter, base):
    probe = "import sys,venv,ensurepip,ssl; assert sys.version_info >= (3,10)"
    try:
        command([interpreter, "-I", "-c", probe], base, 30)
        return
    except subprocess.CalledProcessError:
        pass
    details = subprocess.run([str(interpreter), "-I", "-c",
                              "import sys,json; print(json.dumps([sys.executable, list(sys.version_info[:2])]))"],
                             capture_output=True, text=True, check=True, timeout=15)
    executable, version = json.loads(details.stdout)
    if version < [3, 10] or not re.fullmatch(r"/usr/bin/python3(?:\.\d+)?", executable):
        raise ValueError("OPENMONTAGE_PYTHON_BIN braucht Python >=3.10 mit venv/ensurepip/SSL; "
                         "fremde Python-Installation wird nicht per apt veraendert.")
    release = Path("/etc/os-release")
    distro = release.read_text(encoding="utf-8") if release.is_file() else ""
    if not re.search(r'^ID=(?:"?)(ubuntu|debian)(?:"?)$', distro, re.M):
        raise ValueError("venv/ensurepip/SSL fehlt. Zum gewaehlten Python passendes venv-Paket "
                         "einrichten oder OPENMONTAGE_PYTHON_BIN setzen; danach --repair.")
    package = "python" + ".".join(map(str, version)) + "-venv"
    print("Python-Vorpruefung fehlgeschlagen: venv/ensurepip/SSL pruefen.")
    print("Passendes Ubuntu-/Debian-Basispaket:", package)
    print("Reparatur: sudo apt-get -o DPkg::Lock::Timeout=300 install --no-remove --no-install-recommends " + package)
    print("Kein Austausch des System-Python-Befehls; apt kann passende System-Abhaengigkeiten aktualisieren.")
    print("Gemeinsames Basispaket wird bei Deinstallation nicht entfernt.")
    policy = os.environ.get("OPENMONTAGE_INSTALL_PYTHON_VENV", "ask")
    if policy not in ("ask", "0", "1"):
        raise ValueError("OPENMONTAGE_INSTALL_PYTHON_VENV: nur ask, 0 oder 1.")
    accepted = policy == "1" or (policy == "ask" and sys.stdin.isatty() and
               input("Passendes venv-Basispaket jetzt installieren? [(j)a/(N)ein]: ").strip().lower() == "j")
    if not accepted:
        raise ValueError("venv-Reparatur nicht freigegeben. Obigen Befehl separat ausfuehren oder "
                         "OPENMONTAGE_INSTALL_PYTHON_VENV=1 setzen; danach --repair. Keine Quellen installiert.")
    command(["sudo", "apt-get", "-o", "DPkg::Lock::Timeout=300", "install",
             "--no-remove", "--no-install-recommends", "-y", package], base, 600)
    command([interpreter, "-I", "-c", probe], base, 30)
    print("Python-Vorpruefung nach venv-Reparatur erfolgreich.")


def install(base, source, venv, marker, with_remotion=False):
    reserve(base)
    if marker.exists():
        data = verify_core(base, source, venv, marker, deep=True)
        if with_remotion and not data.get("remotion_ready"):
            data["remotion_version"] = install_remotion(base, source)
            data["remotion_ready"] = True
            try:
                write_marker(marker, data)
            except Exception:
                shutil.rmtree(checked(base / "remotion"))
                raise
        print("Gepinnte Installation geprueft; kein automatisches latest-Upgrade.")
        return
    if venv.exists():
        raise ValueError("Unverwaltete Python-Umgebung vorhanden; erst sichern/pruefen.")
    interpreter = os.environ.get("OPENMONTAGE_PYTHON_BIN", sys.executable)
    prepare_python(interpreter, base)
    created_source = created_venv = created_remotion = False
    try:
        created_source = fetch(base, source)
        created_venv = True
        command([interpreter, "-I", "-m", "venv", venv], base, 120)
        python = python_at(venv)
        command([python, "-I", "-m", "pip", "--isolated", "install", "--no-input", "--no-cache-dir",
                 "--only-binary=:all:", "--index-url", "https://pypi.org/simple", "-r", source / "requirements.txt"], base)
        command([python, "-I", "-B", "-c", IMPORTS], base, 60)
        command([python, "-I", "-m", "pip", "--isolated", "check"], base, 60)
        frozen = subprocess.run([str(python), "-I", "-m", "pip", "--isolated", "freeze"],
                                capture_output=True, text=True, check=True, timeout=60)
        data = {"commit": PIN, "repo": URL, "scope": "github-core-environment", "core_dependencies_ready": True,
                "remotion_ready": False, "render_ready": False, "service_started": False,
                "requirements_sha256": hashlib.sha256((source / "requirements.txt").read_bytes()).hexdigest(),
                "resolved_python_packages": frozen.stdout.splitlines()}
        if with_remotion:
            data["remotion_version"] = install_remotion(base, source)
            created_remotion = True
            data["remotion_ready"] = True
        write_marker(marker, data)
    except Exception:
        for created, path in ((created_remotion, base / "remotion"), (created_venv, venv), (created_source, source)):
            if created and path.exists():
                shutil.rmtree(checked(path))
        print("Rollback: nur neue Komponenten dieses Versuchs entfernt; bestehende Daten bleiben.")
        raise
    print("OpenMontage-GitHub-Kernumgebung installiert. Kein Film, Agent, Browser, Modell, Key oder Dienst gestartet.")


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", nargs="?", default="install", choices=("install", "repair", "update", "uninstall", "status", "check", "doctor", "plan"))
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--with-remotion", action="store_true")
    parser.add_argument("--accept-remotion-license", action="store_true")
    group = parser.add_mutually_exclusive_group()
    for mode in ("repair", "uninstall", "status", "check"):
        group.add_argument("--" + mode, dest="override", action="store_const", const=mode)
    args = parser.parse_args(argv)
    if args.override:
        if args.action not in ("install", args.override):
            parser.error("Widerspruechliche Aktionen.")
        args.action = args.override
    if args.with_remotion and args.action not in ("install", "repair", "update", "plan"):
        parser.error("Remotion nur bei Installation/Update/Repair oder Plan waehlen.")
    base, source, venv, marker = paths()
    if args.dry_run or args.action == "plan":
        print("GitHub:", URL, "Commit:", PIN, "Ziel:", base)
        print("Plan: private Python-Kernumgebung mit PyPI-Wheels; 4 GiB Reserve. Remotion optional:", args.with_remotion)
        print("Kein make setup, Docker, npx latest, Agentenstart, Keyzugriff, Modell oder Render.")
        return 0
    if args.action in ("status", "check", "doctor"):
        data, ready = {}, False
        try:
            data = verify_core(base, source, venv, marker, deep=args.action == "doctor")
            ready = True
        except (ValueError, OSError, KeyError, TypeError, subprocess.SubprocessError):
            pass
        print(json.dumps({"installed": ready, "core_dependencies_ready": ready,
                          "remotion_ready": ready and data.get("remotion_ready", False), "render_ready": False,
                          "service_started": False, "scope": "github-core-environment"}))
        return 0 if ready or args.action == "status" else 1
    with operation(base, args.action, tool="OpenMontage"):
        print("Quelle:", URL, "Commit:", PIN)
        if args.action == "uninstall":
            if marker.exists():
                data = verify_core(base, source, venv, marker)
                shutil.rmtree(checked(venv))
                modules = checked(base / "remotion/node_modules")
                if data.get("remotion_ready") and modules.exists():
                    shutil.rmtree(modules)
                marker.unlink()
            elif venv.exists():
                raise ValueError("Umgebung ohne Besitznachweis; nichts geloescht.")
            print("Private Runtime und Marker entfernt; Quellen, Projekte, Secrets, Logs und Basiswerkzeuge bleiben.")
        else:
            if args.with_remotion and not args.accept_remotion_license:
                raise ValueError("Remotion-Lizenz separat pruefen; danach --accept-remotion-license bewusst setzen.")
            install(base, source, venv, marker, args.with_remotion)
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (ValueError, OSError, KeyError, TypeError, SyntaxError, subprocess.SubprocessError) as error:
        print("OpenMontage fehlgeschlagen:", error, "Aktuelles Operationslog pruefen; kein Film oder Dienst gestartet.", file=sys.stderr)
        raise SystemExit(1)
