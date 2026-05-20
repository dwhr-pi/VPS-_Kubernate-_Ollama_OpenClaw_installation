# Robotertechnik & Anlagensteuerung

Dieses Profil erweitert das Ultimate KI Setup um einen sicheren Robotik-, Anlagensteuerungs- und Simulationspfad fuer ROS 2, Gazebo, MoveIt 2, digitale Zwillinge, Anlagenmonitoring, Sensorik, Predictive Maintenance und industrielle Schnittstellen.

Der Standardmodus ist bewusst defensiv:

> Standardmodus: Simulation / Diagnose / Vorschlag.  
> Realmodus: nur mit Freigabe, Sicherheitsgrenzen und Hardware-Schutz.

KI darf in diesem Profil nicht als unkontrollierte Maschinensteuerung verstanden werden. Sie ist ein Robotik-Ingenieur-Assistent, Diagnosehelfer, Simulationsplaner und Protokollant, nicht der alleinige Entscheider fuer reale Aktoren.

## Kurzbeschreibung

Das Profil verbindet lokale KI mit technischen Systemen:

- Ollama analysiert Logs, Sensordaten und technische Dokumentation lokal.
- OpenClaw orchestriert Agenten fuer Planung, Diagnose, Simulation und Audit.
- n8n und Node-RED verbinden MQTT, OPC UA, Modbus, Home Assistant, Webhooks und Tickets.
- ROS 2, Gazebo, MoveIt 2, RViz, Nav2, Open-RMF und micro-ROS bilden den Robotik- und Simulationspfad.
- InfluxDB, Prometheus, Telegraf und Grafana bilden Messwert-, Monitoring- und Dashboard-Pfade.

## Zweck des Profils

Geeignet fuer:

- Robotik-Planung
- ROS-2-Integration
- Roboter-Simulation
- digitale Zwillinge
- Anlagenueberwachung
- Produktionszellen-Monitoring
- Sensorik-Auswertung
- Aktorik-Kontrolle mit Sicherheitsgrenzen
- Predictive Maintenance
- Flottensteuerung kleiner mobiler Roboter
- industrielle Schnittstellen wie OPC UA, MQTT, Modbus TCP und REST
- Home-Assistant- und n8n-Anbindung
- OpenClaw-Agenten fuer Diagnose, Planung, Freigabe und Protokollierung

## Nicht geeignete Aufgaben / Sicherheitsgrenzen

Nicht geeignet als Standardpfad:

- direkte Steuerung von Motoren, Roboterarmen, Foerderbaendern, Relais, Ventilen, Fraesen, Pumpen oder sonstigen gefaehrlichen Komponenten
- sicherheitskritische Entscheidungen nur durch ein LLM
- Umgehen von Hardware-Interlocks, Not-Aus, Grenzwerten oder Hersteller-Sicherheitslogik
- produktiver Industrieeinsatz ohne Fachpersonal, Risikobeurteilung und Normen-/Herstellerpruefung

Reale Aktoren duerfen nur angesteuert werden, wenn alle Bedingungen erfuellt sind:

1. expliziter Real-Hardware-Modus ist aktiviert
2. menschliche Freigabe ist erforderlich
3. Not-Aus-Konzept ist dokumentiert
4. Hardware-Interlocks sind vorhanden
5. Grenzwerte fuer Geschwindigkeit, Kraft, Temperatur, Strom, Spannung und Bewegungsraum sind definiert
6. jede Aktion wird protokolliert
7. Testlauf in Simulation wurde vorher erfolgreich durchgefuehrt
8. keine sicherheitskritische Funktion wird ausschliesslich durch ein LLM entschieden

## Empfohlene Open-Source-Tools

| Bereich | Tool | Aufgabe |
|---|---|---|
| Robotik-Basis | ROS 2 | Nodes, Topics, Services, Actions, Launch, URDF, tf2, rosbag, Security |
| Simulation | Gazebo / Gazebo Sim | virtuelle Testwelten, Sensor-/Aktor-Simulation, Kollisionspruefung |
| Bewegungsplanung | MoveIt 2 | Roboterarm, Kinematik, Trajektorien, Kollisionspruefung |
| Visualisierung | RViz | Roboterzustand, TF-Frames, Sensoren und Planung anzeigen |
| Navigation | Nav2 | mobile Roboter, Karten, Navigation, Pfadplanung |
| Flotten/Gebaeude | Open-RMF | Roboterflotten, Gebaeudeintegration, Ressourcenkoordination |
| Mikrocontroller | micro-ROS | ROS-nahe Firmware-Anbindung fuer kleine Controller |
| SPS/Test | OpenPLC | Lern-, Test- und Simulationsumgebung fuer IEC-61131-3-Logik |
| Kommunikation | MQTT | Sensordaten, Events, Home Assistant, Node-RED |
| Industrie | OPC UA | Anlagenstatus, SPS-/SCADA-nahe Schnittstelle |
| Industrie | Modbus TCP | einfache industrielle Register-/Sensoranbindung |
| Automation | n8n / Node-RED | Workflows, Grenzwertwarnungen, Tickets, Webhooks |
| Monitoring | InfluxDB / Telegraf / Prometheus / Grafana | Messwerte, Dashboards, Alerts, Historie |

## Empfohlene lokale Dienste

- `Ollama` fuer lokale Analyse, Zusammenfassung und Entscheidungsassistenz.
- `OpenClaw` fuer Agentenrollen, Sicherheits-Gates und Workflows.
- `Home Assistant` fuer sichere, lesende Smart-Home-/Sensorintegration.
- `n8n` fuer Automationsketten, Tickets, Benachrichtigungen und Datenfluesse.
- `Mosquitto` als lokaler MQTT-Broker.
- `Grafana` fuer Dashboards.
- `Prometheus` und/oder `InfluxDB` fuer Metriken.

## Zielarchitektur

```text
[Sensoren / SPS / OpenPLC / Robotercontroller]
        |
        |-- Modbus TCP / OPC UA / MQTT
        |
[Node-RED / n8n Gateway]
        |
        |-- Daten filtern
        |-- Grenzwerte pruefen
        |-- Alarme ausloesen
        |-- Schreibzugriffe blockieren oder freigeben
        |
[FUXA / Dashboard / Home Assistant optional]
        |
[OpenClaw Agent: Robotertechnik_Anlagensteuerung]
        |
        |-- Diagnose
        |-- Wartungsplan
        |-- Log-Auswertung
        |-- Simulationsvorschlag
        |-- Codex-/Script-Erzeugung
        |
[ROS 2 / Gazebo / MoveIt 2 Simulation]
        |
[Freigabe durch Nutzer]
        |
[Optional: reale Roboter-/Anlagensteuerung ueber sicheren Gateway]
```

## OpenClaw-Agentenrollen

### 1. Robotik-Planer

Aufgaben:

- erstellt Bewegungsablaeufe
- beschreibt Roboterzellen
- plant Simulationen
- erzeugt ROS-2-Launch-Dateien als Vorschlag
- erklaert Fehler in ROS-2-Nodes

### 2. Anlagen-Diagnose-Agent

Aufgaben:

- liest Logs
- erkennt ungewoehnliche Sensorwerte
- erstellt Wartungshinweise
- fasst Stoerungen zusammen
- erstellt Checklisten fuer Techniker

### 3. Simulations-Agent

Aufgaben:

- erzeugt Gazebo-Testwelten
- prueft Roboterbewegungen virtuell
- dokumentiert Kollisionen
- erstellt Testprotokolle

### 4. Sicherheits-Agent

Aufgaben:

- prueft Grenzwerte
- kontrolliert, ob Not-Aus und Interlocks dokumentiert sind
- verhindert riskante direkte Steuerbefehle
- erstellt Freigabeprotokolle

### 5. Anlagen-Monitoring-Agent

Aufgaben:

- sammelt Daten aus MQTT, OPC UA, Home Assistant oder n8n
- erstellt Zusammenfassungen
- erkennt Muster
- erzeugt Grafana-Dashboard-Vorschlaege

## Beispiel-Workflows

### Workflow 1: Roboterarm erst simulieren

1. Nutzer beschreibt Aufgabe.
2. OpenClaw erstellt Plan.
3. ROS 2/Gazebo simuliert Bewegung.
4. MoveIt prueft Bewegungsbahn.
5. Sicherheits-Agent prueft Grenzwerte.
6. Mensch gibt frei.
7. Erst danach darf ein realer Controller vorbereitet werden.

### Workflow 2: Anlagenueberwachung

1. Sensorwerte kommen per MQTT oder OPC UA.
2. n8n speichert Daten in InfluxDB.
3. Grafana zeigt Dashboard.
4. OpenClaw analysiert Abweichungen.
5. Ollama fasst Warnungen lokal zusammen.
6. Nutzer erhaelt Bericht.

### Workflow 3: Wartungsdiagnose

1. Logs werden eingesammelt.
2. KI erkennt wiederkehrende Fehler.
3. Diagnose-Agent erstellt moegliche Ursachen.
4. Sicherheits-Agent markiert kritische Zustaende.
5. n8n erstellt Ticket oder Wartungsnotiz.

### Workflow 4: Sprachbefehl nur als Vorschlag

1. Whisper transkribiert Sprache.
2. KI erkennt Absicht.
3. System erzeugt nur einen Vorschlag.
4. Nutzer muss bestaetigen.
5. Erst dann wird ein ungefaehrlicher Testbefehl ausgefuehrt.

## Beispiel-Ordnerstruktur

```text
profiles/
  robotik_anlagensteuerung/
    README.md
    agents/
      robotik_planer.md
      simulations_agent.md
      sicherheits_agent.md
      diagnose_agent.md
      monitoring_agent.md
    examples/
      ros2_gazebo_demo.md
      mqtt_sensor_monitoring.md
      opcua_anlagenstatus.md
      n8n_wartungsworkflow.md
    configs/
      robotik.env.example
      openclaw.robotik.example.json
      docker-compose.optional.yml
    scripts/
      check_robotics_stack.sh
      install_ros2_tools_optional.sh
      test_mqtt_sensor_flow.sh
```

## Beispiel-Konfiguration

```env
ROBOTICS_PROFILE_ENABLED=true
ROBOTICS_MODE=simulation
ROBOTICS_REAL_HARDWARE=false

ROS_DOMAIN_ID=42
ROS_LOCALHOST_ONLY=1

MQTT_HOST=127.0.0.1
MQTT_PORT=1883

OPCUA_ENDPOINT=opc.tcp://127.0.0.1:4840

OPENCLAW_AGENT_PROFILE=robotik_anlagensteuerung
OPENCLAW_SAFETY_GATE=true
OPENCLAW_REQUIRE_HUMAN_APPROVAL=true

OLLAMA_MODEL=llama3.2:3b
OLLAMA_BASE_URL=http://127.0.0.1:11434

LOG_LEVEL=info
AUDIT_LOG_ENABLED=true
```

Wichtig: `ROBOTICS_REAL_HARDWARE=false` ist der sichere Standard.

## n8n-Automationen

- MQTT/OPC-UA-Werte einsammeln und in InfluxDB schreiben.
- Grenzwertueberschreitungen an Telegram, Matrix, Email oder Ticket-System melden.
- Wartungsberichte nach Schichtende erzeugen.
- ROS-2-Logdateien zusammenfassen lassen.
- Simulationsberichte archivieren.
- Freigabe-Workflow fuer Realmodus mit zwei Schritten: Sicherheitscheck und menschliche Bestaetigung.

## Home-Assistant-Anbindung

Home Assistant sollte in diesem Profil standardmaessig nur lesend angebunden werden:

- Sensorstatus anzeigen
- Energie- und Temperaturdaten einbinden
- Benachrichtigungen ausloesen
- keine gefaehrlichen Aktoren ohne separates Safety-Gateway schalten

## ROS-2-/Gazebo-/MoveIt-Struktur

Empfohlener Start:

```bash
mkdir -p ~/robotics_ws/src
cd ~/robotics_ws
ros2 doctor
ros2 topic list
ros2 launch <paket> <simulation>.launch.py
```

Die offizielle ROS-2-Dokumentation beschreibt Installation, CLI, Launch, URDF, Gazebo-Simulation, Security und `ros2doctor`. Dieses Profil nutzt diese Bausteine nur als vorgeschlagene Struktur, nicht als automatische Komplettinstallation.

## OPC-UA-/MQTT-/Modbus-Anbindung

- MQTT fuer einfache Sensor- und Eventdaten.
- OPC UA fuer industrielle Status- und Prozessdaten.
- Modbus TCP fuer einfache Registerdaten.
- Schreibzugriffe werden durch Safety-Gates, Whitelists, Grenzwerte und Audit-Logging blockiert oder freigegeben.

## Logging und Audit

Jede sicherheitsrelevante Aktion braucht:

- Zeitstempel
- Nutzer / Agent / Workflow
- Modus: Simulation oder Realmodus
- Eingangsparameter
- Grenzwertpruefung
- Freigabeentscheidung
- Ergebnis
- Link zu Simulation oder Testprotokoll

## Sicherheitscheckliste vor Realbetrieb

- [ ] Laeuft der Workflow zuerst in Simulation?
- [ ] Gibt es einen physischen Not-Aus?
- [ ] Gibt es mechanische Begrenzungen?
- [ ] Sind Maximalgeschwindigkeit und Kraft begrenzt?
- [ ] Gibt es Strom-/Temperaturueberwachung?
- [ ] Gibt es Kollisionszonen?
- [ ] Ist menschliche Freigabe aktiviert?
- [ ] Werden alle Befehle geloggt?
- [ ] Kann die KI keine Sicherheitslogik ueberschreiben?
- [ ] Gibt es einen manuellen Fallback?
- [ ] Ist klar dokumentiert, welche Hardware real angeschlossen ist?

## Beispielprompts

```text
Analysiere diese ROS2-Fehlermeldung und schlage eine Loesung vor.
```

```text
Erstelle eine sichere Simulationsstruktur fuer einen kleinen Roboterarm mit Gazebo und MoveIt.
```

```text
Werte diese MQTT-Sensordaten aus und erkenne ungewoehnliche Muster.
```

```text
Erstelle einen n8n-Workflow, der Anlagenwerte sammelt, in InfluxDB speichert und bei Grenzwertueberschreitung warnt.
```

```text
Erstelle eine Sicherheitscheckliste fuer einen Roboterarm, der nur nach menschlicher Freigabe starten darf.
```

```text
Erstelle eine OpenClaw-Agentenrolle fuer einen Anlagen-Diagnose-Agenten.
```

## Erweiterungen fuer spaetere Versionen

- Open-RMF-Flottenkoordination
- micro-ROS-Testfirmware fuer ESP32/RP2040
- FUXA-/SCADA-Dashboard
- Foxglove Studio fuer ROS-Datenvisualisierung
- Kubernetes Worker fuer Simulationen
- Hardware-in-the-loop-Testumgebung
- Digital-Twin-Archiv mit Versionierung

## Quellen und Orientierung

- ROS 2 Dokumentation: Installation, CLI, Launch, URDF, Gazebo, Security, ros2doctor.
- Open-RMF: Flotten- und Gebaeudeintegration.
- micro-ROS: Mikrocontroller-Anbindung an ROS-2-nahe Systeme.
