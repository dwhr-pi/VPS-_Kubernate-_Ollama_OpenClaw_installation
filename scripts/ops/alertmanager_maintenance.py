"""Scoped opt-in Alertmanager operations; plans do not contact any service."""
import argparse
from datetime import datetime, timedelta, timezone
import ipaddress
import json
import re
import sys
from urllib.parse import urlsplit
from urllib.request import HTTPRedirectHandler, ProxyHandler, Request, build_opener
import uuid


class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        raise ValueError('Redirect forbidden.')


def endpoint(value):
    url = urlsplit(value)
    if (url.scheme not in ('http', 'https') or url.username is not None or url.password is not None
            or url.path not in ('', '/') or url.query or url.fragment or not url.hostname):
        raise ValueError('Loopback HTTP(S) base required; use an approved SSH tunnel.')
    if not ipaddress.ip_address(url.hostname).is_loopback:
        raise ValueError('Only loopback endpoints allowed.')
    if url.port is not None and not 1 <= url.port <= 65535:
        raise ValueError('Invalid port.')
    return value.rstrip('/')


def scoped_payload(cluster, namespace, job, minutes=30, now=None):
    for value in (cluster, namespace, job):
        if not isinstance(value, str) or not re.fullmatch(r'[a-zA-Z0-9][a-zA-Z0-9_.-]{0,62}', value):
            raise ValueError('Exact bounded cluster, namespace and job required.')
    if type(minutes) is not int or not 1 <= minutes <= 60:
        raise ValueError('Silence must expire in 1 to 60 minutes.')
    now = now or datetime.now(timezone.utc)
    if now.tzinfo is None or now.utcoffset() != timedelta(0):
        raise ValueError('UTC clock required.')
    return {
        'matchers': [{'name': key, 'value': value, 'isRegex': False, 'isEqual': True}
                     for key, value in [('cluster', cluster), ('namespace', namespace), ('job', job)]],
        'startsAt': now.isoformat().replace('+00:00', 'Z'),
        'endsAt': (now + timedelta(minutes=minutes)).isoformat().replace('+00:00', 'Z'),
        'createdBy': 'openclaw-maintenance-operator',
        'comment': 'Explicit scoped maintenance; no deployment or restart performed.',
    }


def perform(base, action, payload, silence_id=None, opener=None):
    base = endpoint(base)
    if action == 'cancel':
        silence_id = str(uuid.UUID(silence_id))
        path, method, data = '/api/v2/silence/' + silence_id, 'DELETE', None
    else:
        path = '/api/v2/silences' if action == 'silence' else '/api/v2/alerts'
        method, data = 'POST', json.dumps(payload).encode('utf-8')
    request = Request(base + path, data=data, headers={'Content-Type': 'application/json'}, method=method)
    opener = opener or build_opener(ProxyHandler({}), NoRedirect())
    try:
        with opener.open(request, timeout=10) as response:
            if response.status != 200:
                raise ValueError('Alertmanager did not acknowledge operation.')
            raw = response.read(65537)
        if len(raw) > 65536:
            raise ValueError('Oversized response.')
        if action == 'silence':
            identifier = str(uuid.UUID(json.loads(raw)['silenceID']))
            return {'acknowledged': True, 'silence_id': identifier, 'discord_delivery_verified': False}
        return {'acknowledged': True, 'discord_delivery_verified': False}
    except Exception:
        # Do not hide a failed mutation or include backend bodies in logs.
        raise ValueError('Alertmanager operation not verified; inspect private monitoring.') from None


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=('silence', 'test-alert', 'cancel'))
    parser.add_argument('--cluster')
    parser.add_argument('--namespace')
    parser.add_argument('--job')
    parser.add_argument('--minutes', type=int, default=30)
    parser.add_argument('--silence-id')
    parser.add_argument('--url', default='http://127.0.0.1:9093')
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--confirm')
    args = parser.parse_args(argv)
    try:
        endpoint(args.url)
        if args.action == 'cancel':
            identifier = str(uuid.UUID(args.silence_id))
            payload, confirmation = None, 'cancel:' + identifier
        else:
            payload = scoped_payload(args.cluster, args.namespace, args.job, args.minutes)
            confirmation = args.action + ':' + ':'.join((args.cluster, args.namespace, args.job))
            if args.action == 'test-alert':
                payload = [{'labels': {'alertname': 'OpenClawManualTest', 'severity': 'critical',
                                      'cluster': args.cluster, 'namespace': args.namespace, 'job': args.job},
                            'startsAt': payload['startsAt'], 'endsAt': payload['endsAt'],
                            'annotations': {'summary': 'Explicit operator test; no real failure inferred.'}}]
        if not args.apply:
            print(json.dumps({'executed': False, 'action': args.action, 'payload': payload,
                              'required_confirmation': confirmation}, indent=2))
            return 0
        if args.confirm != confirmation:
            raise ValueError('Exact action-specific confirmation required.')
        print(json.dumps(perform(args.url, args.action, payload, args.silence_id)))
        return 0
    except (ValueError, TypeError, AttributeError):
        print('Maintenance rejected or unverified; no update, cleanup or restart performed.', file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
