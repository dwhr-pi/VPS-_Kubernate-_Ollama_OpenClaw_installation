"""Generate opt-in private Prometheus/Alertmanager JSON (valid YAML), no services."""
import argparse
import importlib.util
import ipaddress
import json
from pathlib import Path
import sys
from urllib.parse import urlsplit

spec = importlib.util.spec_from_file_location('private_env', Path(__file__).with_name('private_env.py'))
private = importlib.util.module_from_spec(spec)
spec.loader.exec_module(private)


def endpoint(value):
    host, port = value.rsplit(':', 1)
    ip = ipaddress.ip_address(host.strip('[]'))
    networks = ('10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16', '127.0.0.0/8',
                '100.64.0.0/10', 'fc00::/7', '::1/128')
    if (not port.isdecimal() or not 1 <= int(port) <= 65535
            or not any(ip in ipaddress.ip_network(network) for network in networks)):
        raise ValueError('Only explicit VPN/private or loopback IP endpoints allowed')
    return f'[{ip}]:{int(port)}' if ip.version == 6 else f'{ip}:{int(port)}'


def configurations(litellm, node, exporter, token, receiver, rules):
    jobs = [{'job_name': 'prometheus', 'static_configs': [{'targets': ['127.0.0.1:9090']}]}]
    for name, target in (('litellm', litellm), ('node', node), ('ollama-exporter', exporter)):
        job = {'job_name': name, 'static_configs': [{'targets': [endpoint(target)]}], 'sample_limit': 20000}
        if name == 'litellm':
            job['authorization'] = {'type': 'Bearer', 'credentials_file': str(token)}
        jobs.append(job)
    prom = {'global': {'scrape_interval': '30s', 'scrape_timeout': '10s'}, 'rule_files': [str(rules)],
            'alerting': {'alertmanagers': [{'static_configs': [{'targets': ['127.0.0.1:9093']}]}]},
            'scrape_configs': jobs}
    alert = {'route': {'receiver': 'operator', 'group_by': ['alertname', 'job'], 'group_wait': '30s',
                       'group_interval': '5m', 'repeat_interval': '4h'},
             'receivers': [{'name': 'operator', 'webhook_configs': [{'url_file': str(receiver), 'send_resolved': True}]}]}
    return prom, alert


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--output', type=Path)
    parser.add_argument('--litellm')
    parser.add_argument('--node', default='127.0.0.1:9100')
    parser.add_argument('--ollama-exporter', default='127.0.0.1:9404')
    parser.add_argument('--token-file', type=Path)
    parser.add_argument('--receiver-file', type=Path)
    args = parser.parse_args(argv)
    if not args.apply:
        print('Plan only: private targets, external receiver file, native daemons. No reads/writes/reload/notification.')
        return 3
    try:
        if not all((args.output, args.litellm, args.token_file, args.receiver_file)):
            raise ValueError('Explicit private targets and secret files required')
        repo = Path(__file__).resolve().parents[2]
        for path in (args.output, args.token_file, args.receiver_file):
            if not path.is_absolute() or '..' in path.parts or repo == path or repo in path.parents:
                raise ValueError('Output and credential paths must be absolute and outside repository')
        if not private.read_private(args.token_file).strip():
            raise ValueError('Empty scoped metrics token')
        url = urlsplit(private.read_private(args.receiver_file).decode('utf-8').strip())
        if url.scheme != 'https' or not url.hostname or url.username or url.password or url.fragment:
            raise ValueError('Own HTTPS receiver required')
        prom, alert = configurations(args.litellm, args.node, args.ollama_exporter,
                                     args.token_file, args.receiver_file, repo / 'monitoring/alerts.yml')
        with private.directory(args.output, create=True, private=True) as target:
            # Two exclusive files, no replacement. Partial output is never silently adopted.
            private.publish(target, 'prometheus.json', json.dumps(prom, indent=2).encode())
            private.publish(target, 'alertmanager.json', json.dumps(alert, indent=2).encode())
        print('Configs written, NOT activated. Run promtool/amtool validation and an approved notification drill.')
        return 0
    except (OSError, ValueError, UnicodeError):
        print('Monitoring config refused; no secret values disclosed. Preserve/check any partial output.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
