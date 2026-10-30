# Ressourcen, Platzierung und Benchmarks

## Platzierung

| Ort                     | Sinnvolle Rolle                                      | Nicht standardmaessig dort betreiben                                   |
| ----------------------- | ---------------------------------------------------- | ---------------------------------------------------------------------- |
| VPS-DMZ                 | TLS/VPN, kleiner API-Gateway, autorisierte Steuerung | Grosse Modelle, ungeschuetzte Agent-Shell, oeffentliches Qdrant/Ollama |
| Kleiner kostenloser VPS | Wenige Hostdienste oder klar begrenzte K3s-Workloads | Voller Monitoring-/Tracing-/Storage-Cluster ohne RAMmessung            |
| Pi                      | WOL, kleiner Queue-/Netzwerkdienst                   | Schwere Builds und verteilter Storage nur aufgrund des Katalogs        |
| MiniPC/WSL2             | UI, kleine lokale Modelle, Entwicklung               | Gleichzeitige Browser-/Video-/Rust-/Node-Grossbuilds ohne Reserve      |
| RTX-Worker              | Ollama/ComfyUI zeitlich oder per Queue budgetiert    | GPU=1 als VRAM-Isolierung missverstehen                                |
| Externes Backupziel     | Verschluesselte Snapshots/Recovery                   | Einziges Backup auf derselben lokalen MinIO-/Host-Disk                 |

Die Tabelle ist eine Empfehlung, keine gemessene Kapazitaetszusage. HE/DNS und Oracle-VPS-Steuerung
ersetzen weder VPN-/Firewall-Grenze noch Dienstauthentifizierung.

## Budgets und Grenzen

Das GPU-Overlay fordert 4Gi RAM/2 CPU an und begrenzt Ollama auf 12Gi/6 CPU plus eine GPU.
Modell-PVC 50Gi und Agent-PVC 20Gi sind Anfragen, keine sofort garantierte physische Kapazitaet.
`local-path` bindet Daten an einen Node. Kubelet-/Controlplane-/Dateisystem-/Pagecache-Reserven
bleiben zusaetzlich erforderlich.

RTX 5080 mit 16GiB VRAM: Modellgewichte, KV-Cache, Context, Batch und andere GPU-Prozesse gemeinsam
messen. Quantisierung ist keine volle numerische Praezision. VRAM-/RAM-OOM kann trotz
`nvidia.com/gpu: 1` auftreten. Kontext/Parallelitaet zunaechst begrenzen, kein unkontrolliertes
Vorladen vieler Modelle.

Unter WSL begrenzen die Windows-Host-Reserven VHDX-Wachstum. Freie Linux-GiB ersetzen keinen freien
Windows-Speicher. Keine Sicherheitswache herabsetzen, nur um einen grossen Build mit unzureichender
Reserve zu starten.

## Messvertrag

Vorhanden: `scripts/benchmarks/ollama_benchmark.py` und `tests/test_local_ai_benchmarks.py`. Lokaler
Loopback-only, explizites vorhandenes Modell/Digest, kein Pull/Cloud-Fallback. Prefill/Decode
Tokens/s, Load- und Wall-Time werden ausgewertet. **TTFT bleibt derzeit null/nicht gemessen**; nicht
durch Gesamtzeit oder Prefill-Time ersetzen.

Fuer vergleichbare Laeufe Modell/Digest/Quantisierung, Runtimeversion, Context, Prompt,
Ausgabelimit, Parallelitaet, GPU-Treiber und Cold-/Warm-Cache angeben. Streaming-TTFT,
RAM/VRAM-Spitzen und Energie benoetigen eigene Collector-Proben; `nvidia-smi`-Leistung ist kein
automatisch integrierter Gesamtstromverbrauch. Modellqualitaet mit konstantem
Aufgaben-/Antwortkatalog statt Tokens/s gleichsetzen.

RAG-Metriken: [Offline-Auswertung und Grenzen](INTEGRATION_GAPS.md#rag-qualitaetsgate). Keine realen
Performancezahlen wurden in diesem Audit erfunden oder gemessen.

## SLO-Entwurf

Als zu verhandelnder Start: 99% interne Gateway-Verfuegbarkeit ueber 30 Tage, null unbeabsichtigte
externe Requests, null fremde Mandantenhits im RAG-Test, taegliches Backup nur bei konsistentem
Snapshot. RPO/RTO je Datentyp festlegen und durch Restore messen. Kein RTO aus einem erfolgreichen
`restic backup` ableiten. WOL-/Modell-Warmup-Latenz gesondert vom bereits bereiten API-Service
messen.
