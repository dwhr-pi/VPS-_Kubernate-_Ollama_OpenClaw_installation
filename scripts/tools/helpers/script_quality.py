"""Install pinned standalone script tools, without running project tasks."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

from find_skills import checked, operation, resources
from offload_sources import fetch, verify


TOOLS = {
    "bats_core": {
        "name": "Bats_Core", "url": "https://github.com/bats-core/bats-core.git",
        "pin": "3bca150ec86275d6d9d5a4fd7d48ab8b6c6f3d87", "version": "1.13.0",
        "runtime": "bash", "entry": "bin/bats",
        "files": ("LICENSE.md", "bin/bats", "libexec/bats-core/bats"),
    },
    "invoke_build": {
        "name": "Invoke_Build", "url": "https://github.com/nightroman/Invoke-Build.git",
        "pin": "920dec6a3eba26cf41e5adb4d9d99d8865d6dfb0", "version": "5.14.22",
        "runtime": "pwsh", "entry": "Invoke-Build.ps1",
        "files": ("LICENSE", "Invoke-Build.ps1"),
    },
}


def paths(tool):
    raw = Path(os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data")))
    if not raw.is_absolute() or raw == Path(raw.anchor):
        raise ValueError("Absoluten externen User-Workspace angeben.")
    base = checked(raw / "tools" / tool)
    return base, checked(base / "source"), checked(base / "scripts-ready.json")


def record(spec):
    return {"commit": spec["pin"], "version": spec["version"],
            "scope": "github-scripts-installed", "project_tested": False}


def runtime(spec):
    variable = "BATS_BASH_BIN" if spec["runtime"] == "bash" else "INVOKE_BUILD_PWSH_BIN"
    executable = shutil.which(os.environ.get(variable, spec["runtime"]))
    if not executable:
        raise ValueError(spec["runtime"] + " fehlt; vorhandene Runtime bereitstellen, keine Systeminstallation.")
    if os.name == "nt" and spec["runtime"] == "bash":
        location = Path(executable).resolve()
        root = os.environ.get("SystemRoot")
        system = Path(root).resolve() if root else None
        if (location.name.lower() == "wsl.exe" or
                (system and location.parent in (system / "System32", system / "Sysnative")) or
                "windowsapps" in {part.lower() for part in location.parts}):
            raise ValueError("WSL-Launcher nicht erlaubt; BATS_BASH_BIN auf vorhandenes natives Git-Bash setzen.")
    return executable


def validate(source, marker, spec):
    if json.loads(marker.read_text(encoding="utf-8")) != record(spec):
        raise ValueError("Unbekannter Besitznachweis; nichts ersetzen oder loeschen.")
    verify(source, spec)
    runtime(spec)


def syntax_check(source, spec, executable):
    # Parse the installed entrypoint only; never import a module or discover tasks.
    env = {key: os.environ[key] for key in
           ("PATH", "SystemRoot", "SYSTEMROOT", "WINDIR", "PATHEXT", "HOME", "USERPROFILE", "TEMP", "TMP")
           if key in os.environ}
    entry = str(checked(source / spec["entry"]))
    if spec["runtime"] == "bash":
        env["BASH_ENV"] = os.devnull
        command = [executable, "--noprofile", "--norc", "-n", entry]
    else:
        env["TOOL_SCRIPT_FILE"] = entry
        command = [executable, "-NoLogo", "-NoProfile", "-NonInteractive", "-Command",
                   "$tokens=$null; $errors=$null; "
                   "[void][System.Management.Automation.Language.Parser]::ParseFile("
                   "$env:TOOL_SCRIPT_FILE,[ref]$tokens,[ref]$errors); "
                   "if ($errors.Count) { exit 1 }"]
    try:
        subprocess.run(command, env=env, cwd=source, check=True,
                       capture_output=True, timeout=60)
    except (OSError, subprocess.SubprocessError):
        raise ValueError("Syntaxpruefung fehlgeschlagen oder Zeitlimit erreicht; keine Projektausfuehrung.") from None


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tool", choices=TOOLS)
    parser.add_argument("action", nargs="?", default="install",
                        choices=("install", "update", "repair", "uninstall", "status", "check", "doctor", "plan"))
    parser.add_argument("--dry-run", action="store_true")
    modes = parser.add_mutually_exclusive_group()
    for action in ("check", "repair", "uninstall", "status"):
        modes.add_argument("--" + action, dest="override", action="store_const", const=action)
    opts = parser.parse_args(argv)
    if opts.override:
        if opts.action not in ("install", opts.override):
            parser.error("Widerspruechliche Aktionen; keine Aenderung.")
        opts.action = opts.override
    spec = TOOLS[opts.tool]
    base, source, marker = paths(opts.tool)
    if opts.dry_run or opts.action == "plan":
        print(spec["name"], spec["url"], spec["pin"], "Ziel:", source)
        print("GitHub-Skripte; Syntaxpruefung, keine Tests/Buildtasks. 1 GiB Reserve, kein Docker/sudo/apt.")
        return 0
    if opts.action in ("status", "check", "doctor"):
        ready = False
        try:
            validate(source, marker, spec)
            ready = True
        except (OSError, ValueError, subprocess.SubprocessError):
            pass
        print(json.dumps({"installed": ready, "project_tested": False}))
        return 0 if ready or opts.action == "status" else 1
    with operation(base, opts.action, tool=spec["name"]):
        print("Quelle:", spec["url"], "Pin:", spec["pin"], "Version:", spec["version"])
        if opts.action == "uninstall":
            if source.exists():
                # A missing runtime must not prevent cleanup of an owned checkout.
                if not marker.exists() or json.loads(marker.read_text(encoding="utf-8")) != record(spec):
                    raise ValueError("Kein gueltiger Besitznachweis; Quellen bleiben erhalten.")
                verify(source, spec)
                marker.unlink()
                shutil.rmtree(checked(source))
            elif marker.exists():
                if json.loads(marker.read_text(encoding="utf-8")) != record(spec):
                    raise ValueError("Unbekannter Marker; nichts entfernen.")
                marker.unlink()
            print("Eigene unveraenderte Skripte entfernt; Logs und Basiswerkzeuge bleiben erhalten.")
            return 0
        if marker.exists():
            validate(source, marker, spec)
            print("Bereits installiert; Update bleibt am geprueften Pin.")
            return 0
        executable = runtime(spec)
        resources(base, base)
        if shutil.disk_usage(base).free < 1024**3:
            raise ValueError("Speicherplatzmangel: mindestens 1 GiB freie Ziel-Disk.")
        if os.environ.get("WSL_DISTRO_NAME") and Path("/mnt/c").is_dir():
            if shutil.disk_usage("/mnt/c").free < 1024**3:
                raise ValueError("Speicherplatzmangel: mindestens 1 GiB Windows-C:-Reserve.")
        existed = source.exists()
        published = False
        try:
            fetch(base, source, spec)
            syntax_check(source, spec, executable)
            fd, pending = tempfile.mkstemp(prefix="marker-", dir=base)
            try:
                with os.fdopen(fd, "w", encoding="utf-8") as output:
                    json.dump(record(spec), output)
                os.replace(pending, marker)
                published = True
            finally:
                Path(pending).unlink(missing_ok=True)
            print("GitHub-Skripte installiert und Syntax geprueft; keine Projekttests/Buildtasks gestartet.")
            print("Bewusst mit", executable, "und", source / spec["entry"], "verwenden; kein globaler PATH-Eintrag.")
        finally:
            if not published and not existed and source.exists():
                verify(source, spec)
                shutil.rmtree(checked(source))
                print("Rollback: nur neuer unveraenderter Quellcheckout entfernt; Log erhalten.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, subprocess.SubprocessError) as exc:
        print("Script-Quality:", exc, file=sys.stderr)
        sys.exit(1)
