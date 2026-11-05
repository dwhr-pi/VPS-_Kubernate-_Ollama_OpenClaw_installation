# Traefik: nativer Headless-Build und Speicherreserve

Stand: 2026-10-27. Der Tool-Eintrag `Traefik` baut die Headless-Binaerdatei aus
[traefik/traefik](https://github.com/traefik/traefik), derzeit Commit
`b46d3ea648b543a8d8c675a178b0780faae958c7`. Die im Quellenmanifest festgelegte Go-Baseline ist
1.27.3. Es gibt keinen Docker-Fallback und keinen Serverstart durch diesen Build. Dashboard-Build
und Serverkonfiguration sind getrennte Aufgaben.

## Abbruch wegen Windows-Host-Speicher

Das Log vom 27.10.2026 mit 10146 MiB freiem Windows-Host-Speicher zeigt einen korrekten
Sicherheitsabbruch: Das native Buildrezept verlangt **16384 MiB (16 GiB)** freie Reserve vor dem
Start. Es fehlten mindestens **6238 MiB (rund 6,1 GiB)**. Das ist eine konservative Vorstartreserve,
kein gemessener endgueltiger Speicherverbrauch des Programms.

Die rund 951 GiB im virtuellen Linux-Dateisystem ersetzen diesen Platz auf dem Windows-Laufwerk
nicht. Die WSL-VHDX kann nur wachsen, solange ihr Hostlaufwerk Platz hat. Zusaetzlich pruefen, auf
welchem Windows-Laufwerk die Distribution tatsaechlich liegt; die Speicherwache kann nur den
erkannten Host-Mount bewerten.

**Es wurde kein Download oder Build gestartet.** Deshalb muessen fuer diesen Versuch keine
Programmdateien zurueckgerollt oder deinstalliert werden. Vorhandene Daten, Container und
Installationen bleiben erhalten.

## Einheitliche Vorpruefung im Setup

Die aeussere Menue-Wache hatte fuer Traefik bisher den allgemeinen 4096-MiB- Fallback verwendet.
Korrigiert sind jetzt beide Stufen: **16 GiB fuer Linux und Windows-Host**, passend zum nativen
Rezept. OpenTelemetry erhaelt ebenfalls seine bereits im Rezept hinterlegte 8192-MiB-Reserve in der
aeusseren Wache. Ein groesserer Bedarf aus erfolgreichen Messungen erhoeht diese Mindestwerte
weiterhin; kleine Messwerte senken sie nicht ab.

Nach Uebernahme der Aenderungen wird ein zu kleiner Hostspeicher bereits vor dem Tool-Installer
erkannt und die fehlende Menge im aktuellen Operationslog ausgegeben. Keine automatische Bereinigung
und kein Umgehen der Reserve.

Mindestens den fehlenden Platz auf dem **tatsaechlichen VHDX-Hostlaufwerk** freigeben,
sinnvollerweise mit zusaetzlicher Betriebsreserve, oder die Distribution bewusst auf ein ausreichend
grosses Laufwerk migrieren. Danach die freie Kapazitaet erneut pruefen und `Traefik` im Setup erneut
auswaehlen. Eine Linux-Neuinstallation ist wegen dieses Abbruchs nicht erforderlich.

## Build und Dienstbetrieb bleiben getrennt

```bash
# Erst nach ausreichendem Speicher und bewusster Build-Freigabe starten.
# Fehlendes Go wird nur mit Zustimmung privat bereitgestellt.
bash scripts/tools/traefik_install.sh --install-build-deps

# Lokale Buildartefakte pruefen; kein Server oder Zertifikatsabruf.
bash scripts/tools/traefik_status.sh
```

Der lokale Ingress wird erst separat mit
[setup_traefik_local.sh](../../scripts/setup_traefik_local.sh) vorbereitet: gepruefte Binaerdatei,
SHA256, Quellcommit, Loopback-Bindung und eigene Zertifikatsbereitstellung. `--apply` und `--start`
sind getrennte bewusste Freigaben. Bestehenden K3s-Traefik nicht parallel ersetzen.

Hier sind die Speicherwaeche und Abbruchpfade offline getestet, nicht der echte Linux-Quellbuild
oder ein produktiver Ingress.

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
python3 -I -B scripts/tool_commands.py show traefik
```

### SSH-Aktionen: `traefik`

Status und Diagnose lesen den privaten Tool-Zustand auf dem VPS:

```bash
python3 -I -B scripts/tool_commands.py run traefik --action status
python3 -I -B scripts/tool_commands.py run traefik --action doctor
```

Die folgenden Befehle **einzeln und nur nach Freigabe** ausfuehren, nicht als
gemeinsamen Ablauf: Installation, spaeter Update oder bewusst Deinstallation.
Vorher Quellen, Lizenz, Ressourcen und Daten-Erhaltungsregeln dieser Anleitung pruefen.

Installieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run traefik --action install --apply --confirm traefik:install
```

Aktualisieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run traefik --action update --apply --confirm traefik:update
```

Deinstallieren (separate Entscheidung):

```bash
python3 -I -B scripts/tool_commands.py run traefik --action uninstall --apply --confirm traefik:uninstall
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
