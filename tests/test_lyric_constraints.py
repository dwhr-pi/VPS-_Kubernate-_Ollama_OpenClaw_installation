"""Offline stanza fixtures; no real Outlines, model, phonemizer, audio or network."""
from contextlib import redirect_stdout
from copy import deepcopy
import importlib.util
import io
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import types
import unittest
from unittest.mock import Mock, patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('lyric_fixture', ROOT / 'scripts/creative/lyric_constraints.py')
tool = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(tool)
EXAMPLES = ROOT / 'examples/creative_lyrics'


class LyricConstraints(unittest.TestCase):
    def setUp(self):
        self.request = json.loads((EXAMPLES / 'request.json').read_text())
        self.lexicon = json.loads((EXAMPLES / 'lexicon.de.json').read_text())
        self.sample = (EXAMPLES / 'sample.txt').read_text().rstrip('\n')

    def test_sample_form_and_three_output_sections(self):
        report = tool.validate(self.sample, self.request, self.lexicon)
        self.assertEqual(report['exit_code'], 0)
        self.assertTrue(report['validated_lexicon_constraints'])
        self.assertTrue(report['human_review_required'])
        self.assertFalse(report['runtime_acceptance'])
        self.assertEqual([row['syllables'] for row in report['lines']], [4] * 4)
        self.assertEqual([row['stress'] for row in report['lines']], ['0101'] * 4)
        rendered = tool.render(self.sample, report)
        for header in ('[Metadata Header]', '[Lyrics / Poem]', '[Rhyme & Cadence Analysis]'):
            self.assertEqual(rendered.count(header), 1)

    def test_supported_schemes_have_terminal_not_initial_constraints(self):
        for scheme, text in (
            ('AABB', self.sample),
            ('ABAB', 'Es ruft die Nacht\nEs scheint das Licht\nEs strahlt die Pracht\nEs bleibt die Pflicht'),
            ('ABBA', 'Es ruft die Nacht\nEs scheint das Licht\nEs bleibt die Pflicht\nEs strahlt die Pracht'),
            ('AAAA', 'Es ruft die Nacht\nEs strahlt die Pracht\nEs ruft die Macht\nEs ruft die Wacht')):
            with self.subTest(scheme=scheme):
                request = deepcopy(self.request)
                request['scheme'] = scheme
                if scheme == 'AAAA':
                    request['endings'].pop('B')
                planned = tool.plan(request, self.lexicon)
                self.assertTrue(re.fullmatch(planned['pattern'], text))
                self.assertEqual(tool.validate(text, request, self.lexicon)['exit_code'], 0)
                self.assertFalse(re.fullmatch(planned['pattern'], 'Nacht steht am Anfang\n' * 4))

    def test_blank_extra_and_unusual_line_breaks_are_rejected(self):
        for text in (self.sample + '\n', self.sample + '\nNoch eine Zeile',
                     self.sample.replace('\n', '\n\n', 1), self.sample.replace('Es ruft', 'Es\u2028ruft')):
            with self.subTest(text=text):
                report = tool.validate(text, self.request, self.lexicon)
                self.assertEqual(report['exit_code'], 1)
        self.assertEqual(tool.validate(self.sample.replace('\n', '\r\n'), self.request, self.lexicon)['exit_code'], 0)

    def test_known_syllable_and_stress_errors_fail(self):
        report = tool.validate(self.sample.replace('das Licht', 'das Gedicht'), self.request, self.lexicon)
        self.assertIn('syllable-count-line-3', report['errors'])
        request = deepcopy(self.request)
        request['meter'] = '1010'
        self.assertIn('stress-pattern-line-1', tool.validate(self.sample, request, self.lexicon)['errors'])

    def test_unknown_words_and_numbers_never_become_success(self):
        for text in (self.sample.replace('ruft', 'fluestert'), self.sample.replace('ruft', '123')):
            report = tool.validate(text, self.request, self.lexicon)
            self.assertEqual(report['exit_code'], 3)
            self.assertFalse(report['validated_lexicon_constraints'])
            self.assertIsNone(report['lines'][0]['syllables'])
            self.assertTrue(report['pending'])

    def test_terminal_controls_are_not_rendered_from_drafts_or_annotations(self):
        for control in ('\x1b', '\x9b', '\u202e'):
            with self.subTest(control=repr(control)):
                with self.assertRaisesRegex(ValueError, 'Control'):
                    tool.validate(self.sample.replace('ruft', control + 'ruft'), self.request, self.lexicon)
                request = deepcopy(self.request)
                request['topic'] = control + 'theme'
                with self.assertRaises(ValueError):
                    tool.plan(request, self.lexicon)
                lexicon = deepcopy(self.lexicon)
                lexicon['entries']['nacht']['ipa'] = control + '/naxt/'
                with self.assertRaises(ValueError):
                    tool.plan(self.request, lexicon)

    def test_same_end_word_and_invalid_rhyme_groups_fail(self):
        report = tool.validate(self.sample.replace('Pracht', 'Nacht'), self.request, self.lexicon)
        self.assertIn('repeated-end-word', report['errors'])
        request = deepcopy(self.request)
        request['endings']['A'] = ['Nacht', 'Licht']
        with self.assertRaisesRegex(ValueError, 'Rhyme groups'):
            tool.plan(request, self.lexicon)
        lexicon = deepcopy(self.lexicon)
        for word in ('licht', 'sicht', 'gedicht', 'pflicht'):
            lexicon['entries'][word]['rhyme'] = 'axt'
        with self.assertRaisesRegex(ValueError, 'Rhyme groups'):
            tool.plan(self.request, lexicon)

    def test_invalid_request_and_lexicon_inputs_are_bounded(self):
        for field, value in (('topic', 'x' * 301), ('scheme', 'A' * 17), ('syllables_per_line', True),
                             ('meter', 'iambic pentameter'), ('allow_slant', True),
                             ('structure', 'sonnet'), ('language', 'en')):
            with self.subTest(field=field):
                request = deepcopy(self.request)
                request[field] = value
                with self.assertRaises(ValueError):
                    tool.plan(request, self.lexicon)
        lexicon = deepcopy(self.lexicon)
        lexicon['version'] = True
        with self.assertRaises(ValueError):
            tool.plan(self.request, lexicon)
        for key in ('endings', 'mode'):
            request = deepcopy(self.request)
            del request[key]
            with self.assertRaises(ValueError):
                tool.plan(request, self.lexicon)
        with self.assertRaises(ValueError):
            tool.validate('x' * 8193, self.request, self.lexicon)

    def test_json_duplicates_binary_oversize_and_links_are_not_accepted(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            file = root / 'input.json'
            file.write_text('{"mode":"creative","mode":"assistant"}')
            with self.assertRaisesRegex(ValueError, 'Duplicate'):
                tool.load_json(file)
            file.write_bytes(b'a\0b')
            with self.assertRaises(ValueError):
                tool.read_text(file)
            file.write_bytes(b'x' * 65537)
            with self.assertRaises(ValueError):
                tool.read_text(file)
            link = root / 'link'
            with patch.object(Path, 'is_symlink', side_effect=lambda: True):
                with self.assertRaisesRegex(ValueError, 'Linked'):
                    tool.read_text(link)

    def test_plan_needs_no_outlines_and_writes_no_files(self):
        with tempfile.TemporaryDirectory() as temporary, patch.dict(sys.modules, {'outlines': None}), redirect_stdout(io.StringIO()) as out:
            before = list(Path(temporary).iterdir())
            self.assertEqual(tool.main(['plan', '--request', str(EXAMPLES / 'request.json'),
                                       '--lexicon', str(EXAMPLES / 'lexicon.de.json')]), 0)
            planned = json.loads(out.getvalue())
            self.assertFalse(planned['automatic_generation'])
            self.assertFalse(planned['runtime_acceptance'])
            self.assertEqual(before, list(Path(temporary).iterdir()))

    def test_generation_requires_approval_and_has_no_fallback(self):
        model = Mock(return_value=self.sample)
        with self.assertRaisesRegex(ValueError, 'approval'):
            tool.generate_with_outlines(model, self.request, self.lexicon)
        with self.assertRaisesRegex(ValueError, 'approval'):
            tool.generate_with_outlines(model, self.request, self.lexicon, approved='no')
        model.assert_not_called()
        for kwargs in ({'max_attempts': 4}, {'max_new_tokens': 1025}, {'max_attempts': True}):
            with self.assertRaises(ValueError):
                tool.generate_with_outlines(model, self.request, self.lexicon, approved=True, **kwargs)
        model.assert_not_called()

    def test_current_outlines_type_and_bounded_retries_are_stubbed_not_inferred(self):
        module = types.ModuleType('outlines.types')
        module.Regex = Mock(side_effect=lambda pattern: ('Regex-fixture', pattern))
        model = Mock(side_effect=['Es fliegt die Nacht\nEs strahlt die Pracht\nEs scheint das Licht\nEs bleibt die Pflicht', self.sample])
        with patch.dict(sys.modules, {'outlines.types': module}):
            text, report = tool.generate_with_outlines(model, self.request, self.lexicon, approved=True)
            self.assertEqual(text, self.sample)
            self.assertTrue(report['validated_lexicon_constraints'])
            self.assertEqual(model.call_count, 2)
            self.assertEqual(model.call_args.kwargs, {'max_new_tokens': 512})
            self.assertEqual(model.call_args.args[1][0], 'Regex-fixture')
            model = Mock(return_value='invalid')
            with self.assertRaisesRegex(ValueError, 'attempt limit'):
                tool.generate_with_outlines(model, self.request, self.lexicon, approved=True, max_attempts=3)
            self.assertEqual(model.call_count, 3)
            request = deepcopy(self.request)
            request['mode'] = 'assistant'
            with self.assertRaisesRegex(ValueError, 'Assistant mode'):
                tool.generate_with_outlines(model, request, self.lexicon, approved=True)

    def test_cli_renders_utf8_ipa_without_backend_import(self):
        args = [sys.executable, '-B', str(ROOT / 'scripts/creative/lyric_constraints.py'), 'validate',
                '--request', str(EXAMPLES / 'request.json'), '--lexicon', str(EXAMPLES / 'lexicon.de.json'),
                '--lyrics', str(EXAMPLES / 'sample.txt'), '--format', 'markdown']
        result = subprocess.run(args, capture_output=True, encoding='utf-8', timeout=15,
                                env={key: value for key, value in os.environ.items()
                                     if key in ('PATH', 'SYSTEMROOT', 'WINDIR', 'TEMP', 'TMP')})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('/naxt/', result.stdout)
        self.assertIn('[Rhyme & Cadence Analysis]', result.stdout)

    def test_documentation_keeps_runtime_and_phonetics_unverified(self):
        doc = ROOT / 'docs/CREATIVE_LYRICS.md'
        text = doc.read_text(encoding='utf-8')
        for term in ('kein echter Decoder', 'menschliche Skansion', 'runtime_acceptance: false',
                     'nur eine Strophe', 'keine vollstaendige Pruefung', 'LogitsProcessor',
                     'Kein Remote-/Cloud-', 'keine automatische Installation'):
            self.assertIn(term.casefold(), text.casefold())
        for target in re.findall(r'\]\(([^\s)]+)\)', text):
            if '://' not in target and not target.startswith('#'):
                self.assertTrue((doc.parent / target.split('#')[0]).is_file(), target)


if __name__ == '__main__':
    unittest.main()
