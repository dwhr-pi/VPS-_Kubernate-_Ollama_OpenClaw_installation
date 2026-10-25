"""Optional private Go prerequisites; no system upgrade or service start."""
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

import gap_tools as common
import private_go


CONTRACTS = {
    "minio": ([1, 24, 8], "docs/tools/minio.md"),
    "cadvisor": ([1, 25, 0], "docs/tools/cadvisor.md"),
    "node_exporter": ([1, 26, 0], "docs/tools/node-exporter.md"),
    "caddy": ([1, 26, 0], "docs/tools/caddy.md"),
    "watchtower": ([1, 20, 0], "docs/tools/watchtower.md"),
}


def version_ok(text, minimum):
    match = re.fullmatch(r"go version go(\d+)\.(\d+)(?:\.(\d+))? [a-z0-9]+/[a-z0-9]+", text)
    return bool(match and tuple(int(part or 0) for part in match.groups()) >= tuple(minimum))


def select(base, spec, approved=False, allow_download=False):
    minimum = spec["recipe"].get("go_min")
    if minimum is None:
        return None, None
    contract = CONTRACTS.get(spec["id"])
    if not contract or minimum != contract[0]:
        raise ValueError("Nicht freigegebener privater Go-Buildvertrag.")
    name = spec["name"]
    if spec["id"] == "minio":
        print("MinIO: Upstream-README am Pin kennzeichnet die Community-Quelle als nicht mehr gepflegt. "
              "Nur Buildvorbereitung, keine Produktionsfreigabe; siehe docs/tools/minio.md.", flush=True)
    version = ".".join(map(str, minimum))
    env = {key: value for key, value in os.environ.items() if key in ("PATH", "LANG", "LC_ALL")}
    env.update(GOTOOLCHAIN="local", GOENV="off", GOWORK="off", GOTELEMETRY="off")
    binary = shutil.which("go")
    if binary:
        try:
            actual = common.run([binary, "version"], base, env)
            if version_ok(actual, minimum):
                print(name + ": passende vorhandene Go-Toolchain:", binary)
                return binary, None
        except (OSError, subprocess.SubprocessError):
            pass
    key, _, _ = private_go.target()
    slot = common.checked(base / "toolchain" / (private_go.VERSION + "-" + key))
    if not slot.exists():
        print(name + ": Go >=" + version + " fehlt oder ist zu alt. Privates " + private_go.VERSION +
              " aus offiziellem Go-Archiv mit fester SHA256 moeglich; kein apt-Go, sudo oder globaler PATH-Wechsel.")
        print("Gezielt erneut starten: bash scripts/tools/" + spec["id"] + "_install.sh --install-build-deps")
        if allow_download and not approved and sys.stdin.isatty():
            print("Private Go-Toolchain jetzt herunterladen und einrichten? [j/N]", flush=True)
            print("Warte auf Ihre Eingabe und Enter. Nur [j/ja/y/yes] erlaubt die Aktion; Nur [Enter] bedeutet: Nein.", flush=True)
            try:
                approved = input().strip().lower() in ("j", "ja", "y", "yes")
            except EOFError:
                print("Eingabe beendet (EOF); keine Zustimmung erkannt.", flush=True)
                approved = False
        if not allow_download or not approved:
            raise ValueError(name + ": Go >=" + version + " erforderlich; privater Go-Download nicht freigegeben. Siehe " + contract[1] + ".")

    def validate(binary, root, target):
        actual = common.run([str(binary), "version"], base, {**env, "GOROOT": str(root)})
        if actual != "go version " + private_go.VERSION + " " + target.replace("-", "/") or not version_ok(actual, minimum):
            raise ValueError("Private Go-Version/Architektur stimmt nicht; kein Build.")

    return private_go.ensure(base, validate)


def prepare(base, spec, approved=False):
    select(base, spec, approved=approved, allow_download=True)


def activate(base, spec, env):
    if not spec["recipe"].get("go_min"):
        return
    binary, root = select(base, spec)
    # Only the build subprocess environment changes; the parent PATH stays intact.
    env["PATH"] = str(Path(binary).parent) + os.pathsep + env.get("PATH", "")
    if root is not None:
        env["GOROOT"] = str(root)
    env["GOTELEMETRY"] = "off"
