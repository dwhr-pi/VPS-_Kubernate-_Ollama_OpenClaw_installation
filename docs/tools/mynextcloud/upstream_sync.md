# Upstream-Sync fuer myNextCloud Forks

## Server

Fork:
`https://github.com/dwhr-pi/myNextCloud-server`

Upstream:
`https://github.com/nextcloud/server`

Empfohlener Ablauf:

```bash
git remote add upstream https://github.com/nextcloud/server.git
git fetch upstream --tags
git status --short
git log --oneline --decorate --graph --max-count=20 --all
```

Nicht automatisch mergen, wenn Branding-, Lizenz- oder App-spezifische Aenderungen betroffen sind. Erst Diff pruefen, dann gezielt mergen oder rebasen.

## Android

Fork:
`https://github.com/dwhr-pi/myNexcloud-for-android`

Upstream:
`https://github.com/nextcloud/android`

Empfohlener Ablauf:

```bash
git remote add upstream https://github.com/nextcloud/android.git
git fetch upstream --tags
git status --short
git log --oneline --decorate --graph --max-count=20 --all
```

## Android Library

Referenz:
`https://github.com/nextcloud/android-library`

Die Library separat beobachten, besonders wenn Login, WebDAV, TLS, OAuth oder File Sync betroffen sind.

## Rechtlicher Hinweis

Fork based on Nextcloud. Not affiliated with or endorsed by Nextcloud GmbH.

AGPL/GPL/MIT-Lizenztexte und Copyright-Hinweise muessen erhalten bleiben.
