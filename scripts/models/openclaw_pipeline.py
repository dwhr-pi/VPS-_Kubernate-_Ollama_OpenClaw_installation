"""Offline routing/export proposals only: no model downloads, subprocesses or config writes."""
import argparse
import json
from pathlib import Path
import re
import sys

MODEL = re.compile(r'[a-z0-9][a-z0-9_.-]*(?::[a-z0-9][a-z0-9_.-]*)?')
QUANTIZATIONS = ('Q4_K_M', 'Q8_0', 'F16', 'MXFP4')


def integer(value, minimum, maximum):
    if type(value) is not int or not minimum <= value <= maximum:
        raise ValueError('Invalid bounded integer.')
    return value


def route(config, installed, task, free_vram_mib, context):
    integer(free_vram_mib, 0, 1048576)
    integer(context, 128, 131072)
    if task not in ('general', 'code', 'finance', 'audio'):
        raise ValueError('Unknown task.')
    if (not isinstance(config, dict) or set(config) != {'version', 'models'}
            or type(config['version']) is not int or config['version'] != 1
            or not isinstance(config['models'], list) or len(config['models']) > 32
            or not isinstance(installed, list) or len(installed) > 1024
            or any(not isinstance(name, str) or not MODEL.fullmatch(name) for name in installed)):
        raise ValueError('Invalid routing schema or installed-model snapshot.')
    seen = set()
    for row in config['models']:
        if not isinstance(row, dict) or set(row) != {
                'model', 'task', 'quantization', 'max_context', 'required_vram_mib',
                'license_reviewed', 'runtime_reviewed'}:
            raise ValueError('Invalid candidate schema.')
        if (not isinstance(row['model'], str) or not MODEL.fullmatch(row['model'])
                or row['model'] in seen or row['task'] not in ('general', 'code', 'finance')
                or row['quantization'] not in QUANTIZATIONS
                or type(row['license_reviewed']) is not bool or type(row['runtime_reviewed']) is not bool):
            raise ValueError('Invalid or duplicate candidate.')
        seen.add(row['model'])
        integer(row['max_context'], 128, 131072)
        integer(row['required_vram_mib'], 1, 1048576)
    result = {'executed': False, 'cloud_fallback': False, 'automatic_download': False,
              'inference_time_seconds': None, 'inventory_scope': 'operator-supplied-offline-snapshot'}
    if task == 'audio':
        return dict(result, status='transcription-required', selected_model=None,
                    reason='Explicitly approved faster-whisper stage required before text routing.')
    for row in config['models']:
        if (row['task'] == task and row['model'] in installed and row['license_reviewed']
                and row['runtime_reviewed'] and context <= row['max_context']
                and row['required_vram_mib'] <= free_vram_mib):
            return dict(result, status='proposal', selected_model=row['model'],
                        quantization=row['quantization'], context_window=context,
                        capacity_scope='reviewed profile; live admission and concurrency still required',
                        ollama_inspect_command=['ollama', 'show', row['model']],
                        inference_options={'num_ctx': context})
    return dict(result, status='blocked', selected_model=None,
                reason='No installed, reviewed, task-compatible candidate fits the supplied capacity.')


def safe_path(value):
    if not isinstance(value, str) or not value or any(ord(c) < 32 for c in value):
        raise ValueError('Invalid local path.')
    return str(Path(value).absolute())


def export_plan(name, source, llama, destination, quantization):
    if not MODEL.fullmatch(name) or quantization not in ('Q4_K_M', 'Q8_0'):
        raise ValueError('Unsupported name or quantization.')
    source, llama, destination = map(safe_path, (source, llama, destination))
    root = Path(destination)
    intermediate, output = root / 'model-f16.gguf', root / ('model-' + quantization + '.gguf')
    return {
        'executed': False, 'scope': 'export-plan-only', 'architecture_support_verified': False,
        'preconditions': ['reviewed pinned llama.cpp checkout and native quantizer',
                          'compatible merged local HF architecture, tokenizer and model license',
                          'new isolated destination; enough disk for both GGUF files and Ollama copy',
                          'inspect pinned converter and quantizer --help before separate approval'],
        'conversion_argv': [sys.executable, str(Path(llama) / 'convert_hf_to_gguf.py'), source,
                            '--outfile', str(intermediate), '--outtype', 'f16'],
        'quantization_argv': [str(Path(llama) / 'build/bin/llama-quantize'),
                              str(intermediate), str(output), quantization],
        'modelfile_proposal': 'FROM ' + json.dumps(output.as_posix()) +
                              '\nPARAMETER temperature 0.2\nPARAMETER num_ctx 4096\n',
        'registration_argv': ['ollama', 'create', name, '-f', str(root / 'Modelfile')],
        'registration_requires_separate_approval': True,
        'benchmark_requires_separate_approval': True,
        'openclaw_model_reference_proposal': 'ollama/' + name,
        'active_config_modified': False,
    }


def read_json(path):
    path = Path(path).absolute()
    for item in (path, *path.parents):
        if item.is_symlink() or (hasattr(item, 'is_junction') and item.is_junction()):
            raise ValueError('Linked input rejected.')
    if not path.is_file() or path.stat().st_size > 65536:
        raise ValueError('Input must be a bounded regular file.')
    with path.open('rb') as stream:
        data = stream.read(65537)
    if len(data) > 65536:
        raise ValueError('Input exceeds limit.')
    def unique(pairs):
        result = {}
        for key, value in pairs:
            if key in result:
                raise ValueError('Duplicate JSON key.')
            result[key] = value
        return result
    return json.loads(data, object_pairs_hook=unique)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='action', required=True)
    routing = sub.add_parser('route-plan')
    routing.add_argument('--config', required=True)
    routing.add_argument('--installed', required=True)
    routing.add_argument('--task', choices=('general', 'code', 'finance', 'audio'), required=True)
    routing.add_argument('--free-vram-mib', type=int, required=True)
    routing.add_argument('--context', type=int, default=4096)
    export = sub.add_parser('export-plan')
    export.add_argument('--name', required=True)
    export.add_argument('--source', required=True)
    export.add_argument('--llama-cpp', required=True)
    export.add_argument('--destination', required=True)
    export.add_argument('--quantization', choices=('Q4_K_M', 'Q8_0'), default='Q4_K_M')
    args = parser.parse_args(argv)
    try:
        if args.action == 'route-plan':
            result = route(read_json(args.config), read_json(args.installed), args.task,
                           args.free_vram_mib, args.context)
        else:
            result = export_plan(args.name, args.source, args.llama_cpp, args.destination, args.quantization)
        print(json.dumps(result, ensure_ascii=True, indent=2))
        return 3 if result.get('status') in ('blocked', 'transcription-required') else 0
    except (OSError, ValueError, TypeError, KeyError, RecursionError):
        print('Plan rejected; no model, network or configuration operation performed.', file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
