"""Pinned optional GitHub tools; desktop builds and source preparation are distinct."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import shutil
import stat
import subprocess
import sys
import tempfile

from find_skills import checked, git, operation
from webinar_releases import reserve

MANIFEST = Path(__file__).with_name("gap_tools.json")
SPECS = json.loads(MANIFEST.read_text(encoding="utf-8"))


def paths(key):
    raw = Path(os.environ.get("OPENCLAW_USER_DATA_DIR", str(Path.home() / ".openclaw_ultimate_user_data")))
    if not raw.is_absolute() or raw == Path(raw.anchor):
        raise ValueError("Absoluter externer User-Workspace erforderlich.")
    base = checked(raw / "tools" / key)
    return base, checked(base / "runtime"), checked(base / "ready.json")


def inventory(root):
    result = {}
    # Do not traverse venv symlinks or Windows pnpm junctions into other trees.
    for parent, directories, files in os.walk(root, followlinks=False):
        for item in sorted(directories + files):
            path = Path(parent) / item
            name = path.relative_to(root).as_posix()
            info = path.lstat()
            if stat.S_ISLNK(info.st_mode) or getattr(info, "st_file_attributes", 0) & 0x400:
                result[name] = "link:" + os.readlink(path)
                if item in directories:
                    directories.remove(item)
            elif stat.S_ISREG(info.st_mode):
                digest = hashlib.sha256()
                with path.open("rb") as stream:
                    for chunk in iter(lambda: stream.read(1024 * 1024), b""):
                        digest.update(chunk)
                result[name] = digest.hexdigest()
            elif not stat.S_ISDIR(info.st_mode):
                raise ValueError("Spezialdatei im privaten Tool-Verzeichnis.")
    return result


def build_env(runtime):
    allow = {"PATH", "SystemRoot", "SYSTEMROOT", "COMSPEC", "PATHEXT", "LANG", "LC_ALL",
             "RUSTUP_HOME", "CARGO_HOME", "INCLUDE", "LIB", "LIBPATH", "VCToolsInstallDir",
             "WindowsSdkDir", "WindowsSDKVersion", "LD_LIBRARY_PATH"}
    env = {k: v for k, v in os.environ.items() if k in allow}
    home = runtime / ".build-home"
    temp = runtime / ".build-temp"
    home.mkdir(exist_ok=True)
    temp.mkdir(exist_ok=True)
    env.update(HOME=str(home), USERPROFILE=str(home), TEMP=str(temp), TMP=str(temp), TMPDIR=str(temp),
               CI="1", DO_NOT_TRACK="1", QWEN_SKIP_PREPARE="1", QWEN_DESKTOP_DISABLE_UPDATES="1",
               COREPACK_HOME=str(home / "corepack"), npm_config_cache=str(home / "npm-cache"),
               npm_config_userconfig=os.devnull, UV_CACHE_DIR=str(home / "uv-cache"),
               PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD="1", PUPPETEER_SKIP_DOWNLOAD="1",
               CARGO_BUILD_JOBS="1", PYTHONDONTWRITEBYTECODE="1")
    # rustup needs its existing compiler, not a fresh toolchain in the private HOME.
    env.setdefault("RUSTUP_HOME", str(Path.home() / ".rustup"))
    env.setdefault("CARGO_HOME", str(Path.home() / ".cargo"))
    return env


def remove_runtime_tree(runtime):
    runtime = checked(runtime)
    if runtime.name != 'runtime':
        raise ValueError('Bereinigung nur fuer den privaten Runtime-Ordner erlaubt.')
    if not runtime.exists():
        return
    print('Runtime-Bereinigung: eigenen Verzeichnis-Schreibschutz begrenzt aufheben:', runtime, flush=True)

    def unlock(path):
        info = path.lstat()
        if stat.S_ISLNK(info.st_mode) or getattr(info, 'st_file_attributes', 0) & 0x400:
            return False  # Never chmod or traverse a symlink/junction target.
        checked(path)
        if not (stat.S_ISDIR(info.st_mode) or stat.S_ISREG(info.st_mode)):
            raise ValueError('Spezialdatei im privaten Runtime-Bestand; keine Entfernung.')
        if hasattr(os, 'geteuid') and info.st_uid != os.geteuid():
            raise PermissionError('Fremder Dateieigentuemer; keine automatische Rechteaenderung: ' + str(path))
        mode = stat.S_IMODE(info.st_mode)
        if stat.S_ISDIR(info.st_mode):
            mode |= stat.S_IRUSR | stat.S_IWUSR | stat.S_IXUSR
        elif os.name == 'nt' and not mode & stat.S_IWUSR:
            if info.st_nlink > 1:
                raise ValueError('Readonly-Hardlink; keine Rechteaenderung am gemeinsamen Ziel.')
            mode |= stat.S_IWUSR
        if mode != stat.S_IMODE(info.st_mode):
            path.chmod(mode)
        return True

    def failed_walk(error):
        raise error

    unlock(runtime)
    for parent, directories, files in os.walk(runtime, topdown=True, followlinks=False, onerror=failed_walk):
        for name in directories[:]:
            if not unlock(Path(parent) / name):
                directories.remove(name)
        for name in files:
            unlock(Path(parent) / name)
    shutil.rmtree(runtime)


def validate_uninstall_remainder(runtime, marker, spec):
    record = json.loads(checked(marker).read_text(encoding='utf-8'))
    if any(record.get(key) != spec[key] for key in ('repo', 'pin', 'mode')):
        raise ValueError('Unbekannter Installationsnachweis; keine fortgesetzte Deinstallation.')
    expected = record.get('files')
    entries = record.get('entries')
    if not isinstance(expected, dict) or not expected or not isinstance(entries, list) or not entries or any(name not in expected for name in entries):
        raise ValueError('Unvollstaendiger Installationsnachweis; keine Entfernung.')
    current = inventory(checked(runtime)) if runtime.exists() else {}
    if any(name not in expected or expected[name] != value for name, value in current.items()):
        raise ValueError('Restbestand enthaelt neue/geaenderte Dateien; vor Deinstallation sichern, nichts entfernt.')
    print('Fortsetzung ausdruecklich freigegeben: Restbestand stimmt mit gespeichertem Inventar ueberein.', flush=True)


def run(args, cwd, env):
    if env.get('NATIVE_BUILD_STREAM') == 'perplexity-sdk':
        program = Path(str(args[0])).name
        heavy = ((program == 'bazel' and 'build' in args) or
                 (program == 'pnpm' and list(args[1:2]) == ['install']) or
                 (program == 'uv' and list(args[1:3]) == ['pip', 'install']))
        if heavy:
            import native_build_process
            return native_build_process.run(args, cwd, env, timeout=14400 if program == 'bazel' else 7200)
    print("Befehl:", " ".join(map(str, args)), flush=True)
    # Capture and print both streams so the current operation log contains build errors.
    result = subprocess.run(list(map(str, args)), cwd=cwd, env=env, capture_output=True,
                            text=True, errors="replace", timeout=7200)
    for output in (result.stdout, result.stderr):
        if output:
            print(output, flush=True)
    result.check_returncode()
    return result.stdout.strip()


def executable(name):
    value = shutil.which(name)
    if not value:
        raise ValueError(name + " fehlt; Basiswerkzeug separat einrichten. Siehe docs/tools/github-gap-tools.md.")
    return value


def node_command(name):
    node = executable("node")
    launcher = Path(executable(name)).resolve()
    if os.name != "nt":
        return [str(launcher)]
    candidates = [launcher.parent / "node_modules" / name / ("bin/npm-cli.js" if name == "npm" else "dist/corepack.js")]
    for candidate in candidates:
        if candidate.is_file():
            return [node, str(candidate)]
    raise ValueError("Native " + name + "-JS-CLI fehlt neben node.exe; keine unsichere cmd/Shell-Ausweichroute.")


def qwen_build(runtime, env):
    if platform.system() not in ("Linux", "Windows"):
        raise ValueError("Dieser Buildweg unterstuetzt Linux und natives Windows.")
    node = executable("node")
    if not run([node, "--version"], runtime, env).startswith("v22."):
        raise ValueError("Der gepinnte Desktop-Build benoetigt Node 22 gemaess .nvmrc.")
    executable("cargo")
    executable("rustc")
    executable("tar")
    if Path("/proc/meminfo").is_file():
        memory = dict(line.split(":", 1) for line in Path("/proc/meminfo").read_text().splitlines())
        if int(memory["MemAvailable"].split()[0]) < 6 * 1024**2:
            raise ValueError("Qwen-Desktop-Build: mindestens 6 GiB verfuegbarer RAM erforderlich.")
    npm, corepack = node_command("npm"), node_command("corepack")
    if platform.system() == "Linux":
        run([executable("pkg-config"), "--exists", "webkit2gtk-4.1", "gtk+-3.0", "librsvg-2.0"], runtime, env)
    else:
        executable("cl")  # Run from the VS Developer PowerShell, not WSL cross-compilation.
    desktop = runtime / "packages/desktop"
    run(corepack + ["pnpm", "install", "--frozen-lockfile", "--prefer-offline", "--reporter=append-only"], runtime, env)
    run(npm + ["ci", "--workspaces=false", "--no-audit"], desktop, env)
    run(npm + ["run", "build:runtime", "--workspaces=false"], desktop, env)
    # Local unsigned packages: disable updater signatures, never request upstream keys.
    bundle = "nsis" if os.name == "nt" else "appimage"
    run(npm + ["run", "tauri", "--workspaces=false", "--", "build", "--bundles", bundle,
               "--config", json.dumps({"bundle": {"createUpdaterArtifacts": False}})], desktop, env)
    entry = "packages/desktop/src-tauri/target/release/qwen-code-desktop" + (".exe" if os.name == "nt" else "")
    bundles = list((desktop / "src-tauri/target/release/bundle" / bundle).glob("*.exe" if os.name == "nt" else "*.AppImage"))
    if len(bundles) != 1:
        raise ValueError("Erwartetes Desktop-Paket fehlt oder ist nicht eindeutig.")
    return [entry, "packages/desktop/runtime/qwen-code/manifest.json", bundles[0].relative_to(runtime).as_posix()]


def hermes_python(runtime, env):
    uv = executable("uv")
    python = os.environ.get("HERMES_PYTHON_BIN") or shutil.which("python3.14")
    if not python:
        policy = os.environ.get("HERMES_INSTALL_PYTHON", "ask")
        if policy not in ("ask", "0", "1"):
            raise ValueError("HERMES_INSTALL_PYTHON: nur ask, 0 oder 1.")
        print("Hermes: Python 3.14 fehlt. uv kann eine private Astral-python-build-standalone-Laufzeit von GitHub laden.")
        print("Ziel:", runtime / ".python", "; kein System-Python-/PATH-Umbau; Entfernung mit diesem Tool.", flush=True)
        accepted = policy == "1"
        if policy == "ask" and sys.stdin.isatty():
            print("Privates Python 3.14 herunterladen und installieren? [(j)a/(N)ein]", flush=True)
            try:
                accepted = input().strip().lower() in ("j", "ja", "y", "yes")
            except EOFError:
                accepted = False
        print("Privater Python-Download:", "freigegeben" if accepted else "nicht freigegeben", flush=True)
        if not accepted:
            raise ValueError("Python 3.14 fehlt; HERMES_PYTHON_BIN auf vorhandenes Python 3.14 setzen oder HERMES_INSTALL_PYTHON=1 bewusst erlauben. Kein Hermes-Quellcode geladen.")
        env["UV_PYTHON_INSTALL_DIR"] = str(runtime / ".python")
        run([uv, "python", "install", "3.14", "--no-bin", "--no-config"], runtime, env)
        python = run([uv, "python", "find", "3.14", "--managed-python", "--no-python-downloads", "--no-config"], runtime, env)
        candidate = Path(python)
        if not candidate.is_absolute() or not candidate.is_file() or not candidate.resolve().is_relative_to((runtime / ".python").resolve()):
            raise ValueError("uv lieferte keinen privaten Python-Pfad im Tool-Workspace.")
    run([python, "-I", "-c", "import sys,ssl; assert sys.version_info[:2] == (3,14), 'Hermes-Pin braucht Python 3.14'; print(sys.version)"], runtime, env)
    return python


def hermes_build(runtime, env, python=None):
    python = python or hermes_python(runtime, env)
    run([executable("uv"), "sync", "--frozen", "--no-dev", "--no-default-groups",
         "--no-python-downloads", "--python", python], runtime, env)
    vpython = runtime / ".venv" / ("Scripts/python.exe" if os.name == "nt" else "bin/python")
    run([vpython, "-I", "-c", "import importlib.metadata as m; assert m.version('hermes-agent')"], runtime, env)
    return [".venv/Scripts/hermes.exe" if os.name == "nt" else ".venv/bin/hermes", "pyproject.toml"]


def validate(runtime, marker, spec, full=False):
    record = json.loads(checked(marker).read_text(encoding="utf-8"))
    if record.get("pin") != spec["pin"] or record.get("repo") != spec["repo"] or record.get("mode") != spec["mode"]:
        raise ValueError("Unbekannter Installationsnachweis; kein Ueberschreiben/Loeschen.")
    checked(runtime)
    if git(runtime, "rev-parse", "HEAD") != spec["pin"] or git(runtime, "remote", "get-url", "origin") != "https://github.com/" + spec["repo"] + ".git":
        raise ValueError("Fremder Quellbestand.")
    entries = record.get("entries", [])
    if not entries:
        raise ValueError("Keine geprueften Artefakte registriert.")
    for name in entries:
        relative = Path(name)
        if relative.is_absolute() or ".." in relative.parts or "\\" in name or ":" in name:
            raise ValueError("Unsicherer Artefaktpfad.")
        path = checked(runtime / relative)
        if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != record.get("files", {}).get(name):
            raise ValueError("Installationsartefakt fehlt oder wurde veraendert: " + name)
    if full and inventory(runtime) != record.get("files"):
        raise ValueError("Dateien geaendert/ergaenzt; vor Deinstallation sichern, nichts entfernt.")
    return record


def browser_use_uv_spec():
    # Adapt the existing private prerequisite contract without adding a second installer.
    return {'id': 'browser_use', 'recipe': {'private_uv': '0.13.5', 'disk_mb': SPECS['browser_use']['reserve_mb']}}


def browser_use_prepare(base, approved=False):
    if platform.system() != 'Linux':
        raise ValueError('Browser Use Paketinstallation nur unter Linux/WSL, kein Windows-Crossbuild.')
    python = os.environ.get('BROWSER_RESEARCH_PYTHON_BIN') or executable('python3')
    run([python, '-I', '-c', 'import sys,ssl; assert sys.version_info >= (3,11)'], base,
        {key: value for key, value in os.environ.items() if key in ('PATH', 'LANG', 'LC_ALL')})
    import native_uv
    native_uv.prepare(base, browser_use_uv_spec(), approved=approved)


def perplexity_mcp_node_spec():
    import native_node
    return {'id': 'perplexity_mcp', 'recipe': {'private_node_npm': native_node.NODE,
                                             'disk_mb': SPECS['perplexity_mcp']['reserve_mb']}}


def perplexity_mcp_prepare(base, approved=False):
    if platform.system() != 'Linux':
        raise ValueError('Perplexity-MCP-Paketbuild nur Linux/WSL, kein Windows-Crossbuild.')
    import native_node_npm
    native_node_npm.prepare(base, perplexity_mcp_node_spec(), approved=approved)


def browser_research_build(runtime, env, mode):
    if platform.system() != 'Linux':
        raise ValueError('Dieser Paket-Build ist fuer Linux/WSL freigegeben; Desktop-Browser separat manuell installieren.')
    env.update(ANONYMIZED_TELEMETRY='false', BROWSER_USE_CLOUD_SYNC='false',
               UV_PYTHON_DOWNLOADS='never', LEFTHOOK='0')
    if mode == 'perplexity-mcp':
        import native_node_npm
        native_node_npm.activate(runtime.parent, perplexity_mcp_node_spec(), env)
        node = shutil.which('node', path=env.get('PATH', ''))
        npm_path = shutil.which('npm', path=env.get('PATH', ''))
        if not node or not npm_path:
            raise ValueError('Gepruefte Node/npm-Basis im Build-PATH nicht erreichbar; kein globaler Fallback.')
        npm = [npm_path]
        major = int(run([node, '--version'], runtime, env).lstrip('v').split('.')[0])
        if major < 22:
            raise ValueError('MCP-Build: Node >=22 fuer den gepinnten Build-/Test-Toolstack erforderlich.')
        run(npm + ['ci', '--ignore-scripts', '--no-audit', '--no-fund'], runtime, env)
        run(npm + ['run', 'build'], runtime, env)
        run([node, '--check', 'dist/index.js'], runtime, env)
        return ['dist/index.js', 'dist/server.js', 'package-lock.json']

    if mode in ('perplexity-python', 'perplexity-node'):
        import perplexity_sdk_tools
        sdk = perplexity_sdk_tools.activate(runtime.parent, env)
        bazel = sdk['bazel']
        version = run([bazel, '--version'], runtime, env)
        if version != 'bazel 9.2.0':
            raise ValueError('SDK-Pin benoetigt Bazel 9.2.0; gepruefte Buildbasis stimmt nicht.')
        if mode == 'perplexity-node':
            node = sdk['node']
            if not run([node, '--version'], runtime, env).startswith('v26.'):
                raise ValueError('Perplexity-Node-Source-Build benoetigt Node 26 laut CONTRIBUTING.md.')
            if run([sdk['pnpm'], '--version'], runtime, env) != '11.17.0':
                raise ValueError('Perplexity-Node-Pin benoetigt pnpm 11.17.0.')
            run([sdk['pnpm'], 'install', '--frozen-lockfile', '--ignore-scripts'], runtime, env)
            perplexity_sdk_tools.build_artifact(runtime, env, sdk, mode)
            run([node, '--check', 'package/dist/index.js'], runtime, env)
            return ['package/package.json', 'package/dist/index.js']
        wheel = perplexity_sdk_tools.build_artifact(runtime, env, sdk, mode)

    python = os.environ.get('BROWSER_RESEARCH_PYTHON_BIN') or executable('python3')
    minimum = '(3,11)' if mode == 'browser-python' else '(3,10)'
    run([python, '-I', '-c', 'import sys,ssl; assert sys.version_info >= ' + minimum], runtime, env)
    if mode in ('browser-python', 'perplexity-python'):
        import native_uv
        # Resolve an absolute executable: executable('uv') only searches the parent PATH.
        uv_contract = browser_use_uv_spec() if mode == 'browser-python' else perplexity_sdk_tools.uv_spec()
        uv = native_uv.select(runtime.parent, uv_contract)
        env.update(UV_NO_CONFIG='1', UV_PYTHON_DOWNLOADS='never')
    else:
        uv = executable('uv')
    if mode == 'browser-python':
        lock = checked(runtime / 'uv.lock')
        lock_origin = 'upstream' if lock.is_file() else 'locally-resolved'
        if not lock.exists():
            print('Browser_Use: Upstream-Pin enthaelt keine uv.lock; erzeuge lokalen Abhaengigkeits-Lock.', flush=True)
            print('Erstaufloesung kann Paketindizes/Build-Metadaten abrufen; kein upstream-gepinnter Gesamtbestand.', flush=True)
            run([uv, 'lock', '--no-python-downloads', '--python', python], runtime, env)
        if not lock.is_file() or not lock.stat().st_size:
            raise ValueError('Browser_Use: uv.lock fehlt/ist leer nach Lock-Schritt; kein Sync/Erfolgsnachweis.')
        lock_hash = hashlib.sha256(lock.read_bytes()).hexdigest()
        print('Browser_Use: Lock-Herkunft:', lock_origin, 'SHA256:', lock_hash, flush=True)
        run([uv, 'sync', '--frozen', '--no-dev', '--no-default-groups', '--no-python-downloads',
             '--python', python], runtime, env)
        if hashlib.sha256(lock.read_bytes()).hexdigest() != lock_hash:
            raise ValueError('Browser_Use: Lock waehrend frozen Sync veraendert; kein Erfolgsnachweis.')
        # Preserve provenance separately from the upstream checkout and installation marker.
        with checked(runtime / 'browser-use-dependency-lock.json').open('x', encoding='utf-8') as stream:
            json.dump({'source_pin': SPECS['browser_use']['pin'], 'origin': lock_origin,
                       'lock_file': 'uv.lock', 'sha256': lock_hash}, stream)
        distribution = 'browser-use'
    else:
        run([uv, 'venv', '--no-python-downloads', '--python', python, str(runtime / '.venv')], runtime, env)
        run([uv, 'pip', 'install', '--python', str(runtime / '.venv/bin/python'), str(wheel)], runtime, env)
        distribution = 'perplexityai'
    vpython = runtime / '.venv/bin/python'
    run([vpython, '-I', '-c', "import importlib.metadata as m; print(m.version('" + distribution + "'))"], runtime, env)
    # Python launchers can be symlinks; record stable package metadata instead.
    metadata = list((runtime / '.venv/lib').glob('python*/site-packages/' + distribution.replace('-', '_') + '-*.dist-info/METADATA'))
    if len(metadata) != 1:
        raise ValueError('Installierte Paketmetadaten fehlen/nicht eindeutig.')
    entries = ['pyproject.toml', metadata[0].relative_to(runtime).as_posix()]
    if mode == 'browser-python':
        entries += ['uv.lock', 'browser-use-dependency-lock.json']
    return entries


def install(runtime, marker, base, spec, install_build_deps=False):
    if marker.exists():
        validate(runtime, marker, spec)
        print("Gepinnter Bestand geprueft; kein automatisches latest-Upgrade.")
        return
    if runtime.exists():
        raise ValueError("Vorhandener Ordner ohne Besitznachweis; nichts ueberschrieben.")
    reserve(base, spec)
    if spec['mode'] == 'godot-build':
        from game_engine_build import preflight
        preflight()
    if spec['mode'] == 'openapi-time':
        from openapi_servers_runtime import prepare
        prepare(base, approved=install_build_deps)
    if spec['mode'] == 'browser-python':
        browser_use_prepare(base, approved=install_build_deps)
    elif spec['mode'] == 'perplexity-mcp':
        perplexity_mcp_prepare(base, approved=install_build_deps)
    elif spec['mode'] in ('perplexity-python', 'perplexity-node'):
        import perplexity_sdk_tools
        perplexity_sdk_tools.prepare(base, spec['mode'].replace('-', '_'), approved=install_build_deps)
    runtime.mkdir(mode=0o700)
    try:
        env = build_env(runtime) if spec["mode"] != "source" else None
        python = hermes_python(runtime, env) if spec["mode"] == "python-package" else None
        git(runtime, "init", "--initial-branch=main")
        git(runtime, "remote", "add", "origin", "https://github.com/" + spec["repo"] + ".git")
        git(runtime, "fetch", "--depth=1", "origin", spec["pin"])
        git(runtime, "checkout", "--detach", "FETCH_HEAD")
        if git(runtime, "rev-parse", "HEAD") != spec["pin"]:
            raise ValueError("GitHub-Pin stimmt nicht.")
        entries = [".git/HEAD"]
        if spec["mode"] == "source":
            entries += [p.name for p in runtime.iterdir()
                        if p.is_file() and p.name.lower().startswith(("readme", "license", "copying"))]
            if len(entries) < 2:
                raise ValueError("Quellcheckout enthaelt keine README/Lizenzdatei.")
        if spec["mode"] != "source":
            if spec['mode'] == 'openapi-time':
                from openapi_servers_runtime import build
                entries = build(runtime, env)
            elif spec['mode'] == 'godot-build':
                from game_engine_build import build
                entries = build(runtime, env, spec['pin'])
            elif spec['mode'] in ('browser-python', 'perplexity-python', 'perplexity-node', 'perplexity-mcp'):
                entries = browser_research_build(runtime, env, spec['mode'])
            else:
                entries = qwen_build(runtime, env) if spec["mode"] == "desktop-build" else hermes_build(runtime, env, python)
            for name in (".build-home", ".build-temp"):
                shutil.rmtree(checked(runtime / name))
        for name in entries:
            if not checked(runtime / name).is_file():
                raise ValueError("Erwartetes Artefakt fehlt: " + name)
        record = dict(repo=spec["repo"], pin=spec["pin"], mode=spec["mode"], entries=entries,
                      installed=True, runtime_tested=False, files=inventory(runtime))
        descriptor, pending = tempfile.mkstemp(prefix="ready-pending-", dir=base)
        try:
            with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
                json.dump(record, stream)
                stream.flush()
                os.fsync(stream.fileno())
            os.replace(pending, marker)
        finally:
            Path(pending).unlink(missing_ok=True)
        print("Installationsumfang:", spec["mode"], "Ziel:", runtime)
        print("Keine GUI/Agenten, Anmeldung, Modelle, Dienste oder Docker gestartet.")
        if spec["mode"] == "source":
            print("NUR QUELLEN installiert; KEINE gebaute/einsatzbereite Anwendung oder ComfyUI-Integration.")
    except BaseException:
        # This directory was absent before this invocation; venv paths stay stable, no rename.
        remove_runtime_tree(runtime)
        marker.unlink(missing_ok=True)
        print("Rollback: nur neue Dateien dieses Versuchs entfernt; Logs/Basiswerkzeuge bleiben.")
        raise


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("tool", choices=SPECS)
    parser.add_argument("action", nargs="?", default="install", choices=("install", "update", "repair", "uninstall", "status", "check", "doctor", "plan"))
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument('--install-build-deps', action='store_true', help='Browser_Use/Perplexity/OpenAPI tools: explicit consent for pinned private prerequisites; no browser/server start')
    parser.add_argument("--source-only", action="store_true", help="MuseTalk: nur bisherigen Quellcheckout verwalten")
    parser.add_argument('--resume-uninstall', action='store_true', help='Perplexity SDKs: explicit removal of unchanged inventoried remnants after a partial uninstall')
    override = parser.add_mutually_exclusive_group()
    for action in ("repair", "uninstall", "status", "check"):
        override.add_argument("--" + action, dest="override", action="store_const", const=action)
    opts = parser.parse_args(argv)
    if opts.override:
        if opts.action not in ("install", opts.override):
            parser.error("Widerspruechliche Aktionen.")
        opts.action = opts.override
    if opts.install_build_deps and (opts.tool not in ('openapi_servers', 'browser_use', 'perplexity_mcp', 'perplexity_python', 'perplexity_node') or opts.action not in ('install', 'update', 'repair', 'plan')):
        parser.error('--install-build-deps hier nur fuer Browser_Use/Perplexity/OpenAPI bei Install/Update/Repair oder Plan.')
    if opts.resume_uninstall and (opts.tool not in ('perplexity_python', 'perplexity_node') or opts.action != 'uninstall'):
        parser.error('--resume-uninstall nur fuer ausdrueckliche Deinstallation der Perplexity SDKs.')
    if opts.tool == "musetalk" and not opts.source_only:
        from musetalk_runtime import main as musetalk_main
        return musetalk_main([opts.action] + (["--dry-run"] if opts.dry_run else []))
    if opts.tool == "musetalk" and opts.source_only and opts.action == "uninstall" and not opts.dry_run:
        base, _, _ = paths("musetalk")
        if checked(base / "python-runtime").exists() or checked(base / "runtime-ready.json").exists():
            raise ValueError("Python-Runtime vorhanden; Deinstallation ohne --source-only verwenden. Keine verwaiste Umgebung erzeugt.")
    if opts.source_only and opts.tool != "musetalk":
        parser.error("--source-only ist nur fuer MuseTalk vorgesehen.")
    spec = SPECS[opts.tool]
    base, runtime, marker = paths(opts.tool)
    if opts.dry_run or opts.action == "plan":
        print(json.dumps(dict(tool=opts.tool, **spec, target=str(runtime)), indent=2))
        if spec['mode'] == 'openapi-time':
            print('Nur Zeitserver-Pythonumgebung; Linux/WSL, vorhandenes Python >=3.10, uv privat nur nach Zustimmung. Einrichtung/Schluessel und Loopback-Start separat. Keine Filesystem-/SQL-/Tokenserver.')
        if spec['mode'] == 'godot-build':
            print('Linux x86_64/aarch64, INSTALL_HEAVY_TOOLS=1, SCons >=4.4 und C++/Grafik-/Audio-Buildbasis separat; 6 GiB freier RAM, 16 GiB Disk, 1-2 Jobs. Kein GUI/XR-/Export-Template-Start.')
        elif opts.tool == 'o3de_source':
            print('Nur Quellen; Git LFS bleibt deaktiviert. LFS-Payloads, Gems, SDKs und vollstaendiger O3DE-Build nicht enthalten.')
        elif opts.tool == 'lively_wallpaper_source':
            print('Nur Windows-Projektquellen fuer Studien; kein Windows-Build/EXE-Start oder Desktop-Eingriff.')
        if opts.tool == 'browser_use':
            print('uv >=0.13.5: vorhandene Basis bevorzugt, sonst privater GitHub-Bootstrap nur nach Zustimmung; 256 MiB Zusatzreserve. Kein Python-/Chromium-Download.')
        elif opts.tool == 'perplexity_mcp':
            print('Node/npm: vorhandene Basis bevorzugt, sonst privates geprueftes Node-Archiv nur nach Zustimmung; 1024 MiB Zusatzreserve. Kein MCP-Start/API-Aufruf.')
        elif opts.tool in ('perplexity_python', 'perplexity_node'):
            print('Bazel 9.2.0 / Node 26 / pnpm 11.17.0, beim Python-SDK auch uv: privat nur nach Zustimmung, bis 1280 MiB Zusatzreserve; kein API-Test.')
        print("Nur Plan; kein Download/Build/Docker/Start.")
        return 0
    if opts.action in ("status", "check", "doctor"):
        ready = False
        try:
            validate(runtime, marker, spec, full=opts.action == "doctor")
            ready = True
        except (ValueError, OSError, subprocess.SubprocessError, KeyError, TypeError):
            pass
        print(json.dumps(dict(installed=ready, scope=spec["mode"], runtime_tested=False)))
        return 0 if ready or opts.action == "status" else 1
    with operation(base, opts.action, tool=spec["name"]):
        versions = {'browser_use': '2026-10-26-browser-use-explicit-local-lock', 'perplexity_mcp': '2026-10-26-perplexity-mcp-private-node-npm',
                    'perplexity_python': '2026-10-26-perplexity-sdk-readonly-uninstall', 'perplexity_node': '2026-10-26-perplexity-sdk-readonly-uninstall'}
        print('GitHub-Tool-Installer:', versions.get(opts.tool, '2026-10-23-hermes-private-python'))
        print("Installerdatei:", Path(__file__).resolve())
        print("Quellenmanifest:", MANIFEST, "Mindestreserve MiB:", spec["reserve_mb"])
        print("GitHub:", spec["repo"], "Pin:", spec["pin"], "Umfang:", spec["mode"])
        if opts.action == "uninstall":
            if runtime.exists() or marker.exists():
                if opts.resume_uninstall:
                    validate_uninstall_remainder(runtime, marker, spec)
                else:
                    try:
                        validate(runtime, marker, spec, full=True)
                    except (ValueError, OSError, KeyError, TypeError, subprocess.SubprocessError):
                        if opts.tool in ('perplexity_python', 'perplexity_node'):
                            print('Falls eine vorherige Deinstallation teilweise lief: bash scripts/tools/' +
                                  opts.tool + '_uninstall.sh --resume-uninstall. Nur unveraenderte Inventarreste werden akzeptiert.', flush=True)
                        raise
                remove_runtime_tree(runtime)
                marker.unlink()
            print("Privater unveraenderter Bestand entfernt; Nutzerdaten ausserhalb, Logs und Basiswerkzeuge bleiben.")
        else:
            if opts.tool in ('openapi_servers', 'browser_use', 'perplexity_mcp', 'perplexity_python', 'perplexity_node'):
                install(runtime, marker, base, spec, install_build_deps=opts.install_build_deps)
            else:
                install(runtime, marker, base, spec)
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, OSError, subprocess.SubprocessError, KeyError, TypeError) as error:
        print("GitHub-Tool fehlgeschlagen:", error, file=sys.stderr)
        sys.exit(1)
