# Installations-Labor unter normalem Linux

Optionaler Gegenpart zum [separaten WSL-Labor](WSL_INSTALL_LAB.md), Stand 05.11.2026.
Auch hier: native GitHub-Source-Builds, kein Docker, keine Browser-/Dienst-/Modellstarts.
**Implementiert, aber noch kein echter Linux-Host-/systemd-/Buildlauf abgenommen.**

## Plattform und Umfang

Erster nativer Zielvertrag: dedizierter Linux-Testhost mit systemd und Cgroup v2,
bevorzugt Ubuntu 24.04; optionale Basisabhaengigkeiten nur auf Debian/Ubuntu automatisiert.
Kein Versprechen fuer jede Linux-Distribution. Keine Vorbereitung in einer bestehenden WSL-Distro;
dafuer ausschliesslich den eigenen Windows-Starter verwenden.
Die einmaligen apt-Basisabhaengigkeiten sind ein separat freigegebener Betriebssystemschritt;
der derzeitige Testpfad pinnt nicht den gesamten Betriebssystem-Paketbestand fuer reproduzierbare Host-Images.

[linux_install_lab.py](../scripts/benchmarks/linux_install_lab.py) bietet getrennte Aktionen:
`plan`, `prepare`, `run`. Der Standard `plan` braucht keine Rootrechte und aendert nichts.
Der [gemeinsame Runner](../scripts/benchmarks/install_lab.py) und die
[Messwert-Backups](../scripts/benchmarks/install_lab_reports.py) funktionieren fuer Linux und WSL.

Der erste Adapterumfang bleibt derselbe: zehn vorhandene vollstaendige native Go-Buildvertraege.
Alle Registry-Tools erscheinen im Plan/Bericht. Fehlende Adapter, Lizenzfreigaben, RAM oder Platz
werden als Skip ausgewiesen, nicht als erfolgreiche Installation. Weitere Python-/Node-/Rust-/GUI-
Builds brauchen eigene gepruefte Lifecycle-Adapter; reine Quellenbereitstellung wird nicht aufgewertet.

## Plan ohne Installation

```bash
python3 -I -B scripts/benchmarks/linux_install_lab.py plan
```

Das prueft weder einen laufenden Dienst noch Root-, Cgroup- oder installierte User-Daten.
Die gemeinsame Freigabedatei ist unter [Lizenz-/Rezeptfreigaben](WSL_INSTALL_LAB.md#lizenzen-und-buildfreigaben)
beschrieben. Leere oder veraltete Freigaben erlauben keine Vorbereitung eines Testlaufs.

## Vorbereitung bewusst freigeben

Erst geprueften Code committen und den vollstaendigen Source-Commit sowie den absoluten
Pfad zur externen Freigabedatei festlegen. Keine Hashes oder Freigaben erfinden.
Im Folgenden sind `$SOURCE_COMMIT` und `$APPROVALS_FILE` vorher gesetzte eigene Eingaben.

```bash
sudo python3 -I -B scripts/benchmarks/linux_install_lab.py prepare \
  --source-commit "$SOURCE_COMMIT" \
  --approvals "$APPROVALS_FILE" \
  --confirm-dedicated-test-host
```

Nur falls die Basisabhaengigkeiten auf dem **dedizierten Testhost** fehlen, bei diesem einmaligen
Vorbereitungsschritt zusaetzlich `--install-base-deps` angeben. apt installiert dann Buildwerkzeuge,
nicht die Primaerprogramme. Kein automatisches Dist-Upgrade, Docker oder Dienst-Enablement.

Die Vorbereitung verweigert vorhandenen Lab-Zustand, Benutzer `oc-install-lab`, UID 20000 oder
gleichnamige Gruppe. Sie uebernimmt keine alten Konten/Verzeichnisse.
Sie legt einen neuen Benutzer ohne sudo-Zuweisung, einen rootgehoerigen Quell-Snapshot unter
`/var/lib/openclaw-install-lab/RUN-ID/repo` und dessen getrenntes Lab-Home an.
Die Identitaet wird rootgehoerig unter `/etc/openclaw-install-lab.json` gespeichert.
Das startet noch keinen Build. Bestehende Anwendungen, Konten und persoenliche Workspaces bleiben erhalten.

## Messlauf getrennt starten

```bash
sudo python3 -I -B scripts/benchmarks/linux_install_lab.py run \
  --memory-mib 4096 \
  --confirm-build-and-uninstall
```

Der einmalige Lauf erzeugt eine transiente systemd-Unit, keinen beim Boot gestarteten Dauerdaemon.
Sie laeuft als Lab-Benutzer mit 2 CPUs, konfigurierbarem hartem RAM-Limit, maximal 512 Tasks,
`NoNewPrivileges`, ohne Capabilities, mit geschuetzten Home-/Systempfaden und privatem Temp-Verzeichnis.
Nur das neue Lab-Home ist persistent beschreibbar. Downloads bleiben fuer Buildabhaengigkeiten erlaubt.
Der Runner prueft endliche Cgroup-Grenzen tatsaechlich; keine unlimitierte Ersatz-Ausfuehrung.
Bei Prozess-/Cleanup-Unklarheit werden weitere Tools nicht gestartet. Die gesamte eigene Unit
beendet auch Nachkommen, die eine neue Prozesssession geoeffnet haben.

Der Startmarker `STARTED.json` verhindert einen zweiten unbemerkten Lauf derselben Lab-Instanz.
Es gibt keinen automatischen Reset, keine Loeschung des Lab-Kontos und kein Wiederverwenden alter Testdaten.
Ein neuer sauberer Testzyklus nach Fehlern braucht zuerst administrative Pruefung oder einen frischen Testhost.
Auch dieser Pfad ersetzt fuer feindlichen/unbekannten Multi-Tenant-Code keine dedizierte VM.

Die Buildabhaengigkeiten der Testbasis werden separat bereitgestellt und bleiben erhalten.
Private pro Tool neu heruntergeladene Toolchains/Buildcaches gehoeren dagegen zum Testumfang
und werden erst nach bestaetigter Deinstallation aus dem eindeutig neuen Testverzeichnis entfernt.
Installationsfehler werden aufgezeichnet, nicht mit `|| true` als Erfolg verdeckt.

## Zeit, Plattenbedarf und portables Backup

Die vier Phasen Install/Build/Download, Doctor, Probe und Uninstall liefern Dauer und Exitcode.
Installierte Dateigroesse, Daten inklusive Buildcaches und beobachteter Spitzenbedarf werden getrennt
erfasst. Platzmangel fuehrt vor dem jeweiligen Tool zum automatischen Skip.
Die zusaetzliche Entfernung der nur fuer diesen Test angelegten Toolchains/Caches und die
Gesamtdauer des Zyklus werden separat als `cleanup_data_seconds` und `total_cycle_seconds` gesichert.
Die Vorher-/Nachher-Differenz ist keine exakte Spitzenmessung; der Spitzenwert ist eine Abtastung.
Hardware-/Netzwerk-/Cache-Unterschiede beachten und Werte nicht als universelle Mindestanforderung ausgeben.

Linux speichert die Rohmessungen im Lab-Home als `cycles.jsonl`. Nach Ende der Unit erzeugt der
Starter automatisch `measurements-backup.tar` unter `/var/lib/openclaw-install-lab/RUN-ID/`.
WSL erzeugt dieselbe Messwertsicherung automatisch im gewaehlten Windows-Lab-Ordner.
Beide enthalten nur bereinigte Messwerte und einen SHA256-Manifestnachweis, keine Buildlogs,
Quellen, `.env`, Keys oder Benutzerpfade. Eine Pruefsumme weist Beschaedigung nach, nicht die Identitaet eines fremden Absenders.
Es handelt sich nicht um einen verschluesselten Credential-Export.

## Werte ins bestehende Backup uebernehmen und wiederherstellen

Das portable TAR extern aufbewahren. Fuer die Einbindung in den normalen Workspace-Backup-Pfad
als dessen eigener Benutzer, **nicht mit sudo**, ausdruecklich importieren:

Das native Root-TAR ist zunaechst nur fuer root lesbar. Fuer den eigenen Benutzer eine neue
Kopie bereitstellen, keine bestehende Datei ueberschreiben. `$LAB_BACKUP` und
`$MEASUREMENT_BACKUP` vorher als eigene absolute Quell-/Zielpfade festlegen:

```bash
# Nur das eigene Messwert-TAR lesen; die Zieldatei erstellt der normale Benutzer.
sudo cat -- "$LAB_BACKUP" | (umask 077; set -C; cat > "$MEASUREMENT_BACKUP")
```

Danach den Import als normaler Workspace-Besitzer ausfuehren:

```bash
# Zuerst nur den Import planen; keine Eingabedatei oder Workspace wird dabei geoeffnet.
python3 -I -B scripts/benchmarks/install_lab_reports.py import \
  --input "$MEASUREMENT_BACKUP" \
  --workspace "$HOME/.openclaw_ultimate_user_data"

# Danach denselben Import bewusst ausfuehren.
python3 -I -B scripts/benchmarks/install_lab_reports.py import \
  --input "$MEASUREMENT_BACKUP" \
  --workspace "$HOME/.openclaw_ultimate_user_data" --apply
```

`$MEASUREMENT_BACKUP` ist der absolute Pfad zur eigenen TAR-Sicherung oder zu `cycles.jsonl`.
Von Windows nach normalem WSL beispielsweise den eigenen Export bewusst unter `/mnt/c/...`
auswaehlen. Der Teststarter greift dazu nicht auf die persoenliche WSL-Distribution zu.
Unter Windows entsprechend vorhandenes Python und `--workspace` mit einem bewusst gewaehlten
Windows-Pfad verwenden; kein versteckter WSL-Aufruf durch den Importer.

Der Import liest nur die zwei erwarteten TAR-Mitglieder im Speicher und prueft die Pruefsumme;
er entpackt keine beliebigen Dateipfade. Er schreibt eine neue private JSON-Datei nach
`WORKSPACE/metrics_logs/install_lab/ID.json`, ohne bestehende Messungen zu ueberschreiben.
Das vorhandene [Workspace-Backup](../scripts/operations/backup_run.sh) sichert diesen Bereich mit.
Nach Wiederherstellung des gesamten Workspace sind diese Werte ebenfalls wieder vorhanden.
Bei Totalverlust kann dasselbe portable TAR erneut importiert werden.

Wichtig: `installed_after_cycle:false` bleibt false. Der Import setzt keine Tools auf installiert,
veraendert keine `tool_status`-Datei, keine normalen Operationslogs und keine Lizenzfreigabe.
Er senkt auch nicht automatisch Speicherwaechter anhand eines einzelnen beobachteten Spitzenwerts.
Die vorhandenen [Setup-Messwerte](INSTALLATION_BENCHMARKS.md) und die Lab-Messungen bleiben nachvollziehbar getrennt.

## Abnahmegrenzen

Offline-Fixtures sind keine echte Linux-/WSL-/Build-/Uninstall-Abnahme.
Ein kleiner freigegebener Build auf dem dedizierten Zielhost muss vor einem laengeren Batch
erfolgreich durchlaufen, einschliesslich Speicher-/Abbruch-/Cleanup- und Messwert-Restore-Pruefung.
Kein Merge, keine automatische Installation und kein Produktivstart durch diese Dokumentation.
