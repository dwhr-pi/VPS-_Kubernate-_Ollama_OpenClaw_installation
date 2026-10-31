# Manus-Interview: Toolauswahl, Skill und vorhandene Lieferbausteine

Getrennter weiterer Interviewbereich: [Meta AI](meta-development-tooling.md).

Stand: **22.10.2026**. Quelle ist der vom Nutzer eingefuegte Interviewtext. Zweck: Fuer unser
KI-Setup einen kleinen passenden Stack waehlen und die bereits vorhandenen Skills, CI-Vorlagen und
Folien nachvollziehbar zuordnen. Die Aussage "Ich habe alle Aufgaben abgeschlossen" ist eine
Manus-Aussage, kein Nachweis einer Installation, eines Downloads oder eines Tests in diesem Repo.

## Was jetzt im Repository vorliegt

| Interviewpunkt             | Konkreter Bestandteil hier                                                                                                                           | Nachweis / Grenze                                                                                                |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Skill sprach-infra-tooling | [Neuer Repository-Skill](../../skills/sprach-infra-tooling/SKILL.md) mit [Briefing](../../skills/sprach-infra-tooling/assets/tooling-brief.md)       | Eigene Rekonstruktion des beschriebenen Prozesses, kein importierter Manus-Originalskill; nicht global aktiviert |
| Umsetzung eines Projekts   | [agentic-project-delivery](../../skills/agentic-project-delivery/SKILL.md)                                                                           | Bestehender separater Skill fuer freigegebene Umsetzung, Tests und Bericht                                       |
| Go-/Rust-CI                | [Vorhandene vollstaendige Beispiele](../../examples/manus-ci-cd/README.md)                                                                           | Inaktive .example-Dateien; keine neuen Runner-Runs gestartet                                                     |
| Docker/Kubernetes          | [Bestehende Best Practices](manus-ci-cd-deployment.md)                                                                                               | Optionales Auslieferungsformat eigener Apps; Tools weiterhin aus GitHub statt per Docker installieren            |
| Praesentation              | [Bestehende 13-Folien-PPTX](../presentations/technology-tooling-overview.pptx) und [Folienquelle](../presentations/technology-tooling-overview.json) | Unveraendert weiterverwendet; keine zweite angebliche Manus-Datei erzeugt                                        |
| Toolauswahl                | Auswahlhilfe und Ebenentabelle unten                                                                                                                 | Empfehlung nach vorhandenem Kontext, keine Neuinstallation oder automatische Cloud-Freigabe                      |

Der im Interview genannte Pfad `/home/ubuntu/skills/sprach-infra-tooling/SKILL.md` gehoert zur
fremden Manus-Umgebung. Ebenso ist
`manus-resource://manus-slides/deck/technologie-und-tooling-bersicht-mvhhjsvs-3b87b561` kein
oeffentlicher GitHub-Download. Originalinhalt/Layout sind ohne exportierte Dateien nicht unabhaengig
pruefbar. Der beschriebene Navy/Cyan/Mint-Dark-Mode wird deshalb nicht als Designnachweis unserer
vorhandenen Praesentation ausgegeben.

## Toolauswahl mit vorhandenem Kontext

Die sieben Interviewfragen sind sinnvoll, muessen aber nicht erneut pauschal gestellt werden. Aus
den bisherigen Nutzerangaben kennen wir Windows/WSL2, lokale KI, GitHub als bevorzugte
Installationsquelle und ein Verbot eigenmaechtiger WSL-Eingriffe. RTX 5080 und Letsung MiniPC sind
Nutzerangaben, hier nicht neu vermessen. Freie Disk, tatsaechlicher RAM/VRAM und Treiberstand
bleiben vor einem Build zu pruefen. Keine konkrete Modellgroesse wird als passend zugesichert.

**Kleine Ausgangskombination als Empfehlung:** Eine lokale Inferenz-Runtime, genau ein
Coding-Frontend und die Pruefwerkzeuge des konkreten Projekts. Fuer Dokumentenarbeit erst bei Bedarf
einen Retrieval-Store ergaenzen; fuer wiederkehrende Ablaeufe einen Workflow-Baustein waehlen. vLLM,
mehrere Vectorstores, Dify/Flowise und Kubernetes nicht nur wegen ihrer Erwaehnung parallel
einrichten. Hardware-, Betriebs- und Wartungskosten bleiben auch lokal bestehen.

| Ebene                | Kandidaten / offizielle Quelle                                                                                                                                                                                                                                                                                                                                                                                                     | Einordnung fuer dieses Setup                                                                                                                               |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Modelle/API          | [API-Key-Uebersicht](../_API-Keys/README.md), OpenAI, Anthropic, Gemini, Mistral                                                                                                                                                                                                                                                                                                                                                   | Externe Anbieter optional und bewusst freigeben; keine Keys im Skill/Prompt, keine ungeprueften Gratis-/Preiszusagen                                       |
| Lokale Inferenz      | [Ollama](https://github.com/ollama/ollama), [llama.cpp](https://github.com/ggml-org/llama.cpp), [vLLM](https://github.com/vllm-project/vllm)                                                                                                                                                                                                                                                                                       | Zuerst einen passenden lokalen Weg waehlen. Registry-Eintraege beweisen keinen funktionsfaehigen GPU-Betrieb; Cloud-Funktionen/Downloads gesondert pruefen |
| Recherche            | `https://www.perplexity.ai/` (Perplexity; unverifizierte Originalreferenz, CI HTTP 403, 30.10.2026), [Gemini Notebook (vormals NotebookLM; Google-Mitteilung vom 16.07.2026)](https://blog.google/innovation-and-ai/products/gemini-notebook/notebooklm-gemini-notebook/); `https://notebooklm.google/` (Originaladresse, CI 404 am 31.10.2026; nicht als aktueller Einstieg verifiziert), vorhandene Browser-/Transkriptwerkzeuge | Cloud-Produkte sind keine lokalen GitHub-Installer; Dokumentupload und Datenverarbeitung vorher pruefen                                                    |
| Coding               | [VS Code](https://github.com/microsoft/vscode), [Continue](https://github.com/continuedev/continue), [Aider](https://github.com/Aider-AI/aider), [Cursor](https://cursor.com/), [Copilot](https://github.com/features/copilot)                                                                                                                                                                                                     | Lokal konfigurierbare Clients und kommerzielle Dienste unterscheiden; Modell-/Netzkonfiguration entscheidet ueber Datenfluss                               |
| Workflows/Agenten    | [n8n](https://github.com/n8n-io/n8n), [Dify](https://github.com/langgenius/dify), [Flowise](https://github.com/FlowiseAI/Flowise), [LangGraph](https://github.com/langchain-ai/langgraph)                                                                                                                                                                                                                                          | Produktworkflow, RAG-Plattform und Programmierbibliothek sind verschiedene Entscheidungen; nicht automatisch alle starten                                  |
| RAG/Dokumente        | [LlamaIndex](https://github.com/run-llama/llama_index), [LangChain](https://github.com/langchain-ai/langchain), [Qdrant](https://github.com/qdrant/qdrant), [Chroma](https://github.com/chroma-core/chroma), [pgvector](https://github.com/pgvector/pgvector)                                                                                                                                                                      | Zugriffsschutz vor Retrieval, Quellenrechte und Loeschkonzept planen; fuer den Anfang einen Store waehlen                                                  |
| Sprache              | [Whisper](https://github.com/openai/whisper), [faster-whisper](https://github.com/SYSTRAN/faster-whisper), vorhandene TTS-Werkzeuge                                                                                                                                                                                                                                                                                                | Sprachmodell-/Gewichtslizenzen, Downloads, Einwilligung und Disk getrennt von der Softwareinstallation pruefen                                             |
| Lieferung            | [62er-Werkzeugauswahl](../DEVELOPMENT_TOOLS_OVERVIEW.md), [CI-/Deployment-Vorlagen](../../examples/manus-ci-cd/README.md)                                                                                                                                                                                                                                                                                                          | GitHub-Builds und optionale Container-Auslieferung trennen; kein automatisches Terraform-/Cluster-Deployment                                               |
| Qualitaet/Sicherheit | [Projektchecks](manus-development-workflow.md), [Rechts-/RAG-Review](../legal/README.md), Secret-Management und Kostenlimits                                                                                                                                                                                                                                                                                                       | Logs minimieren, Testdaten verwenden und harte Limits technisch umsetzen; ein Prompt ist keine Sandbox                                                     |

Diese Tabelle ergaenzt die Doku, nicht die Anzahl der installierten Tools. Der aktuelle
62er-Installationsweg ist unter Hauptmenue **16** beschrieben:
[Installation und Verwaltung](../tools/development-toolchain-check.md). Dify ist hier eine
zusaetzliche Referenz, kein neu behaupteter fertiger Installer.

## Unterschiede zur Kurzfassung des Interviews

- **Caching:** Unsere [Go-Vorlage](../../examples/manus-ci-cd/go-ci.yml.example) hat `cache: false`.
  `go-version-file: go.mod` und Race Detection sind bereits umgesetzt. Caching erst nach Freigabe
  mit Schluesseln fuer OS/Architektur, Go-Version und go.sum planen; Cacheinhalt ist kein
  Buildnachweis.
- **Rust:** `cargo clippy --locked --all-targets -- -D warnings`, Formatchecks und gelockte Builds
  sind vorhanden. Cargo.lock allein garantiert keine byteidentischen Binaries;
  Linker/Target/Toolchain/Buildflags gehoeren dazu.
- **Manifestchecks:** Kubeconform/KubeLinter sind im Setup vorhanden, aber diese
  Interview-Ergaenzung startet sie nicht. Schema- und Policypruefung ersetzen weder
  Anwendungs-/Lasttests noch kontrollierten Rollout.
- **Lizenzen:** n8n ist Fair-Code mit Sustainable Use License, keine pauschale
  OSI-Open-Source-Zusage. Dify verwendet eine Apache-2.0-basierte Lizenz mit Zusatzbedingungen.
  Software-, Modell- und Dienstelizenzen getrennt pruefen:
  [n8n-Lizenz](https://github.com/n8n-io/n8n/blob/master/LICENSE.md),
  [Dify-Lizenz](https://github.com/langgenius/dify/blob/main/LICENSE).

## Wiederverwendung als Auftrag

```text
Nutze skills/sprach-infra-tooling/SKILL.md fuer eine Toolauswahl zu meinem Projekt.
Lies vorhandene Nutzerangaben und Projektregeln, bevor du Rueckfragen stellst.
Empfiehl eine kleine lokale Kombination und eine begruendete Alternative.
Nenne offizielle Quellen, Pruefdatum, Lizenz, Datenfluss, Voraussetzungen und
den tatsaechlich vorhandenen Setup-/Paketweg. Unbekannte Werte offenlassen.
Verlinke bei Go/Rust die vorhandenen inaktiven CI-/Deployment-Beispiele und
die vorhandene Praesentation. Keine WSL-/Installations-/Cloud-/Deploy-Aktion.
```

Fuer den naechsten Implementierungsauftrag den Umsetzungs-Skill gesondert verwenden. Keine globale
Aktivierung oder Kopie in einen fremden Skill-Ordner wurde durch diese Dokumentation vorgenommen.

## Pruefumfang dieser Ergaenzung

28 Manus-bezogene Offline-Tests bestanden, einschliesslich Skill-Metadaten, lokaler Referenzen,
vorhandener CI-Schutzregeln und Praesentationsstruktur. Der Standard-Skillvalidator konnte mangels
PyYAML nicht starten; dieses Paket wurde nicht nachinstalliert. Das Lesen des Markdown-Skills
benoetigt PyYAML nicht. Kein Live-Agenten-, GitHub-CI-, Modell- oder Deployment-Test erfolgt.
