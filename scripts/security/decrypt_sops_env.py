"""SOPS-age-ENV kontrolliert in den privaten Workspace schreiben, niemals ausfuehren."""
import argparse
import json
import os
from pathlib import Path
import re
import secrets
import stat
import subprocess
import sys

ALLOWED_KEYS = {'OPENCLAW_GATEWAY_TOKEN', 'OPENAI_API_KEY', 'OPENAI_BASE_URL',
                'ANTHROPIC_API_KEY', 'GEMINI_API_KEY', 'MANUS_API_KEY'}


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError('Doppelter JSON-Schluessel.')
        result[key] = value
    return result


def envelope(path):
    path = Path(path)
    if path.is_symlink() or not path.is_file() or path.stat().st_size > 1048576:
        raise ValueError('Regulaere kleine Ciphertext-Datei erforderlich.')
    data = json.loads(path.read_text(encoding='utf-8'), object_pairs_hook=unique_object)
    if not isinstance(data, dict) or set(data) != {'data', 'sops'}:
        raise ValueError('SOPS-Binary-JSON-Huelle erforderlich.')
    metadata = data['sops']
    if not isinstance(data['data'], str) or not data['data'].startswith('ENC[AES256_GCM,') or not isinstance(metadata, dict):
        raise ValueError('Kein erwarteter SOPS-Ciphertext.')
    # Keine fremden Cloud-/Vault-/PGP-Schluesseldienste durch Dateimetadaten ausloesen.
    allowed_metadata = {'age', 'lastmodified', 'mac', 'version', 'unencrypted_suffix',
                        'encrypted_suffix', 'unencrypted_regex', 'encrypted_regex',
                        'unencrypted_comment_regex', 'encrypted_comment_regex',
                        'mac_only_encrypted', 'shamir_threshold', 'kms', 'gcp_kms',
                        'azure_kv', 'hc_vault', 'pgp', 'hckms', 'key_groups'}
    if set(metadata) - allowed_metadata:
        raise ValueError('Unbekannte SOPS-Metadaten zuerst separat pruefen.')
    for field in ('kms', 'gcp_kms', 'azure_kv', 'hc_vault', 'pgp', 'hckms', 'key_groups'):
        if metadata.get(field):
            raise ValueError('Hier ist ausschliesslich lokales age erlaubt.')
    age = metadata.get('age')
    if not isinstance(age, list) or not age:
        raise ValueError('age-Empfaenger fehlt.')
    for recipient in age:
        if not isinstance(recipient, dict) or not re.fullmatch(r'age1[a-z0-9]{50,}', recipient.get('recipient', '')):
            raise ValueError('Nur normale lokale age-Empfaenger erlaubt.')
    return path


def validate_env(payload):
    text = payload.decode('utf-8')
    if len(payload) > 65536:
        raise ValueError('ENV-Ausgabe zu gross.')
    seen = set()
    for line in text.splitlines():
        if not line or line.startswith('#'):
            continue
        key, separator, value = line.partition('=')
        if not separator or key not in ALLOWED_KEYS or key in seen:
            raise ValueError('ENV-Feld ungueltig, nicht erlaubt oder doppelt.')
        if not re.fullmatch(r'[A-Za-z0-9._:/@+=,%!#&?*-]*', value) or 'REPLACE' in value:
            raise ValueError('Nur einfache literale Werte ohne Expansion/Platzhalter erlaubt.')
        seen.add(key)
    if not seen:
        raise ValueError('Keine erlaubten ENV-Felder.')
    return payload


def private_file(path):
    info = path.lstat()
    if not stat.S_ISREG(info.st_mode) or info.st_uid != os.getuid() or stat.S_IMODE(info.st_mode) != 0o600:
        raise ValueError('age-Identitaet muss regulaer, eigen und 0600 sein.')


def decrypt_to_workspace(ciphertext, identity, workspace, name, executable='sops'):
    if sys.platform != 'linux':
        raise ValueError('Schreibmodus nur fuer Linux/WSL.')
    ciphertext = envelope(ciphertext)
    workspace, identity = Path(workspace), Path(identity)
    if not workspace.is_absolute() or workspace.is_symlink() or not workspace.is_dir():
        raise ValueError('Bestehender privater absoluter User-Workspace erforderlich.')
    info = workspace.stat()
    if info.st_uid != os.getuid() or stat.S_IMODE(info.st_mode) != 0o700:
        raise ValueError('Workspace muss eigen und 0700 sein.')
    if not identity.is_absolute() or identity.is_relative_to(workspace.resolve()) or identity.resolve().is_relative_to(workspace.resolve()):
        raise ValueError('age-Identitaet ausserhalb des Backups/Workspace halten.')
    private_file(identity)
    if not re.fullmatch(r'[a-zA-Z0-9][a-zA-Z0-9_.-]{0,80}\.env', name):
        raise ValueError('Einfacher ENV-Dateiname erforderlich.')
    # Kein geerbter Cloud-Key, keyservice, BASH_ENV oder SOPS-Hook.
    env = {'PATH': os.environ.get('PATH', '/usr/bin:/bin'), 'HOME': str(Path.home()),
           'SOPS_AGE_KEY_FILE': str(identity)}
    result = subprocess.run([executable, 'decrypt', '--input-type', 'binary', '--output-type', 'binary', str(ciphertext)],
                            env=env, capture_output=True, timeout=60, check=False)
    if result.returncode:
        raise ValueError('SOPS-Entschluesselung/MAC-Pruefung fehlgeschlagen; keine Ausgabe uebernommen.')
    payload = validate_env(result.stdout)
    root_fd = os.open(workspace, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
    secret_fd = None
    stage = '.decrypt-' + secrets.token_hex(12)
    try:
        try:
            os.mkdir('secrets', 0o700, dir_fd=root_fd)
        except FileExistsError:
            pass
        secret_fd = os.open('secrets', os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW, dir_fd=root_fd)
        info = os.fstat(secret_fd)
        if info.st_uid != os.getuid() or stat.S_IMODE(info.st_mode) != 0o700:
            raise ValueError('Secret-Verzeichnis muss eigen und 0700 sein.')
        fd = os.open(stage, os.O_WRONLY | os.O_CREAT | os.O_EXCL | os.O_NOFOLLOW, 0o600, dir_fd=secret_fd)
        with os.fdopen(fd, 'wb') as output:
            output.write(payload)
            output.flush()
            os.fsync(output.fileno())
        # Atomare Neuanlage, niemals bestehende Secrets oder Symlinks ersetzen.
        os.link(stage, name, src_dir_fd=secret_fd, dst_dir_fd=secret_fd, follow_symlinks=False)
    finally:
        if secret_fd is not None:
            try:
                os.unlink(stage, dir_fd=secret_fd)
            except FileNotFoundError:
                pass
            os.close(secret_fd)
        os.close(root_fd)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--encrypted', type=Path, required=True)
    parser.add_argument('--identity', type=Path, required=True)
    parser.add_argument('--workspace', type=Path, default=Path.home() / '.openclaw_ultimate_user_data')
    parser.add_argument('--name', default='core.env')
    parser.add_argument('--apply', action='store_true')
    args = parser.parse_args()
    try:
        envelope(args.encrypted)
        if args.apply:
            decrypt_to_workspace(args.encrypted, args.identity, args.workspace, args.name)
            print('ENV privat mit 0600 angelegt; keine Werte angezeigt oder ausgefuehrt.')
        else:
            print('Nur age-Ciphertext-Struktur geprueft; keine Entschluesselung oder Dateiaenderung.')
    except (ValueError, OSError, TypeError, KeyError, subprocess.SubprocessError):
        print('SOPS-ENV abgebrochen; Pfade, Rechte und Format pruefen. Keine Secret-Werte ausgegeben.', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
