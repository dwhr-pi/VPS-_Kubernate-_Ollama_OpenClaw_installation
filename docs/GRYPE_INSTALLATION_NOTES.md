# Grype Installation Notes

## Warum `apt install grype` fehlschlaegt

Ubuntu 24.04/Noble liefert in den Standard-Repositories kein offizielles Paket `grype`.
Der Fehler

```text
E: Unable to locate package grype
```

ist deshalb erwartbar, wenn der Installer `apt` verwendet.

## Stabiler Installationspfad

Das Setup installiert Grype ueber das offizielle GitHub-Release von Anchore:

```text
https://github.com/anchore/grype
```

Der Installer:

1. erkennt `amd64` oder `arm64`,
2. laedt das passende Release-Archiv,
3. laedt die Checksum-Datei,
4. prueft SHA256,
5. installiert `grype` nach `/usr/local/bin/grype`,
6. prueft `grype version`.

## Vorab pruefen

```bash
bash scripts/tools/grype_install.sh --check
bash scripts/tools/grype_install.sh --dry-run
```

## Feste Version

```bash
GRYPE_VERSION=v0.87.0 bash scripts/tools/grype_install.sh
```

## Sicherheit

Grype ist ein defensiver Schwachstellenscanner. Reports koennen Paketnamen, Pfade und interne Versionsstaende enthalten und sollten nicht unbedacht veroeffentlicht werden.

