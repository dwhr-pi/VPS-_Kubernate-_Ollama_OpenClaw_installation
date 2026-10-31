# Pinokio nativ aus GitHub installieren

Stand: 16.10.2026. Pinokio ist eine Desktop-Anwendung zum Verwalten und Ausfuehren von App-Skripten.
**Kein Docker erforderlich. Unter Windows wird die Windows-App installiert, nicht eine zweite Kopie
in WSL.**

## 1. Was der Setup-Menuepunkt jetzt macht

1. Unter Tools **Pinokio** auswaehlen.
2. Die Browserfrage mit `j` bestaetigen. Der Assistent oeffnet ausschliesslich die
   [offizielle GitHub-Release-Seite v8.2.0](https://github.com/pinokiocomputer/pinokio/releases/tag/v8.2.0).
3. Unter **Assets** das passende Betriebssystem-Paket herunterladen.
4. Datei pruefen und selbst installieren. Das Setup wartet auf Enter.
5. Erst nach Abschluss Enter druecken und die Abschlussfrage beantworten. Mit Nein wird die Aktion
   als verschoben behandelt, nicht als gescheitert.

Der Assistent startet keine heruntergeladene Datei, installiert keine Modelle und aendert weder WSL
noch Docker, Firewall oder Systempakete. Eine Bestaetigung ist deine Rueckmeldung, kein technischer
Installationsnachweis. Deshalb wird Pinokio nicht automatisch in die Liste nachweislich
installierter Tools geschrieben. Status/Doctor pruefen nur die Registrierung; `installed: false`
bedeutet hier **nicht automatisch nachgewiesen**, nicht dass die Windows-App sicher fehlt.

Alternativ aus Git Bash im Setup-Verzeichnis:

```bash
bash scripts/tools/pinokio_install.sh --dry-run
bash scripts/tools/pinokio_install.sh
# Nur den Browser oeffnen, ohne Installation oder Abschlussbestaetigung:
bash scripts/tools/pinokio_install.sh --open-download
```

Ohne interaktives Terminal oeffnet install/update keinen Browser und liefert Exit-Code 3 (manuell
ausstehend). Exit 0 nach install/update bedeutet nur Benutzerbestaetigung; Exit 1 Browserfehler,
Exit 2 unbekannte/manuelle Aktion.

## 2. Windows: Datei auswaehlen und pruefen

Unter Assets heisst die Windows-Datei **Pinokio.exe**, rund 125 MiB Download. Nicht Source code,
.blockmap oder latest.yml auswaehlen. Der EXE-Name benennt keine Architektur:
Windows-ARM-Kompatibilitaet vorab upstream pruefen.

Der GitHub-Asset-Digest fuer **genau v8.2.0 / Pinokio.exe** lautet:

```text
3f94d8dc19bd09f966021e01d479c3440bb1d9237f4a4923bcd0d356e04c7246
```

In Windows PowerShell pruefen (Dateiauswahl beruecksichtigt auch einen verschobenen
Downloads-Ordner; fuehrt die EXE nicht aus):

```powershell
Add-Type -AssemblyName System.Windows.Forms
$dialog = New-Object System.Windows.Forms.OpenFileDialog
$dialog.Filter = 'Pinokio (Pinokio.exe)|Pinokio.exe'
if ($dialog.ShowDialog() -ne 'OK') { throw 'Auswahl abgebrochen' }
$file = $dialog.FileName
$expected = '3f94d8dc19bd09f966021e01d479c3440bb1d9237f4a4923bcd0d356e04c7246'
if ((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expected) {
    throw 'SHA256 abweichend: Datei nicht ausfuehren'
}
Get-AuthenticodeSignature -LiteralPath $file |
    Format-List Status, StatusMessage, SignerCertificate
```

Bei Abweichungen stoppen und Release/Datei pruefen. Ein Hash bestaetigt nur Uebereinstimmung mit dem
veroeffentlichten Asset, keine Schadsoftwarefreiheit. Eine ungueltige Signatur oder
Sicherheitswarnung nicht blind umgehen. Danach die gepruefte Datei selbst oeffnen und dem
Windows-Dialog folgen. Es wird kein eigenes Electron-Source-Build benoetigt: auch das native
Release-Paket kommt direkt aus GitHub, nicht aus Docker.

## 3. Linux und macOS

Die gleiche Release-Seite bietet .deb fuer amd64/arm64 und AppImage fuer x64/arm64 sowie
macOS-Pakete fuer Intel/Apple Silicon. Zur eigenen Architektur passendes Paket waehlen; unter Linux
zeigt `uname -m` beispielsweise `x86_64` (amd64) oder `aarch64` (arm64). Windows-Hash nicht auf
diese Pakete anwenden. Dieser Assistent installiert keine Linux-Pakete und keine macOS-App
automatisch. Ein kopfloser Oracle VPS ist kein sinnvoller Standardplatz fuer diese Desktop-GUI.

## 4. Sicher in unser KI-Setup einordnen

- Pinokio-App-Skripte koennen mit deinen Benutzerrechten Befehle ausfuehren, Pakete herunterladen
  und Dateien aendern. Eigene App-Verzeichnisse sind **keine Sandbox**. Skripte/Quelle/Version und
  erforderliche Rechte vorher lesen.
- Bestehendes Ollama/ComfyUI nicht ungeprueft doppelt installieren. Endpunkte, Ports, Laufzeit und
  Modellpfade pro App abgleichen.
- Keine Wallet-Seeds, Personalakten, SSH- oder Masterkeys in App-Verzeichnisse kopieren.
  Cloud-Aufrufe und Veroeffentlichung bleiben separate Freigaben.
- Vor grossen App-/Modell-Downloads freien Speicher auf dem tatsaechlichen Windows-Ziellaufwerk
  pruefen. Freier WSL-Speicher ist dafuer kein Ersatz. Der Desktop-Download allein sagt nichts ueber
  spaetere Modellgroessen aus.
- Nur einen schweren Build/GPU-Job gleichzeitig ausfuehren. Pinokio besitzt hier noch keine
  Integration in unsere Setup-Queue oder Ressourcenwache.
- Keine Adminoberflaechen oeffentlich freigeben. Keine automatische Autostart-, Firewall- oder
  Tailscale-Aenderung durch diesen Assistenten.

Planungswerte, **keine getesteten Upstream-Minima**:

| Zielhost             | Einordnung / Ressourcen                                                    |
| -------------------- | -------------------------------------------------------------------------- |
| MiniPC               | Desktop moeglich; 8-16 GiB RAM als Planungsreserve, Modelle separat        |
| RPi5                 | ARM64-Asset vorhanden; GUI/OS/Apps einzeln pruefen, keine GPU-Zusage       |
| Oracle VPS           | keinen Desktop standardmaessig bereitstellen; bestehende Dienste verwenden |
| Gaming PC / RTX 5080 | GPU-Apps einzeln auf CUDA/PyTorch und echte VRAM-Anforderung pruefen       |
| Dual Xeon            | CPU/RAM helfen; fehlende passende GPU nicht durch Kerne ersetzt            |
| Kubernetes           | Desktop auf Arbeitsplatz, nicht als pauschaler Cluster-Operator            |

## 5. Update, Deinstallation und offene Punkte

Update oeffnet bewusst dieselbe gepruefte Version v8.2.0; kein stilles latest. Fuer einen neuen Pin
Release-Assets, Hashes und App-Kompatibilitaet erneut pruefen. Die App kann eigene Updatefunktionen
besitzen, die dieser Assistent nicht kontrolliert. Deinstallation nativ ueber die
Betriebssystem-Appverwaltung durchfuehren; App-Daten/Modelle separat sichern. Der Uninstaller dieses
Setups loescht nichts und meldet Exit 2 fuer den notwendigen manuellen Schritt.

Offen: getestete Installation je OS/Architektur, technische App-Erkennung, automatischer
Paket-/Signaturcheck, Ressourcen- und Queue-Anbindung der einzelnen Pinokio-App-Skripte. Der
Registry-Status bleibt deshalb planned, Installationsmodus ist jetzt manual-desktop statt
documentation-first.

Quellen: [GitHub-Projekt und Script Policy](https://github.com/pinokiocomputer/pinokio),
[Release v8.2.0](https://github.com/pinokiocomputer/pinokio/releases/tag/v8.2.0),
`https://api.github.com/repos/pinokiocomputer/pinokio/releases/tags/v8.2.0` (API-Originalreferenz
fuer Asset-Metadaten; CI HTTP 403 am 31.10.2026). Die Release-Seite belegt Version und Assetliste,
nicht allein die SHA256-Digests. Die separate API-Originalreferenz bleibt deshalb erhalten; ihr
CI-Abruf war gesperrt. Vor einem echten Download muessen die vorgesehenen Integritaetspruefungen
weiterhin erfolgreich sein. Keine neue Downloadfreigabe, kein Erfolg ohne Hash-/Signaturpruefung.
