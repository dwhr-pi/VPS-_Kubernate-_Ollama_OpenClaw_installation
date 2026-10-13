# apt/dpkg ist durch automatische Updates gesperrt

Das Zotero-Protokoll vom 7. Juni 2026 zeigt `unattended-upgr` als Besitzer
von `/var/lib/dpkg/lock-frontend`. Ubuntu installiert bereits Updates;
gleichzeitige Paketinstallationen sind deshalb gesperrt.

Die Basisabhaengigkeits-Helfer und der Zotero-Installer warten jetzt bis zu
300 Sekunden auf apt/dpkg-Sperren. Danach wird mit Fehlerstatus abgebrochen.
Andere Fehler, etwa ein unbekanntes Paket, werden nicht erneut versucht.
Leere Paketlisten starten keinen unnoetigen apt-Lauf mehr.

Nach Abschluss der automatischen Updates den Installer erneut ausfuehren:

```bash
bash scripts/tools/zotero_install.sh
# Optional: Wartebudget auf 10 Minuten erhoehen
APT_LOCK_WAIT_SECONDS=600 bash scripts/tools/zotero_install.sh
```

Es werden keine Sperrdateien geloescht und keine Update-Prozesse beendet.
Die Korrektur gilt fuer die zentralen Basisabhaengigkeiten und Zotero;
andere Installer mit direkten apt-Aufrufen sind noch nicht vollstaendig migriert.
