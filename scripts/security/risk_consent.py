"""Per-action interactive risk acknowledgement; no persisted approvals or environment bypass."""
import argparse
import sys


def risks(subject):
    subject = subject.lower().replace('-', '_').replace(' ', '_')
    result = []
    if any(word in subject for word in ('trading', 'zenbot', 'web3', 'exchange_api')):
        result.append('finance-paper-only')
    if any(word in subject for word in ('voice_clone', 'coqui', 'openvoice', 'rvc')):
        result.append('voice-consent-and-disclosure')
    if any(word in subject for word in ('avatar', 'deepfake')) or subject == 'emo':
        result.append('synthetic-media-disclosure')
    if any(word in subject for word in ('personnel', 'personalakten')):
        result.append('sensitive-personal-data')
    return result


def approve(tags, stream, interactive):
    if not tags:
        return True
    # No verified paper-mode execution contract exists for these legacy finance paths.
    if 'finance-paper-only' in tags or not interactive:
        return False
    required = 'ACK:' + ','.join(tags)
    print('Hochrisiko: ' + ', '.join(tags) + '. Nur eigene/freigegebene Daten und Stimmen verwenden.')
    print('Einmalige Freigabe eingeben: ' + required + ' [Enter: Nein]')
    return stream.readline().rstrip('\r\n') == required


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--subject', required=True)
    args = parser.parse_args(argv)
    tags = risks(args.subject)
    if approve(tags, sys.stdin, sys.stdin.isatty()):
        return 0
    print('Risikofreigabe fehlt oder Finanz-/Paper-Vertrag ungeprueft; keine Installation.', file=sys.stderr)
    return 3


if __name__ == '__main__':
    sys.exit(main())
