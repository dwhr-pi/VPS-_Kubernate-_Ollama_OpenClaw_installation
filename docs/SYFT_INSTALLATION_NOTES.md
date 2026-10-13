# Syft: GitHub statt fehlendem apt-Paket

Im protokollierten Ubuntu-System ist `syft` nicht als apt-Paket verfuegbar.
Der Installer verwendet das [offizielle Anchore-Release](https://github.com/anchore/syft/releases/tag/v1.54.1).
Standard ist `v1.54.1`; `SYFT_VERSION=vX.Y.Z` kann eine andere feste Version setzen.
Linux amd64 (Intel/AMD) und arm64 werden erkannt, das Archiv wird anhand der
Release-SHA256 geprueft. Vor Installation wird `syft version` ausgefuehrt.

```bash
bash scripts/tools/syft_install.sh --dry-run
bash scripts/tools/syft_install.sh
bash scripts/tools/syft_install.sh --check
```

Der Dry-Run fuehrt keine Downloads, Paketinstallation oder Scans aus.
apt wird nur fuer fehlende Basiswerkzeuge verwendet. Das Binary liegt unter
`/usr/local/bin/syft`; die Deinstallation entfernt nur diese Datei und bewahrt
SBOMs sowie Konfiguration. Der Installer startet keinen Scan automatisch.

Die 8397 MB freier Windows-Speicher im Log verursachen nicht den apt-Paketfehler.
Sie bleiben aber ein Engpass fuer WSL-Wachstum und spaetere Image-Scans/Downloads.
Der Installer prueft 256 MB Linux-Speicher. SBOMs koennen interne Pfade und
Paketinformationen enthalten und sollten gezielt gespeichert werden.
Ein echter Linux-Installationslauf steht noch aus.
