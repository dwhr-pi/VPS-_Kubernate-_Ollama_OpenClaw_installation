# Signiertes Setup neu installieren: Windows, WSL und Linux

Diese Anleitung beginnt ohne vorhandenen Setup-Checkout. Sie verwendet
das [veroeffentlichte Release v11.17.0](https://github.com/dwhr-pi/OpenClaw-AI_Infrastructure-_Ultimate_Setup/releases/tag/v11.17.0).
Der oeffentliche Download wurde in WSL erfolgreich geprueft; eine
vollstaendige Fresh-Host-Installation ist damit nicht abgenommen.
Fuer einen bereits installierten Checkout gilt der
[signierte Updatepfad](SIGNED_RELEASES.md#standard-update).

## 1. Terminal und Voraussetzungen

Unter Windows das **Ubuntu-/WSL-Terminal** oeffnen, nicht PowerShell.
Auf einem Linux-VPS das normale Benutzerterminal verwenden. Das Setup
nicht als root ausfuehren. Benoetigt werden Bash, Git, Python 3, curl,
tar und Minisign. Git und curl brauchen HTTPS-Zugriff auf GitHub.

```bash
command -v bash git python3 curl tar minisign
```

Fehlende Systemwerkzeuge auf Ubuntu/Debian bewusst aus den eingerichteten
Paketquellen installieren, zum Beispiel:

```bash
sudo apt-get update &&
sudo apt-get install --no-install-recommends bash git python3 curl tar
```

Falls nur Minisign fehlt, kann der gepruefte
Bootstrap es spaeter nach Zustimmung einrichten. Dieser Schritt kann
ein Systempaket installieren, auch wenn danach nur verifiziert wird.
Kein Docker und kein `curl | bash` erforderlich.

## 2. Oeffentlichen Schluessel aus Windows uebernehmen

Die unveraenderte Datei `release.pub` vom Maintainer ueber einen
vertrauenswuerdigen Kanal beziehen. Wenn sie unter Windows in
`Dokumente\OpenClaw-Vertrauensschluessel` liegt, ist sie in WSL unter
`/mnt/c/Users/DEIN_WINDOWS_NAME/Documents/OpenClaw-Vertrauensschluessel/release.pub`
erreichbar. Den Windows-Benutzernamen einsetzen, nicht den Ubuntu-Namen.
Das `c` in `/mnt/c` ist klein.

```bash
windows_key='/mnt/c/Users/DEIN_WINDOWS_NAME/Documents/OpenClaw-Vertrauensschluessel/release.pub'
key="$HOME/.config/openclaw-trust/release.pub"

test -f "$windows_key" &&
mkdir -p "${key%/*}" &&
cp -n -- "$windows_key" "$key" &&
cmp -- "$windows_key" "$key" &&
sha256sum "$key"
```

Auf nativem Linux die separat erhaltene Datei in denselben privaten
Trust-Ordner kopieren oder `key` auf ihren absoluten Pfad setzen.
Eine bestehende Windows-/WSL-Kopie wird nicht ueberschrieben. Bei
Abweichung oder fehlender Datei hier stoppen.

Den angezeigten SHA256-Wert mit dem **unabhaengig bestaetigten** Hash
der Maintainer-Kopie vergleichen, z. B. persoenlich oder ueber einen
bereits bekannten sicheren Kanal. Die Release-Assets enthalten absichtlich
keinen Vertrauensschluessel. `release.key` und die Passphrase werden
auf dem Installationsziel nie benoetigt. Siehe
[Schluesselhandhabung](MINISIGN_KEY_HANDLING.md).

## 3. Bootstrap von GitHub beziehen und pruefen

Lass dir vom Maintainer den **vollstaendigen, bereits geprueften
Bootstrap-Commit** getrennt vom Download bestaetigen. Fuer den
Bootstrap von `v11.17.0` lautet der erwartete Wert
`8164d68fce1700fa2de4e69baf402da4878dcc13`. Diese Dokumentationsangabe
allein ersetzt die unabhaengige Bestaetigung nicht.

Die folgenden Befehle holen nur den exakten Git-Tag in einen neuen
Arbeitsordner. Es gibt keinen Checkout und keinen Installerstart.
Nur wenn Git den bestaetigten Commit meldet, werden die drei
Bootstrap-Dateien entpackt. In demselben Terminal weiterarbeiten:

```bash
tag='v11.17.0'
pin='8164d68fce1700fa2de4e69baf402da4878dcc13'
repo='https://github.com/dwhr-pi/OpenClaw-AI_Infrastructure-_Ultimate_Setup.git'
bootstrap=$(mktemp -d "$HOME/openclaw-bootstrap.XXXXXXXX")

(
  set -euo pipefail
  git -C "$bootstrap" init --quiet --template=
  git -C "$bootstrap" -c core.hooksPath=/dev/null fetch --no-tags --depth=1 \
    "$repo" "refs/tags/$tag"
  test "$(git -C "$bootstrap" rev-parse 'FETCH_HEAD^{commit}')" = "$pin"
  git -C "$bootstrap" archive "$pin" -- verify_release_and_install.sh \
    scripts/security/ensure_minisign.sh scripts/security/release_manifest.py |
    tar -xf - -C "$bootstrap"
)
```

Bei einem Fehler **nicht fortfahren**. Ein ungepruefter Download darf
sich nicht selbst als vertrauenswuerdig erklaeren. Wenn du bereits einen
unabhaengig geprueften Bootstrap samt beiden Pruefhelfern hast, kannst
du `bootstrap` direkt auf dessen Verzeichnis setzen.

## 4. Release herunterladen und nur verifizieren

```bash
bash "$bootstrap/verify_release_and_install.sh" \
  --tag "$tag" --public-key "$key" --download --verify-only
```

Der Bootstrap laedt `install.sh`, `release.json`, `SHA256SUMS` und
`SHA256SUMS.minisig` selbst von GitHub. Die Meldung **„Signatur, SHA256,
Tag und Commit geprueft. Kein Clone/Installer gestartet.“** bestaetigt
Signatur, Dateiintegritaet und signierte Metadaten. Der Git-Abgleich
mit dem Release-Tag folgt erst bei `--install`. Bei fehlenden Dateien,
falschem Schluessel oder einer fehlerhaften Signatur stoppen.

## 5. Bewusst in einen neuen Ordner installieren

Erst nach erfolgreicher Vorpruefung ausfuehren. Das Ziel muss ein
noch nicht vorhandener Ordner unter deinem Linux-Home sein:

```bash
bash "$bootstrap/verify_release_and_install.sh" \
  --tag "$tag" --public-key "$key" --download --install \
  --destination "$HOME/openclaw_ultimate_setup"
```

Dieser zweite Aufruf laedt und prueft die Dateien erneut, gleicht den
Git-Tag und die Installer-Datei gegen das signierte Release ab und
oeffnet dann das interaktive Setup. Tool-Installationen bleiben
bewusste Menueentscheidungen. Ein bestehendes Ziel nicht loeschen:
entweder den signierten Updatepfad verwenden oder fuer einen isolierten
Test eine separate Testumgebung einrichten. Ein anderer Checkout-Ordner
allein isoliert nicht die Benutzerdaten.

Spaeter den bereits eingerichteten Checkout so oeffnen:

```bash
cd "$HOME/openclaw_ultimate_setup" && bash ./setup_ultimate.sh
```
