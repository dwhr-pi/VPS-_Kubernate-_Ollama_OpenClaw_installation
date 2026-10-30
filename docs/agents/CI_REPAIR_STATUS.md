# PR 6: CI-Befunde und erster Reparatursatz

Stand: 29.10.2026. **Noch keine Merge- oder Produktionsfreigabe.** Die lokalen Teiltests des Nutzers
bleiben gueltig; sie pruefen aber nicht alle Workflows und die gesamte, damals 2.175 Tests
umfassende Regression. Push- und PR-Laeufe zeigen teilweise dieselbe Ursache mehrfach an.

## Ausgewerteter GitHub-Stand

Head `153372ce86f2cc880b0a606bc2c5d5a3d5b07cfc`, Base `ea02bf8d9c36aaf479bd2bd9d1b529ea1b489156`,
[PR 6](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/pull/6). Die
folgenden Links sind datierte Fehlerbelege, keine Aussage ueber spaetere Runs.

| Pruefung               | Belegter Befund                                                                                                                                                                                                                                              | Bearbeitung                                                                                                                 |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| macOS-Agenten-Fixtures | `https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40936270460/job/123667511933` (Job; unverifizierte Originalreferenz, CI HTTP 502, 30.10.2026): temporaerer `/var`-Pfad fuehrt ueber Symlink und wird korrekt abgelehnt | Fixture-Pfade vor Verwendung kanonisieren; produktive Symlink-Sperre bleibt unveraendert                                    |
| Gitleaks               | [Job](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40936270324/job/123667511137): Scanbereich enthaelt einen im flachen Checkout fehlenden Vorfahren                                                                 | Vollstaendige Git-Historie, keine gespeicherten Checkout-Credentials, fester Action-Commit; Scan bleibt verpflichtend       |
| Installationsinventar  | [Job](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40936270648/job/123667513146): vorinstalliertes Kustomize auf dem Runner beeinflusst Fixture-Export                                                               | Inventar-Fixture auf seinen eigenen Workspace begrenzen; Artefakt-/Pruefsummenpruefung erhalten                             |
| Gesamtregression       | [Job](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40936270887/job/123667512668): neun Fehlschlaege und zwei Fehler                                                                                                  | README-Schreibweise, alte Status-/Wrappererwartungen, Displaynamen, Tabellenanzahl und fehlende Beispieldateien korrigieren |
| ShellCheck             | [Job](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40936270195/job/123667510817): Befunde in zahlreichen Skripten                                                                                                    | Weiterhin offen; nicht durch pauschale Excludes oder Fehlerignorierung behoben                                              |
| Markdownlint           | [Job](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40936270540/job/123667512004): umfangreiche Formatbefunde                                                                                                         | Weiterhin offen; keine ungepruefte Massenumschreibung aller Dokumente                                                       |
| Trivy-Konfiguration    | [Job](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40936270648/job/123667513246): HIGH-Befunde etwa zu SecurityContexts/Read-only-Root                                                                               | Weiterhin offen; vollstaendige Workloads und Patch-/Beispieldateien fachlich unterscheiden, nicht Scanner ausschalten       |
| Markdown-Links         | [Job](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40936270792/job/123667512364): zahlreiche nicht erreichbare Links                                                                                                 | Weiterhin offen; historische/unbestaetigte Quellen nicht still als geprueft ausgeben                                        |

## Schutzregeln bleiben bestehen

Die neuen Coding-Adapter akzeptieren weiterhin keine beliebigen Markerdateien. Die alte generische
Marker-Fixture prueft jetzt ausschliesslich ihre Legacy- Vertraege; ein eigener Negativtest prueft
die Ablehnung ungueltiger Coding- Nachweise. Native Tool-/Modellstarts, Credential-Import und
automatische Produktivdeployments werden dadurch nicht freigegeben.

Die fehlenden oeffentlichen Beispiele liegen unter `config/examples/` und `k8s/gitops/examples/`,
nicht in den fuer echte Secrets ignorierten Ordnern. Sie enthalten ausschliesslich Platzhalter. Das
SealedSecret-Strukturbeispiel ist kein echter Ciphertext und kein Apply-fertiges Manifest. Es werden
keine realen Schluessel erzeugt, gelesen oder verschoben.

Gitleaks wurde auf den offiziell aufgeloesten v2-Commit `ff98106e4c7b2bc287b24eaf42907196329070c7`
gepinnt:
[offizielles Tag-Objekt](https://api.github.com/repos/gitleaks/gitleaks-action/git/tags/dcedce43c6f43de0b836d1fe38946645c9c638dc).
Ein Pin ersetzt weder Lizenzpruefung noch einen erfolgreichen Scan. Falls der nun vollstaendige Scan
echte Funde liefert, bleiben diese Blocker; keine breit gefasste Allowlist und keine automatische
History-Umschreibung.

## Zweiter Reparatursatz und neue CI-Belege

Am Head `566ebe51618872e56c62f7b241a146c932d8b7a3` besteht die
[volle Offline-Regression](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40943474053/job/123692602411):
**2.180 Tests, OK (8 uebersprungen)**. Auch die Gitleaks-Scans sind gruen. Das bedeutet keine
Freigabe der weiterhin roten Konfigurations-/Lint-Pruefungen.

Der
[macOS-Lauf](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40943474488/job/123692604206)
passiert nun Workbench und Registry, trifft aber im folgenden Modul `test_native_coding_clis.py`
erneut auf `/var` als Symlink-Vorfahren. Auch dessen temporaere Fixture-Wurzel wird kanonisiert. Der
produktive `guarded()`-Vertrag und seine Symlink-Negativtests bleiben unveraendert.

[Next Level Health](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40943473934/job/123692601516)
meldet unaufgeloeste lokale Queue-Sources und ein unbenutztes TSV-Prioritaetsfeld. ShellCheck
verfolgt diese Sources jetzt explizit mit `-x` und `--source-path=SCRIPTDIR`; es gibt keinen
SC1091-Ausschluss. Das bereits zur Jobauswahl verwendete Prioritaetsfeld wird beim Einlesen der
ausgewaehlten Zeile als `_priority` gekennzeichnet; die TSV-Struktur bleibt gleich. Der
Agent-Framework-Python-Check verwendet statt einer Ein-Element-Schleife einen einzelnen, weiterhin
vollstaendig zitierten Programmpfad. Zwei Tests pruefen Leerzeichen im Pfad und die Ablehnung eines
inkompatiblen Overrides.

Lokale Abnahme des zweiten Satzes: **34 Tests OK (1 uebersprungen)** fuer Queue, Framework und
CI-Vertraege; separat **44 native CLI-Tests OK**. Der gezielte Health-ShellCheck ist mit ShellCheck
0.11.0 ohne Befund. Das pruefsummengepruefte Windows-Testwerkzeug liegt nur im temporaeren
Validierungsordner; weder Setup-Installation noch System-PATH wurden geaendert. Der Ubuntu-CI-Lauf
mit seinem ShellCheck 0.9.0 und die echte macOS-Abnahme muessen fuer den neuen Commit erneut laufen.

Die weiteren Logs zeigen **9.323 Markdownlint-Befunde** und **29 HIGH-Trivy-Befunde**: zwoelf in
unvollstaendigen Kustomize-Patches, 17 in `scripts/k8s_deployments.yaml`. Patches muessen gegen die
gerenderten Workloads bewertet werden; alte vollstaendige Deployments brauchen eine eigene
Laufzeit-/Volume-Abnahme. Keine pauschalen Scanner-Ausnahmen und keine ungepruefte
UID-/Read-only-Umstellung nur fuer einen gruenen Status. Der globale ShellCheck und die Linkpruefung
bleiben ebenfalls offen.

## Dritter Reparatursatz: Health-Wrapper und Overlay-Vertraege

Am Head `8d65f6383429a8890e32d71700b72e3ccb005fb9` sind die Agenten-Fixtures auch auf macOS gruen.
Die Health-ShellCheck- und Registry-Schritte bestehen. Der
[folgende Fehler](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40945192363/job/123698607842)
ist ein separater Exit 126: `scan_secrets.sh` startet `check_secrets.sh` direkt, obwohl dessen
Git-Dateimodus kein Ausfuehrungsrecht enthaelt. Der Wrapper verwendet jetzt `exec bash`, ohne
chmod-Massenaktion oder sudo. Ein isolierter Test mit einem 0600-Helper prueft Erfolg, `--dry-run`
und die unveraenderte Weitergabe eines Fehlercodes. Der echte Scan wird dabei nicht auf persoenliche
Daten angewendet. Sein bisheriger informierender Safe-Modus ist kein Ersatz fuer die weiterhin
verpflichtenden Gitleaks-Scans.

Die globale `.shellcheckrc` aktiviert Source-Verfolgung mit `external-sources=true` und
`source-path=SCRIPTDIR`; sie unterdrueckt keine Regeln. Die noch spaeter folgenden Gitleaks-Schritte
in `CI` und `Repo Health` erhalten ebenfalls vollen Verlauf, den bereits geprueften Action-Commit
und Checkout ohne gespeicherte Credentials. Keine Scan-Abschwaechung.

In den zwei oben genannten Ressourcen-Patches werden die schon aus der Basis geerbten
SecurityContexts ausdruecklich wiederholt: Non-root, UID/GID 10001, RuntimeDefault-Seccomp, kein
Privilegienanstieg, read-only Root und Drop ALL. Die mit pruefsummengeprueftem Kustomize 5.8.3 lokal
gerenderten `production`- und `vps-cpu`-Workloads sind vor/nach dem Patch **bytegleich**. Keine
Aenderung von UID, Datenpfad, Volume, Netzwerk oder Laufzeitverhalten im fertigen Manifest. Ein
Offline-Vertrag gleicht die Sicherheitsfelder gegen die Basis ab. Ein neuer Trivy-Lauf muss das
Ergebnis bestaetigen; lokal wurde Trivy nicht ausgefuehrt. Die **17 HIGH-Befunde im alten
Gesamtmanifest bleiben offen**.

Lokale Abnahme: **57 Tests OK (7 uebersprungen)** in fuenf betroffenen Modulen; der geaenderte
Secret-Wrapper besteht ShellCheck 0.11.0. Die uebersprungenen Tests sind keine
Linux-/Cluster-Abnahme. Globale Shell-/Formatierungsfehler werden durch diese Teilabnahme nicht als
geloest ausgegeben. Eine zusaetzliche lokale ShellCheck-Gesamtanalyse ueber 2.175 Shell-Dateien
wurde zeitlich begrenzt beendet und gilt ausdruecklich nicht als bestanden. Die globalen
CI-Pruefungen bleiben unveraendert verpflichtend.

Der
[neue PR-Linkcheck](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40945192988)
ist inzwischen ebenfalls fehlgeschlagen: darunter echte 404-Links, Platzhalter-Repositories, nicht
erreichbare lokale Beispielports sowie 202-/403-/503-Antworten und Timeouts. Diese Klassen duerfen
nicht pauschal als gueltige Links freigegeben werden. Alte Quellen bleiben erhalten; Ersatz-URLs
muessen einzeln geprueft werden. Mehr Warten behebt abgeschlossene rote Laeufe nicht.
Push-/PR-Doppelanzeigen sind keine unabhaengigen Fehler.

## Vierter Reparatursatz: freigegebene Archivierung des Altmanifests

Der Nutzer hat ausdruecklich freigegeben, das alte Gesamtmanifest als nicht ausfuehrbare historische
Referenz zu erhalten. Der YAML-Pfad unter `scripts/` entfaellt; der unveraenderte Quelltext liegt
als Codeblock in [der Archivdatei](../legacy/K8S_DEPLOYMENTS_LEGACY.md). SHA-256 des normalisierten
Quelltextblocks: `5c6b694dbfbab8e43b26364054777d9d2e930eb64e3acf5dc39da19c5d4354f2`. Der neue Test
prueft diesen Hash, den entfernten YAML-Pfad und die Anzeige in einem isolierten Verzeichnis,
einschliesslich Fehler bei fehlendem Archiv.

Die Menueoperation behaelt ihren Namen, zeigt aber eine deutliche Archivwarnung und die aktuellen
Kustomize-Einstiege. README, Checklisten und lokale Auditlinks verweisen auf die Referenz;
historische Befunde und Inventardaten bleiben als datierte Belege erhalten. Kein Scanner-Ausschluss
wurde hinzugefuegt.

**Breaking Change:** Externe Skripte duerfen den alten YAML-Pfad nicht mehr verwenden. Kein
Installer und keine Operation fuehren den archivierten Code aus. Bereits laufende Pods, Services,
PVCs und Secrets bleiben unveraendert; die Archivierung ist keine Reparatur solcher Installationen.
Eine Ruecknahme der Repo-Aenderung erfordert ein eigenes Review, keinen Cluster-Rollback.

Lokale Abnahme: **39 Tests OK**, ShellCheck der Anzeige ohne Befund. Trivy **0.76.1** aus
SHA256-geprueftem offiziellem Windows-Release meldet beim Konfigurationsscan **0
HIGH/CRITICAL-Befunde** fuer 44 erkannte Dateien. Es bleibt eine Abdeckungsluecke:
`charts/monitoring-lite` kann ohne gepruefte Image-Digests nicht gerendert werden; eine rohe
Helm-Template-Datei wird vom YAML-Parser abgelehnt. Der Scan-Erfolg beweist daher keine
vollstaendige Helm-/Runtime-Pruefung. Keine echten Digests oder Credentials wurden erfunden. Der
neue GitHub-Lauf muss den Stand unter Linux erneut bestaetigen.

Globale Shell-/Markdown- und Linkbefunde bleiben weiterhin offen. Die Zahl roter Push-/PR-Checks
allein erlaubt weder Merge- noch Produktionsfreigabe.

## Freigegebene Formatierungsbereinigung vom 30.10.2026

Dieser Satz ist groesser als die vorangegangenen gezielten Fixes und wurde am 29.10. ausdruecklich
vom Nutzer freigegeben. Die Regeln stehen in der
[Formatierungspolicy](../quality/FORMATTING_POLICY.md). Shell-Dateien wurden mit shfmt 3.8.0,
Markdown mit Prettier 3.6.2 und markdownlint-cli 0.44.0 bearbeitet; keine Installer oder Modelle
wurden dabei gestartet.

Zwei Shell-Formatter-Gates verwenden nun dieselben Optionen. Vier beschaedigte Audit-Tabellen wurden
strukturell korrigiert; urspruengliche Zelltexte, auch Code mit `\|\|`, blieben erhalten.
Historische Codebloecke werden nicht zur optischen Zeilenkuerzung umgeschrieben. Der Archiv-Hash
bleibt Testvertrag.

Der erste komplette Windows-Fixturelauf meldete 2.189 Tests, davon 32 uebersprungen, aber 32
Fehlschlaege und sieben Testfehler. Die Befunde betrafen layoutabhaengige Text-/Quellvergleiche,
keine bestandene Gesamtabnahme. Nach gezielten Testkorrekturen bestanden die betroffenen Module:
**348 Tests OK, drei uebersprungen**. Separate Gegenproben pruefen, dass fehlende Verneinungen
weiterhin fehlschlagen und Marker-/Pruefreihenfolgen erhalten bleiben. Fuer 16 kritische
Shell-Dateien war die minifizierte Programmstruktur vor und nach der Formatierung identisch. Das ist
kein Ersatz fuer Laufzeit-, Plattform- oder Produktionspruefungen.

Abnahme vor dem Upload: Der repositoryweite Markdownlint-Lauf hat **0 Befunde**. Der shfmt-Check mit
gemeinsamen Optionen und `git diff --check` bestehen. Ein weiterer Satz aus Archiv-, Navigations-,
Registry-, Policy- und Testvertragspruefungen besteht mit **36 Tests**. Die Pruefsatzzahlen werden
wegen moeglicher Ueberschneidungen nicht zu einer neuen Gesamtzahl addiert. Die ganze
Linux-Regression muss fuer den neuen Commit in GitHub laufen.

Die letzten lokalen ShellCheck-Befunddateien enthalten noch **388 Meldungen** in 160 zuvor
auffaelligen Dateien. Globale Shell-Befunde und externe Linkfehler sind damit weiterhin offen; keine
pauschalen Excludes oder HTTP-403-/202-Erfolgsbehauptungen. Fuer den neuen Commit muessen alle
verpflichtenden GitHub-Pruefungen erneut laufen. Kein Main-Merge.

## Weitere Shell- und Quellenkorrekturen vom 30.10.2026

Der gemeldete Head `4cead8a` hat 14 erfolgreiche und sieben fehlgeschlagene Pruefungen. Die roten
Anzeigen umfassen doppelte Push-/PR-Laeufe und betreffen weiterhin ShellCheck sowie externe Links.
Ein gruener Markdown- oder Konfigurationsscan ersetzt diese noch offenen Gates nicht.

Dieser begrenzte Reparatursatz aendert keine Scanner-Ausnahmen und keine produktiven Installationen:

- 36 EXIT-Handler deklarieren ihren Fehlerstatus lokal, bevor der verzuegert ausgefuehrte Handler
  ihn setzt. Der originale Exitcode bleibt erhalten.
- Die Enter-Pausen verwenden `read -r`; Benutzertexte mit Backslashes werden nicht als
  Escape-Sequenzen verarbeitet. Leere Bootstrap-Variablen erhalten explizite leere Werte.
- Gemeinsame Vorbedingungen werden als eine Bedingungsgruppe gekennzeichnet. Der Recovery-Block
  bleibt fuer das Scheitern einer beliebigen Vorbedingung zustaendig; Pruefreihenfolge und
  Kurzschlussverhalten bleiben erhalten.
- Sieben aeltere Installer brechen bei fehlgeschlagenem Verzeichniswechsel ab, statt Builds oder
  Git-Befehle im vorherigen Verzeichnis fortzusetzen.
- Benutzer-/Gruppenargumente und zwei kommaseparierte Paketargumente werden eindeutig quotiert.
  Deklaration und berechnete Zuweisung sind getrennt, damit der Rueckgabestatus der Berechnung nicht
  verdeckt wird. Tatsaechlich ungenutzte private Farbkonstanten wurden entfernt.

`tests/test_shell_error_contracts.py` prueft nur isolierte Shell-Fragmente: alle 36 EXIT-Handler mit
Status 0, 17 und 130, negative Verzeichniswechsel, die Build-/Quellen-Freigabe, die Paketargumente
und wortgetreue Eingaben. Dabei werden keine vollstaendigen Installer, Downloads oder Dienste
gestartet. Weitere vorhandene Tool- und Sicherheits-Fixtures bleiben unveraendert aktiv.

Lokale Teilabnahme: **fuenf neue Fragment-Tests OK**, dazu drei bestehende Formatierungspolicy- und
vier Navigations-Tests OK. Die Shell-Syntaxpruefung der 115 geaenderten Shell-Dateien besteht,
ebenso shfmt. Der Offline-Registry-Check bleibt bei **0 Fehlern und 802 Hinweisen**. Der komplette
Windows-Fixturelauf wurde zeitlich begrenzt und vor Abschluss beendet; er wird nicht als bestandene
Gesamtregression ausgewiesen. Ein ShellCheck-Zwischenlauf hat weiterhin Befunde, keine gruene
Gesamtabnahme. Die Linux-CI muss den veroeffentlichten Head erneut pruefen.

Vier Kataloglinks wurden anhand der offiziellen GitHub-Verzeichnis-API geprueft und korrigiert:

| Alter, nicht existierender Repositoryname | Belegter Quellpfad                                                                                               |
| ----------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| `modelcontextprotocol/server-filesystem`  | [servers/src/filesystem](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem)               |
| `modelcontextprotocol/server-git`         | [servers/src/git](https://github.com/modelcontextprotocol/servers/tree/main/src/git)                             |
| `modelcontextprotocol/server-sqlite`      | [servers-archived/src/sqlite](https://github.com/modelcontextprotocol/servers-archived/tree/main/src/sqlite)     |
| `modelcontextprotocol/server-postgres`    | [servers-archived/src/postgres](https://github.com/modelcontextprotocol/servers-archived/tree/main/src/postgres) |

SQLite und PostgreSQL bleiben ausdruecklich archivierte Referenzen und erhalten damit keine
Installations- oder Produktionsfreigabe. Dies ist keine vollstaendige Reparatur des externen
Link-Gates: weitere 404-Links, Login-Seiten und nicht erreichbare Inhalte muessen einzeln behandelt
werden. HTTP 202/403 wird nicht pauschal als Erfolg gewertet.

**Abnahme und Ruecknahme:** Die neuen Fragment-Tests muessen bestehen, Shell-Syntax, shfmt,
Markdownlint und `git diff --check` ebenfalls. Die vollstaendige Linux-Regression sowie die
verbleibenden Shell-/Link-Gates muessen fuer den neuen Head erneut laufen. Ruecknahme nur durch
einen reviewten Gegen-Patch; keine Datenwiederherstellung, Deinstallation oder Cluster-Aktion
erforderlich. Kein Main-Merge, keine Produktionsfreigabe.

## Autonome CI-Runde am 30.10.2026

Ausgangspunkt ist PR-Head `990d947a77e52a6c12eff9b493d310b5fffc27a3` mit 14 erfolgreichen und sieben
fehlgeschlagenen Checks. Der Branch bleibt `codex/optional-coding-agents-20261029`, kein Main-Merge
und kein Force-Push. Unterbrochene Teilaufgaben wurden lokal gegengeprueft, nicht ungeprueft
uebernommen.

Die Statusabfragen in der zentralen Setup-Logik und in den Managern pruefen nun die jeweilige
Operation unmittelbar. Cancel/ESC beendet den Dialog ohne Aktion; ein fehlgeschlagener Kindprozess
darf keine Installationsmarker veraendern. Ueberdeckte Fallback-Muster wurden entfernt, ohne die
spezifischen Speicherreserven abzusenken. Die Modell-Messwertnormalisierung ersetzt ausserdem eine
ungueltige `tr`-Zeichenklasse; der Originalmodellname bleibt ein einzelnes, unveraendertes
CLI-Argument.

Pakete werden als Arrays ohne Dateiglobbing weitergegeben. Externe SDK-/venv-Dateien sind als solche
annotiert, nicht als mitgelieferter, statisch gepruefter Quelltext ausgegeben. Fuer schreibende
Nameref-/Bibliotheksschnittstellen bleiben nur eng begruendete Einzelanweisungs-Ausnahmen.
Dynamische `printf`-Uebersetzungen werden vor der Verwendung auf ausschliesslich die erwartete Zahl
von `%s`-Slots geprueft; `%n`, `%b`, positionale und zusaetzliche Slots werden abgewiesen. Globale
ShellCheck-Regeln bleiben aktiv.

Ein nachgelagerter Lifecycle-Check konnte grosse Diagnoseberichte unter `pipefail` mit SIGPIPE
abbrechen. Sortieren in die temporaere Berichtsdatei statt in eine frueh geschlossene `head`-Pipe
beseitigt diesen Fehler. Der strenge Modus bleibt bei fehlenden Lifecycle-Dateien fehlgeschlagen;
die Anzeigebegrenzung verdeckt sie nicht.

Gezielte lokale Abnahme: sieben Setup-Vertragstests, 26 Shell-Vertragstests, 13
Branch-/Bootstrap-Tests, elf Link-Policy-Tests und ein grosser Lifecycle-Berichtstest bestanden. Ein
erster paralleler Windows-Lauf hatte einen Fixture-Timeout; die unveraenderte Branch-Race-Gegenprobe
und danach das vollstaendige Branch-Modul bestanden erneut. Mock-Tests starten keine echten
Installer, Modelle oder Dienste. Die vollstaendige Linux-Regression muss weiterhin den
veroeffentlichten Head pruefen.

Die Linkregeln stehen in der [Quellenpolicy](../quality/EXTERNAL_LINK_POLICY.md). Alle drei
Link-Gates verwenden dieselbe explizite Konfiguration. Vier exakt verankerte persoenliche
Konto-Einstiege sind als AUTH/inhaltlich nicht verifiziert klassifiziert; keine Domain-Ausnahme.
Oeffentliche 202/403 bleiben Fehler. Nachweise fuer DSGVO, AI Act, DSM und NIS-2 stammen vom
amtlichen EU-Publikationsportal, der Paperless-API-Nachweis aus der offiziellen
Repository-Dokumentation. Titel und CELEX bzw. Projektidentitaet sowie anonyme HTTP-200-Abrufe
wurden geprueft. Die alten Adressen bleiben an den Fundstellen erhalten. Dies belegt keine aktuelle
konsolidierte Rechtspruefung und keine Provider-Inferenz.

Weitere amtliche Quellen liefern weiterhin 403 oder Transportfehler. Eine ausdrueckliche
Entscheidung zur transparenten Archivkennzeichnung dieser einzelnen Quellen ist angefragt; bis dahin
bleiben sie im Link-Gate und blockieren die Gesamtabnahme. Diese Runde behauptet vor dem erneuten
GitHub-Lauf keine vollstaendig gruene CI.

Rollback erfolgt nur durch einen reviewten Gegen-Patch im Featurebranch. Es gibt keinen Datenbank-,
Workspace- oder Cluster-Rollback, weil diese nicht veraendert wurden.

## Nachlauf des autonomen Patchsatzes

Head `3409d90` bestand beide ShellCheck-Jobs. Die volle Linux-Regression meldete 2241 Tests, acht
plattformbedingte Skips und zwei Fehler: der Quellen-Test erkannte erhaltene historische Inline-URLs
nicht und die isolierte Dialog-Fixture lud die neue Formatvalidierung nicht. Beide Fixtures wurden
korrigiert, ohne Produktivpruefungen zu entfernen.

Der macOS-14-Job wurde vor Runner-Start durch den angekuendigten Brownout abgebrochen. Beleg:
[offizielle Runner-Abkuendigung](https://github.com/actions/runner-images/issues/13518). Die
unveraenderten Agententests laufen deshalb kuenftig auf macOS 15; Windows und Ubuntu bleiben.

Der vollstaendige Dateiscan fand acht Treffer, die der separate differenzbasierte Git-Scan nicht
meldete: oeffentliche Digest-/Commit-Metadaten, Prosa, alte Beispiel-Tokens und eine unsichere
private Installationsanleitung. Die Metadaten sind jetzt eindeutig benannt, ihre festen Werte und
Integritaetspruefungen unveraendert. Wiederverwendbare Tokenbeispiele wurden durch Platzhalter mit
lokaler Erzeugungs- und Rotationsanleitung ersetzt. Private Installation verwendet keine Tokens in
URLs oder Prozessargumenten und verweist auf die signierte Release-Pruefung. Gitleaks bleibt ohne
neue Ausnahmen aktiv; Diagnosen nennen geschwaerzt Regel, Datei und Zeile.

`docker_signing_sha256` benennt den oeffentlichen Ansible-Digest eindeutig; die alte Variable
`docker_key_sha256` bleibt als kompatibler Override erhalten. Rollback nur als Gegen-Patch;
veroeffentlichte Beispiel-Tokens nicht wieder in Betrieb nehmen. Echte User-ENV, Zugangsdaten und
Dienste wurden nicht angefasst. Noch keine Gesamtfreigabe: der neue Head und die externen Quellen
muessen erneut alle Gates bestehen.

Lokale Nachpruefung: 53 Tests in vier betroffenen Modulen bestanden; ShellCheck, shfmt, Markdownlint
und `git diff --check` ohne Befund. Der komplette Dateiscan mit dem offiziellen, SHA256-geprueften
Gitleaks 8.30.1 meldete null Treffer, ohne neue Scanner-Ausnahmen. Kein lokaler Ansible-Apply; ein
zusaetzlicher YAML-Parserlauf war mangels PyYAML nicht verfuegbar.

Die acht Skips des vorigen Linux-Gesamtlaufs betrafen drei native Qwen-PowerShell-Fixtures, vier
native Windows-Webinar-/Qwen-Launcher-Fixtures sowie den Windows-WSL-Launcher-Guard. Die dort
benoetigte Windows-Umgebung existiert auf dem Linux-Runner nicht; es wurden keine neuen Skips
eingefuehrt. Die Agenten-Vertragsmatrix auf Windows ersetzt keine volle
Windows-Installationsabnahme.

## Strikte Link-Abnahme nach dem Nachlauf

Head `0cb7ad5` bestand die komplette Linux-Regression mit 2247 Tests und denselben acht
plattformbedingten Skips. Die Agentenmatrix bestand unter Ubuntu, Windows und macOS 15. Der
vollstaendige Dateiscan bestand ohne neue Ausnahmen. Trotzdem war ein gruener Repo-Health-Job kein
gueltiger Linknachweis: seine CLI 3.13.7 protokollierte tote Links und lieferte dennoch Exitcode 0.

Alle drei Link-Gates verwenden deshalb die korrigierte, festgelegte Version 3.15.0 und pruefen deren
echten Prozess-Exitcode vorab mit reinen lokalen Dateifixtures. Die Parser-Abdeckung und
Status-/Auth-Regeln bleiben erhalten. Oeffentliche 202/403, Transportfehler und weitere tote Quellen
muessen weiterhin fehlschlagen. Der alte Drittanbieter-Link-Wrapper wird durch dieselbe festgelegte
CLI ersetzt; alle Markdown-Dateien bleiben erfasst. Keine gruene Gesamtabnahme vor den erneuten
Runs. Die bestehenden externen Quellenblocker bleiben dokumentiert und aktiv.

Lokaler Gegenbeweis: dieselbe Offline-CLI-Fixture besteht mit 3.15.0 und weist 3.13.7 wegen Exitcode
0 fuer ein fehlendes Dateiziel zurueck. Elf Quellenpolicy-Tests, Markdownlint, JavaScript-Syntax und
`git diff --check` bestanden. Der verbleibende Jarvis-404 im duplizierten Inventar ist ebenfalls
historisch gekennzeichnet; pnpm-Paketspezifikationen sind Code, keine E-Mail-Links. Keine neue
Domain- oder Statuscode-Ausnahme.

## Freigegebene Originalreferenzen

Am 30.10.2026 hat der Nutzer die Umklassifizierung einzeln nachgewiesener, nicht automatisch
verifizierbarer Quellen genehmigt. 23 exakte Adressen aus den Runs fuer `6e11a77` bleiben mit
Original-URL, Datum und CI-Status als unverifizierte Referenzen erhalten. Darunter sind geschuetzte
Behoerden-/Perplexity-Seiten sowie lokal erreichbare, aus GitHub fehlgeschlagene Quellen. Das ist
eine dokumentierte Aenderung des Live-Link-Pruefumfangs, kein Nachweis einer geloeschten oder
fachlich veralteten Seite. Keine neue Ignore-Regel und keine akzeptierten 202/403/406/5xx.

Die [Evidenzliste](../quality/UNVERIFIED_SOURCE_REFERENCES_2026-10-30.json) wird nicht als
Checker-Konfiguration benutzt. Erreichbare offizielle Perplexity-/CISA-Belege sind mit begrenztem
Pruefumfang ergaenzt; keine stillschweigende Gleichsetzung des Maerz-Bulletins mit dem August-PDF.
Originaladressen und datierte Berichte bleiben erhalten. Neue Linkfehler muessen weiterhin
fehlschlagen und einzeln geprueft werden. Der naechste Commit braucht erneut alle GitHub-Checks.

Lokale Abnahme dieser Quellenrunde: 21 Tests in drei Modulen bestanden, Markdownlint und
`git diff --check` ohne Befund. Auch der echte Markdown-Extractor der installierten
Linkchecker-Abhaengigkeit erkennt keine der 23 Originalreferenzen mehr als aktives Linkziel.
Die URLs sind weiterhin in ihren urspruenglichen Dateien enthalten. Keine Installation oder
Provider-Anfrage mit Zugangsdaten.

## Aeltere lokale Teilabnahme

Lokale Abnahme dieses Reparatursatzes unter Windows mit nativem Git Bash: 156 Tests in 15
betroffenen Modulen, **OK (2 uebersprungen)**. Der Offline-Registry-Check meldet weiterhin **0
Fehler, 802 Hinweise** bei 400 Tools, 250 Profilen und 45 Ports. `git diff --check` ist ohne Befund.
Diese erste lokale Teilabnahme allein wies noch keine volle Regression und keine echten macOS-,
Trivy-, ShellCheck- oder Gitleaks-Laeufe nach. Die spaeteren GitHub-Belege stehen in den obigen
Abschnitten.

Die hier korrigierten Vertraege lokal mit den betroffenen Testmodulen pruefen, danach die neuen
GitHub-Runs fuer den neuen Commit auswerten. Lokale Fixtures belegen weder einen echten
Gitleaks-Lauf noch eine macOS-Runner-Abnahme. Der komplette CI-Status muss weiterhin fuer genau den
vorgeschlagenen Head geprueft werden. Alte rote Runs verschwinden durch einen Commit nicht
rueckwirkend.

Bis die verbleibenden Befunde geloest und die erforderlichen Pruefungen gruen sind: **PR nicht
mergen, keine Neuinstallation, keine neuen Keys hinterlegen.** Main und produktive Konfigurationen
bleiben von diesem Reparatursatz unberuehrt.
