"""Offline converter for basic line-timed LRC/SRT. No audio recognition or word alignment."""
import argparse
import json
import os
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[2]


def time_ms(value):
    match = re.fullmatch(r'(?:(\d+):)?(\d{1,}):(\d{2})[.,](\d{1,3})', value)
    if not match:
        raise ValueError('Invalid timestamp')
    hours, minutes, seconds, fraction = match.groups()
    if int(seconds) >= 60 or (hours is not None and int(minutes) >= 60):
        raise ValueError('Invalid timestamp range')
    return ((int(hours or 0) * 60 + int(minutes)) * 60 + int(seconds)) * 1000 + int(fraction.ljust(3, '0'))


def parse_srt(text):
    cues = []
    for block in re.split(r'\n\s*\n', text.strip().replace('\r\n', '\n')):
        lines = block.splitlines()
        if len(lines) < 3 or not lines[0].isdigit():
            raise ValueError('Unsupported SRT block')
        pair = re.fullmatch(r'(\d+:\d{2}:\d{2},\d{3}) --> (\d+:\d{2}:\d{2},\d{3})', lines[1])
        if not pair:
            raise ValueError('Unsupported SRT timing')
        start, end = map(time_ms, pair.groups())
        content = '\n'.join(lines[2:]).strip()
        if not content or start >= end or (cues and start <= cues[-1][0]):
            raise ValueError('Invalid SRT cue ordering')
        if cues and start < cues[-1][1]:
            raise ValueError('Overlapping SRT cannot be represented by this basic LRC converter')
        cues.append((start, end, content))
    if not cues:
        raise ValueError('Empty captions')
    return cues


def parse_lrc(text):
    cues = []
    for line in text.splitlines():
        if not line.strip():
            continue
        if re.fullmatch(r'\[(ar|al|ti|by|re|ve):[^\]]*\]', line):
            continue
        if line == '[offset:0]':
            continue
        match = re.fullmatch(r'\[(\d+:\d{2}\.\d{1,3})\](.+)', line)
        if not match or re.search(r'<\d+:\d', line) or re.search(r'\[\d+:\d', match[2]):
            raise ValueError('Only one basic line timestamp supported; no Enhanced LRC/offset')
        start = time_ms(match[1])
        content = match[2].strip()
        if not content or (cues and start <= cues[-1][0]):
            raise ValueError('Invalid LRC ordering')
        cues.append((start, content))
    if not cues:
        raise ValueError('Empty lyrics')
    return cues


def stamp(ms, srt=False):
    seconds, fraction = divmod(ms, 1000)
    minutes, second = divmod(seconds, 60)
    if srt:
        hours, minute = divmod(minutes, 60)
        return f'{hours:02}:{minute:02}:{second:02},{fraction:03}'
    return f'{minutes:02}:{second:02}.{fraction:03}'


def convert(text, source, target, last_end=None):
    if source == target:
        raise ValueError('Different target required')
    if source == 'srt' and target == 'lrc':
        return ''.join(f'[{stamp(start)}]{" ".join(content.splitlines())}\n'
                       for start, _, content in parse_srt(text))
    if source == 'lrc' and target == 'srt':
        cues = parse_lrc(text)
        if last_end is None:
            raise ValueError('Explicit final end time required')
        end = time_ms(last_end)
        if end <= cues[-1][0]:
            raise ValueError('Final end before last cue')
        result = []
        for index, (start, content) in enumerate(cues):
            stop = cues[index + 1][0] if index + 1 < len(cues) else end
            result.append(f'{index + 1}\n{stamp(start, True)} --> {stamp(stop, True)}\n{content}\n\n')
        return ''.join(result)
    raise ValueError('Unsupported format')


def read_text(path):
    path = Path(path)
    if path.is_symlink() or not path.is_file():
        raise ValueError('Invalid input file')
    with path.open('rb') as stream:
        content = stream.read(2 * 1024 * 1024 + 1)
    if len(content) > 2 * 1024 * 1024:
        raise ValueError('Input too large')
    return content.decode('utf-8-sig')


def write_private(path, content):
    path = Path(path).expanduser()
    if not path.is_absolute() or path.is_symlink():
        raise ValueError('Explicit absolute output required')
    resolved = path.resolve()
    if resolved.is_relative_to(ROOT):
        raise ValueError('Exports must stay outside repository')
    fd = os.open(resolved, os.O_WRONLY | os.O_CREAT | os.O_EXCL | getattr(os, 'O_NOFOLLOW', 0), 0o600)
    with os.fdopen(fd, 'w', encoding='utf-8', newline='\n') as stream:
        stream.write(content)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('mode', choices=('plan', 'doctor', 'status', 'check', 'convert', 'install', 'update', 'uninstall'))
    parser.add_argument('--from', dest='source', choices=('srt', 'lrc'))
    parser.add_argument('--to', dest='target', choices=('srt', 'lrc'))
    parser.add_argument('--input')
    parser.add_argument('--output')
    parser.add_argument('--last-end')
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args(argv)
    if args.mode in ('install', 'update', 'uninstall'):
        print('Repository-CLI: keine Paketinstallation oder Datenloeschung. Dokumentation lesen.', file=sys.stderr)
        return 2
    try:
        if args.mode == 'convert' and args.apply:
            if not all((args.source, args.target, args.input, args.output)):
                raise ValueError('Required arguments missing')
            result = convert(read_text(args.input), args.source, args.target, args.last_end)
            write_private(args.output, result)
            print('Export geschrieben. Nur Zeilentiming, keine Wortausrichtung. Metadaten/Endzeiten koennen verloren gehen.')
        elif args.mode == 'check' and args.input:
            if not args.source:
                raise ValueError('Source format required')
            cues = (parse_srt if args.source == 'srt' else parse_lrc)(read_text(args.input))
            print(json.dumps({'valid': True, 'cues': len(cues), 'word_alignment_verified': False}))
        else:
            print(json.dumps({'mode': 'plan', 'written': False, 'network': False,
                              'scope': 'basic_lrc_srt_only', 'apply_required': True}))
        return 0
    except (OSError, ValueError, TypeError):
        print('Abgebrochen: Format, Zeitfolge, letzten Endzeitpunkt und neues externes Ausgabeziel pruefen. Keine Textinhalte ausgegeben.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
