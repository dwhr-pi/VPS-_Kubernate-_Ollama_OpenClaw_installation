"""Find installed pinned Rust without invoking rustup or downloading compilers."""
import os
from pathlib import Path
import re
import shutil
import subprocess

import gap_tools as common

VERSION = '1.98.0'
GUIDANCE = ('LiteLLM: vorhandenes Rust ' + VERSION + ' mit cargo/rustc erforderlich. '
            'Privaten Bootstrap bewusst mit bash scripts/tools/litellm_install.sh --install-build-deps freigeben. '
            'NATIVE_SOURCE_RUST_TOOLCHAIN auf den absoluten Toolchain-Ordner mit bin/cargo und bin/rustc setzen. '
            'Falls rustup bereits vorhanden ist: rustup toolchain install ' + VERSION +
            ' --profile minimal --no-self-update bewusst separat ausfuehren. '
            'Kein automatischer Rust-Download, kein apt-Rust. Siehe docs/tools/litellm.md.')


def verify(root, cwd):
    if not root.is_absolute() or not root.is_dir():
        raise ValueError('Absoluter vorhandener Toolchain-Ordner erforderlich.')
    root = root.resolve()
    for name in ('cargo', 'rustc'):
        binary = root / 'bin' / name
        if (not binary.is_file() or not binary.resolve().is_relative_to(root)
                or binary.resolve().name in ('rustup', 'rustup.exe')):
            raise ValueError('Direkte cargo/rustc-Dateien im Toolchain-Ordner erforderlich; keine rustup-Shims.')
    env = {key: value for key, value in os.environ.items() if key in ('PATH', 'LANG', 'LC_ALL')}
    env.update(RUSTUP_TOOLCHAIN=str(root), RUSTUP_AUTO_INSTALL='0')
    for name in ('rustc', 'cargo'):
        value = common.run([root / 'bin' / name, '--version'], cwd, env)
        if not re.fullmatch(re.escape(name + ' ' + VERSION) + r'(?: \([^\n]*\))?', value.strip()):
            raise ValueError('Rust-/Cargo-Version entspricht nicht dem LiteLLM-Pin ' + VERSION + '.')
    sysroot = common.run([root / 'bin/rustc', '--print', 'sysroot'], cwd, env).strip()
    if not Path(sysroot).is_absolute() or Path(sysroot).resolve() != root:
        raise ValueError('Rust-sysroot passt nicht zur ausgewaehlten Toolchain.')
    return root


def select(base):
    explicit = os.environ.get('NATIVE_SOURCE_RUST_TOOLCHAIN')
    if explicit:
        try:
            return verify(Path(explicit), base)
        except (OSError, ValueError, subprocess.SubprocessError) as error:
            raise ValueError('LiteLLM: explizites NATIVE_SOURCE_RUST_TOOLCHAIN ungueltig; keine automatische Ersetzung. ' + GUIDANCE) from error
    candidates = []
    private = base / 'toolchain'
    if private.is_dir():
        candidates.extend(private.glob('rust-' + VERSION + '-linux-*/rustup/toolchains/' + VERSION + '-*'))
    configured_home = os.environ.get('RUSTUP_HOME')
    rust_home = Path(configured_home) if configured_home else Path.home() / '.rustup'
    if rust_home.is_absolute() and (rust_home / 'toolchains').is_dir():
        for pattern in (VERSION + '-*', 'stable-*'):
            candidates.extend(sorted((rust_home / 'toolchains').glob(pattern)))
    rustc = shutil.which('rustc')
    if rustc:
        candidate = Path(rustc)
        if candidate.is_absolute() and candidate.parent.name == 'bin':
            candidates.append(candidate.parent.parent)
    for candidate in dict.fromkeys(candidates):
        try:
            root = verify(candidate, base)
        except (OSError, ValueError, subprocess.SubprocessError):
            continue
        print('LiteLLM: vorhandene Rust-Toolchain geprueft:', root, flush=True)
        return root
    raise ValueError(GUIDANCE)


def activate(base, spec, env):
    if spec['id'] != 'litellm':
        return
    root = select(base)
    parts = env.get('PATH', '').split(os.pathsep)
    # Keep the container/sudo guards ahead of the compiler directory.
    parts.insert(1 if parts and Path(parts[0]).name == 'guards' else 0, str(root / 'bin'))
    env.update(PATH=os.pathsep.join(parts), RUSTUP_TOOLCHAIN=str(root), RUSTUP_AUTO_INSTALL='0')
