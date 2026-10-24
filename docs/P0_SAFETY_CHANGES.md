# P0-Paket: Update, PAT und datenerhaltender Compose-Uninstall

Ergaenzender [externer P0-Patchplan mit Standabgleich](sources/2026-10-24/README.md)
fuer Kubernetes/Compose: Vorschlag, nicht Bestandteil der hier beschriebenen Freigabe.

Freigegebener Umfang: Update-Sicherung, PAT-Handling und datenerhaltender
Uninstall. Abnahmeziel: **Ubuntu 24.04 x86_64 in einer Wegwerf-VM**.
Die bestehenden Grok-/Architekturentwuerfe bleiben davon getrennt.
Keine produktiven Dienste, echten Zugangsdaten oder Nutzerdaten wurden fuer
die Implementierung geaendert. Keine PR/Commits/Pushes automatisch erstellt.

## Update und Wiederherstellung

[Repo-Safety-Helper](../scripts/lib/repo_safety.py),
[Bootstrap](../install.sh), [normaler Updater](../scripts/update_setup_only.sh),
[expliziter Abgleich](../scripts/auto_update_hard.sh).

Die beiden bisherigen Reset/Clean-Wege sind ersetzt: Der explizite Abgleich
verlangt eine Freigabe, erstellt und verifiziert eine vollstaendige Sicherung
und verwendet einen detached Checkout. Lokale Branch-Refs/Commits bleiben
erhalten. Unversionierte und ignorierte Dateien werden **nicht bereinigt**;
bei Kollision mit einem Zieldateipfad wird abgebrochen statt ueberschrieben.
Das normale Update bleibt Fast-forward-only, ohne erzwungenen Branchwechsel.

Die Sicherung enthaelt Arbeitsdateien, staged Index, `.git`, lokale Commits,
ignorierte und unversionierte Dateien. SHA256-Manifest, Archiv-Pruefsumme und
vollstaendiger Inhaltsvergleich ersetzen die fruehere reine Dateinamenliste.
Mindestens Gesamtdateigroesse plus Metadaten und 512 MiB Reserve sind erforderlich.
Sicherungsfehler stoppen vor dem Checkout; bei ENOSPC gibt es eine Fehlermeldung,
keine Erfolgsmeldung. Partielle Sicherungen bleiben ohne gueltigen Abschluss
zur Diagnose erhalten und werden nicht automatisch geloescht.

**Achtung:** Diese lokalen Archive sind nicht verschluesselt und koennen
Secrets einschliesslich historischer Git-Inhalte enthalten. Verzeichnis 0700,
Archiv/Manifest 0600; keine Ablage in oeffentlichen Freigaben oder unverschluesseltem
Offsite-Speicher. Hashes sind Integritaetspruefung, keine digitale Signatur.
Externe Symlinkziele werden nicht kopiert; der externe User-Workspace bleibt
ausserhalb des Repo-Snapshots. ACLs/xattrs, Spezialdateien, Submodule,
Linked Worktrees und Shared-Object-Clones sind kein freigegebener Restore-Vertrag.
Die letztgenannten Checkout-Varianten werden vor Mutation abgewiesen.

Der Operator muss parallele Editor-/Git-/Build-Aenderungen unterbinden. Ein
Operation-Lock verhindert kooperierende Update-Laeufe; er sperrt keine fremden
Editoren. Der Helper vergleicht den Dateibestand waehrend der Sicherung.
Ein fehlgeschlagener Checkout kann teilweise veraendert sein: kein automatisches
Zurueckschreiben ueber einen aktiven Checkout, sondern isolierter Restore.

```bash
# No network, checkout, backup or installation in these dry runs.
bash install.sh --dry-run
bash scripts/update_setup_only.sh --dry-run
bash scripts/auto_update_hard.sh --dry-run

# Explicit replacement of tracked local changes, with verified backup first.
bash scripts/auto_update_hard.sh --apply --confirm-discard-local

# Verify and restore only into a NEW isolated destination.
python3 -I -B scripts/lib/repo_safety.py verify --snapshot /protected/snapshot
python3 -I -B scripts/lib/repo_safety.py restore --snapshot /protected/snapshot \
  --destination /protected/new-restore-target --dry-run
python3 -I -B scripts/lib/repo_safety.py restore --snapshot /protected/snapshot \
  --destination /protected/new-restore-target --apply
```

Das Menue verlangt nach einem Dry-run die Eingabe `SYNC`. Direkter Aufruf des
Abgleich-Skripts ohne Parameter ist jetzt nur ein Dry-run. Der normale Update-
Menuepfad behaelt seine explizit gewaehlte Update-Aktion; sein `--dry-run` ist
separat verfuegbar. Repo-Sync-Helper und normaler Updater vermeiden bei bereits
aktuellem Stand einen zusaetzlichen Snapshot; der Bootstrap kann auch dann sichern.
Ein Backup vor einem erstmaligen Fetch kann bei Fehlern erhalten bleiben.

**Kompatibilitaet:** Aeltere Checkouts ohne den neuen Helper werden nicht
ungesichert zurueckgesetzt. Einen separat geprueften neuen Checkout verwenden;
lokale Aenderungen nicht loeschen, um diese Sperre zu umgehen. Bereits vorhandene
Backup-Verzeichnisse mit unsicheren Rechten brauchen eine bewusste Rechtekorrektur
durch den Betreiber. Apply ist fuer Linux vorgesehen; Windows-nativ wird vom
CLI abgewiesen, da dessen ACL-/Restore-Semantik nicht freigegeben ist. WSL ist
keine hier durchgefuehrte Abnahme. Die Linux-Platzpruefung ersetzt insbesondere
nicht die separate Kontrolle der Windows-Host-Kapazitaet einer WSL-VHDX.

**Weiter offen:** Signierte Release-Artefakte, unabhaengiger Signer-Vertrauensanker
und eine durchgaengig erzwungene `versions.lock`. `origin/main` bleibt bis zur
getrennten Release-PR ein bewegliches Ziel; dieser Patch behauptet keine
vollstaendige Supply-Chain-Haertung.

## PAT ohne Token-URL

Private GitHub-Zugriffe verwenden eine temporaere Askpass-Datei und eine
Token-Datei unter einem privaten Temp-Verzeichnis. Kein Token in Clone-URLs,
Git-Argumenten oder globaler Git-Konfiguration. Credential-Helper werden fuer
diese Anmeldung deaktiviert; HTTP-Redirects und Git-HTTP-Tracing sind aus.
Die PAT-Variable wird nicht an Kindprozesse exportiert; Shell-Tracing wird beim
Einlesen/Verarbeiten abgeschaltet. Askpass gibt den Token nur fuer den erwarteten
GitHub-Passwortprompt aus. Vor Start des eigentlichen Setups wird aufgeraeumt.
EXIT/INT/TERM loesen Cleanup aus; SIGKILL oder Stromausfall koennen kein Cleanup
garantieren. Tempdateien enthalten bis zur Bereinigung sensible Werte.

Bereits credentialhaltige Remote-URLs werden **vor Fetch abgewiesen**, nicht
heimlich weiterverwendet. Der Betreiber muss die URL bewusst bereinigen und
betroffene Tokens gegebenenfalls widerrufen. Beispiel ohne Token:

```bash
git remote set-url origin https://github.com/OWNER/REPOSITORY.git
```

Damit werden weder historische Geheimnisse entfernt noch Anbieter-Keys rotiert.
[Historische Gitleaks-Befunde](audit-evidence/2026-10-23/gitleaks-summary.json)
bleiben eine gesonderte P0-Triage. Keine echten Keys als Tests verwenden.

## Datenerhaltender Compose-Uninstall

[Gemeinsamer Helper](../scripts/tools/helpers/docker_compose_tool_common.sh).
Standard ist `compose down` **ohne** Volume-Loeschung. Es gibt keinen rekursiven
Dateiloeschschritt und keinen Purge-Schalter. Compose-Datei, `.env`, Bind-Mounts,
Quellen und benannte/anonyme Volumes bleiben erhalten. Anonyme Volumes werden
bei einer Neuinstallation nicht zwingend automatisch wieder zugeordnet.
Der Status-Eintrag wird erst nach erfolgreichem Docker-Aufruf entfernt;
die `.openclaw-compose-owner`-Besitzmarkierung bleibt erhalten.
bei Docker-Fehler wird keine erfolgreiche Deinstallation behauptet.

Zielpfad muss exakt `COMPOSE_TOOL_ROOT/TOOL_SLUG` sein, standardmaessig `/opt/slug`.
Kanonische Pfade, keine Symlink-Ziele, passende Eigentuemer, keine fremden
Schreibrechte und eine passende `.openclaw-compose-owner`-Markierung werden
geprueft. Neue Helper-Installationen schreiben diese Markierung; sie ist ein
lokaler Besitzvertrag, keine kryptografische Herkunftsbestaetigung.

Altinstallationen ohne Markierung werden nicht automatisch uebernommen.
Nach manueller Pruefung des Pfads und der Compose-Datei beispielsweise:

```bash
bash scripts/tools/grafana_uninstall.sh --dry-run --adopt-legacy
bash scripts/tools/grafana_uninstall.sh --apply --adopt-legacy
```

Ein falscher vorhandener Besitzmarker wird auch mit `--adopt-legacy` nicht
ueberschrieben. Markerlose Restverzeichnisse sind kein Installationsnachweis.
Andere, nicht diesen Helper verwendende Deinstaller werden durch diese PR
nicht pauschal abgesichert. Ebenso koennen alte Installer eigene Vorarbeiten
vor dem Helper ausfuehren: Der Helper-Dry-run ist **keine** Freigabe aller alten
Installer fuer einen nebenwirkungsfreien Gesamtlauf.

Nebenbei verhindert der gemeinsame Installationsweg das Ueberschreiben einer
abweichenden Compose-Konfiguration und einer vorhandenen `.env`. Nur das
Tool-Hauptverzeichnis, nicht rekursiv die Datenbankdaten, erhaelt den Installer-
Eigentuemer. Geteilte Basiswerkzeuge wie Docker werden nicht entfernt.

## Tests und Abnahmegrenzen

Lokaler Nachweis vom 23.10.2026 unter Windows mit nativem Git/Bash:
22 P0-Tests: 21 bestanden, ein POSIX-Symlink-Test plattformbedingt uebersprungen.
Alle 13 bestehenden Repository-Audit-Fixtures bestanden. Bash-Syntaxpruefung
der fuenf geaenderten Shell-Einstiegspunkte und `git diff --check` bestanden.
Gezielter ShellCheck fuer beide Update-Skripte und den Compose-Helper ohne
Befunde; YAML des neuen VM-Workflows erfolgreich geparst. Kein vollstaendiger
ShellCheck-Lauf des Hauptsetups.
Platzmangel wird per Fault-Injection simuliert, nicht durch Fuellen der Festplatte.
Dies ist keine gruene Gesamt-CI oder Produktionsfreigabe.

[P0-Fixtures](../tests/test_p0_safety.py) verwenden ausschliesslich temporaere
Git-Repositories, einen Dummy-Token und gemockte Docker-/Statusfunktionen.
Geprueft werden staged/unstaged/untracked/ignored-Dateien, lokale Commits,
Restore, beschaedigte Archive, Platzmangel, Kollisionen, Idempotenz, PAT-Argumente,
Cleanup, Besitzmarker, Pfadgrenzen und Fehlerstatus.

[Ubuntu-24.04-x86_64-Workflow](../.github/workflows/p0-safety.yml) ist fuer eine
GitHub-gehostete Wegwerf-VM vorbereitet. Das ist kein bereits ausgefuehrter
VM-Lauf. Die Test-Idempotenz betrifft Repo-Helper und Compose-Uninstall, nicht
eine zweimalige vollstaendige Installation des interaktiven Hauptsetups.
Kein Docker-Daemon, keine Boerse, keine Wallet und keine Cloud-API werden getestet.

Schwere Builds bleiben fuer Folge-PRs auf **GitHub-Source-Builds ohne Binary-
Fallback** festgelegt. Dieses P0-Paket fuehrt keine schweren Builds aus und
behauptet keine neue repo-weite Enforcement-Logik fuer alle bestehenden Tools.
