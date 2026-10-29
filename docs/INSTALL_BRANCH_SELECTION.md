# Branch fuer den Entwicklungs-Installer waehlen

Die Auswahl gilt nur fuer den **ausdruecklich freigegebenen unsignierten**
Entwicklungsweg. Sie ersetzt weder Minisign noch einen unabhaengig geprueften
Bootstrap. [Signierte Releases](SIGNED_RELEASES.md) verwenden weiterhin feste
Tags und ihren eigenen Pruefpfad. Ohne Freigabe bleibt `install.sh` gesperrt.

## Interaktive Auswahl

Eine bereits gepruefte neue Installerdatei starten:

```bash
bash ./openclaw-install.sh --legacy-unsigned-branch
```

Nach der Sprachauswahl stehen diese Optionen zur Verfuegung:

1. `main`; nur Enter waehlt diesen Standard.
2. `codex/optional-coding-agents-20261029`; ausdruecklicher Feature-/Teststand.
3. Einen anderen exakten Branchnamen eingeben, etwa `feature/meine-aenderung`.
0. Abbrechen, ohne einen Checkout zu starten.

Bei der freien Eingabe bedeutet Enter **Abbrechen**, nicht `main`. Ungueltige
Auswahl, EOF, ungueltiger Git-Ref oder nicht erreichbarer Branch fuehren zum
Abbruch. Es wird weder ein gleichnamiger Tag verwendet noch auf `main`
zurueckgefallen. Neue Branches muessen nicht in einer Liste nachgetragen werden.

Alternativ die Auswahl explizit vorgeben:

```bash
bash ./openclaw-install.sh --legacy-unsigned-branch --branch main
bash ./openclaw-install.sh --legacy-unsigned-branch --branch codex/optional-coding-agents-20261029
```

`--legacy-unsigned-main` bleibt als kompatibler Optionsname erhalten und zeigt
ebenfalls die Auswahl, wenn `--branch` fehlt. Diese Optionen starten weiterhin
einen interaktiven Installer, keine unbeaufsichtigte Hintergrundinstallation.

## Den neuen Bootstrap beziehen

Solange diese Aenderung nur im Featurebranch liegt, enthaelt `main/install.sh`
die Auswahl **noch nicht**. Der Branch der heruntergeladenen Bootstrap-Datei
und der anschliessend ausgewaehlte Zielbranch sind zwei verschiedene Dinge.
Zum bewussten Testen des neuen Bootstraps unter Linux/WSL:

```bash
cd ~
curl -fSL --proto '=https' --proto-redir '=https' \
  https://raw.githubusercontent.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/codex/optional-coding-agents-20261029/install.sh \
  -o openclaw-install.sh
less openclaw-install.sh
```

Erst nach eigener Pruefung `less` mit `q` verlassen und den gewuenschten
Aufruf oben ausfuehren. Download/HTTPS ist **kein Signaturnachweis**. Der
aktuelle Branchstand kann sich aendern; fuer einen festen Bootstrap eine
vorher unabhaengig gepruefte vollstaendige Commit-ID in der Download-URL nutzen.
Hier wurden diese Installationsbefehle nicht ausgefuehrt.

## Ordner und Updates

- `main` behaelt den bisherigen Ordner `openclaw_ultimate_setup` und dessen
  vorhandene Sicherungs-/Updatefreigaben bei.
- Andere Branches verwenden eigene Ordner
  `openclaw_ultimate_setup-branch-NAME-HASH`. Der lesbare Name ist gekuerzt und
  bereinigt; 16 SHA256-Hexzeichen unterscheiden auch aehnlich geschriebene Namen.
- Ein Branchcheckout wird nicht in eine bestehende `main`-Installation kopiert
  oder gemergt. Derselbe ausgewaehlte Branch verwendet seinen eigenen Ordner erneut.
- Feature-Updates verlangen passenden Origin/Branch und einen sauberen
  Arbeitsstand. Vor Fetch wird die bestehende Repo-Sicherung erstellt. Danach
  ist ausschliesslich Fast-Forward auf den zuvor abgefragten Commit erlaubt.
  Ein zwischenzeitlich geaenderter Remote-Stand blockiert den Start.
- Lokale Aenderungen, abweichende Origins, andere lokale Branches, manipulierte
  Pfade oder divergierende Historie werden nicht automatisch repariert,
  geloescht oder zurueckgesetzt. Partielle Clone-Ordner bleiben zur Diagnose erhalten.

Die getrennten Checkouts verwenden weiterhin denselben privaten Nutzerworkspace
`~/.openclaw_ultimate_user_data`: **keine Isolation installierter Tools oder
Nutzdaten**. Nicht mehrere Installationen/Tool-Aktionen parallel starten.
Zum Zurueckkehren zu `main` den Installer erneut ausdruecklich mit `--branch main`
starten. Das ist kein Rollback bereits installierter Programme oder Nutzdaten.

## Nachweise und Grenzen

`tests/test_install_branches.py` prueft Auswahl, freie Branches, Abbruch,
Argument-/Refvalidierung, isolierte Ordnernamen, exakte Head-Abfrage,
Backup-vor-Fetch und Fehlerpfade mit gemocktem Git-Transport und Backup.
Der CI-Workflow `test-install-scripts.yml` fuehrt diese Offline-Tests ebenfalls aus.
Kein echter Clone, Providerlogin, Tool-/Modellstart oder Linux-/WSL-Installerlauf
ist damit als getestet ausgewiesen. Fremder Branchcode bleibt ausfuehrbarer
Code und muss unabhaengig geprueft werden.

Lokaler Nachweis vom 29.10.2026 (Windows mit nativem Git-Bash, kein WSL):
13 Branch-Regressionen und 16 Release-Regressionen bestanden, einschliesslich
Bash-Syntaxpruefung. Im zusaetzlichen P0-Lauf bestanden 20 von 22 Faellen direkt;
ein POSIX-Fall wurde plattformbedingt uebersprungen und ein unveraenderter
Compose-Fixture-Test lief in sein 30-Sekunden-Limit. Dessen separater Nachlauf
bestand. Keine Timeout-Erhoehung und keine Aenderung am Compose-Uninstaller.
