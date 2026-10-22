# Welche dokumentierten Tools fehlen im Setup?

Stand: **22.10.2026**, lokaler Repository-Abgleich. **Nicht alles aus der
Dokumentation ist als installierbares Tool im Setup umgesetzt.** Die
frueheren Hinweise auf Anleitung, Quelle oder planned waren keine fertige
Integration. Das betrifft auch mehrfach gewuenschte Komponenten.

[Vollstaendiger maschineller Abgleich](TOOL_SETUP_AUDIT.md): alle Registry-
Eintraege, expliziten Menuezuordnungen, 62 Entwicklungsrezepte und erkannten
GitHub-Quellen der Markdown-Dokumentation, einschliesslich Fundstellen.

## Konkrete Luecken und unterschiedliche Integrationsgrade

| Werkzeug / Bereich | Tatsaechlicher Stand im Repository | Wo suchen / was fehlt? |
|---|---|---|
| Hermes Agent / JARVIS | Anleitung, Briefing und Skill-Vorlagen; kein eigener Hermes-Menueinstaller oder Registry-Eintrag | [Hermes-Leitfaden](tools/hermes-jarvis-weekend.md), [Dashboard-Konzept](tools/jarvis-hermes-dashboard.md); GitHub-Installer, Status und Lifecycle fehlen |
| Concat | Jetzt eigener Registry-/Menueeintrag und GitHub-AppImage-Installer mit SHA256 | [Concat](tools/concat.md); GUI, Modelle und Export separat testen |
| Gradio / Streamlit | Als Oberflaechenbausteine dokumentiert, keine eigenen Tools-Menueinstaller | [Video-Workflow](media_studio/EDITABLE_VIDEO_WORKFLOWS.md), [Gemini-Quellen](tutorials/gemini-development-tooling.md); Projektabhaengigkeit ist nicht automatisch eigenes Setup-Tool |
| HyperFrames | Jetzt eigener gepinnter Source-Build und Menue-/Registry-Eintrag | [HyperFrames](tools/hyperframes.md); Node/Bun, Buildreserve und Renderabnahme erforderlich |
| Remotion | Jetzt eigener gepinnter Source-Build, unabhaengig vom optionalen OpenMontage-Composer | [Remotion](tools/remotion.md); Lizenzfreigabe, Node/Bun und Renderabnahme getrennt |
| WanVideoWrapper / CogVideoX / LTX_Video / Video2Dataset | Menue und Registry vorhanden, Installationsaktionen zeigen auf Kandidaten-Guards | Kein echter toolbezogener Installer; Eintrag vorhanden bedeutet hier noch nicht installierbar |
| MuseTalk / LivePortrait / SadTalker / RVC / UVR5 / Audacity / OBS | Registry-Eintraege mit gemeinsamem planned-Platzhalter, keine entsprechenden expliziten Tools-Menueeintraege | Nicht betriebsbereit integriert; ein Registry-Label ersetzt keinen Installer |
| WebsiteFactory / AI-ContentMultiplier | Repository-Werkzeuge und Registry vorhanden, nicht in der expliziten Tools-Liste | [WebsiteFactory](tools/websitefactory.md), [ContentMultiplier](tools/ai-content-multiplier/README.md); Projekt-/Workflow-Einstieg von Menueintegration unterscheiden |
| Entwicklungswerkzeuge aus der 62er-Liste | Separater Katalog mit Rezepten; nicht alle als Einzelzeile der Haupt-Tools-Liste | Hauptmenue **16**, oder Hauptmenue **8** und **62 Quellen verwalten**; [Anleitung](tools/development-toolchain-check.md) |
| API-Anbieter, z. B. OpenRouter/token8341/ElevenLabs | Externe Dienste, keine lokal zu installierenden Modelle/Programme | [API-Key-Uebersicht](_API-Keys/README.md); bewusste Konfiguration statt Scheininstallation |

Die genannten Luecken werden hier **nicht** durch neue Schein-Installer oder
erfolgreich endende Platzhalter kaschiert. Ein vollstaendiger neuer Installer
braucht Quellen-/Lizenzpruefung, Ressourcenwache, isolierten Installationsweg,
ehrliche Statuspruefung, Logs, Update und sichere Deinstallation. Diese
Pruefung installiert nichts und schaltet keine bestehenden Kanaele frei.

## Warum du Eintraege nicht findest

`config/tools.yml` und die Bash-Arrays `TOOL_KEYS`/`TOOL_SCRIPT_NAMES` in
`setup_ultimate.sh` sind getrennte Listen. Das Tools-Menue liest nicht
automatisch jeden Registry-Eintrag ein. Umgekehrt gibt es Menue-Skripte ohne
passende Registry-Zuordnung. Teilweise verweist die Registry auf einen
Platzhalter, waehrend das Menue ein eigenes Skript aufruft.

Der Bericht nennt beide Pfade getrennt. Die Zahl der Registry-Platzhalter
ist deshalb **nicht** gleich der Zahl fehlender oder nicht installierter
Programme. Auch Source-only-Downloads und manuelle Windows-Downloads sind
keine vollstaendige Anwendungsinstallation.

Einige Uebersichtsabschnitte bezeichneten inzwischen erweiterte Installer
noch pauschal als planned. Die Kurztexte fuer Medien-/Audio-/HF-Werkzeuge,
Microsoft Agent Framework und Automaton wurden aktualisiert. Historische
Profil-/Kandidatentabellen sind weiterhin keine Live-Statusanzeige.

## Abgleich erneut ausfuehren

Im Repository-Verzeichnis mit einem vorhandenen Python 3.10 oder neuer:

```text
python -B scripts/audit_tool_coverage.py
python -B scripts/audit_tool_coverage.py --format json
python -B scripts/audit_tool_coverage.py --output docs/TOOL_SETUP_AUDIT.md
```

Die ersten beiden Befehle geben nur den Bericht aus. Erst `--output`
schreibt die explizit benannte Datei. Keine Paketinstallation, kein Netzwerk,
kein WSL-/Docker-/Setupstart und kein Zugriff auf private Benutzer-Statusdateien.
Die Auflistung ist ein **statischer Dateiabgleich**, kein Download-, Build-
oder GPU-Test. Nicht verlinkte Textnennungen und indirekte Quellen brauchen
weiterhin manuelle Einordnung; der Bericht weist diese Grenze aus.
