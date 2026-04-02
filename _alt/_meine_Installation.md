Die Installation von OpenClaw (früher bekannt als Clawdbot/Moltbot) auf Windows 11 ermöglicht es, einen KI-Agenten lokal oder via API zu nutzen. Basierend auf aktuellen Anleitungen aus dem Jahr 2026 ist dies der typische Prozess:

### Voraussetzungen
+ Node.js: Installieren Sie die aktuelle LTS-Version von nodejs.org.

+ Git: Installieren Sie Git für Windows von git-scm.com.

+ Optional (für volle lokale Ausführung): Ollama für lokale LLMs (vermeidet API-Kosten). 

### Installationsschritte (Windows 11)
+ Terminal öffnen: Öffnen Sie die PowerShell oder Eingabeaufforderung (CMD) als Administrator.
+ Code herunterladen: Klonen Sie das OpenClaw-Repository (die genaue URL kann je nach Update variieren, üblicherweise via GitHub). Und ggf. entpacken Sie im Arbeits-Verzeichnis. In diesem Verzeichnis müssen Sie auch die PowerShell als Admministrator ausführen. 
+ Abhängigkeiten installieren: Navigieren Sie in das entpackte Verzeichnis und führen Sie den Installationsbefehl aus (meist npm install oder pnpm install).
+ Konfiguration:
Erstellen Sie eine .env-Datei, um API-Keys (z.B. OpenAI oder Anthropic) zu hinterlegen.
+ Alternativ: Konfigurieren Sie Ollama für eine rein lokale Nutzung, um Kosten zu vermeiden.
+ Starten: Starten Sie den Bot mit npm start oder dem entsprechenden Befehl aus der Dokumentation.
Verbindung herstellen: Scannen Sie den QR-Code im Terminal mit Ihrem WhatsApp Business-Konto (verknüpfte Geräte), um den Bot zu aktivieren. 

#### Wichtige Hinweise
+ Update: Das Projekt wurde von Clawdbot/Moltbot zu OpenClaw umbenannt.
+ Alternative zur lokalen Installation: Sie können den Bot auch auf einem virtuellen Server (VPS) wie Hostinger installieren, um ihn 24/7 laufen zu lassen.
+ Hilfe: Im Terminal kann mit open-claw --version oder ähnlichen Befehlen die Installation überprüft werden. 
Es wird empfohlen, den Anleitungen in den Videobeschreibungen aktueller Tutorials zu folgen, da sich die Befehle aufgrund der Open-Source-Entwicklung schnell ändern können
