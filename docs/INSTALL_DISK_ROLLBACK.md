# Rollback bei Speicherplatzfehlern

## Einordnung des Qwen-Protokolls

Der gezeigte Qwen-Code-Build endete erfolgreich mit Exit-Code 0 nach 5207 Sekunden. Die
anschliessenden Meldungen nennen neue Versuche, die bereits **vor dem Start** blockiert wurden. Das
sind keine fehlgeschlagenen Builds, deren Dateien man loeschen sollte. Der erfolgreiche Qwen-Build
bleibt erhalten. Viel freier Linux-Platz beweist unter WSL nicht, dass die Windows-Partition genug
Platz fuer weiteres VHDX-Wachstum hat.

## Implementierter Ablauf

Der zentrale Menuepfad prueft Speicher wie bisher vor dem Installerstart. Bei Ablehnung: nichts
gestartet, kein Rollback, keine Deinstallation. Danach verwendet er den gemeinsamen
Transaktions-Wrapper ohne Docker.

Nur fuer explizit registrierte `disk_rollback`-Tools wird ein **noch nicht vorhandenes** privates
`tools/<tool>/` angelegt und mit Token und Dateisystemidentitaet diesem Versuch zugeordnet. Bereits
vorhandene Verzeichnisse werden bei Fehlern niemals automatisch entfernt, auch nicht bei
Wiederholungen oder Updates. Ein globaler Wrapper-Lock verhindert parallele menuegesteuerte
Transaktionen; direkte Fremdinstaller umgehen ihn.

Nur bei Exit-Code ungleich 0 **und** eindeutigem Platzfehler (z. B. ENOSPC, No space left on device
oder entsprechender harter Ressourcenmeldung) wird das neu angelegte, unveraenderte Eigentumsziel
bereinigt. Eine Warnung allein, zu wenig RAM oder ein erfolgreicher Build loest keine Loeschung aus.
Token, absolute Zielbegrenzung und Inode/Geraet werden erneut geprueft. Symlinks werden hoechstens
selbst entfernt, nicht deren externe Ziele. Mountpoints, Junctions,
.env/SSH-/Wallet-/Nutzdaten-/Modellordner blockieren den automatischen Rollback. Kein sudo und kein
allgemeiner Uninstaller.

## Abdeckung und Grenzen

Erste freigegebene private Neuinstallationen: Qwen_Code, Wan21, YuE, ACE_Step_15, WhisperX, Aegisub,
Basic_Pitch, Sfizz, AIDA_X, ProPainter, Kiwi_Edit und VOID_Model. Die Registry ist die verbindliche
Liste.

ComfyUI_GGUF wird bewusst **nicht** automatisch deinstalliert: Das Plugin kann eine bestehende
ComfyUI-venv und externe custom_nodes-Verknuepfungen verwenden. Ein rekursives Loeschen seines
privaten Ordners waere kein korrekter Rueckbau dieser Aenderungen. WanVideoWrapper ist weiterhin ein
geplanter Guard. Beide bleiben nach einer Ablehnung vor Start unberuehrt.

Legacy-/opt-, apt-, Docker-, systemweite, gemeinsam genutzte venv- und Cloud-/Plugin-Installationen
werden nicht pauschal rueckgaengig gemacht. Neue Installer koennen erst nach Pruefung als
`new-private-root` registriert werden. Keine universelle Datenbank-/Paket-/Service-Transaktion wird
behauptet. Direkte Tool-Skriptaufrufe haben diesen Menue-Wrapper nicht automatisch. Bereits vor
diesem Update entstandene Reste besitzen keinen Eigentumsnachweis und werden nicht nachtraeglich
geloescht. SIGKILL/Hostabsturz braucht manuelle Pruefung; ein Journal ist keine Erlaubnis zur
spaeteren unbeaufsichtigten Loeschung.

`INSTALL_DISK_ROLLBACK=0` deaktiviert die automatische Bereinigung. Journale unter
`${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/install_transactions/` enthalten nur
Tool, Ziel, Besitznachweis und Ergebnis. Logs bleiben im bestehenden `install_logs/` erhalten. Der
urspruengliche Fehlercode bleibt ein Fehler, auch wenn das Aufraeumen gelingt. Bei vollem
Datentraeger kann die Journal-Aktualisierung scheitern; dann gilt die angezeigte Meldung.

## Quellen und Pruefung

Der Wrapper aendert keine Downloadquelle: Qwen/Wan/YuE usw. verwenden weiter ihre dokumentierten
GitHub-Pins, kein Wechsel zu Docker. Die neue Logik wurde nur mit temporaeren Testdateien und
simulierten Installern geprueft. Keine WSL-Installation, Datenbereinigung, Paketdeinstallation oder
echte Builds wurden bei der Entwicklung gestartet.
