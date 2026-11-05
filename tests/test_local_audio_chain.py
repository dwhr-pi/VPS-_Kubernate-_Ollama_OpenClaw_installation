"""Audio source lifecycle, pure planner and stdio fixtures; no audio inference."""
import copy
import importlib.util
import io
import json
from pathlib import Path
import socket
import subprocess
import tempfile
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]


def load(name, filename):
    spec = importlib.util.spec_from_file_location(name, ROOT / 'scripts/audio' / filename)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


pipeline = load('audio_fixture', 'audio_pipeline.py')
mcp = load('audio_mcp_fixture', 'mcp_audio_server.py')
song = load('full_song_fixture', 'run_full_song.py')


class LocalAudioChain(unittest.TestCase):
    def setUp(self):
        self.project = json.loads((ROOT / 'config/audio_project.example.json').read_text(encoding='utf-8'))

    def test_all_six_existing_tools_are_unique_and_have_lifecycle_docs(self):
        tools = json.loads((ROOT / 'config/tools.yml').read_text(encoding='utf-8'))['tools']
        for key in pipeline.TOOLS:
            entries = [t for t in tools if t['id'] == key]
            self.assertEqual(len(entries), 1, key)
            entry = entries[0]
            self.assertFalse(entry['auto_install'])
            self.assertEqual(entry['doc'], 'docs/tools/local-audio-chain.md')
            for action in ('install', 'update', 'uninstall', 'doctor', 'status'):
                self.assertNotIn('planned_tool_stub', entry[action + '_script'])
                self.assertTrue((ROOT / entry[action + '_script']).is_file())

    def test_new_source_recipes_are_exact_and_never_claim_runtime(self):
        recipes = json.loads((ROOT / 'scripts/tools/helpers/gap_tools.json').read_text(encoding='utf-8'))
        for key in ('openutau', 'diffsinger', 'seed_vc'):
            spec = recipes[key]
            self.assertEqual(spec['mode'], 'source')
            self.assertRegex(spec['pin'], r'^[a-f0-9]{40}$')
            self.assertGreaterEqual(spec['reserve_mb'], 2048)
            for action in ('install', 'update', 'uninstall', 'doctor', 'status', 'check'):
                text = (ROOT / f'scripts/tools/{key}_{action}.sh').read_text(encoding='utf-8')
                self.assertIn(f'gap_tools.py" {key} {action} "$@"', text)
                self.assertNotIn('pip install', text)
        self.assertEqual(recipes['openutau']['repo'], 'openutau/OpenUtau')

    def test_ffmpeg_uses_private_pinned_build_without_legacy_deletion(self):
        specs = json.loads((ROOT / 'config/docker_to_github.json').read_text(encoding='utf-8'))['tools']
        recipe = next(t['recipe'] for t in specs if t['id'] == 'ffmpeg')
        self.assertRegex(recipe['pin'], r'^[a-f0-9]{40}$')
        self.assertEqual(recipe['artifacts'], ['app/bin/ffmpeg', 'app/bin/ffprobe'])
        self.assertIn('--disable-network', recipe['steps'][0]['args'])
        self.assertIn('--prefix={prefix}/app', recipe['steps'][0]['args'])
        self.assertEqual(recipe['steps'][1]['args'], ['make', '-j2'])
        for action in ('install', 'uninstall'):
            text = (ROOT / f'scripts/tools/ffmpeg_{action}.sh').read_text(encoding='utf-8')
            self.assertIn('native_github_tools.py', text)
            for forbidden in ('sudo ', 'rm -rf', 'apt', 'ln -s', '|| true'):
                self.assertNotIn(forbidden, text)

    def test_planning_is_deterministic_and_cannot_launch_or_write(self):
        with mock.patch.object(subprocess, 'run', side_effect=AssertionError('process')), \
                mock.patch.object(socket, 'socket', side_effect=AssertionError('network')), \
                mock.patch.object(Path, 'mkdir', side_effect=AssertionError('write')):
            first = pipeline.plan(self.project)
            second = pipeline.plan(self.project)
        self.assertEqual(first, second)
        self.assertFalse(first['executed'])
        self.assertFalse(first['execution_available'])
        self.assertEqual(first['max_parallel_jobs'], 1)
        self.assertIn('-n', first['ffmpeg_preview'])
        self.assertNotIn('-y', first['ffmpeg_preview'])

    def test_invalid_paths_commands_lyrics_and_values_are_rejected(self):
        changes = ({'name': '../escape'}, {'name': 'x;false'}, {'tempo': True}, {'tempo': float('nan')},
                   {'tempo': 0}, {'command': 'false'}, {'voice_engine': 'shell'}, {'rights_confirmed': 'yes'},
                   {'notes': []}, {'notes': [{'midi': True, 'length': 480, 'lyric': 'a'}]},
                   {'notes': [{'midi': 60, 'length': 0, 'lyric': 'a'}]},
                   {'notes': [{'midi': 60, 'length': 480, 'lyric': 'a\n[#SETTING]'}]})
        for change in changes:
            with self.subTest(change=change), self.assertRaises(ValueError):
                pipeline.plan(dict(self.project, **change))

    def test_note_and_duration_limits(self):
        for notes in ([self.project['notes'][0]] * 2049,
                      [dict(midi=60, length=7680, lyric='a')] * 300):
            with self.assertRaises(ValueError):
                pipeline.plan(dict(self.project, notes=notes))

    def test_conversion_and_stems_are_only_blocked_plan_stages(self):
        result = pipeline.plan(dict(self.project, voice_engine='seed_vc', split_stems=True, rights_confirmed=True))
        self.assertEqual([s['tool'] for s in result['stages']], ['openutau', 'diffsinger', 'seed_vc', 'uvr5', 'ffmpeg'])
        self.assertFalse(result['execution_available'])
        self.assertEqual(result['stages'][2]['state'], 'blocked-runtime-unverified')

    def test_mcp_initialize_list_and_call_are_read_only(self):
        server = mcp.Server()
        self.assertIn('error', server.handle(dict(jsonrpc='2.0', id=1, method='tools/list')))
        initialized = server.handle(dict(jsonrpc='2.0', id=2, method='initialize', params={'protocolVersion': '2025-06-18'}))
        self.assertEqual(initialized['result']['protocolVersion'], '2025-06-18')
        tool = server.handle(dict(jsonrpc='2.0', id=3, method='tools/list'))['result']['tools']
        self.assertEqual([t['name'] for t in tool], ['plan_audio_project'])
        self.assertTrue(tool[0]['annotations']['readOnlyHint'])
        request = dict(jsonrpc='2.0', id=4, method='tools/call',
                       params=dict(name='plan_audio_project', arguments=dict(project=self.project)))
        result = server.handle(request)['result']
        self.assertFalse(result['isError'])
        self.assertFalse(json.loads(result['content'][0]['text'])['executed'])
        for name in ('generate_diffsinger_vocals', 'convert_voice_timbre', 'split_stems_uvr5', 'mix_and_master_ffmpeg'):
            bad = copy.deepcopy(request)
            bad['params']['name'] = name
            self.assertIn('error', server.handle(bad))

    def test_stdio_has_only_jsonrpc_and_bounded_input(self):
        messages = [dict(jsonrpc='2.0', id=1, method='initialize', params={}),
                    dict(jsonrpc='2.0', method='notifications/initialized'),
                    dict(jsonrpc='2.0', id=2, method='tools/list')]
        source = io.BytesIO(('\n'.join(json.dumps(m) for m in messages) + '\n').encode())
        target = io.StringIO()
        self.assertEqual(mcp.serve(source, target), 0)
        output = [json.loads(line) for line in target.getvalue().splitlines()]
        self.assertEqual([m['id'] for m in output], [1, 2])
        self.assertEqual(mcp.serve(io.BytesIO(b'x' * (pipeline.MAX_BYTES + 1)), io.StringIO()), 2)

    def test_preset_fans_out_vocals_before_sidechain_and_echo(self):
        result = pipeline.plan(dict(self.project, mix_profile='vocal_ducking_echo'))
        graph = result['ffmpeg_preview'][result['ffmpeg_preview'].index('-filter_complex') + 1]
        self.assertIn('asplit=2[v_mix][v_sc]', graph)
        self.assertIn('[1:a][v_sc]sidechaincompress=', graph)
        self.assertIn('[v_mix]aecho=', graph)
        self.assertIn('[v_wet][i_ducked]amix=', graph)
        with self.assertRaises(ValueError):
            pipeline.plan(dict(self.project, mix_profile='movie=/etc/private'))

    def test_export_is_unique_private_and_never_claims_audio_success(self):
        result = pipeline.plan(self.project)
        with tempfile.TemporaryDirectory() as directory:
            Path(directory).chmod(0o700)
            first = song.export_report(result, directory, True, result['plan_sha256'])
            second = song.export_report(result, directory, True, result['plan_sha256'])
            self.assertNotEqual(first, second)
            report = json.loads(first.read_text(encoding='utf-8'))
            self.assertEqual(report['status'], 'planned')
            self.assertFalse(report['executed'])
            self.assertFalse(report['audio_generated'])
            self.assertEqual(report['artifacts'], [])
            self.assertIn('+00:00', report['timestamp_utc'])

    def test_export_without_confirmation_and_collision_preserve_files(self):
        result = pipeline.plan(self.project)
        with tempfile.TemporaryDirectory() as directory:
            Path(directory).chmod(0o700)
            for apply, confirm in ((False, result['plan_sha256']), (True, None), (True, 'other')):
                with self.assertRaises(ValueError):
                    song.export_report(result, directory, apply, confirm)
            self.assertEqual(list(Path(directory).iterdir()), [])
            with mock.patch.object(song.os, 'link', side_effect=FileExistsError('fixture collision')):
                with self.assertRaises(FileExistsError):
                    song.export_report(result, directory, True, result['plan_sha256'])
            self.assertEqual(list(Path(directory).iterdir()), [])

    def test_execute_fails_before_reading_project_or_writing_metadata(self):
        with mock.patch.object(Path, 'open', side_effect=AssertionError('file read')):
            with self.assertRaisesRegex(ValueError, 'Ausfuehrung gesperrt'):
                song.main(['absent.json', '--execute'])


if __name__ == '__main__':
    unittest.main()
