"""Experimental stdio MCP facade exposing only the pure audio planner."""
import importlib.util
import json
from pathlib import Path
import sys

SPEC = importlib.util.spec_from_file_location('audio_plan', Path(__file__).with_name('audio_pipeline.py'))
pipeline = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(pipeline)
VERSIONS = ('2025-06-18', '2025-03-26', '2024-11-05')
SCHEMA = {'type': 'object', 'properties': {
    'project': {'type': 'object', 'properties': {
        'name': {'type': 'string', 'pattern': '^[A-Za-z0-9_-]{1,64}$'},
        'tempo': {'type': 'number', 'minimum': 30, 'maximum': 300},
        'voice_engine': {'type': 'string', 'enum': ['none', 'rvc', 'seed_vc']},
        'split_stems': {'type': 'boolean'}, 'rights_confirmed': {'type': 'boolean'},
        'mix_profile': {'type': 'string', 'enum': list(pipeline.MIX_PROFILES)},
        'notes': {'type': 'array', 'minItems': 1, 'maxItems': 2048, 'items': {
            'type': 'object', 'properties': {'midi': {'type': 'integer', 'minimum': 0, 'maximum': 127},
                'length': {'type': 'integer', 'minimum': 1, 'maximum': 7680},
                'lyric': {'type': 'string', 'minLength': 1, 'maxLength': 128}},
            'required': ['midi', 'length', 'lyric'], 'additionalProperties': False}}},
        'required': ['name', 'notes'], 'additionalProperties': False}},
    'required': ['project'], 'additionalProperties': False}


class Server:
    def __init__(self):
        self.initialized = False

    def handle(self, request):
        ident = request.get('id') if isinstance(request, dict) else None
        if not isinstance(request, dict) or request.get('jsonrpc') != '2.0' or not isinstance(request.get('method'), str):
            return self.error(ident, -32600, 'Invalid request')
        method = request['method']
        if 'id' not in request:
            return None
        if type(ident) not in (str, int):
            return self.error(None, -32600, 'Invalid request id')
        params = request.get('params', {})
        if not isinstance(params, dict):
            return self.error(ident, -32602, 'Invalid params')
        if method == 'initialize':
            self.initialized = True
            version = params.get('protocolVersion')
            value = dict(protocolVersion=version if version in VERSIONS else VERSIONS[0],
                         capabilities={'tools': {}}, serverInfo={'name': 'local-audio-plan-only', 'version': '0.1.0'})
        elif method == 'ping':
            value = {}
        elif not self.initialized:
            return self.error(ident, -32000, 'Initialize first')
        elif method == 'tools/list':
            value = {'tools': [dict(name='plan_audio_project',
                description='Read-only plan; never installs, renders, reads paths, writes files or downloads models.',
                inputSchema=SCHEMA, annotations=dict(readOnlyHint=True, destructiveHint=False,
                                                     idempotentHint=True, openWorldHint=False))]}
        elif method == 'tools/call':
            arguments = params.get('arguments', {})
            if params.get('name') != 'plan_audio_project' or not isinstance(arguments, dict) or set(arguments) != {'project'}:
                return self.error(ident, -32602, 'Unknown tool or arguments')
            try:
                result = pipeline.plan(arguments['project'])
                value = dict(content=[dict(type='text', text=json.dumps(result, ensure_ascii=True))], isError=False)
            except (ValueError, TypeError):
                value = dict(content=[dict(type='text', text='Invalid audio project; no action executed')], isError=True)
        else:
            return self.error(ident, -32601, 'Method not found')
        return dict(jsonrpc='2.0', id=ident, result=value)

    @staticmethod
    def error(ident, code, message):
        return dict(jsonrpc='2.0', id=ident, error=dict(code=code, message=message))


def serve(source, target):
    server = Server()
    while True:
        line = source.readline(pipeline.MAX_BYTES + 1)
        if not line:
            return 0
        if len(line) > pipeline.MAX_BYTES:
            return 2  # Do not buffer or log an unbounded request.
        try:
            reply = server.handle(json.loads(line))
        except (ValueError, UnicodeError, RecursionError):
            reply = server.error(None, -32700, 'Parse error')
        if reply is not None:
            target.write(json.dumps(reply, ensure_ascii=True) + '\n')
            target.flush()


if __name__ == '__main__':
    try:
        sys.exit(serve(sys.stdin.buffer, sys.stdout))
    except (BrokenPipeError, KeyboardInterrupt):
        sys.exit(0)
