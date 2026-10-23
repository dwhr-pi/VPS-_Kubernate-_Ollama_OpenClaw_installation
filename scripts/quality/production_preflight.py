#!/usr/bin/env python3
"""Reject incomplete deployment inputs without contacting infrastructure."""
import argparse
from pathlib import Path
import re
import sys

DIGEST = re.compile(r'[^\s@]+@sha256:[a-f0-9]{64}\Z')
IMAGE_KEYS = ('PROMETHEUS_IMAGE', 'GRAFANA_IMAGE', 'LOKI_IMAGE', 'ALLOY_IMAGE', 'NODE_EXPORTER_IMAGE')


def validate_manifest(text):
    if re.search(r'REPLACE|example\.invalid', text):
        raise ValueError('Manifest enthaelt noch Platzhalter.')
    images = re.findall(r'''(?m)^\s*image:\s*["']?([^\s"']+)''', text)
    if not images or any(not DIGEST.fullmatch(image) for image in images):
        raise ValueError('Alle Images muessen mit vollstaendigem sha256-Digest gepinnt sein.')


def validate_monitoring(text):
    values = {}
    for line in text.splitlines():
        if not line or line.startswith('#'):
            continue
        key, separator, value = line.partition('=')
        if not separator or key in values:
            raise ValueError('Ungueltige oder doppelte Monitoring-env-Variable.')
        values[key] = value.strip('"\'')
    if any(not DIGEST.fullmatch(values.get(key, '')) for key in IMAGE_KEYS):
        raise ValueError('Alle Monitoring-Images benoetigen einen sha256-Digest.')
    for key in ('MONITORING_SECRET_DIR', 'LLMOPS_LOG_DIR'):
        if not Path(values.get(key, '')).is_absolute():
            raise ValueError('Absolute Secret- und Log-Verzeichnisse erforderlich.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--monitoring-env', type=Path)
    args = parser.parse_args()
    try:
        if args.monitoring_env:
            validate_monitoring(args.monitoring_env.read_text(encoding='utf-8'))
        else:
            if sys.stdin.isatty():
                parser.error('Gerendertes Manifest ueber stdin uebergeben.')
            validate_manifest(sys.stdin.read())
    except (OSError, ValueError) as error:
        # Never echo manifests, env contents, image references or credentials.
        print(f'Vorpruefung fehlgeschlagen: {type(error).__name__}. Konfiguration/Pins pruefen.', file=sys.stderr)
        return 1
    print('Statische Vorpruefung erfolgreich; keine Deployment-/Cluster-Freigabe.')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
