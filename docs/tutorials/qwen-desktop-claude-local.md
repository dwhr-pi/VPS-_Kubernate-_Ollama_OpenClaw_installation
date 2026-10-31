# Qwen Desktop, Claude Code und lokale Modelle unter Windows

Stand der Quellenpruefung: **22.10.2026**. Anlass:
[Claude-Interview](claude-development-tooling.md).

## Was moeglich ist und was nicht belegt ist

**Qwen Code Desktop ist kein Claude-Code-Plugin-Host allein dadurch, dass beide Coding-Agenten
sind.** Eine vollstaendige eingebettete Claude-Code- Integration ist fuer unseren Setup-Stand nicht
nachgewiesen.

Drei Wege auseinanderhalten:

| Ziel                                             | Weg                                                                                                                 | Grenze                                                                                        |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| Quelloffener Coding-Client                       | Vorhandenes [Qwen Code](../tools/qwen-code.md) oder [Qwen Code Desktop](../tools/qwen-desktop-windows.md) verwenden | Provider-/Clientfunktionen separat pruefen; es wird dadurch nicht Claude Code                 |
| Claude-Code-Oberflaeche mit lokalem Modell       | Separat eingerichtete claude-CLI mit einem kompatiblen lokalen Server verbinden                                     | Claude-Code-Client bleibt proprietaer; kein Versprechen saemtlicher Claude-Funktionen         |
| Anthropic-Claude-Modelle in einem anderen Client | Nur dessen dokumentierte Provider-Anbindung mit bewusstem Cloud-Zugang verwenden                                    | Modellzugriff ist keine Einbettung des Claude-Code-Clients; API-Kosten und Datenfluss separat |

Die [Claude-Code-Lizenz](https://github.com/anthropics/claude-code/blob/main/LICENSE.md) und unsere
[Lizenz-/Installationsgrenze](../tools/claude-code.md) bleiben bestehen.
[Anthropic CLI ant](../tools/anthropic-cli.md) ist ein API-Client, nicht der Coding-Agent claude.
GitHub statt Docker wird nicht durch einen versteckten proprietaeren Installer umgangen.

## Bevor du den lokalen Weg ausprobierst

Vorausgesetzt sind bereits bewusst eingerichtete native Windows-Programme: Claude Code und ein
lokaler Ollama-Server mit geeignetem, vorhandenem Modell. Dieses Tutorial installiert nichts und
startet keine WSL-Distro. Qwen Desktop allein stellt keinen Ollama-Server bereit.

Arbeite zuerst in einem Wegwerf-Projekt ohne Secrets. Keine gleichzeitigen Schreibjobs von Qwen
Desktop und Claude Code auf dieselben Dateien; getrennte Branches/Arbeitskopien und gepruefte Diffs
verwenden. Dienste/Prozesse nicht automatisch beenden, wenn Ports belegt sind.

In einer separaten PowerShell kann ein bewusst ausgefuehrtes ollama list die vorhandenen Modellnamen
anzeigen. Das ist kein Modell-Pull. Ein Name mit Cloud-Routing ist nicht der gewuenschte rein lokale
Test. Passenden lokalen Namen und Kontext pruefen; die RTX 5080 mit 16 GB VRAM garantiert kein
grosses Modell mit grossem KV-Cache. Ressourcen vorab planen.

## Manueller Start mit nur temporaerer Prozesskonfiguration

Ollama dokumentiert die Variablen und den expliziten Modellstart:
[manuelle Claude-Code-Anbindung](https://docs.ollama.com/integrations/claude-code). Die folgenden
Befehle sind **Anleitung, hier nicht ausgefuehrt**. Sie starten einen Agenten und koennen nach
dessen Freigaben Dateien/Tools verwenden. Nur nach Erfuellung der Voraussetzungen im freigegebenen
Testordner ausfuehren.

```powershell
$claude = Get-Command claude -CommandType Application -ErrorAction Stop
$model = (Read-Host 'Exakter Name eines bereits vorhandenen lokalen Modells').Trim()
if ([string]::IsNullOrWhiteSpace($model)) { throw 'Modellname fehlt.' }

$names = @('ANTHROPIC_BASE_URL', 'ANTHROPIC_AUTH_TOKEN', 'ANTHROPIC_API_KEY')
$before = @{}
foreach ($name in $names) {
    $before[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
}
try {
    [Environment]::SetEnvironmentVariable('ANTHROPIC_BASE_URL', 'http://127.0.0.1:11434', 'Process')
    [Environment]::SetEnvironmentVariable('ANTHROPIC_AUTH_TOKEN', 'ollama', 'Process')
    [Environment]::SetEnvironmentVariable('ANTHROPIC_API_KEY', $null, 'Process')
    & $claude.Source --model $model
    if ($LASTEXITCODE -ne 0) { throw "Claude Code beendet mit Exit-Code $LASTEXITCODE" }
}
finally {
    foreach ($name in $names) {
        [Environment]::SetEnvironmentVariable($name, $before[$name], 'Process')
    }
}
```

Kein setx, keine Profil-/Registry-Aenderung und keine persistente Keydatei. Die gesicherten Werte
nicht ausgeben oder loggen. Der lokale Platzhalter ollama ist kein Zugriffsschutz des Servers und
kein echter Anthropic-Key.

In Claude Code mit /status Ziel und Modell kontrollieren. Client-/Projekt-/ Managed-Settings koennen
Umgebungswerte uebersteuern. Bei unerwartetem Ziel oder Login-/Providerverhalten abbrechen, nicht
testweise echte Keys an andere Hosts verteilen. Quellen:
[Claude-Gateway-Konfiguration](https://code.claude.com/docs/en/third-party-integrations). Auch bei
lokalem Modell koennen Client-Telemetrie und Tools Netzwerk verwenden; ohne gepruefte
Einstellungen/Netzwerkregeln keine Offline-Garantie.

127.0.0.1 ist hier die Adresse des lokalen Windows-Servers. Ist Ollama stattdessen nur in einer
anderen VM/WSL/auf einem MiniPC vorhanden, passt diese Annahme nicht automatisch. Keine
WSL-/Firewall-/Netzwerkaenderung ableiten.

## Protokoll und Funktionsumfang testen

Die [Ollama-Anthropic-Schnittstelle](https://docs.ollama.com/api/anthropic-compatibility) bietet nur
einen Teil der API. Eine OpenAI-kompatible /v1/chat/completions- URL allein genuegt fuer diesen Weg
nicht. ANTHROPIC_BASE_URL bezeichnet die Basis; /v1/messages nicht zusaetzlich als Basis-Pfad
anhaengen.

Fuer einen kleinen Testauftrag zuerst nur eine Datei lesen lassen, dann eine begrenzt freigegebene
Aenderung mit Diff und echtem Testlauf pruefen. Bei fehlerhaften Toolaufrufen stoppen statt
Endlosschleifen oder globaler Erweiterung der Rechte. Skills, MCP, Hooks und Subagenten jeweils
separat pruefen; clientseitige Verfuegbarkeit beweist keine Modellzuverlaessigkeit. Mehr Kontext
kostet RAM/VRAM, ein Alias verbessert weder Modellqualitaet noch Kontextkapazitaet.

Das Interview-Alias qwen3-coder -> claude-3-5-sonnet ist fuer Clients mit festen Modellnamen
gedacht, aber beim expliziten --model nicht generell erforderlich. Ein Alias macht aus Qwen kein
Anthropic-Modell.

## LiteLLM nur bei echtem Routingbedarf

[LiteLLM](https://github.com/BerriAI/litellm) kann als zusaetzlicher Proxy dienen; hier keine neue
Installation oder Dienstkonfiguration.
[Anleitung fuer andere Modelle](https://docs.litellm.ai/docs/tutorials/claude_non_anthropic_models).
Fuer den Client einen geprueften erreichbaren Host wie 127.0.0.1 verwenden, nicht 0.0.0.0: Das ist
eine Bind-Adresse, keine passende Zielvorgabe.

Proxy-Key, Provider-Key und lokaler Ollama-Platzhalter sind verschiedene Zugangsdaten. Nicht den
echten Anthropic-Key als bequemen Proxy-Key verwenden. Nur freigegebene Modelle anbieten,
Cloud-Fallbacks und Logging pruefen. Modellpicker und Kontext-/Compaction-Einstellungen sind
versionsabhaengig; nicht ungeprueft Namen umetikettieren oder ein Kontextfenster erfinden.

Fuer einen einzelnen lokalen Server ist die direkte Anbindung einfacher zu untersuchen. Ein Gateway
kann Verwaltung bieten, fuegt aber weitere Fehler-, Datenschutz- und Betriebspunkte hinzu.

## Rueckweg und Erfolgskriterien

Nach Beenden stellt finally die drei Prozessvariablen wieder her. Vom Agenten angelegte
Projektdateien oder Einstellungen werden dadurch nicht rueckgaengig gemacht. Diffs vor einer
Uebernahme pruefen. Ein Browserfenster, Start ohne Fehlermeldung oder vorhandener Ordner ist kein
vollstaendiger Funktionstest.

Erfolg erst melden, wenn Zielserver/Modell stimmen, Werkzeugfreigaben funktionieren und ein
begrenzter Auftrag mit bestandenem Test und nachvollziehbarem Diff abgeschlossen wurde. Hier wurde
dieser Live-Test nicht ausgefuehrt.
