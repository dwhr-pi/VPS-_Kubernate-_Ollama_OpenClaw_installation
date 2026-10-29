# Sicherer Einstieg und native Core-Dienste

Stand: 2026-10-27. Diese fuenf Bausteine sind ein **optionaler Migrationspfad**,
keine Behauptung einer bereits abgenommenen Produktionsplattform. Bestehende
Tool-Installer, Statusdateien, Secrets und User-Workspaces werden nicht automatisch
uebernommen oder veraendert. Die vollstaendigen Implementierungen sind unten verlinkt.
Alle Befehle sind zur bewussten Ausfuehrung unter Linux gedacht; sie wurden hier
nicht auf einem Produktivhost ausgefuehrt.

## 1. Installer erst pruefen, dann ausfuehren

Vollstaendiger Code: [verify_and_install.sh](../verify_and_install.sh),
[install.sh](../install.sh) und
[verified_source_install.sh](../scripts/verified_source_install.sh).

Der Wrapper verwendet `set -euo pipefail`, `umask 077`, ein isoliertes temporaeres
Git-Verzeichnis und einen EXIT-Trap zur begrenzten Bereinigung. Git-Hooks,
Submodule, Credential-Helper und geerbte Git-Konfiguration werden nicht uebernommen.
Es wird nur der angegebene volle Commit ausgecheckt. Erst nach SHA256-Pruefung der
`install.sh` darf der Installationspfad starten. Dieser kopiert genau den
geprueften Checkout und laedt nicht anschliessend ungeprueft `main` nach.

```bash
# Wrapper selbst zuerst aus einer vertrauenswuerdigen Quelle beziehen und pruefen.
# Commit und SHA256 benoetigen einen unabhaengig bestaetigten Vertrauensanker.
bash ./verify_and_install.sh \
  --commit DEIN_VERIFIZIERTER_40_STELLIGER_COMMIT \
  --installer-sha256 DEIN_UNABHAENGIG_VERIFIZIERTER_SHA256 \
  --verify-only

# Nach erfolgreicher Pruefung die Installation bewusst freigeben.
bash ./verify_and_install.sh \
  --commit DEIN_VERIFIZIERTER_40_STELLIGER_COMMIT \
  --installer-sha256 DEIN_UNABHAENGIG_VERIFIZIERTER_SHA256 \
  --destination "$HOME/openclaw_ultimate_setup"
```

Dies implementiert die SHA256-Alternative, keine erfundene GPG-Signatur.
Ein Hash vom selben moeglicherweise kompromittierten Downloadkanal beweist keine
Authentizitaet. Auch die Sicherheit des Wrappers und des gesamten ausgewaehlten
Commits muss geprueft sein: der Installer fuehrt weiteren Repo-Code aus.
Das Ziel muss neu sein, im Benutzer-Home liegen und vom User-Workspace getrennt
sein. Der derzeitige Wrapper ist fuer das oeffentliche Repository ausgelegt,
nicht fuer eine automatische PAT-Uebergabe an private Repositories.

Der sichere Einstieg ersetzt keine Inhaltspruefung aller nachfolgenden Installer.
Legacy-Aufrufe und ihre Installations-/Updatepfade sind damit nicht pauschal
gehaertet. Vorhandene Installationen werden nicht ueberschrieben.

## 2. Ansible fuer Ollama und OpenClaw

Vollstaendiger Code:
[Playbook](../ansible/playbooks/core_ai_setup.yml),
[Build-Tasks](../ansible/tasks/core_ai_build.yml),
[Variablenvorlage](../ansible/core_ai.vars.example.yml),
[Inventarvorlage](../ansible/core_ai.inventory.example.ini),
[systemd-Template](../ansible/templates/core-ai.service.j2),
[OpenClaw-Startwrapper](../ansible/templates/core-openclaw-run.sh.j2).

Voraussetzung ist Ubuntu 24.04 mit systemd, eine gepruefte Ansible-Installation
und bereits separat bereitgestellte passende Build-Werkzeuge. Volle GitHub-Commits
und exakte Go-/Node-/pnpm-Versionen sind Pflicht; Platzhalter werden abgewiesen.
Ollama wird nativ per CMake gebaut, OpenClaw mit eingefrorener pnpm-Abhaengigkeitsdatei.
Der aktuelle offizielle Ollama-CMake-Build umfasst CLI und native CPU-Laufzeit;
GPU-Builds und Treiber sind gesondert abzustimmen.

```bash
# Vorlage nur mit Nicht-Secrets ausserhalb des Repositories vervollstaendigen.
install -m 600 ansible/core_ai.vars.example.yml "$HOME/core-ai.vars.yml"

# Nach Eintragen der Pins, Toolchains und des vorhandenen Operators pruefen.
ansible-playbook -i ansible/core_ai.inventory.example.ini \
  ansible/playbooks/core_ai_setup.yml \
  -e "@$HOME/core-ai.vars.yml" --syntax-check

# Erst nach Pruefung bewusst auf dem ausgewaehlten Host anwenden.
ansible-playbook -i ansible/core_ai.inventory.example.ini --ask-become-pass \
  ansible/playbooks/core_ai_setup.yml -e "@$HOME/core-ai.vars.yml"
```

Der `USER_WORKSPACE_DIR` bleibt benutzereigen mit Modus `0700`. Eigene
Build- und Dienstbenutzer verhindern Builds oder Agentenbetrieb als root.
Die Dienste erhalten per systemd `BindPaths` jeweils nur ihren eigenen
Workspace-Teilbaum; es gibt kein rekursives `chown` aller Benutzerdaten.
Builds liegen versionsgetrennt unter `/opt/openclaw-core/<komponente>/<commit>`.
Erst nach erfolgreicher Pruefung entsteht ein Buildnachweis. Bei Wiederholung
werden dessen Quelle, Komponente und Eigentum geprueft und vorhandene Builds
uebersprungen; ein Verzeichnis allein gilt nicht als Installationsbeweis.

Standard ist `core_start_services: false`. Vor einem bewussten Start muessen
OpenClaw-Konfiguration und root-eigene Credential-Datei
`/etc/openclaw-core/gateway.token` geprueft und provisioniert sein. Keine Tokens
als Kommandozeilenargumente uebergeben. Beide APIs binden an Loopback;
Capabilities sind entfernt und Privilegieneskalation ist deaktiviert.
Eine Offline-Umgebungsvariable ist kein belegter Ersatz fuer Netzwerkrichtlinien.

**Migration:** Die neuen Units heissen `openclaw-core-ollama.service` und
`openclaw-core-openclaw.service`. Parallelbetrieb mit alten Units kann
Portkonflikte verursachen. Die bisherigen Menue-Installer und deren Uninstall- /
Statuslogik werden nicht stillschweigend auf dieses separate Deployment umgebogen.
Ihre Abschaltung, Datenuebernahme und Menue-Anbindung brauchen eine eigene Abnahme.

## 3. Taegliches Backup und verschluesselte ENV-Dateien

### Restic: native Ausfuehrung bevorzugt

Vollstaendiger Code:
[Backupskript](../scripts/operations/backup_user_workspace.sh),
[native Konfiguration](../config/workspace-backup.native.env.example),
[Service](../systemd/openclaw-workspace-backup.service.example),
[Timer](../systemd/openclaw-workspace-backup.timer.example).

Restic muss separat aus gepruefter Quelle bereitstehen. Ein **externes,
dediziertes S3-/HTTPS-Repository** wird bewusst initialisiert, nicht automatisch
vom Job angelegt. Ein MinIO auf derselben verlorenen Maschine ist kein Disaster-
Recovery-Ziel. S3-Zugang auf den benoetigten Bucket/Praefix begrenzen.
Root ist beim Dateilesen erforderlich, weil Dienstbenutzer eigene private
Workspace-Teilbaeume besitzen; der native Job behaelt nur `CAP_DAC_READ_SEARCH`.

```bash
# Nur gepruefte Kopien unter root-eigenen Pfaden als Dienst ausfuehren.
sudo install -d -m 755 /usr/local/libexec/openclaw-backup
sudo install -m 755 scripts/operations/backup_user_workspace.sh \
  /usr/local/libexec/openclaw-backup/backup_user_workspace.sh
sudo install -d -m 700 /etc/openclaw-workspace-backup/secrets
sudo install -m 600 config/workspace-backup.native.env.example \
  /etc/openclaw-workspace-backup/native.env
sudo install -m 644 systemd/openclaw-workspace-backup.service.example \
  /etc/systemd/system/openclaw-workspace-backup.service
sudo install -m 644 systemd/openclaw-workspace-backup.timer.example \
  /etc/systemd/system/openclaw-workspace-backup.timer
```

Vor Aktivierung `native.env` lokal bearbeiten: Quelle, stabilen Hostnamen,
geprueften absoluten Restic-Pfad und Repository setzen. Drei vorhandene,
nichtleere Dateien im Secret-Verzeichnis muessen root gehoeren und `0600` haben:
`password`, `access-key-id`, `secret-access-key`. Sie gehoeren **nicht** ins Repo
und nicht in den gesicherten Quellbaum. Passwort und Recovery-Anleitung zusaetzlich
getrennt absichern. Diese Anleitung erzeugt oder liest keine echten Zugangsdaten.

`BACKUP_TARGET_IS_EXTERNAL=1` bestaetigt nach eigener Pruefung das separate Ziel.
Fuer die Aufbewahrungsrichtlinie zusaetzlich `BACKUP_ALLOW_PRUNE=1` und
`BACKUP_DEDICATED_REPOSITORY=1` setzen. Ohne diese explizite Freigabe wird nichts
vergessen oder geprunt. `forget` filtert auf Host, Pfadgruppe und Job-Tag;
`prune` arbeitet repositoryweit, daher kein gemeinsam verwaltetes Repository nutzen.
Aufbewahrung: 7 taegliche, 4 woechentliche und 6 monatliche Sicherungsstaende.

```bash
# Erst nach vollstaendiger Konfiguration und isoliertem Restore-Test aktivieren.
sudo systemctl daemon-reload
sudo systemctl start openclaw-workspace-backup.service
sudo systemctl enable --now openclaw-workspace-backup.timer

# Status ohne Secret-Ausgabe; Journal nur im berechtigten Admin-Kontext pruefen.
systemctl list-timers openclaw-workspace-backup.timer
```

Der Timer laeuft taeglich ab 03:30 Europe/Berlin mit bis zu 20 Minuten Streuung
und nachholendem Lauf nach Ausfall. Ein aktiver Installations-Lock blockiert das
Backup. Restic-Fehler, auch Exitcode 3 fuer unvollstaendige Sicherungen, verhindern
Retention. Nach Prune folgt `restic check`. Kein automatisches `unlock`.

Dateisicherung ist **kein konsistentes Live-Datenbankbackup**. Postgres-Dumps,
Qdrant-Snapshots und eine konsistente MinIO-Strategie sind separat erforderlich.
Restore zuerst in ein leeres, isoliertes Verzeichnis mit `restic restore ...
--target ...`, Inhalt und Rechte pruefen und erst im Wartungsfenster uebernehmen.
Ein erfolgreiches `check` ersetzt diesen Wiederherstellungstest nicht.

### Optionaler Compose-Pfad

Vollstaendiger Code:
[Compose](../stacks/workspace-backup/docker-compose.yml),
[Nicht-Secret-ENV](../stacks/workspace-backup/.env.example),
[alternative Service-Unit](../systemd/openclaw-workspace-backup-compose.service.example).

Dies ist die hier ausdruecklich angefragte **optionale Container-Ausnahme**, nicht
der Standard fuer GitHub-Source-Builds. Kein Docker wird installiert. Benoetigt
wird ein separat aus freigegebenen Quellen gebautes/geprueftes Image mit Bash,
Restic und Coreutils, gepinnt per SHA256-Digest. Es gibt keinen unsicheren
`latest`-Fallback, Docker-Socket, offenen Port oder beschreibbaren Source-Mount.

Nach eigener Pruefung Compose und dessen Nicht-Secret-ENV root-eigen nach
`/etc/openclaw-workspace-backup/docker-compose.yml` und `compose.env` installieren.
Das Jobskript bleibt die root-eigene Kopie unter `/usr/local/libexec`.
**Entweder** native Service-Unit **oder** Compose-Service-Vorlage unter dem Namen
`openclaw-workspace-backup.service` verwenden; niemals beide Scheduler aktivieren.
Beide verwenden denselben Timer. Hostpfade muessen vorher existieren.

### SOPS und age: nur Ciphertext in Git

Vollstaendiger Code: [.sops.yaml](../.sops.yaml),
[ENV-Vorlage](../config/examples/core.env.template),
[Setup-Wrapper](../scripts/decrypt_core_env.sh),
[sicherer Writer](../scripts/security/decrypt_sops_env.py).

SOPS wird heute unter dem Projekt `getsops/sops` gepflegt. Gepruefte SOPS-/age-
Werkzeuge separat bereitstellen. Privater age-Schluessel ausserhalb von Repo und
Workspace mit `0600`; oeffentlichen Empfaenger in `.sops.yaml` eintragen.
Die ENV-Vorlage enthaelt ausschliesslich Platzhalter.

```bash
# Nur die private Arbeitskopie ausserhalb des Repositories mit echten Werten fuellen.
umask 077
install -m 600 config/examples/core.env.template "$HOME/core.private.env"

# Nach lokaler Bearbeitung verschluesseln; niemals die Klartextdatei committen.
# PUBLIC_AGE_RECIPIENT enthaelt ausschliesslich den oeffentlichen age1-Empfaenger.
install -d -m 700 config/secrets
sops encrypt --age "$PUBLIC_AGE_RECIPIENT" \
  --input-type binary --output-type binary "$HOME/core.private.env" \
  > config/secrets/core.env.enc.json

# Zuerst nur die Ciphertext-Struktur pruefen, ohne zu entschluesseln.
bash scripts/decrypt_core_env.sh \
  --encrypted config/secrets/core.env.enc.json \
  --identity "$HOME/.config/sops/age/keys.txt"

# Bewusst eine neue Datei im bestehenden privaten Workspace anlegen.
bash scripts/decrypt_core_env.sh \
  --encrypted config/secrets/core.env.enc.json \
  --identity "$HOME/.config/sops/age/keys.txt" --apply
```

Der Binary-Modus verschluesselt die komplette ENV als SOPS-JSON-Huelle, nicht nur
einzelne Werte. Es wird kein vorgetaeuschter Ciphertext mit Dummy-Schluessel
mitgeliefert. Standardmaessig findet keine Entschluesselung statt. `--apply`
akzeptiert nur lokale age-Metadaten, prueft den SOPS-MAC und schreibt atomar eine
**neue** Datei `USER_WORKSPACE_DIR/secrets/core.env` mit `0600`.
Bestehende Dateien und Symlinks werden nicht ersetzt. Erlaubt sind nur die im
Writer genannten API-/Gateway-Variablen mit einfachen literalen Werten.

Kein `source`, `eval`, Shell-Export von Klartext oder Loggen von Secret-Werten.
Dieser kontrollierte Schritt ersetzt nicht automatisch alle Legacy-ENV-Lader.
Die Token-Credential-Datei der Ansible-Unit muss separat provisioniert werden;
eine `core.env` allein aktiviert weder Dienste noch Modell-/Cloud-Aufrufe.

## 4. Ressourcen pro systemd-Dienst begrenzen

Vollstaendiger Code: [apply_service_limits.sh](../scripts/operations/apply_service_limits.sh).

```bash
# Nur Plan: kein Zugriff auf systemd und keine Datei schreiben.
bash scripts/operations/apply_service_limits.sh \
  --unit ollama.service --memory-max 8G --cpu-quota 200

# Aktivierung und Dienstneustart ausschliesslich im Wartungsfenster.
sudo bash scripts/operations/apply_service_limits.sh \
  --unit ollama.service --memory-max 8G --cpu-quota 200 --apply --restart
```

Fuer ComfyUI `--unit comfyui.service` verwenden. Fuer den Ansible-Pfad heissen die
Units `openclaw-core-ollama.service` beziehungsweise `openclaw-core-openclaw.service`.
Es werden nur bekannte geladene Units akzeptiert; vorhandene abweichende
`limits.conf` bleiben unberuehrt. Ausgabeziel fuer Ollama ist
`/etc/systemd/system/ollama.service.d/limits.conf`.

`MemoryHigh` liegt bei 90 Prozent von `MemoryMax`; `CPUQuota=200%` entspricht zwei
CPU-Zeitaequivalenten, keiner festen Kernzuordnung. Unter 1 GiB Hostreserve wird
die Anwendung verweigert: 8G ist insbesondere **kein** sicherer Wert auf einem
8G-Rechner. Budgets aller Dienste zusammen kalkulieren. Das begrenzt weder VRAM
noch manuell ausserhalb der Unit gestartete Prozesse und ersetzt keine
Kontext-/Parallelitaetsplanung des Modells.

## 5. Traefik lokal und nativ vorbereiten

Vollstaendiger Code: [Setup](../scripts/setup_traefik_local.sh),
[statische Konfiguration](../config/traefik-local/traefik.yml),
[TLS-Konfiguration](../config/traefik-local/dynamic/tls.yml),
[systemd-Unit](../systemd/openclaw-traefik.service).

Zuerst Traefik aus einem geprueften GitHub-Quellstand separat bauen. Das Setup
uebernimmt ausschliesslich eine regulaere Binaerdatei mit bestaetigtem SHA256
und vollem Quellcommit. Das ersetzt keine Build-Provenienzpruefung. Kein Docker-
Fallback und kein automatischer Dienststart. Vorhandene fremde Konfigurationen
oder abweichende Builds werden nicht adoptiert/ueberschrieben.

```bash
# Standard: nur Hash pruefen und den Plan anzeigen.
bash scripts/setup_traefik_local.sh --binary /absolut/zum/geprueften/traefik \
  --sha256 DEIN_VERIFIZIERTER_SHA256 --source-commit DEIN_VOLLER_COMMIT

# Konfiguration, Benutzer und Unit registrieren, noch nicht starten.
sudo bash scripts/setup_traefik_local.sh --binary /absolut/zum/geprueften/traefik \
  --sha256 DEIN_VERIFIZIERTER_SHA256 --source-commit DEIN_VOLLER_COMMIT --apply
```

Zertifikat und privaten Schluessel separat unter
`/etc/openclaw-traefik/tls/origin.crt` und `origin.key` bereitstellen:
root:traefik-local, Modus `0640`, keine Symlinks. Danach erst denselben Apply-
Befehl mit `--start` wiederholen. PEM-Gueltigkeit, Schluesselzuordnung und
Konflikte auf 80/443 werden vor dem Start geprueft. Das Zertifikat muss noch
mindestens einen Tag gueltig sein; Hostname, Aussteller und Vertrauenskette sind
zusaetzlich vom Betreiber abzunehmen.

Traefik bindet ausschliesslich `127.0.0.1:80/443`, leitet HTTP auf HTTPS um,
deaktiviert Dashboard/Insecure-API und verwendet keinen Docker-Socket.
Das Dienstkonto ist nicht root; nur die Capability fuer niedrige Ports bleibt.
TLS erfordert SNI. Routen, Authentifizierung und Tunnel werden absichtlich nicht
automatisch veroeffentlicht. Bestehenden K3s-Traefik nicht parallel ersetzen.

Cloudflare-Origin-Zertifikate schuetzen die Strecke Cloudflare zum Origin und
sind **keine allgemein browser-vertrauenswuerdigen Zertifikate**. Full (strict)
beziehungsweise korrekt konfigurierter Tunnel mit passender CA und Servername
sind erforderlich; niemals `insecureSkipVerify` als Loesung verwenden.
Loopback allein ist nicht vom Cloudflare-Edge erreichbar: ein bewusster Tunnel/
Proxy-Pfad ist noetig. DNS, Zertifikatserneuerung und Ablaufmonitoring bleiben
gesonderte Betriebsaufgaben.

## Pruefung und Abnahmegrenzen

Offline-Vertraege und Bash-Syntax:

```bash
python -B -m unittest discover -s tests -p test_secure_core_refactor.py -v
```

Die Tests fuehren keine Installer, echten S3-Anfragen, Secret-Entschluesselungen,
Modelle oder Dienste aus. Der Backup-Ablauf wird mit einem lokalen Restic-Mock
einschliesslich Fehlerpfad vor Retention geprueft. Linux-spezifische Rechte-/Writer-
Tests werden unter Windows uebersprungen. Vor Produktion sind Ansible-Syntaxcheck,
zweifache Idempotenz-Abnahme in Ubuntu-24.04-Wegwerf-VM, echte SOPS-Runde,
Compose-Konfigurationspruefung, systemd-Haertung und isolierter Restore-Test Pflicht.

## Offizielle technische Quellen

- [Ollama: aktueller Source-Build](https://github.com/ollama/ollama/blob/main/docs/development.md)
- [SOPS und Dateiformate](https://getsops.io/docs/)
- [SOPS: Binary-JSON-Store](https://github.com/getsops/sops/blob/main/stores/json/store.go)
- [Restic: Retention und Prune](https://restic.readthedocs.io/en/stable/060_forget.html)
- [systemd: Ressourcensteuerung](https://www.freedesktop.org/software/systemd/man/latest/systemd.resource-control.html)
- [Traefik: EntryPoints](https://doc.traefik.io/traefik/reference/install-configuration/entrypoints/)
- [Cloudflare: Origin CA und Full (strict)](https://developers.cloudflare.com/ssl/origin-configuration/origin-ca/)
