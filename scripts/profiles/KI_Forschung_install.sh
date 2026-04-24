#!/bin/bash
#
# Skript: KI_Forschung_install.sh
# Beschreibung: Dieses Skript installiert Tools und Konfigurationen, die speziell für die KI-Forschung und -Entwicklung nützlich sind.
# Es umfasst spezialisierte Bibliotheken, Frameworks und Tools für maschinelles Lernen, Deep Learning und Reinforcement Learning.
# Verwendung: Wird vom Haupt-Setup-Skript aufgerufen, wenn das KI-Forschung Profil ausgewählt wird.
#

# Farben
GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

echo -e "${BLUE}Starte Installation des KI-Forschung Profils...${NC}"

# Beispiel: Installation von OpenClaw RL (falls noch nicht geschehen)
if [ -f "$INSTALL_DIR/scripts/tools/openclaw_rl_install.sh" ]; then
    echo -e "${BLUE}Installiere OpenClaw RL als Teil des KI-Forschung Profils...${NC}"
    "$INSTALL_DIR/scripts/tools/openclaw_rl_install.sh"
else
    echo -e "${YELLOW}OpenClaw RL Installationsskript nicht gefunden. Überspringe OpenClaw RL Installation.${NC}"
fi

# Beispiel: Installation von Flowise (falls noch nicht geschehen)
if [ -f "$INSTALL_DIR/scripts/tools/flowise_install.sh" ]; then
    echo -e "${BLUE}Installiere Flowise als Teil des KI-Forschung Profils...${NC}"
    "$INSTALL_DIR/scripts/tools/flowise_install.sh"
else
    echo -e "${YELLOW}Flowise Installationsskript nicht gefunden. Überspringe Flowise Installation.${NC}"
fi

# Beispiel: Installation von LangFlow (falls noch nicht geschehen)
if [ -f "$INSTALL_DIR/scripts/tools/langflow_install.sh" ]; then
    echo -e "${BLUE}Installiere LangFlow als Teil des KI-Forschung Profils...${NC}"
    "$INSTALL_DIR/scripts/tools/langflow_install.sh"
else
    echo -e "${YELLOW}LangFlow Installationsskript nicht gefunden. Überspringe LangFlow Installation.${NC}"
fi

# Weitere KI-Forschung spezifische Tools hier hinzufügen
# z.B. Skripte für TensorFlow, PyTorch, oder spezialisierte RL-Frameworks

echo -e "${GREEN}KI-Forschung Profil Installation abgeschlossen.${NC}"
