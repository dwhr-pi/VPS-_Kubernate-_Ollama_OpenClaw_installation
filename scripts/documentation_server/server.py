"""Read-only, loopback-only documentation viewer; no remote assets or execution."""
import argparse
import html
from html.parser import HTMLParser
import importlib
import json
import mimetypes
from pathlib import Path
import re
import socketserver
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs, quote, unquote, urlsplit
import posixpath
import threading

APP = Path(__file__).resolve().parent
PIN = 'b41e0aaf1181f1a8cb200cf5a815aad7c0020d23'
MAX_PAGE = 1024 * 1024
SOURCE_EXT = {'.md', '.sh', '.py', '.yaml', '.yml', '.json', '.toml', '.txt', '.conf'}
QUICK = [('readme.md', 'Start & Quickstarts'), ('docs/CURRENT_STATUS.md', 'Aktueller Stand'),
         ('docs/SIGNED_RELEASES.md', 'Sicher installieren'),
         ('docs/INSTALL_BRANCH_SELECTION.md', 'Branch waehlen'),
         ('docs/INSTALLATION_BENCHMARKS.md', 'Zeit & Speicher messen'),
         ('docs/LINUX_INSTALL_LAB.md', 'Linux-Testlabor'),
         ('docs/WSL_INSTALL_LAB.md', 'WSL-Testlabor')]
HISTORICAL_QUICK = [('quickstarts', 'Quickstarts'),
                    ('setup-skripte-schnell-finden', 'Setup-Skripte finden'),
                    ('speicherplatz-und-bereinigung', 'Speicher & Bereinigung'),
                    ('-setup-erneut-starten', 'Setup erneut starten'),
                    ('-setup-aktualisieren-oder-lokal-entfernen', 'Aktualisieren / Entfernen')]


def readable(name):
    return Path(name).suffix.lower() in SOURCE_EXT or Path(name).name == 'LICENSE'


def regular(root, name, limit=MAX_PAGE):
    """Reject traversal and symlink components, including links inside the snapshot."""
    parts = name.split('/')
    if not name or any(p in ('', '.', '..') for p in parts) or '\\' in name or ':' in name:
        raise ValueError('Ungueltiger Dokumentpfad')
    path = root
    for part in parts:
        path = path / part
        if path.is_symlink() or (hasattr(path, 'is_junction') and path.is_junction()):
            raise ValueError('Dateilinks sind nicht erlaubt')
    if not path.is_file() or path.stat().st_size > limit:
        raise ValueError('Datei fehlt oder ist zu gross')
    return path


class Sanitizer(HTMLParser):
    TAGS = set('p br hr h1 h2 h3 h4 h5 h6 ul ol li blockquote pre code strong em del a img '
               'table thead tbody tr th td details summary div span dl dt dd'.split())
    VOID = {'br', 'hr', 'img'}
    BLOCK = {'script', 'style', 'iframe', 'object', 'svg', 'math', 'template', 'form'}

    def __init__(self, page, catalog):
        super().__init__(convert_charrefs=True)
        self.page, self.catalog, self.out, self.blocked = page, catalog, [], 0

    def link(self, url, image=False):
        parsed = urlsplit(url)
        if parsed.scheme or parsed.netloc:
            return url if not image and parsed.scheme in ('https', 'http') and parsed.netloc else None
        if '\\' in url or parsed.query:
            return None
        path = posixpath.normpath(posixpath.join(posixpath.dirname(self.page), unquote(parsed.path)))
        if not parsed.path:
            path = self.page
        if path.endswith('/') or path not in self.catalog:
            index = path.rstrip('/') + '/readme.md'
            if index not in self.catalog:
                index = path.rstrip('/') + '/README.md'
            path = index
        if path not in self.catalog:
            return None
        if image:
            return '/asset?path=' + quote(path, safe='') if Path(path).suffix.lower() in {'.png', '.jpg', '.jpeg', '.gif', '.webp'} else None
        return '/?doc=' + quote(path, safe='') + ('#md-' + quote(unquote(parsed.fragment), safe='-_') if parsed.fragment else '')

    def handle_starttag(self, tag, attrs):
        if tag in self.BLOCK:
            self.blocked += 1
        if self.blocked or tag not in self.TAGS:
            return
        clean = []
        for key, value in attrs:
            value = value or ''
            if key == 'id':
                clean.append(('id', 'md-' + value))
            elif key in ('title', 'alt'):
                clean.append((key, value))
            elif tag == 'a' and key == 'href':
                link = self.link(value)
                if link:
                    clean.append(('href', link))
                    if urlsplit(link).scheme:
                        clean.extend([('rel', 'noopener noreferrer'), ('target', '_blank')])
            elif tag == 'img' and key == 'src':
                link = self.link(value, image=True)
                if link:
                    clean.extend([('src', link), ('loading', 'lazy')])
        self.out.append('<' + tag + ''.join(' ' + k + '="' + html.escape(v, quote=True) + '"' for k, v in clean) + '>')

    def handle_endtag(self, tag):
        if tag in self.BLOCK and self.blocked:
            self.blocked -= 1
            return
        if not self.blocked and tag in self.TAGS and tag not in self.VOID:
            self.out.append('</' + tag + '>')

    def handle_data(self, data):
        if not self.blocked:
            self.out.append(html.escape(data))


def github_slug(value, separator):
    value = re.sub(r'[^\w\s-]', '', html.unescape(value).lower())
    return re.sub(r'\s', separator, value)


def engine():
    vendor = APP / 'vendor'
    if not (vendor / 'markdown/__init__.py').is_file():
        raise ValueError('Python-Markdown-Quellen fehlen: zuerst bewusst installieren')
    sys.path.insert(0, str(vendor))
    module = importlib.import_module('markdown')
    if not Path(module.__file__).resolve().is_relative_to(vendor.resolve()):
        raise ValueError('Fremdes Markdown-Modul abgelehnt')
    from markdown.extensions.tables import TableExtension
    from markdown.extensions.fenced_code import FencedCodeExtension
    from markdown.extensions.toc import TocExtension
    from markdown.extensions.sane_lists import SaneListExtension
    from markdown.extensions.md_in_html import MarkdownInHtmlExtension
    return module.Markdown(extensions=[TableExtension(), FencedCodeExtension(), TocExtension(slugify=github_slug), SaneListExtension(), MarkdownInHtmlExtension()])


class Library:
    def __init__(self, root, markdown):
        self.root, self.markdown = root, markdown
        index = json.loads(regular(root, 'DOCS_INDEX.json', 4 * MAX_PAGE).read_text(encoding='utf-8'))
        if not isinstance(index, list) or len(index) > 15000 or any(not isinstance(n, str) for n in index):
            raise ValueError('Ungueltiger Dokumentindex')
        self.catalog = frozenset(index)
        self.pages, self.search = [], []
        for name in sorted(self.catalog, key=str.casefold):
            if not readable(name):
                continue
            text = regular(root, name).read_text(encoding='utf-8', errors='replace')
            match = re.search(r'^#\s+(.+)', text, re.M) if name.lower().endswith('.md') else None
            title = match.group(1).strip() if match else Path(name).stem.replace('_', ' ')
            group = 'Projekt' if '/' not in name else (' / '.join(name.split('/')[1:-1]) or name.split('/')[0])
            self.pages.append(dict(path=name, title=title, group=group))
            self.search.append((name, title, text.casefold()))

    def page(self, name):
        if name not in self.catalog or not readable(name):
            raise ValueError('Dokument nicht freigegeben')
        text = regular(self.root, name).read_text(encoding='utf-8', errors='replace')
        if not name.lower().endswith('.md'):
            return dict(html='<pre><code>' + html.escape(text) + '</code></pre>', toc=[], path=name)
        converter = self.markdown()
        # GitHub renders Markdown inside details; opt in explicitly for this renderer.
        text = re.sub(r'<details\s*>', '<details markdown="1">', text, flags=re.I)
        rendered = converter.convert(text)
        safe = Sanitizer(name, self.catalog)
        safe.feed(rendered)
        toc = []

        def visit(items):
            for item in items:
                toc.append(dict(id='md-' + item['id'], title=html.unescape(re.sub('<[^>]*>', '', item['name'])), level=item['level']))
                visit(item.get('children', []))
        visit(converter.toc_tokens)
        return dict(html=''.join(safe.out), toc=toc, path=name)


class Handler(BaseHTTPRequestHandler):
    server_version = 'OfflineDocs'

    def log_message(self, *_args):
        pass  # Do not log search queries or document text.

    def answer(self, status, data, mime):
        self.send_response(status)
        self.send_header('Content-Type', mime)
        self.send_header('Content-Length', str(len(data)))
        self.send_header('Content-Security-Policy', "default-src 'none'; script-src 'self'; style-src 'self'; img-src 'self'; connect-src 'self'; base-uri 'none'; frame-ancestors 'none'; form-action 'none'")
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.send_header('Cross-Origin-Resource-Policy', 'same-origin')
        self.send_header('Cache-Control', 'no-store')
        self.end_headers()
        if self.command != 'HEAD':
            self.wfile.write(data)

    def do_HEAD(self):
        self.do_GET()

    def do_GET(self):
        port = self.server.server_port
        hosts = {f'127.0.0.1:{port}', f'localhost:{port}'}
        origin = self.headers.get('Origin')
        if self.headers.get('Host') not in hosts or (origin and origin not in {'http://' + h for h in hosts}):
            self.answer(403, b'Nur lokaler Zugriff', 'text/plain; charset=utf-8')
            return
        if len(self.path) > 4096:
            self.answer(414, b'URI zu lang', 'text/plain')
            return
        try:
            parsed = urlsplit(self.path)
            args = parse_qs(parsed.query, max_num_fields=4)
            library = self.server.library
            if parsed.path in ('/', '/static/app.js', '/static/style.css'):
                name = {'/': 'index.html', '/static/app.js': 'app.js', '/static/style.css': 'style.css'}[parsed.path]
                mime = {'index.html': 'text/html; charset=utf-8', 'app.js': 'text/javascript; charset=utf-8', 'style.css': 'text/css; charset=utf-8'}[name]
                self.answer(200, regular(APP / 'web', name).read_bytes(), mime)
                return
            if parsed.path == '/api/index':
                result = dict(pages=library.pages, quick=[dict(path=p, title=t) for p, t in QUICK if p in library.catalog])
                history = 'docs/legacy/README_FULL_2026_11_01.md'
                if history in library.catalog:
                    result['quick'].extend(dict(path=history, title=t, anchor='md-' + a) for a, t in HISTORICAL_QUICK)
            elif parsed.path == '/api/page':
                result = library.page(args.get('path', ['readme.md'])[0])
            elif parsed.path == '/api/search':
                words = args.get('q', [''])[0][:120].casefold().split()
                result = [dict(path=p, title=t) for p, t, text in library.search if words and all(w in text or w in p.casefold() for w in words)][:60]
            elif parsed.path == '/asset':
                name = args.get('path', [''])[0]
                if name not in library.catalog or Path(name).suffix.lower() not in {'.png', '.jpg', '.jpeg', '.gif', '.webp'}:
                    raise ValueError('Asset nicht freigegeben')
                self.answer(200, regular(library.root, name, 20 * MAX_PAGE).read_bytes(), mimetypes.guess_type(name)[0] or 'application/octet-stream')
                return
            else:
                self.answer(404, b'Nicht gefunden', 'text/plain')
                return
            self.answer(200, json.dumps(result, ensure_ascii=False).encode('utf-8'), 'application/json; charset=utf-8')
        except (ValueError, OSError, KeyError):
            self.answer(400, b'Dokument nicht verfuegbar', 'text/plain; charset=utf-8')


class LocalServer(socketserver.ThreadingMixIn, HTTPServer):
    daemon_threads = True

    def __init__(self, address, library):
        self.library = library
        self.slots = threading.BoundedSemaphore(4)
        super().__init__(address, Handler)

    def process_request(self, request, address):
        request.settimeout(5)
        if not self.slots.acquire(blocking=False):
            self.shutdown_request(request)
            return
        try:
            super().process_request(request, address)
        except BaseException:
            self.slots.release()
            raise

    def process_request_thread(self, request, address):
        try:
            super().process_request_thread(request, address)
        finally:
            self.slots.release()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['check', 'serve'])
    parser.add_argument('--port', type=int, default=8765)
    args = parser.parse_args()
    if not 1024 <= args.port <= 65535:
        parser.error('Nur unprivilegierte Ports sind erlaubt')
    library = Library(APP / 'content', engine)
    library.page('readme.md')
    if args.action == 'check':
        print(json.dumps(dict(pages=len(library.pages), runtime_verified=False)))
        return
    import os
    if hasattr(os, 'geteuid') and os.geteuid() == 0:
        parser.error('Bitte als normaler Benutzer starten')
    with LocalServer(('127.0.0.1', args.port), library) as server:
        print(f'Offline-Dokumentation: http://127.0.0.1:{args.port} | Stop: Strg+C', flush=True)
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            pass


if __name__ == '__main__':
    main()
