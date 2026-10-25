#!/usr/bin/env python3
"""Apply only the LiteLLM Secret from SOPS; never log plaintext or write it to disk."""
import argparse
import base64
import json
from pathlib import Path
import subprocess
import sys


def validate(raw):
    value = json.loads(raw)
    metadata = value.get('metadata', {})
    if (value.get('apiVersion') != 'v1' or value.get('kind') != 'Secret'
            or value.get('type') != 'Opaque' or metadata.get('name') != 'litellm-runtime'
            or metadata.get('namespace') != 'llmops'):
        raise ValueError('Secret contract')
    data, string_data = value.get('data', {}), value.get('stringData', {})
    if bool(data) == bool(string_data):
        raise ValueError('Exactly one payload required')
    payload = data or string_data
    if set(payload) != {'master-key'} or not isinstance(payload['master-key'], str):
        raise ValueError('Only master-key allowed')
    key = base64.b64decode(payload['master-key'], validate=True) if data else payload['master-key'].encode('utf-8')
    if len(key) < 32 or b'REPLACE' in key or b'\n' in key or b'\r' in key:
        raise ValueError('Invalid key')
    # Whitelist metadata; do not propagate arbitrary annotations or ownership.
    return json.dumps({'apiVersion': 'v1', 'kind': 'Secret', 'type': 'Opaque',
                       'metadata': {'name': 'litellm-runtime', 'namespace': 'llmops'},
                       'data': {'master-key': base64.b64encode(key).decode('ascii')}})


def apply(path, context):
    if not path.is_absolute() or not path.is_file() or path.is_symlink() or path.stat().st_size > 8 * 1024**2:
        raise ValueError('Invalid input path')
    if not path.name.endswith(('.enc.yaml', '.enc.yml')) or not context or context.startswith('-'):
        raise ValueError('Encrypted file and explicit context required')
    result = subprocess.run(['sops', '--decrypt', '--output-type', 'json', str(path)],
                            capture_output=True, text=True, check=True, timeout=60)
    payload = validate(result.stdout)
    command = ['kubectl', '--context', context, '--request-timeout=30s', 'apply',
               '--server-side', '--field-manager=llmops-secrets', '--validate=strict']
    for flags in (['--dry-run=server'], []):
        # Capture failures too: Kubernetes diagnostics can include submitted objects.
        subprocess.run(command + flags + ['-f', '-'], input=payload,
                       capture_output=True, text=True, check=True, timeout=60)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--file', required=True, type=Path)
    parser.add_argument('--context', required=True)
    parser.add_argument('--confirm-apply', action='store_true')
    args = parser.parse_args()
    if not args.confirm_apply:
        parser.error('--confirm-apply erforderlich; keine Entschluesselung ausgefuehrt')
    try:
        apply(args.file, args.context)
    except (OSError, ValueError, TypeError, AttributeError, subprocess.SubprocessError):
        print('Secret-Schritt fehlgeschlagen; Empfaenger, Kontext, Rechte und Secret-Vertrag separat pruefen. Keine Payload-Ausgabe.', file=sys.stderr)
        return 1
    print('LiteLLM-Secret angewendet; kein Proxy-Neustart oder Modellaufruf.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
