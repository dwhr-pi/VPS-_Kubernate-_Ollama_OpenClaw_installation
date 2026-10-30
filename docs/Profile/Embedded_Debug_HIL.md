# Embedded Debug HIL

Profilstatus: **planned** fuer den vollstaendigen Hardware-in-the-Loop-Adapter. Der zugeordnete
Tool-Baustein bietet jetzt eine **experimentelle Basisinstallation** von pygdbmi aus GitHub, ohne
Docker. Ein installiertes Basispaket ist kein funktionsfaehiger Hardware-Stack und keine Freigabe
fuer ein angeschlossenes Board.

Minimalpfad: [Offline-Reporter](../../tools/embedded_debug_hil/README.md), synthetischen Snapshot
pruefen. Optional bewusst die private pygdbmi-Basis ueber den Tool-Installer einrichten. Vollpfad:
spaeter boardbezogener GDB, OpenOCD/pyOCD und explizite Sitzungs-/Probe-/Firmwarefreigabe; nicht
automatisiert. Keine erforderlichen Ollama-/Cloud-Modelle; keine Registerdaten hochladen.

Basis: 512 MiB RAM und Disk, WSL-Hostreserve 1024 MiB, keine GPU. MiniPC/VPS/K3s koennen
Offline-Berichte erzeugen; WSL-USB und RPi-Probes brauchen eigene Tests. GPU-Workstation bringt fuer
den Parser keinen Vorteil. Keine automatischen Attach/Halt/Reset/Flash/eFuse- oder Schreibaktionen.

Details: [Installation, Grenzen und Schutz](../tools/embedded-debug-hil.md).
