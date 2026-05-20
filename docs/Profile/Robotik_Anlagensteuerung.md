# Robotik Anlagensteuerung

Das Profil `Robotik_Anlagensteuerung` erweitert das Ultimate KI Setup um Robotik, Anlagensteuerung, industrielle Automatisierung, Digital Twin, SCADA/HMI, SPS/PLC-Anbindung und KI-gestuetzte Diagnose. Es ist lokal-first fuer Ubuntu/WSL2 ausgelegt und kann spaeter ueber Tailscale/Cloudflare Access, Home Assistant und Kubernetes erweitert werden.

## Zweck

Dieses Profil hilft dabei:

- Roboterarme und mobile Roboter zuerst in Simulation zu testen.
- Anlagenzustaende zu ueberwachen.
- Sensordaten auszuwerten.
- Fehlerdiagnosen vorzuschlagen.
- Wartungsplaene und Checklisten zu erzeugen.
- Produktions- oder Laborablaeufe zu dokumentieren.
- einfache Automationsketten ueber n8n, Node-RED und MQTT auszuloesen.
- SCADA/HMI-Dashboards zu erstellen.
- ROS 2, MoveIt 2, Gazebo und `ros2_control` als Robotik-Basis vorzubereiten.
- OpenPLC, Modbus TCP, OPC UA und MQTT als industrielle Kommunikationsschicht zu beruecksichtigen.

## Sicherheitsregel: KI darf nicht direkt gefaehrliche Aktoren steuern

KI darf Vorschlaege machen, Diagnosen erstellen, Logs auswerten und Simulationen planen. KI darf im ersten Schritt nur lesend auf echte Anlagendaten zugreifen.

Schreibzugriffe auf SPS/PLC, Robotercontroller, Motoren, Ventile, Relais, Heizungen, Pumpen oder andere Aktoren muessen standardmaessig deaktiviert sein.

Jeder Schreibzugriff braucht:

- manuelle Freigabe.
- Rollen-/Rechtepruefung.
- Whitelist fuer erlaubte Befehle.
- Grenzwertpruefung.
- Protokollierung.
- Not-Aus-Konzept.
- mechanische und elektrische Sicherheit ausserhalb der KI.

Simulation geht immer vor Realbetrieb. Fuer echte Industrieanlagen muessen geltende Normen, Herstellerdokumentationen, Risikoanalysen und Fachpersonal beruecksichtigt werden.

## Empfohlene Komponenten

| Bereich | Tool | Aufgabe |
|---|---|---|
| Robotik-Basis | ROS 2 | Kommunikation, Nodes, Topics, Services, Robotik-Framework |
| Bewegungsplanung | MoveIt 2 | Roboterarm, Greifen, Kinematik, Trajektorienplanung |
| Controller | ros2_control | Controller-Manager, Hardware-Interfaces, Joint-State-Controller |
| Simulation | Gazebo | Digital Twin, Testumgebung, Sensor-/Aktor-Simulation |
| Visualisierung | RViz 2 | Roboterzustand, Sensoren, TF-Frames, Planung anzeigen |
| SPS/PLC | OpenPLC | Open-Source-SPS-Laufzeit und IEC-61131-3-Experimente |
| Industrieprotokolle | Modbus TCP / OPC UA / MQTT | Kommunikation zwischen Steuerung, Sensorik und Dashboard |
| Dashboard / HMI | FUXA oder Node-RED Dashboard | Prozessvisualisierung, Statusanzeigen, Alarme |
| Automation | n8n / Node-RED | Workflows, Benachrichtigungen, Ereignislogik |
| KI-Schicht | Ollama + OpenClaw | Diagnose, Planung, Dokumentation, Wartungsassistent |
| Sicherheit | Tailscale / Cloudflare Access / Firewall | Zugriff absichern |
| Logging | JSONL / SQLite / InfluxDB optional | Ereignisprotokoll, Messwerte, Fehlerhistorie |

## Architekturvorschlag

```text
[Sensoren / SPS / OpenPLC / Robotercontroller]
        |
        +-- Modbus TCP / OPC UA / MQTT
        |
[Node-RED / n8n Gateway]
        |
        +-- Daten filtern
        +-- Grenzwerte pruefen
        +-- Alarme ausloesen
        +-- Schreibzugriffe blockieren oder freigeben
        |
[FUXA / Dashboard / Home Assistant optional]
        |
[OpenClaw Agent: Robotik_Anlagensteuerung]
        |
        +-- Diagnose
        +-- Wartungsplan
        +-- Log-Auswertung
        +-- Simulationsvorschlag
        +-- Codex-/Script-Erzeugung
        |
[ROS 2 / Gazebo / MoveIt 2 Simulation]
        |
[Freigabe durch Nutzer]
        |
[Optional: reale Roboter-/Anlagensteuerung ueber sicheren Gateway]
```

## OpenClaw Agenten

| Agent | Aufgabe |
| --- | --- |
| `robotik-diagnose-agent` | Logs, Sensorwerte und Fehlermeldungen analysieren |
| `digital-twin-agent` | Simulationsszenarien fuer ROS 2/Gazebo planen |
| `wartungsplan-agent` | Checklisten, Wartungsintervalle und Ersatzteilhinweise erstellen |
| `scada-hmi-agent` | Dashboard-Struktur, Alarme und HMI-Texte vorschlagen |
| `plc-safety-review-agent` | PLC-/Modbus-/OPC-UA-Kommandos gegen Whitelist und Grenzwerte pruefen |
| `ros2-codex-agent` | ROS-2-Nodes, Launch-Files und Testskripte erzeugen |
| `anlagen-log-agent` | JSONL/SQLite/InfluxDB-Historie zusammenfassen |

## Ollama Aufgaben

- Fehlermeldungen und Logs erklaeren.
- Aufnahme-/Messplaene fuer Sensordaten vorschlagen.
- ROS-2-Launch-Dateien und Testskripte entwerfen.
- Wartungschecklisten generieren.
- HMI-Texte und Alarmbeschreibungen formulieren.
- Grenzwerttabellen und Freigabeprotokolle dokumentieren.

Geeignete Modellfamilien:

- `qwen2.5-coder` oder `deepseek-coder` fuer Python, ROS 2 und Skripte.
- `llama3.2`, `mistral` oder `gemma` fuer Diagnose, Doku und Checklisten.
- kleine `phi`/`gemma` Modelle fuer schnelle lokale Klassifikation.

## n8n / Node-RED Workflows

- MQTT- oder OPC-UA-Werte lesen und in JSONL/SQLite speichern.
- Grenzwertverletzung erkennen und Alarm senden.
- Wartungsreport automatisch als Markdown/PDF erzeugen.
- GitHub-Issue bei wiederkehrendem Fehler erstellen.
- Node-RED Dashboard oder FUXA-HMI aktualisieren.
- Schreibzugriff nur als separaten Freigabe-Workflow mit Whitelist und Auditlog.

## ROS 2 / Simulation

Empfohlener Ablauf:

1. Roboter- oder Anlagenmodell beschreiben.
2. URDF/Xacro oder vorhandenes Modell laden.
3. Gazebo-Simulation starten.
4. MoveIt 2 fuer Bewegungsplanung testen.
5. `ros2_control` nur gegen simulierte Hardware verwenden.
6. Erst nach Review, Risikoanalyse und manueller Freigabe an reale Hardware anbinden.

## Kubernetes / spaetere Skalierung

- Node 1: OpenClaw, Ollama, Diagnose-Agenten.
- Node 2: ROS 2/Gazebo Simulation.
- Node 3: Logging/InfluxDB/Grafana.
- Node 4: n8n/Node-RED/FUXA Gateway.
- Storage: gemeinsame Logs, Modelle, Konfigurationen und Simulationsartefakte.

Kubernetes eignet sich fuer Simulation, Auswertung, Dashboards und Datenerfassung. Direkte Echtzeitsteuerung echter Maschinen gehoert nicht als Standard in Kubernetes.

## Projektordner

```text
Ultimate_KI_Setup/robotics_control/
  configs/
  logs/
  jsonl/
  sqlite/
  ros2_ws/
  gazebo/
  moveit/
  dashboards/
  node_red/
  n8n/
  plc/
  modbus/
  opcua/
  mqtt/
  reports/
  safety/
```

## Erste lokale Vorbereitung

```bash
bash scripts/tools/robotik_anlagensteuerung_install.sh
cp config/robotik_anlagensteuerung.env.example .env.robotik
```

Der Installer bereitet Ordner, Python-Umgebung, MQTT-/Modbus-/OPC-UA-Clientbibliotheken und optionale Node-RED/n8n-Anschlussstruktur vor. ROS 2, MoveIt 2, Gazebo, FUXA und OpenPLC werden bewusst als groessere, systemnahe Schritte dokumentiert und nicht blind installiert.

## Grenzen

- Keine KI-Direktsteuerung fuer reale Anlagen.
- Keine Umgehung von Sicherheitsketten, Not-Aus, Verriegelungen oder Herstellerfreigaben.
- Keine Garantie fuer Normkonformitaet.
- Simulationen sind Annahmen, keine Abnahme.
- Fachpersonal bleibt Pflicht bei echten Maschinen.

