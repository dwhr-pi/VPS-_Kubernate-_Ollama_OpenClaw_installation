# Supabase: Docker-Socket-Berechtigung

Der Abbruch im Protokoll vom 6. Juni 2026 entsteht beim Zugriff auf
`/var/run/docker.sock`. Der bisherige Scaffold-Aufruf startete Compose direkt
in einer neuen Shell und nutzte den gemeinsamen sudo-Fallback nicht.

Supabase fuehrt die Nachinstallation jetzt ueber eine Funktion im Installer
aus und verwendet `run_docker_compose`. Ist Docker fuer den Benutzer nicht
direkt erreichbar, wird Compose mit sudo gestartet. Falls auch das scheitert,
wird das Tool nicht als erfolgreich installiert markiert.

```bash
bash scripts/tools/supabase_install.sh
```

Im Log sollte bei fehlenden Benutzerrechten stehen:
`Verwende sudo docker compose.` Das Passwort ist das lokale sudo-Passwort.
Die Socket-Rechte werden nicht aufgeweicht.

Der gemeinsame Docker-Helfer erkennt bestehendes Docker und waehlt bei Bedarf
die passende Paketfamilie. Supabase erzwingt nicht mehr `docker.io` neben einer
eventuell vorhandenen Docker-CE-/containerd.io-Installation.

Eine bestehende `/opt/supabase/docker/.env` wird nicht ueberschrieben.
Fehlt sie, wird `.env.example` kopiert und mit Dateirechten 600 versehen.
Die Upstream-Vorlage muss vor produktiver Nutzung mit eigenen Zugangsdaten
und dem passenden Netzwerkzugriff konfiguriert werden.
