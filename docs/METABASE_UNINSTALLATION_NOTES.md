# Metabase: Permission denied bei der Deinstallation

## Gleicher Fehler bei Mosquitto und Node-RED

Die Deinstallationsskripte fuer Mosquitto (`/opt/mosquitto`) und Node-RED
(`/opt/node_red`) verwenden denselben korrigierten Helper wie Metabase.
Die sudo-Pfadpruefung und die Fehlerbehandlung gelten deshalb auch fuer diese
beiden Tools. Nach Uebernahme der Korrektur koennen ihre Deinstallationen
erneut ueber das Setup ausgefuehrt werden. Benoetigte MQTT-/Flow-Daten vorher
sichern: Die bestehende Deinstallation entfernt auch Tooldaten und Volumes.

Der Container wurde im Protokoll vom 7. Juni 2026 erfolgreich entfernt.
`rm: cannot remove '/opt/metabase': Permission denied` betrifft danach das
Installationsverzeichnis: Fuer dessen Entfernung sind Rechte am Elternordner
`/opt` erforderlich, auch wenn der Toolordner selbst dem Benutzer gehoert.

Der gemeinsame Helper `uninstall_git_docker_tool` verwendet jetzt sudo fuer
die Entfernung. Er akzeptiert nur direkte Toolverzeichnisse unter `/opt`,
lehnt Symlinks und abweichende aufgeloeste Pfade ab und bricht bei einem
fehlgeschlagenen Compose-Stop oder Loeschvorgang mit Fehlerstatus ab.
Erst nach erfolgreicher Entfernung wird das Tool als deinstalliert markiert.

Nach Uebernahme dieser Korrektur kann die Deinstallation erneut gestartet werden:

```bash
bash scripts/tools/metabase_uninstall.sh
```

Achtung: Die bestehende Deinstallation verwendet `docker compose down -v`
und entfernt danach den Installationsordner inklusive darin gespeicherter
Daten. Benoetigte Metabase-Daten vorher sichern. Diese Korrektur fuehrt selbst
keine Deinstallation aus und bereinigt keine Docker-Caches.
