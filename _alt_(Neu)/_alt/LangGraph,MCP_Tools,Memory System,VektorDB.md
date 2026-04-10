[LangGraph](#LangGraph)
[MCP Tools](#MCP_Tools)
[Memory System](#Memory_System)
[VektorDB](#VektorDatenBank)

LangGraph,MCP_Tools,Memory System,VektorDB.md



## [LangGraph](https://www.google.com/search?q=LangGraph&sca_esv=8ff0655bc19caeb2&sxsrf=ANbL-n4YGnmLW31LllP7ospLcj9iaiddkA%3A1773137310941&udm=50&fbs=ADc_l-YGrpJMQtvjQ6h14rj-dfIrbPkd_Upq68wJVnEIgo2Pwxu679PACFfTKv4n_1_FsyW7-_4uwv78MBmFJSrc6-X95JGUvavgZlJgRfQvykPu7wYieEtWaAosMNgUrzdYPcim_IccvtGBfqg0imG4Fv6lFkii8ocFqmZVYEI7oJHsA0STSZcbmPfSsgnGcm9FQd0437BgGZOg_4ePTtAcC0s6QIzIOg&aep=1&ntc=1&sa=X&ved=2ahUKEwiu2Lmci5WTAxU997sIHQjWJzYQ2J8OegQIHRAE&biw=1440&bih=765&dpr=1&mstk=AUtExfAMup6SAhzsJe0-tZpkesfz7Emirsgil-NVvc-3JwZTyHm4eseVv4pC09V0KV0io0wHOwTl7iLCaJtbAcBJHETjNDac9xprTZKRBa1Ia482YPcxPHTKUXLzBxKnSmDIjkhiJCnMkAJPDL7VrhcqcaGuQ3ErEP_2qKsix4R4tHuw8MDpVLm-c46ddW4n1-zxzZydf8lWqU626lGNPWCXpERi-PZp9Cw6LfV_ndnnpzB3g2AUQ1IK7Zw-sb8UF91sZ04hvQI396_N2MxtxEUT4yVOrU8MdY3kt40hwz6n-rhfDoA1SzU9RHN8SKRMjY-FzbNp2Qwe5JR9JA&csuir=1)
[IBM LangGraph](https://www.ibm.com/de-de/think/topics/langgraph)
`LangGraph ist ein von den Machern von LangChain entwickeltes Open-Source-Framework zur Erstellung komplexer, zustandsbehafteter KI-Anwendungen mit Large Language Models (LLMs)`. Während das klassische LangChain primär auf lineare Ketten (DAGs) ausgelegt ist, ermöglicht LangGraph die Modellierung von zyklischen Workflows, was für iterative Prozesse und autonome Agenten essenziell ist. 

**Kernkonzepte**
Das Framework nutzt eine graphbasierte Architektur, um Logik abzubilden: 
+ **Nodes (Knoten)**: Funktionen, die die eigentliche Arbeit verrichten (z. B. ein LLM aufrufen oder ein Tool nutzen). Sie erhalten den aktuellen Zustand, verarbeiten ihn und geben ein Update zurück.
+ **Edges (Kanten)** Definieren den Kontrollfluss zwischen den Knoten. Es gibt feste Übergänge sowie **bedingte Kanten** (Conditional Edges), die basierend auf dem Status entscheiden, welcher Pfad als Nächstes eingeschlagen wird.
+ **State (Zustand)**: Ein zentrales, gemeinsames Datenobjekt, das während der Ausführung zwischen den Knoten weitergegeben wird. Es dient als "Kurzzeitgedächtnis" des Agenten. 

**Hauptmerkmale & Vorteile**
+ **Zyklen & Iterationen**: Unterstützung von Schleifen, damit Agenten ihre eigenen Ergebnisse reflektieren, korrigieren oder in einer Endlosschleife bis zur Problemlösung arbeiten können.
+ **Persistence (Persistenz)**: Der Status kann nach jedem Schritt automatisch gespeichert werden ("Check-pointing"). Dies ermöglicht es, Prozesse zu unterbrechen und später genau dort fortzuführen.
+ **Human-in-the-Loop**: Menschen können in den Prozess eingreifen, den Status prüfen oder ändern, bevor der Agent den nächsten Schritt ausführt.
+ **Multi-Agent-Systeme**: LangGraph ist darauf optimiert, die Zusammenarbeit mehrerer spezialisierter Agenten zu orchestrieren. 

**Ökosystem & Tools**
**LangSmith Integration**: Zur detaillierten Überwachung (Observability), zum Debugging und zur Bewertung der Agenten-Trajektorien.
**LangGraph Studio**: Eine visuelle Oberfläche zum Prototyping, Testen und Visualisieren der Graph-Strukturen.
**LangGraph CLI**: Ein Command-Line-Tool zum lokalen Erstellen und Ausführen von Agenten-Servern. 

LangGraph ist sowohl für **Python** als auch für **JavaScript/TypeScript** verfügbar und eignet sich besonders für Projekte, die über einfache Chatbots hinausgehen, wie etwa autonome Recherche-Agenten oder komplexe Planungs-Systeme. 

Möchten Sie erfahren, wie Sie einen **einfachen ReAct-Agenten** mit LangGraph in Python aufsetzen, oder interessieren Sie sich für die **visuelle Modellierung** in LangGraph Studio?


## [Model Context Protocol](https://www.google.com/search?q=MCP+Tools&oq=MCP+Tools&gs_lcrp=EgZjaHJvbWUyBggAEEUYOTIHCAEQABiABDIHCAIQABiABDIICAMQABgWGB4yCAgEEAAYFhgeMggIBRAAGBYYHjIICAYQABgWGB4yCAgHEAAYFhgeMggICBAAGBYYHjIICAkQABgWGB7SAQc5NjRqMGo3qAIIsAIB8QXjyBMDV-Oog_EF48gTA1fjqIM&sourceid=chrome&ie=UTF-8#cobssid=s)

MCP-Tools (Model Context Protocol) sind `standardisierte Schnittstellen, die es KI-Modellen (LLMs) ermöglichen, sicher auf externe Datenquellen, APIs und Entwicklungswerkzeuge zuzugreifen und diese zu steuern`. Sie fungieren als Brücke zwischen KI-Assistenten (wie Claude, Cursor) und Systemen, um Aktionen wie Datenbankabfragen oder Code-Ausführungen zu automatisieren. 

**Wichtige Aspekte und Beispiele von MCP-Tools**:
+ **Funktionsweise**: MCP-Server stellen Funktionen (Tools) zur Verfügung, die das KI-Modell basierend auf dem Kontext automatisch aufruft.
+ Beliebte **MCP-Integrationen & Server**:
	+ **Entwicklung**: [Chrome DevTools MCP](https://www.reddit.com/r/ClaudeCode/comments/1o78tfy/list_your_favourite_mcp_tools_and_why/?tl=de) (Debugging), Sentry, Supabase.
	+ **Suche & Daten**: Brave Search MCP, Exa-Search.
	+ **Tools**: Rapid-MCP.com (API-Integration).
	+ **Vision**: Vision MCP Server von z.ai (erweitert Modelle um Bildverarbeitung).
+ **Entwicklung**: Tools können in Sprachen wie Python, TypeScript, Java und C# erstellt werden, wobei [FastMCP](https://gofastmcp.com/servers/tools) die Erstellung durch Python-Funktionen vereinfacht.
+ **Sicherheit**: Da MCP-Tools oft automatisch agieren, ist eine "Human-in-the-loop"-Validierung (Benutzerbestätigung) zur Vermeidung von Sicherheitsrisiken wie Prompt Injection oder unerwünschter Datenexfiltration entscheidend.
+ **Werkzeuge**: Der [MCP Inspector](https://github.com/modelcontextprotocol/inspector) ist ein interaktives Tool zum Debuggen und Testen von MCP-Servern.


[LangGraph])(https://www.ibm.com/de-de/think/topics/langgraph)

[VectorDB](https://www.google.com/search?q=Vector+DB&oq=Vector+DB&gs_lcrp=EgZjaHJvbWUyBggAEEUYOTIHCAEQABiABDIHCAIQABiABDIHCAMQABiABDIHCAQQABiABDIHCAUQABiABDIHCAYQABiABDIICAcQABgWGB4yCAgIEAAYFhgeMggICRAAGBYYHtIBCDExMjRqMGo3qAIIsAIB8QWFYAlFq8Ie-Q&sourceid=chrome&ie=UTF-8)

## [VektorDatenBank](https://www.google.com/search?q=Vector+DB&oq=Vector+DB&gs_lcrp=EgZjaHJvbWUyBggAEEUYOTIHCAEQABiABDIHCAIQABiABDIHCAMQABiABDIHCAQQABiABDIHCAUQABiABDIHCAYQABiABDIICAcQABgWGB4yCAgIEAAYFhgeMggICRAAGBYYHtIBCDExMjRqMGo3qAIIsAIB8QWFYAlFq8Ie-Q&sourceid=chrome&ie=UTF-8)
`Eine Vektordatenbank speichert Daten als hochdimensionale Vektoren (numerische Einbettungen), um Ähnlichkeitssuchen statt exakter Übereinstimmungen durchzuführen`. Sie sind essenziell für KI-Anwendungen, da sie unstrukturierte Daten (Text, Bilder) semantisch verstehen, durchsuchen und bei geringer Latenz relevante Informationen für LLMs (RAG) liefern. 

**Hauptmerkmale und Funktionen**:
+ **Vektoreinbettungen (Embeddings)**: Daten werden in mathematische Darstellungen umgewandelt, die semantische Merkmale erfassen.
+ **Ähnlichkeitssuche (ANN)**: Algorithmen wie *Approximate Nearest Neighbor* (ANN) finden die ähnlichsten Vektoren mittels Kosinus-Ähnlichkeit oder euklidischem Abstand.
+ **Anwendungsfälle**: Ideal für generative KI (RAG - [Retrieval-Augmented Generation](https://en.wikipedia.org/wiki/Vector_database)), semantische Suche, Empfehlungssysteme und Betrugserkennung.
+ **Skalierbarkeit**: Speziell für die Verarbeitung großer Mengen hochdimensionaler Daten ausgelegt. 

Bekannte Vektordatenbanken umfassen spezialisierte Lösungen wie Pinecone, Milvus, Weaviate oder Erweiterungen für bestehende Datenbanken (z. B. [pgvector für PostgreSQL](https://learn.microsoft.com/de-de/azure/postgresql/azure-ai/generative-ai-vector-databases)).

## [Memory System](https://www.google.com/search?q=Memory+System&oq=Memory+System&gs_lcrp=EgZjaHJvbWUyBggAEEUYOTIHCAEQLhiABDIICAIQABgWGB4yCAgDEAAYFhgeMggIBBAAGBYYHjIICAUQABgWGB4yCAgGEAAYFhgeMggIBxAAGBYYHjIICAgQABgWGB4yCAgJEAAYFhge0gEIMTE3OGowajeoAgiwAgHxBZv6p-py2XK4&sourceid=chrome&ie=UTF-8)

Ein Memory System (Speichersystem) bezeichnet die `strukturierte Organisation von Datenspeichern in Computern (hierarchisch: Register, Cache, RAM, Festplatte) oder spezielle Softwarelösungen`. Dazu gehören Translation-Memory-Systeme (TMS) für Übersetzungen, Arbeitsspeicher (RAM) zur Zwischenspeicherung sowie KI-Speichersysteme (z.B. GitHub Copilot, Vektor-Datenbanken) für Kontextspeicherung. 

Hier sind die verschiedenen Arten von Memory Systems im Detail:

##### 1. Computerspeicher (Hardware-Hierarchie)
Computer nutzen eine hierarchische Struktur, um Leistung und Kapazität zu optimieren: 

+ **Register**: Kleinste, extrem schnelle Speicher direkt im Prozessor.
+ **Cache (L1-L3)**: Sehr schneller Zwischenspeicher für häufig benötigte Daten.
+ **Arbeitsspeicher (RAM)**: Flüchtiger Kurzzeitspeicher für laufende Programme.
+ **Sekundärspeicher**: Langsamerer, nicht-flüchtiger Speicher (Festplatten, SSDs). 

Dieses Video erklärt die verschiedenen Komponenten des Computerspeichers:

Thumbnail des zugehörigen Videos
[Informatik - simpleclub](https://youtu.be/gA_F0id3zAc?si=rQM_vDrjxVVnPLEJ)
YouTube • 12.10.2016

##### 2. Translation-Memory-Systeme (TMS) 
Software, die in der Übersetzungsbranche genutzt wird, um bereits übersetzte Segmente (Ausgangstext + Übersetzung) in einer Datenbank zu speichern. 

+ **Vorteile**: Erhöhte Konsistenz, Zeitersparnis, Kostensenkung.
+ **Funktionsweise**: Das System schlägt bei neuen Übersetzungen automatisch gespeicherte Entsprechungen vor. 

##### 3. KI- und Sprachmodell-Memory
Systeme, die es Künstlicher Intelligenz ermöglichen, Kontext über Chats oder Sitzungen hinweg zu behalten. 

+ **Vektor-Datenbanken**: Vektorisieren vergangene Chats für semantische Ähnlichkeitssuchen.
+ **RAG (Retrieval-Augmented Generation)**: Nutzen Datenbanken, um relevante Daten automatisch in den Kontext einzufügen.
+ **Beispiele**: GitHub Copilot Memory für kontextbezogenes Lernen. 

##### 4. Allgemeine "Memory"-Funktionen
Technologien in elektronischen Geräten, die letzte Einstellungen (z.B. Helligkeit bei Lampen) speichern. 

**Wichtige Konzepte**
+ **Flüchtigkeit**: Daten im RAM gehen nach Abschalten verloren.
+ **Zugriffszeit**: Speicher in der Nähe des Prozessors ist schneller, aber kleiner.
+ **Kontext**: In der KI ermöglicht Memory das Abrufen von Informationen aus früheren Interaktionen

