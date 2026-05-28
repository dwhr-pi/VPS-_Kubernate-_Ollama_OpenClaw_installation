# myNextCloud Android

## Zweck
Android-Fork `myNextCloud Mobile` dokumentieren, bauen und sicher branden.

## Rechtlicher Hinweis
Fork based on Nextcloud. Not affiliated with or endorsed by Nextcloud GmbH.

## Aufgaben
- Upstream `https://github.com/nextcloud/android.git` dokumentieren.
- App-Name auf `myNextCloud Mobile` setzen.
- Package-Name pruefen und eigenen Namespace planen.
- Icon-/Splashscreen-Platzhalter vorbereiten.
- Standard-Server-URL via BuildConfig/Settings vorbereiten.
- QR-Code-Login spaeter optional.

## Build-Pfad
Windows 11 + WSL2 + Android Studio. Keine automatische Play-Store- oder F-Droid-Veroeffentlichung.

## Sicherheitsregeln
Keine produktiven Tokens im Build. Debug- und Release-Konfiguration trennen. Signatur-Schluessel nicht ins Repo.
