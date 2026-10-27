"""Kleiner read-only Ollama-Exporter; nur Inventar, keine Inferenz oder Modellaktionen."""
import argparse
import http.client
from http.server import BaseHTTPRequestHandler, HTTPServer
import ipaddress
import json
import math
import socket
import time
from urllib.parse import urlsplit
from urllib.request import HTTPRedirectHandler, ProxyHandler, Request, build_opener

NETWORKS = tuple(ipaddress.ip_network(value) for value in
                 ('10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16', 'fc00::/7'))


def private_ip(value):
    address = ipaddress.ip_address(value)
    if not (address.is_loopback or any(address in net for net in NETWORKS)):
        raise ValueError('Nur Loopback oder private IP-Adressen erlaubt.')
    return address


def endpoint(value):
    parsed = urlsplit(value)
    if (parsed.scheme not in ('http', 'https') or parsed.username is not None or
            parsed.password is not None or parsed.path not in ('', '/') or
            parsed.query or parsed.fragment or not parsed.hostname):
        raise ValueError('Private HTTP(S)-Basis ohne Zugangsdaten/Pfadparameter erforderlich.')
    if parsed.hostname != 'ollama.llmops.svc.cluster.local':
        private_ip(parsed.hostname)
    if parsed.port is not None and not 1 <= parsed.port <= 65535:
        raise ValueError('Ungueltiger Zielport.')
    return value.rstrip('/') + '/api/ps'


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        raise ValueError('Exporter folgt keinen Umleitungen.')


def number(value):
    if (isinstance(value, bool) or not isinstance(value, (int, float)) or
            value < 0 or value > 2**63 or not math.isfinite(value)):
        raise ValueError('Ungueltige Inventarzahl.')
    return value


def inventory(data):
    models = data.get('models') if isinstance(data, dict) else None
    if not isinstance(models, list) or len(models) > 1024:
        raise ValueError('Ungueltige Inventarliste.')
    return len(models), sum(number(model.get('size_vram')) for model in models)


def scrape(url, opener, clock=time.monotonic):
    started = clock()
    up, count, vram = 0, 0, 0
    try:
        # Ausschliesslich GET /api/ps; keine /generate-, /chat-, /pull- oder Loeschaufrufe.
        with opener.open(Request(url, method='GET'), timeout=2) as response:
            payload = response.read(1048577)
        if len(payload) > 1048576:
            raise ValueError('Antwort zu gross.')
        count, vram = inventory(json.loads(payload))
        up = 1
    except (OSError, ValueError, TypeError, AttributeError, http.client.HTTPException):
        pass  # Keine Upstream-Antworten, Modellnamen oder Zugangsdaten protokollieren.
    values = {
        'ollama_monitor_up': (up, 'Inventarabfrage erfolgreich, nicht Inferenzgesundheit.'),
        'ollama_monitor_loaded_models': (count, 'Anzahl aktuell geladener Modelle.'),
        'ollama_monitor_loaded_vram_bytes': (vram, 'Von Ollama gemeldete VRAM-Belegung geladener Modelle.'),
        'ollama_monitor_poll_duration_seconds': (max(0, clock() - started), 'Dauer der Inventarabfrage, keine Inferenzlatenz.'),
    }
    return ''.join(f'# HELP {name} {help_text}\n# TYPE {name} gauge\n{name} {value}\n'
                   for name, (value, help_text) in values.items()).encode('utf-8')


def handler(url, opener):
    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            if self.path == '/metrics':
                body, status = scrape(url, opener), 200
            elif self.path == '/healthz':
                body, status = b'ok\n', 200
            else:
                body, status = b'not found\n', 404
            self.send_response(status)
            self.send_header('Content-Type', 'text/plain; version=0.0.4; charset=utf-8')
            self.send_header('Content-Length', str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def log_message(self, *_):
            pass
    return Handler


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--ollama-url', default='http://127.0.0.1:11434')
    parser.add_argument('--listen-address', default='127.0.0.1')
    parser.add_argument('--port', type=int, default=9404)
    args = parser.parse_args()
    try:
        url, address = endpoint(args.ollama_url), private_ip(args.listen_address)
        if not 1024 <= args.port <= 65535:
            raise ValueError('Unprivilegierter Listener-Port erforderlich.')
    except ValueError as error:
        parser.error(str(error))
    # Keine geerbten Proxy-Einstellungen; TLS-Pruefung von urllib bleibt aktiv.
    opener = build_opener(ProxyHandler({}), NoRedirect())
    class PrivateHTTPServer(HTTPServer):
        address_family = socket.AF_INET6 if address.version == 6 else socket.AF_INET

        def get_request(self):
            connection, peer = super().get_request()
            connection.settimeout(5)
            return connection, peer
    server_type = PrivateHTTPServer
    with server_type((str(address), args.port), handler(url, opener)) as server:
        server.serve_forever()


if __name__ == '__main__':
    main()
