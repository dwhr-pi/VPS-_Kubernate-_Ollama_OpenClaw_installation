# Minisign: Schluessel aufbewahren, verteilen und pruefen

Diese Anleitung ergaenzt den [Release-Vertrag](SIGNED_RELEASES.md).
Der oeffentliche Download von `v11.17.0` wurde in Ubuntu/WSL mit
`--download --verify-only` geprueft. Das war keine Neuinstallation.

## Welche Datei gehoert wohin?

| Datei | Umgang |
| --- | --- |
| `release.key` | Privater Signierschluessel. Verschluesselt und zugriffsbeschraenkt aufbewahren, mit einer gesicherten Offline-Kopie. Nicht in Git, Cloud-Sync, Chats oder Release-Uploads. |
| `release.pub` | Oeffentlicher Pruefschluessel. Darf bytegleich kopiert und weitergegeben werden; getrennt vom Release beziehen und unabhaengig bestaetigen. |
| `SHA256SUMS.minisig` | Oeffentliche Signatur der Pruefsummenliste. Gehoert zu den Release-Assets und ist kein Schluessel. |
| `SHA256SUMS`, `release.json`, `install.sh` | Die drei weiteren Release-Assets. Nach dem Signieren nicht mehr veraendern. |

Die Passphrase des privaten Schluessels bleibt privat. Bei vorhandenem
Schluesselpaar keine neue Datei darueberschreiben. Einen neuen Schluessel
nur bewusst auf einem vertrauenswuerdigen Signiersystem erzeugen und vor
der ersten Freigabe seinen oeffentlichen Teil sichern.

## Privaten Schluessel sichern und die Kopie pruefen

Im beschriebenen Ubuntu-/WSL-Setup liegt das Original unter
`$HOME/.openclaw-release-signing/release.key`. Bevorzugt eine Kopie auf
einem verschluesselten, nach der Sicherung getrennten Datentraeger
aufbewahren. Die Passphrase getrennt sichern. Eine lokale Windows-Kopie
ist zusaetzlich moeglich, aber **kein Offline-Backup**. Dafuer einen
zugriffsbeschraenkten, nicht synchronisierten Ordner verwenden und die
Windows-Berechtigungen am Ziel pruefen; Linux-Dateimodi allein
garantieren auf einem Windows-Laufwerk keine Zugriffsbeschraenkung.

Beispiel in Ubuntu/WSL mit GNU Coreutils; Windows-Benutzernamen anpassen.
Das kleine `c` in `/mnt/c` ist wichtig:

```bash
src="$HOME/.openclaw-release-signing/release.key"
dest='/mnt/c/Users/DEIN_WINDOWS_NAME/AppData/Local/OpenClaw-Signiersicherung'
mkdir -p "$dest" &&
cp --update=none -- "$src" "$dest/release.key" &&
cmp -- "$src" "$dest/release.key" &&
printf '%s\n' 'Sicherung vorhanden und bytegleich.'
```

Der Kopierbefehl ueberschreibt keine vorhandene Datei. Bei
`Permission denied` fuer `/mnt/C` zuerst den Pfad korrigieren, statt
Rechte zu lockern oder `sudo` zu verwenden. Ist die Ausgabe
widerspruechlich, den Vergleich separat ausfuehren:

```bash
if cmp -s -- "$src" "$dest/release.key"; then
  printf '%s\n' 'Sicherung vorhanden und bytegleich.'
else
  printf '%s\n' 'Sicherung fehlt, ist nicht lesbar oder weicht ab.'
fi
```

Die Pruefung zeigt keinen Schluesselinhalt an. Bei Abweichung nichts
ueberschreiben, bis klar ist, welches Schluesselpaar verwendet wird.

## Public Key erhalten und unabhaengig bestaetigen

1. Der Maintainer berechnet den SHA256-Wert seiner originalen `release.pub`:

   ```bash
   sha256sum "$HOME/.openclaw-release-signing/release.pub"
   ```

2. Empfaenger erhalten eine unveraenderte Kopie der Datei ueber einen
   vertrauenswuerdigen Kanal. Den vollstaendigen 64-stelligen SHA256-Wert
   ueber einen zweiten, bereits bekannten Kanal bestaetigen, zum Beispiel
   persoenlich, telefonisch oder ueber einen bekannten sicheren Chat.
3. Empfaenger berechnen den Hash ihrer Kopie. Nur bei exakter
   Uebereinstimmung verwenden. Eine Datei und eine Pruefsumme aus
   derselben ungeprueften Quelle schaffen kein Vertrauen. Der SHA256-Wert
   bezieht sich auf die exakten Dateibytes, nicht auf die Minisign-Key-ID.

Den Public Key nicht aus dem ungeprueften Release-Verzeichnis als
Vertrauensanker uebernehmen. Auch Bootstrap und Pruefhelfer muessen aus
einer unabhaengig geprueften Kopie stammen.

## Oeffentliche Datei unter Windows ablegen

Beispiel in Ubuntu/WSL: Benutzername anpassen. Ein bereits vorhandener
Zielschluessel wird nicht ueberschrieben. Die private Datei wird nicht kopiert.

```bash
src="$HOME/.openclaw-release-signing/release.pub"
dest='/mnt/c/Users/DEIN_WINDOWS_NAME/Documents/OpenClaw-Vertrauensschluessel'
mkdir -p "$dest" &&
cp -n -- "$src" "$dest/release.pub" &&
sha256sum "$src" "$dest/release.pub"
```

Beide Werte muessen gleich sein. Die Datei nicht im Editor neu speichern.
Unter PowerShell prueft `Get-FileHash -Algorithm SHA256 -LiteralPath .\release.pub`
die Datei im aktuellen Ordner. Gross- und Kleinschreibung der ausgegebenen
Hex-Zeichen aendert den Hashwert nicht. Den Windows-Ordner ausserhalb des
Repositorys halten und bei Bedarf nur die einzelne Datei weitergeben.

## Vor jeder Installation erst pruefen

Aus einem bereits geprueften Bootstrap-Checkout in Linux oder WSL:

```bash
bash ./verify_release_and_install.sh \
  --tag v11.17.0 --public-key "$HOME/.openclaw-release-signing/release.pub" \
  --download --verify-only
```

Der Beispielpfad passt zum Maintainer; Empfaenger setzen den absoluten Pfad
zu ihrer unabhaengig bestaetigten Kopie ein. `--verify-only` klont keinen
Release-Checkout und fuehrt den Installer nicht aus. Geprueft werden
Signatur, SHA256 und Metadaten; der Tag-/Checkout-Abgleich folgt im
ausdruecklich freigegebenen Installationsschritt. Siehe
[signierter Installationsweg](SIGNED_RELEASES.md#installation).

| Meldung oder Anzeige | Was tun? |
| --- | --- |
| Schluesselpfad nicht gefunden | Platzhalter durch den tatsaechlichen Pfad ersetzen. Nicht nach fremden Schluesseln suchen. |
| Schluesselordner existiert bereits | Vorhandenes Paar identifizieren; nichts loeschen oder ueberschreiben. |
| Nur zwei Source-Code-Archive sichtbar | Es fehlen die vier Release-Assets. Nicht aus den Archiven heraus die Signaturpruefung umgehen. |
| Signatur fehlt oder ist ungueltig | Abbrechen. Tag, Dateien und unabhaengig bestaetigten Public Key pruefen; kein unsignierter Fallback. |

## Rotation und Verlust

Bei einem geplanten Wechsel den neuen Public Key und seinen Hash erneut
ueber unabhaengige Kanaele bestaetigen. Den Zeitpunkt des Wechsels, die
betroffenen Release-Tags und die Gueltigkeit des alten Schluessels
dokumentieren. Alte Releases nicht stillschweigend mit neuen Dateien
ueberschreiben.

Bei vermutetem Verlust oder Kompromittierung des privaten Schluessels
Signierung stoppen und den Vorfall mit betroffenem Fingerabdruck und
Zeitraum ueber den vertrauenswuerdigen Maintainer-Kanal melden. Einen
neuen Schluessel erst nach unabhaengiger Verteilung einsetzen. Die
vorhandene Bootstrap-Pruefung hat keine automatische Widerrufsliste.
