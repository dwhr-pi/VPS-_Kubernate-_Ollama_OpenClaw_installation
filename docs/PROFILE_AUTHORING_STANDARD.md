# Profile Authoring Standard

Neue Profile werden erst dann als installierbare Menuepunkte aktiviert, wenn diese Mindeststruktur vorhanden ist.

## Pflichtfelder

Jedes Profil-Dokument unter `docs/Profile/` soll enthalten:

- Zweck
- Zielgruppe
- Ressourcenbedarf
- empfohlene Tools
- optionale Tools
- Ports
- Sicherheitsnotizen
- Installationsbefehl
- Testbefehl
- Deinstallationshinweis
- bekannte Fehler
- Reparaturhinweise

## Statusklassen

| Status | Bedeutung |
|---|---|
| `stable` | getestet, klein genug fuer Standardpfad |
| `beta` | nutzbar, aber mit Warnungen |
| `planned` | dokumentiert, noch kein stabiler Installer |
| `documentation-first` | Konzept/Backlog, nicht im Setup aktiv |
| `experimental` | nur mit expliziter Zustimmung |
| `gpu-only` | nur bei erkannter GPU sinnvoll |
| `vps-only` | nicht fuer lokale WSL2-Standardinstallation |
| `cluster` | Kubernetes/K3s/mehrere Nodes |

## Sicherheitsregeln

- Security-Profile sind defensiv, legal und autorisiert zu formulieren.
- Smart-Home-, Robotik-, Trading-, Security- und Browser-Agenten brauchen Human Approval fuer schreibende Aktionen.
- Keine Secrets, Tokens oder echten `.env`-Dateien im Profil.
- Ports als `127.0.0.1:<port>` dokumentieren, wenn kein Remotezugriff geplant ist.

## Aktivierungsregel

Ein Profil wird erst im Setup-Menue aktiviert, wenn vorhanden:

- Registry-Eintrag
- Doku
- Toolmapping
- Ressourcenwerte
- Portdoku
- Installer
- Uninstaller
- Doctor/Statuscheck
- Reparaturhinweise
