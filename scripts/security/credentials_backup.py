#!/usr/bin/env python3
"""Explicit credential selection, encrypted TAR export and isolated recovery."""
import argparse
from email.message import EmailMessage
from email.policy import SMTP
import hashlib
import io
import json
import os
from pathlib import Path, PurePosixPath
import re
import shutil
import subprocess
import sys
import tarfile

from env_vault import Workspace, VaultError, age_run, no_symlinks

LIMIT = 32 * 1024**2
SETTINGS = 'credential-backup-settings.json'

# Keep recovery instructions in the message itself, not only behind a web link.
RECOVERY_GUIDE = r'''
ANLEITUNG: credentials.tar.age entschluesseln und wieder einspielen

1. Software und Bedeutung
Die Endung .age bedeutet Verschluesselung; darin steckt ein normales TAR.
7-Zip/Windows-tar allein koennen die age-Schicht nicht entschluesseln.
age fuer Windows/Linux ausschliesslich aus der offiziellen Quelle beziehen:
https://github.com/FiloSottile/age#installation
https://github.com/FiloSottile/age/releases
Passendes Betriebssystem/Prozessor waehlen und die dortigen Pruefhinweise beachten.
Fuer TAR: Windows tar.exe (falls vorhanden), 7-Zip von https://www.7-zip.org/
oder tar unter Linux. age muss im PATH sein, sonst seinen absoluten Pfad verwenden.
Die Passphrase kommt separat, NICHT in dieser Mail. Vergessen = kein Restore.
Eine zusaetzliche Passphrase des enthaltenen env-vault.age bleibt erforderlich.

2. Windows -> WSL (empfohlener Weg)
Anhang als D:\Setup-Sicherung\credentials.tar.age speichern (Beispielpfad).
PowerShell: wsl --list --verbose
Dann: wsl -d Ubuntu
Den tatsaechlichen Distributionsnamen statt Ubuntu einsetzen. Ab hier Linux-Shell!
D:\Setup-Sicherung\credentials.tar.age liegt bei Standard-Mounts unter
/mnt/d/Setup-Sicherung/credentials.tar.age. Andere Laufwerke entsprechend anpassen.
Der verschluesselte Anhang darf dort bleiben; Klartext nur im privaten WSL-Home.
Setup aus vertrauenswuerdiger Quelle bereitstellen und in seinen Repo-Ordner gehen.
Python 3.10+ und age muessen in WSL vorhanden sein, Windows-age allein reicht nicht.

Pruefen (schreibt noch keine Dateien, Ziel darf nicht existieren):
python3 -B scripts/security/credentials_backup.py check --input /mnt/d/Setup-Sicherung/credentials.tar.age --output "$HOME/credentials-recovery-neu"
Isoliert wiederherstellen (fragt die Passphrase erneut):
python3 -B scripts/security/credentials_backup.py restore --input /mnt/d/Setup-Sicherung/credentials.tar.age --output "$HOME/credentials-recovery-neu" --confirm-restore
Alternativ im Setup: Optionen -> 21 -> 5 -> 3 (pruefen) oder 4 (Restore).

3. Nur Linux, ohne Windows
Den verschluesselten Anhang z.B. unter $HOME/Downloads/credentials.tar.age ablegen.
Die gleichen check-/restore-Befehle verwenden; --input dabei auf
"$HOME/Downloads/credentials.tar.age" aendern. Ziel bleibt ein neuer privater
Linux-Ordner. Die Wiederherstellung startet keine Dienste und importiert nichts
automatisch in aktive Konfigurationen. Sie enthaelt nur die ausgewaehlten Dateien,
keine Programme, Modelle oder komplette WSL-Installation.

4. Manuell ansehen, auch ohne installiertes Setup
Unter Linux/WSL im Terminal (nicht im Git-Ordner):
umask 077
VIEW_DIR=$(mktemp -d "$HOME/credentials-view.XXXXXX")
age --decrypt --output "$VIEW_DIR/credentials.tar" /pfad/zur/credentials.tar.age
tar -tf "$VIEW_DIR/credentials.tar"
Der letzte Befehl zeigt nur Dateinamen. Einen bekannten Eintrag gezielt ansehen:
tar -xOf "$VIEW_DIR/credentials.tar" env/mein-tool/.env | less
mein-tool und Archivpfad anpassen. 'q' beendet less. less/Terminal nur ohne
Sitzungsaufzeichnung benutzen: der Inhalt enthaelt echte Schluessel!

Alternativ Windows-PowerShell, in einem neuen privaten, nicht synchronisierten
Ordner auf geschuetztem Datentraeger (Dateiname darf nicht existieren):
age --decrypt --output credentials.tar "D:\Setup-Sicherung\credentials.tar.age"
if ($LASTEXITCODE -ne 0) { throw "Entschluesselung fehlgeschlagen" }
tar -tf credentials.tar
Das TAR kann jetzt mit 7-Zip geoeffnet und ein bekannter Eintrag eingesehen werden.
Das entschluesselte TAR und extrahierte Dateien sind KLARTEXT. Nicht in OneDrive,
Mail, Git, Screenshots oder Logs kopieren. Fremde Archive niemals blind komplett
entpacken; fuer Restore die Pfad-/Hash-Pruefung des Setup-Helfers bevorzugen.

5. Aus dem Recovery-Ordner in das Setup uebernehmen
Dienste/Agenten zuerst stoppen. Recovery-Dateien privat pruefen, keine .env sourcen.
Ausgewaehlte relative Pfade bleiben erhalten, z.B. env/mein-tool/.env.
Das Ziel ist normalerweise ~/.openclaw_ultimate_user_data; bei eigener
OPENCLAW_USER_DATA_DIR-Konfiguration gilt stattdessen dieser Workspace.
Vorhandene aktive Dateien vorher separat privat sichern. Dann nur die benoetigten
Dateien bewusst uebernehmen, z.B. env/mein-tool/.env an denselben relativen Pfad.
Ordnerrechte 0700, Dateirechte 0600 und den richtigen Linux-Eigentuemer sicherstellen.
backups/credentials/env-vault.age ist der verschluesselte Tresor, keine .env-Datei.
credential-backup-settings.json enthaelt Versandeinstellungen: Adressen und Auswahl
vor einer weiteren Mail pruefen. Nicht unbesehen ueber bestehende Einstellungen kopieren.
Die Wiederherstellung allein setzt keine Programme auf 'installiert'. Dienste erst
nach lokaler Pruefung bewusst wieder starten. Keine automatischen API-Tests.

Ausfuehrliche Befehle zum kontrollierten Uebernehmen stehen im vertrauenswuerdigen
Setup unter docs/CREDENTIALS_BACKUP.md und online hier:
https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/blob/main/docs/CREDENTIALS_BACKUP.md
Der Online-Stand entspricht dem veroeffentlichten main-Branch und kann von dieser
Mail abweichen. Passphrase, Schluessel und Klartextdateien
nicht in Antworten auf diese Mail schicken. Private Pruefkopien nach erfolgreicher
Kontrolle bewusst entfernen; Loeschen garantiert auf SSDs/Backups keine Datenvernichtung.
'''


def relative(value):
    path = PurePosixPath(value)
    if (not value or path.is_absolute() or '..' in path.parts or
            '\\' in value or ':' in value or any(ord(c) < 32 for c in value) or
            str(path) != value or value == '.'):
        raise VaultError('Nur normale relative Workspace-Pfade erlaubt.')
    return path


def read_bounded(path):
    no_symlinks(path)
    if not path.is_file() or path.stat().st_nlink != 1 or path.stat().st_size > LIMIT:
        raise VaultError('Datei fehlt, ist verlinkt oder zu gross.')
    with path.open('rb') as stream:
        data = stream.read(LIMIT + 1)
    if len(data) > LIMIT:
        raise VaultError('Dateigroessenlimit ueberschritten.')
    return data


def new_file(path, data):
    no_symlinks(path)
    path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    with path.open('xb') as stream:
        os.chmod(path, 0o600)
        stream.write(data)
        stream.flush()
        os.fsync(stream.fileno())


def settings_check(data):
    if not isinstance(data, dict) or set(data) != {'version', 'paths', 'recipient', 'sender', 'hint'} or data['version'] != 1:
        raise VaultError('Unbekanntes Einstellungsformat.')
    if not isinstance(data['paths'], list) or not 1 <= len(data['paths']) <= 100:
        raise VaultError('1 bis 100 ausgewaehlte Dateien/Ordner erforderlich.')
    for item in data['paths']:
        relative(item)
        if item == SETTINGS or item.startswith(('tools/', 'backups/')) and item != 'backups/credentials/env-vault.age':
            raise VaultError('Builds/Backups nicht pauschal sichern; nur env-vault.age ist hier erlaubt.')
    for field in ('sender', 'recipient'):
        value = data[field]
        if not isinstance(value, str) or value and not re.fullmatch(r'[A-Za-z0-9_.+%-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', value):
            raise VaultError('Ungueltige E-Mail-Adresse.')
    if not isinstance(data['hint'], str) or len(data['hint']) > 300 or any(ord(c) < 32 for c in data['hint']):
        raise VaultError('Hinweis muss ein kurzer einzeiliger Text sein, kein Passwort.')
    return data


def load_settings(root):
    return settings_check(json.loads(read_bounded(root / SETTINGS)))


def pack(root, settings):
    settings_check(settings)
    files = {}
    total = 0
    for selected in settings['paths']:
        path = root / str(relative(selected))
        no_symlinks(path)
        if not path.exists():
            raise VaultError('Ausgewaehlter Pfad fehlt; keine unvollstaendige Sicherung.')
        candidates = path.rglob('*') if path.is_dir() else [path]
        for candidate in candidates:
            no_symlinks(candidate)
            if candidate.is_dir():
                continue
            name = candidate.relative_to(root).as_posix()
            if name in files:
                continue
            if len(files) >= 500:
                raise VaultError('Hoechstens 500 Dateien pro Export.')
            content = read_bounded(candidate)
            total += len(content)
            if total > LIMIT:
                raise VaultError('Hoechstens 32 MiB Klartext pro Export.')
            files[name] = content
    if not files:
        raise VaultError('Auswahl enthaelt keine Dateien.')
    files[SETTINGS] = json.dumps(settings, ensure_ascii=True).encode()
    manifest = {'format': 'openclaw-credentials', 'version': 1,
                'files': {name: hashlib.sha256(content).hexdigest() for name, content in files.items()}}
    if 'manifest.json' in files:
        raise VaultError('manifest.json ist reserviert.')
    files['manifest.json'] = json.dumps(manifest).encode()
    buffer = io.BytesIO()
    with tarfile.open(fileobj=buffer, mode='w', format=tarfile.USTAR_FORMAT) as archive:
        for name, content in files.items():
            entry = tarfile.TarInfo(name)
            entry.size, entry.mode = len(content), 0o600
            archive.addfile(entry, io.BytesIO(content))
    return buffer.getvalue()


def unpack(payload):
    if len(payload) > LIMIT + 2 * 1024**2:
        raise VaultError('Archiv zu gross.')
    files = {}
    with tarfile.open(fileobj=io.BytesIO(payload), mode='r:') as archive:
        total = 0
        for item in archive:
            relative(item.name)
            if not item.isfile() or item.name in files or len(files) > 501 or item.size < 0:
                raise VaultError('Links, Sonderdateien oder doppelte Eintraege nicht erlaubt.')
            total += item.size
            if total > LIMIT + 1024**2:
                raise VaultError('Archivinhalt zu gross.')
            files[item.name] = archive.extractfile(item).read()
    if 'manifest.json' not in files or SETTINGS not in files:
        raise VaultError('Manifest oder Einstellungen fehlen.')
    manifest = json.loads(files.pop('manifest.json'))
    if (manifest.get('format') != 'openclaw-credentials' or manifest.get('version') != 1 or
            manifest.get('files') != {name: hashlib.sha256(data).hexdigest() for name, data in files.items()}):
        raise VaultError('Manifest-/Integritaetspruefung fehlgeschlagen.')
    settings_check(json.loads(files[SETTINGS]))
    return files


def export(root, target):
    no_symlinks(target)
    if not target.is_absolute() or target.is_relative_to(root) or target.exists() or not target.name.endswith('.tar.age'):
        raise VaultError('Neues absolutes .tar.age-Ziel ausserhalb des Workspace waehlen.')
    Workspace(target.parent)  # Also reject repository destinations.
    content = pack(root, load_settings(root))
    encrypted = age_run(['--passphrase'], content)
    new_file(target, encrypted)
    print('Verschluesselter Export geschrieben. Keine Klartext-TAR auf Disk; separat sicher aufbewahren.')


def recover(source, target, apply=False):
    encrypted = read_bounded(source)
    # Validate a private Linux destination before decrypting or writing secrets.
    no_symlinks(target)
    if not target.is_absolute() or target.exists():
        raise VaultError('Neuen absoluten Wiederherstellungsordner waehlen.')
    target = target.resolve()
    Workspace(target)
    if str(target).startswith('/mnt/'):
        raise VaultError('Klartext-Wiederherstellung nur im privaten Linux-Dateisystem, nicht /mnt/.')
    files = unpack(age_run(['--decrypt'], encrypted))
    print('Gepruefte Dateien:', len(files), '(keine Werte angezeigt).')
    if not apply:
        print('Nur Pruefung. --confirm-restore schreibt in den neuen Ordner, nie in aktive Konfigurationen.')
        return
    target.mkdir(parents=True, mode=0o700)
    for name, content in files.items():
        new_file(target / name, content)
    print('Isoliert wiederhergestellt. Dateien lokal pruefen; nichts sourcen oder automatisch aktivieren.')


def mail(archive, settings, destination=None, confirmed=False):
    settings_check(settings)
    if not settings['sender'] or not settings['recipient']:
        raise VaultError('Absender und Empfaenger zuerst konfigurieren.')
    content = read_bounded(archive)
    if not archive.name.endswith('.tar.age') or not content.startswith(b'age-encryption.org/v1\n') or len(content) > 15 * 1024**2:
        raise VaultError('Nur age-Archiv bis 15 MiB als Anhang erlaubt.')
    message = EmailMessage(policy=SMTP)
    message['From'], message['To'] = settings['sender'], settings['recipient']
    message['Subject'] = 'Verschluesseltes Setup-Zugangsdaten-Backup'
    message.set_content('Verschluesseltes TAR-Archiv. Passphrase separat uebermitteln.\n'
                        'Optionaler Hinweis (nicht das Passwort): ' + settings['hint'] + '\n'
                        'Empfaenger/Absender/Hinweis sind fuer Mailanbieter sichtbar.\n' + RECOVERY_GUIDE)
    message.add_attachment(content, maintype='application', subtype='octet-stream', filename='credentials.tar.age')
    if destination is not None:
        if not destination.is_absolute() or destination.suffix != '.eml':
            raise VaultError('Neuer absoluter .eml-Zielpfad erforderlich.')
        Workspace(destination.parent)
        new_file(destination, message.as_bytes())
        print('EML erstellt. Im Mailprogramm Empfaenger und Hinweis pruefen, dann bewusst senden.')
    elif confirmed:
        executable = shutil.which('msmtp')
        if not executable:
            raise VaultError('msmtp fehlt; vorhandenen SMTP-Account separat sicher konfigurieren oder EML verwenden.')
        result = subprocess.run([executable, '--tls=on', '--tls-starttls=on', '--tls-certcheck=on', '--', settings['recipient']],
                                input=message.as_bytes(), stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=90)
        if result.returncode:
            raise VaultError('SMTP-Uebergabe fehlgeschlagen/unklar; vor Wiederholung Postausgang pruefen.')
        print('An SMTP uebergeben; keine Garantie fuer Zustellung. Kein Passwort mitgesendet.')
    else:
        raise VaultError('Versand braucht --confirm-send; keine Mail versendet.')


def configure(root):
    if not sys.stdin.isatty():
        raise VaultError('Konfiguration braucht ein Terminal.')
    print('Nur ausgewaehlte Workspace-Dateien! Beispiel: env oder backups/credentials/env-vault.age')
    print('API-Keys in anderen Dateien bewusst per relativem Pfad hinzufuegen; keine automatische Vollsuche.')
    paths = input('Relative Pfade, mit Komma getrennt: ').split(',')
    print('Hinweis wird bei E-Mail offen mitgesendet. KEIN Passwort oder leicht erratbare Antwort eintragen.')
    data = settings_check({'version': 1, 'paths': [x.strip() for x in paths],
                           'sender': input('Absender (optional): ').strip(),
                           'recipient': input('Empfaenger (optional): ').strip(),
                           'hint': input('Optionaler nicht-verratender Hinweis (leer empfohlen): ').strip()})
    root.mkdir(parents=True, exist_ok=True, mode=0o700)
    target = root / SETTINGS
    if target.exists():
        raise VaultError('Einstellungen bestehen bereits; lokal bewusst bearbeiten, kein Ueberschreiben.')
    new_file(target, json.dumps(data, indent=2).encode())
    print('Einstellungen gespeichert; werden im verschluesselten Archiv mitgesichert, kein Passwort gespeichert.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['configure', 'settings', 'export', 'check', 'restore', 'draft', 'send'])
    parser.add_argument('--input', type=Path)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--confirm-restore', action='store_true')
    parser.add_argument('--confirm-send', action='store_true')
    args = parser.parse_args()
    os.umask(0o077)
    try:
        root = Workspace().root
        if root == Path(root.anchor):
            raise VaultError('Workspace darf keine Dateisystemwurzel sein.')
        if args.action == 'configure':
            configure(root)
        elif args.action == 'settings':
            settings = load_settings(root)
            print('Absender:', settings['sender'], '| Empfaenger:', settings['recipient'])
            print('Optionaler Hinweis wird in der Mail sichtbar; Inhalt lokal in den Einstellungen pruefen.')
        elif args.action == 'export' and args.output:
            export(root, args.output)
        elif args.action in ('check', 'restore') and args.input and args.output:
            recover(args.input, args.output, args.action == 'restore' and args.confirm_restore)
        elif args.action in ('draft', 'send') and args.input:
            if args.action == 'draft' and not args.output:
                raise VaultError('EML-Ziel --output fehlt.')
            mail(args.input, load_settings(root), args.output if args.action == 'draft' else None, args.confirm_send)
        else:
            raise VaultError('Erforderliche --input/--output fehlen; --help verwenden.')
        return 0
    except (VaultError, OSError, ValueError, TypeError, KeyError, tarfile.TarError, subprocess.SubprocessError):
        print('Zugangsdaten-Backup abgebrochen/fehlgeschlagen. Pfade, Format, age, Platz und Freigabe pruefen. '
              'Kein Erfolgsnachweis; teilweise Ausgaben ggf. vorhanden. Keine geheimen Werte ausgegeben.', file=sys.stderr)
        return 1
    except (EOFError, KeyboardInterrupt):
        print('Abgebrochen; kein automatischer Versand.', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
