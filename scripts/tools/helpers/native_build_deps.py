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
LITELLM_PACKAGES = ("build-essential", "pkg-config")


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
    name, slug = "Mosquitto", "mosquitto"
    if spec["id"] == "litellm":
        if packages and tuple(packages) != LITELLM_PACKAGES:
            raise ValueError("Nicht freigegebene LiteLLM-Systempaketliste; keine apt-Aktion.")
        name, slug, packages = "LiteLLM", "litellm", LITELLM_PACKAGES
        if all(shutil.which(tool) for tool in ("cc", "c++", "make", "pkg-config")):
            print("LiteLLM: C/C++-Buildwerkzeuge bereits vorhanden; keine apt-Aktion.")
            return
    if not packages:
        return
    if (spec["id"] not in ("mosquitto", "litellm") or
            (spec["id"] == "mosquitto" and tuple(packages) != MOSQUITTO_PACKAGES)):
        raise ValueError("Nicht freigegebene Systempaketliste; keine apt-Aktion.")
    if not ubuntu_release() or not all(shutil.which(name) for name in ("apt-get", "dpkg-query")):
        message = name + ": gefuehrter apt-Weg nur fuer Ubuntu 24.04; Buildwerkzeuge/Bibliotheken separat bereitstellen. Siehe docs/tools/" + slug + ".md."
        if approved:
            raise ValueError(message + " Keine Systemaenderung.")
        print(message)
        return
    missing = [package for package in packages if not installed(package)]
    if not missing:
        print(name + ": Ubuntu-Buildpakete bereits vorhanden; keine apt-Aktion.")
        if slug == "litellm":
            raise ValueError("LiteLLM: Pakete installiert, aber cc/c++/make/pkg-config fehlen im PATH; PATH/Paketinstallation separat reparieren.")
        return
    print(name + ": fehlende gemeinsame Buildpakete: " + " ".join(missing))
    print("Nur Compiler/Bibliotheken via apt; " + name + " selbst aus GitHub. "
          "apt kann Abhaengigkeiten aktualisieren. Basiswerkzeuge bleiben bei Deinstallation erhalten.")
    print("Gezielt erneut starten: bash scripts/tools/" + slug + "_install.sh --install-build-deps")
    if not approved and sys.stdin.isatty():
        try:
            print("Fehlende Buildpakete jetzt mit apt installieren? [j/N]", flush=True)
            print("Warte auf Ihre Eingabe und Enter. Nur [j/ja/y/yes] erlaubt die Aktion; Nur [Enter] bedeutet: Nein.", flush=True)
            approved = input().strip().lower() in ("j", "ja", "y", "yes")
        except EOFError:
            approved = False
    if not approved:
        raise ValueError(name + ": Buildabhaengigkeiten fehlen; Zustimmung nicht erteilt. "
                         "Kein Download/Build, kein Erfolgsmarker. Siehe docs/tools/" + slug + ".md.")
    # Privilege escalation is confined to the explicitly approved apt phase.
    prefix = [] if os.geteuid() == 0 else [common.executable("sudo"), "--"]
    env = {key: value for key, value in os.environ.items() if key in ("PATH", "LANG", "LC_ALL", "TERM")}
    env["DEBIAN_FRONTEND"] = "noninteractive"
    options = ["-o", "DPkg::Lock::Timeout=300"]
    common.run(prefix + ["apt-get"] + options + ["update"], Path.cwd(), env)
    common.run(prefix + ["apt-get"] + options + ["install", "--no-remove", "--no-install-recommends", "-y"] + missing, Path.cwd(), env)
    if any(not installed(package) for package in packages):
        raise ValueError(name + ": Buildpakete nach apt unvollstaendig; kein Quellen-Download.")
    if slug == "litellm" and not all(shutil.which(tool) for tool in ("cc", "c++", "make", "pkg-config")):
        raise ValueError("LiteLLM: Compiler/Linker nach apt nicht im PATH; kein Quellen-Download.")
    print(name + ": Buildabhaengigkeiten eingerichtet; GitHub-Build folgt ohne sudo/Docker.")
