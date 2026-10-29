"""Expliziter Helm-Plan/Render/Apply; keine automatische Host-Konfiguration."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.parse
import urllib.request

ROOT = Path(__file__).resolve().parents[2]


def run(args, **kwargs):
    return subprocess.run(args, check=True, text=True, timeout=1200, **kwargs)


def fetch_chart(item, target):
    # Nur feste GitHub-Release-URLs, HTTPS und begrenzte Downloadgroesse.
    url = urllib.parse.urlsplit(item['url'])
    if url.scheme != 'https' or url.netloc != 'github.com' or '/releases/download/' not in url.path:
        raise ValueError('Nicht freigegebene Chart-Quelle')
    if not re.fullmatch(r'[a-f0-9]{64}', item['sha256']):
        raise ValueError('Ungueltige SHA256')

    class HTTPSOnly(urllib.request.HTTPRedirectHandler):
        def redirect_request(self, req, fp, code, msg, headers, newurl):
            if urllib.parse.urlsplit(newurl).scheme != 'https':
                raise ValueError('Unsichere Download-Umleitung')
            return super().redirect_request(req, fp, code, msg, headers, newurl)

    opener = urllib.request.build_opener(HTTPSOnly())
    digest = hashlib.sha256()
    count = 0
    with opener.open(item['url'], timeout=60) as response, target.open('xb') as output:
        while chunk := response.read(1024 * 1024):
            count += len(chunk)
            if count > 100 * 1024 * 1024:
                raise ValueError('Chart groesser als Downloadlimit')
            digest.update(chunk)
            output.write(chunk)
    if digest.hexdigest() != item['sha256']:
        raise ValueError('Chart-Pruefsumme stimmt nicht; kein Helm-Aufruf')


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('stack', choices=['monitoring', 'nvidia'])
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument('--plan', action='store_true')
    mode.add_argument('--render', action='store_true')
    mode.add_argument('--apply', action='store_true')
    parser.add_argument('--context')
    parser.add_argument('--confirm', action='store_true')
    parser.add_argument('--allow-upgrade', action='store_true')
    args = parser.parse_args(argv)
    manifest = json.loads((ROOT / 'config/platform_helm_releases.json').read_text())
    names = ['nvidia'] if args.stack == 'nvidia' else ['prometheus', 'loki']
    items = [manifest['releases'][name] for name in names]
    if not args.render and not args.apply:
        print(json.dumps({'mode': 'offline-plan', 'releases': items,
                          'warning': 'Keine Installation. Treiber, Secrets, Storage und Kapazitaet separat pruefen.'}, indent=2))
        return 0
    if not shutil.which('helm'):
        raise ValueError('Helm fehlt; separat aus gepruefter Quelle einrichten')
    if args.apply:
        if not args.context or not args.confirm:
            raise ValueError('--apply erfordert --context und --confirm')
        if not shutil.which('kubectl'):
            raise ValueError('kubectl fehlt')
        kube = ['kubectl', '--context', args.context]
        run(kube + ['cluster-info'], stdout=subprocess.DEVNULL)
        if args.stack == 'monitoring':
            # Kein generiertes oder fest eingebautes Grafana-Passwort.
            result = run(kube + ['-n', 'monitoring', 'get', 'secret', 'grafana-admin',
                                 '-o', 'go-template={{if and (index .data "admin-user") (index .data "admin-password")}}ready{{end}}'],
                         capture_output=True)
            if result.stdout.strip() != 'ready':
                raise ValueError('Grafana-Secret braucht admin-user und admin-password')
        else:
            run(kube + ['get', 'runtimeclass', 'nvidia'], stdout=subprocess.DEVNULL)
            result = run(kube + ['get', 'nodes', '-l', 'nvidia.com/gpu.present=true', '-o', 'name'], capture_output=True)
            if not result.stdout.strip():
                raise ValueError('Kein ausdruecklich gekennzeichneter NVIDIA-Node')
        # Existierende Releases werden nicht stillschweigend aktualisiert/adoptiert.
        for item in items:
            result = run(['helm', 'list', '--kube-context', args.context, '-n', item['namespace'],
                          '--all', '-o', 'json'], capture_output=True)
            if any(release['name'] == item['name'] for release in json.loads(result.stdout)) and not args.allow_upgrade:
                raise ValueError('Release existiert: Upgrade nur nach Review mit --allow-upgrade')
        if args.stack == 'monitoring':
            run(kube + ['apply', '-f', str(ROOT / 'k8s/monitoring/network-policy.yml')])
    # Nur eigene temporaere Downloads aufraeumen; niemals PVCs/Workspaces loeschen.
    with tempfile.TemporaryDirectory(prefix='llmops-helm-') as temporary:
        os.chmod(temporary, 0o700)
        for item in items:
            chart = Path(temporary) / (item['name'] + '.tgz')
            fetch_chart(item, chart)
            values = ROOT / item['values']
            if args.render:
                run(['helm', 'template', item['name'], str(chart), '--namespace', item['namespace'],
                     '--include-crds', '-f', str(values)])
            else:
                run(['helm', 'upgrade', '--install', item['name'], str(chart), '--kube-context', args.context,
                     '--namespace', item['namespace'], '--create-namespace', '--atomic', '--wait',
                     '--timeout', '15m', '--history-max', '5', '-f', str(values)])
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(f'Abbruch: {error}', file=sys.stderr)
        sys.exit(1)
