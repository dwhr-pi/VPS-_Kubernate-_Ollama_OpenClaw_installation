"""Consent-gated Ubuntu build dependencies, separate from unprivileged builds."""
import os
from pathlib import Path
import shutil
import subprocess
import sys

import gap_tools as common


# Do not allow recipes to install applications or arbitrary system packages.
MOSQUITTO_PACKAGES = ("git", "cmake", "build-essential", "pkg-config", "libssl-dev",
                      "libcjson-dev", "libsqlite3-dev", "libedit-dev", "libmicrohttpd-dev")


def ubuntu_release():
    values = {}
    for line in Path("/etc/os-release").read_text(encoding="utf-8").splitlines():
        if "=" in line:
            key, value = line.split("=", 1)
            values[key] = value.strip('"')
    return values.get("ID") == "ubuntu" and values.get("VERSION_ID") == "24.04"


def installed(package):
    result = subprocess.run(["dpkg-query", "-W", "-f=${Status}", package],
                            capture_output=True, text=True, check=False)
    return result.returncode == 0 and result.stdout.strip() == "install ok installed"


def prepare(spec, approved=False):
    packages = spec["recipe"].get("apt_build_deps", [])
    if not packages:
        return
    if spec["id"] != "mosquitto" or tuple(packages) != MOSQUITTO_PACKAGES:
        raise ValueError("Nicht freigegebene Systempaketliste; keine apt-Aktion.")
    if not ubuntu_release() or not all(shutil.which(name) for name in ("apt-get", "dpkg-query")):
        message = "Mosquitto: gefuehrter apt-Weg nur fuer Ubuntu 24.04; Buildwerkzeuge/Bibliotheken separat bereitstellen. Siehe docs/tools/mosquitto.md."
        if approved:
            raise ValueError(message + " Keine Systemaenderung.")
        print(message)
        return
    missing = [package for package in packages if not installed(package)]
    if not missing:
        print("Mosquitto: Ubuntu-Buildpakete bereits vorhanden; keine apt-Aktion.")
        return
    print("Mosquitto: fehlende gemeinsame Buildpakete: " + " ".join(missing))
    print("Nur Compiler/Bibliotheken via apt; Mosquitto selbst aus GitHub. "
          "apt kann Abhaengigkeiten aktualisieren. Basiswerkzeuge bleiben bei Deinstallation erhalten.")
    print("Gezielt erneut starten: bash scripts/tools/mosquitto_install.sh --install-build-deps")
    if not approved and sys.stdin.isatty():
        try:
            approved = input("Fehlende Buildpakete jetzt mit apt installieren? [j/N]: ").strip().lower() in ("j", "ja", "y", "yes")
        except EOFError:
            approved = False
    if not approved:
        raise ValueError("Mosquitto: Buildabhaengigkeiten fehlen; Zustimmung nicht erteilt. "
                         "Kein Download/Build, kein Erfolgsmarker. Siehe docs/tools/mosquitto.md.")
    # Privilege escalation is confined to the explicitly approved apt phase.
    prefix = [] if os.geteuid() == 0 else [common.executable("sudo"), "--"]
    env = {key: value for key, value in os.environ.items() if key in ("PATH", "LANG", "LC_ALL", "TERM")}
    env["DEBIAN_FRONTEND"] = "noninteractive"
    options = ["-o", "DPkg::Lock::Timeout=300"]
    common.run(prefix + ["apt-get"] + options + ["update"], Path.cwd(), env)
    common.run(prefix + ["apt-get"] + options + ["install", "--no-remove", "--no-install-recommends", "-y"] + missing, Path.cwd(), env)
    if any(not installed(package) for package in packages):
        raise ValueError("Mosquitto: Buildpakete nach apt unvollstaendig; kein Quellen-Download.")
    print("Mosquitto: Buildabhaengigkeiten eingerichtet; GitHub-Build folgt ohne sudo/Docker.")
