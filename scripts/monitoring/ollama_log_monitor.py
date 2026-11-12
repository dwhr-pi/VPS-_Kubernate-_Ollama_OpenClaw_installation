"""Opt-in bounded kubectl log polling; emit categories, never raw application logs."""
import argparse
import json
import os
from pathlib import Path
import re
import stat
import subprocess
import sys
import time
from urllib.error import HTTPError, URLError
from urllib.request import HTTPRedirectHandler, ProxyHandler, Request, build_opener

PATTERNS = {
    'gpu-memory': re.compile(r'cuda out of memory|out of memory.*cuda', re.I),
    'oom-killed': re.compile(r'\boomkilled\b', re.I),
    'crash': re.compile(r'\bpanic\b|segmentation fault|\bfatal\b', re.I),
    'model-load': re.compile(r'failed to load model', re.I),
    'error': re.compile(r'\berror\b', re.I),
}
LABEL = r'[a-zA-Z0-9](?:[a-zA-Z0-9_.-]{0,61}[a-zA-Z0-9])?'
WEBHOOK = re.compile(r'https://discord\.com/api/webhooks/[0-9]{10,25}/[A-Za-z0-9_.-]{20,200}')


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        raise ValueError('Webhook redirects are forbidden.')


def classify(text):
    if not isinstance(text, str) or len(text.encode('utf-8')) > 65536:
        raise ValueError('Log snapshot exceeds limit.')
    return [key for key, pattern in PATTERNS.items() if pattern.search(text)]


def command(context, namespace, selector, container):
    if not re.fullmatch(r'[a-z0-9][a-z0-9-]{0,62}', namespace):
        raise ValueError('Invalid namespace.')
    if (not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_.:@/-]{0,127}', context)
            or not re.fullmatch(LABEL + '=' + LABEL, selector)
            or not re.fullmatch(r'[a-z0-9][a-z0-9-]{0,62}', container)):
        raise ValueError('Invalid context, equality selector or container.')
    return ['kubectl', '--context', context, '--namespace', namespace,
            '--request-timeout=15s', 'logs', '--selector', selector,
            '--container', container, '--tail=100', '--since=60s',
            '--limit-bytes=65536', '--timestamps=true', '--max-log-requests=1']


def snapshot(args, runner=subprocess.run):
    # kubectl bounds the response; stderr may contain credentials, so discard it.
    allowed = {'path', 'home', 'user', 'logname', 'kubeconfig', 'systemroot',
               'windir', 'tmp', 'temp', 'lang', 'lc_all', 'xdg_cache_home'}
    env = {key: value for key, value in os.environ.items() if key.casefold() in allowed}
    result = runner(args, stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                    stderr=subprocess.DEVNULL, timeout=20, check=False, env=env)
    if result.returncode or len(result.stdout) > 65536:
        raise ValueError('Kubernetes log snapshot unavailable.')
    return classify(result.stdout.decode('utf-8', errors='replace'))


def read_webhook(path):
    path = Path(os.path.abspath(path))
    for item in (path, *path.parents):
        if item.is_symlink() or (hasattr(item, 'is_junction') and item.is_junction()):
            raise ValueError('Linked credential paths are forbidden.')
    fd = os.open(path, os.O_RDONLY | getattr(os, 'O_NOFOLLOW', 0))
    with os.fdopen(fd, 'rb') as stream:
        info = os.fstat(stream.fileno())
        if not stat.S_ISREG(info.st_mode) or info.st_size > 2048:
            raise ValueError('Credential must be a small regular file.')
        if os.name != 'nt' and (info.st_mode & 0o077 or info.st_uid != os.geteuid()):
            raise ValueError('Credential must be owned by this user with mode 0600 or stricter.')
        raw = stream.read(2049)
    if len(raw) > 2048:
        raise ValueError('Credential too large.')
    url = raw.decode('ascii').strip()
    if not WEBHOOK.fullmatch(url):
        raise ValueError('Expected native Discord HTTPS webhook, without query or /slack.')
    return url


def notify(url, category, opener=None):
    if not WEBHOOK.fullmatch(url) or category not in PATTERNS:
        raise ValueError('Invalid notification destination or category.')
    payload = json.dumps({'content': 'OpenClaw Ollama monitor: ' + category,
                          'allowed_mentions': {'parse': []}}).encode('utf-8')
    request = Request(url, data=payload, headers={'Content-Type': 'application/json'}, method='POST')
    opener = opener or build_opener(ProxyHandler({}), NoRedirect())
    try:
        with opener.open(request, timeout=10) as response:
            return response.status in (200, 204)
    except (HTTPError, URLError, OSError, ValueError):
        return False  # Never expose exception text, URLs, tokens or response bodies.


def monitor(args, *, duration, interval, cooldown, url=None,
            clock=time.monotonic, sleep=time.sleep, poll=snapshot, send=notify):
    deadline, next_allowed, failures = clock() + duration, {}, 0
    failed = False
    while clock() < deadline:
        try:
            categories = poll(args)
            failures = 0
            for category in categories:
                now = clock()
                if now < next_allowed.get(category, float('-inf')):
                    continue
                # Failed delivery also consumes cooldown; no provider retry storms.
                next_allowed[category] = now + cooldown
                delivered = send(url, category) if url else None
                failed = failed or delivered is False
                print(json.dumps({'category': category, 'discord_delivery': delivered}), flush=True)
        except (OSError, subprocess.SubprocessError, ValueError):
            failed = True
            failures = min(5, failures + 1)
            print('{"monitor_error":"snapshot-unavailable"}', flush=True)
        remaining = deadline - clock()
        if remaining > 0:
            sleep(min(remaining, interval * 2**failures, 300))
    return 1 if failed else 0


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--context')
    parser.add_argument('--namespace', default='llmops')
    parser.add_argument('--selector', default='app=ollama')
    parser.add_argument('--container', default='ollama')
    parser.add_argument('--watch', action='store_true')
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--send-discord', action='store_true')
    parser.add_argument('--webhook-file')
    parser.add_argument('--duration', type=int, default=300)
    parser.add_argument('--interval', type=int, default=30)
    parser.add_argument('--cooldown', type=int, default=300)
    args = parser.parse_args(argv)
    if not (1 <= args.duration <= 86400 and 10 <= args.interval <= 300
            and 60 <= args.cooldown <= 86400):
        parser.error('Invalid bounded timing options.')
    if not args.watch:
        if args.apply or args.send_discord or args.webhook_file:
            parser.error('Runtime options require --watch --apply.')
        print('{"scope":"plan","executed":false,"discord":false,"docker":false}')
        return 0
    if not args.apply or not args.context:
        parser.error('Monitoring requires --watch --apply and an explicit --context.')
    if bool(args.send_discord) != bool(args.webhook_file):
        parser.error('Discord requires both --send-discord and --webhook-file.')
    try:
        cmd = command(args.context, args.namespace, args.selector, args.container)
        url = read_webhook(args.webhook_file) if args.send_discord else None
        return monitor(cmd, duration=args.duration, interval=args.interval,
                       cooldown=args.cooldown, url=url)
    except KeyboardInterrupt:
        return 130
    except (OSError, UnicodeError, ValueError):
        print('Monitor configuration unavailable; no details logged.', file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
