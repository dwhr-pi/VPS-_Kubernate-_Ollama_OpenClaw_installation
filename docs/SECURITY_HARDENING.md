# Security Hardening

Diese Datei ist die kompakte Härtungsanleitung für das Setup.

## 1. Secrets niemals ins Repo

- keine `.env` mit echten Schlüsseln committen
- keine Wallet-Seeds, Private Keys, API-Tokens oder OAuth-Secrets ablegen
- nur Vorlagen wie `configs/.env.example` verwenden
- Secret-Scan vor Commit ausführen:

```bash
bash scripts/operations/security_scan.sh
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

Portübersicht:

```bash
bash scripts/operations/check_port_conflicts.sh
```

## 4. Host-Härtung

Empfohlene Basis:

- `UFW`
- `Fail2Ban`
- optional `CrowdSec`

Wichtig:
- SSH nicht unnötig offen lassen
- Passwort-Login nach Möglichkeit deaktivieren
- SSH-Keys bevorzugen

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

## 7. Trading und Web3

- Paper-Trading als Default
- keine Seed-Phrases speichern
- keine Private Keys im Klartext
- echte Börsen- oder Wallet-Zugänge erst nach bewusster Freigabe verwenden

## 8. Medien- und Dokumenten-Profile

- nur vertrauenswürdige Dateien importieren
- OCR-, PDF- und Office-Tools lokal verwenden, wenn Dokumente sensibel sind
- Audio-/Voice-Cloning nur mit Einwilligung und sauberer Lizenzlage nutzen

## 9. WSL2-Hinweise

- Docker-, GPU- und Netzwerkfreigaben in WSL2 bewusst konfigurieren
- Ports nicht unbemerkt von Windows nach außen durchreichen
- Speicher- und SSD-Bedarf bei Bild-/Video-Workflows früh prüfen
