#!/bin/bash
# ==============================================================================
# KI_Forschung_uninstall.sh - Deinstallationsskript für das KI-Forschung Profil
# ==============================================================================

GREEN=\033[0;32m
BLUE=\033[0;34m
RED=\033[0;31m
YELLOW=\033[1;33m
NC=\033[0m

echo -e "${BLUE}Deinstalliere KI-Forschung Profil...${NC}"

# Beispiel: Python Bibliotheken für Reinforcement Learning deinstallieren
# echo -e "${GREEN}Deinstalliere Python RL Bibliotheken (z.B. gym, stable-baselines3)...${NC}"
# pip uninstall -y gym stable-baselines3

# Beispiel: Ollama Modell entfernen (optional)
# echo -e "${GREEN}Entferne Ollama Modell für erweiterte Forschung (z.B. mistral:7b)...${NC}"
# ollama rm mistral:7b

echo -e "${YELLOW}Hinweis: Die Deinstallation von Profilen ist oft komplex, da Abhängigkeiten geteilt werden können.${NC}"
echo -e "${YELLOW}Bitte prüfen Sie manuell, ob alle Komponenten entfernt wurden, die nicht mehr benötigt werden.${NC}"

echo -e "${GREEN}KI-Forschung Profil Deinstallation abgeschlossen.${NC}"
