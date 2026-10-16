# Karaoke Formats

Eigener lokaler Basis-LRC/SRT-Konverter, keine Audio-KI und kein Lyrics-Downloader.
[Anleitung und verlustbehaftete Konvertierung](../../docs/media_studio/KARAOKE_SUBTITLES_GUIDE.md).

Plan standardmaessig ohne Lesen/Schreiben. Export braucht `--apply`, ein neues
absolutes Ziel ausserhalb des Repos und bei LRC nach SRT `--last-end`.
Keine Shell-/Netzwerk-/Modellaufrufe durch den Konverter.

## Installation aus dem GitHub-Setup

Im Setup-Checkout `bash scripts/tools/karaoke_formats_install.sh` ausfuehren.
Das installiert einen privaten CLI-Starter, keine fremden Pakete oder Container.
Quelle ist genau dieser GitHub-Checkout; kein zweiter Clone und keine alte
separate Programmkopie. SHA-256 bindet den Starter an den installierten Stand.
Nach Aenderungen im Setup `bash scripts/tools/karaoke_formats_update.sh` aufrufen.
Workspace: `~/.openclaw_ultimate_user_data/tools/karaoke_formats/`.
Details zu Status, Deinstallation und Nutzung stehen im verlinkten Leitfaden.
