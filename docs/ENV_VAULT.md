# Masterpassphrase und automatische ENV-Verwaltung

Fuer einen unabhaengigen Export von Tresor und ausgewaehlten ENV-Dateien nach
Windows, einschliesslich isolierter Wiederherstellung und optionalem Mailversand:
[Zugangsdaten-Backup](CREDENTIALS_BACKUP.md), **Optionen -> 21 -> 5**.

## Was ist das?

Ein lokaler, mit [age](https://github.com/FiloSottile/age) verschluesselter Tresor
fuer Zugangsdaten aller registrierten Programme. Eine Masterpassphrase schuetzt
den Tresor; **sie ist kein Universalpasswort fuer die Programme**. Pro Dienst
eigene Tokens/Passwoerter verwenden. Keine Keys werden bei Cloudanbietern erzeugt.

Speicherorte auf dem Zielsystem:

| Datei | Inhalt |
|---|---|
| `~/.openclaw_ultimate_user_data/backups/credentials/env-vault.age` | Verschluesselte Werte und ENV-Zuordnungen |
| `~/.openclaw_ultimate_user_data/env/<tool-id>/.env` | Bewusst erzeugte Klartext-Konfiguration, Modus 0600 |

Die Masterpassphrase wird weder gespeichert noch als Argument/Variable an age
uebergeben. age liest sie interaktiv vom Terminal. Seine Meldungen gehen direkt
ans Terminal, nicht in Installer-Logs. Verlorene Passphrase = kein Wiederherstellen!
Die Passphrase separat sicher verwahren, nicht neben dem Backup.

## Voraussetzungen

Linux/WSL, Python >=3.10, age und ein interaktives Terminal. Keine automatische
Installation dieser Abhaengigkeiten. age nach seiner offiziellen
[Installationsanleitung](https://github.com/FiloSottile/age#installation) bewusst
bereitstellen, beispielsweise aus den offiziellen GitHub-Releases mit deren
Pruefanleitung. Das Modul braucht keine Python-Zusatzpakete und keinen Server.
Windows ist in dieser ersten Version nur Testumgebung, nicht freigegebener
produktiver Tresorbetrieb. Unter Windows bieten chmod-Rechte keinen ACL-Ersatz.

## Einfacher Einstieg

Im Setup **Optionen -> 19: Verschluesselter ENV-Tresor** waehlen. Alternativ:

```bash
python3 scripts/security/env_vault.py init
python3 scripts/security/env_vault.py set openclaw_token
python3 scripts/security/env_vault.py bind openclaw OPENCLAW_GATEWAY_TOKEN openclaw_token
python3 scripts/security/env_vault.py render openclaw
python3 scripts/security/env_vault.py render openclaw --apply
```

1. Bei `init` eine lange, eigene Masterpassphrase festlegen.
2. Bei `set` den bereits vorhandenen echten Token unsichtbar eingeben und bestaetigen.
3. `bind` ordnet den Tresoreintrag einem konkreten ENV-Feld zu.
4. `render` zeigt nur Feldnamen, keine geheimen Werte und schreibt keine ENV-Datei.
5. `--apply` erzeugt die vorbereitete ENV im User-Workspace. Bestehende Datei wird
   abgelehnt; `--apply --replace` erlaubt ein bewusstes Ersetzen.

Bei jedem Aendern: age fragt erst nach der bisherigen Passphrase zum Lesen und
danach nach der Passphrase zum erneuten Speichern. **Dieselbe Masterpassphrase
wieder eingeben**, sofern nicht bewusst rotiert werden soll. Nicht leer bestaetigen
und eine von age gegebenenfalls generierte Passphrase nicht verlieren.
`set NAME --replace` erlaubt das bewusste Ersetzen eines gespeicherten Werts.
Danach betroffene ENV-Dateien erneut erzeugen; laufende Dienste aendern sich nicht.

## Alle Programme, aber keine erfundenen ENV-Felder

```bash
python3 scripts/security/env_vault.py catalog
python3 scripts/security/env_vault.py status
```

Der Katalog liest alle Tool-IDs aus `config/tools.yml`, auch geplante Tools.
Vorhandene `.env.example` unter config/, tools/ oder stacks/ werden erkannt.
Fuer andere Programme eine gepruefte Vorlage bewusst angeben:

```bash
python3 scripts/security/env_vault.py render supabase --template /path/to/.env.example
python3 scripts/security/env_vault.py render supabase --template /path/to/.env.example --apply
```

Vorher die benoetigten Felder per `bind` zuordnen. Das Modul unterstuetzt alle
registrierten IDs, **aber nicht automatisch jede spezielle Programmsyntax**.
Nur uebliche `NAME=WERT`-dotenv-Vorlagen, Kommentare und Leerzeilen. Keine
Shell-Ausfuehrung, kein Sourcing. Doppelte Felder, fehlende Zuordnungsziele und
unbekannte Werte fuehren zum Abbruch. Nicht zugeordnete Vorgaben bleiben stehen;
Pflichtfelder/Platzhalter muessen weiterhin vom Benutzer geprueft werden.

Eingesetzte Werte werden einfach gequotet, sodass z.B. `$` nicht interpoliert
wird, siehe [Compose-ENV-Syntax](https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/#env-file-syntax).
Steuerzeichen, Apostroph und Backslash in eingesetzten Werten werden derzeit
bewusst abgelehnt statt moeglicherweise falsch escaped. Keine TOML-/JSON-/YAML-
oder PEM-Ausgabe in Version 1. Import privater SSH-Schluessel ist nicht vorgesehen.

## Verwendung durch das eigentliche Programm

Das Modul erzeugt **vorbereitete ENV-Dateien**, aendert aber keine laufenden
Programme und schreibt nichts nach `/opt`. Nicht alle alten Installer lesen
diesen Ort bereits automatisch. Je Tool eine gepruefte Anbindung konfigurieren,
etwa Compose `--env-file` oder die passende Anwendungskonfiguration. Eine
Compose-ENV ersetzt ausserdem keine im YAML hart codierten Zugangsdaten.
Kein pauschales Kopieren ueber bestehende produktive Konfigurationen!

Agenten/OpenClaw erhalten keinen autonomen Tresorzugriff. Kein Hintergrund-
Entsperren, kein Klartext-Masterkey, keine automatische API-/Kostenaktivierung.
Ein Tresor beseitigt auch keine unsicheren Standardpasswoerter in alten Stacks.

## Backup und Restore

`bash scripts/backup.sh` nimmt den verschluesselten Tresor explizit in
`<backup-stempel>/credentials/env-vault.age` auf. Der User-Ordner `env/` mit
generierten Klartextdateien wird ausgeschlossen. **Andere Workspace-Dateien
koennen weiterhin Secrets enthalten**; das gesamte bestehende Backup ist damit
nicht automatisch verschluesselt. Externe Backups zusaetzlich verschluesseln.

Restore: Mit gestoppten Tresorvorgaengen die verschluesselte Datei bewusst nach
`backups/credentials/env-vault.age` im neuen User-Workspace zuruecklegen,
Verzeichnisrechte 0700/Dateirechte 0600 sicherstellen, Passphrase bereithalten
und zuerst eine ENV-Vorschau testen. Keine Passphrase aus dem Backup erforderlich
oder enthalten. Restore muss auf einem separaten Testsystem geprueft werden.

Parallelzugriffe werden per exklusivem Lock abgelehnt. Nach Absturz einen
verbliebenen `.vault.lock` erst nach Prozesspruefung manuell entfernen. Symlink-
Pfade und ein User-Workspace innerhalb des Repositories werden abgelehnt.
Der entschluesselte Tresor liegt kurz im Prozessspeicher: kein Schutz gegen
Root, kompromittiertes Benutzerkonto, Speicherabbilder oder unverschluesselten Swap.

## Tests und Grenzen

`python3 -m unittest discover -s tests -p 'test_env_vault.py'` prueft Dateisystem-
Grenzen, Vorschau und Rendering mit Testwerten/Mock-Verschluesselung. Kein
echtes Geheimnis wird erzeugt. Interaktiver age-Roundtrip und echter Restore
sind vor produktivem Einsatz noch am Zielsystem zu testen.
