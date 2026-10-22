# JARVIS mit Hermes: Dashboard, Sprache und sichere Einrichtung

Stand: **22.10.2026**. Anleitung und umsetzbares Briefing, keine hier
ausgefuehrte Installation und kein bereits vorhandenes JARVIS-Dashboard.

**Sinn und Zweck:** Eine persoenliche, deutschsprachige Bedienoberflaeche
fuer Hermes Agent: sprechen oder schreiben, Aufgaben planen lassen und
Werkzeuge gezielt freigeben. Der animierte Kern ist eine Statusanzeige,
kein Beleg fuer mehrere aktive Agenten oder erledigte Arbeiten.

Fuer dein Setup ist ein eigenes Hermes-Profil auf MiniPC oder Rechner der
sinnvolle erste Schritt. Ein gemieteter VPS ist optional; Hostinger ist
keine technische Voraussetzung. Lokale Ollama-Inferenz am RTX-Rechner bleibt
eine getrennt einzurichtende Option. Jarvis-Core und OpenClaw werden nicht
ersetzt und erhalten keine neuen Rechte.

## Quelle und wichtige Korrekturen

[Nutzerquelle: Instagram-Reel](https://www.instagram.com/reel/DdJaffWsN-4/).
Der Abruf war gedrosselt; Video, Urheberschaft und Zeitversprechen wurden
nicht unabhaengig bestaetigt. Grundlage ist der eingefuegte Nutzertext.

| Aussage aus der Vorlage | Sichere Einordnung |
|---|---|
| In 30 Minuten fertig | Kein belastbarer Zeitplan fuer SSH, DNS, HTTPS, OAuth, Voice und Sicherheitstests |
| SSH-Schluessel an Claude schicken | Niemals private Schluessel, Passwoerter, OAuth-Tokens oder API-Keys in den Chat kopieren; lokale SSH-Konfiguration/Agent verwenden |
| OpenAI-Abo und GPT-6 verbinden | Hermes dokumentiert ChatGPT-/Codex-OAuth; Zugang, Modell-ID und Kontolimits konkret pruefen, nicht aus dem Abo ableiten |
| Dashboard ist automatisch Voice-Chat | Dashboard, API-Server und Voice-Clients sind unterschiedliche Komponenten; gewuenschte Browserfunktionen gesondert implementieren/testen |
| Offizielle JARVIS-Stimme aus Drive | Herkunft und Klonrechte sind hier nicht belegt; keine offizielle Lizenz aus dem Link ableiten |
| Hintergrundgeraeusche immer behalten | Keine allgemeine Qualitaetsempfehlung; konsistente, saubere Einzelsprecher-Aufnahmen verwenden |
| Alles automatisch starten | Autostart erst nach Funktionstest, Sicherheitsabnahme und dokumentiertem Stopweg |

Der mitgelieferte [Drive-Ordner](https://drive.google.com/drive/folders/1JrlicTWHYdZAAwcX8G7jKXFT4XxPU9Mq?usp=sharing)
bleibt ausschliesslich eine **ungepruefte Nutzerquelle**. Keine Audiodateien
wurden abgerufen, hochgeladen oder als Stimmenmodell verwendet. Stattdessen
eigene Stimme mit Einwilligung oder eine passend lizenzierte Katalogstimme
nutzen. Eine persoenliche Assistentenstimme erfordert keine Filmstimmenkopie.

## Weitere Quelle: Till Schaefer

Die [Jarvis-Anleitung von Till Schaefer](https://till-schaefer.de/github/jarvis)
wurde am **22.10.2026** direkt gelesen. Sie beschreibt 43 Schritte auf Basis
von Hermes Agent, mit Hetzner, Telegram und optionalen Erweiterungen.
Der GitHub-Link fuehrt zu
[NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent),
nicht zu einem nachgewiesenen eigenen Jarvis-Quellcodeprojekt.

Die im Nutzertext genannte Adresse
[till-schaefer/jarvis](https://github.com/till-schaefer/jarvis) lieferte beim
Pruefen **404**. Das beweist keine dauerhafte Nichtexistenz, belegt aber
keinen installierbaren oeffentlichen Quellstand. Die behauptete Folge aus
Clone, `pip install -r requirements.txt`, `.env.example` und `python main.py`
ist deshalb **kein verifizierter Schnellstart** und wird nicht ausgefuehrt.

### Belegte Inhalte statt vermuteter Architektur

| Thema | Inhalt der gelesenen Anleitung |
|---|---|
| Agent und Bedienung | Hermes, Telegram und persoenliches Briefing |
| Memory | Notizdateien; optional Supabase und Voyage AI fuer Vektorsuche |
| Sprache | faster-whisper erwaehnt; ElevenLabs fuer Ausgabe |
| Oberflaeche | Hermes-Dashboard per SSH-Tunnel; eigenes Design als gesonderter Auftrag |
| Grenzen | Nutzerfreigabe im Verhaltenstext, kein Nachweis technischer Rechteisolation |

Ein eigenes Core-Framework, Piper, WhatsApp-/Discord-Connectoren oder eine
eigene Open-Source-Lizenz sind damit nicht belegt. Auch die Aussage, alles
bleibe lokal, passt nicht zu den beschriebenen externen Diensten. Ein
Dashboard-Entwurf ist noch keine fertige Anbindung.

### Unsere Umsetzungsempfehlung

Als Ergaenzung zur bestehenden Anleitung ist die Quelle nuetzlich, nicht
als zweiter Jarvis-Installer. Fuer unser Setup gelten weiterhin folgende
eigene Betriebsregeln:

- Vorhandenes Hermes-Profil und GitHub-Source-Weg verwenden; keine
  unbelegten Repository-Adressen in Installationsskripte aufnehmen.
- Nur benoetigte Verbindungen aktivieren. Vor jedem Dienst Datenarten,
  Zielsystem, Zugriffsrechte, Kosten und Loeschweg dokumentieren; lokaler
  Serverbetrieb allein begrenzt den Datenfluss nicht.
- Mit synthetischem Briefing und lesenden Werkzeugen beginnen. Mailversand,
  Loeschen und Finanzaktionen technisch sperren, bis eine ausdrueckliche
  Freigabe vorliegt; ein Prompt-Verbot ist keine Zugriffskontrolle.
- Private SSH-Schluessel lokal belassen. Einen eigenen geschuetzten Key
  verwenden, Fingerprints pruefen und keine vorhandenen Keys ueberschreiben.
- Secrets nicht in CLI-Argumente, Chat oder Versionsverwaltung schreiben.
  Backups als potenziell geheimnishaltig behandeln, verschluesseln und eine
  Wiederherstellung ohne produktive Schluessel testen.
- Keine SQL-Schemata, Cloud-Projekte, Zeitplaene oder Dienste allein wegen
  des Dokumentationslinks anlegen. Installation, Memory-Erweiterung und
  Dauerbetrieb bleiben getrennte Entscheidungen mit separater Abnahme.

Die Quelle wurde verlinkt und eingeordnet, nicht vollstaendig kopiert.
Es wurde kein neues Tool installiert, keine Datenbank angelegt und keine
Automation aktiviert. Weiter geht es mit dem
[Hermes-Source-Leitfaden](hermes-jarvis-weekend.md).

## Jarvis in 30 Minuten: Express-Setup als Arbeitsplan

Die nachgereichte Markdown-Vorlage wird hier als **Express-Einstieg**
aufgenommen, nicht als Zusicherung einer vollautomatischen Einrichtung.
Die Zeitfenster sind selbst gesetzte Planungsbudgets, keine gemessenen
Installationszeiten. Bei ungeklaerten Voraussetzungen anhalten und offene
Punkte dokumentieren; Sicherheit nicht fuer das Zeitlimit ueberspringen.

### Voraussetzungen und Auswahl

- Vorhandener Rechner oder eigener Server mit ausreichender Speicherreserve;
  ein [Hostinger-VPS](https://www.hostinger.com) ist eine optionale
  Anbieterwahl aus der Nutzerquelle, keine Empfehlung oder Voraussetzung.
- Claude Code als optionaler Einrichtungsassistent mit bewusst begrenztem
  Terminalzugriff; die Anleitung ist auch manuell abarbeitbar.
- Bei Fernzugriff: gepruefte SSH-Verbindung ueber ein lokales Profil und
  Public-Key-Authentifizierung. Private Schluessel bleiben auf dem Client.
- Bewusst gewaehlter Modellzugang und, nur falls gewuenscht, ein
  [ElevenLabs-Konto](https://elevenlabs.io) fuer Cloud-TTS. Fuer lokale
  Sprache ist ElevenLabs keine Voraussetzung.
- Fuer externen Browserzugriff: geplanter HTTPS-/Anmeldeweg. DNS,
  Zertifikate, Ports und laufende Dienste nicht ungefragt veraendern.

### Drei Phasen statt eines unkontrollierten Gesamtauftrags

| Planungsfenster | Arbeit | Nachweis / Haltbedingung |
|---|---|---|
| Minute 0-10 | Ziel, Speicher, SSH falls benoetigt, GitHub-Quellstand und Kostenplan pruefen | Dokumentierter Plan; bei fehlenden Voraussetzungen kein Installationsstart |
| Minute 10-20 | Nach Freigabe isolierte Hermes-Einrichtung und echten Modelltest versuchen | Verwendeter Commit und Testergebnis; keine Zugangsdaten im Bericht |
| Minute 20-30 | Vorhandene Oberflaeche und einen deutschen Sprach-Test pruefen | Tatsaechlich funktionierende Teilstrecke oder ehrliche Liste offener Arbeiten |

Ein individuell gebautes Dashboard, Streaming mit Unterbrechung,
Telegram/Mail/Kalender, oeffentliches HTTPS und Autostart sind **eigene
Ausbaustufen**. Sie gelten nicht nach Ablauf der 30 Minuten automatisch als
fertig. Bleibt die Zeit knapp, zuerst Textchat im geschuetzten lokalen
Zugriff abnehmen, danach Sprache und erst zuletzt Fernzugriff/Dauerbetrieb.

Die sichere Reihenfolge ist: Serverzugang pruefen, Modell und Textchat
abnehmen, dann eine freigegebene Stimme auswaehlen. Das Drive-Paket ist
keine Voraussetzung. Keine Audio-Dateien pauschal hochladen und keine
Rauschoption allein aufgrund der Vorlage deaktivieren; siehe
[ElevenLabs und Stimmenrechte](#elevenlabs-nur-als-bewusste-cloud-option).

### Erwartete Uebergabe nach der Einrichtung

Der Einrichtungsassistent soll diese Ergebnisse **pruefen**, nicht vorab
als vorhanden versprechen:

| Ergebnis | Abnahme |
|---|---|
| Dashboard-Link | Nur die tatsaechlich erreichbare, gepruefte Adresse nennen; lokal ist nicht automatisch von aussen erreichbar |
| Anmeldung und HTTPS | Unberechtigten Zugriff ablehnen; Zertifikat und Anmeldeablauf testen, Passwort nicht ins Abschlussprotokoll schreiben |
| Sprache und Textkanaele | Jeden ausgewaehlten Kanal einzeln mit Testdaten pruefen; nicht ausgewaehlte Kanaele bleiben aus |
| Autostart | Erst nach Zustimmung einrichten, Neustart und Stopweg testen; ein gestarteter Prozess allein belegt keinen Autostart |
| Kurzanleitung | Start/Stop, Zielprofil, Konfigurations- und Logpfade, Datenfluss, Kosten und offene Punkte ohne Secrets auffuehren |

Nutze dafuer den [Einrichtungs-Prompt](#wiederverwendbarer-einrichtungs-prompt)
und die [Abnahmekriterien](#abnahme-und-aktueller-stand) dieser Seite.
Dieser Express-Abschnitt ergaenzt die Vorlage als Dokumentation; er startet
keinen Installer und erzeugt keine Anmeldedaten oder Dashboard-URL.

## Architektur fuer unser Setup

```text
Browser: Mikrofon / Chat / Start / Stop / sichtbarer Status
  -> eigenes authentifiziertes Backend (Keys bleiben hier)
  -> isoliertes Hermes-Profil mit begrenzten Werkzeugen
  -> bewusst gewaehltes lokales Modell ODER freigegebener Cloud-Provider
  -> STT und TTS: lokale Backends ODER separat freigegebene Cloud-Dienste
```

Eine Webseite allein ist keine sichere Runtime. Zuerst das vorhandene
[Hermes-Dashboard](https://hermes-agent.nousresearch.com/docs/user-guide/features/web-dashboard)
und den [Voice-Modus](https://hermes-agent.nousresearch.com/docs/user-guide/features/voice-mode)
der gewaehlten Version pruefen. Dokumentierte Voice-Funktionen bedeuten nicht,
dass ein selbst gebauter Browserclient automatisch dieselben Funktionen hat.

Ein eigenes UI kann dunklen Hintergrund, orangegoldenen Kern, kleinen Chat
rechts und Gespraechstasten unten erhalten. Auf Mobilgeraeten Chat unter den
Kern setzen; reduzierte Bewegung respektieren. Zustaende sichtbar benennen:
getrennt, hoert zu, verarbeitet, spricht, wartet auf Freigabe, Fehler.
Keine erfundenen Agentenzaehler oder Erfolgsmeldungen anzeigen.

## Einrichtung in freizugebenden Etappen

1. **Ziel bestimmen:** Bekannte Hardwaredaten uebernehmen; nur fehlendes Ziel
   (Laptop, MiniPC, Raspberry Pi oder VPS), Benutzer und Datenordner abfragen.
   Freien Zielspeicher, bei WSL auch das Windows-Laufwerk der VHDX, pruefen.
2. **SSH nur falls erforderlich:** Hostadresse, Benutzer und Public-Key
   konfigurieren. Host-Fingerprint ueber vertrauenswuerdigen Kanal pruefen;
   Host-Key-Pruefung nicht deaktivieren. Kein Root-Dauerbetrieb und keine
   ungefragte Firewall-/SSH-Aenderung. Lokaler Betrieb braucht kein SSH.
3. **GitHub statt Docker:** Die Quellen von
   [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)
   und einen geprueften Commit/Release verwenden. Den vorhandenen
   [Source-Leitfaden](hermes-jarvis-weekend.md) befolgen; keine ungeprueften
   Download-Einzeiler oder automatischen Modell-/Browserdownloads ausfuehren.
4. **Modell waehlen:** Provider, Datenschutz und Budget festlegen. Hermes
   beschreibt die Anmeldung unter
   [Model Providers](https://hermes-agent.nousresearch.com/docs/integrations/providers).
   OAuth ausschliesslich ueber den echten Loginablauf durch den Nutzer;
   Codes nicht protokollieren oder im Chat sammeln. Nur ein dort angebotenes
   Modell waehlen und nach Zustimmung mit synthetischen Daten testen.
5. **Sprache testen:** Zuerst Push-to-talk, danach Pausenerkennung, Streaming
   und Unterbrechung einzeln abnehmen. Mikrofon verlangt Browserberechtigung
   und einen sicheren Kontext (HTTPS bzw. lokale Browserausnahme).
   Browser-Spracherkennung nicht ungeprueft als offline ausgeben.
6. **Kanaele einzeln:** Telegram, Mail, Kalender und Notizen optional mit
   minimalen Scopes anbinden. Entwurf und Versand technisch trennen;
   ausgehende Nachrichten und Kalender-Schreibaktionen separat bestaetigen.
7. **Betrieb absichern:** Zunaechst Loopback bzw. SSH-Tunnel, danach bei Bedarf
   Anmeldung, HTTPS und eng begrenzter Netzzugang. Secrets nur serverseitig,
   nicht in Browsercode, Git oder Logs. Autostart erst gesondert freigeben;
   Start, Stop, Neustart, Wiederherstellung und Fehlerlogs dokumentieren.

Die [offizielle OpenAI-Authentifizierungsdokumentation](https://learn.chatgpt.com/docs/auth)
unterscheidet ChatGPT-Anmeldung und API-Key-Nutzung. Hermes-Unterstuetzung ist
eine Aussage des Hermes-Projekts, keine Zusicherung aller Drittanbieterpfade
durch OpenAI. API-Abrechnung und zusaetzliche Dienste nicht pauschal als im
ChatGPT-Abo enthalten darstellen. Auch ein existierendes GPT-6-Angebot belegt
nicht den Zugriff deines Kontos ueber die konkrete Hermes-Version.

### ElevenLabs nur als bewusste Cloud-Option

Vor Aktivierung Tarif, verfuegbare Klonfunktion, Zeichen-/Nutzungslimits und
Kosten im eigenen Konto pruefen. Sprachtext und gegebenenfalls Aufnahmen
verlassen dabei die lokale Umgebung. Keys lokal geschuetzt hinterlegen,
nicht an einen Coding-Agenten als Chatnachricht schicken.

Die [offizielle IVC-Anleitung](https://elevenlabs.io/docs/eleven-creative/voices/voice-cloning/instant-voice-cloning)
empfiehlt konsistentes, sauberes Material mit einer Stimme; Rauschen kann
mitgelernt werden. Rauschunterdrueckung daher nach Hoerprobe entscheiden,
nicht pauschal deaktivieren. Keine fremde Stimme ohne erforderliche Rechte
und ausdrueckliche Einwilligung klonen. Lokale STT/TTS-Alternativen und ihre
Modelllizenzen stehen im [Hermes-Leitfaden](hermes-jarvis-weekend.md).

## Wiederverwendbarer Einrichtungs-Prompt

```text
Plane einen persoenlichen deutschsprachigen JARVIS mit Hermes Agent.
Nutze docs/tools/jarvis-hermes-dashboard.md und den Hermes-Source-Leitfaden.
Uebernimm bekannte Hardwaredaten; frage nur fehlende entscheidende Angaben.
Beginne mit einem lesenden Bestandscheck und einem Plan, nicht mit Installation.
GitHub-Quellen mit dokumentiertem Commit/Release, keine Docker-Pflicht.
Keine privaten SSH-Schluessel, API-Keys, OAuth-Codes oder Passwoerter im Chat.
Login und Geheimniseingabe erfolgen durch mich in der jeweiligen sicheren UI.
Keine festen Modellnamen erfinden: Providerangebot und Kontozugriff pruefen.
Zeige Datenfluesse und Kosten fuer Modell, STT, TTS und VPS vorab.
Baue erst nach separater Zustimmung einen isolierten Prototyp:
mobilfaehig, dunkles UI, orangegoldener animierter Kern, kleiner Chat,
Start/Stop, sichtbare Mikrofonanzeige und barrierearme Bewegungsalternative.
Teste Sprache, Pausenerkennung, Streaming und Unterbrechung einzeln.
Nutze nur eigene/freigegebene Stimmen; keine Drive-Filmstimmen importieren.
Kanaele, Schreibrechte, Netzwerkfreigaben und Autostart jeweils extra freigeben.
Nachrichten nur als Entwurf, Versand erst nach konkreter Bestaetigung.
Keine automatische Paketbereinigung bei Fehlern; vorhandene Daten erhalten.
Liefere Testprotokoll mit echten Ergebnissen und offenen Punkten,
Bedienungsanleitung und Stopweg. Dashboard-Link erst nach geprueftem Start.
```

Der Prompt ist keine Sandbox. Benutzerrechte, Toolfreigaben, Budgetlimits und
Netzwerkregeln muessen die Grenzen technisch durchsetzen.

## Abnahme und aktueller Stand

- Ohne Anmeldung ist kein Zugriff auf Chat, Sitzungen oder Werkzeuge moeglich.
- Mikrofon-Stop beendet Aufnahme; Unterbrechung stoppt die Ausgabe und bricht
  laufende Verarbeitung ab, soweit das Backend dies unterstuetzt. Ein bereits
  ausgefuehrter Tool-Aufruf wird dadurch nicht rueckgaengig gemacht.
- Ein harmloser Modelltest liefert eine echte Antwort; Modell, Laufzeit,
  Provider und moegliche Kosten werden ohne Geheimnisse protokolliert.
- Nicht freigegebene Mail-/Kalenderaktionen bleiben gesperrt; fremde
  Telegram-Nutzer erhalten keinen Zugriff. Ausfalltests loesen keine Endlosschleife aus.
- Ein Neustarttest und der dokumentierte Stopweg funktionieren, bevor
  Autostart als erfolgreich bezeichnet wird.

Hier hinzugefuegt wurden Dokumentation und Briefing. Kein VPS gemietet,
Hermes installiert, Dashboard gebaut, Konto verbunden, Audio kopiert oder
Autostart eingerichtet. Die geprueften Links sind keine Live-Abnahme dieser
Zielarchitektur. Der bestehende Hermes-Leitfaden bleibt der Einstiegspunkt.
