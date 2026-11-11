# Maintainer-Vorgaben

## Installation

- Tools und Programme bevorzugt aus ihren Git-Quellen herunterladen, pruefen, nativ bauen und installieren.
- Keine Docker-/Compose-Installation und kein Docker-basierter Installations-Fallback.
- Reviews/Warnungen sind kein Auftrag, den Git-Installationsweg pauschal zu entfernen oder durch Docker zu ersetzen.
- Integritaets-, Besitz-, Pfad- und Ressourcenpruefungen bleiben verbindlich; bei Fehlern den konkreten Versuch stoppen.
- Fehlende native Buildrezepte ehrlich als offen melden; ein Clone allein ist keine fertige Runtime.
- apt nur fuer System-/Build-Abhaengigkeiten. Bestehende genehmigte Quellen-/Basis-Toolchain-Ausnahmen beibehalten.
- Vorhandene Container, Volumes und Benutzerdateien nicht wegen dieser Richtlinie entfernen.
- Keine automatischen Dienst-/Modell-/Tunnel-/Clusterstarts. Kubernetes-CRI ist keine Docker-Installationsfreigabe.

Verbindliche Details: [Installationsrichtlinie](docs/INSTALLATION_POLICY.md).
Abnahmen und offene Grenzen: [F01-F07](docs/F01_F07_IMPLEMENTATION.md).

## Sicherheit und Nachweise

- Secrets bleiben ausserhalb des Repos; keine Zugangsdaten ausgeben oder in Tests verwenden.
- Benutzerdaten unter `~/.openclaw_ultimate_user_data` erhalten; keine destruktiven Git-/Uninstall-Abkuerzungen.
- Metadaten/Fixtures nicht als echte Build-, Runtime-, Alarmierungs- oder Restore-Abnahme ausgeben.
- Dokumentation auf Deutsch, neue Code-Kommentare auf Englisch.

## Vertrag fuer neue Tool-PRs

- GitHub-Source-URL, voller Commit-Pin und SHA256 fuer Buildartefakte/Downloads;
  Build-Lockfiles und SBOM benoetigen einen nachvollziehbaren Erzeugungspfad.
- Native systemd-Unit oder K8s-Manifest, falls ein Dienst vorgesehen ist.
  Reine CLI-/Desktop-/Dokumentationswerkzeuge begruenden Nichtanwendbarkeit.
- Begrenzter Smoke-Test, Doctor-Check, idempotenter Uninstall und deutsche
  SSH-Anleitung. Marker und Klone sind kein Runtime-Nachweis.
- Kein automatischer Start, Modell-Pull, Provider-Test oder Secret-Zugriff
  fuer Dokumentations-/Diagnosebefehle. Nicht implementierte Pfade explizit
  als offen markieren statt Erfolg vorzutaeuschen.
- Neue Diagnose: `scripts/doctor.sh` und `scripts/smoke-test.sh` sind offline
  standardmaessig unvollstaendig (Exit 3). Runtime nur explizit auswaehlen.
