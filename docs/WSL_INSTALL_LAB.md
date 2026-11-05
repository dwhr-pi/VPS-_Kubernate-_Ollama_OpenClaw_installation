# Installationsmessungen in einer separaten WSL-Testdistribution

Stand: 05.11.2026. Neuer optionaler Testpfad, **keine reale WSL-/Build-Abnahme bisher**.

Auch fuer [normales Linux](LINUX_INSTALL_LAB.md) gibt es einen getrennten Pfad mit begrenzter
systemd-Unit. Die Messwertsicherung und der Import ins Workspace-Backup sind fuer beide Plattformen gemeinsam.
Nicht die vorhandene persoenliche Distribution verwenden und nichts daraus exportieren.
Die Auswahl einer Testdistribution allein startet noch keine Installation.

## Was bereits implementiert ist

- Windows-Starter: [wsl_install_lab.ps1](../scripts/benchmarks/wsl_install_lab.ps1).
- Gast-Runner und reiner Offline-Plan: [install_lab.py](../scripts/benchmarks/install_lab.py).
- Leere [Lizenz-/Rezeptfreigaben](../config/install_lab_approvals.example.json): standardmaessig keine Zustimmung.
- [Offline-Fixtures](../tests/test_install_lab.py), eigene [CI](../.github/workflows/install-lab-offline.yml).

Der Plan erfasst jeden Eintrag der Tool-Registry. Die erste Ausfuehrungs-Allowlist umfasst
zehn vorhandene native Go-Vertraege: Caddy, Kubeseal, Traefik, ArgoCD CLI, Cloudflared,
cAdvisor, MinIO, Node Exporter, OpenTelemetry und Watchtower.
Das sind Build-/CLI-Pruefungen, keine Dienste, Controller, Tunnel oder Containerstarts.
Watchtower wird nur gebaut und mit `--help` geprueft; Docker wird nicht eingerichtet.
MinIO bleibt trotz optionalem Build ohne Produktionsfreigabe; Wartungshinweis im vorhandenen Installer beachten.

**Nicht alle rund 400 Tools sind schon automatisch testbar.** Andere Tools werden als
`skipped_unsupported_contract` aufgefuehrt, nicht als installiert oder erfolgreich getestet.
Insbesondere Quellensammlungen, Browser-/Loginpfade, Windows-EXE, offene native Umstellungen
und Installer ohne geeigneten sicheren Lifecycle brauchen eigene Adapter und Negativtests.
Kein Weg umgeht bestehende Source-/Build-/Besitz- oder Implementierungssperren.

## Verbindlicher Ablauf

1. Plan unter Windows, ohne WSL-Abfrage, Download oder Verzeichniserzeugung.
2. Spaeter expliziter Run: verifiziertes frisches Ubuntu-24.04-Rootfs-TAR mit unabhaengig bestaetigtem SHA256.
3. Nur neue Distribution `OpenClaw-InstallLab-NAME` und neuer lokaler Speicherordner.
4. Basisabhaengigkeiten per apt ausschliesslich innerhalb dieser neuen Distribution bereitstellen.
5. Eigenen nichtprivilegierten Lab-Benutzer anlegen; Windows-Automount/Interop und systemd fuer die Lab-Distro deaktivieren.
6. Nur diese neue Distro beenden/neustarten, damit ihre Einstellungen wirksam werden.
7. Fuer jedes Tool neu Speicher, RAM und exakte Freigabe pruefen; bei Platzmangel ueberspringen.
8. GitHub-Source-Build einschliesslich notwendiger gepruefter privater Toolchain, Doctor und freigegebenem CLI-Probe.
9. Native Deinstallation, danach nur das eindeutig diesem frischen Test gehoerende Daten-/Toolchain-Verzeichnis entfernen.
10. Messbericht nach Windows exportieren. Normale Tool-Statusdateien bleiben unberuehrt.

Primaertools kommen aus GitHub-Quellen. apt dient nur den Basis-/Build-Abhaengigkeiten.
Der bestehende separat dokumentierte offizielle Go-SDK-Bootstrap mit fester SHA256 bleibt erhalten;
ein Release-SDK ist kein vorgebautes Caddy-/Traefik-Programmpaket und keine neue pauschale Ausnahme.
Das Rootfs ist eine vorher manuell gepruefte Basisdatei, kein Download aus beliebigen Toolquellen.
Es wird nicht automatisch aus Docker oder einer persoenlichen WSL-Installation gewonnen.

Es gibt weder Docker-/Compose-Installation noch Fallback, globales WSL-Shutdown,
Default-Distro-Wechsel, Aenderung von `%USERPROFILE%/.wslconfig` oder automatisches Unregister.
Bestehende Distributionsnamen werden nur zum Kollisionsschutz gelistet; sie werden nicht gestartet.
Die Basisbereitstellung ist der einzige privilegierte Teil innerhalb der frischen Distro;
Tool-Builds laufen als Lab-Benutzer ohne sudo-Gruppe.

## Offline-Plan jetzt ansehen

Im geprueften Repository unter PowerShell, mit der bereits vorhandenen Python-Variable:

```powershell
& .\scripts\benchmarks\wsl_install_lab.ps1 -Action Plan -Python $Python
```

Alternativ direkt ohne PowerShell-Starter, mit vorhandenem Linux-/Windows-Python:

```bash
python3 -I -B scripts/benchmarks/install_lab.py plan
```

Das startet keine WSL-Distribution. Fehlendes Python wird nicht automatisch nachinstalliert.
Im Plan bezeichnet `eligible:true` nur einen vorhandenen Adapter, keine Freigabe oder bestandene Installation.

## Lizenzen und Buildfreigaben

Einmalige ausdrueckliche Freigabe pro Rezept/Quell-Pin und dessen Buildabhaengigkeiten,
danach unbeaufsichtigte Wiederverwendung nur solange der Rezept-Hash identisch bleibt.
Der Hash kommt aus dem lokalen Plan und ersetzt keine persoenliche Lizenzpruefung.
Die Primarquelle ist am Commit gebunden; Aenderungen am Rezept machen alte Freigaben ungueltig.
Der Freigabehash bindet auch die Python-/JSON-Vertraege der Installerhelfer, etwa private SDK-Pins;
deren Aenderung verlangt eine neue Freigabe. LF/CRLF-Zeilenenden werden dafuer vereinheitlicht.
Interaktive unbekannte EULAs werden nicht mit `yes |` beantwortet. Keine Kosten-, Konto-,
Cloud- oder Zahlungsbedingungen automatisch bestaetigen.

Nach der eigenen Pruefung kann beispielsweise Caddy freigegeben werden:

```powershell
$plan = & .\scripts\benchmarks\wsl_install_lab.ps1 -Action Plan -Python $Python | ConvertFrom-Json
$caddy = $plan.tools | Where-Object tool -eq 'caddy'
$approvals = @{
    caddy = @{
        recipe_sha256 = $caddy.recipe_sha256
        source_and_dependency_terms_reviewed = $true
    }
}
# Nur nach der eigenen Pruefung ausfuehren; neue externe Datei verwenden.
$approvals | ConvertTo-Json -Depth 5 | Out-File -LiteralPath $ApprovalsFile -Encoding utf8 -NoClobber
```

`$ApprovalsFile` vorher als neuen absoluten Pfad ausserhalb des Repos festlegen.
Keine Secrets in diese Freigabedatei schreiben. Ohne passende Freigaben wird keine Lab-Distro importiert.
Weitere Tools nur nach Einzelpruefung aufnehmen; kein pauschales Akzeptieren aller unbekannten Bedingungen.

## Echten Lauf spaeter ausdruecklich starten

Voraussetzungen: vorhandenes WSL2, sauberes geprueftes Rootfs ohne persoenliche Daten,
passender unabhaengiger SHA256, genuegend Windows-Speicher, Freigabedatei und ein
**reviewter Commit mit dem Lab-Code**. Uncommitteter Buildcode wird nicht in die Distro geschmuggelt.
Der Starter verwendet `git archive HEAD`; keine privaten/untracked Dateien und keine Git-Credentials.

Erst nach Setzen der eigenen Eingaben, nicht mit erfundenen Hashes oder Pfaden:

```powershell
& .\scripts\benchmarks\wsl_install_lab.ps1 `
    -Action Run -Python $Python `
    -Distribution OpenClaw-InstallLab-Builds `
    -LabDirectory $LabDirectory `
    -RootfsTar $RootfsTar -RootfsSha256 $RootfsSha256 `
    -ApprovalsFile $ApprovalsFile `
    -ConfirmNewDistribution -ConfirmBuildAndUninstall
```

Die Distribution und der Lab-Ordner muessen neu sein. Auch ein frueherer Lab-Lauf wird
nicht automatisch uebernommen oder ueberschrieben. Kein Resume einer vorhandenen persoenlichen Distro.
Ohne `$LabDirectory` liegt das neue Labor unter `%LOCALAPPDATA%/OpenClawInstallLabs/NAME`.
Bei knapper Systemplatte ein anderes geeignetes lokales Laufwerk bewusst waehlen.

## Messwerte und Speicherwaechter

Pro Tool: Status, Quell-Pin/Rezept-Hash, Install-/Build-/Download-Gesamtzeit, Doctor-/Probe-/
Uninstall-Dauer, Exitcodes, beobachteter Spitzenverbrauch und zugeordnete installierte Dateigroessen.
Der kombinierte Installationsschritt zerlegt Download/Compilerzeit noch nicht einzeln.
Der Linux-Spitzenwert wird alle 0,5 Sekunden aus dem freien Dateisystemspeicher angenaehert;
kurze Spitzen und fremde I/O sind damit nicht exakt messbar.
Installierte Baumgroesse und Daten inklusive Buildcaches werden getrennt ausgegeben.
Keine GPU-, Runtime- oder Restore-Abnahme und keine erfundenen Download-Bytezahlen.

Vor jedem Tool: Rezeptreserve plus 2048 MiB Puffer; unter Windows zusaetzlich standardmaessig
8192 MiB Hostreserve. Vor Import: Hostreserve plus 4096 MiB und TAR-Groesse.
Linux-MemAvailable muss vor Start mindestens 4096 MiB betragen.
Sinkt Linux-Restplatz unter 2048 MiB oder MemAvailable unter 512 MiB, wird der Lauf abgebrochen.
Der Windows-Starter ueberwacht auch waehrend Gastaktionen die Hostreserve.
Keine globale RAM-Konfiguration aller WSL-Distributionen wird dazu veraendert.
Speicherwachen sind **keine harte Cgroup-/RAM-/CPU-Isolation**: WSL teilt Kernel/VM-Ressourcen,
und schnelle OOM-/Disk-Spitzen bleiben ein Risiko. Persoenliche WSL-Arbeiten waehrend eines Lab-Builds vermeiden.

Berichte in Windows: `LABORDNER/cycles.jsonl`, Identitaet und Source-Archiv daneben.
Zusaetzlich erzeugt der Starter automatisch `measurements-backup.tar` mit bereinigten Messwerten
und Pruefsumme. [Import/Wiederherstellung und normales Backup](LINUX_INSTALL_LAB.md#werte-ins-bestehende-backup-uebernehmen-und-wiederherstellen).
Private Buildlogs und detaillierte Reports bleiben unter `/home/oc-install-lab/install-lab-runs/`.
`CYCLE_INCOMPLETE` kennzeichnet einen nicht ordentlich abgeschlossenen Batch.
Niemals daraus normalen Installationsstatus importieren. Nach erfolgreichem Deinstallieren ist
`installed_after_cycle:false`; bei ungeklaertem Zustand `null`, nicht ein behaupteter Erfolg.

| Status | Bedeutung |
|---|---|
| `passed_build_probe_uninstall` | Voller Build, Artefakt-Doctor, CLI-Probe und Deinstallation bestanden; keine Dienstabnahme |
| `skipped_insufficient_space` | Vor Start nicht ausreichend Platz; keine Installation |
| `skipped_insufficient_ram` | Vor Start nicht ausreichend verfuegbarer RAM |
| `skipped_license_not_approved` | Rezept-/Lizenzfreigabe fehlt oder ist veraltet |
| `skipped_unsupported_contract` | Noch kein geeigneter Testadapter; keine Scheinerfolgsmeldung |
| `failed_install`, `failed_doctor`, `failed_probe` | Kein erfolgreicher Gesamttest; nur nach bestaetigter Bereinigung weiter |
| `failed_cleanup`, `failed_process_cleanup`, `failed_supervisor` | Unklarer Zustand: weitere Builds blockiert, neue Lab-Distro gestoppt, Daten erhalten |
| `not_attempted_cleanup_blocked` | Restliche Tools wegen unbestaetigter Bereinigung nicht gestartet |

Informations-URLs werden nicht geoeffnet. Ein optionaler Doku-Link ist kein Installationsschritt.
Pflichtregistrierung/Aktivierung oder fehlende Programmbestandteile werden nicht uebersprungen
und dann als erledigt deklariert. Eine Quellensammlung ist kein vollstaendiger Build.

## Abbruch, Aufbewahrung und Grenzen

Bei Abbruch stoppt der Starter ausschliesslich die von diesem Aufruf neu angelegte Lab-Distro,
nie alle WSL-Distributionen. Logs, Source-Archiv und Lab bleiben zur Diagnose erhalten.
Nicht weiterbauen, wenn das Prozessende oder die Bereinigung unbestaetigt ist.
Innerhalb des Testlaufs werden nur neue eigene Tooldaten/Toolchains entfernt, keine alten `/opt`-
Installationen, normalen Workspaces oder globalen Pakete der persoenlichen Installation.
Die einmal bereitgestellte Testbasis und apt-Buildabhaengigkeiten bleiben erhalten.
Linux-Dateiloeschung ist kein Nachweis, dass Windows exakt denselben VHDX-Platz zurueckerhalten hat;
deshalb Windows-Speicher vor jedem Tool erneut pruefen. Kein automatisches Kompaktieren oder Loeschen der Lab-Distro.

Quellen fuer den WSL-Vertrag: [Import eines TAR](https://learn.microsoft.com/en-us/windows/wsl/use-custom-distro),
[distributionsbezogene Einstellungen](https://learn.microsoft.com/en-us/windows/wsl/wsl-config),
[WSL-Befehle](https://learn.microsoft.com/en-us/windows/wsl/basic-commands),
[VHD und Windows-/Linux-Speicher](https://learn.microsoft.com/en-us/windows/wsl/disk-space).
Das Docker-Beispiel der Microsoft-Importseite wird ausdruecklich **nicht** verwendet.

Die Offline-Tests pruefen Plan, Freigaben, Skip-/Fehlerpfade, Eigentum und gemockte Zyklen.
Ein echter Import, Compilerlauf, Zeit-/Platzmessung und Deinstallation in WSL sind noch offen.
Erst mit einem kleinen freigegebenen Tool in einer frischen Testdistribution beginnen;
danach erweitern, nicht sofort einen unbeaufsichtigten Gesamtlauf als abgenommen betrachten.
