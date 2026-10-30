# Lokaler Kubernetes-Ressourcenplaner

[Planer oeffnen](index.html). Lokal im Browser die HTML-Datei oeffnen; auf GitHub wird HTML nur als
Quelltext gezeigt. Keine Installation, kein Webserver noetig, keine API, Telemetrie,
Profil-/Cookieimporte oder Clusterverbindungen. JavaScript muss aktiviert sein. Nicht mit Secrets
oder realen Prompts fuettern.

## Annahmen und Formeln

CPU-Inferenz; alle **Gesamtparameter** im RAM. Keine simulierte GPU-, SSD- Expertstreaming- oder
Unified-Memory-Magie. GiB = 2^30 Bytes, KiB = 2^10 Bytes.

```text
Gewichte GiB = Parameter(Milliarden) * 1e9 * Bits/8 / 2^30 * 1.15
KV GiB       = KV KiB/Token/Slot * Kontext * parallele Slots / 2^20
Pod-RAM GiB  = (Gewichte + KV + Runtime) * 1.15
Pod-vCPU     = parallele Slots * angenommene vCPU/Slot
Pods/Node    = min(floor((RAM - Reserve)/Pod-RAM),
                   floor((vCPU - Reserve)/Pod-vCPU),
                   floor(0.85 * freie Disk/PVC-Groesse))
Angebotene parallele Arbeit = Anfragen/Minute / 60 * Bearbeitungssekunden
Sollpods     = ceil(angebotene Arbeit / (Slots * Zielauslastung)), mindestens 1
```

Beide 15%-Aufschlaege sind **Sicherheitsannahmen**, nicht gemessene Werte. Die erste Reserve
betrifft Quantisierungs-/Gewichtsmetadaten, die zweite Runtime- Spitzen. KV pro Token ist frei
einzugeben: keine erfundene exakte Gemma-Konstante. Modelldateigroesse, KV, RSS und reale
Serving-Zeit muessen vor Abnahme gemessen werden. PVC braucht mindestens 1.3 \* geschaetzte
Gewichte; sonst ist das Profil nicht planbar. Jedem Pod wird ein eigener Modell-PVC zugerechnet.
Cachekopien, weitere Modelle und Logs koennen mehr Platz brauchen.

Die Node-Reserve umfasst Linux, K3s, Ingress, OpenClaw, LiteLLM und Monitoring konservativ **je
Node**. Nicht gleichzeitig als freies Allocatable rechnen. Standardslots/Runtime/Zeiten sind
illustrative Startwerte, keine Benchmarkdaten. Die Standards sind nicht automatisch die
Requests/Limits im Repo-Overlay.

## Gemma 4

Die Profile nutzen die offiziell beschriebenen Gesamtgroessen **31B dense** und **26B MoE**. Nicht
aktive MoE-Parameter als gesamte Gewichtsgroesse zaehlen. Die E2B/E4B-Varianten werden bewusst nicht
aus ihren effektiven Namen in vollstaendige RAM-Anforderungen umgerechnet.
Architektur-/Modalitaetskosten, zusaetzliche Encoder/Draft-Modelle sind separat einzurechnen.
[Offizielle Modelluebersicht](https://ai.google.dev/gemma/docs/core). Historischer Exportpfad:
`https://ai.google.dev/gemma/docs/core.md` (Abruf ohne Antwort); die HTML-Seite ist belegt, ihre
Erreichbarkeit bleibt Teil der Linkpruefung.

## Diskreter Skalierungsversuch

Zehn Minuten, Zeitschritt 10s, konstante Anfragerate; Queue ist ein kontinuierliches Fluidmodell,
deshalb sind Bruchteile moeglich. Serving-Zeit bleibt konstant, keine realistische
CPU-Konkurrenz-/Prefill-Kurve. Start mit maximal einem warmen Pod. Alle 30s wird ein einfacher
Queue-/Slotregler ausgewertet. Neue Pods sind erst nach Kaltstart bereit; jeweils ein Node wird nach
Bereitstellungszeit hinzugefuegt. Kein Downscaling und keine N+1-Ausfallreserve. Null Sekunden
Kaltstart werden auf einen Zeitschritt gerundet.

**Nicht die echte Kubernetes-HPA-Formel.** Der Slot-Zielwert ist kein CPU-HPA- Prozentwert und keine
konfigurierte Metrik im Cluster. Ohne Metrics-Adapter, HPA/KEDA und echten Node-Provisioner bleibt
das ein Was-waere-wenn-Modell. Eine einzelne VPS-Instanz wird durch Pending-Pods nicht automatisch
groesser. Ein zu grosser Pod passt auch auf zehn gleich kleine Nodes nicht. Lokale RWO- Volumes
koennen zwischen Nodes nicht frei migrieren; zusaetzliche Modellkopien und langsame Downloads machen
Kaltstarts laenger als die Eingabe.

## Tests

`tests/resource_planner.test.cjs` testet die reine Mathematik ohne Browser oder Netzwerk.
Browser-Smoke-Tests muessen zusaetzlich Eingaben, Fehlermeldungen, Profilwechsel, Reset und
Mobilansicht pruefen. Keine echte Inferenzabnahme.
