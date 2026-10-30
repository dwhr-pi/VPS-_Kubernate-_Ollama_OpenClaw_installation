# Ollama in der Toolauswahl

Der hervorgehobene Balken ist der Cursor, kein Installationsstatus. Ollama ist der erste Eintrag und
kann deshalb beim Oeffnen hervorgehoben sein. Ein Haekchen `(*)` bedeutet dagegen: behalten oder
installieren.

Bisher konnte ein alter `Ollama`-Eintrag in der Installationsliste bestehen bleiben, obwohl der
Befehl entfernt wurde. Beim Oeffnen der Toolverwaltung gleicht das Setup diesen Eintrag jetzt ab:
Nur eine vorhandene ausfuehrbare Datei fuer `ollama` im aktuellen PATH wird erkannt. Fehlt sie,
entfernt das Setup die Markierung aus Haupt- und Legacy-Statusdatei, damit die Migration den Eintrag
nicht wiederherstellt. Andere Tool-Eintraege bleiben erhalten.

Es wird dabei weder Ollama installiert/deinstalliert noch dessen Server gestartet. Die Pruefung
beweist nur das Vorhandensein des lokalen Befehls, nicht die Funktionsfaehigkeit des Daemons.
Remote-/Container-Installationen ohne lokalen ollama-Befehl werden damit nicht als lokale CLI
erkannt.

Die Codekorrektur aendert keine WSL-Dateien durch Codex. Der neue Abgleich wird erst ausgefuehrt,
wenn der Nutzer das aktualisierte Setup startet.
