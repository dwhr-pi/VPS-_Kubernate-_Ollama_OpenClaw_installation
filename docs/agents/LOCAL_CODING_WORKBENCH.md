# Optionale lokale Coding-Agenten

Stand: 29.10.2026. [Belegte Ausgangsmatrix](CODING_AGENT_INVENTORY.md),
[native Source-Builds](NATIVE_CLI_BUILDS.md). Keine Anwendung, kein Modell, Docker, WSL oder
Provider-Login wurde fuer diese Integration gestartet/installiert. Offline-Fixtures sind keine
Produktions- oder Image-Kompatibilitaetsfreigabe.

## Architektur und Reifegrad

```text
Mensch -> eigener agents/NAME-Worktree -> ausdruecklicher Einmallauf
                                           |
                     Docker: non-root, network=none, kein Host-Socket
                      /workspace: ro oder nur Implementierung rw
                                           |
                   lokaler HTTP-Adapter -> Unix-Socket (nur Modell-API)
                                           |
                      begrenzter Host-Broker -> Ollama auf Loopback
```

Es gibt keinen neuen Scheduler oder dauerhaft laufenden Dienst. Vorhandene
Queue-/OpenClaw-Orchestrierung kann den vertrauenswuerdigen Wrapper aufrufen; die bisherigen Queues
selbst sind **keine Sandbox** und werden nicht umgebaut. Ungepruefte Modellantworten duerfen niemals
als Host-`job_cmd` eingereiht werden. Keine automatische PR-Uebernahme oder
Produktivveroeffentlichung.

| Stufe         | Bedeutung in diesem PR                                                               |
| ------------- | ------------------------------------------------------------------------------------ |
| dokumentiert  | Matrix, Voraussetzungen und Bedienung vorhanden                                      |
| konfiguriert  | Private Client-/Profilvorlage geschrieben; kein Modellaufruf                         |
| installierbar | Gepinnter Build-/Quellenvertrag vorhanden; Toolchain/Lockfile fehlen moeglicherweise |
| getestet      | Genau benannte Offline-Fixtures/MOCKs, nicht reale Agentenfunktion                   |
| produktiv     | Fuer keine der neuen Verbindungen behauptet                                          |

Qwen Code verwendet unveraendert seinen vorhandenen gepinnten Build. OpenCode, Aider und Codex CLI
erhalten getrennte optionale Source-Buildpfade. Der OpenHands-Eintrag bereitet SDK-Quellen vor,
**nicht** die OpenHands-Webanwendung oder bereits einen lauffaehigen Worker. Alte `/opt`-Scaffolds
bleiben erhalten. Die neuen Profile installieren nur Vorlagen und tragen `runtime_ready:false`. Das
ist keine Installation aller abhaengigen Tools.

## Voraussetzungen

Planung/Konfiguration: vorhandenes Python 3.10+ und Git, Linux/Windows/macOS toolweise nutzbar.
Source-Builds haben eigene Plattform-/Disk-Gates; das ersetzt keine RAM- oder Gesamt-Plattenquota
fuer den Buildprozess. Ausfuehrung derzeit ausschliesslich auf einem **nicht-root Linux-Worker** mit
vorhandenem, bewusst administriertem Docker-Daemon. Kein automatischer WSL-/SSH- Start.
Docker-Desktop-/macOS-/Rootless-/Usernamespace-Socketmapping ist nicht abgenommen und wird nicht als
automatisch kompatibel ausgegeben.

Der Operator braucht Zugriff auf den lokalen Docker-Daemon. Das ist bei rootful Docker ein starkes
Hostrecht; keine automatische Gruppenzuweisung. Der Container bekommt diesen Socket **nicht**. Fuer
feindlichen Multi-Tenant-Code eine dedizierte VM/MicroVM vorziehen: Container teilen weiterhin den
Hostkernel.

Ein geprueftes, bereits lokal vorhandenes Image muss Python 3 sowie genau die gewaehlte CLI bzw. das
OpenHands-SDK enthalten. `--image` verlangt einen echten Registry-Digest. Keine Tags, kein
Pull/Build im Workerstart, kein erfundener Standarddigest. Native installierte Host-CLIs werden
nicht heimlich in Images kopiert. Ollama muss das explizit gewaehlte Modell lokal mit Digest
fuehren; kein Pull, kein Cloudmodell. Modell-/Toolcalling-/Responses-Kompatibilitaet einzeln
abnehmen.

## 1. Agent unabhaengig konfigurieren

```bash
# Plan, keine Verzeichnisse, Agenten oder API-Abfragen:
python3 -I -B scripts/agents/workbench.py configure \
  --agent opencode --model qwen2.5-coder:7b

# Bewusst nur private Client-Konfiguration schreiben:
python3 -I -B scripts/agents/workbench.py configure \
  --agent qwen_code --model qwen2.5-coder:7b --apply
```

Der Modellname ist ein Beispiel, keine Behauptung eines installierten Modells. Auch `aider`,
`codex_cli` oder `openhands` sind einzeln waehlbar. Endpoint-Standard ist `http://127.0.0.1:11434`;
nur direkte Loopback-IP, keine Credentials, Proxy-URLs, Query oder Redirects. Bestehende abweichende
Dateien werden nicht ueberschrieben. Externe Daten liegen unter
`OPENCLAW_USER_DATA_DIR/coding_workbench/AGENT`, sonst im privaten Standardworkspace.

Die Dateien sind Vorlagen fuer bewusst gestartete native Clients, kein neuer automatischer Launcher.
OpenCode kann `OPENCODE_CONFIG` auf `client.json` setzen; Aider liest dieselbe JSON-Datei als YAML
mit `--config`. Qwen benoetigt sein zum Pin passendes `settings.json` und OpenAI-kompatible
Environment-Werte. Codex liest `config.toml` bei explizit gesetztem `CODEX_HOME`. Nichts aendert die
vorhandenen globalen Agentenkonfigurationen. Ein nativer Direktstart ausserhalb des Workers ist
**nicht** durch dessen Containergrenzen geschuetzt.

## 2. Separaten Worktree vorbereiten

```bash
python3 -I -B scripts/agents/workbench.py worktree \
  --repo "$SOURCE_REPO" --destination "$NEW_WORKTREE" --branch agents/fix-001
```

`SOURCE_REPO` und `NEW_WORKTREE` sind eigene kanonische absolute Pfade, keine vorbelegten
Produktionspfade. Quelle muss sauber, Ziel neu und ausserhalb der Quelle sein. Ohne `--confirm` nur
Lesepruefung/Plan. Erst nach Review denselben Aufruf mit `--confirm` ausfuehren. Kein Fetch, Reset,
Stash oder Merge. Pro paralleler Aufgabe einen eigenen Worktree/Branch verwenden.

## 3. Rolle und Einmallauf

```bash
python3 -I -B scripts/agents/workbench.py worker \
  --agent qwen_code --role review --model "$LOCAL_MODEL" \
  --worktree "$AGENT_WORKTREE" --image "$REVIEWED_IMAGE" \
  --prompt-file "$PRIVATE_PROMPT_FILE"
```

Dies ist ein Offline-Plan: keine Git-/Docker-/Ollama-Probes. Das Modell, der Image-Digest und die
Pfade muessen vom Operator gesetzt werden. Erst nach Pruefung zusaetzlich **`--run --confirm`**
angeben. Promptdatei: UTF-8, maximal 64KiB. Bei echtem Run sind nur saubere Linked-Worktrees auf
`agents/NAME` erlaubt; ein regulaerer Main-Checkout wird abgewiesen. Erkennbare Credential-Dateien
und verlinkte Pfade blockieren den Start. Das ist kein vollstaendiger DLP-Scanner: den ausgewählten
Quellbaum vorher persoenlich auf Geheimnisse pruefen.

| Rolle       | Technisch erlaubte Projektmutation                                                          |
| ----------- | ------------------------------------------------------------------------------------------- |
| `plan`      | Read-only Projektmount                                                                      |
| `review`    | Read-only Projektmount                                                                      |
| `implement` | Schreibzugriff ausschliesslich auf diesen Worktree                                          |
| `test`      | Read-only Projekt; feste `python3 -B -m unittest discover -s tests -v`-Auswahl im Container |

Keine frei uebergebenen Host-Testkommandos. Fuer andere Testsysteme spaeter eine reviewte feste
Auswahl ergaenzen, keinen Shell-String vom Modell. Die Container- Grenze gilt unabhaengig von den
CLI-internen Permission-Settings; JSON-Rollen allein koennen keinen Schreibzugriff freischalten.

Fest erzwungen: Network none, Read-only Root, alle Capabilities entfernt, NoNewPrivileges, non-root
UID/GID, 2 CPU, 2GiB RAM ohne zusaetzlichen Swap, 128 PIDs, 900s Agentlaufzeit, begrenztes
noexec-Tmpfs und 8MiB pro regulaerer Datei. Die `.git`-Kontrolldatei wird separat read-only
uebermountet; gemeinsame Host- Git-Metadaten werden nicht eingehängt. Deshalb sind einige
Git-Funktionen der Agenten im Container eingeschraenkt. Commit/Push/PR erfolgen anschliessend vom
Menschen ausserhalb des Containers. Das Git-Kontrolldatei-Hash wird nachgeprueft.

Der lokale Broker laeuft nur fuer die Sitzung: vier Handler gleichzeitig, hoechstens 64
Verbindungen, 16 autorisierte Modell-/Inventarrequests, 1MiB Request und 8MiB Antwort. Nur fest
erlaubte Modell-API-Pfade; kein Pull/Delete, kein Modellwechsel, keine Remote-Modelle, kein
Credential-Header-Forwarding. Ausgabe maximal 2048 Tokens pro Generierung, keine Context-Erweiterung
ueber 4096 in uebergebenen Optionen. Requests ohne diese Kompatibilitaet scheitern; keine
automatische Lockerung. Bild-/Datei-URL-Inputs sind ausgeschlossen.

SSE-Antworten werden begrenzt gepuffert: **kein echtes Streaming-/TTFT-Versprechen**. Ollama selbst
braucht weiter eigene RAM-/VRAM-/Contextlimits; Containerlimits begrenzen nicht den externen
Inferenzprozess. Ein beschaedigter/boesartiger lokaler Modellserver liegt ausserhalb dieses Brokers
als Vertrauensanker.

Agentenausgaben gehen in eine einzelne begrenzte Datei, nicht in Dockerlogs. Nach dem Lauf liegt das
**unvertrauenswuerdige** Transkript mit 0600 unter `coding_workbench/reports/`; niemals automatisch
ausfuehren oder veroeffentlichen. Bei Timeout wird nur der anhand eines zufaelligen Run-Labels
nachgewiesene eigene Container entfernt. Projektdateien werden nie automatisch zurueckgesetzt.
Crash-/SIGKILL-Locks werden nicht pauschal geloescht: eigenen Container und Lock erst pruefen.
Scheitern Containerpruefung oder Entfernung, bleibt zusaetzlich
`coding_workbench/.cleanup-review-required` erhalten und blockiert weitere Runs. Die JSON-Datei
nennt Run-ID und Worktree: erst den Container mit genau dieser ID und passendem `llmops.run`-Label
pruefen und sein Ende bestaetigen; dann den Sperrmarker bewusst archivieren. Keine automatische
Sperrloeschung bei Daemonfehlern. Sonderdateien (auch Unix-Sockets) und Hardlinks im Projekt werden
abgewiesen. Eine harte Gesamt-Diskquota fuer einen beschreibbaren Worktree ist nicht enthalten;
eigene Quota/VM und Diskalarm bleiben vor untrusted Vollautonomie Pflicht.

## OpenHands-Workerimage

[Dockerfile](../../containers/openhands-worker/Dockerfile): nur das fest gepinnte OpenHands-SDK und
Tools aus dem offiziellen GitHub-Repository, `uv sync --frozen`, kein `make build`, Git-Hook,
Host-Socket, Webserver oder Modellstart. Vorhandenes geprueftes Base-Image mit Python 3.13, uv und
git erforderlich:

```bash
python3 -I -B scripts/agents/workbench.py image-plan --base-image "$VERIFIED_BASE_DIGEST"
```

Ausgabe ist nur der zu reviewende Build-Aufruf; kein Build durch diesen Befehl. Nach bewusstem Build
separat Image/CVEs/Lizenz/UID/Socketrechte und CLI-/SDK- Funktion testen und einen wirklichen
Registry-Digest bestimmen. Keine Authentifizierungsdateien oder Projektquellen im Buildkontext. Der
Controller mountet seinen Runner beim Einmallauf read-only hinein. Andere Agenten brauchen je ein
entsprechend vorbereitetes Image; kein Sammelimage wird automatisch gebaut.

## Authentifizierung, Lizenzen und bestehende Agenten

OpenCode MIT, Qwen Code Apache-2.0, Aider Apache-2.0, Codex CLI Apache-2.0 und OpenHands-SDK MIT am
jeweils dokumentierten Quellpin; Abhaengigkeiten/Modelle separat. Ein CLI-Lizenzrecht beinhaltet
keine Gratis-API oder Modelllizenz. Codex kann lokale Provider nutzen; dieser Adapter nutzt
ausschliesslich die lokale Responses-kompatible Route. Externe OpenAI-Nutzung verlangt gesonderte
Anmeldung/API-Berechtigung und Budget-/Datenschutzfreigabe. Keine Zugangsdaten werden aus dem
Host-Codex-Verzeichnis uebernommen und kein Login gestartet.

Gemini CLI bleibt der vorhandene source-only Eintrag. Claude Code wird nicht als vollstaendige
Open-Source-CLI ausgegeben; dessen bestehendes Referenzmaterial und proprietaere Lizenzbedingungen
bleiben getrennt. Diese beiden Eintraege werden nicht heimlich durch andere Clients oder Plugins
ersetzt.

## Deaktivierung, Abnahme und Rollback

Profile deinstallieren entfernt nur deren eigene Registrierung, keine CLI, Quellen, Modelle oder
Projekte. Native CLI-Uninstaller deaktivieren nur ihre nachgewiesenen eigenen Marker; alte
`/opt`-/venv-Installationen bleiben erhalten. Client-Konfigurationen und Transkripte bewusst privat
aufbewahren oder nach Review einzeln entfernen, nicht rekursiv den gesamten Workspace loeschen.

CI prueft Matrix/Registries, Konfigurationen, Brokergrenzen, Docker-Argumente,
Timeout-/Ownership-Verhalten und gemockte Lifecycle-Pfade. Auf Linux kommen synthetische
Loopback-/Unix-Socket-Proben hinzu, keine echte Inferenz. Nicht abgenommen: alle Source-Builds,
konkrete OCI-Images/Daemons, reale Modelle, OAuth/Cloud, ARM/macOS/Windows-Ausfuehrung, hostile
Kernel-Exploits und gesamte Queue-/OpenClaw-End-to-End-Pipeline. Ein erfolgreicher Mock ist kein
Runtime-Nachweis.

Rollback: Featurebranch nicht mergen oder Commit gezielt ruecknehmen. Keine Nutzdatenmigration. Kein
automatischer Merge/Deploy, keine Background-Aktivierung.

Bewusste Verhaltensaenderung: OpenCode/Aider/OpenHands werden nicht mehr allein an alten
`/opt`-Verzeichnissen oder globalen PATH-Befehlen erkannt. Ihre neuen Menuepruefungen verlangen
eigene Integritaetsnachweise. Vorhandene Altinstallationen bleiben unberuehrt; der
OpenHands-Menuepunkt bereitet jetzt ausdruecklich SDK- Quellen vor statt eine fertige Webanwendung
zu suggerieren. Keine automatische Migration.

## Lokales Pruefprotokoll vom 29.10.2026

Auf dem Windows-Client mit privatem Fixture-Workspace und nativem Git-Bash, ohne WSL, Downloads,
echte Builds, Container, Provideranmeldung oder Inferenz:

- **162 ausgewaehlte Regressionstests: 160 bestanden, 2 POSIX-bedingt uebersprungen.** Umfasst
  Workbench, Registry/Profile, native Lifecycle-Vertraege, OpenHands- Abschlussstatus, bestehende
  Agentenprofile, Qwen, Lizenz-/Agentendokumentation, Tool-Abdeckung, Menueintegration und
  A-Z-Reihenfolge. Nicht die gesamte Testsuite.
- 37 betroffene Shell-Dateien mit `bash -n`, 10 Python-Dateien per AST geprueft; `git diff --check`
  ohne Befund.
- Repo-Offline-Audit: 400 Tools, 250 Profile, 45 Port-Eintraege; keine Fehler. 804
  Katalog-/Dokumentationshinweise bleiben separat bestehen, darunter zwei bestehende Links in
  `GITOPS_SMALL_VPS.md` und `SECURE_CORE_REFACTOR.md`.
- Die beiden lokalen Auslassungen betreffen POSIX-Rechte/Symlinks und eine synthetische
  Unix-Socket-/Loopback-Probe. Die neue Linux-/macOS-/Windows-CI ist vorbereitet; ihr Lauf ist eine
  nachgelagerte GitHub-Pruefung, kein hier vorweggenommener Erfolg.

Die Kernpruefungen sind in [coding-agents.yml](../../.github/workflows/coding-agents.yml)
reproduzierbar hinterlegt. Vor Produktionsfreigabe bleiben echte gepinnte Builds, Hash-Lock-Abnahme
fuer Aider, gepruefte Worker-Images, Modell-/Toolcalling-Tests, Workspace-Gesamtquota und
Linux-Isolations-/Abbruchtests erforderlich.

## Offizielle Quellen

- [OpenCode Provider](https://opencode.ai/docs/providers/)
- [Qwen Auth und kompatible Endpoints](https://qwenlm.github.io/qwen-code-docs/en/users/configuration/auth/)
- [Aider und Ollama](https://aider.chat/docs/llms/ollama.html)
- [Codex CLI Referenz](https://developers.openai.com/codex/cli/reference/)
- [Codex Authentifizierung](https://developers.openai.com/codex/auth/)
- [OpenHands-SDK am Pin](https://github.com/OpenHands/software-agent-sdk/tree/47bbc5e8392c4c75b7f77a1da38bed4a9f53d6a5)
