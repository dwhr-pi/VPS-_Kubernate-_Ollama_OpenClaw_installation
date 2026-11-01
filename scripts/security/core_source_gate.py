"""Offline source-byte verification, never an installer or an authenticated attestation."""
import argparse
from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path
import re
import stat
import sys

REPOS = {'ollama': 'ollama/ollama', 'k3s': 'k3s-io/k3s'}
MAX_ARTIFACT = 1024**3


class Parser(argparse.ArgumentParser):
    def error(self, message):
        self.print_usage(sys.stderr)
        self.exit(2, 'Ungueltige Optionen; kein Force-, Download- oder Apply-Modus.\n')


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError('Duplicate manifest field')
        result[key] = value
    return result


@contextmanager
def regular_input(path, limit):
    path = Path(path)
    if not path.is_absolute() or '..' in path.parts:
        raise ValueError('Absolute input required')
    for component in (path, *path.parents):
        info = component.lstat()
        if stat.S_ISLNK(info.st_mode) or (hasattr(component, 'is_junction') and component.is_junction()):
            raise ValueError('Linked input rejected')
    before = path.lstat()
    if not stat.S_ISREG(before.st_mode) or before.st_nlink != 1 or not 0 < before.st_size <= limit:
        raise ValueError('Invalid input type or size')
    descriptor = os.open(path, os.O_RDONLY | getattr(os, 'O_NOFOLLOW', 0) | getattr(os, 'O_BINARY', 0))
    with os.fdopen(descriptor, 'rb') as stream:
        opened = os.fstat(stream.fileno())
        if ((opened.st_dev, opened.st_ino) != (before.st_dev, before.st_ino)
                or not stat.S_ISREG(opened.st_mode) or opened.st_nlink != 1):
            raise ValueError('Input changed before open')
        yield stream, opened
        after = os.fstat(stream.fileno())
        if (after.st_size, after.st_mtime_ns, after.st_ctime_ns) != (opened.st_size, opened.st_mtime_ns, opened.st_ctime_ns):
            raise ValueError('Input changed during verification')


def manifest(path, tool):
    with regular_input(path, 65536) as (stream, _):
        payload = stream.read(65537)
    if len(payload) > 65536:
        raise ValueError('Manifest grew beyond limit')
    data = json.loads(payload, object_pairs_hook=unique_object)
    required = {'schema', 'tool', 'source_commit', 'url', 'sha256', 'size'}
    if not isinstance(data, dict) or set(data) != required or type(data['schema']) is not int or data['schema'] != 1:
        raise ValueError('Unsupported manifest schema')
    pin = data['source_commit']
    if (data['tool'] != tool or not isinstance(pin, str) or not re.fullmatch('[a-f0-9]{40}', pin)
            or pin == '0' * 40 or data['url'] != f'https://github.com/{REPOS[tool]}/archive/{pin}.tar.gz'):
        raise ValueError('Immutable official source contract required')
    if (not isinstance(data['sha256'], str) or not re.fullmatch('[a-f0-9]{64}', data['sha256'])
            or data['sha256'] == '0' * 64 or type(data['size']) is not int or not 1 <= data['size'] <= MAX_ARTIFACT):
        raise ValueError('Reviewed digest and bounded size required')
    return data


def verify(tool, lock, artifact):
    contract = manifest(lock, tool)
    digest = hashlib.sha256()
    count = 0
    with regular_input(artifact, contract['size']) as (stream, metadata):
        if metadata.st_size != contract['size']:
            raise ValueError('Artifact size mismatch')
        while True:
            block = stream.read(min(65536, contract['size'] - count + 1))
            if not block:
                break
            count += len(block)
            if count > contract['size']:
                raise ValueError('Artifact grew beyond contract')
            digest.update(block)
        if count != contract['size'] or digest.hexdigest() != contract['sha256']:
            raise ValueError('Artifact integrity mismatch')
    return {'tool': tool, 'scope': 'source-byte-integrity-only', 'source_commit': contract['source_commit'],
            'verified': True, 'authenticity_verified': False, 'archive_contents_verified': False,
            'installed': False, 'service_started': False}


def main(argv=None):
    parser = Parser(description=__doc__)
    parser.add_argument('tool', choices=tuple(REPOS))
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--plan', '--dry-run', action='store_true')
    mode.add_argument('--verify-source', action='store_true')
    parser.add_argument('--manifest', type=Path)
    parser.add_argument('--artifact', type=Path)
    args = parser.parse_args(argv)
    try:
        if not args.verify_source:
            if args.manifest or args.artifact:
                raise ValueError('Input paths require explicit source verification')
            print(json.dumps({'tool': args.tool, 'mode': 'plan', 'installed': False, 'network_calls': False,
                              'writes': False, 'service_started': False, 'legacy_installer': 'blocked'}))
            print('Direktinstallation gesperrt; keine veraenderlichen Internetskripte ausfuehren. '
                  'Geprueften nativen Core-/GitOps-Pfad separat planen. Siehe docs/P0_B_CORE_SOURCES.md.')
            return 3
        if not args.manifest or not args.artifact:
            raise ValueError('Reviewed manifest and source artifact required')
        print(json.dumps(verify(args.tool, args.manifest, args.artifact)))
        print('Quellenbytes geprueft, NICHT installiert. Kein Build, Entpacken, Dienst oder Erfolgsmarker.')
        return 3
    except (OSError, ValueError, KeyError, TypeError, RecursionError):
        print('Quellenpruefung fehlgeschlagen; kein Download, Build, Dienst oder Statusaenderung.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
