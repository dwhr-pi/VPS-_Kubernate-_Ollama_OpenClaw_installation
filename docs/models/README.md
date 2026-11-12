# Coding-Modelle: Einrichtung, Sprachen und Werkzeuge

Gezielte Quellenpruefung: **11.11.2026**. Dokumentation und Offline-Fixtures,
keine Installation von Gewichten, keine Inferenz- oder Trainingsabnahme.
Native GitHub-Source-Builds bleiben Vorgabe; kein Docker-Fallback.

## Navigation

- [Modell-Detailseiten-Vorlage](MODEL_PAGE_TEMPLATE.md)
- [Offline-Routing, GGUF-Exportplan und Monitoring](../MODEL_ROUTING_EXPORT_AND_MONITORING.md)

- [Qwen-Coder-Tool und Quellen-Lifecycle](../tools/qwen-coder.md)
- [Open Weights, RAG und erkennbare Modellherkunft](WEIGHTS_RAG_AND_PROVENANCE.md)
- [Wissensluecken, Weitertraining und Nachfolgemodelle](TRAINING_AND_EVALUATION.md)
- [DeepSeek-R1](../tools/deepseek-r1.md), [MiniMax-M3](../tools/minimax-m3.md)
- [API-Zugaenge sind separate Cloud-Dienste](../_API-Keys/README.md)

## 1. Was ist hier Open Source?

Qwen Coder ist eine Modellfamilie, Qwen Code ein Client und Ollama eine
Inferenz-Runtime. Diese drei Installationen sind nicht austauschbar.
Das neue Tool `Qwen_Coder` bereitet gepinnte GitHub-Quellen vor, nicht die Gewichte.

| Modell / Projekt | Gepruefte Einordnung | Nicht daraus ableiten |
| --- | --- | --- |
| Qwen3-Coder-30B-A3B-Instruct | Open Weights, Apache-2.0 laut offizieller Modellkarte | Alle Qwen-Varianten gleich lizenziert; Trainingskorpus vollstaendig verfuegbar |
| Qwen2.5-Coder-7B-Instruct | Kleineres, separat zu pruefendes Modell; eigene Modellkarte | Eine 7B- oder 30B-Konfiguration passt ungeprueft auf jede RTX |
| DeepSeek-R1 | Code und R1-Gewichte laut Upstream MIT; Distill-Basismodelle gesondert | Jede DeepSeek-Generation unter denselben Bedingungen |
| MiniMax-M3 | Open Weights mit MiniMax Community License | Uneingeschraenkte Open-Source-/kommerzielle Freigabe |
| Obot / Qwen Code / Aider / OpenCode | Anwendungen bzw. Clients, keine trainierten Coding-LLMs | Deren Implementierungssprache beschreibt die Faehigkeiten des angebundenen Modells |
| LTX Video | Videomodell-/Quellprojekt | Coding-Sprachen oder Coding-Benchmark-Faehigkeiten |

Primaerquellen: [Qwen3-Modellkarte](https://huggingface.co/Qwen/Qwen3-Coder-30B-A3B-Instruct),
[Qwen2.5-Modellkarte](https://huggingface.co/Qwen/Qwen2.5-Coder-7B-Instruct),
[DeepSeek-R1](https://github.com/deepseek-ai/DeepSeek-R1),
[MiniMax-Review mit Modelllizenz](../HYBRID_CLOUD_MCP.md).

## 2. Welche Programmiersprachen?

Es gibt keine verlaessliche Ja/Nein-Grenze wie bei einem Compiler. Ein Modell
kann plausiblen Text in vielen Sprachen erzeugen und trotzdem falsche APIs,
Speicherzugriffe oder Syntax liefern. "Unterstuetzt" ist kein Qualitaetsnachweis.
Die folgende Tabelle trennt Herstellerangaben und noch zu messende Faehigkeiten.

| Modell | Belegte Sprachangabe / Beispiele | Assembler | Setup-Nachweis |
| --- | --- | --- | --- |
| Qwen3-Coder-Familie, insbesondere aktueller Next-Abschnitt | Upstream nennt 358 Coding-Sprachen/Formate; Auswahl: Python, JavaScript, TypeScript, C, C++, C#, Java, Rust, Go, Ruby, PHP, Swift, Kotlin, Scala, SQL, Shell, PowerShell, Fortran, COBOL, Verilog | Assembly, GAS und WebAssembly stehen in der Upstream-Liste | Kein lokaler Sprachbenchmark; nicht ungeprueft auf jeden Checkpoint uebertragen |
| Qwen2.5-Coder | Mehrsprachiges Coding wird im technischen Bericht bewertet; fuer den gewaehlten 7B-Checkpoint ist eine eigene Testmatrix erforderlich | Hier nicht fuer einen Dialekt abgenommen | Nicht installiert oder evaluiert |
| DeepSeek-R1 | Coding-Evaluation im Modell-README; keine hier belegte vollstaendige Sprachliste mit garantierter Abdeckung | Moeglicher Testbereich, keine Zusage fuer x86/ARM/RISC-V | Nicht installiert oder evaluiert |
| MiniMax-M3 | Allgemeine Coding-/Agentenfaehigkeiten; in der geprueften Quelle keine vollstaendige garantierte Sprachliste | Nicht explizit belegt; vor Nutzung testen | Nicht installiert oder evaluiert |

Die [vollstaendige Qwen-Upstream-Liste](https://github.com/QwenLM/Qwen3-Coder)
enthaelt auch Daten-/Konfigurationsformate. Diese Zahl ist keine Anzahl einzeln
bestandener Compilerabnahmen. [Qwen2.5-Bericht](https://arxiv.org/abs/2409.12186).

**Eigene Pruefliste pro Modell, keine behauptete Supportliste:** Python;
JavaScript/TypeScript; C/C++; C#; Java; Rust; Go; Shell/PowerShell; SQL;
Ruby/PHP; Swift/Kotlin; Lua/R; Fortran/COBOL; Verilog/VHDL; Assembly.
Versionen und Frameworks jeweils angeben. Deutsch/Englisch fuer Erklaerungen
separat testen: gute deutsche Antworten beweisen keine C++-Korrektheit.

### Assembler genauer pruefen

Assembler ist eine Sprachfamilie: x86-64, AArch64 und RISC-V unterscheiden sich;
Intel-/AT&T-Syntax, NASM/GAS, Betriebssystem, ABI und Aufrufkonvention ebenfalls.
WebAssembly oder LLVM IR sind kein Nachweis fuer nativen x86-Assembler.

Pro Test festlegen: ISA/Erweiterungen, Syntax, Assembler-Version, OS/ABI,
Register-/Stack-Vertrag, Ein-/Ausgaben und erlaubte Befehle. Dann assemblieren,
gegen eine bekannte Referenz testen und Disassembly pruefen. Ein harmloser Test
ist eine reine Additionsfunktion ohne Syscalls; Randwerte und Registererhalt
mitpruefen. Keine Modellvorschlaege ungeprueft auf dem Host ausfuehren.
Cross-Architektur braucht separat freigegebene Hardware oder Emulation;
ein x86-Test beweist keine ARM-Faehigkeit. Evaluationsvorlagen:
[JSON-Testfaelle](../../examples/models/coding-eval-cases.json).

## 3. Vollstaendiger Einrichtungsweg mit Open Weights

### Schritt A: Quellen und Voraussetzungen

1. Signierten Setup-Stand nach [Installationsanleitung](../INSTALL_SIGNED_RELEASE.md)
   verwenden; vorhandene Benutzerdaten und laufende Dienste erhalten.
2. `Qwen_Coder` bewusst auswaehlen oder dessen `--dry-run` lesen. GitHub-Quellen
   und Modellartefakte sind getrennte Lieferketten.
3. Vorhandene native Inferenz-Runtime und GPU-Treiber pruefen, nicht automatisch
   ersetzen. [Ollama](../tools/registry/ollama.md) und
   [Buildrichtlinie](../INSTALLATION_POLICY.md) verwenden.

### Schritt B: Exakten Checkpoint und Speicherbedarf festlegen

Festhalten: Modell-ID, voller Gewichts-Revision-Pin, Lizenz, Downloadherkunft,
Format, Quantisierung, Tokenizer und Chat-Template. GitHub-Code-Pin und
Gewichts-Pin sind **zwei verschiedene Pins**. Ein `main`-Link ist kein Gewichtspin.
Fuer jede Gewichts-/Index-/Tokenizerdatei SHA256 gegen einen unabhaengig
bezogenen oder signierten Freigabenachweis pruefen; ein Hash direkt neben einem
unvertrauten Download beweist dessen Herkunft nicht.

Planungsrechnung: Parameterzahl mal Bits geteilt durch acht liefert nur eine
Rohgewichtsuntergrenze. Beispiel 30 Milliarden bei 4 Bit: rund 14 GiB, nicht
der gesamte RAM-/VRAM-Bedarf. Dazu kommen Quantisierungsmetadaten, KV-Cache,
Runtime und Arbeitsbereiche. 3B aktive MoE-Parameter bedeuten nicht 3B zu
speichernde Gesamtgewichte. Kontext und Parallelitaet klein beginnen.
Unter WSL auch freien Windows-Hostspeicher pruefen; Entpacken, Konvertieren und
Training benoetigen oft mehrere Kopien. Keine Passgarantie fuer eine RTX 5080.

### Schritt C: Freigegebene Gewichte extern bereitstellen

Gewichte ausserhalb des Repos, etwa unter
`~/.openclaw_ultimate_user_data/models/`, ablegen. Keine API-Keys, Checkpoints
oder Trainingskorpora in Git. Vorher Lizenz und Datenrechte bestaetigen.

Offizielle Modellkarten verweisen haeufig auf Hugging Face oder ModelScope.
**Die GitHub-Quellenrichtlinie ist keine automatische Freigabe dieser Hosts.**
Eine andere Gewichtsquelle braucht eine bewusste gesonderte Freigabe oder ein
geprueftes bereitgestelltes Artefakt. Deshalb hier kein stiller Hub-Download,
kein Registry-Pull und keine universelle "alles installieren"-Zeile.
Bereitstellung und Hashpruefung sind der noch manuell auszufuellende Schritt,
nicht ein bereits erfolgreicher Installer-Nachweis.

Safetensors fuer Tensoren bevorzugen; fremde Pickle-/`.pth`-Dateien nicht
ungeprueft laden. `trust_remote_code=True` ist keine Standardfreigabe.
Auch Modellformate brauchen aktuelle Parser, Groessenlimits und Rechtegrenzen.
Siehe [Safetensors](https://huggingface.co/docs/safetensors/index).

### Schritt D: Import in eine kompatible Runtime

Nicht jede Architektur oder Quantisierung wird von jeder Runtime-Version
unterstuetzt. Aktuelle Kompatibilitaet fuer den **exakten** Checkpoint pruefen.
Ein Safetensors-Verzeichnis ist nicht automatisch ein GGUF; Konvertierung nur
mit passendem, gepinntem Konverter und danach eigener Qualitaetspruefung.
[llama.cpp](https://github.com/ggml-org/llama.cpp) ist ein moeglicher Konverter/
Inferenzpfad, keine pauschale Kompatibilitaetszusage.

Beispiel fuer ein **bereits freigegebenes und lokal vorhandenes** GGUF mit
einer kompatiblen nativen Ollama-Version; Pfad ersetzen, nicht blind ausfuehren:

```text
# Modelfile: local artifact only; never a remote model alias.
FROM /srv/ai/models/qwen-coder/model.gguf
PARAMETER num_ctx 4096
PARAMETER temperature 0.1
```

Nur der Betreiber darf nach Pruefung importieren; der bereits eingerichtete
private Ollama-Dienst muss bewusst laufen. Dieser Schritt schreibt Modelldaten:

```bash
ollama create local-qwen-coder -f /srv/ai/models/qwen-coder/Modelfile
ollama show local-qwen-coder
```

Kein automatisches `ollama run` oder `pull`: solche Aufrufe koennen weitere
Downloads oder Inferenz ausloesen. Fehlende lokale Dateien sind ein Fehler,
kein Anlass fuer Cloud-Fallback. [Ollama-Import](https://docs.ollama.com/import),
[Modelfile-Referenz](https://docs.ollama.com/modelfile).

### Schritt E: Privat verbinden und abnehmen

Lokal Loopback; ueber VPS/WireGuard einen authentifizierten privaten Gateway
nutzen. Kein oeffentliches `11434`, keine Cloud als stiller Ersatz.
Zuerst einzelne harmlose Prompts, dann explizit freigegebene Coding-Tests.
Modell-Digest, Runtime-Pin, Kontext, Quantisierung, Seed soweit unterstuetzt,
Latenz, Tokens, RAM/VRAM und Ausgaben mit redigierten Testdaten dokumentieren.
Ein erfolgreicher Import ist noch kein Sprach-/Tool-Calling-Nachweis.

## 4. Wie verwenden die Coding-Tools das Modell?

```text
Qwen Code / Aider / OpenCode / freigegebener Agent
    -> privater Modell-Endpunkt oder vorhandenes Inference-Gateway
       -> native Runtime -> lokal freigegebene Gewichte
    -> getrennte Tool-Berechtigungen -> Worktree und Sandbox
```

Das LLM erzeugt Text/Tool-Anforderungen; **der Client** entscheidet ueber
Dateizugriffe, Tests und Shell-Befehle. Mehr Modellrechte sind nicht noetig.
Read-only zuerst; Schreibzugriffe nur mit Freigabe in einem eigenen Worktree.
Tool-Calling, Streaming, JSON-Ausgabe und Edit-Format separat testen.
OpenAI-kompatibel bedeutet nur API-Teilkompatibilitaet, nicht gleiche Faehigkeiten.
[Ollama-Kompatibilitaet](https://docs.ollama.com/api/openai-compatibility).

| Vorhandenes Werkzeug | Anschluss und Grenze |
| --- | --- |
| [Qwen Code](../tools/qwen-code.md) | Lokalen Provider, exakte Modell-ID und Kontext konfigurieren; Client-Build installiert keine Gewichte |
| [Aider / OpenCode](../agents/NATIVE_CLI_BUILDS.md) | Versionseigenen Ollama-/OpenAI-kompatiblen Provider verwenden; Edit-Format und Repo-Map testen |
| [OpenHands / Coding-Workbench](../agents/LOCAL_CODING_WORKBENCH.md) | Lokales Modell ist nur Backend; dessen Sandbox muss separat Docker-frei und begrenzt abgenommen sein |
| [OpenClaw](../tools/registry/openclaw.md) | Lokale Route explizit konfigurieren; Skills/MCP und Shell-Freigaben sind nicht Teil der Gewichte |
| [LiteLLM](../tools/litellm.md) | Optionaler vorhandener Router; nur die erlaubte lokale Route, keine automatische Provider-Ausweichliste |
| Andere Coding-Clients | Ob eigene lokale Provider unterstuetzt sind, versionsbezogen pruefen; kein universeller Schluessel-/Konfigurationsname |

[Aider-Ollama-Anleitung](https://aider.chat/docs/llms/ollama.html) und
[OpenCode-Providerdokumentation](https://opencode.ai/docs/providers/)
belegen moegliche Anschlusswege, keine hier getestete Integration.
Hostnamen, Modellalias und API-Protokoll pro Client passend setzen. Dummy-Keys,
die ein SDK formal verlangt, bieten keine Authentifizierung fuer einen Server.
Geheimnisse nie global an alle Clients exportieren.

## 5. Sinnvolle Reihenfolge

Zuerst ein kleines passend lizenziertes Modell mit wenigen gleichzeitigen
Anfragen. Dann Sprach-/Compiler-Tests und Agentenrechte. Danach RAG fuer eigene
Dokumentation; erst bei gemessenen verbleibenden Fehlern gezieltes Training.
Kein neues Gateway, keine zweite Vektordatenbank oder weiterer Cluster allein
wegen der Aufnahme eines Modells. Die folgenden beiden Kapitel liefern die
Pruefschritte; keines davon startet Downloads, Modelle oder Training.
