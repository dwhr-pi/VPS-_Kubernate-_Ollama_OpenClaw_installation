# Capability- und Plattformmatrix

`implemented` bedeutet Code vorhanden; `tested` nennt immer einen konkreten Testumfang. Kein
pauschales `production_verified` in diesem Audit.

| Ziel                | Bash/Installer                                | Runtime/Build                                           | Kubernetes/GPU                           | Abnahmestand                                                             |
| ------------------- | --------------------------------------------- | ------------------------------------------------------- | ---------------------------------------- | ------------------------------------------------------------------------ |
| Ubuntu 24.04 x86_64 | Hauptziel, Quelle `p0-safety.yml`             | Private Toolchains, native Source-Builds                | K3s/NVIDIA gesonderte Infrastruktur      | Offline-Fixtures; echte Wegwerf-VM-/GPU-Abnahme offen                    |
| Ubuntu 22.04        | Teile von Ansible/Bash                        | Python-/glibc-/Go-/Node-Mindestversionen je Pin         | K3s nur nach Versionspruefung            | Nicht aus 24.04 ableiten                                                 |
| Debian/POSIX        | Teilweise gemeinsame Shelllogik               | apt/systemd/Library-Pfade sind nicht universelles POSIX | CNI/Runtime separat                      | Keine breite Debian-/BSD-Freigabe                                        |
| Windows nativ       | PowerShell-/Desktop-Optionen, getrennte Tools | Source-only ist kein fertiges Windows-Binary            | Kein nativer Linux-K3s-Host              | Hier ausgefuehrte Python-/Syntax-Fixtures sind keine Windows-App-Abnahme |
| WSL2                | Linux-Installer plus Host-Diskwache           | Linux- und Windows-Reserven getrennt                    | GPU-Weitergabe/Kernel/systemd gesondert  | Kein WSL-Zugriff in diesem Audit                                         |
| macOS               | Einzelne Upstream-Tools moeglich              | GNU-Utilities, ELF, apt, NVIDIA nicht annehmen          | Kein nativer Linux-/NVIDIA-Worker        | Toolweise Kandidat, nicht systemweit unterstuetzt                        |
| Raspberry Pi ARM64  | Je Installer/Artefakt                         | ARM64-Pins und Buildlimits pruefen                      | Kleine K3s-Workloads optional            | Kein x86-Artefakt oder CUDA-Profil ungeprueft verwenden                  |
| MiniPC              | Wenige Dienste, begrenzter Parallelismus      | RAM-/NVMe-/Thermalbudget                                | K3s nur bei echtem Orchestrierungsnutzen | Nicht als beliebig grosse GPU-Maschine behandeln                         |

Docker und Podman sind unterschiedliche Betriebsvarianten. Ein Compose-File belegt weder
Rootless-Podman-Unterstuetzung noch kompatible GPU-/Netzwerk-/Volume- Semantik. Native
GitHub-Toolinstaller werden nicht wegen dieser Varianten auf Container zurueckgestellt. Forgejos
freigegebene Codeberg-Ausnahme bleibt erhalten. GitLab-/Codeberg-Installer sind laut Nutzer noch
nicht installiert getestet.

Belege: `config/development_toolchains.json`, `config/docker_to_github.json`,
`scripts/tools/helpers/gap_tools.json`, `scripts/lib/private_go.py`,
`.github/workflows/p0-safety.yml`, `docs/tools/ai-game-engines-xr-wallpaper.md`.

## Plattformgate

Pro Tool Betriebssystem, Architektur, libc, Kernel, Service-Manager, GPU-Runtime, Dateirechte und
Artefaktherkunft pruefen. Danach Installation zweimal in einer Wegwerf-Umgebung, Abbruch/Resume,
fehlende Abhaengigkeit, Offline-/Timeoutfall, Uninstall mit erhaltener Nutzdatei und anschliessenden
Health-/Versionsnachweis. Ein erfolgreich kopierter Source-Baum ist lediglich eine
Quellenbereitstellung.
