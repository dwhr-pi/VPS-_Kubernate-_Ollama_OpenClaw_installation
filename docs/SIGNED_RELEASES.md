# Signierte Releases mit Minisign

Status: implementierter Pruefpfad, offline getestet; keine Release- oder Ubuntu-Laufzeitfreigabe.
Der Nutzer hat Minisign mit **separat bereitgestelltem oeffentlichem Schluessel** gewaehlt. Hier
wird kein echter Schluessel erzeugt, importiert, aus dem Download uebernommen oder als bereits
vorhanden ausgegeben.

## Vertrauensgrenze

Bootstrap (`verify_release_and_install.sh`) und Python-Pruefhelfer muessen aus einer unabhaengig
geprueften Kopie stammen. Ein ungepruefter Bootstrap von `main` kann seine eigene
Vertrauenswuerdigkeit nicht nachtraeglich beweisen. Minisign muss bereits separat geprueft vorhanden
sein. Falls es fehlt, kann der gepruefte Bootstrap samt
`scripts/security/ensure_minisign.sh` es unter Ubuntu/Debian nach ausdruecklicher
Zustimmung aus den eingerichteten APT-Paketquellen installieren. Dies ist eine
ausdrueckliche Paketquellen-Ausnahme fuer das Pruefwerkzeug, kein GitHub-Source-Build.
APT-Signaturpruefungen werden nicht deaktiviert; die Vertrauenswuerdigkeit der
eingerichteten Paketquellen bleibt Voraussetzung. Vorhandenes Minisign wird nur
mit `minisign -v` geprueft. Den Fingerprint des oeffentlichen Schluessels ueber einen zweiten vertrauenswuerdigen Kanal
pruefen. Private Signierschluessel gehoeren weder ins Repo noch auf Installationsziele.

Ein Release besteht aus vier Dateien:

| Datei                | Bedeutung                                                      |
| -------------------- | -------------------------------------------------------------- |
| `install.sh`         | Installer exakt aus dem ausgewaehlten Tag                      |
| `release.json`       | Schema 1, Tag, voller Commit und festes offizielles Repository |
| `SHA256SUMS`         | Genau die SHA256-Summen von Installer und Metadaten            |
| `SHA256SUMS.minisig` | Minisign-Signatur dieser Pruefsummenliste                      |

Die Pruefung arbeitet auf privaten Momentaufnahmen der Dateien. Ungueltige Signatur, falsche Summen,
doppelte JSON-Schluessel, unerlaubte Dateinamen, abweichende Tags/Repos und ein im Release
beigelegter Vertrauensschluessel fuehren zum Abbruch. Es gibt keinen unsignierten Ersatzweg bei
Fehlern. Die Release-Auswahl erfolgt ausdruecklich: kein automatischer Latest-Tag und kein
Downgrade-Schutz gegen einen bewusst gewaehlten alten signierten Tag.

## Installation

Fehlt Minisign, fragt der Bootstrap bei interaktiver Standardeingabe mit `[j/N]`.
Enter, EOF oder fehlende interaktive Eingabe erlauben keine Paketinstallation.
Die ausdrueckliche Option `--install-minisign` erlaubt diese Einrichtung ohne
zusaetzliche Ja/Nein-Frage; `sudo` kann weiterhin ein Passwort verlangen.
Auch `--verify-only --install-minisign` kann somit Systempakete installieren.
Es werden keine Schluessel erzeugt, keine Signaturen uebersprungen und keine
privaten Schluessel benoetigt. APT-Fehler brechen den Ablauf vor dem Release-Download
ab. Andere Plattformen benoetigen eine separate Minisign-Installation.
Eine echte APT-/Fresh-Host-Abnahme ist nicht Bestandteil der Offline-Tests.

Beispielbefehle, **nicht hier ausgefuehrt**. `vX.Y.Z` und Pfade ersetzen; es wird kein bereits
veroeffentlichtes signiertes Release behauptet.

```bash
bash ./verify_release_and_install.sh --tag vX.Y.Z \
  --public-key /sicher/separat/release.pub \
  --artifacts /sicher/release-artefakte --verify-only
```

Erst nach erfolgreicher Pruefung kann `--verify-only` durch
`--install --destination "$HOME/openclaw_ultimate_setup"` ersetzt werden. Installation nur als
normaler Linux-/WSL-Benutzer. Vorhandene Ziele werden nicht ersetzt. Alternativ laedt **explizites**
`--download` statt `--artifacts ABS` die vier Dateien aus dem angegebenen GitHub-Release; der
Schluessel kommt nie aus diesem Download. Download ist keine Installation.

Beim Installieren wird der Git-Tag isoliert geklont. Dessen Commit muss dem signierten Commit
entsprechen, `install.sh` muss regulaer und bytegleich sein. Anschliessend uebernimmt der vorhandene
`--verified-source`-Pfad genau diesen Checkout, ohne erneut `main` zu laden. Die Signatur bestaetigt
Herkunft und Integritaet, nicht die Fehlerfreiheit oder Unbedenklichkeit jedes Installers.

## Standard-Update

```bash
bash scripts/update_setup_only.sh --tag vX.Y.Z \
  --public-key /sicher/separat/release.pub \
  --artifacts /sicher/release-artefakte --dry-run
```

Fuer ein bewusstes Linux-Update `--dry-run` durch `--apply --fetch` ersetzen. Ohne `--fetch` wird
ausschliesslich ein bereits vorhandener lokaler Tag genutzt. Die Reihenfolge ist: Signaturpruefung,
sauberer Arbeitsstand, offizieller Origin, Transport-/Filterkonfiguration pruefen, vollstaendige
verifizierte Repo-Sicherung, erst danach Fetch, Tag-/Commitvergleich und Checkout **ohne Force**.
Lokale Aenderungen blockieren das Update. Die Sicherung bleibt bei Fehlern erhalten.
`~/.openclaw_ultimate_user_data` wird nicht geloescht oder zurueckgesetzt. Der Checkout allein ist
kein getestetes Runtime-Upgrade.

Der Menuepfad ohne Argumente benoetigt alle drei expliziten Einstellungen:

```bash
export OPENCLAW_RELEASE_TAG=vX.Y.Z
export OPENCLAW_RELEASE_ARTIFACTS=/sicher/release-artefakte
export OPENCLAW_RELEASE_PUBLIC_KEY=/sicher/separat/release.pub
```

Ohne diese Werte bricht das Update ab, statt `origin/main` zu verwenden. `check_setup_updates.sh`
fuehrt nur den lokalen Release-Plan aus; es fragt keine neuen Releases ab. Die bisherige
ausdrueckliche Main-Reparatur bleibt getrennt und verlangt ihre vorhandene
Sicherungs-/Bestaetigungslogik. `install.sh --legacy-unsigned-main` ist bewusst als unsignierter
Altpfad markiert, nicht der empfohlene Einstieg. Ein direkter Aufruf ohne Optionen ist gesperrt. Der
explizite Altpfad bietet jetzt eine [Branch-Auswahl](INSTALL_BRANCH_SELECTION.md) fuer `main`, den
Coding-Agenten-Featurebranch oder einen anderen exakten Branch. Alternativer Optionsname:
`--legacy-unsigned-branch`; optional `--branch NAME`. Dies sind keine signierten Releases. Der
signierte Tag-/Minisign-Pfad bleibt getrennt.

## Release vorbereiten: Maintainer

Nur aus einem zuvor geprueften **lokalen** Tag exportieren. Der Export liest Git lokal und signiert
oder veroeffentlicht nichts. Die folgenden Befehle sind eine Anleitung; weder Schluesselzugriff noch
Signierung wurden hier ausgefuehrt.

```bash
python3 -I -B scripts/security/prepare_release.py \
  --tag vX.Y.Z --output /sicher/neues-release-verzeichnis
minisign -Sm /sicher/neues-release-verzeichnis/SHA256SUMS \
  -s /offline/signierschluessel.key
```

Die vier Dateien erst nach manueller Gegenpruefung als Release-Assets bereitstellen.
Schluesselaustausch/-widerruf und die unabhaengige Verteilung des Public Keys bleiben
organisatorisch festzulegen. Keine automatisierte Schluesselrotation.

## Nachweis und Grenzen

`tests/test_signed_release.py` prueft Vertrag, Manipulationsabwehr, Momentaufnahme und
Backup-vor-Fetch-Reihenfolge mit gemocktem Minisign und gemockten Update-Aktionen. Das ist **kein
echter kryptografischer Signaturtest**. `tests/test_p0_safety.py` ergaenzt lokale Git-Fixtures und
PAT-/Uninstall-Tests. Eine echte Signatur-Gegenprobe und die Installation/Update-Abnahme in einer
Ubuntu-24.04-Wegwerf-VM sind noch erforderlich. Keine Netzwerk-/Cloud-Aufrufe, Installationen oder
Zugriffe auf echte Secrets waren Teil dieser Arbeit.
