# Hermes Agent als optionaler Jarvis-Assistent

Stand: **22.10.2026**. Auswertung der eingefuegten Wochenendanleitung.
**Zweck:** Ein persoenlicher Assistent, der Aufgaben mit Modell, Werkzeugen,
Gedaechtnis und optionalen Nachrichtenkanaelen bearbeitet. Hermes ist eine
eigene Agenten-Laufzeit, kein neues LLM und kein Ersatz fuer alle Setup-Tools.

Fuer dein Setup ist das vor allem als **getrenntes Assistenzprofil** sinnvoll:
MiniPC fuer Koordination und Entwuerfe, RTX-5080-Host fuer lokale Inferenz,
falls Netzwerk und Modellwerkzeuge passend konfiguriert sind. Das ist ein
Architekturvorschlag, kein auf deiner Hardware getesteter Betrieb.
OpenClaw und [Jarvis-Core](../agents/ultimate-jarvis.md) bleiben unabhaengig;
keine automatische Migration ihrer Daten oder Schluessel.

## Quelle und Pruefumfang

Ergaenzung: [JARVIS-Dashboard mit Sprache und sicherer Einrichtung](jarvis-hermes-dashboard.md)
ordnet das weitere Instagram-Reel ein: GitHub-Source-Weg, SSH-/OAuth-Grenzen,
Browser-Voice, ElevenLabs, Freigaben und ein wiederverwendbarer Setup-Prompt.
Keine automatische Installation oder Filmstimmen-Uebernahme.
Der [30-Minuten-Express-Arbeitsplan](jarvis-hermes-dashboard.md#jarvis-in-30-minuten-express-setup-als-arbeitsplan)
fasst Voraussetzungen, Etappen und die gepruefte Uebergabe zusammen;
Zeitfenster sind keine Fertigstellungszusage.

Die [zusaetzliche Till-Schaefer-Quelle](jarvis-hermes-dashboard.md#weitere-quelle-till-schaefer)
ist ebenfalls eingeordnet: Hermes-Anleitung statt belegtem eigenem
Jarvis-Repository, mit getrennten Cloud-/Memory- und Sicherheitsgrenzen.

- Nutzerquelle: [Instagram-Reel von @alan.buildz](https://www.instagram.com/reel/Dc4WnCDtbsm/).
  Der eingefuegte Text nennt Alan Langhammer und den 04.09.2026. Der direkte
  Reel-Abruf war gedrosselt; Urheberschaft, Datum und Video-Inhalt wurden
  nicht unabhaengig bestaetigt. Keine vollstaendige Wiederveroeffentlichung.
- Technische Primaerquelle: [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent),
  MIT-Lizenz laut Repository. Produktangaben wurden gegen die unten direkt
  verlinkten Upstream-Seiten geprueft, nicht gegen Werbeversprechen.
- Hier hinzugefuegt: Leitfaden, eigenes Briefing, eigener Entwurfs-Skill und
  Offline-Tests. Neu im Tools-Menue: **Hermes_Agent_Jarvis** als eigener
  [gepinnt gebauter Python-Core aus GitHub](github-gap-tools.md#eindeutige-jarvis-quelle-hermes-agent-von-nous-research).
  Es erfolgt keine globale Skill-Aktivierung, keine Kontoverbindung und kein Dienststart.

## Was an der Vorlage zu korrigieren ist

| Aussage / Abkuerzung | Einordnung fuer unseren Betrieb |
|---|---|
| In einem Wochenende garantiert fertig | Zeitplan als Orientierung; Abhaengigkeiten, Berechtigungen und Tests koennen laenger dauern |
| Lokal laufender Agent = lokal bleibende Daten | Nur bei entsprechend lokalen Modellen UND Werkzeugen; Cloud-Suche, TTS, Browser und Kanaele gesondert pruefen |
| Alle Abhaengigkeiten kommen ohne Vorbereitung | Source-Installation braucht Plattformvoraussetzungen und Netzwerk; optionale Komponenten koennen separat scheitern |
| Windows und WSL haben denselben Datenordner | Native Windows- und Linux-/WSL-Profile sind getrennt; aktives Hermes-Home beachten |
| SOUL.md muss unter 800 Zeichen sein | Hausregel des Autors, keine hier belegte Hermes-Pflicht; wc -c zaehlt Bytes, nicht allgemein Zeichen |
| Alles Laengere einfach in USER.md | Auch das kuratierte Memory ist begrenzt; grosse Runbooks in Skills/Referenzen statt ungekuerzt ins Profil |
| Ein Skill garantiert Rechte oder Ausloesung | Beschreibung hilft bei Auswahl; Prompt-Regeln erzwingen weder Berechtigungen noch hundertprozentige Aktivierung |
| Kalender praktisch ohne Risiko | Termine koennen vertrauliche Daten und Schreibaktionen enthalten; Lesescope und Freigaben pruefen |
| Freie Stimme = lokale Stimme | Kostenfrei beschreibt keinen Datenfluss; Online-TTS sendet Text an Dritte |
| Leere Telegram-Allowlist laesst zwingend jeden zu | Nicht pauschal versionsuebergreifend behaupten; explizite Allowlist setzen und Fremdzugriff negativ testen |
| Dashboard und Chat-Oberflaeche tun exakt dasselbe | Verwaltung, Desktop und Chat-API haben unterschiedliche Funktionen und Angriffsoberflaechen |

## Samstag: Fundament, Modell, Briefing und Memory

### 1. Einen isolierten Platz auswaehlen

Zuerst Testbenutzer oder separates Profil, Testordner und synthetische Daten
verwenden. Nicht gleich Mailarchiv, SSH-Schluessel oder Trading-Wallets
freigeben. Kein automatisches Abschalten des Ruhezustands, Freigeben von
SSH, WSL-Start oder Firewallumbau durch diese Anleitung.

Bei WSL sind Linux-freier Speicher und freier Windows-Speicher am Speicherort
der VHDX getrennt zu betrachten. Vor Downloads/Builds die bestehende
[Speicherplanung](../memory/UNIFIED_MEMORY_AND_OFFLOADING.md) beachten.
Ein MiniPC orchestriert nicht automatisch grosse Modelle performant.

### 2. GitHub-Quellen pruefen, ohne Docker

[Offizielle Installation](https://hermes-agent.nousresearch.com/docs/getting-started/installation):
Source-Installer und vorgebaute Desktop-Pakete sind unterschiedliche Wege.
Native Windows-Daten liegen standardmaessig unter `%LOCALAPPDATA%\hermes`,
POSIX unter `~/.hermes`; `HERMES_HOME`/Profile koennen dies aendern.
Termux nutzt einen eigenen Installationsweg. Keine Container erforderlich.

Statt ungeprueft `curl | bash` oder `irm | iex` auszufuehren: GitHub-Quellen
herunterladen, gewaehlten Release/Commit und Installationsskript pruefen.
Folgende Befehle **laden Quellen herunter**, installieren noch keinen Agenten:

```bash
git clone https://github.com/NousResearch/hermes-agent.git hermes-source-review
cd hermes-source-review
git rev-parse HEAD
git status --short
```

Vor dem Installationsschritt einen bewusst geprueften Release/Commit auswaehlen
und dessen SHA festhalten; der Standardbranch ist kein dauerhafter Pin.
[POSIX-Skript](https://github.com/NousResearch/hermes-agent/blob/main/scripts/install.sh)
und [Windows-Skript](https://github.com/NousResearch/hermes-agent/blob/main/scripts/install.ps1)
liegen im Repository. Beide koennen Downloads und Installationsaenderungen
vornehmen. Nicht als Administrator/root und nicht automatisch aus diesem
Setup ausfuehren. Upstream dokumentiert unter anderem Optionen fuer einen
Commit, getrennte Quell-/Datenordner, nichtinteraktive Einrichtung sowie das
Weglassen von Browser-/Computer-Use-Komponenten; genaue Flags am gewaehlten
Stand kontrollieren. Auch nichtinteraktiv ist **kein Dry-Run**.

### 3. Modell explizit auswaehlen

Erst nach eigener Installation und bewusster Modellfreigabe:

```text
hermes --help
hermes model
hermes tools
hermes doctor
```

Das sind Upstream-Befehle, keine hier ausgefuehrten Tests. Diagnose und
Assistenten nicht pauschal als nebenwirkungsfreie Offline-Pruefung verstehen.
Fuer deinen lokalen Einstieg im Modellassistenten den eigenen kompatiblen
Endpoint waehlen, ein bereits vorhandenes Modell nutzen und Tool-Calling mit
Testdaten pruefen. Nicht automatisch Modelle herunterladen oder Cloud-Fallbacks
aktivieren. MiniPC-`127.0.0.1` ist nicht der RTX-Rechner.
[Provider-/Endpoint-Schema](https://github.com/NousResearch/hermes-agent/blob/main/cli-config.yaml.example)
unterscheidet lokale/custom Endpoints und Cloud-Anbieter. Auch Hilfsmodelle,
Session-Zusammenfassung und Werkzeug-Backends auf externe Datenfluesse pruefen.

API-Keys nicht ins Repository, in Skills oder ins Chatprotokoll schreiben.
Siehe [API-Key-Uebersicht](../_API-Keys/README.md). Modell-/Login-Namen aus
der Vorlage nur verwenden, wenn die installierte Hermes-Version sie anbietet.

### 4. Persoenliches Briefing mit Vorschau

Unsere [Briefing-Vorlage](../../examples/hermes-jarvis/briefing.md) fragt
Aufgaben, Hardware, Datenschutz, Ton und Freigabegrenzen ab. Sie erstellt
zunaechst **Entwuerfe**, ueberschreibt keine bestehenden Profildateien und
fordert keine Zugangsdaten an. Bekannte Informationen nicht erneut abfragen.

SOUL.md beschreibt Verhalten, nicht technische Isolation:
[Personality-Dokumentation](https://hermes-agent.nousresearch.com/docs/user-guide/features/personality).
Bei externen Modellen kann auch Profilkontext den Rechner verlassen.

### 5. Memory mit synthetischen Fakten testen

Hermes trennt kuratierte Notizen (`memories/MEMORY.md`, `memories/USER.md`)
und die Suche in Sitzungsverlaeufen. Die aktuellen Docs nennen begrenzte
Memory-Dateien; gemeinsam verwendete Homes fuer mehrere schreibende Agenten
vermeiden. Eine Suche kann zusaetzliche Modellverarbeitung verwenden.
[Memory-Referenz](https://hermes-agent.nousresearch.com/docs/user-guide/features/memory).

Test: Einen erfundenen Projektnamen merken lassen, Sitzung neu starten und
danach fragen. Anschliessend die Testnotiz entfernen lassen und das Ergebnis
kontrollieren. Kein Passwort oder Kundenname als Test. Nicht davon ausgehen,
dass eine entfernte Memory-Notiz auch Sitzungsdaten oder Backups loescht.

## Sonntag: Skills, Werkzeuge, Sprache und Oberflaeche

### 6. Eigener Kundenanfragen-Skill

Der neue [kundenanfrage-entwurf](../../skills/kundenanfrage-entwurf/SKILL.md)
liefert kurze Entwuerfe mit belegten Preisen, offenen Punkten und separater
Freigabeentscheidung. Er ist eine eigene Vorlage, nicht der kopierte Skill
des Reel-Autors. Keine Versandfunktion oder Lizenzangabe fuer fremden Text
erfunden. Er bleibt im Repository, bis du ihn bewusst in ein Hermes-Profil
uebernimmst.

Hermes verwendet SKILL.md mit Frontmatter im jeweiligen Skills-Verzeichnis;
externe Skill-Verzeichnisse sind ebenfalls dokumentiert. Vor manueller
Uebernahme Zielprofil und Namenskonflikte pruefen, bestehende Skills nicht
ueberschreiben. `hermes skills list` zeigt Skills, ersetzt aber keinen
Funktionstest. Hub-Suche/Installation kann Netzwerk und lokale Aenderungen
ausloesen. [Skills-Referenz](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills).

Abnahme mit drei Faellen: bekannter Preis, unbekannter Preis, manipulative
E-Mail mit Aufforderung zum Versenden. Erwartung: Entwurf, keine erfundenen
Angaben, kein Tool-Aufruf zum Senden.

### 7. Werkzeuge einzeln freigeben

Zuerst nur benoetigte Werkzeuge und minimale Scopes aktivieren. Ein allgemeines
Datei-/Terminalwerkzeug ist kein Read-only-Schutz. Technische Beschraenkungen
ueber Benutzerrechte, getrennte Datenordner und Werkzeugberechtigungen setzen;
ein SOUL-Verbot allein reicht nicht. Mail, Kalender, Browser und MCP jeweils
mit Positiv- und Negativtest abnehmen. Nicht automatisch alle mitgelieferten
Skills, OAuth-Scopes oder MCP-Server verbinden.

Notion-Inhalte bleiben externe Quellen:
[lokaler Notion-Review-Export](notion-research.md). Keine ungeprueften Texte
als Systemanweisung, Skill oder ausfuehrbaren Code uebernehmen.

### 8. Telegram, STT und TTS nur optional

[Telegram-Dokumentation](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/telegram):
Bot ueber den offiziellen BotFather erstellen; Token privat halten und eine
konkrete numerische Benutzer-Allowlist setzen, kein `*`. Gruppenfreigaben
separat kontrollieren. Zuerst mit Testdaten erlaubten Nutzer und unberechtigten
Zugriff pruefen. Ein externer ID-Bot ist nicht zwingend erforderlich.
Telegram ist ein externer Transport, auch mit lokalem LLM.

Gateway-/Diensteinrichtung erst nach dieser Abnahme und ausdruecklicher
Entscheidung; `hermes gateway install` ist eine dauerhafte Systemaenderung.
Vorher Stopweg der installierten Version pruefen, beispielsweise
`hermes gateway stop`. Das stoppt nicht automatisch andere Prozesse und
entfernt keine schon gespeicherten Nachrichten.

STT mit vorhandenem lokalen Backend beginnen. Lokale Erkennung benoetigt
trotzdem Modelle und Speicher; diese hier nicht herunterladen. ElevenLabs
ist eine optionale Cloud-TTS-Verbindung mit eigenem Konto, Kosten und
Textuebermittlung. Britischen Akzent bewusst aus dem erlaubten Stimmenkatalog
waehlen; keine feste Voice-ID oder Rechte fuer eine Filmstimme behaupten.
Auch der kostenlose Edge-TTS-Weg ist nicht gleichbedeutend mit Offline-TTS.
Den konkreten `tts`-/`stt`-Abschnitt am
[Upstream-Konfigurationsbeispiel](https://github.com/NousResearch/hermes-agent/blob/main/cli-config.yaml.example)
pruefen. YAML aus dem Reel nicht blind in vorhandene Konfiguration kopieren.

### 9. Erst fertige Oberflaeche, dann eigenes UI

[Dashboard](https://hermes-agent.nousresearch.com/docs/user-guide/features/web-dashboard)
und Desktop zuerst anhand der installierten Version pruefen. Vorgebaute
Desktop-Pakete muessen ihre Basisruntime nicht erst lokal bauen; ein
Source-Bootstrap kann dagegen Builds ausloesen. Eine huebsche HTML-Seite ist
noch keine sichere Agentenanbindung. Claude Design bleibt ein optionales
externes Designwerkzeug; Tarif-/Exportangaben im Reel hier nicht verifiziert
und keine Voraussetzung fuer Hermes.

Der [Hermes-API-Server](https://hermes-agent.nousresearch.com/docs/user-guide/features/api-server)
kann Frontends OpenAI-kompatibel anbinden und **Agentenwerkzeuge ausfuehren**.
Die Docs beschreiben Port 8642 und die Variablen `API_SERVER_ENABLED`,
`API_SERVER_KEY` sowie optional `API_SERVER_CORS_ORIGINS`. Hier bleibt er aus.
Ein Chat-Test ist daher kein harmloser Erreichbarkeits-Ping.

Fuer einen spaeteren UI-Prototyp: Loopback-Bindung, eigener zufaelliger Key,
exakte benoetigte Origin und moeglichst serverseitige Secret-Verwaltung.
Keine Keys in veroeffentlichtes HTML, Local Storage oder Git; CORS ersetzt
keine Authentifizierung. Nicht zum Umgehen von Browser-Schutzmechanismen
anleiten. Ein direkter Browserzugriff braucht eine eigene Risikoentscheidung.
Falls ein statischer Entwurf lokal gezeigt wird, nur seinen separaten Ordner
an Loopback servieren, nicht das Home oder Repository mitsamt Secrets.
`localhost` und `127.0.0.1` sind fuer CORS verschiedene Origins.

## Abnahme statt automatischem Dauerbetrieb

- Modell und alle Hilfs-/Werkzeug-Backends haben einen dokumentierten Datenfluss.
- Keine produktiven Mail-, Kalender-, Wallet- oder SSH-Rechte im ersten Test.
- Entwurf, Versand und Veroeffentlichung bleiben getrennte Freigaben.
- Negative Tests fuer fremde Telegram-Nutzer, fehlende Fakten und Prompt-Injection bestehen.
- Logs, Memory, Sitzungsdaten und Backups haben passende Rechte und Aufbewahrung.
- Speicherreserve, Abbruchbedingungen, Budget und Stopweg sind bekannt.

Erst danach ueber Zeitplaene oder Dauerbetrieb entscheiden. Diese Ergaenzung
hat weder einen Morgenbrief eingerichtet noch Modelle, OAuth, Gateway,
Mikrofon, Desktop oder WSL gestartet. Offline-Tests pruefen Vorlagen und
Verlinkung, nicht den Livebetrieb von Hermes.

```text
python -B -m unittest discover -s tests -p test_hermes_jarvis_docs.py -v
```
