# myNextCloud Mobile: Android Build

## Ziel
Android-Fork lokal unter Windows 11 + WSL2 + Android Studio bauen.

## Upstream

```bash
git clone https://github.com/dwhr-pi/myNexcloud-for-android.git
cd myNexcloud-for-android
git remote add upstream https://github.com/nextcloud/android.git || true
git fetch upstream --tags
```

## Branding-Aufgaben

- App-Name: `myNextCloud Mobile`
- Package/Application-ID pruefen und eigenen Namespace planen.
- Launcher-Icon und Splashscreen durch eigene Platzhalter ersetzen.
- Login-Hinweis: `Fork based on Nextcloud. Not affiliated with or endorsed by Nextcloud GmbH.`
- Standard-Server-URL per BuildConfig/Settings vorbereiten.

## Build-Hinweise

- Android Studio nutzen, keine automatische Store-Veroeffentlichung.
- Signing-Keys nicht ins Repo.
- F-Droid/Google-Play-Tauglichkeit nur dokumentieren, nicht automatisieren.

## TODO

QR-Code Login spaeter vorbereiten, aber nicht ohne Sicherheitsreview aktivieren.
