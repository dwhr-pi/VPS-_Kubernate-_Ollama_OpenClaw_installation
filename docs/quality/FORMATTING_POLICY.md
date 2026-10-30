# Formatierung und Pruefgrenzen

Stand: 30.10.2026. Freigabe: 29.10.2026. Die repositoryweite mechanische Bereinigung und die hier beschriebenen
Markdown-Regeln wurden vom Nutzer ausdruecklich freigegeben. Sie sind keine Aenderung der
Sicherheits-, Secret- oder Linkpruefungen.

## Shell

Shell-Dateien verwenden zwei Leerzeichen, LF und eingerueckte Case-Zweige. `.editorconfig` und die
CI-Aufrufe stimmen darin ueberein. Der Formatter ist `shfmt 3.8.0`; der lokale Windows-Prueflauf
nutzt das offizielle GitHub-Artefakt mit dessen veroeffentlichter SHA256-Pruefsumme. Formatieren
startet keinen Installer und fuehrt keine Befehle aus den formatierten Dateien aus.

```bash
shfmt -d -i 2 -ci scripts install.sh setup_ultimate.sh
```

## Markdown

`.markdownlint.json` aktiviert die Standardregeln mit zwei begruendeten Anpassungen:

- Fliesstext hat maximal 120 Zeichen je Zeile. Breite Tabellen und Codebloecke sind von dieser
  **Zeilenlaengenregel** ausgenommen. Tabellen koennen nicht beliebig umgebrochen werden; Code und
  historische Quellreferenzen duerfen fuer eine optische Zeilenlaenge nicht veraendert werden.
  Andere Tabellen- und Codeblockregeln bleiben aktiv.
- Gleichlautende Ueberschriften sind unter verschiedenen Eltern erlaubt. Doppelte Ueberschriften auf
  derselben Gliederungsebene im selben Abschnitt bleiben ein Fehler. So duerfen verschiedene
  Tool-Kapitel jeweils eine Ueberschrift "Installation" besitzen.

Prettier 3.6.2 formatiert Markdown mit 100 Zeichen Zielbreite und umgebrochenem Fliesstext.
`embeddedLanguageFormatting: off` bewahrt eingebettete Codebeispiele; insbesondere wird der
SHA256-gepruefte historische YAML-Block nicht umgebaut. Markdownlint prueft das Ergebnis unabhaengig
vom Formatter.

## Eng begrenzte Datenmodul-Ausnahme

Die zehn Dateien `scripts/lang/{ar,de,en,eo,es,fr,he,ja,ru,zh}.sh` sind
Sprachkataloge. Ihre `TXT_*`-Variablen bilden eine vom Hauptmenue dynamisch
geladene Schnittstelle. Ausschliesslich dort ist SC2034 fuer scheinbar
unbenutzte Deklarationen begruendet ausgenommen; andere Regeln bleiben aktiv.
Es gibt keine globale ShellCheck-Disable-Liste.

## Abnahme

Mechanische Formatierung ersetzt keine Funktionspruefung. ShellCheck, Bash-Syntax,
Offline-Regression, Secret-Scan, Konfigurationsscan und Linkchecks bleiben aktiv. Aenderungen an
Programmlogik oder Testvertraegen brauchen einen separaten Review; sie werden nicht als reine
Formatierung ausgegeben. Kein automatisches Merge, Deployment oder Zugriff auf den Nutzworkspace.
