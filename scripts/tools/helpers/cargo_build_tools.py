"""Explicit shared Rust/Cargo bootstrap using the already approved private toolchain."""
import argparse
import json
import os
import subprocess
import sys

import gap_tools as common
import litellm_rust as rust
import litellm_rust_bootstrap as bootstrap

SPEC = {'id': 'cargo_build_tools', 'name': 'Cargo/Rust Build Tools',
        'recipe': {'disk_mb': 4096}}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', nargs='?', default='plan', choices=('plan', 'install', 'status', 'doctor'))
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args(argv)
    if args.apply and args.action != 'install':
        parser.error('--apply ist nur fuer install erlaubt')
    if args.action == 'plan' or (args.action == 'install' and not args.apply):
        print(json.dumps(dict(action='plan', installed=False, apply=False, rust_version=rust.VERSION,
                              rustup_version=bootstrap.MANAGER_VERSION, source='https://static.rust-lang.org',
                              source_exception='existing-approved-private-compiler-bootstrap',
                              target='USER_WORKSPACE/tools/cargo_build_tools', reserve_mb=6144,
                              docker=False, sudo=False, global_path_change=False)))
        return 0 if args.action == 'plan' else 2
    base, _, _ = common.paths(SPEC['id'])
    if args.action in ('status', 'doctor'):
        root = bootstrap.existing(base)
        print(json.dumps(dict(installed=root is not None, toolchain=str(root) if root else None,
                              application_tested=False)))
        return 0 if root is not None or args.action == 'status' else 1
    # Do not run as root or modify a shared system compiler installation.
    if hasattr(os, 'geteuid') and os.geteuid() == 0:
        raise ValueError('Private Cargo/Rust-Basis als normaler Benutzer installieren, nicht mit sudo.')
    if os.environ.get('NATIVE_SOURCE_RUST_TOOLCHAIN'):
        raise ValueError('Explizite NATIVE_SOURCE_RUST_TOOLCHAIN gesetzt; vorhandene Basis verwenden, nicht automatisch ersetzen.')
    with common.operation(base, 'install', tool='Cargo_Build_Tools'):
        root = bootstrap.prepare(base, SPEC, approved=True)
        print('Gepruefte Toolchain:', root)
        print('Nur Buildwerkzeuge; kein XERJ-/LiteLLM-Build und kein Dienst gestartet.')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, TypeError, subprocess.SubprocessError) as error:
        print('Cargo/Rust-Basis: ' + str(error), file=sys.stderr)
        sys.exit(1)
