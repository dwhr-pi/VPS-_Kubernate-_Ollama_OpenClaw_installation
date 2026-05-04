# Knowledge_Graph_RAG

## Zweck
Graph-RAG mit Entitäten, Beziehungen und lokaler Wissensgraph-Schicht.

## Typische Aufgaben
- Entitäten extrahieren
- Relationen modellieren
- Graph- und Vektor-Retrieval kombinieren
- domänenspezifische Wissensnetze aufbauen

## Empfohlene Tools
Neo4j, Qdrant, LightRAG, LlamaIndex, Haystack.

## Optionale Tools
KuzuDB, Graphiti, pgvector.

## Benötigte Ports
`6333`, `7474`, `7687`

## Ressourcenbedarf
8 GB RAM empfohlen; bei großen Graphen mehr.

## Sicherheitsrisiken
Graphen bündeln oft stark sensitive Zusammenhänge. Zugriffe und Exporte besonders schützen.

## Ollama/OpenClaw-Fit
Sehr gut für strukturierte Research-, Compliance- und DMS-nahe Wissensarbeit.

## LiteLLM/Open WebUI-Fit
Gut in Kombination mit LiteLLM als Gateway und Open WebUI als exploratives Frontend.

## Quickstart
`bash scripts/profiles/Knowledge_Graph_RAG_install.sh`

## Deinstallation
`bash scripts/profiles/Knowledge_Graph_RAG_uninstall.sh`

## Sinnvolle lokale Modelle
Modelle mit solider Extraktions- und Zusammenfassungsqualität.

## Grenzen und Warnhinweise
Graph-RAG erhöht Komplexität. Erst für klare Domänen und Datensätze einsetzen.
