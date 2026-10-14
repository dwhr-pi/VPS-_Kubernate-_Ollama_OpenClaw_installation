# Embedded Debug HIL

Offline-Prototyp und vorbereitete Integration fuer GDB/OpenOCD/pyOCD.
Keine eigene Debugger-Implementierung, kein aktiver MCP-Server und kein
automatischer Hardwarezugriff. Eigene Integrationsdateien unter der
Repository-Lizenz; Upstream-Lizenzen gesondert beachten.

```bash
python3 tools/embedded_debug_hil/hil.py plan
python3 tools/embedded_debug_hil/hil.py doctor
python3 tools/embedded_debug_hil/hil.py report tools/embedded_debug_hil/snapshot.example.json
```

Die JSON-Datei enthaelt ausschliesslich synthetische Demonstrationswerte.
Vollstaendige [Anleitung](../../docs/tools/embedded-debug-hil.md) und
[Agentenregeln](../../docs/agents/EmbeddedDebugAgent.md).
