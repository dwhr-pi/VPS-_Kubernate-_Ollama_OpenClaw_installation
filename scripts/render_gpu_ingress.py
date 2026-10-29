"""Ingress-Konfiguration offline erzeugen; niemals DNS oder Cluster veraendern."""
import argparse
import ipaddress
import json
from pathlib import Path
import re


def resources(domain, email, cidr):
    if not re.fullmatch(r'(?=.{1,253}$)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,63}', domain):
        raise ValueError('Eigene gueltige DNS-Domain erforderlich')
    if domain.endswith(('.invalid', '.localhost', '.example')) or domain in ('example.com', 'example.org', 'example.net'):
        raise ValueError('Beispieldomains sind nicht freigegeben')
    if not re.fullmatch(r'[^\s@]+@[^\s@]+\.[^\s@]+', email):
        raise ValueError('Gueltiger ACME-Kontakt erforderlich')
    network = ipaddress.ip_network(cidr, strict=True)
    # Nur explizite private Netze, keine weltweite Freigabe.
    private = ['10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16', 'fc00::/7']
    if not any(network.version == ipaddress.ip_network(block).version and network.subnet_of(ipaddress.ip_network(block)) for block in private):
        raise ValueError('Privates VPN-/Clientnetz erforderlich')
    metadata = {'name': 'llmops-api', 'namespace': 'llmops'}
    return {'apiVersion': 'v1', 'kind': 'List', 'items': [
        {'apiVersion': 'cert-manager.io/v1', 'kind': 'Issuer',
         'metadata': {'name': 'letsencrypt-production', 'namespace': 'llmops'},
         'spec': {'acme': {'email': email, 'server': 'https://acme-v02.api.letsencrypt.org/directory',
                           'privateKeySecretRef': {'name': 'letsencrypt-account'},
                           'solvers': [{'http01': {'ingress': {'ingressClassName': 'traefik'}}}]}}},
        {'apiVersion': 'traefik.io/v1alpha1', 'kind': 'Middleware', 'metadata': metadata,
         'spec': {'ipAllowList': {'sourceRange': [str(network)]}}},
        {'apiVersion': 'networking.k8s.io/v1', 'kind': 'Ingress',
         'metadata': {**metadata, 'annotations': {'cert-manager.io/issuer': 'letsencrypt-production',
                       'traefik.ingress.kubernetes.io/router.entrypoints': 'websecure',
                       'traefik.ingress.kubernetes.io/router.tls': 'true',
                       'traefik.ingress.kubernetes.io/router.middlewares': 'llmops-llmops-api@kubernetescrd'}},
         'spec': {'ingressClassName': 'traefik', 'tls': [{'hosts': [domain], 'secretName': 'llmops-api-tls'}],
                  'rules': [{'host': domain, 'http': {'paths': [{'path': '/v1', 'pathType': 'Prefix',
                    'backend': {'service': {'name': 'litellm', 'port': {'number': 4000}}}}]}}]}}
    ]}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--domain', required=True)
    parser.add_argument('--email', required=True)
    parser.add_argument('--client-cidr', required=True)
    args = parser.parse_args()
    try:
        print(json.dumps(resources(args.domain, args.email, args.client_cidr), indent=2))
    except ValueError as error:
        parser.error(str(error))


if __name__ == '__main__':
    main()
