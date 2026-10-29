# Coding-Agenten-Branch: Abnahme vor main

Die Frischinstallation wurde vom Nutzer als erfolgreich gemeldet. Das belegt
zunaechst den Einstieg und das laufende Setup-Menue, nicht alle Agenten oder
deren Modellverbindungen. Die folgenden Tests im **installierten Feature-Checkout**
ausfuehren: dort liegen `setup_ultimate.sh`, `scripts/` und `tests/`.
Nicht mit `sudo`, nicht in produktiven Agentenprojekten und nicht parallel zu
einer anderen Installation testen. [Bedienung und Grenzen](LOCAL_CODING_WORKBENCH.md).

## 1. Ausgangsstand festhalten

```bash
pwd
git branch --show-current
git log -1 --format='%h %s'
git status --short
git diff --summary
uname -srmo
python3 --version
df -h . "$HOME"
```

Erwartet: `codex/optional-coding-agents-20261029`, passende Commit-ID und
nachvollziehbarer Arbeitsstand. Keine ENV-/Auth-Dateien ausgeben. Falls Git
Aenderungen meldet, zuerst melden, nicht resetten oder automatisch bereinigen.
Der bisherige Bootstrap macht Shell-Dateien ausfuehrbar; reine Mode-Aenderungen
erscheinen in `git diff --summary`. Auch diese koennen Clean-Worktree- und
Update-Checks blockieren und sind vor deren Live-Abnahme zu klaeren.

## 2. Gefahrloser Offline-Kerncheck

Diese benannten Tests verwenden temporaere Fixtures und Mocks. Keine echten
CLIs bauen, Modelle herunterladen, Docker-/Clusterdienste starten oder API-Keys
eingeben. Der Subshell-Block begrenzt `set -e` auf den Testlauf: ein Fehler
beendet nicht deine interaktive Linux-Shell.

```bash
(
  set -e
  for pattern in \
    test_install_branches.py \
    test_signed_release.py \
    test_coding_workbench.py \
    test_coding_workbench_registry.py \
    test_native_coding_clis.py \
    test_openhands_worker.py \
    test_coding_agent_profiles.py
  do
    test -f "tests/$pattern" || { printf 'Testdatei fehlt: %s\n' "$pattern"; exit 1; }
    python3 -B -m unittest discover -s tests -p "$pattern" -v
  done
  python3 -B scripts/quality/repository_audit.py --section registry
)
```

Erwartet: alle Unittest-Zusammenfassungen mit `OK`, keine `FAILED`-/`ERROR`-
Testergebnisse und am Ende Registry-Fehlerzahl 0. Negative Mocktests koennen
absichtlich Ablehnungs-/Fehlermeldungen ausgeben; entscheidend ist ihr finales
Testergebnis, nicht ein einzelnes Wort im simulierten Log. Bestehende
Kataloghinweise getrennt notieren. `skipped` mit Grund dokumentieren, nicht als
bestanden zaehlen. Ein Socket-/Rechte-Fixturetest auf Linux bleibt eine synthetische
Probe, kein echter Ollama-/OpenHands-Test. Die neue Dokumentationspruefung
`test_docs_navigation.py` kommt mit diesem Doku-Commit hinzu und laeuft in CI;
auf deinem frisch installierten aelteren Checkout kann sie noch fehlen.
Zusaetzlich moeglich: `test_p0_safety.py`, `test_qwen_code.py`,
`test_tool_menu_order.py` und `test_native_tool_menu.py` nach demselben Schema.

## 3. Menue und Planfunktionen

Im bereits laufenden Setup nur navigieren, noch keine schweren Tools auswaehlen:

- In Tools sind OpenCode, Qwen Code, Aider, OpenHands und Codex_CLI auffindbar.
  Bestehende Tool-Eintraege und A-Z-Sortierung bleiben erhalten.
- Die Profile OpenCode_Local, Qwen_Code_Local, Aider_Local,
  OpenHands_Isolated_Worker und Codex_CLI_Adapter sind einzeln auffindbar.
- OpenHands beschreibt SDK-Quellen statt einer fertigen Web-App.
  Claude Code wird nicht als vollstaendige Open-Source-CLI dargestellt.
- `experimental` bleibt absichtlich bestehen, solange echte Laufzeitabnahmen fehlen.
  Keine installierten Programme durch pauschales Abwaehlen deinstallieren.

Die neuen Buildplaene ohne Installation pruefen:

```bash
(
  set -e
  for tool in opencode aider codex_cli openhands; do
    bash "scripts/tools/${tool}_install.sh" --plan
  done
  python3 -I -B scripts/agents/workbench.py configure \
    --agent opencode --model qwen2.5-coder:7b
)
```

Erwartet: Quelle/Pin und Voraussetzungen bzw. Konfigurationsplan, keine
Downloads, Builds, Anmeldung oder Modellanfrage. Der Modellname ist nur ein
Planbeispiel; er wird weder gesucht noch installiert. Qwens bestehender Builder
hat eigene Optionen und wird durch diesen Loop nicht gestartet.

## 4. Profil-Lifecycle in einem Wegwerf-Workspace

Dieser optionale Test schreibt ausschliesslich Vorlagen/Marker in einen neu
angelegten temporaeren Workspace. Er installiert keine CLIs oder Modelle und
fasst deinen normalen Nutzerworkspace nicht an. Der Testordner bleibt zur
Nachkontrolle erhalten, statt automatisch rekursiv geloescht zu werden.

```bash
(
  set -e
  TEST_ROOT="$(mktemp -d -t openclaw-agent-abnahme.XXXXXX)"
  export OPENCLAW_USER_DATA_DIR="$TEST_ROOT/workspace"
  for profile in OpenCode_Local Qwen_Code_Local Aider_Local \
                 OpenHands_Isolated_Worker Codex_CLI_Adapter; do
    bash "scripts/profiles/${profile}_install.sh"
    bash "scripts/profiles/${profile}_install.sh"
    bash "scripts/profiles/${profile}_uninstall.sh"
  done
  printf 'Testdaten zur Nachkontrolle: %s\n' "$TEST_ROOT"
)
```

Erwartet: zweiter Installationsaufruf ohne Konflikt; Deaktivierung entfernt nur
die Profilregistrierung. `profile.json` bleibt erhalten, `installed.json` wird
entfernt; keine echte Runtime wird als einsatzbereit gemeldet. Ein Fehler ist
kein Anlass, deinen normalen Workspace oder dessen Sperren zu loeschen.

## 5. Branch-Auswahl und Updates

Die Offline-Tests decken Default-main, Featurebranch, freie Namen, fehlende
Branches, Ref-/Tag-Verwechslung und Backup-vor-Fetch ab. Einen zusaetzlichen
Live-Test nur ohne parallel laufendes Setup und vorzugsweise in einer
Wegwerf-VM bzw. mit gepruefter Sicherung vornehmen:

- Auswahl `0` beendet den Bootstrap, ohne Checkout/Setup zu starten.
- Bei freier Eingabe bedeutet eine leere Eingabe Abbrechen, nicht main.
- Ein sicher nicht vorhandener Branch bricht nach der Remote-Abfrage ab;
  es wird kein main als Ersatz installiert. Netzwerkfehler bleiben Fehler.
- Fuer ein Live-Update desselben Featurebranches erst sauberen Arbeitsstand,
  passenden Origin und eine erfolgreiche Repo-Sicherung pruefen. Kein zweites
  Setup gleichzeitig starten. Keine echten Nutzdaten fuer Fehlerprovokationen verwenden.
- main nicht probeweise ueber die bestehende Feature-Installation kopieren.
  Separate Checkout-Ordner bedeuten weiterhin denselben privaten Nutzerworkspace.

Der signierte Update-Menuepunkt ist kein Branch-Updater. Ohne signiertes
Release, Artefakte und unabhaengigen Public Key ist dessen Abbruch beabsichtigt.
Nicht fuer den Test die Signaturpruefung abschalten.
[Branch-Installer und Parameter](../INSTALL_BRANCH_SELECTION.md).

## 6. Echte Agentenfunktion separat abnehmen

Das ist **nicht** durch Frischinstallation oder Offline-Tests bewiesen:

| Komponente | Gesonderter Nachweis |
| --- | --- |
| OpenCode | Erfolgreicher gepinnter Bun-Build; geprueftes Workerimage; reale lokale Modellantwort und Tool Calling |
| Qwen Code | Vorhandener Source-Build; reale lokale Modellantwort; kein unerwarteter Login oder Cloud-Fallback |
| Aider | Vollstaendiger gepruefter Hash-Lock, Wheel/venv-Build, `pip check` und lokale Modellfunktion |
| Codex CLI | Passende echte Rust-Toolchain, gepinnter Build und lokale Responses-Kompatibilitaet; kein erzwungener OpenAI-Login |
| OpenHands | SDK im separat gebauten Image; echter erfolgreicher SDK-Abschluss; Quellen allein sind kein Worker |

Neue native Buildpfade sind derzeit nur fuer nichtprivilegiertes natives Linux
amd64/glibc freigegeben. Eine WSL-Ablehnung ist dort eine dokumentierte Grenze,
kein Anlass fuer sudo, einen Docker-Fallback oder das Entfernen von Schutzchecks.
Die Linux-Container-Ausfuehrung benoetigt ein vorhandenes geprueftes Image mit
echtem Digest und ein bereits lokal vorhandenes Modell. Nicht fuer die Abnahme
beliebige Images, Hashes oder Zugangsdaten erfinden.

Vor einem echten Lauf die [Workbench-Anleitung](LOCAL_CODING_WORKBENCH.md)
vollstaendig beachten. In einem separaten agents/NAME-Testworktree nachweisen:
Plan/Review/Test koennen die Projektdateien nicht aendern, Implementierung nur
diesen Worktree; keine weiteren Host-Sockets oder Host-Credentials ausser dem
ausdruecklich vorgesehenen Modell-Broker-Socket, kein Netz nach aussen,
funktionierende Ressourcen-/Zeitgrenzen, sichere Abbruchbehandlung und private
Transkripte. Host-Quota und Kernel-/Container-Isolation bleiben eigene Abnahmen.
Fehlende Hardware/Images/Toolchains als **nicht getestet** protokollieren.

## 7. Entscheidung fuer main und Testbericht

Fuer einen PR muessen mindestens Einstieg/Menue, Offline-Kernchecks, Quellen-/
Profilverweise, bestehende Basisfunktionen und die GitHub-CI nachvollziehbar
funktionieren. Fehler oder unerwartete Daten-/Dienstaktionen zuerst beheben.
Den PR nicht allein wegen einer erfolgreichen Frischinstallation genehmigen.

Offene optionale Runtime-Tests duerfen nur mit explizit dokumentierter Grenze
und unveraendertem experimental-/Opt-in-Status offenbleiben; das ist **keine**
Produktionsfreigabe. Fuer stable-/Runtime-Zusagen sind die echten Tests Pflicht.
Keine automatischen Deployments oder Main-Merges zur Abnahme starten.

Bitte folgende bereinigte Angaben zurueckmelden:

```text
Branch und Commit:
Plattform (Ubuntu-Version, WSL ja/nein, Architektur):
Arbeitsstand (git status; Codeaenderungen oder nur Mode-Aenderungen?):
Offline-Tests (OK / Fehler / skipped mit Gruenden):
Menue und Profile auffindbar:
Planaufrufe und temporaerer Profil-Lifecycle:
Branch-Test (Abbruch / fehlender Branch / Update):
Echte Agenten-/Modelltests: bestanden / nicht getestet / Fehler
Unerwartete Dateien, Dienste oder Downloads:
Relevanter Fehlerausschnitt ohne Zugangsdaten:
```

Keine kompletten ENV-Dateien, Auth-Verzeichnisse, Tokens oder privaten
Credential-Backups senden. Der Maintainer prueft Diff, CI und offene Punkte
vor dem bewussten Merge. [Zur Dokumentationsuebersicht](../readme.md).
