Ich habe das Setup nun tiefgreifend überarbeitet und die von Ihnen genannten Details (Modell llama3.2:1b, pnpm-Installation, gcali-Skill, Gemini-Ollama-Fallback-Routing und Multi-VPS-Support) vollständig integriert.

Die neue interaktive Plattform (complete_setup_v3.zip) bietet Ihnen nun eine hochpräzise Menüführung für verschiedene Szenarien (Hybrid, Standalone, Profile für Programmierer, Media oder KI-Forschung).

#### Wesentliche Verbesserungen in V3:
+ 1. **Modell-Fokus**: Standardmäßige Nutzung von llama3.2:1b (1,3 GB), um RAM und Speicher auf dem Letsung MiniPC und Oracle VPS zu schonen.
+ 2. **Fallback-Routing**: Saubere Trennung und automatisches Umschalten zwischen Gemini (Cloud) und Ollama (Lokal), um die Zuverlässigkeit zu erhöhen.
+ 3. **pnpm Integration**: Zwingende Nutzung von pnpm für alle OpenClaw-Builds aus den GitHub-Quellen, um Fehler bei der Installation zu vermeiden.
+ 4. **Skills**: Integration des gcali Skills für Google Kalender und Vorbereitung der OpenClaw RL Version.
+ 5. **Multi-VPS Support**: Architekturvorschläge zur Verteilung der Last (Letsung für Privacy/Lokal, Oracle VPS für 24/7 Trading/Agenten, Google Cloud für Monitoring).
+ 6. **Interaktive Menüführung**: Ein neues Hauptskript setup_ultimate_v3.sh führt Sie durch den gesamten Prozess.

**Anleitung zur Verwendung:**
+ 1. Laden Sie complete_setup_v3.zip herunter und entpacken Sie es auf Ihrem Linux-System.
+ 2. Führen Sie das Hauptskript aus:
```bash
chmod +x setup_ultimate_v3.sh
./setup_ultimate_v3.sh
```

+ 3. Wählen Sie im Menü Ihr gewünschtes Setup oder Profil aus.
+ 4. Beachten Sie den beigefügten **API_KEY_GUIDE.md** für die Einrichtung der Ports und Schlüssel.

Ich habe bei der Planung den Speicherplatz (70 GB Letsung / 24 GB RAM Oracle) genau berücksichtigt und die Last entsprechend verteilt. Viel Erfolg mit diesem umfassenden KI- und Home-Automation-System!
