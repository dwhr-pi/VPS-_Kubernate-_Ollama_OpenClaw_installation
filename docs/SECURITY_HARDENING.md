# Security Hardening

Diese Datei ist die kompakte Härtungsanleitung für das Setup.

## 1. Secrets niemals ins Repo

- keine `.env` mit echten Schlüsseln committen
- keine Wallet-Seeds, Private Keys, API-Tokens oder OAuth-Secrets ablegen
- nur Vorlagen wie `configs/.env.example` verwenden
- Secret-Scan vor Commit ausführen:

```bash
bash scripts/operations/security_scan.sh
bash scripts/security/secret_scan.sh
```

## 2. Benutzer-Workspace nutzen

Sensible Dateien gehören in:

```bash
~/.openclaw_ultimate_user_data
```

Nicht in:

```bash
~/openclaw_ultimate_setup
```

## 3. Öffentliche Ports absichern

- Grafana, Open WebUI, LiteLLM, Home Assistant und MinIO nicht blind ins Internet hängen
- wenn extern nötig:
  - Reverse Proxy
  - Auth
  - HTTPS
  - Firewall-Regeln
  - Cloudflare-Tunnel-Policies
  - alternativ privater Zugriff über `Tailscale`

Portübersicht:

```bash
bash scripts/operations/check_port_conflicts.sh
bash scripts/security/port_exposure_audit.sh
```

## 4. Host-Härtung

Empfohlene Basis:

- `UFW`
- `Fail2Ban`
- optional `CrowdSec`
- optional `Tailscale` für privaten Admin-Zugriff ohne offene Panel-Ports

Wichtig:
- SSH nicht unnötig offen lassen
- Passwort-Login nach Möglichkeit deaktivieren
- SSH-Keys bevorzugen

Zusätzliche Audits:

```bash
bash scripts/security/firewall_audit.sh
bash scripts/security/docker_socket_audit.sh
bash scripts/security/env_permissions_audit.sh
```

## 5. Agenten mit Schreib- oder Shell-Rechten

Besonders riskant:

- Shell-MCP
- Browser-Agenten
- Filesystem-Agenten
- Trading-/Web3-Agenten

Regel:
- immer mit Safe-Mode starten
- niemals ungeprüft Schreibzugriff auf produktive Verzeichnisse geben
- keine API-Schlüssel oder Wallet-Operationen automatisch durch Agenten ausführen lassen

## 6. Cloudflare Tunnel

- nur die wirklich nötigen Ziele freigeben
- keine überbreiten Wildcard-Freigaben
- Tunnel-Tokens nicht im Repo speichern
- Policies und Identitätsregeln nutzen
- `cloudflared` nur für bewusst veröffentlichte Dienste verwenden, nicht als Ersatz für privaten Admin-Zugriff auf alles
- für die gemeinsame Einordnung mit `Tailscale` und `Hurricane Electric` siehe `docs/REMOTE_ACCESS_DNS_GUIDE.md`

## 6b. Tailscale

- sinnvoll für privaten Zugriff auf `SSH`, `Open WebUI`, `Grafana`, `Home Assistant`, `MinIO` oder andere Admin-UIs
- `tailscale up` bewusst manuell ausführen, damit Tailnet-Join und Freigaben nicht ungefragt automatisiert werden
- oft die sauberere Wahl, wenn kein öffentlicher Reverse-Proxy-Zugang benötigt wird
- ACLs, Key-Expiry und eventuelle Subnet-Router bewusst planen
- für die gemeinsame Einordnung mit `Cloudflare` und `Hurricane Electric` siehe `docs/REMOTE_ACCESS_DNS_GUIDE.md`

## 7. Trading und Web3

- Keine Haftung für Verluste oder sonstige verursachte Schäden.
- Das Setup ist keine Finanz- oder Anlageberatung.
- Paper-Trading als Default
- keine Seed-Phrases speichern
- keine Private Keys im Klartext
- echte Börsen- oder Wallet-Zugänge erst nach bewusster Freigabe verwenden
- keine autonomen Live-Orders durch LLMs oder Agenten zulassen
- Backtesting, Marktbeobachtung und Simulation vor echter Ausführung bevorzugen

Warum so streng:

- LLMs sind probabilistisch und können Trading-Begründungen halluzinieren
- ein einzelner Key-Leak kann Konten oder Wallets kompromittieren
- automatisierte Signale oder Empfehlungen können rechtliche Risiken erzeugen
- psychologisch entsteht schnell ein falsches Sicherheitsgefühl gegenüber KI-Ausgaben

Empfohlener Ansatz:

- Trading- und Web3-Profile primär für Analyse, Alerts, Simulation und Strategieprüfung nutzen
- echte Execution nur getrennt, manuell und mit ausdrücklicher Bestätigung ausführen
- Börsen-, Wallet- und RPC-Zugänge immer getrennt von normalen Agenten-Workflows behandeln

## 8. Medien- und Dokumenten-Profile

- nur vertrauenswürdige Dateien importieren
- OCR-, PDF- und Office-Tools lokal verwenden, wenn Dokumente sensibel sind
- Audio-/Voice-Cloning nur mit Einwilligung und sauberer Lizenzlage nutzen

## 9. WSL2-Hinweise

- Docker-, GPU- und Netzwerkfreigaben in WSL2 bewusst konfigurieren
- Ports nicht unbemerkt von Windows nach außen durchreichen
- Speicher- und SSD-Bedarf bei Bild-/Video-Workflows früh prüfen
