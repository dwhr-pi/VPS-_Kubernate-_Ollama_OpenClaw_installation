# Welche dokumentierten Tools fehlen im Setup?

Ergaenzt: [Qwen_Desktop_Study](tools/qwen-desktop-study.md), im Studien-/Browserbereich
des Tools-Menues. Quellen und optionaler Linux-/Windows-Build sind getrennt;
kein gestarteter oder produktiv abgenommener Desktop.

[Aktueller Docker-zu-GitHub-Abgleich](DOCKER_TO_GITHUB.md): native Buildrezepte
und noch offene Migrationen unterscheiden; Quellen allein sind keine Runtime.

Stand: **23.10.2026**, lokaler Repository-Abgleich. **Nicht alles aus der
Dokumentation ist als installierbares Tool im Setup umgesetzt.** Die
frueheren Hinweise auf Anleitung, Quelle oder planned waren keine fertige
Integration. Das betrifft auch mehrfach gewuenschte Komponenten.

[Vollstaendiger maschineller Abgleich](TOOL_SETUP_AUDIT.md): alle Registry-
Eintraege, expliziten Menuezuordnungen, 62 Entwicklungsrezepte und erkannten
GitHub-Quellen der Markdown-Dokumentation, einschliesslich Fundstellen.

## Konkrete Luecken und unterschiedliche Integrationsgrade

Neu: [GitHub-Ergaenzungen am Ende der Tools-Liste](tools/github-gap-tools.md).

Neu am Ende hinter A-Z: **Comet, BrowserOS, Enki_Browser, Browser_Use,
Perplexity_MCP, Perplexity_Python, Perplexity_Node, Perplexity_API_Cookbook**.
[Installationswege, Voraussetzungen und Grenzen](tools/comet-and-browser-research.md).
Comet nutzt einen manuellen Windows-Download mit Pause wie Qwen Desktop;
kein behaupteter Comet-Source-Build. Cookbook = lokale Beispiele, kein Dienst.

**BrowserOS_Study** ist als separater GitHub-Quell-/Entwicklungsweg ergaenzt,
mit ausdruecklich optionalem experimentellem Linux-Vollbuild fuer Studienzwecke
und Weiterentwicklung: [Voraussetzungen und Grenzen](tools/browseros-study.md).

Entsprechend **Enki_Browser_Study**: Studienquellen und optionaler Paketbuild
mit gesonderter Zustimmung zu gepinnten Chromium-Binaries. Kein voller Chromium-
Source-Build: [Anleitung](tools/enki-browser-study.md).
Die Gruppe wird vorerst nicht nach A-Z sortiert. Qwen Desktop besitzt jetzt
zusaetzlich einen echten nativen Linux-/Windows-Buildweg; der manuelle
Windows-Download bleibt erhalten. Weitere Quellinstallationen sind bewusst
**nicht** mit vollstaendiger Runtime-Bereitschaft gleichgesetzt.

| Werkzeug / Bereich | Tatsaechlicher Stand im Repository | Wo suchen / was fehlt? |
|---|---|---|
| Hermes Agent / JARVIS | Jetzt eigener Eintrag **Hermes_Agent_Jarvis**, gepinnte GitHub-Core-Installation mit uv/Python 3.14 | [Installation](tools/github-gap-tools.md); kein fertiges Dashboard, kein Agenten-/Dienststart; Till-Webseite ist keine separate verifizierte Jarvis-Codebasis |
| Concat | Jetzt eigener Registry-/Menueeintrag und GitHub-AppImage-Installer mit SHA256 | [Concat](tools/concat.md); GUI, Modelle und Export separat testen |
| Gradio / Streamlit | Jetzt eigene Menueeintraege mit gepinnten GitHub-Quellinstallern und Lifecycle | [Installation und Grenzen](tools/github-gap-tools.md); Python-/Frontend-Build und App-Einrichtung fehlen noch |
| HyperFrames | Jetzt eigener gepinnter Source-Build und Menue-/Registry-Eintrag | [HyperFrames](tools/hyperframes.md); Node/Bun, Buildreserve und Renderabnahme erforderlich |
| Remotion | Jetzt eigener gepinnter Source-Build, unabhaengig vom optionalen OpenMontage-Composer | [Remotion](tools/remotion.md); Lizenzfreigabe, Node/Bun und Renderabnahme getrennt |
| WanVideoWrapper / CogVideoX / LTX_Video / Video2Dataset | Kandidaten-Guards durch eigene gepinnte GitHub-Quellinstaller ersetzt, Gruppe am Listenende | [Details](tools/github-gap-tools.md); keine ComfyUI-Integration, GPU-Runtime oder Modelle installiert |
| MuseTalk / LivePortrait / SadTalker / RVC / UVR5 / Audacity / OBS | Jetzt explizite Menueeintraege und eigene gepinnte GitHub-Quellinstaller statt planned-Platzhalter | [Details](tools/github-gap-tools.md); reine Quellen, keine gebauten GUI-/GPU-Anwendungen |
| WebsiteFactory / AI-ContentMultiplier | Bestehende Workflow-Installer jetzt in der expliziten Tools-Liste angehaengt | [WebsiteFactory](tools/websitefactory.md), [ContentMultiplier](tools/ai-content-multiplier/README.md); Einrichtung ist kein Dienststart, Deinstallation standardmaessig Vorschau/Abmeldung ohne Projektloeschung |
| Entwicklungswerkzeuge aus der 62er-Liste | Separater Katalog mit Rezepten; nicht alle als Einzelzeile der Haupt-Tools-Liste | Hauptmenue **16**, oder Hauptmenue **8** und **62 Quellen verwalten**; [Anleitung](tools/development-toolchain-check.md) |
| API-Anbieter, z. B. OpenRouter/token8341/ElevenLabs | Externe Dienste, keine lokal zu installierenden Modelle/Programme | [API-Key-Uebersicht](_API-Keys/README.md); bewusste Konfiguration statt Scheininstallation |

Die verbleibenden Runtime-Luecken werden **nicht** durch neue Schein-Installer
oder erfolgreich endende Platzhalter kaschiert. Quellinstaller laden und
pruefen echte Revisionen, behaupten aber keine fertige Anwendung. Ein neuer Installer
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
