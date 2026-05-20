# Elektronik Dashboard

Das Elektronik-Dashboard ist als Darkmode-Hacker-/Engineering-Oberflaeche mit orangefarbenen Akzenten geplant. Es kann spaeter in das AI-Dashboard-Profil oder ein eigenes React/Tailwind/Three.js-Frontend einfliessen.

## Widgets

- Firmware Build Status.
- FPGA Synthese und Simulation.
- KiCad ERC/DRC/Gerber Review.
- BOM Preisvergleich und Lieferstatus.
- Temperatur, Strom, Spannung, Batterieprognose.
- Home Assistant Sensorwerte und MQTT Status.
- CI/CD Status, PR Status und letzte Fehlerlogs.
- Produktionsstatus und Testpunktabdeckung.

## Datenquellen

- `pio run` / PlatformIO Logs.
- Arduino CLI Build Logs.
- ESP-IDF CMake/Ninja Logs.
- Verilator/Yosys/OpenROAD Logs.
- KiCad ERC/DRC Reports.
- MQTT/Home Assistant.
- n8n Webhooks.
- GitHub Actions.

## Design

- Hintergrund: sehr dunkles Blau/Schwarz.
- Akzent: Orange/Amber fuer aktive Signale.
- Kritisch: Rot.
- Warnung: Gelb.
- OK: Gruen.
- Stil: Cyberpunk, Terminal, Engineering Console.

