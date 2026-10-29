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

## Naechste Abnahme

Lokale Abnahme dieses Reparatursatzes unter Windows mit nativem Git Bash:
156 Tests in 15 betroffenen Modulen, **OK (2 uebersprungen)**.
Der Offline-Registry-Check meldet weiterhin **0 Fehler, 802 Hinweise** bei
400 Tools, 250 Profilen und 45 Ports. `git diff --check` ist ohne Befund.
Die komplette Regression mit ueber 2.000 Tests sowie echte macOS-, Trivy-,
ShellCheck- und Gitleaks-Laeufe sind damit nicht als bestanden nachgewiesen.

Die hier korrigierten Vertraege lokal mit den betroffenen Testmodulen pruefen,
danach die neuen GitHub-Runs fuer den neuen Commit auswerten. Lokale Fixtures
belegen weder einen echten Gitleaks-Lauf noch eine macOS-Runner-Abnahme.
Der komplette CI-Status muss weiterhin fuer genau den vorgeschlagenen Head
geprueft werden. Alte rote Runs verschwinden durch einen Commit nicht rueckwirkend.

Bis die verbleibenden Befunde geloest und die erforderlichen Pruefungen gruen
sind: **PR nicht mergen, keine Neuinstallation, keine neuen Keys hinterlegen.**
Main und produktive Konfigurationen bleiben von diesem Reparatursatz unberuehrt.
