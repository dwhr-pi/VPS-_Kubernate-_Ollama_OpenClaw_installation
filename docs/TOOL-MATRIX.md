# Tool-Matrix: Auswahl, Nachweis und Alternativen

Die vollstaendige maschinenlesbare Grundlage bleibt
[config/tools.yml](../config/tools.yml). Die [generierte Tool-Matrix](generated/TOOL_MATRIX.md)
listet die 402 Hauptwerkzeuge mit Lifecycle-Verweisen; der
[SSH-Wegweiser](generated/HEADLESS_TOOL_COMMANDS.md) zeigt konkrete Befehle.
Fehlende Doctor-/Update-Eintraege, Status oder Runtime-Nachweise nicht
aus einem Installer-Dateinamen ableiten. Hardware und letztes Testdatum
gelten nur, wenn der jeweilige Tool-Bericht sie belegt.

| Zweck | Empfohlener Einstieg | Alternative, bleibt erhalten |
| --- | --- | --- |
| Lokale Inferenz | Ollama mit begrenztem Kontext und Parallelitaet | llama.cpp/vLLM nach Modell-, Hardware- und Betriebsabnahme |
| Modellauswahl und Routing | Privates LiteLLM vor Ollama | OpenRouter nur bei bewusster externer Freigabe; kein Cloud-Fallback als Default |
| Automatisierung | n8n fuer allgemeine Workflows | Activepieces, Huginn fuer Ereignisse; Pipedream fuer bewusst externe Integrationen |
| Visuelle LLM-Flows | Flowise oder LangFlow passend zu vorhandenen Flows | Jeweils das andere, keine parallele Pflichtinstallation |
| Persistente Vektoren | Qdrant mit separatem Restore-Test | pgvector wenn PostgreSQL ohnehin betrieben wird |
| Private Verbindung | Vorhandenes WireGuard | Tailscale opt-in; keine parallele Pflicht |
| Monitoring | Vorhandenes Monitoring-lite | Langfuse opt-in nach Pruefung von Datenfluss, Speicher und Retention |

Menue: Ollama, OpenClaw und Ruflo vor der Trennlinie. Danach die
eingefrorene A-Z-Basis, derzeit 352 Schluessel. Neue Eintraege bleiben
hinter dem letzten bestehenden Anhang; der Stand beginnt dort mit Markdown
Docs Server, Cloudflared und XERJ. Nicht allein wegen der alphabetischen
Anzeige die Registry oder funktionale Abhaengigkeiten umsortieren.
