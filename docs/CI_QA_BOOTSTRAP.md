# CI-QA-Bootstrap: direkte signierte Ubuntu-Quellen

Stand **11.11.2026**, PR 25, Head `b854d26fd1244a5a274531d9acbe439f20205900`.
Bei beiden Versuchen scheiterten diese Laeufe vor Beginn der eigentlichen QA:
[CI PR](https://github.com/dwhr-pi/OpenClaw-AI_Infrastructure-_Ultimate_Setup/actions/runs/43041922592),
[CI Push](https://github.com/dwhr-pi/OpenClaw-AI_Infrastructure-_Ultimate_Setup/actions/runs/43041786057),
[Repo Health](https://github.com/dwhr-pi/OpenClaw-AI_Infrastructure-_Ultimate_Setup/actions/runs/43041922511).
APT meldete `Temporary failure resolving 'azure.archive.ubuntu.com'`;
das fehlende `shfmt` konnte nicht geladen werden, Exit 100.

`scripts/ci/install_qa_tools.sh` ist nur fuer **GitHub-gehostete Ubuntu-24.04-
amd64-Runner** vorgesehen. Kein WSL-/VPS-/Benutzer-Installer, kein Self-hosted-
Runner-Eingriff. Die beiden Workflows pinnen deshalb `ubuntu-24.04`.

Vorhandene QA-Kommandos werden geprueft, nur fehlende Pakete installiert.
APT nutzt fuer diese Aufrufe eine temporaere eigene Quellenliste mit den
offiziellen HTTPS-Endpunkten `archive.ubuntu.com` / `security.ubuntu.com` und
dem vorhandenen Ubuntu-Archivschluesselring. Dadurch wird die defekte
Azure-Mirrorliste nicht verwendet. `/etc/apt/sources.list*` bleibt unveraendert.
Die temporaere Datei wird anschliessend gezielt entfernt, keine rekursive
Bereinigung von Verzeichnissen oder Benutzerdateien.

Metadatenfehler sind fatal (`APT::Update::Error-Mode=any`), Timeout/Retry sind
begrenzt. Kein `trusted=yes`, keine ausgeschaltete TLS-/Signaturpruefung und
kein `continue-on-error`. Versionsaufrufe muessen danach erfolgreich sein.
Alle bisherigen Bash-, ShellCheck-, shfmt-, Secret-, Registry-, Matrix- und
Linkpruefungen bleiben erhalten. npm-Versionpins werden nicht ersetzt.

Nur Quellenliste lesend anzeigen, ohne Installation:

```bash
bash scripts/ci/install_qa_tools.sh --sources
```

Referenzen: [Ubuntu sources.list](https://manpages.ubuntu.com/manpages/noble/man5/sources.list.5.html),
[Ubuntu apt-get](https://manpages.ubuntu.com/manpages/noble/man8/apt-get.8.html).
Offline-Tests verwenden Stubs fuer sudo/APT und installieren keine Pakete.
Ein erfolgreicher echter Runner-Lauf nach Commit/Push ist weiterhin notwendig;
die lokale Fixture ist keine CI-Abnahme. Actions-Neustart durch die Integration
war zuvor mit HTTP 403 gesperrt; keine Credentials als Umgehung auslesen.
