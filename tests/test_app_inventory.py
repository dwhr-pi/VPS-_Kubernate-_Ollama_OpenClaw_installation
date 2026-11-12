"""Synthetic cross-platform app metadata only; never inspect installed host apps."""
from contextlib import redirect_stdout, redirect_stderr
import importlib.util
import io
import json
import os
from pathlib import Path
import plistlib
import tempfile
import types
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('app_inventory', ROOT / 'scripts/desktop/app_inventory.py')
app = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(app)


class AppInventory(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.hints = app.load_hints()

    def desktop(self, name='Qwen Code Desktop', filename='fixture.desktop', extra=''):
        path = self.root / filename
        path.write_text('[Desktop Entry]\nType=Application\nName=' + name + '\n' + extra, encoding='utf-8')
        return path

    def test_default_plan_never_scans_or_reads_hints(self):
        with patch.object(app, 'scan') as scan, patch.object(app, 'load_hints') as hints:
            with redirect_stdout(io.StringIO()) as out:
                self.assertEqual(app.main([]), 0)
            self.assertFalse(json.loads(out.getvalue())['scan_performed'])
            scan.assert_not_called()
            hints.assert_not_called()

    def test_cli_requires_consent_roots_and_actual_platform(self):
        with patch.object(app, 'scan') as scan, patch.object(app, 'host_platform', return_value='linux'):
            for args in (['--scan'], ['--scan', '--root', str(self.root)],
                         ['--scan', '--approve-local-inventory'],
                         ['--scan', '--approve-local-inventory', '--platform', 'macos', '--root', str(self.root)]):
                with redirect_stderr(io.StringIO()), self.assertRaises(SystemExit):
                    app.main(args)
            scan.assert_not_called()

    def test_linux_reads_name_but_never_exports_exec_or_tokens(self):
        self.desktop(extra='Exec=sh -c "touch SHOULD_NOT_EXIST; token=synthetic-secret"\nIcon=/private/brand.png\n')
        report = app.scan([self.root], 'linux', self.hints)
        row = report['candidates'][0]
        self.assertEqual(row['registry_candidates'], ['qwen_desktop', 'qwen_desktop_build'])
        self.assertFalse(row['launch_enabled'])
        self.assertEqual(row['icon'], {'state': 'reference-only', 'name_hint': 'brand.png'})
        self.assertFalse((self.root / 'SHOULD_NOT_EXIST').exists())
        for private in ('synthetic-secret', str(self.root), '/private', 'Exec='):
            self.assertNotIn(private, json.dumps(report))

    def test_unknown_ai_apps_are_unmapped_proposals(self):
        self.desktop('Example AI Workbench')
        row = app.scan([self.root], 'linux', self.hints)['candidates'][0]
        self.assertEqual(row['registry_candidates'], [])
        self.assertEqual(row['match_basis'], 'ai-name-heuristic')
        self.assertEqual(row['installation_status'], 'unverified')

    def test_unknown_non_ai_apps_require_extra_export_opt_in(self):
        self.desktop('Example Editor')
        self.assertEqual(app.scan([self.root], 'linux', self.hints)['candidates'], [])
        row = app.scan([self.root], 'linux', self.hints, include_unclassified=True)['candidates'][0]
        self.assertEqual(row['match_basis'], 'unclassified')

    def test_windows_filename_only_and_installers_are_not_launchers(self):
        (self.root / 'qwen-code-desktop.exe').write_bytes(b'NOT AN EXECUTABLE')
        (self.root / 'qwen-desktop-setup.exe').write_bytes(b'NOT AN INSTALLER')
        (self.root / 'fixture.lnk').write_bytes(b'not parsed')
        report = app.scan([self.root], 'windows', self.hints)
        self.assertEqual(len(report['candidates']), 1)
        self.assertEqual(report['candidates'][0]['installation_status'], 'unverified')
        self.assertFalse(report['executed'])

    def test_macos_xml_and_binary_plist_without_executing_bundle(self):
        for i, fmt in enumerate((plistlib.FMT_XML, plistlib.FMT_BINARY)):
            bundle = self.root / f'Fixture{i}.app/Contents'
            bundle.mkdir(parents=True)
            (bundle / 'Info.plist').write_bytes(plistlib.dumps({
                'CFBundleName': 'Ollama', 'CFBundleIdentifier': 'example.fixture.app',
                'CFBundleShortVersionString': '0.fixture', 'CFBundleExecutable': 'never-executed',
                'CFBundleIconFile': 'fixture.icns'}, fmt=fmt))
        report = app.scan([self.root], 'macos', self.hints)
        self.assertEqual(len(report['candidates']), 2)
        self.assertTrue(report['complete_scope'])
        self.assertTrue(all(row['version_hint'] == '0.fixture' for row in report['candidates']))

    def test_mobile_plans_are_explicit_and_scans_refused(self):
        for platform in ('android', 'ios'):
            with redirect_stdout(io.StringIO()) as out:
                self.assertEqual(app.main(['--platform', platform]), 0)
            self.assertEqual(json.loads(out.getvalue())['platform'], platform)
            with self.assertRaises(ValueError):
                app.scan([self.root], platform, self.hints)

    def test_hidden_link_and_broken_metadata_are_not_exported(self):
        self.desktop(extra='Hidden=true\n')
        (self.root / 'bad.desktop').write_text('invalid', encoding='utf-8')
        report = app.scan([self.root], 'linux', self.hints)
        self.assertEqual(report['candidates'], [])
        self.assertGreater(report['stats']['errors'], 0)
        self.assertFalse(report['complete_scope'])

    def test_malformed_plists_and_entities_are_bounded_failures(self):
        for name, payload in (('Bad', b'<plist><dict>'),
                              ('Entity', b'<!DOCTYPE plist [<!ENTITY x "NO">]><plist>&x;</plist>')):
            bundle = self.root / (name + '.app/Contents')
            bundle.mkdir(parents=True)
            (bundle / 'Info.plist').write_bytes(payload)
        report = app.scan([self.root], 'macos', self.hints)
        self.assertFalse(report['complete_scope'])
        self.assertEqual(report['candidates'], [])

    def test_oversized_metadata_is_not_parsed(self):
        (self.root / 'oversized.desktop').write_bytes(b'x' * (app.MAX_BYTES + 1))
        report = app.scan([self.root], 'linux', self.hints)
        self.assertEqual(report['candidates'], [])
        self.assertFalse(report['complete_scope'])

    def test_windows_reparse_attribute_is_a_link_boundary(self):
        info = types.SimpleNamespace(st_mode=app.stat.S_IFDIR, st_file_attributes=0x400)
        with patch.object(Path, 'lstat', return_value=info):
            self.assertTrue(app.linked(self.root))

    def test_all_scan_parameters_are_bounded_before_traversal(self):
        for options in ({'max_depth': 4}, {'limit': 2001}, {'limit': 0}):
            with patch.object(app.os, 'scandir') as listing:
                with self.assertRaises(ValueError):
                    app.scan([self.root], 'linux', self.hints, **options)
                listing.assert_not_called()
        with self.assertRaises(ValueError):
            app.scan([self.root] * 9, 'linux', self.hints)

    def test_sensitive_hidden_directories_are_not_descended(self):
        for folder in ('.ssh', '.hidden', 'credentials'):
            directory = self.root / folder
            directory.mkdir()
            (directory / 'Fake AI.desktop').write_text('[Desktop Entry]\nType=Application\nName=Fake AI\n')
        self.assertEqual(app.scan([self.root], 'linux', self.hints, max_depth=3)['candidates'], [])

    def test_depth_and_entry_limits_report_partial_scope(self):
        nested = self.root / 'level1/level2'
        nested.mkdir(parents=True)
        (nested / 'x.desktop').write_text('[Desktop Entry]\nType=Application\nName=Ollama\n')
        self.assertEqual(app.scan([self.root], 'linux', self.hints, max_depth=0)['candidates'], [])
        self.assertEqual(len(app.scan([self.root], 'linux', self.hints, max_depth=2)['candidates']), 1)
        self.desktop()
        report = app.scan([self.root], 'linux', self.hints, limit=1)
        self.assertFalse(report['complete_scope'])
        self.assertLessEqual(report['stats']['visited'], 1)

    def test_deadline_stops_without_marking_full_inventory(self):
        self.desktop()
        times = iter((0, 100))
        report = app.scan([self.root], 'linux', self.hints, clock=lambda: next(times))
        self.assertFalse(report['complete_scope'])
        self.assertFalse(report['full_os_inventory'])

    def test_local_paths_need_explicit_output_opt_in(self):
        path = self.desktop()
        row = app.scan([self.root], 'linux', self.hints, include_paths=True)['candidates'][0]
        self.assertEqual(row['local_metadata_path'], str(path))

    def test_device_alias_separates_candidates_without_reading_hostname(self):
        self.desktop()
        first = app.scan([self.root], 'linux', self.hints, device_id='workstation')
        second = app.scan([self.root], 'linux', self.hints, device_id='laptop')
        self.assertNotEqual(first['candidates'][0]['candidate_id'], second['candidates'][0]['candidate_id'])
        for alias in ('', 'bad\nvalue', 'a' * 65, '../secret'):
            with self.assertRaises(ValueError):
                app.scan([self.root], 'linux', self.hints, device_id=alias)

    def test_broad_and_credential_roots_are_refused(self):
        for path in (self.root.anchor, str(Path.home()), str(self.root / '..'), '//server/share', 'relative'):
            with self.assertRaises((ValueError, OSError)):
                app.checked_root(path)
        sensitive = self.root / '.ssh'
        sensitive.mkdir()
        with self.assertRaises(ValueError):
            app.checked_root(sensitive)

    @unittest.skipUnless(os.name == 'posix', 'POSIX symlink fixture; no WSL fallback')
    def test_symlink_and_hardlink_metadata_are_not_read(self):
        peer = self.desktop()
        (self.root / 'linked.desktop').symlink_to(peer)
        os.link(peer, self.root / 'hardlink.desktop')
        report = app.scan([self.root], 'linux', self.hints)
        self.assertEqual(report['candidates'], [])
        self.assertGreater(report['stats']['errors'], 0)

    def test_cli_scan_fixture_and_schema_contract(self):
        self.desktop()
        with patch.object(app, 'host_platform', return_value='linux'), redirect_stdout(io.StringIO()) as out:
            self.assertEqual(app.main(['--scan', '--approve-local-inventory', '--root', str(self.root)]), 0)
        report = json.loads(out.getvalue())
        schema = json.loads((ROOT / 'config/schemas/app-discovery.schema.json').read_text(encoding='utf-8'))
        self.assertEqual(set(schema['required']), set(report))
        self.assertEqual(set(schema['$defs']['candidate']['required']), set(report['candidates'][0]))
        for key in ('executed', 'network_requested', 'registration_changed', 'full_os_inventory'):
            self.assertFalse(report[key])


if __name__ == '__main__':
    unittest.main()
