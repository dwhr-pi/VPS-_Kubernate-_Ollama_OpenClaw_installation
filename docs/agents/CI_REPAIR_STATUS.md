# PR 6: CI-Befunde und erster Reparatursatz

Stand: 29.10.2026. **Noch keine Merge- oder Produktionsfreigabe.**
Die lokalen Teiltests des Nutzers bleiben gueltig; sie pruefen aber nicht alle
Workflows und die gesamte, damals 2.175 Tests umfassende Regression.
Push- und PR-Laeufe zeigen teilweise dieselbe Ursache mehrfach an.

## Ausgewerteter GitHub-Stand

Head `153372ce86f2cc880b0a606bc2c5d5a3d5b07cfc`, Base
`ea02bf8d9c36aaf479bd2bd9d1b529ea1b489156`,
[PR 6](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/pull/6).
Die folgenden Links sind datierte Fehlerbelege, keine Aussage ueber spaetere Runs.

| Pruefung | Belegter Befund | Bearbeitung |
| --- | --- | --- |
| macOS-Agenten-Fixtures | [Job](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40936270460/job/123667511933): temporaerer `/var`-Pfad fuehrt ueber Symlink und wird korrekt abgelehnt | Fixture-Pfade vor Verwendung kanonisieren; produktive Symlink-Sperre bleibt unveraendert |
| Gitleaks | [Job](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40936270324/job/123667511137): Scanbereich enthaelt einen im flachen Checkout fehlenden Vorfahren | Vollstaendige Git-Historie, keine gespeicherten Checkout-Credentials, fester Action-Commit; Scan bleibt verpflichtend |
| Installationsinventar | [Job](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40936270648/job/123667513146): vorinstalliertes Kustomize auf dem Runner beeinflusst Fixture-Export | Inventar-Fixture auf seinen eigenen Workspace begrenzen; Artefakt-/Pruefsummenpruefung erhalten |
| Gesamtregression | [Job](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40936270887/job/123667512668): neun Fehlschlaege und zwei Fehler | README-Schreibweise, alte Status-/Wrappererwartungen, Displaynamen, Tabellenanzahl und fehlende Beispieldateien korrigieren |
| ShellCheck | [Job](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40936270195/job/123667510817): Befunde in zahlreichen Skripten | Weiterhin offen; nicht durch pauschale Excludes oder Fehlerignorierung behoben |
| Markdownlint | [Job](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40936270540/job/123667512004): umfangreiche Formatbefunde | Weiterhin offen; keine ungepruefte Massenumschreibung aller Dokumente |
| Trivy-Konfiguration | [Job](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40936270648/job/123667513246): HIGH-Befunde etwa zu SecurityContexts/Read-only-Root | Weiterhin offen; vollstaendige Workloads und Patch-/Beispieldateien fachlich unterscheiden, nicht Scanner ausschalten |
| Markdown-Links | [Job](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40936270792/job/123667512364): zahlreiche nicht erreichbare Links | Weiterhin offen; historische/unbestaetigte Quellen nicht still als geprueft ausgeben |

## Schutzregeln bleiben bestehen

Die neuen Coding-Adapter akzeptieren weiterhin keine beliebigen Markerdateien.
Die alte generische Marker-Fixture prueft jetzt ausschliesslich ihre Legacy-
Vertraege; ein eigener Negativtest prueft die Ablehnung ungueltiger Coding-
Nachweise. Native Tool-/Modellstarts, Credential-Import und automatische
Produktivdeployments werden dadurch nicht freigegeben.

Die fehlenden oeffentlichen Beispiele liegen unter `config/examples/` und
`k8s/gitops/examples/`, nicht in den fuer echte Secrets ignorierten Ordnern.
Sie enthalten ausschliesslich Platzhalter. Das SealedSecret-Strukturbeispiel
ist kein echter Ciphertext und kein Apply-fertiges Manifest. Es werden keine
realen Schluessel erzeugt, gelesen oder verschoben.

Gitleaks wurde auf den offiziell aufgeloesten v2-Commit
`ff98106e4c7b2bc287b24eaf42907196329070c7` gepinnt:
[offizielles Tag-Objekt](https://api.github.com/repos/gitleaks/gitleaks-action/git/tags/dcedce43c6f43de0b836d1fe38946645c9c638dc).
Ein Pin ersetzt weder Lizenzpruefung noch einen erfolgreichen Scan.
Falls der nun vollstaendige Scan echte Funde liefert, bleiben diese Blocker;
keine breit gefasste Allowlist und keine automatische History-Umschreibung.

## Zweiter Reparatursatz und neue CI-Belege

Am Head `566ebe51618872e56c62f7b241a146c932d8b7a3` besteht die
[volle Offline-Regression](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40943474053/job/123692602411):
**2.180 Tests, OK (8 uebersprungen)**. Auch die Gitleaks-Scans sind gruen.
Das bedeutet keine Freigabe der weiterhin roten Konfigurations-/Lint-Pruefungen.

Der [macOS-Lauf](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40943474488/job/123692604206)
passiert nun Workbench und Registry, trifft aber im folgenden Modul
`test_native_coding_clis.py` erneut auf `/var` als Symlink-Vorfahren.
Auch dessen temporaere Fixture-Wurzel wird kanonisiert. Der produktive
`guarded()`-Vertrag und seine Symlink-Negativtests bleiben unveraendert.

[Next Level Health](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40943473934/job/123692601516)
meldet unaufgeloeste lokale Queue-Sources und ein unbenutztes TSV-Prioritaetsfeld.
ShellCheck verfolgt diese Sources jetzt explizit mit `-x` und
`--source-path=SCRIPTDIR`; es gibt keinen SC1091-Ausschluss.
Das bereits zur Jobauswahl verwendete Prioritaetsfeld wird beim Einlesen der
ausgewaehlten Zeile als `_priority` gekennzeichnet; die TSV-Struktur bleibt gleich.
Der Agent-Framework-Python-Check verwendet statt einer Ein-Element-Schleife
einen einzelnen, weiterhin vollstaendig zitierten Programmpfad. Zwei Tests
pruefen Leerzeichen im Pfad und die Ablehnung eines inkompatiblen Overrides.

Lokale Abnahme des zweiten Satzes: **34 Tests OK (1 uebersprungen)** fuer
Queue, Framework und CI-Vertraege; separat **44 native CLI-Tests OK**.
Der gezielte Health-ShellCheck ist mit ShellCheck 0.11.0 ohne Befund.
Das pruefsummengepruefte Windows-Testwerkzeug liegt nur im temporaeren
Validierungsordner; weder Setup-Installation noch System-PATH wurden geaendert.
Der Ubuntu-CI-Lauf mit seinem ShellCheck 0.9.0 und die echte macOS-Abnahme
muessen fuer den neuen Commit erneut laufen.

Die weiteren Logs zeigen **9.323 Markdownlint-Befunde** und
**29 HIGH-Trivy-Befunde**: zwoelf in unvollstaendigen Kustomize-Patches,
17 in `scripts/k8s_deployments.yaml`. Patches muessen gegen die gerenderten
Workloads bewertet werden; alte vollstaendige Deployments brauchen eine
eigene Laufzeit-/Volume-Abnahme. Keine pauschalen Scanner-Ausnahmen und
keine ungepruefte UID-/Read-only-Umstellung nur fuer einen gruenen Status.
Der globale ShellCheck und die Linkpruefung bleiben ebenfalls offen.

## Dritter Reparatursatz: Health-Wrapper und Overlay-Vertraege

Am Head `8d65f6383429a8890e32d71700b72e3ccb005fb9` sind die Agenten-Fixtures
auch auf macOS gruen. Die Health-ShellCheck- und Registry-Schritte bestehen.
Der [folgende Fehler](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40945192363/job/123698607842)
ist ein separater Exit 126: `scan_secrets.sh` startet `check_secrets.sh`
direkt, obwohl dessen Git-Dateimodus kein Ausfuehrungsrecht enthaelt.
Der Wrapper verwendet jetzt `exec bash`, ohne chmod-Massenaktion oder sudo.
Ein isolierter Test mit einem 0600-Helper prueft Erfolg, `--dry-run` und
die unveraenderte Weitergabe eines Fehlercodes. Der echte Scan wird dabei
nicht auf persoenliche Daten angewendet. Sein bisheriger informierender
Safe-Modus ist kein Ersatz fuer die weiterhin verpflichtenden Gitleaks-Scans.

Die globale `.shellcheckrc` aktiviert Source-Verfolgung mit
`external-sources=true` und `source-path=SCRIPTDIR`; sie unterdrueckt keine
Regeln. Die noch spaeter folgenden Gitleaks-Schritte in `CI` und `Repo Health`
erhalten ebenfalls vollen Verlauf, den bereits geprueften Action-Commit und
Checkout ohne gespeicherte Credentials. Keine Scan-Abschwaechung.

In den zwei oben genannten Ressourcen-Patches werden die schon aus der Basis
geerbten SecurityContexts ausdruecklich wiederholt: Non-root, UID/GID 10001,
RuntimeDefault-Seccomp, kein Privilegienanstieg, read-only Root und Drop ALL.
Die mit pruefsummengeprueftem Kustomize 5.8.3 lokal gerenderten `production`-
und `vps-cpu`-Workloads sind vor/nach dem Patch **bytegleich**. Keine Aenderung
von UID, Datenpfad, Volume, Netzwerk oder Laufzeitverhalten im fertigen Manifest.
Ein Offline-Vertrag gleicht die Sicherheitsfelder gegen die Basis ab.
Ein neuer Trivy-Lauf muss das Ergebnis bestaetigen; lokal wurde Trivy nicht
ausgefuehrt. Die **17 HIGH-Befunde im alten Gesamtmanifest bleiben offen**.

Lokale Abnahme: **57 Tests OK (7 uebersprungen)** in fuenf betroffenen Modulen;
der geaenderte Secret-Wrapper besteht ShellCheck 0.11.0. Die uebersprungenen
Tests sind keine Linux-/Cluster-Abnahme. Globale Shell-/Formatierungsfehler
werden durch diese Teilabnahme nicht als geloest ausgegeben.
Eine zusaetzliche lokale ShellCheck-Gesamtanalyse ueber 2.175 Shell-Dateien
wurde zeitlich begrenzt beendet und gilt ausdruecklich nicht als bestanden.
Die globalen CI-Pruefungen bleiben unveraendert verpflichtend.

Der [neue PR-Linkcheck](https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation/actions/runs/40945192988)
ist inzwischen ebenfalls fehlgeschlagen: darunter echte 404-Links,
Platzhalter-Repositories, nicht erreichbare lokale Beispielports sowie
202-/403-/503-Antworten und Timeouts. Diese Klassen duerfen nicht pauschal
als gueltige Links freigegeben werden. Alte Quellen bleiben erhalten;
Ersatz-URLs muessen einzeln geprueft werden. Mehr Warten behebt abgeschlossene
rote Laeufe nicht. Push-/PR-Doppelanzeigen sind keine unabhaengigen Fehler.

## Vierter Reparatursatz: freigegebene Archivierung des Altmanifests

Der Nutzer hat ausdruecklich freigegeben, das alte Gesamtmanifest als nicht
ausfuehrbare historische Referenz zu erhalten. Der YAML-Pfad unter `scripts/`
entfaellt; der unveraenderte Quelltext liegt als Codeblock in
[der Archivdatei](../legacy/K8S_DEPLOYMENTS_LEGACY.md).
SHA-256 des normalisierten Quelltextblocks:
`5c6b694dbfbab8e43b26364054777d9d2e930eb64e3acf5dc39da19c5d4354f2`.
Der neue Test prueft diesen Hash, den entfernten YAML-Pfad und die Anzeige
in einem isolierten Verzeichnis, einschliesslich Fehler bei fehlendem Archiv.

Die Menueoperation behaelt ihren Namen, zeigt aber eine deutliche Archivwarnung
und die aktuellen Kustomize-Einstiege. README, Checklisten und lokale Auditlinks
verweisen auf die Referenz; historische Befunde und Inventardaten bleiben als
datierte Belege erhalten. Kein Scanner-Ausschluss wurde hinzugefuegt.

**Breaking Change:** Externe Skripte duerfen den alten YAML-Pfad nicht mehr
verwenden. Kein Installer und keine Operation fuehren den archivierten Code
aus. Bereits laufende Pods, Services, PVCs und Secrets bleiben unveraendert;
die Archivierung ist keine Reparatur solcher Installationen. Eine Ruecknahme
der Repo-Aenderung erfordert ein eigenes Review, keinen Cluster-Rollback.

Lokale Abnahme: **39 Tests OK**, ShellCheck der Anzeige ohne Befund.
Trivy **0.76.1** aus SHA256-geprueftem offiziellem Windows-Release meldet beim
Konfigurationsscan **0 HIGH/CRITICAL-Befunde** fuer 44 erkannte Dateien.
Es bleibt eine Abdeckungsluecke: `charts/monitoring-lite` kann ohne gepruefte
Image-Digests nicht gerendert werden; eine rohe Helm-Template-Datei wird vom
YAML-Parser abgelehnt. Der Scan-Erfolg beweist daher keine vollstaendige
Helm-/Runtime-Pruefung. Keine echten Digests oder Credentials wurden erfunden.
Der neue GitHub-Lauf muss den Stand unter Linux erneut bestaetigen.

Globale Shell-/Markdown- und Linkbefunde bleiben weiterhin offen. Die Zahl
roter Push-/PR-Checks allein erlaubt weder Merge- noch Produktionsfreigabe.

## Erste lokale Abnahme (historisch)

Lokale Abnahme dieses Reparatursatzes unter Windows mit nativem Git Bash:
156 Tests in 15 betroffenen Modulen, **OK (2 uebersprungen)**.
Der Offline-Registry-Check meldet weiterhin **0 Fehler, 802 Hinweise** bei
400 Tools, 250 Profilen und 45 Ports. `git diff --check` ist ohne Befund.
Diese erste lokale Teilabnahme allein wies noch keine volle Regression und
keine echten macOS-, Trivy-, ShellCheck- oder Gitleaks-Laeufe nach.
Die spaeteren GitHub-Belege stehen in den obigen Abschnitten.

Die hier korrigierten Vertraege lokal mit den betroffenen Testmodulen pruefen,
danach die neuen GitHub-Runs fuer den neuen Commit auswerten. Lokale Fixtures
belegen weder einen echten Gitleaks-Lauf noch eine macOS-Runner-Abnahme.
Der komplette CI-Status muss weiterhin fuer genau den vorgeschlagenen Head
geprueft werden. Alte rote Runs verschwinden durch einen Commit nicht rueckwirkend.

Bis die verbleibenden Befunde geloest und die erforderlichen Pruefungen gruen
sind: **PR nicht mergen, keine Neuinstallation, keine neuen Keys hinterlegen.**
Main und produktive Konfigurationen bleiben von diesem Reparatursatz unberuehrt.
