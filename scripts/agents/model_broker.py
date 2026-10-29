"""Bounded local Ollama access for networkless workers; never forwards credentials."""
import http.client
from http.server import BaseHTTPRequestHandler
import json
import os
import re
import socketserver
import threading
import time
from urllib.parse import urlsplit

MAX_BODY = 1024 * 1024
MAX_RESPONSE = 8 * 1024 * 1024
GET_PATHS = {'/api/version', '/api/tags', '/v1/models'}
POST_PATHS = {'/v1/chat/completions', '/v1/responses', '/api/show'}


def endpoint(value):
    parsed = urlsplit(value)
    if (parsed.scheme != 'http' or parsed.hostname not in ('127.0.0.1', '::1') or
            parsed.username or parsed.password or parsed.path not in ('', '/') or parsed.query or parsed.fragment):
        raise ValueError('Only direct HTTP loopback Ollama, without credentials or redirects')
    return parsed.hostname, parsed.port or 11434


def model_name(value):
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9._:/-]{0,199}', value) or 'cloud' in value.lower():
        raise ValueError('Explicit local model name required')
    return value


class Broker:
    def __init__(self, base, model, requests=16, seconds=900):
        self.host, self.port = endpoint(base)
        self.model = model_name(model)
        self.remaining = requests
        self.deadline = time.monotonic() + seconds
        self.lock = threading.Lock()

    def local_model(self):
        connection = http.client.HTTPConnection(self.host, self.port, timeout=10)
        try:
            connection.request('GET', '/api/tags')
            response = connection.getresponse()
            raw = response.read(MAX_BODY + 1)
            if response.status != 200 or len(raw) > MAX_BODY:
                raise ValueError('Local model inventory unavailable')
            inventory = json.loads(raw)
            if not isinstance(inventory, dict) or not isinstance(inventory.get('models'), list):
                raise ValueError('Invalid local model inventory')
            rows = inventory['models']
            if any(not isinstance(row, dict) for row in rows):
                raise ValueError('Invalid local model inventory entry')
            rows = [row for row in rows if self.model in (row.get('name'), row.get('model'))]
            if (len(rows) != 1 or rows[0].get('remote_host') or rows[0].get('remote_model') or
                    not isinstance(rows[0].get('digest'), str) or
                    not re.fullmatch(r'(?:sha256:)?[a-f0-9]{64}', rows[0]['digest'])):
                raise ValueError('Model must be present locally with a digest; no pull or cloud fallback')
            return rows[0]['digest']
        finally:
            connection.close()

    def authorize(self, method, path, raw):
        if '?' in path or '#' in path or path not in (GET_PATHS if method == 'GET' else POST_PATHS):
            raise ValueError('API path denied')
        if method not in ('GET', 'POST') or len(raw) > MAX_BODY:
            raise ValueError('Method or request size denied')
        if method == 'GET':
            if raw:
                raise ValueError('GET body denied')
            body = None
        else:
            body = json.loads(raw)
            if not isinstance(body, dict) or body.get('model') != self.model:
                raise ValueError('Model switch denied')
            def safe_input(value):
                if isinstance(value, dict):
                    if any(key in value for key in ('image_url', 'file_url', 'api_base', 'base_url', 'remote_host', 'remote_model')):
                        raise ValueError('External/remote inputs denied')
                    if value.get('type') in ('input_image', 'input_file', 'image_url', 'input_audio'):
                        raise ValueError('Only text coding requests are supported')
                    for item in value.values():
                        safe_input(item)
                elif isinstance(value, list):
                    for item in value:
                        safe_input(item)
            safe_input(body)
            options = body.get('options', {})
            if not isinstance(options, dict) or ('num_ctx' in options and
                    (type(options['num_ctx']) is not int or not 1 <= options['num_ctx'] <= 4096)):
                raise ValueError('Context expansion denied')
            if path != '/api/show':
                # Enforced at the host boundary, not only in agent instructions.
                for field in ('max_tokens', 'max_completion_tokens', 'max_output_tokens'):
                    if field in body and (type(body[field]) is not int or not 1 <= body[field] <= 2048):
                        raise ValueError('Output token limit exceeded')
                field = 'max_output_tokens' if path == '/v1/responses' else 'max_tokens'
                body[field] = min(body.get(field, 2048), 2048)
        with self.lock:
            if self.remaining <= 0 or time.monotonic() >= self.deadline:
                raise ValueError('Session budget exhausted')
            self.remaining -= 1
        return None if body is None else json.dumps(body).encode()


class UnixHTTPServer(socketserver.ThreadingMixIn, getattr(socketserver, 'UnixStreamServer', socketserver.TCPServer)):
    daemon_threads = True

    def __init__(self, *args, **kwargs):
        self.slots = threading.BoundedSemaphore(4)
        self.accepted = 0
        self.accept_lock = threading.Lock()
        super().__init__(*args, **kwargs)

    def process_request(self, request, address):
        with self.accept_lock:
            self.accepted += 1
            allowed = self.accepted <= 64
        if not allowed or not self.slots.acquire(blocking=False):
            self.shutdown_request(request)
            return
        try:
            super().process_request(request, address)
        except BaseException:
            self.slots.release()
            raise

    def process_request_thread(self, request, address):
        try:
            super().process_request_thread(request, address)
        finally:
            self.slots.release()


def handler(broker):
    class Handler(BaseHTTPRequestHandler):
        def log_message(self, *_args):
            pass

        def do_GET(self):
            self.forward()

        def do_POST(self):
            self.forward()

        def forward(self):
            connection = None
            try:
                if self.headers.get('Transfer-Encoding'):
                    raise ValueError('Chunked requests denied')
                size = int(self.headers.get('Content-Length', '0'))
                if not 0 <= size <= MAX_BODY:
                    raise ValueError('Request size denied')
                self.connection.settimeout(30)
                raw = self.rfile.read(size)
                if len(raw) != size:
                    raise ValueError('Incomplete body')
                body = broker.authorize(self.command, self.path, raw)
                connection = http.client.HTTPConnection(broker.host, broker.port, timeout=60)
                connection.request(self.command, self.path, body, {'Content-Type': 'application/json'})
                response = connection.getresponse()
                if 300 <= response.status < 400:
                    raise ValueError('Redirect denied')
                # Bound the response before relaying; SSE is supported but buffered.
                payload = response.read(MAX_RESPONSE + 1)
                if len(payload) > MAX_RESPONSE:
                    raise ValueError('Response size exceeded')
                self.send_response(response.status)
                self.send_header('Content-Type', response.getheader('Content-Type', 'application/json'))
                self.send_header('Content-Length', str(len(payload)))
                self.end_headers()
                self.wfile.write(payload)
            except (ValueError, OSError, http.client.HTTPException):
                self.send_error(403, 'Broker request denied or local backend unavailable')
            finally:
                if connection:
                    connection.close()
    return Handler


def start(path, broker):
    if not hasattr(socketserver, 'UnixStreamServer'):
        raise ValueError('Unix broker execution is unavailable on this platform; no TCP fallback')
    server = UnixHTTPServer(str(path), handler(broker))
    os.chmod(path, 0o600)
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    return server
