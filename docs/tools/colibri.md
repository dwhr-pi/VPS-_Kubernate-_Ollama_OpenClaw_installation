# Colibri: grosse Modelle auf MiniPC und RTX 5080?

**Zweck:** Colibri versucht, grosse Sprachmodelle trotz begrenztem Arbeitsspeicher lokal nutzbar zu
machen: Bei Mixture-of-Experts-Modellen (MoE) werden benoetigte Expert-Gewichte von der SSD
nachgeladen. Das ist ein Speicher-/I/O-Verfahren, kein zusaetzlicher RAM und keine Garantie fuer
schnelle oder gute Antworten.

**GitHub:** [JustVugg/colibri](https://github.com/JustVugg/colibri). **Setupstatus:** experimental,
optional, `github-source-only`. Kein Docker. Gepruefter Quellstand am 20.10.2026:
[`e0db083cdc9e563e0766cc6fc661ef23c32298e0`](https://github.com/JustVugg/colibri/tree/e0db083cdc9e563e0766cc6fc661ef23c32298e0).
Die Registrierung bedeutet **Quellen vorbereitet**, nicht Runtime/Modelle installiert. Lizenz des
Codes:
[Apache-2.0](https://github.com/JustVugg/colibri/blob/e0db083cdc9e563e0766cc6fc661ef23c32298e0/LICENSE).
Modellgewichte und weitere Komponenten haben eigene Bedingungen.

## 1. Was an den bisherigen Aussagen stimmt

Colibris C-Engine kann MoE-Experts vom Datentraeger streamen; eine GPU ist optional. Das Projekt
beschreibt auch GPU-Backends und eine lokale API. Das ist nicht gleichbedeutend mit einer pauschalen
1-/2-Bit-Komprimierung. Siehe
[Funktionsprinzip und Schnellstart](https://github.com/JustVugg/colibri/blob/e0db083cdc9e563e0766cc6fc661ef23c32298e0/README.md).

Davon getrennt muessen wir beurteilen:

| Aussage                                      | Einordnung fuer dein Setup                                                                                                              |
| -------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| Colibri senkt grundsaetzlich die Intelligenz | Nicht belegt. Quantisierung, Modell, Routing-Einstellungen und Umsetzung entscheiden; Streaming allein ist keine extreme Quantisierung. |
| Eine PCIe-4.0-/5.0-NVMe ist zwingend         | Keine allgemeine Voraussetzung. Schnellere tatsaechliche I/O hilft, macht aber eine ungeeignete CPU oder zu wenig RAM nicht wett.       |
| Doppelte SSD-GB/s ergeben doppelte Tokens/s  | Keine belastbare Formel: Cache-Treffer, Zugriffslatenz, aktive Gewichte, CPU und Datentransfer spielen mit.                             |
| 70B laeuft auf 8 GB immer gut                | Laden ist nicht gleich interaktiv nutzbar. Residenter Anteil, Kontext, Cache und Betriebssystem brauchen weiterhin RAM.                 |
| Q4/Q8 bedeutet volle Praezision              | Beides ist quantisiert. Auch bei 14B passt Q8 inklusive KV-Cache nicht garantiert in 16 GB VRAM.                                        |
| Jeder grosse Modellname ist kompatibel       | Engine, konkretes Format und Modellrevision muessen zusammenpassen. Keine beliebigen Ollama-/GGUF-Dateien voraussetzen.                 |

Die pauschalen Modell-/Groessenangaben aus dem Beispiel sind deshalb keine Installationsauswahl.
Verwende den Modellkatalog des gepinnten Checkouts und pruefe pro Modell Lizenz, Artefaktgroesse,
erforderliches Format und RAM-Bedarf. Ein Modellname wie "Llama 3.3 8B" ist hier keine gepruefte
Empfehlung.

## 2. Empfehlung fuer RTX 5080 und Letsung

| Zielhost               | Empfehlung                                                                                              | CPU / RAM                                                               | VRAM                                                   | Speicherplatz                                      |
| ---------------------- | ------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------ | -------------------------------------------------- |
| RTX 5080 Workstation   | Interessantes Experiment fuer Modelle oberhalb des residenten Budgets; nicht grundsaetzlich unnuetzlich | CPU und freies System-RAM separat beruecksichtigen                      | Deine 16 GB sind kein vollstaendig freies Modellbudget | Modell + Cache + Build + Reserve kalkulieren       |
| Letsung MiniPC         | Bedingt sinnvoll fuer Experimente, keine Kauf-/Geschwindigkeitszusage                                   | Exaktes CPU-Modell, Architektur, Instruktionen, RAM und Kuehlung fehlen | iGPU teilt meist System-RAM; nicht doppelt zaehlen     | SSD-Typ, reale I/O und freier Platz noch unbekannt |
| RPi5                   | Nur nach Architektur-/Build-/Modellpruefung experimentell                                               | ARM ist kein x86; wenig freies RAM beachten                             | Kein CUDA voraussetzen                                 | SD-Karte nicht mit NVMe gleichsetzen               |
| Oracle VPS / Dual Xeon | Nur auf erlaubter eigener Ressource testen                                                              | vCPU-/RAM-/Provider-Limits bzw. NUMA beachten                           | Nicht automatisch vorhanden                            | Disk-/I/O-/Traffic-Limits pruefen                  |
| Kubernetes Cluster     | Kein Deployment Teil dieses Integrationsschritts                                                        | Ein Pod erhaelt nicht automatisch den RAM aller Nodes                   | GPU-Zuteilung waere separat                            | Keine automatischen PVC-/Modell-Downloads          |

Fuer den RTX-Host zuerst ein kleineres, ausreichend quantisiertes Modell im bestehenden
Ollama/llama.cpp messen, dann Colibri auf derselben Aufgabe bewerten. Fuer Letsung zuerst CPU,
freies RAM und SSD spezifizieren. Ein grosser Modellname allein rechtfertigt weder stundenlange
Wartezeit noch eine volle Systemplatte.

## 3. Was der Setup-Installer wirklich macht

Voraussetzungen fuer die reine Quellvorbereitung: vorhandenes Git und Python 3, Netzwerkzugriff zu
GitHub. Er prueft eine 1-GiB-Disk-Reserve und die gemeinsamen Basis-Ressourcengrenzen; **dies ist
kein Modell-Preflight**. Es werden keine Systempakete, Compiler, CUDA-Treiber oder Python-Pakete
installiert.

Manuell aus dem Setup-Repository ausfuehren, wenn gewuenscht:

```bash
bash scripts/tools/colibri_install.sh --dry-run
bash scripts/tools/colibri_install.sh
bash scripts/tools/colibri_doctor.sh
bash scripts/tools/colibri_status.sh
```

Ziel: `${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/colibri/source`.
`source-ready.json` enthaelt Pin, `scope=github-source` und `runtime_ready=false`. Status/Doctor
validieren den Quellcheckout und Marker, nicht die Inferenz. Update verwendet denselben Pin; kein
unbeaufsichtigtes `main`-Upgrade. Fremde/lokal veraenderte Quellen werden nicht zurueckgesetzt.
Jeder veraendernde Versuch bekommt ein eigenes Log und eine Operationssperre. Fehlgeschlagene neue
Download-Stagingverzeichnisse werden entfernt; ein vorhandener Quellbestand wird nicht geloescht.

```bash
bash scripts/tools/colibri_update.sh --dry-run
bash scripts/tools/colibri_uninstall.sh --dry-run
bash scripts/tools/colibri_uninstall.sh
```

Deinstallation deaktiviert **nur den Setup-Marker**. Quellen, Modelle, manuell gebaute Programme,
Konfiguration und Logs bleiben erhalten. Das verhindert, dass gemeinsam verwendete Daten
versehentlich verschwinden.

## 4. Build und Modellbetrieb bewusst trennen

Vor manuellen Laufzeitschritten den gepinnten Code und seine Abhaengigkeiten pruefen. Das
[Python-Paket](https://github.com/JustVugg/colibri/blob/e0db083cdc9e563e0766cc6fc661ef23c32298e0/pyproject.toml)
fordert Python >=3.10. Die
[Buildregeln](https://github.com/JustVugg/colibri/blob/e0db083cdc9e563e0766cc6fc661ef23c32298e0/c/Makefile)
unterscheiden Plattform und Backend; native Windows-Builds verwenden einen anderen Werkzeugpfad als
Linux/macOS. Ein Linux-CUDA-Build ist keine Garantie fuer deine konkrete
RTX-/Treiber-/Toolkit-Kombination.

**Achtung:** `start-here.sh`, `START-HERE.bat` und `coli setup` sind keine reine Quellinstallation.
Sie koennen Build/Binary-Bezug, Modell-Download und Serverstart verbinden. Der Setup-Installer
fuehrt sie **nicht** aus. Kein `curl | bash`, kein Docker und keine automatische MCP-Registrierung.

Nach eigener Freigabe und bereits vorhandener C-Toolchain ist unter Linux/macOS folgendes ein
separater CPU-Build, kein Modell-Download:

```bash
SOURCE="${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/tools/colibri/source"
make -C "$SOURCE/c" -j 1 colibri CUDA=0 CUDA_DLL=0 HIP=0 HIP_DLL=0 VK=0 METAL=0 XDNA=0
```

Dieser optionale Build wird hier nicht ausgefuehrt oder als getestet behauptet. Buildartefakte
koennen den Checkout als veraendert markieren; der strikte Quell-Doctor verweigert dann bewusst die
Bestaetigung eines sauberen Checkouts. Fuer dauerhafte Experimente einen getrennten, von dir
kontrollierten Buildbestand verwenden; der Installer entfernt keine Buildartefakte, um das zu
"reparieren".

Der
[Controller liegt in `c/coli`](https://github.com/JustVugg/colibri/blob/e0db083cdc9e563e0766cc6fc661ef23c32298e0/c/coli).
Nach manueller Vorbereitung lautet ein Quellbaum-Aufruf beispielsweise
`python3 "$SOURCE/c/coli" info`, nicht pauschal `python3 coli info` im Repo-Root. Auch dieser Aufruf
startet Upstream-Code und ist kein Bestandteil unseres Doctors.

## 5. Sicherer Versuchsplan und Integration

1. CPU-Modell, freies RAM, freie SSD-/Host-Kapazitaet und Kuehlung notieren.
2. Kleinstes fuer die gewaehlte Engine tatsaechlich geeignetes Modell auswaehlen; Artefaktgroesse +
   temporaere Daten + Cache + persoenliche Reserve einplanen.
3. Erst danach einen einzelnen Download/Build freigeben. Maximal ein schwerer Job gleichzeitig;
   keine Hintergrundinstallation weiterer Medienmodelle.
4. Kurzen identischen Prompt, Kontextlaenge und Tokenlimit verwenden; Kalt-/Warmlauf, RAM, I/O,
   Antwortqualitaet und Abbruchkriterium notieren.
5. Nur bei brauchbarem Ergebnis dauerhaft integrieren. Keine unbelegten Tokens/s oder
   Q4/Q8-Voll-VRAM-Versprechen in die Ergebnisvorlage eintragen.

Bei WSL muss auch die freie Kapazitaet des Laufwerks mit der VHDX passen. Viel freier Platz
innerhalb Linux hebt einen vollen Windows-Host nicht auf. Ein Modellpfad im Linux-Dateisystem kann
I/O guenstiger machen als `/mnt/c`, umgeht aber nicht die Kapazitaetsgrenze der Host-Platte. Keine
automatischen WSL-, Swap-, Treiber- oder Datentraegerverschiebungen durch diese Erweiterung.

Der Upstream-Schnellstart dokumentiert Loopback-Port **8000**, OpenAI-Basis
`http://127.0.0.1:8000/v1`. Vor manuellem Start auf Kollisionen pruefen, Bindings kontrollieren und
nicht oeffentlich freigeben. Der Quellinstaller oeffnet keinen Port. OpenAI-Kompatibilitaet ist kein
Nachweis fuer getestetes Tool-Calling, FreeLLMAPI-, OpenClaw- oder n8n-Routing. Solche Adapter
separat pruefen; keine Secrets oder vertraulichen Prompts in Tests/Logs verwenden.

Weiter: [Speicherarchitektur und Offloading](../memory/UNIFIED_MEMORY_AND_OFFLOADING.md),
[lokale KI-Benchmarks](local-ai-benchmarks.md), [Ergebnisvorlage](../benchmarks/RESULT_TEMPLATE.md).
