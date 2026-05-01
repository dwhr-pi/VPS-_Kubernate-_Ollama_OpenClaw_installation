# Inkonsistenzbericht

Dieser Bericht benennt die aktuell wichtigsten inhaltlichen und strukturellen Lücken des Repositories.

## 1. Profil-Dubletten und Überlappungen

- `Audio` und `Audio_Voice_Music` überschneiden sich stark.
- `Trading_AI`, `Trading_Crypto_Web3` und `Web3_Crypto_Agent` liegen thematisch dicht beieinander.
- `Image_Generation` und `Image_Generation_Studio` sind ähnlich, unterscheiden sich aber im Reifegrad und in der Workflow-Tiefe.
- `Video_Generation` und `Video_Generation_Studio` überlappen ebenfalls.
- `Smart_Home_Automation` und `Smart_Home_AI_Assistant` teilen große Teile der Toolbasis.

Empfehlung:
- die älteren Profile als kompakte Einstiegspfade lassen
- die `*_Studio`- und `*_Agent`-Varianten als vertiefte Spezialisierungen dokumentieren

## 2. README, Menü und Skriptwahrheit sind noch nicht vollständig identisch

- viele neue Profile und Tools existieren bereits als Skripte
- das große `setup_ultimate.sh` kennt aber nicht jede neue Profilfamilie bereits als vollwertigen Menüpfad
- `setup_ultimate_v7.sh` dient aktuell eher als ergänzendes Betriebsmenü

## 3. Registry-System ist neu, aber noch nicht die alleinige Wahrheit

- `config/tools.yml`
- `config/profiles.yml`
- `config/ports.yml`

sind jetzt als zentrale Registries vorhanden, werden aber noch nicht vollständig zur Menü-Generierung verwendet.

## 4. Nicht jeder Installer ist vollumfänglich source-only

Der Nutzerwunsch lautet bevorzugt: direkt aus GitHub beziehen und lokal bauen.

Aktueller Stand:
- ein Teil der Tools wird bereits per GitHub-Clone aufgebaut
- andere Installer nutzen aus Stabilitätsgründen `apt`, `pip`, `npm` oder Docker-Images

Das ist funktional, aber nicht überall deckungsgleich mit dem GitHub-only-Ziel.

## 5. Uninstall-Reifegrad ist unterschiedlich

- für die meisten neuen Tools gibt es echte `*_uninstall.sh`-Skripte
- einige Uninstall-Wege entfernen jedoch primär Installationspfade und Statusmarken, nicht immer jede Laufzeit- oder Datenablage

## 6. Dokumentation ist deutlich besser, aber noch im Wachstum

Verbessert:
- Profilseiten
- Matrixen
- Security- und Recovery-Doku
- LLMOps-/RAG-/Ollama-Doku

Offen bzw. weiter pflegebedürftig:
- Port- und Ressourcenangaben bei jedem einzelnen Tool
- Source-vs-Package-vs-Container-Hinweise pro Tool
- Start/Stop/Status-Kommandos für jede neue Toolfamilie
