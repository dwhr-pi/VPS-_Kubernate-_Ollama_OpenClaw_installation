# Musikerkennung und Rechts-/Finanzmodelle

Stand: 2026-11-11. Quellenintegration, keine Runtime-Abnahme.

## Musikerkennung

| Tool | Plattform und Abgleich | Lizenz |
| --- | --- | --- |
| [Audile](tools/audile.md) | Android, AudD/ACRCloud/Shazam extern | GPL-3.0 |
| [SongRec](tools/songrec.md) | Linux GUI/CLI, Shazam extern | GPL-3.0 |
| [Mousai](tools/mousai.md) | GNOME, AudD extern | GPL-3.0 |
| [Dejavu](tools/dejavu.md) | Python, eigene MySQL-/PostgreSQL-Fingerprints | MIT |

Alle vier sind als optionale Quellenrezepte mit Bereitschaft `planned` erfasst.
Fingerprints sind kein LLM. Die ersten drei Clients sind keine quelloffenen
Kopien des weltweiten Shazam-Katalogs. Externe Erkennung bedeutet moegliche
Datenuebertragung, Kosten und Anbieterabhaengigkeit. Offline vorgemerkte
Aufnahmen bei Audile/Mousai sind keine Offline-Erkennung. Eine lokale
Audile-Matching-Engine wurde nicht belegt. Dejavu vergleicht ausschliesslich
gegen zuvor indexierte, rechtmaessig nutzbare Referenzen; Rauschrobustheit
ist selbst zu messen, nicht pauschal garantiert.

Primaerquellen: [Audile](https://github.com/AudileTeam/Audile),
[SongRec](https://github.com/marin-m/SongRec),
[Mousai](https://github.com/SeaDve/Mousai),
[Dejavu](https://github.com/worldveil/dejavu).
Pins und SHA256 fuer README/Lizenz stehen im Quellenmanifest und auf jeder Tool-Seite.
Keine API-, Konto-, Preis- oder Erkennungspruefung wurde durchgefuehrt.

## Reasoning-Modelle

| Modell | Quelle und Lizenz | Grenzen |
| --- | --- | --- |
| [DeepSeek-R1](tools/deepseek-r1.md) | Bestehender Eintrag, MIT; Distills separat pruefen | 671B/MoE ist kein Einzel-RTX-Standard |
| [Qwen3-235B-A22B](tools/qwen3-235b.md) | Qwen3; Modellkarte Apache-2.0 | 235B insgesamt, 22B aktiv; kein kleiner 22B-Gewichtssatz |
| [QwQ-32B](tools/qwq-32b.md) | QwQ und Modellkarte Apache-2.0 | Speicher inklusive Runtime/KV-Cache pruefen |
| [GPT-OSS-120B](tools/gpt-oss-120b.md) | gpt-oss Apache-2.0 | Upstream MXFP4: 80-GB-GPU; Harmony-Unterstuetzung notwendig |

Keine Zusicherung zertifizierter Rechts-/Steuer-/Finanzexperten. Benchmarks
oder lange Reasoning-Ausgaben begruenden keinen Goldstandard fuer Recht und
keine fehlerfreie Buchhaltung. Open Weights bedeutet nicht offene Trainingsdaten
oder eine komplett reproduzierbare Trainingspipeline. Gewichte sind kein
Klartext-Nachschlagewerk fuer RAG.

Primaerquellen: [DeepSeek-R1](https://github.com/deepseek-ai/DeepSeek-R1),
[Qwen3-Modellkarte](https://huggingface.co/Qwen/Qwen3-235B-A22B),
[QwQ-Modellkarte](https://huggingface.co/Qwen/QwQ-32B),
[GPT-OSS-120B OpenAI Docs](https://developers.openai.com/api/docs/models/gpt-oss-120b),
[GPT-OSS Referenzcode](https://github.com/openai/gpt-oss).
GitHub-Pins sichern Quellen, nicht separat gehostete Gewichte. Qwen3 hat am
geprueften GitHub-Pin keine Root-LICENSE; die Apache-Angabe bezieht sich auf
die Modellkarte, nicht pauschal alle Repository-Inhalte.

## Sicherer Hybrid-Ablauf

1. Auf dem VPS nur Plan/Quellenverwaltung; keine Mikrofonaufnahme oder GPU-Inferenz voraussetzen.
2. Android-/Desktop-Clients auf passenden Endgeraeten betreiben, nicht als K3s-Daemon ausgeben.
3. Dejavu-Datenbank privat halten; Import und Erkennung nur fuer freigegebene Audiodateien.
4. Gewichte separat nach Lizenz, Revision, Pruefsummen, Speicherreserve und GPU-Kompatibilitaet freigeben.
5. Ollama/vLLM nur mit passender Modell-/Quantisierungsunterstuetzung auf dem lokalen Worker einrichten. Kein
automatischer Modell-Pull.
6. VPS zu Worker nur ueber WireGuard und authentifizierte, begrenzte Endpunkte; keine oeffentlichen
Ollama-/Datenbankports.
7. OpenClaw/MCP nur erlaubte Werkzeuge geben; Dokumente und Ergebnisse sind keine vertrauenswuerdigen Befehle.

[Modell-Einrichtung](models/README.md) ergaenzt die Quellenverwaltung.
Je Tool bleiben nativer Runtime-Build, Dependency-Lock, SBOM und echter
End-to-End-Test offen. Keine fertige Agenten-/MCP-Integration behauptet.
Keine systemd-Unit fuer reine Quellenrezepte; kein Docker-Fallback.

## Rechts- und Finanzarbeit

[Promptvorlage](prompts/LEGAL_FINANCIAL_ASSISTANT.md) fuer belegte Entscheidungshilfe.
Jurisdiktion, Stichtag, geltende Fassung und Originalquelle explizit erfassen.
RAG-Korpus mit Herkunft, Abrufdatum und Versionsstand verwenden; Fundstelle
und tatsaechliche Aussage gegeneinander pruefen. Keine erfundenen Paragraphen,
keine autonome Buchung, Zahlung, Steuererklaerung oder Rechtsauskunft freigeben.
Geldwerte mit Decimal oder geprueften Werkzeugen berechnen; Einheiten, Rundung,
Annahmen und Tests nachvollziehbar ausgeben. Keine interne Chain-of-Thought
verlangen: kurze pruefbare Begruendungen genuegen. Vertrauliche Vertraege und
Buchungsdaten nicht an externe Audio-/KI-APIs senden. Ausgaben ersetzen keine
Rechts-, Steuer- oder Anlageberatung.
