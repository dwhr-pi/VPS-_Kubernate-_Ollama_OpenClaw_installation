"""Bounded public-web research. Plan by default; never executes page instructions."""
import argparse
from collections import deque
import csv
from datetime import datetime, timezone
import hashlib
from html.parser import HTMLParser
import http.client
import ipaddress
import json
import os
from pathlib import Path
import re
import shutil
import signal
import socket
import sqlite3
import ssl
import stat
import subprocess
import sys
import tempfile
import time
from urllib.parse import parse_qsl, unquote, urlencode, urljoin, urlsplit, urlunsplit
from urllib.robotparser import RobotFileParser

ROOT = Path(__file__).resolve().parents[2]
UA = 'OpenClawResearch/0.1'
APP_ID = 0x4F435257
MAX_BODY = 512 * 1024
SCHEMA = '''CREATE TABLE pages(url TEXT PRIMARY KEY, final_url TEXT, title TEXT, body TEXT,
    sha256 TEXT, status INTEGER, fetched_at TEXT, source TEXT, error TEXT);
CREATE TABLE links(url TEXT, from_url TEXT, depth INTEGER, PRIMARY KEY(url,from_url));
CREATE VIRTUAL TABLE search USING fts5(url UNINDEXED,title,body);'''


class GuardError(ValueError):
    pass


def safe_file(path, limit=1024 * 1024):
    path = Path(path)
    for part in [*path.parents, path]:
        if part.is_symlink() or (hasattr(part, 'is_junction') and part.is_junction()):
            raise GuardError('linked_path')
    info = path.stat()
    if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1 or info.st_size > limit:
        raise GuardError('invalid_file')
    return path


def config(path):
    data = json.loads(safe_file(path).read_text(encoding='utf-8'))
    allowed = {'seeds', 'allowed_hosts', 'max_pages', 'max_depth', 'max_requests', 'max_seconds',
               'max_bytes', 'delay_seconds', 'searxng_url', 'query_keys', 'extractor'}
    if not isinstance(data, dict) or set(data) - allowed:
        raise GuardError('unknown_config_field')
    for name, default, lower, upper in [('max_pages', 20, 1, 100), ('max_depth', 1, 0, 3),
                                      ('max_requests', 100, 1, 500), ('max_seconds', 120, 10, 600),
                                      ('max_bytes', 10 * 1024 ** 2, MAX_BODY, 50 * 1024 ** 2),
                                      ('delay_seconds', 2, 2, 60)]:
        value = data.get(name, default)
        if type(value) is not int or not lower <= value <= upper:
            raise GuardError('invalid_' + name)
        data[name] = value
    hosts = data.get('allowed_hosts', [])
    if not isinstance(hosts, list) or not 1 <= len(hosts) <= 25 or any(not isinstance(h, str) or not re.fullmatch(r'[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?', h) or '..' in h for h in hosts):
        raise GuardError('explicit_hosts_required')
    keys = data.setdefault('query_keys', [])
    if not isinstance(keys, list) or len(keys) > 10 or any(not isinstance(k, str) or not re.fullmatch('[a-z0-9_]{1,30}', k) or re.search('key|token|secret|pass|auth|signature', k) for k in keys):
        raise GuardError('invalid_query_keys')
    data.setdefault('extractor', 'builtin')
    if data['extractor'] not in ('builtin', 'crawl4ai'):
        raise GuardError('invalid_extractor')
    seeds = data.get('seeds', [])
    if not isinstance(seeds, list) or len(seeds) > 100:
        raise GuardError('invalid_seeds')
    data['seeds'] = list(dict.fromkeys(normalize(s, data) for s in seeds))
    endpoint = data.get('searxng_url')
    if endpoint:
        searx_endpoint(endpoint, allow_local=True)  # Runtime needs a separate local-service grant.
    return data


def normalize(url, settings):
    if not isinstance(url, str) or len(url) > 2048 or '\\' in url or any(ord(c) < 33 for c in url):
        raise GuardError('invalid_url')
    part = urlsplit(url)
    host = part.hostname or ''
    if part.scheme != 'https' or part.username is not None or part.password is not None or part.port not in (None, 443):
        raise GuardError('https_without_credentials_required')
    if host not in settings['allowed_hosts'] or '%' in host:
        raise GuardError('outside_allowlist')
    try:
        if not public_address(host):
            raise GuardError('nonpublic_address')
    except ValueError as error:
        if isinstance(error, GuardError):
            raise
    if any(ord(c) < 32 for c in unquote(part.path)):
        raise GuardError('invalid_path')
    pairs = parse_qsl(part.query, keep_blank_values=True, max_num_fields=10)
    if any(key not in settings['query_keys'] or len(value) > 128 for key, value in pairs):
        raise GuardError('query_not_approved')
    return urlunsplit(('https', host, part.path or '/', urlencode(sorted(pairs)), ''))


def searx_endpoint(url, allow_local=False):
    p = urlsplit(url)
    if p.username is not None or p.password is not None or p.path != '/search' or p.query or p.fragment:
        raise GuardError('invalid_searxng_endpoint')
    if p.hostname == '127.0.0.1' and p.scheme == 'http' and p.port and 1024 <= p.port <= 65535:
        if not allow_local:
            raise GuardError('local_searxng_needs_explicit_grant')
        return True
    if p.scheme != 'https' or p.port not in (None, 443) or not p.hostname:
        raise GuardError('invalid_searxng_endpoint')
    return False


class Budget:
    def __init__(self, settings):
        self.settings = settings
        self.started = time.monotonic()
        self.requests = self.bytes = 0
        self.last = {}

    def check(self):
        if time.monotonic() - self.started >= self.settings['max_seconds']:
            raise GuardError('time_budget')
        if self.requests >= self.settings['max_requests'] or self.bytes >= self.settings['max_bytes']:
            raise GuardError('request_or_byte_budget')

    def wait(self, host, delay=None):
        pause = max(self.settings['delay_seconds'], delay or 0)
        remaining = pause - (time.monotonic() - self.last.get(host, -1e9))
        if remaining > 0:
            time.sleep(min(remaining, self.settings['max_seconds']))
        self.check()
        self.last[host] = time.monotonic()


def public_address(value):
    ip = ipaddress.ip_address(value)
    return ip.is_global and not (ip.is_multicast or ip.is_reserved or ip.is_unspecified)


def public_ip(host, port):
    results = socket.getaddrinfo(host, port, type=socket.SOCK_STREAM)
    addresses = list(dict.fromkeys(item[4][0] for item in results))
    if not addresses or any(not public_address(ip) for ip in addresses):
        raise GuardError('dns_nonpublic_address')
    return addresses[0]


class Broker:
    def __init__(self, settings):
        self.settings, self.budget = settings, Budget(settings)

    def request(self, url, local_searx=False):
        self.budget.check()
        p = urlsplit(url)
        if local_searx:
            if not (p.hostname == '127.0.0.1' and p.scheme == 'http' and p.path == '/search' and p.port and 1024 <= p.port <= 65535):
                raise GuardError('invalid_local_exception')
            address = '127.0.0.1'
        else:
            if p.scheme != 'https' or p.port not in (None, 443) or p.username or p.password:
                raise GuardError('invalid_transport')
            address = public_ip(p.hostname, 443)
        self.budget.wait(p.hostname)
        self.budget.requests += 1
        port = p.port or (443 if p.scheme == 'https' else 80)
        connection = (http.client.HTTPSConnection(p.hostname, port, timeout=10, context=ssl.create_default_context())
                      if p.scheme == 'https' else http.client.HTTPConnection(p.hostname, port, timeout=10))
        # Pin the validated IP while keeping the original TLS hostname/SNI and certificate check.
        connection._create_connection = lambda _target, timeout, source_address=None: socket.create_connection((address, port), timeout, source_address)
        try:
            connection.request('GET', urlunsplit(('', '', p.path or '/', p.query, '')),
                               headers={'User-Agent': UA, 'Accept-Encoding': 'identity', 'Connection': 'close'})
            response = connection.getresponse()
            headers = {k.lower(): v for k, v in response.getheaders()}
            if headers.get('content-encoding', 'identity').lower() != 'identity':
                raise GuardError('compressed_response_rejected')
            size = min(MAX_BODY, self.settings['max_bytes'] - self.budget.bytes)
            body = response.read(size + 1)
            if len(body) > size:
                raise GuardError('response_size_limit')
            self.budget.bytes += len(body)
            return response.status, headers, body
        finally:
            connection.close()

    def fetch(self, url):
        for _ in range(4):
            url = normalize(url, self.settings)
            status, headers, body = self.request(url)
            if status in (301, 302, 303, 307, 308):
                target = normalize(urljoin(url, headers.get('location', '')), self.settings)
                if urlsplit(target).netloc != urlsplit(url).netloc:
                    raise GuardError('cross_origin_redirect')
                url = target
                continue
            if status == 429:
                retry = headers.get('retry-after', '')
                if retry.isdigit() and 1 <= int(retry) <= 10:
                    time.sleep(int(retry))
                    status, headers, body = self.request(url)
            return url, status, headers, body
        raise GuardError('redirect_limit')


class Document(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.block = 0
        self.in_title = False
        self.title, self.text, self.links = [], [], []

    def handle_starttag(self, tag, attrs):
        if tag in ('script', 'style', 'iframe', 'svg', 'form', 'noscript'):
            self.block += 1
        if self.block:
            return
        if tag == 'title':
            self.in_title = True
        if tag == 'a' and len(self.links) < 128:
            value = dict(attrs).get('href')
            if value:
                self.links.append(value)

    def handle_endtag(self, tag):
        if tag in ('script', 'style', 'iframe', 'svg', 'form', 'noscript') and self.block:
            self.block -= 1
        if tag == 'title':
            self.in_title = False

    def handle_data(self, value):
        if not self.block:
            (self.title if self.in_title else self.text).append(value)

    def result(self):
        return ' '.join(' '.join(self.title).split())[:512], ' '.join(' '.join(self.text).split())[:100000]


def private_dir(path, create=False):
    if not path.is_absolute() or path.resolve().is_relative_to(ROOT):
        raise GuardError('private_absolute_path_outside_repo_required')
    for component in [*reversed(path.parents), path]:
        if component.is_symlink() or (hasattr(component, 'is_junction') and component.is_junction()):
            raise GuardError('linked_path')
    if not path.exists() and create:
        path.mkdir(mode=0o700)
    info = path.stat()
    if not path.is_dir() or (os.name != 'nt' and (info.st_uid != os.getuid() or stat.S_IMODE(info.st_mode) & 0o077)):
        raise GuardError('unsafe_private_directory')
    return path


def database(workspace, create=False):
    private_dir(workspace, create)
    folder = private_dir(workspace / 'web_research', create)
    path = folder / 'index.sqlite3'
    exists = path.exists()
    for suffix in ('', '-journal', '-wal', '-shm'):
        candidate = Path(str(path) + suffix)
        if candidate.exists() or candidate.is_symlink():
            safe_file(candidate, 128 * 1024 ** 2)
            info = candidate.stat()
            if os.name != 'nt' and (info.st_uid != os.getuid() or stat.S_IMODE(info.st_mode) & 0o077):
                raise GuardError('unsafe_database_file')
    if not exists and not create:
        raise GuardError('database_absent')
    if exists:
        probe = sqlite3.connect(path.as_uri() + '?mode=ro', uri=True)
        try:
            if probe.execute('PRAGMA application_id').fetchone()[0] != APP_ID or probe.execute('PRAGMA user_version').fetchone()[0] != 1:
                raise GuardError('foreign_database')
        finally:
            probe.close()
    connection = sqlite3.connect(path.as_uri() + ('?mode=rw' if create and exists else '?mode=rwc' if create else '?mode=ro'), uri=True, timeout=2)
    connection.execute('PRAGMA trusted_schema=OFF')
    if not exists:
        path.chmod(0o600)
        connection.executescript(SCHEMA)
        connection.execute(f'PRAGMA application_id={APP_ID}')
        connection.execute('PRAGMA user_version=1')
        connection.commit()
    if create:
        page_size = connection.execute('PRAGMA page_size').fetchone()[0]
        connection.execute('PRAGMA max_page_count=' + str(128 * 1024 ** 2 // page_size))
    return connection


def store_page(db, url, final, title='', body='', status=0, source='seed', error=''):
    now = datetime.now(timezone.utc).isoformat()
    with db:
        db.execute('INSERT OR REPLACE INTO pages VALUES(?,?,?,?,?,?,?,?,?)',
                   (url, final, title, body, hashlib.sha256(body.encode()).hexdigest() if body else '', status, now, source, error))
        db.execute('DELETE FROM search WHERE url=?', (url,))
        if body and status == 200 and not error:
            db.execute('INSERT INTO search VALUES(?,?,?)', (url, title, body))


def robots(url, broker, cache):
    p = urlsplit(url)
    origin = urlunsplit((p.scheme, p.netloc, '', '', ''))
    if origin not in cache:
        final, status, _headers, body = broker.fetch(origin + '/robots.txt')
        if urlsplit(final).netloc != p.netloc:
            raise GuardError('cross_origin_robots')
        parser = RobotFileParser()
        if status == 404:
            parser.parse(['User-agent: *', 'Allow: /'])
        elif status == 200:
            parser.parse(body.decode('utf-8', errors='replace').splitlines())
        else:
            parser.parse(['User-agent: *', 'Disallow: /'])
        cache[origin] = parser
    parser = cache[origin]
    delay = parser.crawl_delay(UA)
    if delay:
        broker.budget.wait(p.hostname, delay)
    return parser.can_fetch(UA, url)


def discover(settings, broker, query, allow_local):
    endpoint = settings.get('searxng_url')
    if not endpoint or len(query) > 200:
        raise GuardError('searxng_endpoint_and_short_query_required')
    local = searx_endpoint(endpoint, allow_local)
    status, headers, data = broker.request(endpoint + '?' + urlencode({'q': query, 'format': 'json'}), local_searx=local)
    if status != 200 or 'application/json' not in headers.get('content-type', ''):
        raise GuardError('searxng_failed_or_json_disabled')
    results = json.loads(data).get('results', [])
    if not isinstance(results, list):
        raise GuardError('invalid_search_results')
    urls = []
    for row in results[:100]:
        try:
            urls.append(normalize(row['url'], settings))
        except (ValueError, KeyError, TypeError):
            continue
    return list(dict.fromkeys(urls))


def crawl(settings, workspace, query='', allow_local=False, extract=None, broker=None):
    os.umask(0o077)
    broker = broker or Broker(settings)
    db = database(workspace, create=True)
    count = blocked = errors = 0
    queue, visited, robot_cache = deque(), set(), {}
    reason = ''
    try:
        if shutil.disk_usage(workspace).free < 512 * 1024 ** 2:
            raise GuardError('insufficient_disk_reserve')
        seeds = settings['seeds'] + (discover(settings, broker, query, allow_local) if query else [])
        if not seeds:
            raise GuardError('no_allowed_seeds')
        queue.extend((url, 0, 'seed' if url in settings['seeds'] else 'searxng') for url in seeds)
        while queue and count < settings['max_pages']:
            url, depth, source = queue.popleft()
            if url in visited:
                continue
            visited.add(url)
            count += 1
            try:
                broker.budget.check()
                if shutil.disk_usage(workspace).free < 256 * 1024 ** 2:
                    raise GuardError('disk_reserve_exhausted')
                if not robots(url, broker, robot_cache):
                    store_page(db, url, url, source=source, error='robots_denied')
                    blocked += 1
                    continue
                final, status, headers, body = broker.fetch(url)
                if status != 200:
                    store_page(db, url, final, status=status, source=source, error='http_rejected')
                    blocked += 1
                    continue
                if 'text/html' not in headers.get('content-type', ''):
                    raise GuardError('html_required')
                document = Document()
                markup = body.decode('utf-8', errors='replace')
                document.feed(markup)
                title, text = document.result()
                if headers.get('cf-mitigated') == 'challenge' or title.casefold() in ('just a moment...', 'access denied'):
                    raise GuardError('challenge_page')
                if settings['extractor'] == 'crawl4ai':
                    if not extract:
                        raise GuardError('sandboxed_crawl4ai_required')
                    text = extract(final, markup)
                store_page(db, url, final, title, text, status, source)
                if depth < settings['max_depth']:
                    for href in document.links:
                        try:
                            link = normalize(urljoin(final, href), settings)
                            with db:
                                db.execute('INSERT OR IGNORE INTO links VALUES(?,?,?)', (link, final, depth + 1))
                            if link not in visited and len(queue) < 1000:
                                queue.append((link, depth + 1, final))
                        except ValueError:
                            continue
            except (OSError, ValueError, http.client.HTTPException) as error:
                reason = str(error) if isinstance(error, GuardError) else 'transport_or_parse_error'
                store_page(db, url, url, source=source, error=reason)
                errors += 1
                if reason in ('time_budget', 'request_or_byte_budget', 'disk_reserve_exhausted'):
                    break
    finally:
        db.close()
    return dict(visited=count, blocked=blocked, errors=errors, requests=broker.budget.requests,
                bytes=broker.budget.bytes, complete=not queue and not errors and not blocked,
                limit_reached=bool(queue), untrusted_web_content=True, stop_reason=reason)


def search(workspace, query):
    words = re.findall(r'\w+', query[:200])[:8]
    if not words:
        return []
    db = database(workspace)
    try:
        expression = ' AND '.join('"' + word + '"' for word in words)
        return [dict(url=r[0], title=r[1], excerpt=r[2], untrusted_web_content=True)
                for r in db.execute('SELECT url,title,snippet(search,2,\'\',\'\',\' ... \',24) FROM search WHERE search MATCH ? LIMIT 20', (expression,))]
    finally:
        db.close()


def csv_cell(value):
    value = str(value or '')
    return "'" + value if value[:1].isspace() or value.lstrip().startswith(('=', '+', '-', '@')) else value


def export(workspace, output):
    output = Path(output)
    private_dir(output.parent)
    db = database(workspace)
    temporary = None
    try:
        with tempfile.NamedTemporaryFile('w', dir=output.parent, encoding='utf-8-sig', newline='', delete=False) as stream:
            temporary = Path(stream.name)
            writer = csv.writer(stream, quoting=csv.QUOTE_ALL)
            writer.writerow(['url', 'final_url', 'title', 'sha256', 'http_status', 'fetched_at', 'source', 'error'])
            for row in db.execute('SELECT url,final_url,title,sha256,status,fetched_at,source,error FROM pages ORDER BY url LIMIT 10000'):
                writer.writerow([csv_cell(value) for value in row])
            stream.flush()
            os.fsync(stream.fileno())
        os.link(temporary, output)  # Atomic no-clobber publication, never overwrite a previous export.
    finally:
        db.close()
        if temporary:
            temporary.unlink(missing_ok=True)


def workspace_path(value=None):
    return Path(value or os.environ.get('OPENCLAW_USER_DATA_DIR', str(Path.home() / '.openclaw_ultimate_user_data')))


def supervise(args, settings):
    if sys.platform != 'linux':
        raise GuardError('crawl_requires_explicit_linux_shell_no_wsl_fallback')
    command = [sys.executable, '-I', '-B', str(Path(__file__).resolve()), '_worker', '--config', str(Path(args.config).resolve()),
               '--workspace', str(workspace_path(args.workspace)), '--apply', '--confirm-public-web']
    if args.query:
        command += ['--query', args.query]
    if args.allow_local_searxng:
        command.append('--allow-local-searxng')
    env = {k: v for k, v in os.environ.items() if k in ('PATH', 'HOME', 'LANG', 'LC_ALL')}
    process = subprocess.Popen(command, stdin=subprocess.DEVNULL, start_new_session=True, env=env)
    try:
        return process.wait(timeout=settings['max_seconds'] + 5)
    except (subprocess.TimeoutExpired, KeyboardInterrupt):
        if process.poll() is None:
            os.killpg(process.pid, signal.SIGTERM)
            try:
                process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait()
        print(json.dumps(dict(complete=False, partial=True, stop_reason='timeout_or_cancel', database_preserved=True)))
        return 2


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['plan', 'crawl', '_worker', 'search', 'export', 'doctor'])
    parser.add_argument('--config', default=str(ROOT / 'config/web_research.example.json'))
    parser.add_argument('--workspace')
    parser.add_argument('--query', default='')
    parser.add_argument('--output')
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--confirm-public-web', action='store_true')
    parser.add_argument('--allow-local-searxng', action='store_true')
    args = parser.parse_args(argv)
    if args.action in ('plan', 'crawl', '_worker'):
        settings = config(args.config)
        if args.action == 'plan' or not (args.apply and args.confirm_public_web):
            print(json.dumps(dict(executed=False, config=settings, default_database='WORKSPACE/web_research/index.sqlite3',
                                  instructions='crawl requires --apply --confirm-public-web; local SearXNG needs its separate flag')))
            return 0 if args.action == 'plan' else 2
        if args.action == 'crawl':
            return supervise(args, settings)
        import resource
        resource.setrlimit(resource.RLIMIT_AS, (768 * 1024 ** 2, 768 * 1024 ** 2))
        resource.setrlimit(resource.RLIMIT_CPU, (settings['max_seconds'], settings['max_seconds']))
        resource.setrlimit(resource.RLIMIT_NOFILE, (64, 64))
        extractor = None
        if settings['extractor'] == 'crawl4ai':
            sys.path.insert(0, str(Path(__file__).resolve().parent))
            from crawl4ai_adapter import extract
            extractor = lambda url, markup: extract(workspace_path(args.workspace), url, markup)
        result = crawl(settings, workspace_path(args.workspace), args.query, args.allow_local_searxng, extractor)
        print(json.dumps(result))
        return 1 if result['errors'] or result['blocked'] else 0
    if args.action == 'export':
        if not args.apply:
            print(json.dumps(dict(executed=False, action='export', no_input_read=True)))
            return 0
        if not args.output:
            raise GuardError('explicit_output_required')
        export(workspace_path(args.workspace), args.output)
        print(json.dumps(dict(exported=True, formula_cells_escaped=True)))
    elif args.action == 'search':
        print(json.dumps(search(workspace_path(args.workspace), args.query), ensure_ascii=True))
    elif args.action == 'doctor':
        db = database(workspace_path(args.workspace))
        try:
            ok = db.execute('PRAGMA quick_check').fetchone()[0] == 'ok'
            print(json.dumps(dict(database_ok=ok, pages=db.execute('SELECT COUNT(*) FROM pages').fetchone()[0], network_tested=False)))
            return 0 if ok else 1
        finally:
            db.close()
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, sqlite3.Error, http.client.HTTPException):
        print(json.dumps(dict(success=False, error='research_failed_check_configuration_or_local_fixture_diagnostics')), file=sys.stderr)
        sys.exit(1)
