# OpenClaw-Guard und Tool-Reihenfolge: lokale Abnahme

Stand: 02.11.2026. Basis: `e5359d0` auf lokalem `main` im regulaeren
Projektverzeichnis, kein Ersatz-Worktree. Keine produktive Installation,
kein WSL-, Modell-, Dienst-, Container- oder Clusterstart. Keine realen Keys
oder privaten User-Workspaces gelesen. Kein Push oder Merge durch diesen Auftrag.

Implementierungscode: lokaler Commit `084f950` auf `main`; diese Dokumentation
folgt als getrennter Nachweiscommit. Das ist kein Online-CI-Nachweis.

## Aenderungen

- OpenClaw-Legacy-Clone/Pull, `/opt`-Adoption und Paket-Hooks durch denselben
  Quellen-Guard wie Ollama/K3s ersetzt. Bytepruefung ist weiterhin keine
  Installation, Authentizitaetspruefung oder Runtime-Abnahme.
- Alter Installertext als nicht ausfuehrbare historische Referenz erhalten;
  seine gemockten Fehlerhandler-Tests bleiben bestehen. Neue Tests pruefen
  zusaetzlich den echten aktiven Wrapper und den vorgezogenen Menue-Guard.
- 352 vorhandene Nicht-Core-Menueschluessel wieder A-Z, drei feste Eintraege
  vor der Trennlinie. Keine Programme hinzugefuegt oder Schluessel umbenannt.
- Neue Schluessel bleiben automatisch hinter dem eingefrorenen Katalog;
  erneutes Oeffnen veraendert ihre Registrierungsreihenfolge nicht.
- Sortierlogik als kleiner Offline-Python-Helfer statt weiterer Bash-
  Datenflusslogik im Monolithen. Kein Download und kein zusaetzlicher Dienst.

## Funktionstests

Serielle Gruppen mit disjunkten Testmodulen, keine Testloeschung, keine
pauschal verlaengerten Timeouts und keine abgeschwaechten CI-Regeln:

| Auswahl | Tests | Bestanden | Skips |
| --- | ---: | ---: | ---: |
| P0-Safety: temporaere Git-Repositories und gemockte Docker-/PAT-Pfade | 22 | 21 | 1 |
| Sortierung, Core-Guard, Trennlinie/Plattformdispatch, Shell-Vertraege, Legacy-Uninstall, Registry, Navigation, ComfyUI und Medienstatus | 112 | 110 | 2 |
| Summe unterschiedlicher Tests | 134 | 131 | 3 |

Die drei Skips betreffen echte Symlink-Tests ohne entsprechende Windows-
Berechtigung. Die Linux-CI bleibt fuer diese Abnahme erforderlich.
Die Core-Guard-Suite (18 Tests, 17 bestanden, ein Skip) wurde nach einer
expliziten LF-Korrektur ihrer generierten Shell-Fixtures erneut geprueft;
diese Wiederholung ist bereits in der obigen Testmenge enthalten, nicht additiv.

## Pruefgrenzen und Ressourcen

Ein erster gebuendelter Lauf unter paralleler Prueflast meldete
Ausfuehrungsfehler und wurde abgebrochen, nicht als erfolgreich gewertet.
Auch ein langer Voll-ShellCheck wurde beendet. Ein zusaetzlicher Diagnoseaufruf
erreichte sein Zeitlimit. Die konkrete Ursache ist damit nicht abschliessend
bewiesen; nach Beenden des eigenen langen Prueflaufs wurden 8 GiB RAM gesamt
und rund 1,2 GiB frei gemessen. Fremde Prozesse oder Dienste wurden nicht beendet.
Die seriellen Wiederholungen oben bestehen; daraus wird kein erfolgreicher
erster Lauf und keine vollstaendige Plattform-Abnahme abgeleitet.

ShellCheck wurde danach gezielt fuer den vollstaendigen OpenClaw-Wrapper und
die aus dem echten Setup extrahierte finale Sortierfunktion erfolgreich
ausgefuehrt, mit unveraenderter `.shellcheckrc`. Die generierte Pruefdatei hat
explizit LF; ein zuvor dabei gemeldeter CRLF-Fehler betraf die temporaere
Pruefdatei und wurde dort behoben, nicht per Regelunterdrueckung.
**Der komplette neue Voll-ShellCheck des Monolithen ist lokal nicht abgenommen.**
Die vorhandene Windows-Binaerdatei unterstuetzt das angefragte RTS-Speicherlimit
nicht; der entsprechende Diagnoseaufruf war kein bestandener Lint-Lauf.
Die vollstaendigen CI-ShellCheck-Regeln bleiben unveraendert aktiv.
Die vollstaendige Bash-Syntaxpruefung beider geaenderten Shell-Dateien und
deren shfmt-Differenzpruefung bestehen ebenfalls.
Der abschliessende Offline-Repositorycheck meldet 400 Tools, 250 Profile,
45 Ports, 269 Python-Dateien, 177 Testmodule und 1196 Markdown-Dateien:
0 Fehler, unveraendert 802 dokumentierte Metadatenhinweise.

Nicht nachgewiesen: Online-CI fuer diese Commits, neue vollstaendige Python-
Discovery, Fresh-Host-/Linux-/ARM-Betrieb, native OpenClaw-Builds, Dienste,
Hardware oder Inferenz. Keine automatische Bereitschafts-Hochstufung.

## Breaking Changes und Rollback

OpenClaw-Legacy-Neuinstallation und das darin versteckte Update sind bewusst
gesperrt. Vorhandene Installationen und Nutzdaten bleiben erhalten.
Fehlende/defekte Sortierbasis oder fehlendes Python lassen die Auswahl
unveraendert und brechen das Menue vor weiterer Statusverarbeitung ab.

Code-Rollback nur nach Review; keine privaten Daten oder Marker loeschen.
Eine Rueckkehr zum alten OpenClaw-Installer wuerde das dokumentierte Risiko
reaktivieren und ist kein empfohlener Betriebs-Workaround.

Naechster Sicherheitsschritt: authentisierte Quell-/Toolchain-Vertraege mit
kontrolliertem Build-Snapshot und getrenntem Dienst-/Runtime-Nachweis verbinden;
siehe [P0-B-Restliste](../P0_B_CORE_SOURCES.md#naechster-teilsatz).
