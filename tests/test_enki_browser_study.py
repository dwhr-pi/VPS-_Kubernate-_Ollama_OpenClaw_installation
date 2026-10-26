"""Offline Enki source/packaging fixtures; no binary downloads or browser execution."""
from contextlib import redirect_stdout
import io
import json
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / 'scripts/tools/helpers'))
import enki_browser_study as study


class EnkiStudyTests(unittest.TestCase):
    def test_plans_and_absent_status_do_not_touch_disk_or_network(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': directory}), patch.object(study.common, 'git') as git, patch.object(study.process, 'run') as run:
            with redirect_stdout(io.StringIO()) as output:
                self.assertEqual(study.main(['install', '--build-browser', '--dry-run']), 0)
                self.assertEqual(study.main(['status']), 0)
            self.assertIn('Studienzwecke und Weiterentwicklung', output.getvalue())
            self.assertIn('"chromium_source_build": false', output.getvalue())
            self.assertEqual(list(Path(directory).iterdir()), [])
            git.assert_not_called()
            run.assert_not_called()

    def test_binary_consent_precedes_all_downloads(self):
        with patch.object(study.common, 'reserve') as reserve:
            with self.assertRaisesRegex(ValueError, 'accept-pinned-binaries'):
                study.preflight(Path('/fixture'), False)
            reserve.assert_not_called()

    def test_packaging_build_keeps_sources_and_does_not_start_browser(self):
        for system in ('Linux', 'Windows'):
            with self.subTest(system=system), tempfile.TemporaryDirectory() as directory:
                base = Path(directory)
                runtime = base / 'runtime'
                (runtime / 'extension').mkdir(parents=True)
                (runtime / 'package.json').write_text(json.dumps({'version': '0.8.11'}))
                original = runtime / 'study-notes.txt'
                original.write_text('fixture original')
                calls = []
                def run(args, cwd, env, **kwargs):
                    calls.append(list(map(str, args)))
                    self.assertNotIn('OPENAI_API_KEY', env)
                    self.assertNotIn('ENKI_SIGN_COMMAND', env)
                    self.assertIn('ENKI_DIST', env)
                    if args[0] == 'node':
                        target = base / study.artifact_name('0.8.11', system)
                        target.parent.mkdir(parents=True)
                        target.write_bytes(b'fixture package')
                    return ''
                with patch.dict(os.environ, {'OPENAI_API_KEY': 'fixture', 'ENKI_SIGN_COMMAND': 'must-not-run'}), patch.object(study.common, 'validate'), patch.object(study, 'validate_inputs'), patch.object(study, 'preflight', return_value=(system, 'node', ['npm'])), patch.object(study.process, 'run', side_effect=run):
                    study.build(base, runtime, base / 'ready.json', True)
                self.assertEqual(original.read_text(), 'fixture original')
                self.assertFalse((runtime / 'out').exists())
                self.assertEqual(calls[0], ['npm', 'ci', '--ignore-scripts', '--no-audit', '--no-fund'])
                self.assertEqual(calls[2], ['npm', 'run', 'build'])
                self.assertEqual(calls[-1], ['node', 'build/build.mjs' if system == 'Windows' else 'build/build-linux.mjs'])
                self.assertTrue(study.build_status(base))
                record = json.loads((base / 'package-build.json').read_text())
                self.assertFalse(record['application_tested'])
                self.assertEqual(record['scope'], 'source-extension-plus-pinned-binary-packaging')

    def test_upstream_hash_and_host_contract(self):
        with tempfile.TemporaryDirectory() as directory:
            runtime = Path(directory)
            record = {'url': 'https://github.com/owner/repo/releases/download/v1/file.zip', 'sha256': 'a' * 64}
            data = {'chromiumLinux': record, 'blocker': record}
            (runtime / 'upstream.json').write_text(json.dumps(data))
            study.validate_inputs(runtime, 'Linux')
            for invalid in ('http://github.com/owner/repo/releases/download/v1/file.zip',
                            'https://evil.example/owner/repo/releases/download/v1/file.zip'):
                (runtime / 'upstream.json').write_text(json.dumps({**data, 'blocker': {**record, 'url': invalid}}))
                with self.assertRaisesRegex(ValueError, 'GitHub-/SHA256'):
                    study.validate_inputs(runtime, 'Linux')

    def test_artifact_paths_cannot_escape(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            (base / 'package-build.json').write_text(json.dumps({'platform': 'Linux', 'version': '0.8.11', 'artifact': '../../escape'}))
            with self.assertRaisesRegex(ValueError, 'Paketpfad'):
                study.build_status(base)

    def test_registry_lifecycle_docs_and_study_purpose(self):
        entry, = [e for e in json.loads((ROOT / 'config/tools.yml').read_text())['tools'] if e['id'] == study.KEY]
        self.assertEqual(entry['source_commit'], study.SPEC['pin'])
        self.assertFalse(entry['auto_install'])
        for action in ('install', 'update', 'uninstall', 'status', 'check', 'doctor'):
            self.assertTrue((ROOT / 'scripts/tools' / (study.KEY + '_' + action + '.sh')).is_file())
        doc = (ROOT / entry['doc']).read_text(encoding='utf-8')
        for text in ('Studienzwecke und Weiterentwicklung', '--accept-pinned-binaries',
                     '8 GiB', 'kein vollstaendiger', 'nicht ausgefuehrt'):
            self.assertIn(text.lower(), doc.lower())


if __name__ == '__main__':
    unittest.main()
