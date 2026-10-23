# Rhasspy: Optionen und Dringlichkeit

Stand: 24.10.2026. Diese Seite erlaeutert die zwei Entwicklungswege und ihre
Prioritaeten. Sie ist keine Installations- oder Produktionsfreigabe.
**Die bereits getroffene Nutzerentscheidung bleibt bestehen: Rhasspy 2 als
getrenntes Legacy-Projekt weiter pruefen.** Ein moderner Sprachstack wird
nicht ohne neue Freigabe als Ersatz installiert.

## Dringlichkeit und Reihenfolge

Die Prioritaeten sind eine technische Einschaetzung fuer dieses Setup, keine
Meldung ueber einen nachgewiesenen Angriff oder eine externe Frist.

| Prioritaet | Was jetzt wichtig ist | Abnahmekriterium |
|---|---|---|
| P0: vor jedem Installationsversuch | Bestehende Rhasspy-Profile und Konfigurationen sichern; Legacy-Build nicht mit Produktivdaten oder im normalen System-Python ausfuehren. Kein oeffentlicher Dienst. | Getrennte Arbeitsumgebung, gepruefte Backup-/Restore-Wege und keine Ueberschreibungen vorhandener Profile/Venvs. |
| P1: naechster Entwicklungsschritt | Gewaehlten Legacy-Weg reproduzierbar machen: feste Quellen, gepruefte Downloads, passende private Buildumgebung und zunaechst minimaler Funktionsumfang. | Erfolgreicher Build plus Tests; ein Checkout oder Paketimport reicht nicht als Sprachassistenten-Abnahme. |
| P1: vor produktiver Sprachsteuerung | Mikrofon, Audioausgabe, MQTT, Authentifizierung und erlaubte Aktionen testen. Kritische Aktionen duerfen keine ungeprueften LLM-Entscheidungen ausfuehren. | Ende-zu-Ende-Test mit deutschem Testmaterial, definierten Rechten und nachvollziehbaren Fehlerfaellen. |
| P2: separat bewerten | Modernen Stack als moeglichen Zukunftspfad vergleichen, besonders wenn neue Funktionen statt alter Profile im Vordergrund stehen. | Eigene Architektur- und Integrationsentscheidung; keine stille Umstellung des Legacy-Projekts. |

**Praktische Bedeutung:** Schutz der vorhandenen Installation hat Vorrang vor
einer schnellen Freischaltung des Menueeintrags. Falls kurzfristig eine
einsatzfaehige Sprachsteuerung benoetigt wird, ist ein zeitlich begrenzter
Machbarkeitstest beider Wege sinnvoll; keiner ist derzeit als vollstaendige
Pipeline in diesem Setup abgenommen. Es gibt keine belastbare Zeitgarantie.
Mit zuletzt rund 7,9 GiB auf C: keine grossen Legacy-Builds oder Modell-
Downloads ohne erneute Speicherplanung beginnen.

## Weg 1: Rhasspy 2 als getrenntes Legacy-Projekt

**Was das bedeutet:** Die bekannte Rhasspy-2.x-Architektur bleibt erhalten.
Ziel ist, vorhandene Profile, Absichtserkennung und MQTT-/Hermes-Ablaufe
weiterverwenden zu koennen. Das [offizielle Repository](https://github.com/rhasspy/rhasspy)
ist archiviert; die [native GitHub-/venv-Anleitung](https://rhasspy.readthedocs.io/en/latest/installation/)
nennt Ubuntu 20.04/WSL2 als getestete Vergleichsumgebung. Unser Ziel Ubuntu
24.04 ist damit noch nicht nachgewiesen.

**Der Haken:** Historische Python-, Audio- und STT-Abhaengigkeiten muessen
mit einer passenden, isolierten Buildumgebung zusammengebracht werden.
Workarounds duerfen keine unkontrollierten Paket-Upgrades, entfernten
Requirements oder veraendertes System-Python verdecken. Der bisherige
Quellenbefund enthaelt auch HTTP-Downloads und veraenderliche master-Links.
Vor einem Build sind feste Artefakte, Hashes und transitive Abhaengigkeiten
zu pruefen. Einzelheiten: [Legacy-Buildpruefung](../legacy/rhasspy2/BUILD_REVIEW.md).

**Isolierung statt Docker-Ausweichloesung:** Container koennen verschiedene
Systembibliotheken kapseln, reparieren aber weder alte Bibliotheken noch
fehlende Pruefsummen oder Sicherheitsupdates. Fuer dieses Projekt gilt die
gewaehlte GitHub-/Source-Strategie **ohne automatischen Docker-Fallback**.
Als Vergleichsumgebung kommt eine abgeschottete Wegwerf-VM infrage; ein
historisches OS ist dabei ein Testmittel, keine Produktionsfreigabe.

**Fuer wen geeignet:** Besonders fuer vorhandene, erhaltenswerte Rhasspy-
Profile, eigene Intent-Regeln und bewusste Abhaengigkeiten von der
Rhasspy-2-/Hermes-MQTT-Struktur. MQTT allein erzwingt allerdings nicht
Rhasspy 2; auch eine andere Architektur kann MQTT verwenden.

**Erfolg bedeutet:** Reproduzierbarer Build, genau benannte aktive
Komponenten und eine getestete Audio-/Intent-Pipeline. Bis dahin bleibt
der Installer blockiert und erzeugt keinen Erfolgsmarker.

## Weg 2: modernen lokalen Sprachstack separat integrieren

**Was das bedeutet:** Funktionen werden in austauschbare Bausteine getrennt,
statt die komplette alte Rhasspy-Laufzeit zu uebernehmen. Das kann Wartung,
Hardwareauswahl und Integration erleichtern. Es garantiert aber weder
dauerhafte Pflege noch fehlerfreien Betrieb auf Ubuntu 24.04/WSL oder
bestimmten GPUs. Jedes konkrete Repository, Modell und Backend braucht eine
eigene Versions-, Lizenz- und Funktionspruefung.

Ein moeglicher, noch nicht implementierter Entwurf:

```text
Mikrofon / Satellit
  -> Audioaufbereitung, optional VAD und Wake Word
  -> Speech-to-Text
  -> Intent-Regeln oder lokales LLM
  -> Rechtepruefung / erforderliche Nutzerfreigabe
  -> freigegebener Aktionsadapter
  -> Text-to-Speech
  -> Lautsprecher
```

### Bausteine und ihre tatsaechlichen Rollen

| Ebene | Kandidat | Wichtige Abgrenzung |
|---|---|---|
| Audio-Satellit / Transport | [Wyoming-Satellite](https://github.com/rhasspy/wyoming-satellite) | Audio-Endpunkt mit Wyoming-Anbindung, kein eigenstaendiges Wake-Word-Modell. Seit 27.01.2026 archiviert und als deprecated markiert; nicht pauschal als aktiv gepflegten Neubau empfehlen. |
| Separater Satellitenkandidat | [Linux Voice Assistant](https://github.com/OHF-Voice/linux-voice-assistant) | Upstream bezeichnet ihn als experimentell. Home-Assistant-Anbindung ueber ESPHome statt Wyoming; kein ungepruefter Drop-in-Ersatz. Nativen GitHub-Build und Audio separat pruefen. |
| Wake Word | [openWakeWord](https://github.com/dscripka/openWakeWord) | Eigentliche Erkennung eines Aktivierungsworts. Upstream nennt englische vortrainierte Modelle; deutsche Aktivierungswoerter und Modelllizenzen gesondert pruefen. |
| Speech-to-Text | [Whisper](https://github.com/openai/whisper) oder [faster-whisper](https://github.com/SYSTRAN/faster-whisper) | Audiosignal wird zu Text. Im Entwurf eine eigene STT-Runtime vorsehen, nicht Ollama pauschal als Whisper-Ausfuehrungsnachweis verwenden. Backend-/CUDA-Kompatibilitaet messen. |
| Intent / Sprache verstehen | Feste Regeln oder lokale Modelle wie Qwen/Llama ueber eine geeignete Runtime | Modell, Server und Agentensteuerung sind unterschiedliche Ebenen. Hermes Agent ist eine Agenten-Runtime, kein STT- oder Intent-Modell. Kritische Aktionen brauchen begrenzte Rechte und Freigaben. |
| Lokale TTS | [Piper unter OHF Voice](https://github.com/OHF-Voice/piper1-gpl) | Lokale Sprachausgabe. Upstream sucht Maintainer; aus dem Projektnamen keine Wartungsgarantie ableiten. Code-Lizenz und die jeweilige Stimme separat pruefen. |
| Zusaetzliche lokale TTS-Option | [XTTS-v2](https://huggingface.co/coqui/XTTS-v2) | Modell/Runtimes, Ressourcenbedarf und Pflegezustand gesondert pruefen. Die Modellkarte nennt die Coqui Public Model License; lokale Ausfuehrung ist keine pauschale Nutzungsfreigabe. |
| Optionale Cloud-TTS | [ElevenLabs](https://elevenlabs.io/docs/overview/capabilities/text-to-speech) | Externe API, nicht Teil eines vollstaendig lokalen Open-Source-Stacks. Nur bewusst freigeben; Kosten, Datenuebertragung und Stimmenrechte vorab klaeren. |

Die Tabelle ist ein Kandidatenvergleich, **keine Liste neu installierter
oder bereits freigeschalteter Installer**. Wyoming-Protokoll, Wyoming-
Satellite und ein Wake-Word-Service sind nicht dasselbe. Ein vorhandener
Katalogeintrag belegt auch keinen fertigen Integrationsworkflow.

**Fuer wen geeignet:** Neue, modular erweiterbare Sprachsteuerung, wenn
keine unverzichtbare Bindung an alte Rhasspy-Profile besteht oder deren
Migration bewusst geplant wird. Fluessigkeit und Leistung muessen durch
Messungen nachgewiesen werden, nicht durch das Etikett modern.

## Bewertung fuer dieses hybride Setup

Pi/MiniPC koennen als Audio-Endpunkt untersucht werden; GPU-/STT-/LLM-
Verarbeitung kann getrennt auf dem RTX-System liegen. Das ist eine
Architekturoption, kein bestaetigter Betrieb. WSL-Audio, deutsche Sprache,
Echo-/Geraeuschunterdrueckung, Unterbrechen, Netzwerkverzoegerung und
gleichzeitige Modellnutzung muessen real getestet werden.

Vor einer Entscheidung messen: Reaktionszeit bis zum ersten Audiowort,
Transkriptqualitaet bei deutschem Testmaterial, Fehlaktivierungen, RAM/VRAM,
CPU/GPU und Verhalten bei ausgeschaltetem RTX-Host. Ohne Audiofreigabe keine
Mikrofonaufnahme. Ohne Cloud-Freigabe keine Sprachdaten an ElevenLabs oder
andere Anbieter senden. Bestehende Profile unveraendert sichern; Migration
nur mit Rueckweg.

**Aktueller Beschluss:** Weg 1 bleibt priorisiert als abgegrenzte Legacy-
Pruefung. Weg 2 wird hier zur informierten spaeteren Entscheidung dokumentiert,
nicht automatisch installiert. Zurueck zum [Rhasspy-Status](rhasspy.md).
