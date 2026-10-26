"""Offline BrowserOS study/build contracts, never downloads Chromium or runs a build."""
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
import browseros_study as study


class BrowserOSStudyTests(unittest.TestCase):
    def test_plan_and_status_are_readonly(self):
        with tempfile.TemporaryDirectory() as directory, patch.dict(os.environ, {'OPENCLAW_USER_DATA_DIR': directory}), patch.object(study.common, 'git') as git, patch.object(study.process, 'run') as run:
            with redirect_stdout(io.StringIO()) as output:
                self.assertEqual(study.main(['install', '--build-browser', '--dry-run']), 0)
                self.assertEqual(study.main(['status']), 0)
            self.assertIn('Studienzwecke und Weiterentwicklung', output.getvalue())
            self.assertIn('102400', output.getvalue())
            self.assertEqual(list(Path(directory).iterdir()), [])
            git.assert_not_called()
            run.assert_not_called()

    def test_build_consent_required_before_any_resources_or_downloads(self):
        with patch.object(study.common, 'reserve') as reserve:
            with self.assertRaisesRegex(ValueError, 'confirm-chromium-changes'):
                study.preflight(Path('/fixture'), False)
            reserve.assert_not_called()

    def test_windows_crossbuild_refused(self):
        with patch.object(study.platform, 'system', return_value='Windows'):
            with self.assertRaisesRegex(ValueError, 'kein Windows-Crossbuild'):
                study.preflight(Path('/fixture'), True)

    def test_experimental_command_is_source_only_no_publication_and_records_artifact(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            runtime = base / 'runtime'
            module = runtime / 'packages/browseros'
            module.mkdir(parents=True)
            (module / 'BASE_COMMIT').write_text('a' * 40)
            agent = runtime / 'packages/browseros-agent'
            agent.mkdir()
            (agent / 'package.json').write_text(json.dumps({'packageManager': 'bun@1.3.10'}))
            chromium = base / 'chromium/src'
            chromium.mkdir(parents=True)
            depot = base / 'chromium/depot_tools'
            depot.mkdir()
            commands = []
            def pipeline(args, cwd, env, **kwargs):
                commands.append(list(map(str, args)))
                self.assertNotIn('OPENAI_API_KEY', env)
                if '--show-plan' not in args and 'build' in args:
                    output = chromium / 'out/Study/chrome'
                    output.parent.mkdir(parents=True)
                    output.write_bytes(b'offline-artifact')
                return ''
            with patch.object(study.common, 'validate'), patch.object(study, 'preflight', return_value=(chromium, depot, 'python3')), patch.object(study.common, 'git', side_effect=['a' * 40, '']), patch.object(study.common, 'run', return_value='1.3.10'), patch.object(study.process, 'run', side_effect=pipeline):
                study.build(base, runtime, base / 'ready.json', True)
            browser = commands[-1]
            for flag in ('--no-clean', '--no-sign', '--no-upload'):
                self.assertIn(flag, browser)
            self.assertEqual(browser[browser.index('--provision') + 1], 'none')
            self.assertEqual(browser[browser.index('--resource-mode') + 1], 'source')
            self.assertIn('--show-plan', commands[-2])
            self.assertTrue(study.build_status(base))
            self.assertFalse(json.loads((base / 'browser-build.json').read_text())['application_tested'])
            (chromium / 'out/Study/chrome').write_bytes(b'changed')
            self.assertFalse(study.build_status(base))

    def test_forged_artifact_paths_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            base = Path(directory)
            (base / 'browser-build.json').write_text(json.dumps({'artifact': '../../outside'}))
            with self.assertRaisesRegex(ValueError, 'artefaktpfad'):
                study.build_status(base)

    def test_registry_and_docs_distinguish_source_from_browser(self):
        entry, = [e for e in json.loads((ROOT / 'config/tools.yml').read_text())['tools'] if e['id'] == study.KEY]
        self.assertEqual(entry['source_commit'], study.SPEC['pin'])
        self.assertFalse(entry['auto_install'])
        doc = (ROOT / entry['doc']).read_text(encoding='utf-8')
        for text in ('Studienzwecke und Weiterentwicklung', '--confirm-chromium-changes',
                     'kein automatischer', '100 GiB', '16 GiB', 'kein kompletter Chromium-Build'):
            self.assertIn(text.lower(), doc.lower())


if __name__ == '__main__':
    unittest.main()
