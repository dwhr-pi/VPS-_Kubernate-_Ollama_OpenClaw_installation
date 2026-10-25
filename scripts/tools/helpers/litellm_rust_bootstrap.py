"""Consent-gated official Rust prerequisite in LiteLLM's private toolchain tree."""
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import sys
import tempfile
from urllib.parse import urlsplit
from urllib.request import HTTPRedirectHandler, build_opener

import gap_tools as common
import litellm_rust as rust
import webinar_releases as releases

MANAGER_VERSION = '1.29.2'
ARTIFACTS = {
    'linux-amd64': ('x86_64-unknown-linux-gnu', 21139856,
                    '5be191e8c70a5007074254cb74d78dbfdd25cd5a61c27de7b8e5410122ec24f4'),
    'linux-arm64': ('aarch64-unknown-linux-gnu', 19930504,
                    'a9c168dbea81a84671c6b7a5c1795cb0eb699020110d107ddfca427bd797e697'),
}


class OfficialRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        parts = urlsplit(newurl)
        if parts.scheme != 'https' or parts.hostname != 'static.rust-lang.org' or parts.username or parts.password:
            raise ValueError('Rust-Bootstrap: Redirect ausserhalb des offiziellen HTTPS-Hosts blockiert.')
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def download(url, target, size, digest):
    parts = urlsplit(url)
    if parts.scheme != 'https' or parts.hostname != 'static.rust-lang.org' or parts.username or parts.password:
        raise ValueError('Unzulaessiger Rust-Bootstrap-Host.')
    total, sha = 0, hashlib.sha256()
    with build_opener(OfficialRedirect()).open(url, timeout=45) as response, target.open('xb') as stream:
        while True:
            chunk = response.read(1024 * 1024)
            if not chunk:
                break
            total += len(chunk)
            if total > size:
                raise ValueError('rustup-init groesser als der gepruefte Pin.')
            stream.write(chunk)
            sha.update(chunk)
    if total != size or sha.hexdigest() != digest:
        raise ValueError('rustup-init: Groesse/SHA256 stimmt nicht; keine Ausfuehrung.')
    target.chmod(0o700)


def location(base):
    key = releases.host_key()
    if key not in ARTIFACTS:
        raise ValueError('Privates Rust nur fuer Linux amd64/arm64; Rust separat bereitstellen.')
    triple, size, digest = ARTIFACTS[key]
    slot = common.checked(base / 'toolchain' / ('rust-' + rust.VERSION + '-' + key))
    return slot, triple, size, digest


def existing(base):
    if releases.host_key() not in ARTIFACTS:
        return None
    slot, triple, _, digest = location(base)
    if not slot.exists():
        return None
    marker = common.checked(slot / 'rust-ready.json')
    record = json.loads(marker.read_text(encoding='utf-8'))
    files = common.inventory(slot)
    files.pop('rust-ready.json', None)
    if (record.get('version') != rust.VERSION or record.get('manager_sha256') != digest or
            record.get('files') != files):
        raise ValueError('Private Rust-Basis veraendert/unvollstaendig; nichts ueberschreiben oder loeschen.')
    return rust.verify(common.checked(slot / 'rustup/toolchains' / (rust.VERSION + '-' + triple)), base)


def prepare(base, spec, approved=False):
    if spec['id'] != 'litellm':
        return None
    # Explicit user paths must never be silently replaced, even on download consent.
    if os.environ.get('NATIVE_SOURCE_RUST_TOOLCHAIN'):
        return rust.select(base)
    private = existing(base)
    if private:
        print('LiteLLM: gepruefte private Rust-Basis wiederverwendet:', private)
        return private
    try:
        return rust.select(base)
    except ValueError:
        pass
    slot, triple, size, digest = location(base)
    print('LiteLLM: Rust ' + rust.VERSION + ' fehlt. Private Basis moeglich; keine System-/Default-/PATH-Aenderung.')
    print('Quelle: static.rust-lang.org; rustup-init ' + MANAGER_VERSION + ', feste SHA256; Rust ' + rust.VERSION + '.')
    print('Ziel:', slot, '; 2048 MiB Puffer zusaetzlich zur Toolreserve. Basis bleibt bei App-Deinstallation erhalten.')
    print('Gezielt erneut starten: bash scripts/tools/litellm_install.sh --install-build-deps', flush=True)
    if not approved and sys.stdin.isatty():
        print('Rust jetzt privat herunterladen/einrichten? [j/N]', flush=True)
        print('Warte auf Ihre Eingabe und Enter. Nur [j/ja/y/yes] erlaubt die Aktion; Nur [Enter] bedeutet: Nein.', flush=True)
        try:
            approved = input().strip().lower() in ('j', 'ja', 'y', 'yes')
        except EOFError:
            approved = False
    if not approved:
        raise ValueError('LiteLLM: privater Rust-Download nicht freigegeben. ' + rust.GUIDANCE)
    common.reserve(base, {'reserve_mb': spec['recipe']['disk_mb'] + 2048})
    slot.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    stage = common.checked(Path(tempfile.mkdtemp(prefix='rust-bootstrap-', dir=slot.parent)))
    published = False
    try:
        installer = stage / 'rustup-init'
        url = 'https://static.rust-lang.org/rustup/archive/' + MANAGER_VERSION + '/' + triple + '/rustup-init'
        print('Rust-Bootstrap-Download:', url, 'Bytes:', size, 'SHA256:', digest, flush=True)
        download(url, installer, size, digest)
        env = {k: v for k, v in os.environ.items() if k in ('PATH', 'LANG', 'LC_ALL', 'HTTPS_PROXY', 'https_proxy', 'NO_PROXY', 'no_proxy')}
        home = stage / 'home'
        home.mkdir(mode=0o700)
        env.update(HOME=str(home), CARGO_HOME=str(stage / 'cargo'), RUSTUP_HOME=str(stage / 'rustup'),
                   RUSTUP_DIST_SERVER='https://static.rust-lang.org', RUSTUP_UPDATE_ROOT='https://static.rust-lang.org/rustup',
                   RUSTUP_AUTO_INSTALL='0', RUSTUP_IO_THREADS='1', RUSTUP_CONCURRENT_DOWNLOADS='1',
                   RUSTUP_UNPACK_RAM=str(512 * 1024**2))
        version = common.run([installer, '--version'], stage, env)
        if not re.fullmatch(r'rustup-init ' + re.escape(MANAGER_VERSION) + r'(?: \([^\n]*\))?', version):
            raise ValueError('rustup-init-Version stimmt nicht mit dem Pin ueberein.')
        common.run([installer, '-y', '--no-modify-path', '--profile', 'minimal',
                    '--default-host', triple, '--default-toolchain', rust.VERSION], stage, env)
        rust.verify(stage / 'rustup/toolchains' / (rust.VERSION + '-' + triple), stage)
        installer.unlink()
        if slot.exists():
            raise ValueError('Rust-Ziel inzwischen vorhanden; nichts ueberschreiben.')
        stage.rename(slot)
        published = True
        root = rust.verify(slot / 'rustup/toolchains' / (rust.VERSION + '-' + triple), base)
        record = {'version': rust.VERSION, 'manager_sha256': digest, 'files': common.inventory(slot)}
        with (slot / 'rust-ready.json').open('x', encoding='utf-8') as stream:
            os.chmod(slot / 'rust-ready.json', 0o600)
            json.dump(record, stream)
        print('Private Rust-Basis erfolgreich geprueft; noch kein erfolgreicher LiteLLM-Build.', flush=True)
        return root
    except BaseException:
        if published:
            shutil.rmtree(common.checked(slot))
        raise
    finally:
        if stage.exists():
            shutil.rmtree(common.checked(stage))
