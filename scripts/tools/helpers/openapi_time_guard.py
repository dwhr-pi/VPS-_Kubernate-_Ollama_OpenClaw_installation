"""Local authenticated ASGI guard for the pinned upstream time example only."""
import importlib.util
import json
import os
from pathlib import Path
import re
import secrets
import stat
from urllib.parse import urlsplit


def validate_config(config):
    if not isinstance(config, dict) or set(config) != {'version', 'port', 'bearer_token', 'allowed_origins'} or config['version'] != 1:
        raise ValueError('Unbekanntes Zeitserver-Konfigurationsschema.')
    if type(config['port']) is not int or not 1024 <= config['port'] <= 65535:
        raise ValueError('Zeitserver-Port muss zwischen 1024 und 65535 liegen.')
    if not isinstance(config['bearer_token'], str) or not re.fullmatch(r'[A-Za-z0-9_-]{32,128}', config['bearer_token']):
        raise ValueError('Zeitserver-Key fehlt oder hat ein ungueltiges Format.')
    if not isinstance(config['allowed_origins'], list):
        raise ValueError('allowed_origins muss eine Liste sein.')
    for origin in config['allowed_origins']:
        if not isinstance(origin, str):
            raise ValueError('Origin muss eine URL sein.')
        parsed = urlsplit(origin)
        if parsed.scheme not in ('https', 'http') or not parsed.hostname or parsed.username or parsed.password or '*' in origin or any(c.isspace() for c in origin) or parsed.path or parsed.query or parsed.fragment:
            raise ValueError('Nur exakte HTTP(S)-Origins ohne Pfad, Zugangsdaten oder Wildcard.')
    return config


def load_config(path):
    path = Path(path)
    for part in (path, *path.parents):
        info = part.lstat()
        if stat.S_ISLNK(info.st_mode) or getattr(info, 'st_file_attributes', 0) & 0x400:
            raise ValueError('Verknuepfte Zeitserver-Konfiguration nicht erlaubt.')
    info = path.stat()
    if not stat.S_ISREG(info.st_mode) or info.st_size > 16384:
        raise ValueError('Ungueltige Zeitserver-Konfigurationsdatei.')
    if os.name == 'posix' and (info.st_uid != os.geteuid() or stat.S_IMODE(info.st_mode) & 0o077):
        raise ValueError('Zeitserver-Konfiguration muss dem Nutzer gehoeren und Rechte 0600 haben.')
    return validate_config(json.loads(path.read_text(encoding='utf-8')))


class TimeGuard:
    def __init__(self, app, config):
        self.app = app
        self.config = validate_config(config)

    async def __call__(self, scope, receive, send):
        if scope['type'] != 'http':
            if scope['type'] == 'websocket':
                await send({'type': 'websocket.close', 'code': 1008})
                return
            return await self.app(scope, receive, send)
        headers = scope.get('headers', [])
        values = {key.lower(): value for key, value in headers}
        origin = values.get(b'origin', b'').decode('latin-1')
        host = values.get(b'host', b'').decode('latin-1').lower()
        allowed_hosts = {name + ':' + str(self.config['port']) for name in ('127.0.0.1', 'localhost')}
        status, body = 0, b''
        if host not in allowed_hosts:
            status, body = 403, b'Host not allowed'
        elif origin and origin not in self.config['allowed_origins']:
            status, body = 403, b'Origin not allowed'
        elif scope['method'] == 'OPTIONS':
            status, body = (204, b'') if origin else (403, b'Origin required')
        else:
            auth = [v for k, v in headers if k.lower() == b'authorization']
            expected = ('Bearer ' + self.config['bearer_token']).encode('ascii')
            if len(auth) != 1 or not secrets.compare_digest(auth[0], expected):
                status, body = 401, b'Bearer authentication required'

        async def cors_send(message):
            if message['type'] == 'http.response.start' and origin in self.config['allowed_origins']:
                message = {**message, 'headers': list(message.get('headers', [])) + [
                    (b'access-control-allow-origin', origin.encode('latin-1')), (b'vary', b'Origin'),
                    (b'access-control-allow-methods', b'GET, POST, OPTIONS'),
                    (b'access-control-allow-headers', b'Authorization, Content-Type')]}
            await send(message)
        if status:
            response_headers = [(b'content-type', b'text/plain'), (b'cache-control', b'no-store')]
            if status == 401:
                response_headers.append((b'www-authenticate', b'Bearer'))
            await cors_send({'type': 'http.response.start', 'status': status, 'headers': response_headers})
            await cors_send({'type': 'http.response.body', 'body': body})
            return
        await self.app(scope, receive, cors_send)


def create_app(root, config):
    module_path = Path(root) / 'servers/time/main.py'
    spec = importlib.util.spec_from_file_location('approved_upstream_time', module_path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    app = module.app
    # Replace the reference's wildcard CORS; no other upstream server is imported.
    app.user_middleware.clear()
    app.middleware_stack = None
    schema = app.openapi()
    schema.setdefault('components', {}).setdefault('securitySchemes', {})['bearerAuth'] = {'type': 'http', 'scheme': 'bearer'}
    schema['security'] = [{'bearerAuth': []}]
    return TimeGuard(app, config)


if __name__ == '__main__':
    import uvicorn
    root = Path(__file__).resolve().parent
    config = load_config(root.parent / 'config/time.json')
    uvicorn.run(create_app(root, config), host='127.0.0.1', port=config['port'],
                proxy_headers=False, access_log=False, limit_concurrency=16,
                timeout_keep_alive=5, server_header=False)
