# ChromaDB Integration Guide

## Kurzfassung

ChromaDB ist eine lokale Vektor-/Embedding-Datenbank fuer RAG, Memory, Dokumentensuche und Agentenkontext. Je nach Nutzung kann ChromaDB entweder direkt als Python-Bibliothek in Skripten laufen oder als eigener lokaler Server gestartet werden.

Nach der Installation liegt die Python-Umgebung typischerweise in:

```bash
/opt/chromadb/venv
```

Dein Installationslog zeigt eine erfolgreiche Installation, u. a. mit:

```text
chromadb-1.5.9
```

## Installation pruefen

```bash
source /opt/chromadb/venv/bin/activate
python -c "import chromadb; print('ChromaDB OK')"
pip show chromadb
```

## Nutzung als Python-Bibliothek

Fuer einfache lokale RAG-/Memory-Skripte reicht die Python-Bibliothek:

```python
import chromadb

client = chromadb.PersistentClient(path="/home/ubuntu/.openclaw_ultimate_user_data/chromadb")
collection = client.get_or_create_collection("openclaw_memory")
collection.add(
    ids=["example-1"],
    documents=["Dies ist ein lokaler Testeintrag fuer OpenClaw Memory."]
)
print(collection.count())
```

Empfohlener Speicherort:

```bash
~/.openclaw_ultimate_user_data/chromadb/
```

## Nutzung als lokaler Server

Wenn ein Tool per HTTP auf ChromaDB zugreifen soll, kann ein Servermodus genutzt werden. Der genaue Startbefehl haengt von der installierten Version ab. Typische Variante:

```bash
source /opt/chromadb/venv/bin/activate
chroma run --host 127.0.0.1 --port 8000 --path "$HOME/.openclaw_ultimate_user_data/chromadb"
```

Wichtig: Nicht oeffentlich binden. Standard fuer dieses Setup ist `127.0.0.1` oder Zugriff ueber Tailscale.

## Wofuer ist ChromaDB sinnvoll?

- lokale Wissensdatenbanken
- Chat-/Projekt-Memory
- Dokumenten-RAG
- Persona-Memory
- schnelle lokale Tests ohne separaten Qdrant-Server
- Agenten-Kontext fuer OpenClaw, LangGraph, CrewAI und AutoGen

## Was ChromaDB nicht ist

ChromaDB ist nicht das Modell und nicht der Chat-Agent.

- Ollama erzeugt Antworten und Embeddings, speichert aber nicht automatisch deine Dokumente in ChromaDB.
- OpenClaw nutzt ChromaDB nicht automatisch, nur weil ChromaDB installiert ist.
- ChromaDB beantwortet keine Fragen allein. Es liefert passende Textstuecke, Erinnerungen oder Dokumente zurueck.
- Ein RAG-/Memory-Workflow muss ChromaDB bewusst befuellen und abfragen.

Praktisch bedeutet das:

```text
Dokumente/Notizen/Chats
  -> Import-/Chunking-Skript
  -> Embeddings erzeugen
  -> ChromaDB speichert Vektoren + Text
  -> Frage kommt rein
  -> ChromaDB liefert passende Treffer
  -> Ollama/OpenClaw nutzt diese Treffer als Kontext
```

## Typische Kombinationen

| Kombination | Zweck | Status im Setup |
|---|---|---|
| ChromaDB + Python-Skript | einfachster lokaler Memory-/RAG-Test | vorbereitet, Beispielskripte noch TODO |
| ChromaDB + Ollama | Ollama generiert Antwort, ChromaDB liefert Kontext | braucht RAG-Skript oder Tool |
| ChromaDB + OpenClaw | OpenClaw fragt Memory/RAG ab und nutzt Treffer im Task | noch nicht automatisch integriert |
| ChromaDB + LlamaIndex | LlamaIndex baut Index-/Query-Pipeline | sinnvoller naechster Integrationspfad |
| ChromaDB + LangChain/LangGraph | Graph-/Agenten-Knoten mit Retriever | spaeterer Worker |
| ChromaDB + Open WebUI | Knowledge-/RAG-nahe Nutzung je nach Open-WebUI-Konfiguration | separat konfigurieren |
| ChromaDB + Memory_Import_Export | Chat-/Markdown-/JSONL-Import als lokaler Wissensspeicher | geplant |
| ChromaDB + Persona-System | langfristige Persona-/Projekt-Erinnerungen | geplant, nur mit Transparenz |

## Minimaler Nutzungsablauf

1. Dokument oder Notiz vorbereiten.
2. Text in Abschnitte teilen.
3. Embeddings erzeugen, z. B. ueber ein lokales Modell oder eine Pipeline.
4. Abschnitte in ChromaDB speichern.
5. Bei einer Frage aehnliche Abschnitte suchen.
6. Treffer als Kontext an Ollama/OpenClaw/LiteLLM weitergeben.

Ohne diese Pipeline bleibt ChromaDB nur installiert, aber ungenutzt.

## Beispiel: ChromaDB lokal befuellen

```bash
source /opt/chromadb/venv/bin/activate
python
```

```python
import chromadb

client = chromadb.PersistentClient(
    path="/home/ubuntu/.openclaw_ultimate_user_data/chromadb"
)
collection = client.get_or_create_collection("openclaw_notes")

collection.add(
    ids=["note-001"],
    documents=["Huginn laeuft im Setup auf Port 3002 und nutzt Web- und Worker-Service."]
)

print(collection.count())
```

## Beispiel: ChromaDB abfragen

```python
results = collection.query(
    query_texts=["Auf welchem Port laeuft Huginn?"],
    n_results=3
)

print(results["documents"])
```

Hinweis: Fuer bessere Trefferqualitaet sollte spaeter ein definiertes Embedding-Modell genutzt werden. Diese Auswahl ist noch ein TODO fuer die OpenClaw-/Ollama-Integration.

## Welche vorhandenen Tools koennen ChromaDB nutzen?

| Tool/Profil | ChromaDB-Nutzen | Integrationsart |
|---|---|---|
| OpenClaw | lokaler Memory-/RAG-Speicher | Python-Tool oder HTTP-Server |
| Open WebUI | Knowledge-/RAG-nahe Nutzung, je nach Konfiguration | indirekt |
| LangGraph | Retriever-Knoten fuer Graphen | Python-Bibliothek |
| CrewAI | Wissen fuer Rollen/Teams | Tool/Retriever |
| AutoGen | gemeinsamer Kontext fuer Agenten | Tool/Retriever |
| LlamaIndex | Vektorstore-Backend | Python-Integration |
| Document_Intelligence | Dokumente einbetten und durchsuchen | RAG-Pipeline |
| Memory_Import_Export | Chat-/Markdown-/JSONL-Importe speichern | Import-Pipeline |
| Personal_Knowledge_Memory | lokaler Wissensspeicher | Memory-Pipeline |

## Unterschied zu Qdrant

| Punkt | ChromaDB | Qdrant |
|---|---|---|
| Einstieg | sehr einfach lokal/Python | staerker als eigener Server |
| Betrieb | Bibliothek oder lokaler Server | Dienst/API |
| MiniPC Standalone | sehr gut | sehr gut |
| Skalierung | eher leicht bis mittel | besser fuer groessere Vektor-Sets |
| Setup-Komplexitaet | niedrig | mittel |

Empfehlung:

- ChromaDB fuer schnelle lokale Memory-/RAG-Tests und Python-nahe Workflows.
- Qdrant fuer stabilere Server-/API-Setups und groessere RAG-Sammlungen.

## OpenClaw-Zielbild

```text
OpenClaw Task
  -> scripts/chromadb/query_memory.py
  -> ChromaDB PersistentClient
  -> relevante Dokumente/Erinnerungen
  -> OpenClaw nutzt Kontext fuer Antwort oder Tool-Plan
```

Aktueller Stand:

- ChromaDB ist als Tool installierbar.
- ChromaDB ist in Profilen wie `RAG_Wissensdatenbank`, `Personal_Knowledge_Memory`, `Memory_Import_Export` und `Next_Level_Persona_System` sinnvoll.
- Es gibt noch kein fertiges OpenClaw-Tool, das ChromaDB automatisch befuellt oder abfragt.
- Das muss bewusst nachgeruestet werden, damit OpenClaw ChromaDB wirklich nutzt.

## Sicherheit und Datenschutz

- ChromaDB kann private Dokumente, Chatverlaeufe und personenbezogene Daten enthalten.
- Datenbankordner gehoeren nicht ins Repo.
- Standardpfad: `~/.openclaw_ultimate_user_data/chromadb`.
- Keine oeffentliche Bindung des HTTP-Servers.
- Vor Exporten sensible Inhalte redigieren.

## TODO fuer spaeter

- [ ] `scripts/chromadb/import_markdown_memory.py` erstellen.
- [ ] `scripts/chromadb/query_memory.py` erstellen.
- [ ] Embedding-Modell festlegen, z. B. lokales Ollama-Embedding-Modell oder kompatible Pipeline.
- [ ] Doctor-Check fuer ChromaDB-Import und optionalen Serverport ergaenzen.
- [ ] OpenClaw-Tooldefinition fuer ChromaDB-RAG-Kontext ergaenzen.
- [ ] Memory_Import_Export-Profil mit ChromaDB-Beispielpipeline verbinden.
- [ ] Redaction-Pruefung vor Import sensibler Dokumente dokumentieren.
