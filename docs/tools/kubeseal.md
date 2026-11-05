# Kubeseal: nativer GitHub-CLI-Build

Stand: 2026-10-27. Kubeseal verschluesselt Kubernetes-Secrets fuer den separat betriebenen
Sealed-Secrets-Controller. Der Installer baut ausschliesslich die CLI aus GitHub, ohne Docker,
Controller-Installation, Clusterzugriff, Schluesselimport oder Secret-Apply.

## Quelle und Buildvertrag

- Repository: [bitnami/sealed-secrets](https://github.com/bitnami/sealed-secrets).
- Gepinnter Commit: `c58a60f0bd5283d28c25ad068e7c9760634be470`.
- Paket: `./cmd/kubeseal`; Versionsprobe: `--version`.
- Go mindestens **1.27.3**, bestaetigt in der
  [go.mod am Pin](https://github.com/bitnami/sealed-secrets/blob/c58a60f0bd5283d28c25ad068e7c9760634be470/go.mod).
- Linux-/WSL- und Windows-Host-Speicherwachen bleiben aktiv; die Toolreserve betraegt derzeit 4096
  MiB. Ein Build kann trotzdem mehr Ressourcen benoetigen.

## Fehler: Nicht freigegebener privater Go-Buildvertrag

Das Installationslog vom 27.10.2026 zeigte einen internen Konsistenzfehler:
`config/docker_to_github.json` enthielt das Rezept, aber die separate Freigabeliste in
`scripts/tools/helpers/native_go.py` noch keinen Kubeseal- Eintrag. Deshalb wurde bereits vor der
Auswahl einer vorhandenen Go-Toolchain abgebrochen. Die Meldung bedeutete **nicht**, dass der Nutzer
eine Nachfrage abgelehnt hatte, und war kein Speicherplatzfehler.

Die Freigabeliste ist ergaenzt. Der gleiche Abgleich wurde fuer Traefik und OpenTelemetry
korrigiert. Ein Offline-Regressionstest verlangt fuer jedes versionierte Go-Rezept einen passenden
Vertrag; unbekannte oder abweichende Mindestversionen werden weiterhin vor Download und Build
abgelehnt.

## Erneut versuchen

Nach Uebernahme der korrigierten Dateien im Ubuntu-/WSL-Setup erneut `Kubeseal` auswaehlen. Eine
passende vorhandene Go-Version wird bevorzugt. Wenn sie fehlt, ist eine ausdrueckliche Zustimmung
fuer die private, SHA256-gepruefte offizielle Go-Basis erforderlich. Nicht-interaktiv gezielt:

```bash
# Bewusste Freigabe ausschliesslich fuer fehlende Build-Abhaengigkeiten.
# Aus dem Setup-Repository ohne sudo ausfuehren.
bash scripts/tools/kubeseal_install.sh --install-build-deps

# Installationsnachweis und lokale Artefakte pruefen, kein Clusterzugriff.
bash scripts/tools/kubeseal_status.sh
```

Die CLI selbst wird weiterhin aus dem gepinnten GitHub-Quellstand gebaut. Die optionale Go-Basis
kommt aus dem bereits hinterlegten offiziellen Go-Archiv; kein apt-Go und kein globaler
PATH-/System-Go-Wechsel. Beim Build gelten `GOTOOLCHAIN=local` und die gepruefte private Umgebung.
Ein Buildfehler erzeugt keinen Erfolgsnachweis. Private Basiswerkzeuge werden nicht pauschal
entfernt.

Hier wurden nur Offline-Tests mit gemockten Toolchains ausgefuehrt, kein echter Linux-Quellbuild.
Controller, Zertifikatsvertrauen, Recovery und tatsaechliche Secret-Verschluesselung brauchen eine
separate Abnahme. Siehe [Sealed Secrets und GitOps](../GITOPS_SMALL_VPS.md).

<!-- BEGIN GENERATED VPS SSH -->

## VPS ueber SSH bedienen

Voraussetzung: ein bereits gepruefter Setup-Checkout und ein selbst eingerichteter
SSH-Alias `vps` (Benutzer, Host und Schluessel in deiner SSH-Konfiguration).
Alternativ `vps` durch `BENUTZER@VPS_HOST` ersetzen. Den Host-Fingerprint vorher
unabhaengig pruefen; keine Host-Key-Pruefung abschalten. Keine Zugangsdaten in Git.

Auf deinem Client (PowerShell, Linux oder macOS):

```bash
ssh -t vps
```

Danach **im Linux-Terminal des VPS**. Den Pfad bei einem Branch-Checkout anpassen;
ein Windows-/Desktop-Tool wird durch SSH nicht zu einer VPS-Anwendung:

```bash
cd "$HOME/openclaw_ultimate_setup" || exit 1
test -f scripts/tool_commands.py || exit 1
```

Zuerst nur den Offline-Plan lesen (keine Installation und kein Dienststart):

```bash
python3 -I -B scripts/tool_commands.py show kubeseal
```

### SSH-Aktionen: `kubeseal`

Status und Diagnose lesen den privaten Tool-Zustand auf dem VPS:

```bash
python3 -I -B scripts/tool_commands.py run kubeseal --action status
python3 -I -B scripts/tool_commands.py run kubeseal --action doctor
```

Die folgenden Befehle **einzeln und nur nach Freigabe** ausfuehren, nicht als
gemeinsamen Ablauf: Installation, spaeter Update oder bewusst Deinstallation.
Vorher Quellen, Lizenz, Ressourcen und Daten-Erhaltungsregeln dieser Anleitung pruefen.

Installieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run kubeseal --action install --apply --confirm kubeseal:install
```

Aktualisieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run kubeseal --action update --apply --confirm kubeseal:update
```

Deinstallieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run kubeseal --action uninstall --apply --confirm kubeseal:uninstall
```

Fehlende Build-Abhaengigkeiten stoppen den Versuch. Nur fuer Install/Update
`--install-build-deps` nach separater Download-Freigabe ergaenzen. Kein Auto-Yes,
kein Docker-Fallback; Source-Build/Status ist keine erfolgreiche Runtime-Abnahme.

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](../HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
