"""Validate reviewed bootstrap artifacts offline; never download or execute anything."""
import argparse
import ipaddress
import json
from pathlib import Path
import re


PATTERNS = {
    'k3s': r'https://github\.com/k3s-io/k3s/releases/download/v[0-9][0-9A-Za-z.%+_-]*/k3s(?:-arm64)?',
    'k3s_installer': r'https://raw\.githubusercontent\.com/k3s-io/k3s/[a-f0-9]{40}/install\.sh',
    'cloudflared': r'https://github\.com/cloudflare/cloudflared/releases/download/[0-9][0-9A-Za-z._-]*/cloudflared-linux-(?:amd64|arm64)',
    'argocd': r'https://raw\.githubusercontent\.com/argoproj/argo-cd/[a-f0-9]{40}/manifests/core-install\.yaml',
}


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError('Doppelter JSON-Schluessel.')
        result[key] = value
    return result


def document(path):
    path = Path(path)
    if path.is_symlink() or not path.is_file() or path.stat().st_size > 65536:
        raise ValueError('Regulaere kleine Artefakt-Lockdatei erforderlich.')
    data = json.loads(path.read_text(encoding='utf-8'), object_pairs_hook=unique_object)
    if not isinstance(data, dict) or set(data) != {'schema_version', 'platforms', 'argocd_images'}:
        raise ValueError('Lockfelder ungueltig.')
    pins = data['argocd_images']
    if not isinstance(pins, dict) or not 1 <= len(pins) <= 32:
        raise ValueError('Argo-Image-Digests erforderlich.')
    for source, digest in pins.items():
        if (not re.fullmatch(r'[A-Za-z0-9._/@:-]+', source) or not isinstance(digest, str)
                or not re.fullmatch(r'sha256:[a-f0-9]{64}', digest) or digest == 'sha256:' + '0' * 64):
            raise ValueError('Argo-Image-Pin ungueltig.')
    return data


def validate(path, arch):
    data = document(path)
    if type(data['schema_version']) is not int or data['schema_version'] != 1 or arch not in ('linux-amd64', 'linux-arm64'):
        raise ValueError('Lockschema oder Architektur ungueltig.')
    assets = data['platforms'][arch]
    if not isinstance(assets, dict) or set(assets) != set(PATTERNS):
        raise ValueError('Genau vier freigegebene Bootstrap-Artefakte erforderlich.')
    for name, pattern in PATTERNS.items():
        item = assets[name]
        if not isinstance(item, dict) or set(item) != {'url', 'sha256'} or not isinstance(item['url'], str) or not re.fullmatch(pattern, item['url']):
            raise ValueError('Nicht freigegebene gepinnte GitHub-Quelle: ' + name)
        digest = item['sha256']
        if not isinstance(digest, str) or not re.fullmatch('[a-f0-9]{64}', digest) or digest == '0' * 64:
            raise ValueError('Echte, separat gepruefte SHA256 erforderlich: ' + name)
    suffix = 'arm64' if arch.endswith('arm64') else 'amd64'
    if not assets['cloudflared']['url'].endswith('linux-' + suffix):
        raise ValueError('Cloudflared-Architektur stimmt nicht.')
    version = assets['cloudflared']['url'].split('/download/', 1)[1].split('/')[0]
    if not re.fullmatch(r'[0-9]{4}\.[0-9]+\.[0-9]+', version) or tuple(map(int, version.split('.'))) < (2025, 4, 0):
        raise ValueError('Cloudflared >=2025.4.0 fuer --token-file erforderlich.')
    if assets['k3s']['url'].endswith('k3s-arm64') != (suffix == 'arm64'):
        raise ValueError('K3s-Architektur stimmt nicht.')
    version = assets['k3s']['url'].split('/download/', 1)[1].split('/')[0]
    match = re.fullmatch(r'v1\.([0-9]+)\.[0-9]+(?:%2B|\+)k3s[0-9]+', version)
    if not match or int(match.group(1)) < 34:
        raise ValueError('Dieser PSS-Vertrag erfordert einen geprueften K3s-Release >=1.34.')
    return assets


def pin_manifest(text, pins):
    # Nur explizite einzeilige image-Felder: unbekannte YAML-Formen fail-closed.
    pattern = re.compile(r'''(?m)^(\s*image:[ \t]*)(?:"([^"\n]+)"|'([^'\n]+)'|([^\s#]+))([ \t]*(?:\#[^\n]*)?)$''')
    matches = list(pattern.finditer(text))
    sources = {next(value for value in match.group(2, 3, 4) if value is not None) for match in matches}
    if not matches or len(matches) != len(re.findall(r'(?m)^\s*image:', text)) or sources != set(pins):
        raise ValueError('Argo-Manifest und vollstaendige Image-Pinliste passen nicht.')
    def replace(match):
        source = next(value for value in match.group(2, 3, 4) if value is not None)
        return match.group(1) + source.split('@', 1)[0] + '@' + pins[source] + match.group(5)
    return pattern.sub(replace, text)


def private_address(value):
    address = ipaddress.ip_address(value)
    networks = ('10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16')
    if address.version != 4 or not any(address in ipaddress.ip_network(n) for n in networks):
        raise ValueError('Vorhandene private RFC1918-IPv4 fuer API/Node erforderlich.')
    return str(address)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('lock')
    parser.add_argument('--arch', required=True)
    parser.add_argument('--private-address', required=True)
    parser.add_argument('--lines', action='store_true')
    parser.add_argument('--pin-argocd', type=Path)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    try:
        assets = validate(args.lock, args.arch)
        address = private_address(args.private_address)
        if args.pin_argocd:
            if args.lines or args.output is None:
                raise ValueError('Image-Pinning braucht eigenen neuen Ausgabepfad.')
            text = pin_manifest(args.pin_argocd.read_text(encoding='utf-8'), document(args.lock)['argocd_images'])
            with args.output.open('x', encoding='utf-8') as target:
                target.write(text)
            return
        if args.output:
            raise ValueError('--output nur fuer --pin-argocd.')
    except (ValueError, KeyError, TypeError, OSError) as error:
        parser.exit(2, 'Bootstrap-Konfiguration ungueltig: ' + str(error) + '\n')
    if args.lines:
        for name in PATTERNS:
            print(name)
            print(assets[name]['url'])
            print(assets[name]['sha256'])
    else:
        print(json.dumps({'mode': 'offline-plan', 'private_address': address,
                          'assets': assets, 'argocd_image_pins': document(args.lock)['argocd_images'],
                          'traefik': 'retained', 'argocd': 'core',
                          'downloads': False, 'host_changes': False}, indent=2))


if __name__ == '__main__':
    main()
