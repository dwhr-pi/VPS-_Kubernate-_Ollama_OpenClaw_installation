"""Offline fixtures only: ephemeral HTTP server and private temporary files."""
import importlib.util
import io
import json
import os
from pathlib import Path
import tarfile
import tempfile
import threading
import unittest
from unittest import mock

ROOT = Path(__file__).resolve().parents[1]


def module(name):
    spec = importlib.util.spec_from_file_location('docs_' + name, ROOT / 'scripts/documentation_server' / (name + '.py'))
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


server, lifecycle = module('server'), module('lifecycle')


class Converter:
    """Deterministic raw-HTML boundary fixture, not an upstream renderer substitute."""
    toc_tokens = [{'id': 'hello', 'name': 'Hello', 'level': 1, 'children': []}]

    def convert(self, text):
        return '<h1 id="hello">Hello</h1><p>' + text + '</p>'


class Viewer(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / 'docs').mkdir()
        (self.root / 'readme.md').write_text('Welcome', encoding='utf-8')
        (self.root / 'docs/test.md').write_text('GPU RAM Test', encoding='utf-8')
        (self.root / 'config.yml').write_text('a: <script>secret</script>', encoding='utf-8')
        (self.root / 'private.env').write_text('NEVER_SERVE_THIS', encoding='utf-8')
        (self.root / 'DOCS_INDEX.json').write_text(json.dumps(['readme.md', 'docs/test.md', 'config.yml']))
        self.library = server.Library(self.root, Converter)

    def test_page_and_source_are_read_only_and_toc_is_prefixed(self):
        self.assertEqual(self.library.page('readme.md')['toc'][0]['id'], 'md-hello')
        self.assertIn('&lt;script&gt;', self.library.page('config.yml')['html'])
        for name in ('../private.env', 'private.env', '/readme.md', 'docs/../../private.env'):
            with self.assertRaises(ValueError):
                self.library.page(name)

    def test_sanitizer_drops_active_html_events_schemes_and_remote_images(self):
        safe = server.Sanitizer('readme.md', self.library.catalog)
        safe.feed('<script>alert(1)</script><svg><a href="javascript:x">x</a></svg>'
                  '<img src="https://tracker.invalid/pixel" onerror="alert(2)">'
                  '<a href="javascript:alert(3)" style="color:red">bad</a>'
                  '<iframe src="//evil.invalid"></iframe><h2 id="navigation">safe</h2>')
        result = ''.join(safe.out)
        for forbidden in ('alert', 'tracker.invalid', 'javascript:', 'onerror', '<script', '<svg', '<iframe', 'style='):
            self.assertNotIn(forbidden, result)
        self.assertIn('id="md-navigation"', result)

    def test_links_rewrite_only_known_documents_and_external_clicks(self):
        safe = server.Sanitizer('docs/test.md', self.library.catalog)
        self.assertEqual(safe.link('../readme.md#hello'), '/?doc=readme.md#md-hello')
        for value in ('../../private.env', 'file:///etc/passwd', '//evil.invalid/x', 'data:text/html,test', '\\server\\file'):
            self.assertIsNone(safe.link(value))
        self.assertEqual(safe.link('https://example.com/help'), 'https://example.com/help')
        self.assertIsNone(safe.link('https://example.com/pixel.png', image=True))

    def test_github_style_unicode_anchors_keep_historical_section_links(self):
        self.assertEqual(server.github_slug('\U0001f504 Setup erneut starten', '-'), '-setup-erneut-starten')
        self.assertEqual(server.github_slug('Speicherplatz und Bereinigung', '-'), 'speicherplatz-und-bereinigung')
        self.assertEqual(server.github_slug('Gegenw\u00e4rtiger Status', '-'), 'gegenw\u00e4rtiger-status')

    def test_http_host_origin_paths_and_methods(self):
        http = server.LocalServer(('127.0.0.1', 0), self.library)
        thread = threading.Thread(target=http.serve_forever, daemon=True)
        thread.start()
        try:
            def request(path, method='GET', headers=None):
                connection = http_client = http_module.HTTPConnection('127.0.0.1', http.server_port, timeout=5)
                try:
                    http_client.request(method, path, headers=headers or {})
                    response = connection.getresponse()
                    return response.status, dict(response.getheaders()), response.read()
                finally:
                    connection.close()
            http_module = __import__('http.client', fromlist=['HTTPConnection'])
            status, headers, data = request('/api/index')
            self.assertEqual(status, 200)
            self.assertIn('pages', json.loads(data))
            self.assertIn("frame-ancestors 'none'", headers['Content-Security-Policy'])
            for headers in ({'Host': 'evil.invalid'}, {'Origin': 'https://evil.invalid'}):
                self.assertEqual(request('/api/index', headers=headers)[0], 403)
            self.assertEqual(request('/api/page?path=private.env')[0], 400)
            self.assertEqual(request('/asset?path=readme.md')[0], 400)
            self.assertEqual(request('/.git/config')[0], 404)
            self.assertEqual(request('/api/index', method='POST')[0], 501)
            self.assertEqual(request('/api/index', method='HEAD')[2], b'')
            results = json.loads(request('/api/search?q=GPU%20RAM')[2])
            self.assertEqual(results[0]['path'], 'docs/test.md')
        finally:
            http.shutdown()
            http.server_close()
            thread.join(5)

    def test_frontend_has_local_assets_compact_navigation_and_no_cdn(self):
        for name in ('index.html', 'app.js', 'style.css'):
            text = (server.APP / 'web' / name).read_text(encoding='utf-8')
            self.assertNotIn('https://', text)
            self.assertNotIn('eval(', text)
        html = (server.APP / 'web/index.html').read_text(encoding='utf-8')
        for name in ('search', 'quick', 'tree', 'toc', 'menu'):
            self.assertIn('id="' + name + '"', html)
        self.assertIn('max-width:760px', (server.APP / 'web/style.css').read_text())


class Lifecycle(unittest.TestCase):
    def test_plan_has_no_file_process_or_network_side_effects(self):
        with mock.patch('sys.argv', ['lifecycle.py', 'install']), mock.patch.object(lifecycle, 'base_path', side_effect=AssertionError), mock.patch.object(lifecycle, 'command', side_effect=AssertionError):
            with mock.patch('sys.stdout', new_callable=io.StringIO) as output:
                lifecycle.main()
        self.assertFalse(json.loads(output.getvalue())['apply'])

    def test_immutable_snapshot_and_foreign_file_protection(self):
        with tempfile.TemporaryDirectory() as temp:
            base = Path(temp)
            app = base / 'app'
            app.mkdir()
            (app / 'server.py').write_text('print(1)')
            data = dict(kind='offline-docs-source-v1', files=lifecycle.inventory(app))
            lifecycle.write_new(base / 'OWNED.json', data)
            self.assertEqual(lifecycle.verified(base), data)
            (app / 'extra.txt').write_text('user-file')
            with self.assertRaises(ValueError):
                lifecycle.verified(base)
            with self.assertRaises(FileExistsError):
                lifecycle.write_new(base / 'OWNED.json', {})

    def test_exclusive_lease_never_removes_existing_lock(self):
        with tempfile.TemporaryDirectory() as temp:
            base = Path(temp)
            with lifecycle.lease(base):
                with self.assertRaises(ValueError):
                    with lifecycle.lease(base):
                        self.fail('Should not run')
                self.assertTrue((base / 'operation.lock').exists())
            self.assertFalse((base / 'operation.lock').exists())

    def test_source_allowlist_excludes_env_git_userdata_and_executables(self):
        for path in ('.env', '.git/config', 'docs/.env', 'docs/.secret/key.md', 'tools/program.exe', 'user/secret.md'):
            self.assertIsNone(lifecycle.select_project(path))
        self.assertEqual(lifecycle.select_project('docs/guide.md'), 'content/docs/guide.md')
        self.assertEqual(lifecycle.select_project('scripts/documentation_server/server.py'), 'server.py')

    def test_archive_rejects_symlinks_and_traversal_and_keeps_safe_directories(self):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            for name, kind in (('../escape', tarfile.REGTYPE), ('link', tarfile.SYMTYPE), ('docs/safe.md', tarfile.REGTYPE)):
                archive = root / 'test.tar'
                with tarfile.open(archive, 'w') as tar:
                    directory = tarfile.TarInfo('docs/')
                    directory.type = tarfile.DIRTYPE
                    tar.addfile(directory)
                    item = tarfile.TarInfo(name)
                    item.type = kind
                    tar.addfile(item)
                if name == 'docs/safe.md':
                    lifecycle.copy_archive(archive, root / 'output', lambda n: n)
                    self.assertTrue((root / 'output/docs/safe.md').is_file())
                else:
                    with self.assertRaises(ValueError):
                        lifecycle.copy_archive(archive, root / 'output', lambda n: n)

    def test_large_text_is_not_indexed_as_browser_content_and_license_is_readable(self):
        self.assertTrue(server.readable('LICENSE'))
        self.assertFalse(server.readable('program.exe'))
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            archive = root / 'large.tar'
            with tarfile.open(archive, 'w') as tar:
                item = tarfile.TarInfo('docs/inventory.json')
                item.size = 1024 ** 2 + 1
                tar.addfile(item, io.BytesIO(b'x' * item.size))
            lifecycle.copy_archive(archive, root / 'app', lifecycle.select_project)
            self.assertFalse((root / 'app/content/docs/inventory.json').exists())

    def test_clean_git_environment_preserves_windows_systemroot_not_credentials(self):
        with mock.patch.dict(os.environ, {'SYSTEMROOT': 'C:/Windows', 'GITHUB_TOKEN': 'fixture', 'PYTHONPATH': 'unsafe'}, clear=True):
            env = lifecycle.git_env()
        self.assertEqual(env['SYSTEMROOT'], 'C:/Windows')
        self.assertNotIn('GITHUB_TOKEN', env)
        self.assertNotIn('PYTHONPATH', env)
        self.assertEqual(env['GIT_TERMINAL_PROMPT'], '0')

    def test_command_timeout_can_be_disabled_for_foreground_server(self):
        with mock.patch.object(lifecycle.subprocess, 'run') as run:
            lifecycle.command(['fixture'], timeout=None)
        self.assertIsNone(run.call_args.kwargs['timeout'])

    def test_failed_metadata_serialization_never_leaves_a_partial_marker(self):
        with tempfile.TemporaryDirectory() as temp:
            marker = Path(temp) / 'OWNED.json'
            with self.assertRaises(TypeError):
                lifecycle.write_new(marker, {'bad': object()})
            self.assertFalse(marker.exists())
            self.assertEqual(list(Path(temp).iterdir()), [])

    def test_update_publication_failure_restores_previous_app(self):
        with tempfile.TemporaryDirectory() as temp:
            base = Path(temp)
            base.chmod(0o700)
            (base / 'app').mkdir()
            (base / 'app/old.txt').write_text('keep')
            original = dict(kind='offline-docs-source-v1', files=lifecycle.inventory(base / 'app'))
            lifecycle.write_new(base / 'OWNED.json', original)
            real_write = lifecycle.write_new

            def write(path, data):
                if path.name == 'OWNED.json':
                    raise OSError('fixture publication failure')
                real_write(path, data)

            def copy(_archive, stage, _select):
                stage.mkdir(parents=True, exist_ok=True)
                (stage / 'content').mkdir(exist_ok=True)
                (stage / 'content/readme.md').write_text('# Fixture')
            with mock.patch.object(lifecycle, 'source_archive', return_value=base / 'unused.tar'), mock.patch.object(lifecycle, 'copy_archive', side_effect=copy), mock.patch.object(lifecycle, 'command'), mock.patch.object(lifecycle, 'write_new', side_effect=write):
                with self.assertRaises(OSError):
                    lifecycle.install(base, 'a' * 40, update=True)
            self.assertEqual(lifecycle.verified(base), original)
            self.assertEqual((base / 'app/old.txt').read_text(), 'keep')


if __name__ == '__main__':
    unittest.main()
