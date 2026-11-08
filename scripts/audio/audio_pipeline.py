"""Read-only local singing workflow planner; never invokes a model or shell."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import re
import sys

MAX_BYTES = 65536
TOOLS = ('openutau', 'diffsinger', 'rvc', 'seed_vc', 'uvr5', 'ffmpeg')
MIX_PROFILES = {
    'dry': '[0:a][1:a]amix=inputs=2:duration=longest[mix];',
    'vocal_ducking_echo': (
        '[0:a]highpass=f=90,equalizer=f=1500:t=q:w=1.5:g=-2.5,'
        'acompressor=threshold=0.158489:ratio=3:attack=5:release=50,asplit=2[v_mix][v_sc];'
        '[1:a][v_sc]sidechaincompress=threshold=0.125:ratio=4:attack=5:release=100[i_ducked];'
        '[v_mix]aecho=0.8:0.88:60|120:0.4|0.3[v_wet];'
        '[v_wet][i_ducked]amix=inputs=2:duration=longest[mix];')}


def validate(project):
    allowed = {'name', 'tempo', 'notes', 'voice_engine', 'split_stems', 'rights_confirmed', 'mix_profile'}
    if not isinstance(project, dict) or set(project) - allowed:
        raise ValueError('Projekt muss ein Objekt mit bekannten Feldern sein')
    if not re.fullmatch(r'[A-Za-z0-9_-]{1,64}', project.get('name', '')):
        raise ValueError('Projektname muss ein einfacher Bezeichner sein')
    tempo = project.get('tempo', 120)
    if type(tempo) not in (int, float) or not math.isfinite(tempo) or not 30 <= tempo <= 300:
        raise ValueError('Tempo ausserhalb 30 bis 300 BPM')
    notes = project.get('notes')
    if not isinstance(notes, list) or not 1 <= len(notes) <= 2048:
        raise ValueError('Erforderlich: 1 bis 2048 Noten')
    normalized = []
    for note in notes:
        if not isinstance(note, dict) or set(note) != {'midi', 'length', 'lyric'}:
            raise ValueError('Note braucht genau midi, length und lyric')
        if type(note['midi']) is not int or not 0 <= note['midi'] <= 127:
            raise ValueError('Ungueltige MIDI-Note')
        if type(note['length']) is not int or not 1 <= note['length'] <= 7680:
            raise ValueError('Ungueltige Laenge in 480-PPQ-Ticks')
        lyric = note['lyric']
        if not isinstance(lyric, str) or not 1 <= len(lyric) <= 128 or any(ord(c) < 32 or c in '[]' for c in lyric):
            raise ValueError('Ungueltige Silbe oder Steuerzeichen')
        normalized.append(dict(midi=note['midi'], length=note['length'], lyric=lyric))
    duration = sum(n['length'] for n in normalized) / 480 * 60 / tempo
    if duration > 600:
        raise ValueError('Maximal zehn Minuten pro Entwurf')
    voice = project.get('voice_engine', 'none')
    if voice not in ('none', 'rvc', 'seed_vc'):
        raise ValueError('voice_engine muss none, rvc oder seed_vc sein')
    for name in ('split_stems', 'rights_confirmed'):
        if name in project and type(project[name]) is not bool:
            raise ValueError('Freigabefelder muessen boolesch sein')
    profile = project.get('mix_profile', 'dry')
    if not isinstance(profile, str) or profile not in MIX_PROFILES:
        raise ValueError('Unbekanntes Mix-Preset; keine frei eingegebenen Filter')
    return dict(name=project['name'], tempo=tempo, notes=normalized, voice_engine=voice,
                split_stems=project.get('split_stems', False), rights_confirmed=project.get('rights_confirmed', False),
                mix_profile=profile)


def plan(project):
    project = validate(project)
    digest = hashlib.sha256(json.dumps(project, sort_keys=True, ensure_ascii=True).encode()).hexdigest()
    stages = [dict(id='arrange', tool='openutau', state='manual-project-handoff',
                   requires=['reviewed-project-format', 'voicebank-license']),
              dict(id='sing', tool='diffsinger', state='blocked-runtime-unverified',
                   requires=['reviewed-runtime', 'licensed-local-model', 'phonemes-and-alignment'])]
    if project['voice_engine'] != 'none':
        stages.append(dict(id='timbre', tool=project['voice_engine'], state='blocked-runtime-unverified',
                           requires=['speaker-consent', 'licensed-local-model', 'reviewed-runtime']))
    if project['split_stems']:
        stages.append(dict(id='stems', tool='uvr5', state='blocked-runtime-unverified',
                           requires=['source-recording-rights', 'licensed-separation-model', 'reviewed-runtime']))
    stages.append(dict(id='mix-export', tool='ffmpeg', state='plan-only',
                       requires=['reviewed-binary', 'approved-input-stems', 'bounded-worker', 'human-approval']))
    return dict(executed=False, execution_available=False, plan_sha256=digest, project=project,
                stages=stages, max_parallel_jobs=1, preview_max_seconds=600,
                planned_outputs=['vocals_raw.wav'] +
                                (['vocals_converted.wav'] if project['voice_engine'] != 'none' else []) + ['master.flac'],
                blockers=['No verified singing/voice runtime adapters', 'No licensed models selected',
                          'No renderer or write-capable MCP tool enabled'],
                ffmpeg_preview=['ffmpeg', '-nostdin', '-n', '-threads', '2', '-i', 'vocals.wav',
                                '-i', 'instrumental.wav', '-filter_complex_threads', '1',
                                '-filter_complex', MIX_PROFILES[project['mix_profile']] +
                                '[mix]loudnorm=I=-16:LRA=11:TP=-1.5:print_format=json[out]',
                                '-map', '[out]', '-c:a', 'flac', 'master.flac'],
                loudness_note='-16 LUFS is a project target, not the -23 LUFS EBU R128 programme target; '
                              'production export needs measured two-pass loudness and true-peak verification')


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('project', type=Path)
    args = parser.parse_args(argv)
    path = args.project
    if path.is_symlink() or (hasattr(path, 'is_junction') and path.is_junction()) or not path.is_file():
        raise ValueError('Regulaere Projekt-JSON erforderlich')
    with path.open('rb') as stream:
        payload = stream.read(MAX_BYTES + 1)
    if len(payload) > MAX_BYTES:
        raise ValueError('Projekt-JSON zu gross')
    print(json.dumps(plan(json.loads(payload)), ensure_ascii=True, indent=2))
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (ValueError, OSError, TypeError, RecursionError):
        print('Audio-Plan abgelehnt; Schema, Groesse und lokalen Dateipfad pruefen. Keine Aktion ausgefuehrt.', file=sys.stderr)
        sys.exit(2)
