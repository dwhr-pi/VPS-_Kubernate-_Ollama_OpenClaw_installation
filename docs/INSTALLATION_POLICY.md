# Verbindliche Installationsrichtlinie

Entscheidung des Maintainers vom 03.11.2026:

- Git-Quellen herunterladen, pruefen, bauen und installieren bleibt der Standard fuer Tools und Programme.
- Keine Installation von Docker Engine, Docker Compose oder Tools ueber Docker; kein automatischer Docker-Fallback.
- Warnungen oder spaetere Reviews sind kein Auftrag, Git-Installationen pauschal zu sperren
  oder auf Docker umzulenken.
- Integritaets-, Pfad-, Speicherplatz- und Berechtigungspruefungen bleiben verbindlich.
  Eine fehlgeschlagene Pruefung stoppt den konkreten Versuch, nicht grundsaetzlich den Git-Weg.
- Fehlende native Buildrezepte bleiben sichtbar offen; Quellen allein sind keine installierte Runtime.
- apt ist nur fuer erforderliche System-/Build-Abhaengigkeiten vorgesehen.
  Bereits genehmigte private Basis-Toolchains und die offizielle Forgejo-Codeberg-Ausnahme
  bleiben dokumentierte Ausnahmen.

Bestehende Docker-/Compose-Dateien bleiben fuer historische Referenz und Datenrettung erhalten,
nicht als Empfehlung fuer Neuinstallationen. Bestehende Container, Volumes und Programme werden nicht entfernt.
Kubernetes benoetigt eine CRI-Laufzeit wie containerd; das ist keine Docker-Installation und keine
Freigabe fuer einen automatischen Cluster-Start. Dienste, Tunnel, Modelle und Cluster bleiben opt-in.

Die Alt-Deinstallationen von K3s und Clawbake liefern jetzt wie Ollama/OpenClaw eine
nicht loeschende Vorschau mit Exitcode 3. Ohne belegten Besitz-/Migrationsvertrag gibt es
keine automatische Entfernung und keinen geloeschten Installationsstatus.

Abnahme und Restarbeiten: [F01-F07](F01_F07_IMPLEMENTATION.md).

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
python3 -I -B scripts/tool_commands.py show docker
```

### SSH-Aktionen: `docker`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`Docker` (ID `docker`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
