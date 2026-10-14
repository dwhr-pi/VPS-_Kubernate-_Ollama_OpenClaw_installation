"""Synthetic offline subtitle tests; no models, services or user media."""
import contextlib
import importlib.util
import io
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('karaoke_formats', ROOT / 'tools/karaoke_formats/formats.py')
formats = importlib.util.module_from_spec(spec)
spec.loader.exec_module(formats)
SRT = '1\n00:00:01,000 --> 00:00:03,000\nHello test\n\n2\n00:00:04,000 --> 00:00:06,000\nSecond line\n'
LRC = '[00:01.000]Hello test\n[00:04.000]Second line\n'


class KaraokeFormats(unittest.TestCase):
    def test_timestamps(self):
        for value, expected in [('00:01.1', 1100), ('00:01.12', 1120),
                                ('01:02:03,456', 3723456), ('90:00.000', 5400000)]:
            self.assertEqual(formats.time_ms(value), expected)
        self.assertEqual(formats.stamp(3723456, True), '01:02:03,456')

    def test_invalid_timestamps(self):
        for value in ('-1:00.000', '01:60.000', '01:60:00,000', '1.1', '00:00.1234'):
            with self.subTest(value=value), self.assertRaises(ValueError):
                formats.time_ms(value)

    def test_srt_to_lrc(self):
        self.assertEqual(formats.convert(SRT, 'srt', 'lrc'), LRC)
        multiline = '1\n00:00:01,000 --> 00:00:02,000\nFirst\nsecond\n'
        self.assertEqual(formats.convert(multiline, 'srt', 'lrc'), '[00:01.000]First second\n')

    def test_lrc_to_srt_loses_gap(self):
        result = formats.convert(LRC, 'lrc', 'srt', '00:00:06.000')
        self.assertEqual(formats.parse_srt(result)[0][1], 4000)
        self.assertNotEqual(result, SRT)

    def test_lrc_requires_final_end(self):
        for end in (None, '00:04.000', '00:03.000'):
            with self.subTest(end=end), self.assertRaises(ValueError):
                formats.convert(LRC, 'lrc', 'srt', end)

    def test_unsupported_lrc_rejected(self):
        for text in ('[00:01.00]<00:01.10>word', '[00:01.00][00:02.00]line',
                     '[offset:100]\n' + LRC, '[00:04.00]later\n[00:01.00]earlier',
                     '[00:01.00]one\n[00:01.00]two', '', '[00:01.00] '):
            with self.subTest(text=text), self.assertRaises(ValueError):
                formats.parse_lrc(text)

    def test_metadata_ignored(self):
        self.assertEqual(formats.parse_lrc('[ti:demo]\n[offset:0]\n' + LRC),
                         [(1000, 'Hello test'), (4000, 'Second line')])

    def test_invalid_srt_rejected(self):
        for text in ('', 'not srt', SRT.replace('00:00:03,000', '00:00:05,000'),
                     SRT.replace('00:00:03,000', '00:00:00,000')):
            with self.subTest(text=text), self.assertRaises(ValueError):
                formats.parse_srt(text)

    def test_unicode(self):
        text = '[00:01.000]Gr\u00fcsse \u65e5\u672c\u8a9e\n'
        self.assertIn('Gr\u00fcsse', formats.convert(text, 'lrc', 'srt', '00:02.000'))

    def test_plan_does_not_read_or_write(self):
        with patch.object(formats, 'read_text', side_effect=AssertionError('read')), patch.object(formats, 'write_private', side_effect=AssertionError('write')), contextlib.redirect_stdout(io.StringIO()):
            self.assertEqual(formats.main(['convert', '--input', 'nonexistent']), 0)

    def test_export_explicit_and_no_overwrite(self):
        with tempfile.TemporaryDirectory() as temp:
            source, output = Path(temp) / 'demo.srt', Path(temp) / 'demo.lrc'
            source.write_text(SRT, encoding='utf-8')
            argv = ['convert', '--from', 'srt', '--to', 'lrc', '--input', str(source),
                    '--output', str(output), '--apply']
            with contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(formats.main(argv), 0)
            self.assertEqual(output.read_text(encoding='utf-8'), LRC)
            with contextlib.redirect_stderr(io.StringIO()):
                self.assertEqual(formats.main(argv), 1)
            self.assertEqual(output.read_text(encoding='utf-8'), LRC)

    def test_invalid_output_paths(self):
        for path in ('relative.lrc', ROOT / 'never-write.lrc'):
            with self.subTest(path=path), self.assertRaises(ValueError):
                formats.write_private(path, 'test')

    def test_oversized_input(self):
        with tempfile.TemporaryDirectory() as temp:
            source = Path(temp) / 'huge.lrc'
            source.write_bytes(b'x' * (2 * 1024 * 1024 + 1))
            with self.assertRaises(ValueError):
                formats.read_text(source)

    def test_not_a_package_installer(self):
        with contextlib.redirect_stderr(io.StringIO()):
            for mode in ('install', 'uninstall', 'update'):
                self.assertEqual(formats.main([mode]), 2)


if __name__ == '__main__':
    unittest.main()
