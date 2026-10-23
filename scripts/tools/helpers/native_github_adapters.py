"""Explicit packaging adapters inside a newly owned native build directory."""
import json
import hashlib
import os
from pathlib import Path
import re
import shutil
from urllib.parse import urlsplit
from urllib.request import build_opener, HTTPRedirectHandler

import gap_tools as common


ASSETS = Path(__file__).resolve().parent.parent / "assets"


def emsdk_path():
    path = Path(os.environ.get("PENPOT_EMSDK_ENV", "/opt/emsdk/emsdk_env.sh"))
    if not path.is_absolute() or not path.is_file():
        raise ValueError("Penpot: vorhandenes Emscripten-SDK benoetigt; PENPOT_EMSDK_ENV auf dessen absolute emsdk_env.sh setzen. Kein SDK-Download.")
    return path.resolve()


def preflight(spec):
    if spec["id"] == "penpot":
        emsdk_path()


class GithubRedirects(HTTPRedirectHandler):
    def redirect_request(self, request, response, code, message, headers, newurl):
        target = urlsplit(newurl)
        if target.scheme != "https" or not (target.hostname == "github.com" or (target.hostname or "").endswith(".githubusercontent.com")):
            raise ValueError("Build-Asset-Redirect ausserhalb offizieller GitHub-Hosts verweigert.")
        return super().redirect_request(request, response, code, message, headers, newurl)


def download_asset(prefix, asset):
    if (not asset["url"].startswith("https://github.com/penpot/skia-binaries/releases/download/") or
            not re.fullmatch(r"[a-f0-9]{64}", asset["sha256"]) or
            not isinstance(asset["bytes"], int) or not 0 < asset["bytes"] <= 64 * 1024 * 1024):
        raise ValueError("Ungueltiger Skia-Asset-Vertrag.")
    target = prefix / "_build/skia-verified.tar.gz"
    digest = hashlib.sha256()
    size = 0
    print("Penpot: pruefe offizielles GitHub-Skia-Asset SHA256", asset["sha256"])
    with build_opener(GithubRedirects()).open(asset["url"], timeout=120) as response, target.open("xb") as stream:
        while True:
            chunk = response.read(1024 * 1024)
            if not chunk:
                break
            size += len(chunk)
            if size > asset["bytes"]:
                raise ValueError("Skia-Asset groesser als freigegeben.")
            digest.update(chunk)
            stream.write(chunk)
    if size != asset["bytes"] or digest.hexdigest() != asset["sha256"]:
        raise ValueError("Skia-Asset-Pruefsumme/Laenge falsch; kein WASM-Build.")
    (prefix / "github-build-assets.json").write_text(json.dumps(asset), encoding="utf-8")
    return target


def prepare(prefix, spec, env):
    if spec["id"] == "penpot":
        version = common.run(["rustc", "--version"], prefix, env)
        if not version.startswith("rustc 1.99.0 "):
            raise ValueError("Penpot-Pin verlangt vorhandenes Rust 1.99.0; keine globale Toolchain-Aenderung.")
        targets = common.run(["rustup", "target", "list", "--installed", "--toolchain", env["RUSTUP_TOOLCHAIN"]], prefix, env)
        if "wasm32-unknown-emscripten" not in targets.splitlines():
            raise ValueError("Vorhandenes Rust-Ziel wasm32-unknown-emscripten fehlt; kein automatisches rustup target add.")
        env["PENPOT_EMSDK_ENV"] = str(emsdk_path())
        env["SKIA_BINARIES_URL"] = download_asset(prefix, spec["recipe"]["skia_asset"]).resolve().as_uri()
        env["FORCE_SKIA_BINARIES_DOWNLOAD"] = "1"
        shutil.copy2(ASSETS / "penpot_native_wasm.sh", prefix / "penpot-native-wasm.sh")
        return
    if spec["id"] != "nocodb":
        return
    npmrc = prefix / "source/.npmrc"
    original = npmrc.read_text(encoding="utf-8")
    expected = "use-node-version=24.14.0"
    if original.splitlines().count(expected) != 1:
        raise ValueError("NocoDB Node-Vertrag geaendert; keine automatische Node-Installation.")
    # pnpm must use the already verified Node, not download a second runtime.
    (prefix / "upstream.npmrc.original").write_text(original, encoding="utf-8")
    npmrc.write_text(original.replace(expected, "# Native build: use existing Node 24.14.0"), encoding="utf-8")
    integrations = prefix / "source/packages/nocodb/build-utils/registerIntegrations.js"
    generator = integrations.read_text(encoding="utf-8")
    if generator.count("await registerIntegrations(true);") != 1:
        raise ValueError("NocoDB CE-Generatorvertrag geaendert; kein stiller Enterprise-Build.")
    integrations.with_name("registerIntegrations.native.cjs").write_text(
        generator.replace("await registerIntegrations(true);", "await registerIntegrations(false);"), encoding="utf-8")
    shutil.copy2(ASSETS / "nocodb_run_native.cjs", prefix / "run-native.cjs")
    (prefix / "packaging-adapter.json").write_text(json.dumps({
        "adapter": "nocodb-existing-node", "node": "24.14.0",
        "change": "Disable pnpm use-node-version only in this new checkout",
        "upstream_backup": "upstream.npmrc.original", "runtime_started": False,
        "integration_generator": "private CE-only copy; upstream original unchanged",
    }), encoding="utf-8")
    print("NocoDB: nur privates .npmrc angepasst; vorhandenes Node, kein globaler Wechsel/Download.")
