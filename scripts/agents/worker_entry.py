"""Trusted in-container adapter. No host shell, daemon socket or provider keys."""
import http.client
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os
from pathlib import Path
import socket
import subprocess
import threading

URL = 'http://127.0.0.1:8123'


class UnixConnection(http.client.HTTPConnection):
    def connect(self):
        self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.sock.settimeout(90)
        self.sock.connect('/broker/model.sock')


class Proxy(BaseHTTPRequestHandler):
    def log_message(self, *_args):
        pass

    def do_GET(self):
        self.forward()

    def do_POST(self):
        self.forward()

    def forward(self):
        connection = UnixConnection('localhost')
        try:
            size = int(self.headers.get('Content-Length', '0'))
            if self.headers.get('Transfer-Encoding') or not 0 <= size <= 1024 * 1024:
                raise ValueError('Request denied')
            connection.request(self.command, self.path, self.rfile.read(size), {'Content-Type': 'application/json'})
            response = connection.getresponse()
            payload = response.read(8 * 1024 * 1024 + 1)
            if len(payload) > 8 * 1024 * 1024:
                raise ValueError('Response denied')
            self.send_response(response.status)
            self.send_header('Content-Type', response.getheader('Content-Type', 'application/json'))
            self.send_header('Content-Length', str(len(payload)))
            self.end_headers()
            self.wfile.write(payload)
        except (ValueError, OSError, http.client.HTTPException):
            self.send_error(502, 'Local broker unavailable')
        finally:
            connection.close()


def configurations(agent, model, role, base=URL):
    if agent == 'opencode':
        return {'model': 'ollama/' + model, 'enabled_providers': ['ollama'], 'share': 'disabled',
                'autoupdate': False, 'provider': {'ollama': {'npm': '@ai-sdk/openai-compatible',
                'options': {'baseURL': base + '/v1'}, 'models': {model: {'name': model}}}},
                'permission': {'*': 'deny', 'read': 'allow', 'glob': 'allow', 'grep': 'allow',
                               'edit': 'allow' if role == 'implement' else 'deny'}}
    if agent == 'qwen_code':
        return {'security': {'auth': {'selectedType': 'openai', 'enforcedType': 'openai'}},
                'model': {'name': model}, 'telemetry': {'enabled': False}}
    if agent == 'aider':
        return {'model': 'openai/' + model, 'openai-api-base': base + '/v1',
                'auto-commits': False, 'analytics': False, 'check-update': False}
    if agent == 'codex_cli':
        return ('model_provider = "local_ollama"\nmodel = ' + json.dumps(model) +
                '\napproval_policy = "never"\nsandbox_mode = ' +
                json.dumps('workspace-write' if role == 'implement' else 'read-only') +
                '\n[model_providers.local_ollama]\nname = "Local Ollama"\nbase_url = ' +
                json.dumps(base + '/v1') + '\nwire_api = "responses"\nrequires_openai_auth = false\n')
    return {}


def command(agent, role, model):
    prompt = 'Aufgabe: ' + Path('/policy/prompt.txt').read_text(encoding='utf-8')
    if role == 'test':
        return ['python3', '-B', '-m', 'unittest', 'discover', '-s', 'tests', '-v']
    if agent == 'opencode':
        return ['opencode', 'run', '--model', 'ollama/' + model, prompt]
    if agent == 'qwen_code':
        return ['qwen', '--prompt', prompt]
    if agent == 'aider':
        return ['aider', '--config', '/tmp/agent-config', '--message', prompt,
                '--no-auto-commits', '--no-analytics', '--no-check-update', '--yes-always']
    if agent == 'codex_cli':
        return ['codex', 'exec', '--skip-git-repo-check', prompt]
    if agent == 'openhands':
        return ['python3', '-B', '/runner/openhands_task.py']
    raise ValueError('Unknown adapter')


def main():
    policy = json.loads(Path('/policy/run.json').read_text())
    agent, role, model = policy['agent'], policy['role'], policy['model']
    home = Path('/tmp/home')
    home.mkdir(mode=0o700, exist_ok=True)
    os.environ.update(HOME=str(home), XDG_CONFIG_HOME=str(home / '.config'),
                      OPENAI_BASE_URL=URL + '/v1', OPENAI_API_KEY='local', OPENAI_MODEL=model,
                      OLLAMA_API_BASE=URL, OLLAMA_HOST=URL, OLLAMA_BASE_URL=URL,
                      OTEL_SDK_DISABLED='true', DO_NOT_TRACK='1', PYTHONDONTWRITEBYTECODE='1')
    config = configurations(agent, model, role)
    text = config if isinstance(config, str) else json.dumps(config)
    Path('/tmp/agent-config').write_text(text)
    if agent == 'qwen_code':
        (home / '.qwen').mkdir(mode=0o700)
        (home / '.qwen/settings.json').write_text(text)
    if agent == 'codex_cli':
        (home / '.codex').mkdir(mode=0o700)
        (home / '.codex/config.toml').write_text(text)
        os.environ['CODEX_HOME'] = str(home / '.codex')
    os.environ['OPENCODE_CONFIG'] = '/tmp/agent-config'
    server = ThreadingHTTPServer(('127.0.0.1', 8123), Proxy)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    try:
        descriptor = os.open('/result.txt', os.O_WRONLY | os.O_TRUNC | os.O_NOFOLLOW)
        with os.fdopen(descriptor, 'wb') as transcript:
            return subprocess.run(command(agent, role, model), cwd='/workspace', check=False,
                                  stdout=transcript, stderr=subprocess.STDOUT).returncode
    finally:
        server.shutdown()
        server.server_close()


if __name__ == '__main__':
    raise SystemExit(main())
