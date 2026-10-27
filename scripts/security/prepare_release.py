"""Release-Metadaten aus einem lokalen Tag exportieren; signiert/veroefentlicht nichts."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tempfile
import os

ROOT = Path(__file__).resolve().parents[2]


def prepare(repo, tag, destination):
    import importlib.util
    spec = importlib.util.spec_from_file_location('release_contract', Path(__file__).with_name('release_manifest.py'))
    contract = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(contract)
    if not contract.TAG.fullmatch(tag):
        raise ValueError('Expliziter Release-Tag erforderlich.')
    repo, destination = Path(repo).resolve(strict=True), Path(destination).absolute()
    if destination.exists() or destination.is_symlink() or destination.resolve().is_relative_to(repo):
        raise ValueError('Neues Exportziel ausserhalb des Repositories erforderlich.')
    env = {key: value for key, value in os.environ.items() if key in ('PATH', 'SYSTEMROOT', 'LANG')}
    env.update(GIT_CONFIG_GLOBAL=os.devnull, GIT_CONFIG_NOSYSTEM='1', GIT_NOREPLACE_OBJECTS='1')

    def git(*args):
        return subprocess.run(['git', '-c', 'core.hooksPath=' + os.devnull, '-C', str(repo), *args],
                              env=env, check=True, capture_output=True, timeout=30).stdout

    commit = git('rev-parse', '--verify', '--end-of-options', 'refs/tags/' + tag + '^{commit}').decode().strip()
    installer = git('show', commit + ':install.sh')
    metadata = json.dumps({'schema_version': 1, 'tag': tag, 'commit': commit, 'repo': contract.REPO},
                          sort_keys=True, indent=2).encode() + b'\n'
    if not destination.parent.is_dir() or destination.parent != destination.parent.resolve():
        raise ValueError('Bestehendes kanonisches Export-Elternverzeichnis erforderlich.')
    with tempfile.TemporaryDirectory(prefix='release-export-', dir=destination.parent) as temp:
        stage = Path(temp) / 'artifacts'
        stage.mkdir(mode=0o700)
        payloads = {'install.sh': installer, 'release.json': metadata}
        for name, content in payloads.items():
            (stage / name).write_bytes(content)
        (stage / 'SHA256SUMS').write_text(''.join(hashlib.sha256(content).hexdigest() + '  ' + name + '\n'
                                               for name, content in sorted(payloads.items())), encoding='ascii')
        stage.rename(destination)
    return commit


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=ROOT)
    parser.add_argument('--tag', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    try:
        print('Unsigned release metadata exported: ' + prepare(args.repo, args.tag, args.output))
    except (ValueError, OSError, subprocess.SubprocessError):
        parser.exit(1, 'Release-Export fehlgeschlagen; lokaler Tag und neues externes Exportziel erforderlich.\n')


if __name__ == '__main__':
    main()
