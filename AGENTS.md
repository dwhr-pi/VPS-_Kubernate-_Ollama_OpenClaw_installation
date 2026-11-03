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
