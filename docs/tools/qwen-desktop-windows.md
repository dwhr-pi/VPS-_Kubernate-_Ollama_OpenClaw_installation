# Qwen Desktop unter Windows: der richtige Einstieg

Geprueft am **15.10.2026**. Im Setup heisst der Eintrag **Qwen_Desktop**
und meint **Qwen Code Desktop**, die grafische Coding-Anwendung des
offiziellen Projekts [QwenLM/qwen-code](https://github.com/QwenLM/qwen-code).
Code-Lizenz: [Apache-2.0](https://github.com/QwenLM/qwen-code/blob/main/LICENSE);
Modelle, externe Dienste und Abhaengigkeiten separat pruefen.

## 1. Drei verschiedene Anwendungen auseinanderhalten

| Name | Zweck | Richtiger Einstieg |
|---|---|---|
| Qwen Code Desktop | Grafischer Coding-Agent fuer Projektdateien, Patches und Tests | [Offizieller Desktop-Download](https://github.com/QwenLM/qwen-code/releases/tag/desktop-latest) |
| Qwen Code CLI | Terminal-Oberflaeche derselben Agentenfamilie | [Quellcode/CLI-Anleitung](https://github.com/QwenLM/qwen-code) |
| Qwen Chat / Qwen Studio | Chat-/Multimodal-Client, nicht automatisch dieselbe Coding-App | [Offizielle Qwen-Downloadseite](https://qwen.ai/download) |

QwenWork ist wiederum ein gesonderter Produktname; dessen Installer,
Speicheranforderungen und Anmeldung nicht auf Qwen Code Desktop uebertragen.
Keine beliebige Community-App namens "Qwen Desktop" als offiziell ausgeben.
Ein Web-Wrapper ist auch nicht automatisch ein lokaler Modellserver.

**Ja, es gibt die Coding-Desktop-App fuer Windows.** Die offizielle
[README](https://github.com/QwenLM/qwen-code/blob/main/README.md) verlinkt sie
gesondert fuer Windows/macOS/Linux. Linux-Unterstuetzung dieser Coding-App
nicht mit Linux-Verfuegbarkeit des separaten Chat-/Studio-Clients gleichsetzen.
Eine pauschale Open-Source-Freigabe aller Desktop-/Android-Qwen-Produkte
ist damit nicht belegt. Android-APK-Quellen/Lizenzen getrennt pruefen;
die Windows-EXE ist keine Android-App.

## 2. Was du auf Windows brauchst

- Einen Windows-Rechner mit zur Release-Datei passender Architektur.
  Der hier gepruefte Windows-Installer ist **x64**, nicht ARM64.
- Internet fuer Download und gegebenenfalls Provider-Anmeldung/API.
  Fuer einen spaeter rein lokalen Betrieb vorher Downloads/Telemetrie pruefen.
- Freien Platz fuer App, Updates, Projekte und Caches; lokale Modellgewichte
  brauchen zusaetzlichen Speicher. Keine aus fremden Produktseiten
  uebernommene RAM-/500-MB-Mindestgarantie.
- Fuer die Oberflaeche allein keine zugesicherte NVIDIA-/CUDA-Pflicht.
  RAM/VRAM-Bedarf entsteht insbesondere beim gewaehlten lokalen Modell.

**Keine WSL- oder Docker-Pflicht.** Nicht zuerst Ubuntu oder ein npm-Paket
installieren, wenn du einfach die Windows-GUI willst. Der Desktop hat
einen paketierten Runtime-Pfad; bei fehlenden Laufzeitkomponenten nur den
aktuellen offiziellen Release-Hinweisen folgen, nicht fremde DLLs nachladen.

## 3. Schritt fuer Schritt installieren

1. Oeffne [Download Qwen Code Desktop](https://github.com/QwenLM/qwen-code/releases/tag/desktop-latest).
   Pruefe oben den Herausgeber/Repositorynamen **QwenLM/qwen-code**.
2. Scrolle zu **Assets**. Waehle den Windows-Installer, nicht Source code,
   SDK, nightly oder ein macOS-/Linux-Paket.
3. Ein konkret geprueftes Beispiel ist
   [Desktop v0.25.2](https://github.com/QwenLM/qwen-code/releases/tag/desktop-v0.25.2):
   `Qwen-Code-Desktop_0.25.2_x64-setup.exe`.
   Bei einer anderen Version immer deren zugehoerige Pruefsummen verwenden.
4. Lade den Installer und die zugehoerigen Pruefsummen aus demselben Release
   bewusst im Browser herunter. Das Setup erledigt das nicht heimlich.
5. Pruefe Hash, Signatur und Herausgeber wie im naechsten Abschnitt.
   SmartScreen/Antivirus nicht pauschal deaktivieren oder Warnungen umgehen.
6. Erst nach erfolgreicher Pruefung die EXE selbst per Doppelklick starten.
   Installationsdialog lesen; keine ungeprueften Administratorrechte freigeben.
7. Nach Abschluss im Startmenue nach **Qwen Code Desktop** suchen und starten.
   Falls der Installer eine Desktop-Verknuepfung anbietet, kannst du sie waehlen.
8. Fuer schnellen Zugriff: Startmenue-Eintrag rechts anklicken und
   **An Taskleiste anheften** waehlen, falls Windows diese Option dort anbietet.

So verwendest du die Anwendung nativ auf deinem Windows-Desktop, nicht
ueber einen Linux-Dienst. Kein Download oder Installationsschritt wurde
fuer diese Dokumentation lokal ausgefuehrt.

## 4. Installer lokal pruefen, nicht starten

PowerShell im Setup-Arbeitsverzeichnis oeffnen:

```powershell
# Zeigt nur den Plan, kein Netzwerk und kein Programmstart:
.\scripts\windows\qwen_desktop.ps1 -Action Plan
```

Fuer das oben genannte, unveraenderte **v0.25.2-x64-Paket** veroeffentlicht
GitHub SHA-256:
`f6257e577c014244f660620e7f84e288ba17f2bb78486f81065a4e8f42dbd69c`.
[Release-Assets mit Digests](https://github.com/QwenLM/qwen-code/releases/expanded_assets/desktop-v0.25.2).

```powershell
# Pfad durch deine bereits heruntergeladene Datei ersetzen:
.\scripts\windows\qwen_desktop.ps1 -Action CheckInstaller `
  -InstallerPath "$HOME\Downloads\Qwen-Code-Desktop_0.25.2_x64-setup.exe" `
  -ExpectedSha256 "f6257e577c014244f660620e7f84e288ba17f2bb78486f81065a4e8f42dbd69c"
```

Der Helfer liest nur diese Datei: Hash muss passen und Authenticode muss
`Valid` melden. Er zeigt den Signaturinhaber, prueft aber dessen Identitaet
nicht gegen eine hinterlegte Publisher-Allowlist. Auch ein gueltig
signiertes Programm eines falschen Anbieters ist nicht automatisch richtig.
Bei fehlender/ungueltiger Signatur oder Hash-Abweichung stoppen und klaeren.
Die separate `.sig` eines Tauri-Updaters ist nicht dasselbe wie Authenticode.
Kein Download, Installerstart, Entsperren oder ExecutionPolicy-Bypass enthalten.
Falls PowerShell die Skriptausfuehrung blockiert, nicht die globale Policy
abschalten; Hash/Signatur alternativ ueber Windows-Dateieigenschaften bzw.
`Get-FileHash`/`Get-AuthenticodeSignature` manuell kontrollieren.

## 5. Erster sicherer Coding-Auftrag

1. Oeffne bewusst einen vorhandenen, freigegebenen Windows-Projektordner,
   nicht dein gesamtes Benutzerprofil, Backupverzeichnis oder Secret-Verzeichnis.
2. Lies die erste Vertrauens-/Berechtigungsabfrage. Auto-Approve,
   unbegrenzte Agentenschleifen, Computersteuerung, LAN-Sharing und fremde
   MCP-Server nicht zum Einstieg aktivieren.
3. Beginne mit einem nur lesenden Auftrag:

```text
Erklaere die Struktur dieses Projekts. Veraendere keine Dateien, installiere
nichts, starte keine Terminalbefehle und greife nicht auf WSL zu.
Nenne anschliessend einen kleinen Verbesserungsvorschlag.
```

4. Erst danach einen kleinen Patch vorschlagen lassen; Diff lesen,
   konkrete Aenderung und konkrete Tests einzeln freigeben.
5. Keine automatischen Commits, Pushes oder Installationen. Ein Agent
   mit Toolrechten kann echte Dateien veraendern; ein Prompt allein
   ersetzt keine technischen Berechtigungsgrenzen.

## 6. Modelle und andere APIs anschliessen

Qwen Code ist nicht auf Qwen-Gewichte beschraenkt.
Die [Provider-/Authentifizierungsdoku](https://github.com/QwenLM/qwen-code/blob/main/docs/users/configuration/auth.md)
beschreibt OpenAI-kompatible, Anthropic- und Gemini-Pfade sowie
Drittanbieter wie OpenRouter. Dialognamen/unterstuetzte Features der
paketierten Desktop-Version muessen im konkreten Build geprueft werden.
CLI-Beispiele nicht blind als identische Desktop-Menues ausgeben.

| Gewuenschter Pfad | Im Client konfigurieren / Grenze |
|---|---|
| Lokal mit vorhandenem Ollama | Custom/OpenAI-kompatibler Provider, Basis `http://127.0.0.1:11434/v1`, exakt vorhandener Modellname |
| OpenRouter | zugehoeriger Provider bzw. Basis `https://openrouter.ai/api/v1`, eigener Key und explizites Modell-/Kostenlimit |
| OpenAI / Anthropic / Gemini | passendes Protokoll und eigener autorisierter API-Zugang; keine Chat-Cookies als API-Key verwenden |

Lokaler Client bedeutet nicht lokale Inferenz. Keine vertraulichen Dateien
an Cloud-Provider senden, ohne das bewusst freizugeben.
Nicht jeder kleine Ollama-Checkpoint kann verlaesslich Tools aufrufen;
erst Lesen, strukturiertes Ergebnis und eine harmlose Testaufgabe pruefen.
Eine lokale Dummy-Authentifizierung ist kein Schutz fuer eine offene Ollama-API.
Windows-Loopback nur dann benutzen, wenn der vorhandene Server dort wirklich
erreichbar ist. Bei getrennten Hosts VPN/Authentifizierung planen, nicht
`OLLAMA_HOST=0.0.0.0` als schnelle Loesung setzen.

Der aktuelle Auth-Leitfaden meldet den frueheren Qwen-OAuth-Free-Tier als
eingestellt. Keine kostenlose Dauerquote oder feste Cent-/Monatskosten
versprechen. Tarife und Datenschutz jeweils vor Nutzung aktuell pruefen.
Keys nur privat ausserhalb Git, minimal berechtigen, nie ins Chatfenster,
Screenshot, Terminal-History oder gemeinsame Logs kopieren.
Ein `.env`-Eintrag allein bedeutet nicht, dass die Desktop-App ihn laedt.

## 7. CLI, Linux und Android

- CLI ist eine Alternative, keine Voraussetzung fuer den manuellen GUI-Start.
  Die aktuelle README nennt `@qwen-code/qwen-code`; das im Anhang genannte
  `@qwen-code/cli` nicht ungeprueft installieren. Keine `curl|bash`- oder
  `irm|iex`-Einzeiler in dieser Anleitung.
- Linux: derselbe gepruefte Desktop-Release bietet AppImage-/DEB-Dateien
  fuer die dort angegebenen Architekturen. Nicht in deiner WSL einrichten;
  keine Desktop-Installation auf dem headless Oracle-VPS voraussetzen.
- Android: Desktop-Code/-Lizenz beweist keine offene native Android-App.
  Web-/Remote-Steuerung ist eine andere Betriebsart; LAN-/QR-Sharing bleibt
  im Setup aus. Open WebUI als vorhandenen privaten Webclient getrennt planen.

## 8. Updates, Entfernen und Setup-Status

Vor Updates Projekt/Git-Diff und private Einstellungen sichern; nur
offiziellen Updater oder passenden Desktop-Release verwenden.
Unter Windows bei Bedarf ueber **Einstellungen -> Apps -> Installierte Apps**
deinstallieren. Projektordner/Keys/Sessiondaten nicht automatisch loeschen.
Eine GUI-Deinstallation ersetzt keine Widerrufung verwendeter API-Keys.

Im Ultimate-Setup ist `qwen_desktop` **planned/manual-windows**:
sichtbarer Menueeintrag, keine automatische Windows-/WSL-Installation.
Die Bash-Checks zeigen nur die Registrierung, nicht eine erkannte
Windows-Installation. Installation/Update/Uninstall aus dem Linux-Menue
geben bewusst keinen falschen Erfolg aus.

Offen: echter Windows-Installations-Smoke-Test, Publisher-Pin, ARM64-Paket,
versionsbezogene GUI-Provider-Tests und eng begrenzter OpenClaw/n8n-Adapter.
Quelle/Download verifiziert ist nicht dasselbe wie lokal installiert/getestet.
