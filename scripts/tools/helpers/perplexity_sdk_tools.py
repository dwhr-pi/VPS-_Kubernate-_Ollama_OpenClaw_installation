"""Pinned private SDK build prerequisites; no SDK, API or global install here."""
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

import gap_tools as common
import native_node
import native_node_npm
import native_uv
import webinar_releases as releases

VERSIONS = {'bazel': '9.2.0', 'node': '26.12.1', 'pnpm': '11.17.0'}
# Official GitHub asset digests; Node digests from nodejs.org SHASUMS256.txt.
ASSETS = {
    'linux-amd64': {
        'bazel': ('https://github.com/bazelbuild/bazel/releases/download/9.2.0/bazel-9.2.0-linux-x86_64', 65942537, '7668a95db1250f12c40407251e4e203b4ec8bf39bc495d2f485b2d8c99048694'),
        'node': ('https://nodejs.org/dist/v26.12.1/node-v26.12.1-linux-x64.tar.gz', 62907493, '0fd1eb7770598f52a21995edf6ed35fc690400fa437c2386af329519e9143132'),
        'pnpm': ('https://github.com/pnpm/pnpm/releases/download/v11.17.0/pnpm-linux-x64.tar.gz', 50975875, 'bdb1db01bf0f757495405a59a09c5c287f315889dc98d3b14bc374b9fe43a0bf'),
    },
    'linux-arm64': {
        'bazel': ('https://github.com/bazelbuild/bazel/releases/download/9.2.0/bazel-9.2.0-linux-arm64', 63821331, '049dd21f40ad979db11c3ee68c96a42ce75f1185e69ac61ab20de1501427a410'),
        'node': ('https://nodejs.org/dist/v26.12.1/node-v26.12.1-linux-arm64.tar.gz', 62602144, 'a6c01af459dd8972ab3fb08ee5da81244d26ba8c4944a62d5bbba8c597ae154f'),
        'pnpm': ('https://github.com/pnpm/pnpm/releases/download/v11.17.0/pnpm-linux-arm64.tar.gz', 51247006, '730d17de742a3efbb020ba91d7acfc0456c6ba6ad1cd8eb49f4c229fe9f504d3'),
    },
}


def uv_spec():
    return {'id': 'perplexity_python', 'recipe': {'private_uv': native_uv.VERSION, 'disk_mb': 8192}}


def probe(binary, name, base, env, private=False, repair=False):
    with tempfile.TemporaryDirectory(prefix='sdk-probe-', dir=base) as directory:
        child = native_node_npm.config_environment(Path(directory) / 'npm', env)
        child.update(HOME=directory, USERPROFILE=directory, COREPACK_ENABLE_NETWORK='0',
                     npm_config_manage_package_manager_versions='false')
        if name == 'bazel':
            version = common.run([binary, '--version'], base, child)
        else:
            version = native_node.runtime_version(binary, base, child, repair,
                tool_name='Perplexity SDK', policy_name='PERPLEXITY_SDK_INSTALL_RUNTIME_LIBS')
    wanted = ('bazel ' + VERSIONS[name] if name == 'bazel' else
              'v' + VERSIONS[name] if name == 'node' else VERSIONS[name])
    okay = version == wanted
    if name == 'node' and not private:
        okay = bool(re.fullmatch(r'v26\.[0-9]+\.[0-9]+', version))
    if not okay:
        raise ValueError('Perplexity SDK: ' + name + '-Version unpassend; erwartet ' + wanted + '.')


def slot_for(base, name):
    host = releases.host_key()
    if host not in ASSETS:
        raise ValueError('Private SDK-Werkzeuge nur Linux amd64/arm64; separat bereitstellen.')
    slot = common.checked(base / 'toolchain' / (name + '-' + VERSIONS[name] + '-' + host))
    return slot, ASSETS[host][name]


def selected(base, name, env):
    # A global "bazel" can be Bazelisk, which may download on --version.
    # Use only our hash-verified direct Bazel binary, never auto-resolve that shim.
    binary = shutil.which(name, path=env.get('PATH', '')) if name != 'bazel' else None
    if binary:
        try:
            probe(binary, name, base, env)
            return str(Path(binary).absolute())
        except (OSError, ValueError, subprocess.SubprocessError):
            pass
    slot, (_, _, sha) = slot_for(base, name)
    if not slot.exists():
        return None
    record = releases.validate_record(slot / 'app', slot / 'ready.json',
        {'repo': name, 'version': VERSIONS[name]}, full=True)
    if record.get('artifact_sha256') != sha:
        raise ValueError('Privater SDK-Archivnachweis geaendert; nichts ueberschreiben.')
    binary = common.checked(slot / 'app' / name)
    probe(str(binary), name, base, env, private=True)
    return str(binary)


def install_one(base, name, env):
    slot, (url, size, sha) = slot_for(base, name)
    if slot.exists():
        raise ValueError('SDK-Toolchain-Ziel vorhanden; nichts ueberschreiben.')
    print('SDK-Buildwerkzeug:', name, VERSIONS[name], url, 'Bytes:', size, 'SHA256:', sha, flush=True)
    with tempfile.TemporaryDirectory(prefix='sdk-bootstrap-', dir=base) as directory:
        stage = common.checked(Path(directory))
        app = stage / 'bundle/app'
        app.mkdir(parents=True, mode=0o700)
        archive = stage / 'download'
        if name == 'node':
            native_node.download_node(url, archive, size, sha)
            native_node.unpack_node(archive, app / name, 'x64' if releases.host_key() == 'linux-amd64' else 'arm64', version=VERSIONS['node'])
        else:
            releases.download(url, archive, size, sha)
            if name == 'bazel':
                shutil.copyfile(archive, app / name)
            else:
                extracted = stage / 'extracted'
                extracted.mkdir()
                releases.unpack(archive, extracted)
                entries = [path for path in extracted.rglob('pnpm') if path.is_file()]
                if len(entries) != 1:
                    raise ValueError('pnpm-Einstieg fehlt/nicht eindeutig.')
                shutil.copyfile(common.checked(entries[0]), app / name)
        (app / name).chmod(0o700)
        probe(str(app / name), name, base, env, private=True, repair=True)
        record = {'repo': name, 'version': VERSIONS[name], 'entry': name,
                  'artifact_sha256': sha, 'hashes': releases.inventory(app)}
        (app.parent / 'ready.json').write_text(json.dumps(record), encoding='utf-8')
        slot.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
        app.parent.rename(slot)
    return str(slot / 'app' / name)


def environment():
    return {key: value for key, value in os.environ.items() if key in ('PATH', 'LANG', 'LC_ALL')}


def prepare(base, key, approved=False):
    if key not in ('perplexity_python', 'perplexity_node'):
        raise ValueError('Nicht freigegebener SDK-Bootstrap.')
    if releases.host_key() not in ASSETS:
        raise ValueError('SDK-Buildbasis nur Linux/WSL amd64/arm64, kein Windows-Crossbuild.')
    python = os.environ.get('BROWSER_RESEARCH_PYTHON_BIN') or common.executable('python3')
    env = environment()
    common.run([python, '-I', '-c', 'import sys,ssl; assert sys.version_info >= (3,10)'], base, env)
    found = {}
    for name in VERSIONS:
        found[name] = selected(base, name, env)
        if found[name]:
            env['PATH'] = str(Path(found[name]).parent) + os.pathsep + env.get('PATH', '')
    missing = [name for name, binary in found.items() if not binary]
    if missing:
        print(key + ': fehlende SDK-Buildwerkzeuge:', ', '.join(missing))
        print('Privat: Bazel 9.2.0 / pnpm 11.17.0 aus GitHub, Node 26.12.1 von nodejs.org; SHA256-geprueft.')
        print('Gezielt erneut starten: bash scripts/tools/' + key + '_install.sh --install-build-deps', flush=True)
        if not approved:
            approved = native_node.confirm('Fehlende SDK-Buildwerkzeuge jetzt privat bereitstellen?')
        if not approved:
            raise ValueError('SDK-Bootstrap nicht freigegeben; kein Quellen-/Paketbuild gestartet.')
        # Combined headroom for binaries, extraction and a possible private uv.
        common.reserve(base, {'reserve_mb': 8192 + 1280})
        for name in missing:
            found[name] = install_one(base, name, env)
            env['PATH'] = str(Path(found[name]).parent) + os.pathsep + env.get('PATH', '')
    if key == 'perplexity_python':
        native_uv.prepare(base, uv_spec(), approved=approved)
    return found


def activate(base, env):
    result = {}
    for name in VERSIONS:
        result[name] = selected(base, name, env)
        if not result[name]:
            raise ValueError('SDK-Buildbasis fehlt: ' + name + '; --install-build-deps bewusst freigeben.')
        env['PATH'] = str(Path(result[name]).parent) + os.pathsep + env.get('PATH', '')
    if not env.get('HOME'):
        raise ValueError('Private Build-HOME erforderlich.')
    env.update(native_node_npm.config_environment(Path(env['HOME']) / '.npm-config', env))
    env.update(COREPACK_ENABLE_NETWORK='0', npm_config_manage_package_manager_versions='false',
               npm_config_update_notifier='false', CARGO_HOME=str(Path(env['HOME']) / 'cargo'),
               RUSTUP_AUTO_INSTALL='0', NATIVE_BUILD_STREAM='perplexity-sdk')
    return result
