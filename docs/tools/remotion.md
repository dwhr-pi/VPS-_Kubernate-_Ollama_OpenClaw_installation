# Remotion: Videos mit React komponieren

Stand: **22.10.2026**. [GitHub](https://github.com/remotion-dev/remotion),
[offizieller Build-Leitfaden](https://www.remotion.dev/docs/contributing).

**Zweck:** Videos aus React-Komponenten, Text, Bildern, Ton und Clips programmatisch zusammensetzen.
In deinem Setup ist das eine Montage-/ Grafikebene nach Wan/LTX, kein Ersatz fuer deren generative
Modelle. Ein Coding-Agent kann Kompositionen vorbereiten, ist aber keine Pflicht.

## Eigener Tools-Menueeintrag ohne Docker

**Remotion** besitzt jetzt eigene Install-/Update-/Uninstall-/Status-/Doctor- Skripte, unabhaengig
von OpenMontage. Der Installer klont den offiziellen GitHub-Commit
`3ab34665c49279cc35820275380983068bb1bbf9` (**4.0.538**), installiert Abhaengigkeiten aus `bun.lock`
ohne Lifecycle-Skripte und baut den CLI-Abhaengigkeitsgraphen mit Turbo-Concurrency 1. Kein
`npx latest`, globaler Paket-/PATH-Umbau oder Docker.

Voraussetzungen: vorhandenes **Node >=22**, **Bun genau 1.4.3**, mindestens **4 GiB freier RAM** und
**16 GiB freier Zielspeicher**. Bei erkannter WSL- Umgebung gilt dieselbe Reserve fuer C:. Die etwa
11 GiB aus dem Nutzerlog reichen fuer diesen schweren Build nicht. Linux-freier Speicher ersetzt
nicht den freien Platz des Windows-Hostlaufwerks.

Die Bun-Vorgabe steht im gepinnten
[package.json](https://github.com/remotion-dev/remotion/blob/3ab34665c49279cc35820275380983068bb1bbf9/package.json).
Node/Bun separat aus offiziellen Quellen vorbereiten, nicht global ungefragt aktualisieren. Die
Bash-Wrapper brauchen Python >=3.10 als Steuerung, aber **kein ensurepip/venv**. Reserven sind
konservative Planung, keine Messwerte.

```bash
bash scripts/tools/remotion_install.sh --dry-run
bash scripts/tools/remotion_install.sh
bash scripts/tools/remotion_status.sh
bash scripts/tools/remotion_doctor.sh
bash scripts/tools/remotion_update.sh
bash scripts/tools/remotion_uninstall.sh
```

## Lizenztext vor Zustimmung

Remotion ist nicht pauschal MIT/Apache-Open-Source. Die
[Remotion-Lizenz](https://github.com/remotion-dev/remotion/blob/3ab34665c49279cc35820275380983068bb1bbf9/LICENSE.md)
unterscheidet freie Nutzung und Unternehmenslizenz. Eigene Nutzungsgrenzen am vollstaendigen Text
pruefen; dies ist keine Rechtsfreigabe.

Der Installer zeigt den gepinnten Lizenztext **vor Paketinstallation/Build** und fragt
`[(j)a/(N)ein]`. Bei Ablehnung werden nur die neuen Stage-Quellen entfernt. Nach bewusster
Vorabpruefung ist nichtinteraktiv moeglich:

```bash
bash scripts/tools/remotion_install.sh --accept-license
```

Der Parameter bestaetigt keinen Kauf einer gegebenenfalls noetigen Lizenz.

## Nutzung und Grenze zu OpenMontage

Privater CLI-Einstieg nach erfolgreichem Build, bewusst manuell:

```bash
node "$HOME/.openclaw_ultimate_user_data/tools/remotion/runtime/packages/cli/remotion-cli.js" --help
```

Bei eigenem `OPENCLAW_USER_DATA_DIR` den Pfad anpassen. React-Projekte ausserhalb der Runtime
anlegen und deren Paketversionen abstimmen. Browser, Codecs, native Bibliotheken und erster Render
brauchen gesonderte Abnahme.

[OpenMontage](openmontage.md) bleibt getrennt: Sein optionaler Composer verwendet den dortigen
npm-Lockstand, nicht automatisch diesen Source-Build. Keine node_modules zwischen verschiedenen
Remotion-Versionen teilen. Keine automatische Adapter-/Projektmigration.

Dependency-Hooks und Browser-Downloadhooks sind ausgeschaltet, ausgewaehlte **Upstream-Buildskripte
laufen aber als Code**. Das ist keine Sandbox oder nebenwirkungsfreie Offline-Pruefung.
GitHub/Paketregistries werden kontaktiert; Buildanforderungen koennen scheitern. Build-Home ist
getrennt und Provider- Schluessel werden nicht als Umgebungsvariablen weitergegeben.

## Nachweise und Entfernung

Marker erst nach Build-Artefakten und CLI-Syntaxpruefung: `build_ready=true`, aber
`runtime_ready=false`. Kein Browser, Studio, Film, MCP oder Cloud- Deployment wird gestartet. Der
Source-Build ist experimentell; bisher nur synthetische Offline-Tests, kein kompletter
Zielsystem-Livebuild.

Update/Repair pruefen denselben Pin. Die drei neuen Medieninstaller teilen einen Build-Lock; nach
hartem Abbruch erst auf noch laufende Prozesse pruefen. Fehler rollen nur neue
Stage-/Runtime-Dateien zurueck. Doctor/Deinstallation vergleichen das Inventar;
Aenderungen/Zusatzdateien blockieren die Entfernung. Eigene externe Projekte, Bun/Node, Modelle und
Logs bleiben erhalten.
