"""Native GitHub builds replacing image installers; never starts services."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import shutil
import stat
import subprocess
import sys
import tempfile

import gap_tools as common
import native_github_adapters as adapters
import native_build_deps as build_deps
import native_go
import native_uv
import native_node

ROOT = Path(__file__).resolve().parents[3]
MANIFEST = ROOT / "config/docker_to_github.json"
TOOLS = {item["id"]: item for item in json.loads(MANIFEST.read_text(encoding="utf-8"))["tools"]}
for key, item in TOOLS.items():
    recipe = item.get("recipe")
    if not re.fullmatch(r"[a-z0-9_]+", key):
        raise ValueError("Ungueltiger nativer Tool-Schluessel.")
    if recipe:
        host = recipe.get("source_host", "github.com")
        if host != "github.com" and not (key == "forgejo" and host == "codeberg.org" and recipe["repo"] == "forgejo/forgejo"):
            raise ValueError("Nicht freigegebene Quellen-Ausnahme.")
        if (not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", recipe["repo"]) or
                not re.fullmatch(r"[0-9a-f]{40}", recipe["pin"]) or
                recipe["kind"] not in ("go", "rust", "cmake", "make", "python", "requirements", "npm", "pnpm", "pipeline") or
                not isinstance(recipe["disk_mb"], int) or recipe["disk_mb"] < 1024):
            raise ValueError("Ungueltiges natives Buildrezept.")
        for field in ("artifact", "entry", "assets", "assets_script", "module_dir", "package", "binary"):
            value = recipe.get(field)
            if value and (Path(value).is_absolute() or ".." in Path(value).parts or "\\" in value or ":" in value or value.startswith("-")):
                raise ValueError("Buildrezept enthaelt unsicheren Pfad.")
        for value in recipe.get("artifacts", []) + recipe.get("artifact_globs", []):
            if not isinstance(value, str) or not value or Path(value).is_absolute() or ".." in Path(value).parts or "\\" in value or ":" in value:
                raise ValueError("Unsicherer Pipeline-Artefaktpfad.")
        for step in recipe.get("steps", []):
            cwd = step.get("cwd", ".")
            args = step.get("args", [])
            if (not isinstance(cwd, str) or Path(cwd).is_absolute() or ".." in Path(cwd).parts or
                    "\\" in cwd or ":" in cwd or not args or
                    any(not isinstance(arg, str) for arg in args) or
                    args[0] not in ("go", "make", "npm", "pnpm", "yarn", "mvn", "java", "bun", "clojure", "composer", "php", "gradle", "node", "bash")):
                raise ValueError("Ungueltiger Pipeline-Buildschritt.")
        for dependency in recipe.get("sources", []):
            if (not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", dependency["repo"]) or
                    not re.fullmatch(r"[0-9a-f]{40}", dependency["pin"]) or
                    not re.fullmatch(r"[A-Za-z0-9_./-]+", dependency["path"]) or
                    Path(dependency["path"]).is_absolute() or ".." in Path(dependency["path"]).parts):
                raise ValueError("Ungueltige abhaengige GitHub-Quelle.")


def recipe_hash(spec):
    return hashlib.sha256(json.dumps(spec["recipe"], sort_keys=True).encode()).hexdigest()


def source_origin(recipe):
    return "https://" + recipe.get("source_host", "github.com") + "/" + recipe["repo"] + ".git"


def fetch_source(checkout, marker, prefix, spec, recipe):
    if recipe.get("source_host", "github.com") == "github.com":
        common.install(checkout, marker, prefix, spec)
        return
    # The only approved non-GitHub primary source is Forgejo's authoritative repository.
    if checkout.exists():
        raise ValueError("Vorhandene Quellen bleiben unangetastet.")
    checkout.mkdir(mode=0o700)
    common.git(checkout, "init", "--initial-branch=main")
    common.git(checkout, "remote", "add", "origin", source_origin(recipe))
    common.git(checkout, "fetch", "--depth=1", "origin", recipe["pin"])
    common.git(checkout, "checkout", "--detach", "FETCH_HEAD")
    if common.git(checkout, "rev-parse", "HEAD") != recipe["pin"]:
        raise ValueError("Offizieller Codeberg-Pin stimmt nicht.")
    marker.write_text(json.dumps(dict(source=source_origin(recipe), commit=recipe["pin"],
                                      scope="source-only", installed=False)), encoding="utf-8")
    print("Freigegebene Quellen-Ausnahme: offizielles Forgejo auf Codeberg; noch KEIN Buildnachweis.")


def paths(key):
    outer, _, _ = common.paths(key)
    prefix = common.checked(outer / "native-github")
    return outer, prefix, common.checked(prefix / "build-ready.json")


def run(args, cwd, env):
    if Path(str(args[0])).name in ("docker", "podman", "sudo"):
        raise ValueError("Kein Container-/privilegierter Fallback erlaubt.")
    return common.run(args, cwd, env)


def requirements(spec):
    if spec["recipe"].get("tools"):
        return spec["recipe"]["tools"]
    kind = spec["recipe"]["kind"]
    return {
        "go": ["go"], "rust": ["cargo", "rustc", "cc", "pkg-config"],
        "cmake": ["cmake", "make", "cc", "pkg-config"],
        "python": ["uv"], "requirements": ["uv"],
        "npm": ["node", "npm"], "pnpm": ["node", "pnpm"],
        "make": spec["recipe"].get("tools", ["make"]),
        "pipeline": [],
    }[kind]


def preflight(outer, spec, install_build_deps=False):
    if platform.system() != "Linux":
        raise ValueError("Native Builds derzeit fuer Ubuntu/WSL Linux; kein Windows-Crossbuild.")
    common.reserve(outer, {"reserve_mb": spec["recipe"]["disk_mb"]})
    acknowledgement = spec["recipe"].get("eol_ack")
    if acknowledgement and os.environ.get(acknowledgement) != "1":
        raise ValueError("EOL-Archivbuild nicht freigegeben. " + acknowledgement + "=1 nur nach Lesen der Migrationsdokumentation setzen.")
    info = Path("/proc/meminfo")
    if info.is_file():
        memory = dict(line.split(":", 1) for line in info.read_text().splitlines())
        minimum = spec["recipe"].get("ram_mb", 4096 if spec["recipe"]["disk_mb"] >= 16384 else 2048)
        if int(memory["MemAvailable"].split()[0]) < minimum * 1024:
            raise ValueError("Zu wenig verfuegbarer RAM: mindestens " + str(minimum) + " MiB fuer diesen Build.")
    build_deps.prepare(spec, approved=install_build_deps)
    for name in ["git"] + requirements(spec):
        if name == "go" and spec["recipe"].get("go_min"):
            continue  # This versioned prerequisite is checked separately below.
        if name == "uv" and spec["recipe"].get("private_uv"):
            continue
        if name in ("node", "pnpm") and spec["recipe"].get("private_node"):
            continue
        common.executable(name)
    native_go.prepare(outer, spec, approved=install_build_deps)
    adapters.preflight(spec)
    recipe = spec["recipe"]
    if recipe.get("python_min"):
        python = os.environ.get("NATIVE_SOURCE_PYTHON_BIN", sys.executable)
        lower = tuple(recipe["python_min"])
        upper = tuple(recipe.get("python_max", [99]))
        common.run([python, "-I", "-c", "import sys; assert " + repr(lower) +
                    " <= sys.version_info[:3] < " + repr(upper) +
                    ", 'Python-Version ausserhalb des gepinnten Buildvertrags'"], Path.cwd(),
                   {name: value for name, value in os.environ.items() if name in ("PATH", "LANG", "LC_ALL")})
    native_uv.prepare(outer, spec, approved=install_build_deps)
    native_node.prepare(outer, spec, approved=install_build_deps)


def environment(prefix):
    work = prefix / "_build"
    work.mkdir(mode=0o700)
    env = common.build_env(work)
    guard = work / "guards"
    guard.mkdir(mode=0o700)
    for name in ("docker", "podman", "sudo"):
        path = guard / name
        path.write_text("#!/bin/sh\nprintf '%s\\n' 'Container-/sudo-Aufruf im nativen Build gesperrt.' >&2\nexit 126\n", encoding="ascii")
        path.chmod(0o700)
    env.update(PATH=str(guard) + os.pathsep + str(work / ".build-home/go/bin") + os.pathsep + env.get("PATH", ""),
               GOTOOLCHAIN="local", GOENV="off", GOWORK="off", GOFLAGS="", GOMAXPROCS="2",
               GOPATH=str(work / ".build-home/go"), GOCACHE=str(work / ".build-home/go-cache"),
               GOMODCACHE=str(work / ".build-home/go-mod"), GOPROXY="https://proxy.golang.org",
               GOSUMDB="sum.golang.org", CARGO_BUILD_JOBS="2", CARGO_HOME=str(work / ".build-home/cargo"),
               RUSTUP_HOME=str(Path.home() / ".rustup"), UV_PYTHON_DOWNLOADS="never",
               COREPACK_ENABLE_NETWORK="0", HF_HUB_OFFLINE="1", TRANSFORMERS_OFFLINE="1",
               GRADIO_ANALYTICS_ENABLED="False", npm_config_fund="false", npm_config_audit="false")
    env.update(GRADLE_USER_HOME=str(work / ".build-home/gradle"),
               npm_config_cache=str(work / ".build-home/npm-cache"),
               YARN_ENABLE_TELEMETRY="0", NX_DAEMON="false", NX_CLOUD="false",
               NEXT_TELEMETRY_DISABLED="1", DO_NOT_TRACK="1")
    return env


def remove_native_tree(prefix, cache_only=False):
    prefix = common.checked(prefix)
    if not cache_only and prefix.name != "native-github":
        raise ValueError("Entfernung nur fuer den privaten nativen Buildordner erlaubt.")
    target = common.checked(prefix / "_build") if cache_only else prefix
    cache = common.checked(prefix / "_build/.build-home/go-mod")
    if cache.is_dir():
        print("Cleanup: Schreibschutz nur im privaten Go-Modulcache aufheben:", cache)

        def unlock(path):
            info = path.lstat()
            if stat.S_ISLNK(info.st_mode) or getattr(info, "st_file_attributes", 0) & 0x400:
                return False  # Never chmod a symlink/junction target outside the cache.
            common.checked(path)
            if not (stat.S_ISREG(info.st_mode) or stat.S_ISDIR(info.st_mode)):
                raise ValueError("Spezialdatei im privaten Go-Modulcache.")
            if stat.S_ISREG(info.st_mode) and info.st_nlink > 1:
                raise ValueError("Mehrfach verlinkte Cache-Datei; keine Rechteaenderung.")
            mode = stat.S_IMODE(info.st_mode) | stat.S_IWUSR
            if stat.S_ISDIR(info.st_mode):
                mode |= stat.S_IRUSR | stat.S_IXUSR
            if mode != stat.S_IMODE(info.st_mode):
                path.chmod(mode)
            return True

        def failed_walk(error):
            raise error

        unlock(cache)
        for parent, directories, files in os.walk(cache, topdown=True, followlinks=False, onerror=failed_walk):
            for name in directories[:]:
                if not unlock(Path(parent) / name):
                    directories.remove(name)
            for name in files:
                unlock(Path(parent) / name)
    if target.exists():
        shutil.rmtree(target)


def build(prefix, spec):
    recipe = spec["recipe"]
    kind = recipe["kind"]
    checkout = prefix / "source"
    env = environment(prefix)
    native_go.activate(prefix.parent, spec, env)
    native_uv.activate(prefix.parent, spec, env)
    native_node.activate(prefix.parent, spec, env)
    substitutions = dict(prefix=str(prefix), source=str(checkout), cache=str(prefix / "_build"))
    env.update({name: value.format_map(substitutions) for name, value in recipe.get("build_env", {}).items()})
    binary = prefix / "bin" / recipe.get("binary", "unused")
    binary.parent.mkdir(mode=0o700)
    artifacts = []
    if recipe.get("node_min"):
        upper = recipe.get("node_max", 999)
        run(["node", "-e", "const v=+process.versions.node.split('.')[0]; if(v < " +
             str(recipe["node_min"]) + " || v > " + str(upper) + ") process.exit(1)"], checkout, env)
    if recipe.get("node_exact"):
        if run(["node", "-p", "process.versions.node"], checkout, env) != recipe["node_exact"]:
            raise ValueError("Vorhandenes Node " + recipe["node_exact"] + " erforderlich; kein automatischer Runtime-Download.")
    if kind == "pipeline" and "cargo" in requirements(spec):
        selected = os.environ.get("NATIVE_SOURCE_RUST_TOOLCHAIN")
        if selected:
            toolchain = Path(selected)
            if not toolchain.is_absolute() or not (toolchain / "bin/rustc").is_file():
                raise ValueError("NATIVE_SOURCE_RUST_TOOLCHAIN muss auf eine vorhandene absolute Toolchain zeigen.")
            env["RUSTUP_TOOLCHAIN"] = str(toolchain)
        sysroot = run(["rustc", "--print", "sysroot"], prefix, env)
        if not Path(sysroot).is_absolute() or not Path(sysroot).is_dir():
            raise ValueError("Vorhandene Rust-Toolchain nicht eindeutig; kein automatischer Download.")
        env["RUSTUP_TOOLCHAIN"] = sysroot
    if recipe.get("manager"):
        manager, version = recipe["manager"]
        if run([manager, "--version"], checkout, env) != version:
            raise ValueError("Vorhandener Paketmanager abweichend: " + manager + " " + version + " erforderlich.")
    adapters.prepare(prefix, spec, env)
    if kind == "go":
        env["CGO_ENABLED"] = "0"
        module = checkout / recipe.get("module_dir", ".")
        if recipe.get("assets_script"):
            run(["bash", str(checkout / recipe["assets_script"])], checkout, env)
        run(["go", "mod", "download"], module, env)
        run(["go", "mod", "verify"], module, env)
        run(["go", "build", "-mod=readonly", "-trimpath", "-buildvcs=false", "-p=2",
             "-o", str(binary), recipe["package"]], module, env)
        artifacts = [binary.relative_to(prefix).as_posix()]
    elif kind == "rust":
        # An absolute already-installed toolchain prevents rust-toolchain.toml downloads.
        sysroot = run(["rustc", "--print", "sysroot"], prefix, env)
        if not Path(sysroot).is_absolute() or not Path(sysroot).is_dir():
            raise ValueError("Vorhandene Rust-Toolchain nicht eindeutig; kein automatischer Download.")
        env["RUSTUP_TOOLCHAIN"] = sysroot
        run(["cargo", "build", "--locked", "--release", "--bin", recipe["binary"], "-j", "2"], checkout, env)
        shutil.copy2(common.checked(checkout / "target/release" / recipe["binary"]), binary)
        artifacts = [binary.relative_to(prefix).as_posix()]
    elif kind == "cmake":
        run(["cmake", "-S", str(checkout), "-B", str(prefix / "cmake-build"),
             "-DCMAKE_BUILD_TYPE=Release", "-DCMAKE_INSTALL_PREFIX=" + str(prefix / "app"),
             "-DWITH_DOCS=OFF", "-DWITH_TESTS=OFF"] + recipe.get("cmake_options", []), prefix, env)
        run(["cmake", "--build", str(prefix / "cmake-build"), "--parallel", "2"], prefix, env)
        run(["cmake", "--install", str(prefix / "cmake-build")], prefix, env)
        artifacts = [recipe["artifact"]]
        binary = prefix / artifacts[0]
    elif kind == "make":
        if spec["id"] == "prometheus":
            # Prebuild promu from source; Makefile.common otherwise downloads a binary.
            expected = "PROMU_VERSION ?= " + recipe["promu_version"]
            if expected not in (checkout / "Makefile.common").read_text(encoding="utf-8"):
                raise ValueError("Promu-Buildvertrag abweichend; kein Binary-Fallback.")
            run(["go", "install", "github.com/prometheus/promu@v" + recipe["promu_version"]], checkout, env)
        run(["make", recipe["target"]], checkout, env)
        artifacts = [recipe["artifact"]]
        binary = prefix / artifacts[0]
    elif kind in ("npm", "pnpm"):
        package = json.loads((checkout / "package.json").read_text(encoding="utf-8"))
        run(["node", "-e", "if (+process.versions.node.split('.')[0] < " + str(recipe["node_min"]) + ") process.exit(1)"], checkout, env)
        if kind == "pnpm":
            expected = "pnpm@" + recipe["package_manager"]
            if package.get("packageManager") != expected or run(["pnpm", "--version"], checkout, env) != recipe["package_manager"]:
                raise ValueError("Gepinntes pnpm fehlt/abweichend; kein automatisches Corepack-/Global-Update.")
            run(["pnpm", "install", "--frozen-lockfile"], checkout, env)
            run(["pnpm", "run", "build"], checkout, env)
        else:
            run(["npm", "ci", "--no-audit", "--no-fund"], checkout, env)
            run(["npm", "run", "build"], checkout, env)
        artifacts = ["source/" + recipe["entry"], "source/package.json"]
        if recipe.get("assets"):
            artifacts.append("source/" + recipe["assets"])
    elif kind == "pipeline":
        for step in recipe["steps"]:
            args = [arg.format_map(substitutions) for arg in step["args"]]
            run(args, common.checked(checkout / step.get("cwd", ".")), env)
        artifacts = list(recipe["artifacts"])
        for pattern in recipe.get("artifact_globs", []):
            matches = sorted(path.relative_to(prefix).as_posix() for path in prefix.glob(pattern) if path.is_file())
            if not matches:
                raise ValueError("Buildausgabe fehlt: " + pattern)
            artifacts.extend(matches)
        if artifacts:
            binary = prefix / artifacts[0]
    elif kind in ("python", "requirements"):
        for step in recipe.get("steps", []):
            run([arg.format_map(substitutions) for arg in step["args"]],
                common.checked(checkout / step.get("cwd", ".")), env)
        module = checkout / recipe.get("module_dir", ".")
        python = os.environ.get("NATIVE_SOURCE_PYTHON_BIN", sys.executable)
        venv = prefix / "venv"
        run(["uv", "venv", "--python", python, "--no-python-downloads", str(venv)], prefix, env)
        vpython = venv / "bin/python"
        pip = ["uv", "pip", "install", "--python", str(vpython), "--index-url", "https://pypi.org/simple"]
        if spec["id"] == "open_webui":
            run(["npm", "ci", "--no-audit", "--no-fund"], checkout, env)
            run(["npm", "run", "build"], checkout, env)
            if not (checkout / "build/index.html").is_file():
                raise ValueError("Open-WebUI-Frontend fehlt; kein Backend-only-Erfolg.")
            # The upstream hook runs npm install --force; use the lockfile build above instead.
            env["HATCH_BUILD_NO_HOOKS"] = "true"
        if (module / "requirements.txt").is_file():
            run(pip + ["-r", str(module / "requirements.txt")], prefix, env)
        if kind == "python":
            local = str(module) + ("[" + recipe["extras"] + "]" if recipe.get("extras") else "")
            if spec["id"] == "searxng":
                run(pip + ["setuptools", "wheel"], prefix, env)
                run(pip + ["--no-build-isolation", local], prefix, env)
            else:
                run(pip + [local], prefix, env)
        run(["uv", "pip", "check", "--python", str(vpython)], prefix, env)
        run([vpython, "-I", "-c", "import importlib.metadata as m; print(m.version(" + repr(recipe["distribution"]) + "))"], prefix, env)
        artifacts = ["venv/pyvenv.cfg"]
        if recipe.get("entry"):
            artifacts.append("source/" + recipe["entry"])
        resolved = run(["uv", "pip", "freeze", "--python", str(vpython)], prefix, env)
        (prefix / "resolved-requirements.txt").write_text(resolved + "\n", encoding="utf-8")
        artifacts.append("resolved-requirements.txt")
        for entry in recipe.get("artifacts", []):
            artifacts.append(entry)
    else:
        raise ValueError("Unbekanntes Buildrezept.")
    for name in artifacts:
        if not common.checked(prefix / name).is_file():
            raise ValueError("Erwartetes Buildartefakt fehlt: " + name)
    if recipe.get("probe"):
        run([str(binary)] + recipe["probe"], prefix, env)
    remove_native_tree(prefix, cache_only=True)
    return artifacts


def validate(prefix, marker, spec, full=False):
    record = json.loads(marker.read_text(encoding="utf-8"))
    if record.get("recipe_hash") != recipe_hash(spec) or record.get("application_tested") is not False:
        raise ValueError("Native Buildmarkierung passt nicht; kein Ueberschreiben/Loeschen.")
    repo = spec["recipe"]["repo"]
    if common.git(prefix / "source", "rev-parse", "HEAD") != spec["recipe"]["pin"] or common.git(prefix / "source", "remote", "get-url", "origin") != source_origin(spec["recipe"]):
        raise ValueError("GitHub-Quellidentitaet stimmt nicht.")
    for dependency in spec["recipe"].get("sources", []):
        path = common.checked(prefix / "source" / dependency["path"])
        if (common.git(path, "rev-parse", "HEAD") != dependency["pin"] or
                common.git(path, "remote", "get-url", "origin") != "https://github.com/" + dependency["repo"] + ".git"):
            raise ValueError("Abhaengige GitHub-Quelle stimmt nicht.")
    files = record.get("files", {})
    if not record.get("artifacts") or not files:
        raise ValueError("Buildartefakte fehlen im Nachweis.")
    for name in record["artifacts"]:
        relative = Path(name)
        if relative.is_absolute() or ".." in relative.parts or "\\" in name or ":" in name:
            raise ValueError("Ungueltiger Artefaktpfad.")
        path = common.checked(prefix / relative)
        if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != files.get(name):
            raise ValueError("Artefakt fehlt/veraendert: " + name)
    if full:
        current = common.inventory(prefix)
        current.pop("build-ready.json", None)
        if current != files:
            raise ValueError("Native Dateien veraendert/ergaenzt; vor Entfernung sichern. Keine Daten geloescht.")
    return record


def install(outer, prefix, marker, spec, install_build_deps=False):
    if marker.exists():
        validate(prefix, marker, spec)
        print("Nativer gepinnter Build bereits vorhanden; kein Upgrade/Download/Start.")
        return
    if prefix.exists():
        raise ValueError("Vorhandener nativer Ordner ohne Buildnachweis; nichts ueberschreiben.")
    preflight(outer, spec, install_build_deps=install_build_deps)
    prefix.mkdir(mode=0o700)
    try:
        recipe = spec["recipe"]
        source_spec = dict(name=spec["name"], repo=recipe["repo"], pin=recipe["pin"], mode="source", reserve_mb=recipe["disk_mb"])
        fetch_source(prefix / "source", prefix / "source-ready.json", prefix, source_spec, recipe)
        for index, dependency in enumerate(recipe.get("sources", [])):
            path = common.checked(prefix / "source" / dependency["path"])
            entry = common.git(prefix / "source", "ls-tree", "HEAD", "--", dependency["path"])
            if not entry.startswith("160000 commit " + dependency["pin"] + "\t"):
                raise ValueError("Submodul-Pin passt nicht zum uebergeordneten GitHub-Commit.")
            if path.exists():
                path.rmdir()  # Only the empty gitlink directory in this new checkout may be removed.
            common.install(path, prefix / ("dependency-" + str(index) + ".json"), prefix,
                           dict(name=dependency["repo"], repo=dependency["repo"], pin=dependency["pin"],
                                mode="source", reserve_mb=recipe["disk_mb"]))
        artifacts = build(prefix, spec)
        if spec["id"] == "mosquitto":
            (prefix / "mosquitto.conf.example").write_text(
                "listener 1883 127.0.0.1\nallow_anonymous false\npersistence false\nlog_dest stdout\n",
                encoding="ascii")
        (prefix / "RUN_NATIVE.md").write_text(
            "# Nativer Build, kein gestarteter Dienst\n\n"
            "Konfiguration, Authentifizierung, localhost/VPN-Bindung und Datenmigration separat pruefen.\n"
            "Keine alten /opt-Containerdaten automatisch verwenden oder loeschen.\n"
            "Siehe docs/DOCKER_TO_GITHUB.md im Setup-Repository.\n\n" +
            recipe.get("note", "") + "\n", encoding="utf-8")
        files = common.inventory(prefix)
        record = dict(recipe_hash=recipe_hash(spec), commit=recipe["pin"], scope="native-github-build",
                      application_tested=False, artifacts=artifacts, files=files)
        fd, pending = tempfile.mkstemp(prefix="build-ready-pending-", dir=prefix)
        try:
            with os.fdopen(fd, "w", encoding="utf-8") as stream:
                json.dump(record, stream)
                stream.flush()
                os.fsync(stream.fileno())
            os.replace(pending, marker)
        finally:
            Path(pending).unlink(missing_ok=True)
        print("Nativer GitHub-Build/Paket vorhanden. Kein Container, Dienststart, Port, Datenbank-Setup oder automatische Datenmigration.")
    except BaseException:
        try:
            marker.unlink(missing_ok=True)
            remove_native_tree(prefix)
            print("Rollback: nur neuer nativer Buildordner entfernt; /opt, alte Container/Volumes, Nutzerdaten und Logs bleiben.")
        except (OSError, ValueError) as cleanup_error:
            print("Rollback unvollstaendig:", cleanup_error)
            print("Restordner erhalten:", prefix, "; Bereinigung nicht abgeschlossen. Urspruenglicher Fehler folgt; keine sudo-/Fremddaten-Bereinigung.")
        raise


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tool", choices=TOOLS)
    parser.add_argument("action", nargs="?", default="install", choices=("install", "update", "repair", "uninstall", "status", "check", "doctor", "plan"))
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--install-build-deps", action="store_true", help="Explicit consent for approved build dependencies/private toolchains; no application package")
    alias = parser.add_mutually_exclusive_group()
    for action in ("repair", "uninstall", "status", "check"):
        alias.add_argument("--" + action, dest="override", action="store_const", const=action)
    args = parser.parse_args(argv)
    if args.override:
        if args.action not in ("install", args.override):
            parser.error("Widerspruechliche Aktionen.")
        args.action = args.override
    if args.install_build_deps and args.action not in ("install", "update", "repair", "plan"):
        parser.error("--install-build-deps ist nur fuer Install/Update/Repair oder deren Plan erlaubt.")
    spec = TOOLS[args.tool]
    outer, prefix, marker = paths(args.tool)
    if args.dry_run or args.action == "plan":
        print(json.dumps(dict(tool=args.tool, target=str(prefix), **spec), indent=2))
        print("Nur Plan. Kein Download/Build/Container/Hosteingriff; blocked_reason ist KEINE Installation.")
        return 0
    if args.action in ("status", "check", "doctor"):
        ready = False
        if spec["recipe"]:
            try:
                validate(prefix, marker, spec, full=args.action == "doctor")
                ready = True
            except (ValueError, OSError, subprocess.SubprocessError, KeyError, TypeError):
                pass
        print(json.dumps(dict(installed=ready, scope="native-github-build" if ready else "absent",
                              application_tested=False, blocked_reason=spec["blocked_reason"],
                              build_note=(spec.get("recipe") or {}).get("note", ""))))
        return 0 if ready or args.action == "status" else 1
    with common.operation(outer, args.action, tool=spec["name"].replace(" ", "_")):
        print("GitHub-native-Umstellung:", args.tool, "Manifest:", MANIFEST)
        print("Alte Container, Volumes, /opt-Installationen und Daten bleiben unberuehrt.")
        if not spec["recipe"]:
            raise ValueError("Native Umstellung noch OFFEN: " + spec["blocked_reason"] +
                             " Kein Docker-Fallback, kein Erfolgsmarker. Siehe " +
                             spec.get("blocked_doc", "docs/DOCKER_TO_GITHUB.md") + ".")
        if args.action == "uninstall":
            if prefix.exists():
                validate(prefix, marker, spec, full=True)
                remove_native_tree(prefix)
            print("Nur eigener unveraenderter nativer Build entfernt; Legacy-Container/Volumendaten bleiben.")
        else:
            install(outer, prefix, marker, spec, install_build_deps=args.install_build_deps)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, subprocess.SubprocessError, KeyError, TypeError) as error:
        print("Nativer GitHub-Installer fehlgeschlagen:", error, file=sys.stderr)
        sys.exit(1)
