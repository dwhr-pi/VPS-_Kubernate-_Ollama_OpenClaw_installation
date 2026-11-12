# Desktop-Cockpit: Apps starten, Icons und Ressourcen anzeigen

**Ja: App-Kacheln mit Icons, lokale Programmstarts und eine getrennte Ressourcenansicht sind moeglich.**
Das erfordert einen eigenen begrenzten Launcher bzw. eine Desktop-Erweiterung neben Headlamp und Grafana.
Headlamp ist nicht bereits ein universeller Starter fuer Qwen, Gemini oder native Programme.

Stand: 2026-11-12. **Ausbauvertrag, noch kein implementierter Launcher.**
Es wurde kein URL-Protokoll registriert, kein lokaler Startdienst eingerichtet, kein Icon aus Benutzerordnern
ausgelesen und keine Anwendung gestartet. Die bestehenden Installer wurden durch diese Dokumentation nicht erweitert.
Die [Git-Source-Installationsrichtlinie](INSTALLATION_POLICY.md) und alle getrennten Freigaben bleiben verbindlich.

## Drei getrennte Ansichten

```text
OpenClaw-Cockpit
  Apps          -> freigegebene lokale App starten oder freigegebene Web-URL oeffnen
  Kubernetes    -> Headlamp, begrenzter read-only Clusterzugriff
  Ressourcen    -> Grafana, CPU/RAM/GPU/Storage und passende Workload-Metriken
```

Die Icons sollen in der App-Uebersicht und optional auf dem Desktop dasselbe gepruefte Bild verwenden.
Ein Desktop-Shortcut ist dabei nur eine Verknuepfung; das Dashboard braucht die gepruefte Bilddatei selbst.
Eine Web-App-Kachel darf nicht mit einer lokalen EXE, einem Studiencheckout oder Kubernetes-Pod verwechselt werden.

## Lokale Apps ueber eine URL starten

Es gibt zwei sinnvolle Ausbaustufen:

| Variante | Funktionsweise | Grenze |
| --- | --- | --- |
| Eigenes Desktop-Cockpit | Eine eng begrenzte native Funktion startet eine freigegebene Tool-ID | Nur vertrauenswuerdiger lokaler UI-Code erhaelt die Startberechtigung |
| Browser plus lokaler URI-Handler | Ein eigener Handler uebersetzt eine Tool-ID in einen lokal geprueften Programmeintrag | Registrierung und Bestaetigung noetig; Aufrufe koennen von fremden Webseiten stammen |

Fuer einen ersten nativen Ausbau ist ein eigenes Cockpit mit enger Start-Allowlist vorzuziehen.
Tauri ist eine moegliche Implementierung, aber keine neue freigegebene Abhaengigkeit oder fertige Anwendung.
Remote-Inhalte wie Grafana/Headlamp duerfen keine nativen Start-Capabilities des Cockpits erhalten.

Ein moegliches **eigenes, noch nicht registriertes** Schema waere:

```text
openclaw-launch://app/qwen_desktop_build
```

Dies behauptet kein existierendes Qwen- oder Gemini-Protokoll. Der eigene Handler wuerde die ID ausschliesslich
gegen seinen lokalen, vorher freigegebenen Katalog aufloesen. In die URL gehoeren **keine** EXE-Pfade,
Shellbefehle, Argumente, Dateien, Tokens oder Prompts. Unbekannte IDs, Query-Strings und Fragmente ablehnen.
Die ID allein darf noch keinen Start ausloesen: pro Aufruf eine sichtbare lokale Bestaetigung verlangen.
Eine URI kann von jeder Webseite aus aufgerufen werden; die angebliche Herkunft ist kein Vertrauensnachweis.
Keine GET-URL wie `http://localhost:PORT/run?command=...` als universellen Startdienst anbieten.

Ein Web-Cockpit auf dem VPS startet dadurch nicht einfach Programme auf deinem Windows-PC.
Der gepruefte Handler muss auf dem Ziel-PC vorhanden sein. Ein Desktop-Cockpit auf Rechner A startet nicht
ohne separates Remote-Ausfuehrungskonzept Apps auf Rechner B. Remote-Starts sind nicht Teil dieses Vertrags.

## Was der Setup-Installer kuenftig beitragen muss

Ein neuer gemeinsamer, **opt-in** Registrierungsadapter soll nach einer nachgewiesenen Installation bzw.
einem geprueften nativen Build aufgerufen werden. Er gehoert nicht in den Plan-/Status-/Check-Pfad.
Er soll fuer Windows und Linux getrennte, benutzerspezifische Kataloge verwalten, nicht das Desktop-Verzeichnis scannen.

| Information | Zweck |
| --- | --- |
| Schema-Version, Registry-Tool-ID und lokale Installations-ID | Eindeutige Zuordnung auch bei mehreren Varianten/Versionen |
| Zielplattform und Rechnerzuordnung | Windows-Installation nicht mit Linux/WSL oder einem VPS verwechseln |
| Version, Source-Pin und Installationsnachweis | Clone/Marker/manuelle Bestaetigung nicht als Runtime-Nachweis behandeln |
| Kanonischer EXE-/Programm-Pfad und SHA256 | Nur das freigegebene Artefakt starten, keine Aufloesung ueber beliebige PATH-Eintraege |
| Geprueftes Arbeitsverzeichnis | Keine zufaellige Vererbung aus Browser oder fremdem Projekt |
| Icon-Datei, Hash, Herkunft und Lizenzhinweis | Dasselbe Bild fuer Dashboard und optionalen Desktop-Shortcut |
| Freigabestatus, Pruefzeitpunkt und Startbestaetigung | Installation und Startrecht getrennt behandeln |

Private Laufzeitkataloge gehoeren ausserhalb von Git, z. B. in ein benutzergeschuetztes Unterverzeichnis von
`~/.openclaw_ultimate_user_data` oder unter Windows `%LOCALAPPDATA%\OpenClaw\dashboard`.
Keine EXE-Pfade, Benutzerverzeichnisse oder Zugangsdaten an einen oeffentlichen Dashboard-Server weitergeben.
Die sichtbare Kachelliste erhaelt nur eine begrenzte Projektion aus Name, ID, Status und freigegebenem Icon.

Ein noch nicht freigegebener Katalogeintrag koennte so aussehen; dies ist kein bestehendes Dateiformat:

```json
{
  "schema_version": 1,
  "tool_id": "qwen_desktop_build",
  "installation_id": "local-example",
  "platform": "windows",
  "installation_status": "unverified",
  "executable": null,
  "executable_sha256": null,
  "icon_asset": null,
  "icon_sha256": null,
  "launch_enabled": false,
  "confirmation_required": true
}
```

Ein Hash allein ist kein Vertrauensnachweis. Der Adapter muss Source-/Build-Herkunft, Dateiart, Besitzer/Rechte
und Links/Junctions pruefen. Unverifizierte Eintraege bleiben deaktiviert.
Vorhandene Fremdeintraege nicht ueberschreiben.
Beim Update Artefakt und Icon erneut pruefen; bei fehlendem/veraendertem Programm den Start sperren.
Beim Uninstall nur den eigenen Launcher-Eintrag und eigens erzeugte Verknuepfungen entfernen,
keine Benutzerprofile, Cookies, Modelle oder sonstigen Daten loeschen. Keine automatischen App-Starts als Smoke-Test.

### Konkreter Bestand: Qwen und Gemini

- [Qwen Desktop](tools/qwen-desktop-windows.md): manueller Windows-Einstieg und separater nativer Buildweg vorhanden.
  `scripts/windows/qwen_desktop.ps1` prueft einen Installer, registriert aber keinen Dashboard-Start.
  Der Buildweg `scripts/windows/qwen_desktop_build.ps1` ist ebenfalls kein universeller Launcher.
- Qwen-Studienquellen und `ready.json` allein duerfen keine startbare App-Kachel ergeben.
  Der Adapter muss den tatsaechlichen gebauten und freigegebenen Programmeinstieg nachweisen.
- [Gemini-Desktop-Clients](tools/gemini-desktop-clients.md): die eingetragenen Drittanbieter-Webwrapper sind
  weder Gemini CLI noch pauschal offizielle Google-Desktop-Clients.
  Ein manueller Download-/Studienpfad ist kein Startrecht.
  Die in der bestehenden Anleitung beschriebenen Pflege-/Legacy-Risiken vor einer Freigabe erneut pruefen.
  Nicht jede vorhandene Gemini-Variante automatisch in die Start-Allowlist uebernehmen.

## Icons sicher uebernehmen

- Vorzugsweise das Icon aus dem geprueften Source-/Build-Artefakt verwenden, nicht beliebige Desktop-Links ausfuehren.
- Fuer die Anzeige ein geprueftes PNG bzw. kontrolliert konvertiertes ICO mit begrenzter Groesse bevorzugen.
- Keine ungeprueften aktiven SVG-/HTML-Inhalte und keine automatischen externen Icon-Downloads laden.
- Falls ein Icon aus einer signierten EXE extrahiert wird: nur mit geprueftem Parser, niemals die EXE dazu ausfuehren.
- Ohne verfuegbares/lizenzrechtlich nutzbares Icon ein neutrales lokales Ersatzsymbol anzeigen.
- Keine beliebigen lokalen Dateipfade per Dashboard-URL bereitstellen; Zugriff auf den Iconbestand begrenzen.

## Weitere Uebersicht: Prometheus CPU, RAM, GPU und Kubernetes

**Ja: Ein eigener Ressourcen-Reiter kann vorhandene Grafana-Dashboards oeffnen oder eine begrenzte Ansicht zeigen.**
Der erste Schritt ist ein Link auf die bestehende private Grafana-Oberflaeche, nicht eine neue Monitoring-Installation.
Das vorhandene [LLMOps-JSON](../monitoring/grafana/dashboards/llmops.json) enthaelt bereits CPU, RAM, Disk und GPU.
Das [All-Tools-Paket](monitoring/ALL_TOOLS_OBSERVABILITY.md) ergaenzt Tool-Ziele, Abdeckung und Alarme.
Grafana importieren/aktivieren und Exporter abnehmen bleiben gesonderte Aufgaben; hier werden keine Metriken abgefragt.

| Anzeige | Datenquelle | Wichtige Grenze |
| --- | --- | --- |
| Linux-Host CPU/RAM/Dateisystem | Node Exporter -> Prometheus -> Grafana | Richtigen VPS/Worker waehlen, nicht alle Hosts als Desktop ausgeben |
| Kubernetes-Pod CPU/RAM | kubelet/cAdvisor, Labels ueber kube-state-metrics | Clusterzugriff und Scrape-Vertrag gesondert einrichten |
| NVIDIA GPU/VRAM/Temperatur | DCGM Exporter | Nicht automatisch eine Zuordnung zu einzelnen Desktop-Apps |
| Windows-Host CPU/RAM | Separat gepruefter Windows Exporter oder begrenzter nativer Collector | Linux-/WSL-Werte sind keine vollstaendigen Windows-Host-Werte |

Pro Standort/Cluster/Node filtern und Einheiten unterscheiden: CPU-Prozent, CPU-Kerne und Load sind nicht dasselbe.
Fehlende Exporter oder ein ausgeschalteter WoL-Worker ergeben `keine Daten`, nicht null Last oder einen gesunden Dienst.
Eine Host-Auslastung ist noch keine Messung des einzelnen Qwen-/Gemini-Prozesses.

Fuer echte eingebettete Panels muessen Grafana-Authentifizierung, Frame-/Cookie-/CSP-Vorgaben und Berechtigungen passen.
Nicht anonymen Zugriff, oeffentliche Snapshots oder pauschale Embedding-Freigaben als Abkuerzung einschalten.
Ein Ressourcen-Tab darf Remote-Inhalte anzeigen, aber keine lokalen Startberechtigungen an diese Inhalte vererben.
Alternativ koennen spaeter freigegebene feste PromQL-Abfragen ueber einen read-only Backend-Adapter laufen:
keine Tokens im Frontend, keine frei uebergebenen Prometheus-Zieladressen, begrenzte Zeitraeume und Abfrageraten.
Prometheus nicht oeffentlich ins Internet stellen; vorhandene private Zugaenge erhalten.

## Umsetzungsreihenfolge und Abnahme

- [ ] Zuerst App-/Kubernetes-/Ressourcen-Reiter und einen neutralen Iconbestand ohne Startfunktion vorbereiten.
- [ ] Gemeinsames Katalogschema und opt-in Installer-Adapter implementieren; nur synthetische Fixtures verwenden.
- [ ] Qwen-Buildweg als ersten konkreten Adapter testen; manuelle und Source-only Varianten deaktiviert halten.
- [ ] Native Startfunktion mit fester ID-Allowlist und sichtbarer Bestaetigung separat implementieren.
- [ ] Negative Tests: manipulierte IDs/Argumente, Pfadwechsel, fremde Links, entfernte EXE und Startflut ablehnen.
- [ ] Erst danach optionalen URI-Handler registrieren; fremde Webseiten duerfen keinen stillen Start erreichen.
- [ ] Update/Uninstall muessen idempotent sein und fremde Eintraege/Benutzerdaten erhalten.
- [ ] Ressourcenansicht mit bekannten Messwerten, Zielwechsel und Ausfall der Datenquelle abnehmen.
- [ ] Weitere Clients erst nach eigener Sicherheits-/Lizenz-/Artefaktpruefung freischalten.

Noch offen: gemeinsames Cockpit, Registrierungsadapter, Iconuebernahme, Launcher, URI-Handler und Runtime-Abnahme.
Diese Checkliste ist ein umsetzbarer Vertrag, kein Nachweis bereits vorhandener Features.

## Quellen

- [Windows: URI-Aktivierung und Sicherheitsgrenzen][win-uri]
- [Tauri: begrenzte Capabilities](https://v2.tauri.app/security/capabilities/)
- [Grafana: Links und eingebettete Panels][grafana-share]
- [Windows Exporter: native Host-Metriken](https://github.com/prometheus-community/windows_exporter)
- [Dashboard-Einstieg und Boardroom](TOOL_DASHBOARD_BROWSER_DESKTOP.md)

[win-uri]: https://learn.microsoft.com/en-us/windows/apps/develop/launch/handle-uri-activation
[grafana-share]: https://grafana.com/docs/grafana/latest/visualizations/dashboards/share-dashboards-panels/
