# Automaton von Conway Research

**Status: optionaler GitHub-Source-Build, experimental / hohes Risiko, ohne Docker.**

Zum Unterschied zwischen einem allgemeinen Automaten-/Workflow-Prinzip und
diesem konkreten Conway-Projekt sowie zur begrenzten Repo-Entwicklung siehe
den [Agentic-Coding-Leitfaden](../AGENTIC_CODING_GUIDE.md).
Im Tool-Menue kann jetzt der gepinnte Quellcode gebaut werden. Build und
Agentenbetrieb sind strikt getrennt: kein automatischer Start, Wallet-Zugriff,
Provisionieren, Autostart oder Docker. Der bisherige Offline-Vorschlagspruefer
bleibt unabhaengig davon erhalten und startet weder Automaton noch Zenbot/Ollama.

## Herkunft und gepruefter Stand

- [Conway-Research/automaton](https://github.com/Conway-Research/automaton), MIT.
- [Conway](https://conway.tech) ist das zugehoerige Ecosystem, keine Garantie fuer kostenlose Infrastruktur.
- Quellcode/Buildmanifest und GitHub-HEAD am 16.10.2026 erneut geprueft: Commit `d8f816881fd24b6f5e3d616e59edec387a447667`.
- Paketversion dort `0.2.1`; ein Paketversionsfeld ist kein Beleg fuer ein gleichnamiges Release-Tag.

Upstream beschreibt eine autonome Runtime mit Wallet-Initialisierung,
SIWE-Authentifizierung, Cloud-Sandbox, Agentenloop, Skills, Selbstmodifikation
und Replikation. Das ist **kein fertig abgesicherter Trading-Bot** und kein
Nachweis wirtschaftlicher Rentabilitaet. Die README weist zudem auf intern
fortgesetzte Entwicklung hin. Siehe
[Upstream-README](https://github.com/Conway-Research/automaton/blob/d8f816881fd24b6f5e3d616e59edec387a447667/README.md).

## Wichtige Korrekturen zum vorgeschlagenen Tutorial

| Aussage | Belastbare Einordnung |
|---|---|
| Wallet sei automatisch verschluesselt | Der gepruefte Wallet-Code schreibt private Schluesseldaten als JSON; `0600` sind Zugriffsrechte, keine Verschluesselung. |
| Seed Phrase werde immer erzeugt | Der EVM-Pfad erzeugt einen Private Key; eine Mnemonic wird dort nicht garantiert. |
| Bei exakt 0 Dollar ende alles | README und Code unterscheiden sich: im geprueften Code ist 0 Credits `critical`, negativ `dead`. Credits und On-Chain-Guthaben sind verschiedene Groessen. |
| Lokales Ollama beseitige alle Kosten | Es spart moeglicherweise externe Inferenzkosten, nicht Strom, Hardware, Cloud, Domains oder Transaktionsgebuehren. Survival-/Provisionierungslogik verschwindet dadurch nicht. |
| 10 bis 20 Dollar seien ausreichend | Keine belastbare Kapital- oder Laufzeitgarantie; hier wird keine Einzahlung empfohlen. |
| Agent koenne Oracle-Free-Tier-Limits umgehen | Keine Umgehung von Kapazitaeten oder Providerregeln. Bezahlte API-Ressourcen brauchen gesonderte Freigabe. |
| Zenbot-Wallet einfach uebergeben | Bestehende produktive Wallet/Seed niemals an diesen Agenten weiterreichen. |
| SOUL.md sei sicher oeffentlich sicherbar | Auch Gedaechtnis, Logs, Prompts und Konfiguration koennen vertrauliche Inhalte enthalten. Erst pruefen und bereinigen. |

Belege: [Wallet-Speicherung](https://github.com/Conway-Research/automaton/blob/d8f816881fd24b6f5e3d616e59edec387a447667/src/identity/wallet.ts),
[Survival-Schwellen](https://github.com/Conway-Research/automaton/blob/d8f816881fd24b6f5e3d616e59edec387a447667/src/types.ts),
[Credit-Auswertung](https://github.com/Conway-Research/automaton/blob/d8f816881fd24b6f5e3d616e59edec387a447667/src/conway/credits.ts).
Es wurde keine unabhaengige Erfolgsquote ermittelt; Zahlen wie 10/10 oder 2/10
werden nicht als Testergebnis uebernommen.

## Schritt 1: Voraussetzungen pruefen

Als normaler Benutzer auf Linux/WSL, nicht mit `sudo`, im Setup-Verzeichnis:

```bash
node --version
pnpm --version
git --version
command -v flock
bash scripts/tools/automaton_install.sh --dry-run
```

Dieser Installer verlangt bewusst Node **22.x** und exakt **pnpm 10.28.1**.
Upstream verlangt mindestens Node 20; 22.x ist unser eingegrenzter Buildpfad,
keine Zusage fuer alle neueren Versionen. Fehlende Runtimes werden nicht
automatisch global ersetzt. Fuer native SQLite-/esbuild-Abhaengigkeiten koennen
Python 3, C/C++-Compiler und make notwendig sein. Bei fehlenden Prebuilds
zuerst diese System-/Build-Werkzeuge einrichten; kein Docker erforderlich.

Planungsreserve: **4 GiB RAM und 10 GiB freier Datentraegerplatz**, unter WSL
zusaetzlich **10 GiB auf Windows C:**. Das sind konservative Setup-Grenzen,
keine gemessenen Upstream-Mindestwerte. Der RAM-Check misst Gesamt-RAM, nicht
die garantierte freie Reserve; andere grosse Jobs vorher beenden.
Lokale Modelle brauchen zusaetzliche Ressourcen und werden nicht geladen.

## Schritt 2: Aus GitHub installieren

```bash
bash scripts/tools/automaton_install.sh
bash scripts/tools/automaton_status.sh
bash scripts/tools/automaton_doctor.sh
```

Nur nach deiner ausdruecklichen Menue-/CLI-Auswahl: gepinnten Commit von
GitHub holen, `pnpm install --frozen-lockfile`, `pnpm run build`, Syntax und
SQLite-In-Memory-Smoke-Test pruefen. Keine Ausfuehrung von `dist/index.js`,
auch nicht mit `--status`: Upstream-Status kann eine Datenbank oeffnen.
Paketabhaengigkeiten/native Prebuilds kommen zusaetzlich von den im Lockfile
referenzierten Registries/Hosts; GitHub-Quelle bedeutet nicht ausschliesslich
GitHub-Netzwerkverkehr. Lifecycle-Skripte fuer native Pakete laufen beim Build.
Nur auf einem vertrauenswuerdigen Laborhost ohne produktive Schluessel bauen;
der Build selbst ist keine OS-Sandbox und kein vollstaendiger Supply-Chain-Audit.

Privates Ziel (alternativ ueber `OPENCLAW_USER_DATA_DIR`):

```text
~/.openclaw_ultimate_user_data/tools/automaton/source/
~/.openclaw_ultimate_user_data/tools/automaton/source-built
~/.openclaw_ultimate_user_data/install_logs/*_automaton_source_*.log
```

Der Marker wird erst nach erfolgreichem Build/Smoke-Test geschrieben und vor
erneutem Build entfernt. Wiederholte Installation prueft einen vorhandenen
Build statt ihn erneut zu bauen. Quelle, Commit, lokale Aenderungen und ein
Lock werden geprueft. Ein kaputter Checkout wird nicht blind geloescht;
erst sichern/pruefen. Keine globalen CLI-Symlinks, Ports oder Dienste.

**Die Installation macht Automaton nicht zu einem sicher eingeschraenkten
Agenten.** `--run`, `--init`, `--setup` und `--provision` bleiben im Setup
gesperrt. Auch ohne Docker koennen solche separat gestarteten Upstream-Befehle
Wallets/Signaturen, Cloudzugriffe und Ausgaben ausloesen. Diese Anleitung gibt
dafuer keine Startfreigabe und importiert keine bestehende Zenbot-Wallet.

## Schritt 3: Reparatur oder Deaktivierung

```bash
# Bewusst denselben gepinnten Stand neu bauen, kein ungepruefter main-Pull:
bash scripts/tools/automaton_update.sh
bash scripts/tools/automaton_install.sh --repair

# Code datenerhaltend nach source.disabled.<Zeit>.<PID> verschieben:
bash scripts/tools/automaton_uninstall.sh
```

Update ist derzeit ein Rebuild des geprueften Commits, kein Versionssprung.
Abweichende/lokal geaenderte Quellen werden nicht ueberschrieben. Deaktivierung
loescht nur den Buildmarker, erhaelt den Code und beendet keine Prozesse.
Wallets, `~/.automaton`, ENV-Dateien und bestehende Installationen ausserhalb
dieses privaten Ziels werden nicht angefasst. Ein manuell separat gestarteter
Agent muss vor Wartung vom Betreiber gestoppt werden.

## Optional: nur Offline-Review

Im Repository-Root, mit vorhandenem Python 3:

```bash
python3 tools/automaton/review.py plan
python3 tools/automaton/review.py doctor
python3 tools/automaton/review.py review examples/automaton/review-proposal.json
```

Nur fuer diesen separaten Python-Pruefer: Status `planned`, `installed: false` bzw. Entscheidung
`manual_review_required`, niemals eine Ausfuehrungsfreigabe.
Diese Werte beurteilen nur Integrationsbeispiele, niemals den Source-Build.
`review.py install` bleibt gesperrt; die echte Quellcodeinstallation erfolgt
jetzt durch das Bash-Skript oben.

| Exit-Code | Bedeutung |
|---|---|
| 0 | Gewaehlte Pruefung/Build erfolgreich; kein Agent gestartet |
| 1 | Vorschlag ungueltig, zu weitreichend oder Datei nicht lesbar |
| 2 | Runtime-Aktion absichtlich gesperrt oder CLI falsch aufgerufen |

Der Offline-Pruefer liest nur die angegebene Vorschlagsdatei und eigene
Integrationsbeispiele. Er liest **nicht** `~/.automaton`, Wallets, ENV-Dateien
oder den ENV-Tresor. Keine Netzwerkabfrage, keine Signatur und keine Shell-Ausfuehrung.

## Ressourcen und Plattformen

| Einsatz | Planungswert / Status |
|---|---|
| Eigener Offline-Pruefer | Python 3, keine GPU/Node/Docker; kleine JSON-Dateien bis 64 KiB |
| Spaeteres Automaton-Labor | vorsichtige Reserve: 2 vCPU, 4 GiB RAM, 10 GiB Disk; nicht gemessen, keine Upstream-Mindestwerte |
| GitHub-Source-Build | Setup: Node 22.x, pnpm 10.28.1; native SQLite-Abhaengigkeit kann Build-Werkzeuge benoetigen |
| Lokale LLMs | RAM/VRAM und Modellplatz kommen separat hinzu; keine Modell-Downloads hier |
| WSL2 | spaeteres isoliertes Labor moeglich, aber kein Zugriff durch diesen Auftrag; Host-SSD als Engpass pruefen |
| Oracle VPS | nur separates Labor, keine Admin-/Cloud-Keys des Control Nodes bereitstellen |
| MiniPC/RPi/ARM | Offline-Pruefer geeignet; Runtime/native Dependencies ungetestet |
| GPU-Workstation/K3s | optionale spaetere Adapter, nicht implementiert |

Quelle fuer Build-/Paketangaben:
[package.json](https://github.com/Conway-Research/automaton/blob/d8f816881fd24b6f5e3d616e59edec387a447667/package.json).
Es wird kein Docker vorausgesetzt und kein Port geoeffnet; daher kein neuer
Eintrag mit einem erfundenen Server-Port in der Portregistry.

## Zenbot, Web3-Wallet und OpenClaw

Das vorhandene [Web3_Crypto_Agent-Profil](../Profile/Web3_Crypto_Agent.md)
bleibt bei Monitoring/Analyse/Simulation. Automaton wird **nicht** dessen
automatische Installationsabhaengigkeit.

Die genaue Zenbot-/Zentrade-Implementierung und deren API-Vertrag sind noch
nicht verifiziert. Ein Trading-Bot ist nicht automatisch eine EVM-Wallet oder
ein SIWE-Signer. Deshalb gibt es hier keine erfundenen Zenbot-REST-Endpunkte
und keine CLI fuer Live-Orders.

```mermaid
flowchart LR
  A[OpenClaw oder n8n] --> B[Strukturierter Vorschlag]
  B --> C[Offline-Review]
  C --> D[Manuelle Pruefung]
  D -. spaeterer Adapter .-> E[Isolierter Analysejob]
  E -. nur bereinigter Bericht .-> F[Zenbot / Betreiber]
  W[Produktive Wallet] --- X[Kein Zugriff durch Agent]
```

Erster sinnvoller Adapter: bereinigte Backtest-Ergebnisse oder lokal exportierte
oeffentliche Wallet-Bestaende analysieren. `wallet_balance_report` bedeutet im
Prototyp nur einen Vorschlagstyp, **keinen implementierten RPC-Aufruf**.
OpenClaw/n8n koennen den Offline-Pruefer als begrenzten Schritt aufrufen;
es gibt noch keinen nativen Automaton-Connector, MCP-Adapter oder Zahlungsdienst.

Vor einer kuenftigen Ausfuehrungsbruecke muessen OS-Sandbox, Netzwerk-Allowlist,
separater Benutzer, erlaubte feste Befehle und menschliche Freigaben technisch
erzwungen werden. Ein Prompt oder diese JSON-Pruefung ist dafuer kein Ersatz.
Keine generischen Shell-Kommandos aus einem LLM-Vorschlag ausfuehren.

## Ollama, OpenRouter und FreeLLMAPI

Upstream enthaelt `ollamaBaseUrl` in der Konfiguration sowie einen
OpenAI-basierten Inferenzclient. Das allein beweist keinen vollstaendig lokalen
Startpfad ohne Cloud, Provisionierung oder Wallet.
[Konfiguration](https://github.com/Conway-Research/automaton/blob/d8f816881fd24b6f5e3d616e59edec387a447667/src/config.ts),
[Inferenzclient](https://github.com/Conway-Research/automaton/blob/d8f816881fd24b6f5e3d616e59edec387a447667/src/inference/inference-client.ts).

Ollama-Anbindung, OpenRouter und [FreeLLMAPI](freellmapi.md) bleiben getrennt
zu testende Integrationsoptionen. Kein blindes Umbenennen der Conway-API-URL:
Cloud-/Provisionierungs- und Inferenzschnittstellen sind nicht austauschbar.
Keine API-Keys oder Provider-Fallbacks automatisch uebernehmen.

## Genesis Prompt fuer ein spaeteres, begrenztes Labor

```text
Du bist ein read-only Analyseassistent fuer ein isoliertes Testprojekt.
Erstelle Berichte aus freigegebenen, bereinigten lokalen Eingabedaten.
Keine Wallets lesen oder anlegen, keine Signaturen, Zahlungen oder Live-Orders.
Keine Cloud-Ressourcen anlegen, keine Replikation oder Selbstmodifikation.
Maximal 10 Schritte und 2 Fehlversuche; danach Bericht und Abbruch.
Bei fehlenden Berechtigungen stoppen, niemals Schutzmassnahmen umgehen.
Codeaenderungen nur als vorgeschlagenen Diff ausgeben, nicht selbst anwenden.
```

Dies ist eine Aufgabenbeschreibung, keine Sicherheitsbarriere.
Die [Policy-Vorlage](../../config/automaton.policy.example.json) ist ein Entwurf
unserer Integrationsschicht und **keine Upstream-Konfiguration**. Sie deaktiviert
keine Upstream-Tools, wenn jemand die originale Runtime separat startet.
Maximal ein Job, Timeout und Retry-Limits muessen im spaeteren Queue-/Sandbox-
Adapter umgesetzt werden. Keine endlosen lokalen Loops: auch diese kosten Ressourcen.

## Wallets, Backup, Datenschutz und Verantwortung

Keine produktiven Seeds/Keys aus Zenbot, Browser-Wallet oder Hardware-Wallet
importieren. Spaetere Versuche brauchen eine getrennte, begrenzte Laboridentitaet
und einen extern kontrollierten Signatur-/Freigabeprozess. SIWE-Nachrichten
ebenfalls pruefen: eine Anmeldung ist zwar keine normale Ueberweisung, aber
trotzdem eine wirksame Signatur. Testnet-Kompatibilitaet und Chain-ID muessen
vorher konkret nachgewiesen werden; Sepolia ist hier kein getesteter Startpfad.

Der ENV-Tresor wird nicht mit Wallet-Schluesseln vorbefuellt. Das Upstream-
Standardverzeichnis ist `~/.automaton`; fuer ein kuenftiges Labor ein separates
Benutzerkonto/isoliertes HOME unter dem privaten User-Workspace planen.
Das aendert dieses Setup nicht automatisch.

Vor Updates den Agenten stoppen und Zustand/DB, Konfiguration und erforderliche
Schluessel zusammen **verschluesselt** sichern; Restore nur in isolierter
Testumgebung. Niemals Rohzustand oder Wallet ins Git schieben. `.gitignore`
verhindert keine bereits getrackten Geheimnisse: Secret-Scan bleibt erforderlich.
Auch SOUL.md, Logs, Prompts und Berichte vor Export auf vertrauliche Daten pruefen.

Ein automatisierter Stopp bei Guthabenmangel ist kein allgemeiner Schutz gegen
laufende Cloud-Rechnungen. Das Aufladen einer Wallet garantiert weder Restore
noch Fortsetzung eines beendeten Jobs. Erst Zustand, Version und Provider pruefen.
Keine Rendite-, Einkommens- oder automatische Wiederbelebungsgarantie.

Recht/Steuern: Dieser technische Entwurf klaert weder Gewerbe-, Steuer-,
Datenschutz- noch Finanzaufsichtspflichten. Vor kostenpflichtigem, oeffentlichem
oder finanziell handelndem Betrieb die konkrete Nutzung fachkundig pruefen lassen;
keine pauschalen DACH-Anmeldeformulare oder Haftungsausschluesse aus dem Prompt uebernehmen.

## Offene Freigabekriterien

1. Exakte Zenbot-/Zentrade-Version und read-only Datenschnittstelle pruefen.
2. Abhaengigkeiten, Supply Chain und Pinning am genannten Commit auditieren.
3. Echten Labor-Build auf Linux/WSL und ARM pruefen; bisher keine Live-Installation durch Codex, kein `curl|sh`.
4. Technische Grenzen fuer Netzwerk, Signer, Cloudbudget, Prozesslaufzeit und Dateizugriff testen.
5. Ollama-only-Pfad ohne Cloud-Fallback und getrennte Testchain pruefen.
6. Danach erst eine separate opt-in Ausfuehrungsbruecke planen; Source-Build ist keine Betriebsfreigabe.

Reproduzierbarer Offline-Test:

Stand 16.10.2026: die 12 Python-Review-/Registry-Tests sowie Dry-Run,
Start-Sperre und simulierte Fetch-/Commit-Fehler wurden geprueft. Der kombinierte
Build-/Deaktivierungs-Mocktest erreicht auf diesem Windows-Testhost das
Zeitlimit und ist noch nicht als bestanden bestaetigt. Kein echter
pnpm-Install/Build, keine Wallet-/Cloud-/Agentenausfuehrung durch Codex.

```bash
python3 -m unittest discover -s tests -p test_automaton.py -v
```
