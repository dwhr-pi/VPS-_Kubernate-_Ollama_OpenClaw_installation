# ENV-Dateien und API-Keys gesondert sichern

## Zweck und Einstieg

Dieser Export sichert bewusst ausgewaehlte Dateien mit Zugangsdaten getrennt vom
[Programminventar](INSTALLATION_STATUS_BACKUP.md). Installierte Programme, Statuslisten und
Zugangsdaten sind verschiedene Sicherungsgegenstaende. Der normale Backup-Lauf nimmt weiterhin keine
Klartext-Dateien aus `env/` auf. Der neue Export ist manuell gestartet, kein automatischer Mailjob.

**Optionen -> 21 -> 5: ENV / API-Keys**, alternativ:

```bash
bash scripts/credentials_backup_menu.sh
```

Voraussetzungen: Linux/WSL, Python >=3.10, interaktives Terminal und
[age aus offizieller Quelle](https://github.com/FiloSottile/age). Keine automatische Docker-,
Paket-, SMTP- oder Dienstinstallation. Die age-Abfrage des vorhandenen [ENV-Tresors](ENV_VAULT.md)
wird wiederverwendet.

## TAR, ZIP und Passwort

**TAR hat keinen eingebauten Passwortschutz.** Hier wird das TAR als Ganzes mit `age --passphrase`
verschluesselt: `zugangsdaten.tar.age`. Die Passphrase fragt age direkt am Terminal ab. Sie wird
nicht in Argumenten, Einstellungen oder E-Mails gespeichert. Leere Eingabe kann age eine zufaellige
Passphrase erzeugen lassen: unbedingt separat sicher verwahren. Verlorene Passphrase bedeutet keine
Wiederherstellung! Der mitgesicherte ENV-Tresor kann eine andere Passphrase besitzen; dann werden
beide benoetigt.

ZIP ist hier nicht implementiert. Altes ZIP/ZipCrypto ist fuer API-Keys ungeeignet. Fuer einen
manuellen Windows-Workflow bietet das [offizielle 7-Zip](https://www.7-zip.org/7z.html) AES-256 im
7z-Format. `.tar.age` ist jedoch kein 7-Zip-Passwortarchiv.

## Auswahl und Einstellungen

Untermenue **1** fragt relative Workspace-Dateien/-Ordner, Absender, Empfaenger und optionalen
Hinweis ab. Beispielauswahl:

```text
env,backups/credentials/env-vault.age
```

Weitere Dateien mit API-Keys bewusst hinzufuegen. Keine automatische Vollsuche: Keys ausserhalb der
Auswahl, in Browsern, Kubernetes Secrets, Keystores oder Prozessvariablen sind nicht automatisch
gesichert. Ganze `tools/` und `backups/` sind ausgeschlossen; nur der konkrete ENV-Tresor ist dort
erlaubt. Jeder ausgewaehlte Pfad muss existieren, sonst Abbruch statt stiller Teilsicherung.

`~/.openclaw_ultimate_user_data/credential-backup-settings.json` enthaelt:

| Feld                  | Inhalt                                                       |
| --------------------- | ------------------------------------------------------------ |
| `paths`               | Bewusst ausgewaehlte relative Quellen                        |
| `sender`, `recipient` | Optionaler Absender und frei waehlbare Zieladresse           |
| `hint`                | Optionaler Hinweis, leer empfohlen; niemals Passwort/Antwort |
| `version`             | Formatversion                                                |

Diese Einstellungen werden **im verschluesselten Archiv mitgesichert** und isoliert
wiederhergestellt. Lokal sind sie Klartext-Metadaten (0600). SMTP-Passwort und Archivpassphrase
werden dort nicht gespeichert. Bestehende Einstellungen bewusst lokal in der JSON-Datei bearbeiten,
kein automatisches Ueberschreiben. Importierte Adressen/Auswahl vor neuer Nutzung kontrollieren.

## Export nach Windows oder extern

Untermenue **2** verlangt einen neuen absoluten Zielpfad ausserhalb von Repository und Workspace,
etwa `/mnt/d/Setup-Sicherung/zugangsdaten.tar.age`.

```bash
python3 -B scripts/security/credentials_backup.py configure
python3 -B scripts/security/credentials_backup.py export \
  --output /mnt/d/Setup-Sicherung/zugangsdaten.tar.age
```

Nur verschluesselte Bytes werden auf Disk geschrieben; das TAR entsteht im RAM. Grenze: 500 Dateien,
32 MiB Dateiinhalte. Kein Modell-/Datenbank-/Vollsystembackup. Swap, Core-Dumps und ein
kompromittierter laufender Host sind nicht geschuetzt. Schreibende Dienste/Agenten vorher stoppen:
kein atomarer Snapshot gleichzeitig veraenderter Dateien. Bei Platzmangel/Abbruch kann eine
unvollstaendige Ausgabe bleiben; kein Erfolg wird gemeldet, alte Dateien werden nicht
ueberschrieben.

Windows-Mountrechte ersetzen keine Linux-0600-Rechte: nur verschluesselte Exporte dort ablegen,
ACLs/BitLocker ergaenzend nutzen. Ein zweiter Ordner auf derselben Platte schuetzt nicht vor deren
Ausfall. Getrennte USB-/NAS-/Offsite-Kopie vorhalten.

### Benoetigte Software

| Aufgabe                 | Windows                                         | Linux / WSL                                  |
| ----------------------- | ----------------------------------------------- | -------------------------------------------- |
| `.age` entschluesseln   | Offizielles age fuer Windows                    | Offizielles age fuer Linux                   |
| TAR-Dateinamen anzeigen | `tar.exe`, falls vorhanden, oder 7-Zip          | `tar`                                        |
| Einzelne Datei ansehen  | TAR in 7-Zip oeffnen, bekannten Eintrag ansehen | `tar -xOf ...` mit privatem Pager wie `less` |
| Sicherer Setup-Restore  | Ubuntu/WSL mit Python und Linux-age             | Python >=3.10 und age, Setup-Helfer          |

age nur aus [offiziellen GitHub-Releases](https://github.com/FiloSottile/age/releases) fuer das
passende System/CPU beziehen und die dortigen Pruefhinweise beachten. Die
[offizielle Installation/Bedienung](https://github.com/FiloSottile/age#installation) beschreibt die
Voraussetzungen. age in den PATH aufnehmen oder den absoluten Pfad zur passenden Binaerdatei
verwenden. Windows-age installiert nicht zugleich age in WSL. 7-Zip nur von
[7-zip.org](https://www.7-zip.org/) beziehen. **7-Zip und tar allein koennen `.tar.age` nicht
entschluesseln.** Zuerst age, dann TAR.

## Windows nach WSL zurueckspielen

1. Anhang etwa als `D:\Setup-Sicherung\credentials.tar.age` speichern. Die E-Mail verwendet diesen
   Beispielnamen; bei anderem Namen Befehle anpassen.
2. In PowerShell Distribution ermitteln und starten:

   ```powershell
   wsl --list --verbose
   wsl -d Ubuntu
   ```

   `Ubuntu` durch den angezeigten Namen ersetzen, etwa `Ubuntu-24.04`. **Alle folgenden
   Bash-/Python-Befehle in der Linux-Shell ausfuehren**, nicht direkt in PowerShell. Bei
   Standard-WSL-Mounts ist `D:\Setup-Sicherung\credentials.tar.age` unter
   `/mnt/d/Setup-Sicherung/credentials.tar.age` verfuegbar; fuer C: `/mnt/c/`. Bei eigener
   Mount-Konfiguration den tatsaechlichen Pfad verwenden.
   [Microsoft beschreibt die Laufwerkszuordnung und WSL-Aufrufe](https://learn.microsoft.com/en-us/windows/wsl/filesystems).

3. Das Setup aus vertrauenswuerdiger Quelle bereitstellen, in dessen Repository- Ordner wechseln und
   Python/age in WSL pruefen:

   ```bash
   python3 --version
   age --version
   ```

4. Die unten angegebenen `check`-/`restore`-Befehle verwenden, dabei als `--input`
   `/mnt/d/Setup-Sicherung/credentials.tar.age` und als Ziel `"$HOME/credentials-recovery-neu"`
   einsetzen. Der verschluesselte Anhang muss dafuer nicht nach Linux kopiert werden. **Klartext
   dagegen im Linux-Home** wiederherstellen, nicht unter `/mnt/d/`.
5. Dateien pruefen und erst danach wie unter **Kontrolliert aktivieren** beschrieben gezielt in den
   Workspace uebernehmen. Ein Linux-/WSL-Neuaufsetzen ist fuer diesen Restore nicht erforderlich;
   geloeschte Programme installiert er nicht.

## Nur Linux: Anhang einspielen

Den verschluesselten Anhang z.B. nach `$HOME/Downloads/credentials.tar.age` herunterladen oder vom
Backupmedium dorthin kopieren. Bei einem VPS ohne GUI einen authentifizierten Dateitransfer wie SFTP
verwenden, keine oeffentliche URL. Dann im vertrauenswuerdigen Setup-Repository die gleichen
folgenden Befehle verwenden, aber `--input "$HOME/Downloads/credentials.tar.age"` einsetzen. `$HOME`
bezeichnet den Benutzer, der spaeter den Workspace besitzen soll: nicht unnoetig als root/sudo
wiederherstellen.

## Wiederherstellung und Pruefung

**3** prueft Entschluesselung/Manifest/Hashes ohne Dateiausgabe. **4** schreibt nach Bestaetigung in
einen **neuen privaten Linux-Ordner**, nie automatisch ueber aktive Konfigurationen. Kein
Dienststart, keine API-Anfrage und keine Tokenrotation.

```bash
python3 -B scripts/security/credentials_backup.py check \
  --input /mnt/d/Setup-Sicherung/zugangsdaten.tar.age \
  --output /home/ubuntu/credentials-recovery-neu
python3 -B scripts/security/credentials_backup.py restore \
  --input /mnt/d/Setup-Sicherung/zugangsdaten.tar.age \
  --output /home/ubuntu/credentials-recovery-neu --confirm-restore
```

Ziel darf noch nicht existieren; `/mnt/` ist fuer Klartext-Restore gesperrt. Pruefungen blockieren
Pfadtraversal, doppelte Eintraege, Links/Sonderdateien, Uebergroesse und falsche Hashes. Kein
`tar.extractall`, kein Shell-Ausfuehren. Bei Schreibfehlern kann der neue Ordner teilweise gefuellt
sein; dann liegt keine vollstaendige Wiederherstellung vor. Dateien lokal pruefen und bewusst an
ihren vorgesehenen Ort uebernehmen. Importierte `.env` **nicht automatisch sourcen**: sie koennte
Shell-Code enthalten. Hashes beweisen nicht die Identitaet des Absenders.

### Kontrolliert aktivieren

Die folgenden Beispiele sind **manuelle Verwaltungsbefehle**, keine automatisch ausgefuehrte
Importlogik. Sie setzen einen erfolgreich geprueften Recovery-Ordner voraus. Vorher betroffene
Dienste/Agenten stoppen. Dateien lokal vertraulich ansehen; nur erwartete Konfiguration uebernehmen,
keine fremden Symlinks verwenden.

1. Pfade und konkrete Tool-ID festlegen (`mein-tool` ersetzen):

   ```bash
   umask 077
   RECOVERY="$HOME/credentials-recovery-neu"
   WORKSPACE="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}"
   TOOL_ID='mein-tool'
   ```

2. Falls eine aktive ENV vorhanden ist, zuerst eine private Sicherung erstellen:

   ```bash
   BEFORE=$(mktemp -d "$HOME/credentials-before.XXXXXX")
   if [ -f "$WORKSPACE/env/$TOOL_ID/.env" ]; then
       cp --preserve=mode,timestamps -- "$WORKSPACE/env/$TOOL_ID/.env" "$BEFORE/previous.env"
   fi
   ```

3. Nur diese ENV uebernehmen. `cp -i` fragt bei einer bestehenden Zieldatei nach:

   ```bash
   install -d -m 700 -- "$WORKSPACE/env/$TOOL_ID"
   cp -i -- "$RECOVERY/env/$TOOL_ID/.env" "$WORKSPACE/env/$TOOL_ID/.env"
   chmod 600 -- "$WORKSPACE/env/$TOOL_ID/.env"
   ```

   Als richtiger Linux-Benutzer ausfuehren, Eigentum/Dateityp mit `stat` kontrollieren. Die Dateirechte
   muessen 0600, die privaten Ordnerrechte 0700 sein. Bei abgelehntem Kopieren bleibt die alte ENV
   aktiv. Keine pauschale rekursive Kopie ueber den gesamten Workspace und kein `source`/`eval` auf
   importierte Dateien!

4. Fuer den Tresor ist der relative Zielpfad `backups/credentials/env-vault.age`. Vorhandenen Tresor
   ebenfalls vorher in einen privaten Sicherungsordner kopieren; dann bewusst mit `cp -i`
   uebernehmen:

   ```bash
   install -d -m 700 -- "$WORKSPACE/backups/credentials"
   cp -i -- "$RECOVERY/backups/credentials/env-vault.age" "$WORKSPACE/backups/credentials/env-vault.age"
   chmod 600 -- "$WORKSPACE/backups/credentials/env-vault.age"
   ```

   Nur ausfuehren, wenn der Tresor in der Auswahl enthalten war. Seine eigene Masterpassphrase bleibt
   gueltig; die Archivpassphrase ersetzt sie nicht. `python3 -B scripts/security/env_vault.py status`
   prueft nur das Vorhandensein, nicht die Entschluesselbarkeit. Anschliessend den Tresor ueber das
   bekannte [ENV-Tresor-Menue](ENV_VAULT.md) bewusst verwenden; vorhandene ENV nicht blind neu rendern.

5. `credential-backup-settings.json` kann nach Kontrolle der Pfade, Absender- und Empfaengeradresse
   ebenfalls an denselben relativen Workspace-Pfad kopiert werden (bestehende Datei vorher sichern,
   `cp -i`, Modus 0600). Keine Mail allein durch diesen Import versenden. Weitere ausgewaehlte
   Dateien einzeln ihrem dokumentierten Dienst zuordnen. Erst danach bewusst Dienste starten;
   geaenderte Schluessel ggf. beim Anbieter separat pruefen/rotieren. Der Zugangsdaten-Restore setzt
   keine Programme auf installiert und stellt keine Datenbanken/Modelle her.

## Ohne Setup manuell entschluesseln und einsehen

### Linux / WSL

Ein neuer privater Ordner verhindert, dass alte Klartextdateien ueberschrieben werden:

```bash
umask 077
VIEW_DIR=$(mktemp -d "$HOME/credentials-view.XXXXXX")
age --decrypt --output "$VIEW_DIR/credentials.tar" /pfad/zur/credentials.tar.age
tar -tf "$VIEW_DIR/credentials.tar"
```

Den Archivpfad ersetzen. age fragt die Passphrase am Terminal ab. Bei einem Fehler **nicht
fortfahren**; eine eventuell unvollstaendige Ausgabe nicht als Backup nutzen. `tar -tf` listet nur
Namen auf, nicht die Schluesselwerte. Den bekannten eigenen Eintrag gezielt lesen (Tool-ID
anpassen):

```bash
tar -xOf "$VIEW_DIR/credentials.tar" env/mein-tool/.env | less
```

`q` beendet `less`. Eintrag fehlt? Dann war er nicht in der Sicherung ausgewaehlt. Nicht in
aufgezeichneten Terminals/Remote-Sitzungen oder Screen-Sharing verwenden. Das TAR ist nun
**Klartext**. Keinen ungeprueften Komplett-Extract in den Workspace ausfuehren: die manuelle Ansicht
ersetzt nicht Manifest-/Hash-/Pfadpruefungen des Setup-Helfers. Ein TAR kann fremde Links oder
gefaehrliche Pfade enthalten.

### Windows ohne WSL

Einen neuen privaten, nicht synchronisierten Ordner auf einem geschuetzten Datentraeger anlegen und
PowerShell dort oeffnen. `credentials.tar` darf noch nicht existieren. age muss im PATH sein, sonst
den absoluten Programmpfad verwenden:

```powershell
age --decrypt --output credentials.tar "D:\Setup-Sicherung\credentials.tar.age"
if ($LASTEXITCODE -ne 0) { throw "Entschluesselung fehlgeschlagen" }
tar -tf credentials.tar
```

Wenn `tar` nicht vorhanden ist, das entschluesselte TAR im offiziellen 7-Zip oeffnen. Bekannte
Eintraege dort gezielt ansehen; nicht alles ungeprueft in aktive Ordner entpacken. Auch
Editor-/7-Zip-Vorschau kann private Temporaerdateien erzeugen. Das Klartext-TAR und eventuelle
Extraktionen nicht in Git, OneDrive, Mail, Zwischenablage oder Screenshots weitergeben. Zum
Aufspielen nach WSL am besten weiterhin das **verschluesselte Original** mit dem WSL-Restore
verwenden, statt Klartextdateien von Windows zurueckzukopieren: Linux-Rechte/Eigentuemer muessen
dort kontrolliert gesetzt werden.

Private Klartext-Pruefkopien nach erfolgreicher Kontrolle bewusst entfernen. Loeschen garantiert auf
SSDs, Snapshots, Swap und Sicherungen keine vollstaendige Datenvernichtung; geschuetzte Datentraeger
und getrennte Aufbewahrung bleiben wichtig.

## E-Mail: Entwurf oder ausdruecklich bestaetigter Versand

**5** erzeugt eine `.eml` mit verschluesseltem Anhang zum Oeffnen in einem geeigneten
Windows-Mailprogramm. Empfaenger pruefen und dort bewusst senden; eine EML-Datei ist kein
Zustellnachweis. **6** sendet nach Bestaetigung ueber einen bereits separat konfigurierten
`msmtp`-Standardaccount an die gespeicherte Adresse. TLS + STARTTLS werden erzwungen. Fuer
implizites TLS auf Port 465 stattdessen EML/passenden Client verwenden. SMTP-Zugangsdaten verbleiben
im vorhandenen Client.

```bash
python3 -B scripts/security/credentials_backup.py draft \
  --input /mnt/d/Setup-Sicherung/zugangsdaten.tar.age \
  --output /mnt/d/Setup-Sicherung/backup-mail.eml
python3 -B scripts/security/credentials_backup.py send \
  --input /mnt/d/Setup-Sicherung/zugangsdaten.tar.age --confirm-send
```

Maximal 15 MiB Anhang; Base64 vergroessert die Mail. Anbieter koennen verschluesselte Anhaenge
blockieren. Erfolg bedeutet SMTP-Uebergabe, **nicht Zustellung**. Bei Timeout zuerst
Postausgang/Zielpostfach pruefen, nicht blind erneut versenden. Betreff, Adressen und Hinweis sind
fuer Mailanbieter sichtbar; Inhalt und Dateinamen im TAR sind verschluesselt. Der EML-Entwurf
enthaelt diese Metadaten ebenfalls im Klartext und sollte privat aufbewahrt werden.

Sowohl EML-Entwurf als auch direkter SMTP-Versand enthalten diese Bedienhinweise im **Mailtext
selbst**: Softwarequellen, Windows-/WSL-/Linux-Befehle, manuelle TAR-Ansicht, Rueckuebernahme in den
Workspace und Warnungen vor Klartextkopien. So bleiben grundlegende Restore-Schritte auch ohne
Zugriff auf das Repository verfuegbar. Die Anleitung enthaelt keine Passphrase und aktiviert nichts
automatisch. Die Mail enthaelt ausserdem einen direkten Link zur
[Online-Dokumentation auf GitHub](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/blob/main/docs/CREDENTIALS_BACKUP.md).
Dieser zeigt den veroeffentlichten Stand auf `main`; lokale Aenderungen sind erst nach ihrer
Veroeffentlichung dort sichtbar. Bestehende EML-Dateien/Mails werden nicht nachtraeglich geaendert;
einen neuen Entwurf erstellen.

## Erinnerungsfragen: Grenzen und unsichere Beispiele

**Empfehlung: Hinweis leer lassen, lange zufaellige Passphrase im Passwortmanager aufbewahren und
ueber einen getrennten sicheren Kanal teilen.** Anhang und Passwort im gleichen Postfach erlauben
jedem mit Postfachzugriff die Entschluesselung. Eine zweite Adresse ist nicht automatisch ein
unabhaengiger Sicherheitskanal.

Vom Nutzer genannte Beispiele, **nicht als sichere Passwortbasis empfohlen**:

| Frage                                     | Risiko                                              |
| ----------------------------------------- | --------------------------------------------------- |
| Wann wurdest Du geboren?                  | Wenige moegliche Antworten, oft oeffentlich bekannt |
| Wie lautet der Name Deiner Mutter?        | Ueber Familie/soziale Netzwerke recherchierbar      |
| Selbst definierter Fragesatz als Passwort | Ein mitgesendeter Satz ist kein Geheimnis           |

Ein eigener optionaler Hinweis kann auf den **separat verwahrten Passwortmanager- Eintrag**
verweisen, darf aber weder Passphrase noch erratbare Antworten verraten. Die Antwort auf eine
Erinnerungsfrage wird nicht gespeichert. Technisch kann ein Fragesatz als Passphrase gewaehlt
werden: **Wird derselbe Satz als Hinweis in der Mail mitgeschickt, ist das unsicher und hebt
praktisch den Passwortschutz auf.** Es gibt daher kein eigenes Passwort-im-Mail-Feld. Das Setup kann
nicht erkennen, ob ein freier Hinweis die bei age gewaehlte Passphrase verraet; die Kontrolle bleibt
beim Nutzer.

[NIST zu wissensbasierten Sicherheitsfragen](https://pages.nist.gov/800-63-FAQ/),
[OWASP zu passwortverratenden Hinweisen](https://cheatsheetseries.owasp.org/cheatsheets/Choosing_and_Using_Security_Questions_Cheat_Sheet.html).

## Abnahmestand

Fixture-Tests pruefen Auswahl, Archivformat, Pfade/Integritaet, isolierten Restore und Mailfreigaben
ohne echte Zugangsdaten. Kryptographie liefert age, keine eigene Implementierung. Interaktiver
age-Roundtrip, SMTP-Zustellung und Windows-Mailclient sind auf dem Zielsystem separat abzunehmen.
Tests senden keine E-Mails und lesen keine persoenlichen Schluessel.
