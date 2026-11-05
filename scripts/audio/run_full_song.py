"""Review the full song plan and optionally export metadata; no simulated success."""
import argparse
from datetime import datetime, timezone
import importlib.util
import json
import os
from pathlib import Path
import stat
import sys
import tempfile
import uuid

SPEC = importlib.util.spec_from_file_location('song_plan', Path(__file__).with_name('audio_pipeline.py'))
pipeline = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(pipeline)
ROOT = Path(__file__).resolve().parents[2]


def export_report(result, directory, apply=False, confirm=None):
    if not apply or confirm != result['plan_sha256']:
        raise ValueError('Metadatenexport braucht --apply und den exakten --confirm Plan-Hash')
    path = Path(directory)
    if not path.is_absolute() or not path.is_dir() or path == Path(path.anchor):
        raise ValueError('Vorhandener privater absoluter Ausgabeordner erforderlich')
    for part in (path, *path.parents):
        if part.is_symlink() or (hasattr(part, 'is_junction') and part.is_junction()):
            raise ValueError('Verlinkter Ausgabepfad')
    if path.resolve().is_relative_to(ROOT):
        raise ValueError('Berichte bleiben ausserhalb des Repositorys')
    info = path.stat()
    if os.name != 'nt' and (info.st_uid != os.getuid() or stat.S_IMODE(info.st_mode) & 0o077):
        raise ValueError('Privater eigener Ordner mit Modus 0700 erforderlich')
    now = datetime.now(timezone.utc)
    report_id = now.strftime('%Y%m%dT%H%M%S%fZ') + '-' + uuid.uuid4().hex
    # Metadata records planning, not a fabricated audio export or model execution.
    report = dict(schema=1, report_id=report_id, timestamp_utc=now.isoformat(), status='planned',
                  executed=False, audio_generated=False, artifacts=[], model_hashes={}, runtime_versions={},
                  plan=result, limits=dict(note_preview_seconds=600, planned_parallel_jobs=1),
                  provenance='local-audio-plan-only; no renderer/model run or quality acceptance')
    target = path / ('audio_plan_' + report_id + '.json')
    temporary = None
    try:
        with tempfile.NamedTemporaryFile('w', dir=path, encoding='utf-8', newline='\n', delete=False) as stream:
            temporary = Path(stream.name)
            json.dump(report, stream, ensure_ascii=True, indent=2)
            stream.write('\n')
            stream.flush()
            os.fsync(stream.fileno())
        # Exclusive atomic publication: timestamps alone do not prevent overwrites.
        os.link(temporary, target)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)
    return target


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('project', type=Path)
    parser.add_argument('--execute', action='store_true')
    parser.add_argument('--export-report', type=Path)
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--confirm')
    args = parser.parse_args(argv)
    if args.execute:
        raise ValueError('Ausfuehrung gesperrt: Renderer, lokale lizenzierte Modelle und Worker noch nicht abgenommen')
    if args.project.is_symlink() or not args.project.is_file():
        raise ValueError('Regulaere Projekt-JSON erforderlich')
    with args.project.open('rb') as stream:
        data = stream.read(pipeline.MAX_BYTES + 1)
    if len(data) > pipeline.MAX_BYTES:
        raise ValueError('Projekt zu gross')
    result = pipeline.plan(json.loads(data))
    if args.export_report:
        result['metadata_report'] = export_report(dict(result), args.export_report, args.apply, args.confirm).name
    elif args.apply or args.confirm:
        raise ValueError('Schreibfreigabe ist nur fuer --export-report zulaessig')
    print(json.dumps(result, ensure_ascii=True, indent=2))
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (ValueError, OSError, TypeError, RecursionError):
        print('Song-Workflow gestoppt: Plan-/Pfad-/Freigabegrenzen oder fehlende Runtime-Abnahme. '
              'Kein Audio erzeugt; kein Dummy-Erfolg.', file=sys.stderr)
        sys.exit(2)
