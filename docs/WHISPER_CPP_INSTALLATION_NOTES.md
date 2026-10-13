# Whisper.cpp: CMake fehlt

Im Protokoll vom 6. Juni 2026 bricht `make` mit `cmake: No such file or directory`
ab. Der bisherige Installer verwendete einen Node-Projekthelfer, obwohl
Whisper.cpp ein C/C++-Projekt ist. Dabei fehlte die CMake-Abhaengigkeit.

Der Installer stellt jetzt `git`, `build-essential` und `cmake` bereit und
baut aus `https://github.com/ggml-org/whisper.cpp.git` direkt mit CMake.
Node-Pakete werden fuer diesen Build nicht angefordert. Vorher bereits
installierte Pakete werden nicht automatisch entfernt.

```bash
bash scripts/tools/whisper_cpp_install.sh
# Bei wenig RAM nur einen Build-Job verwenden:
WHISPER_CPP_BUILD_JOBS=1 bash scripts/tools/whisper_cpp_install.sh
```

Standard sind zwei Build-Jobs und CPU-Betrieb (`GGML_CUDA=OFF`). Der Installer
prueft mindestens 2 GB freien Speicher unter `/opt`; Modelle benoetigen
zusaetzlichen Platz und werden nicht automatisch heruntergeladen.
Der Smoke-Test verwendet `/opt/whisper_cpp/build/bin/whisper-cli --help`.
Eine echte Transkription erfordert ein separat bereitgestelltes Modell und Audio.

Bei erneuter Ausfuehrung wird die Quelle ueber den bestehenden Git-Helfer
aktualisiert und der vorhandene CMake-Build weiterverwendet.
