# Flux CLI Installation Notes

## Was im Log passiert ist

Das gezeigte Log endet mit:

```text
[INFO] Installing flux to /usr/local/bin/flux
```

Das sieht nach erfolgreicher Installation aus. Was gefehlt hat, war ein klarer Nachtest:

```bash
flux --version
```

## Warum kein `curl | bash` mehr?

Der alte Installer nutzte:

```bash
curl -fsSL https://fluxcd.io/install.sh | sudo bash
```

Das ist bequem, aber fuer dieses Setup schlechter pruefbar. Der neue Installer laedt direkt das offizielle GitHub-Release-Binary von `fluxcd/flux2`, verifiziert die SHA256-Checksumme und installiert dann nach `/usr/local/bin/flux`.

## Intel, AMD und ARM

| Plattform | `uname -m` | Flux Asset |
| --- | --- | --- |
| Intel/AMD 64-bit | `x86_64`, `amd64` | `linux_amd64` |
| ARM64 / Raspberry Pi 5 / Oracle ARM | `aarch64`, `arm64` | `linux_arm64` |
| 32-bit ARM | `armv7l`, `armv6l` | `linux_arm` |

Intel und AMD nutzen also denselben `amd64`-Build. Raspberry Pi 5 und Oracle Ampere ARM nutzen `arm64`.

## Vorabpruefung

```bash
bash scripts/tools/flux_cli_install.sh --check
bash scripts/tools/flux_cli_install.sh --dry-run
```

## Feste Version installieren

```bash
FLUX_VERSION=v2.8.8 bash scripts/tools/flux_cli_install.sh
```

## Aus Source bauen?

Ein Build aus Source ist moeglich, aber fuer das Setup nicht der Standardpfad. Er benoetigt Go, mehr RAM und kann je nach Flux-Version andere Go-Versionen verlangen. Deshalb bleibt der sichere Standard:

1. offizielles GitHub-Release-Binary
2. Checksumme pruefen
3. `flux --version` ausfuehren

Source-Build sollte nur manuell und mit dokumentierter Go-Version erfolgen.

