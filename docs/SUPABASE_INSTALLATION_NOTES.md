# Supabase: Docker-Socket-Berechtigung

Der Abbruch im Protokoll vom 6. Juni 2026 entsteht beim Zugriff auf `/var/run/docker.sock`. Der
bisherige Scaffold-Aufruf startete Compose direkt in einer neuen Shell und nutzte den gemeinsamen
sudo-Fallback nicht.

Supabase fuehrt die Nachinstallation jetzt ueber eine Funktion im Installer aus und verwendet
`run_docker_compose`. Ist Docker fuer den Benutzer nicht direkt erreichbar, wird Compose mit sudo
gestartet. Falls auch das scheitert, wird das Tool nicht als erfolgreich installiert markiert.

```bash
bash scripts/tools/supabase_install.sh
```

Im Log sollte bei fehlenden Benutzerrechten stehen: `Verwende sudo docker compose.` Das Passwort ist
das lokale sudo-Passwort. Die Socket-Rechte werden nicht aufgeweicht.

Der gemeinsame Docker-Helfer erkennt bestehendes Docker und waehlt bei Bedarf die passende
Paketfamilie. Supabase erzwingt nicht mehr `docker.io` neben einer eventuell vorhandenen
Docker-CE-/containerd.io-Installation.

Eine bestehende `/opt/supabase/docker/.env` wird nicht ueberschrieben. Fehlt sie, wird
`.env.example` kopiert und mit Dateirechten 600 versehen. Die Upstream-Vorlage muss vor produktiver
Nutzung mit eigenen Zugangsdaten und dem passenden Netzwerkzugriff konfiguriert werden.

## Download-Abbruch: connection reset by peer

Im Protokoll vom 14. Oktober 2026 wird die HTTPS-Verbindung beim Image-Download zurueckgesetzt. Das
beweist keinen Speicherfehler; moegliche Ursachen sind Netzwerk, Proxy/VPN, Registry/CDN oder eine
Zwischenstelle. Aus dem Log allein laesst sich der Verursacher nicht bestimmen.

Der Installer fuehrt jetzt vor dem Start `docker compose --parallel 1 pull` ueber den bestehenden
sudo-Fallback aus. Laut
[Docker-Dokumentation](https://docs.docker.com/reference/cli/docker/compose/#configuring-parallelism)
werden damit Images nacheinander gezogen. Einzelne Layer eines Images koennen weiterhin parallel
geladen werden; globale Daemon-Einstellungen werden nicht geaendert.

Bei erkannten Netzwerkfehlern gibt es maximal drei Versuche, mit 5 und 10 Sekunden Pause. Andere
Fehler, beispielsweise fehlende Rechte, fehlender Speicher oder falsche Image-Namen, werden nicht
automatisch wiederholt. Nach erfolgreichem Pull folgt `up -d --pull never`; so gibt es keinen
zweiten ungeplanten Pull waehrend des Starts. Kein Installiert-Status bei Pull-Fehlern.

Vorhandene Layer bleiben erhalten, aber Docker muss unvollstaendige Downloads gegebenenfalls erneut
laden. Es gibt kein garantiertes bytegenaues Resume. Nicht `/opt/supabase`, Volumes oder
Docker-Caches loeschen, nur weil der Download abgebrochen ist. Bestehende `.env` bleibt erhalten.
Nach Pruefung der Verbindung kann der aktualisierte Installer bewusst erneut gestartet werden.

TODO: echter Zielsystemtest, Zeitlimit pro Pull, Ressourcen-Preflight und Pruefung der
Gesundheitszustaende aller Supabase-Dienste. Ein erfolgreicher Compose-Start ist noch kein
vollstaendiger Funktionstest.
