# Privacy First Cloud Sync

Status: `planned`  
Hardwarebedarf: `medium` bis `server`  
Installationsart: lokal, VPS, NAS, Kubernetes spaeter

## Zweck

Eigene Cloud-, WebDAV- und Datei-Synchronisation als Alternative zu kommerziellen Diensten. Fokus: lokale Kontrolle, Verschluesselung und nachvollziehbare Backups.

## Kern-Tools

| Tool | Zweck | Status |
|---|---|---|
| Rclone | Cloud-/WebDAV-Sync | empfohlen |
| Syncthing | Peer-to-peer Dateisync | empfohlen |
| Nextcloud | Self-hosted Cloud | optional, schwerer Stack |
| Seafile | Alternative Team-Sync-Loesung | optional |
| WebDAV | Standard-Schnittstelle | empfohlen |
| age/gocryptfs/Cryptomator | Clientseitige Verschluesselung | empfohlen |

## Sicherheitsregeln

- Remote-Zugriff nur ueber Tailscale, Cloudflare Access oder Reverse Proxy mit Auth.
- Keine offenen Admin-Ports.
- Backups und Sync-Ziele getrennt behandeln; Sync ersetzt kein Backup.
