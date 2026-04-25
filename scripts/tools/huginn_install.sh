#!/bin/bash
# ==============================================================================
# HUGINN_INSTALL.SH - Installation von Huginn
# Huginn ist ein Open-Source-Agentensystem, das Aktionen im Web automatisiert.
# ==============================================================================

# Farben
GREEN=\033[032m
BLUE=\033[034m
RED=\033[031m
YELLOW=\033[133m
NC=\033[0m

HUGINN_DIR="/opt/huginn"

echo -e "${BLUE}Starte Installation von Huginn...${NC}"

# 1. Abhängigkeiten installieren (Ruby, Bundler, MySQL/PostgreSQL Client)
echo -e "${GREEN}1/5: Installiere System-Abhängigkeiten für Huginn...${NC}"
sudo apt update
sudo apt install -y ruby-full build-essential libmysqlclient-dev # oder libpq-dev für PostgreSQL

# 2. Huginn aus GitHub klonen
if [ -d "$HUGINN_DIR" ]; then
    echo -e "${YELLOW}Huginn Verzeichnis $HUGINN_DIR existiert bereits. Aktualisiere Repository...${NC}"
    cd "$HUGINN_DIR"
    git pull
else
    echo -e "${BLUE}Klone Huginn in $HUGINN_DIR...${NC}"
    sudo mkdir -p "$HUGINN_DIR"
    sudo chown -R $USER:$USER "$HUGINN_DIR"
    git clone https://github.com/huginn/huginn.git "$HUGINN_DIR"
    cd "$HUGINN_DIR"
fi

# 3. Ruby Gems installieren mit Bundler
echo -e "${GREEN}2/5: Installiere Ruby Gems mit Bundler...${NC}"
gem install bundler
bundle install --deployment --without development test
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler: Bundler install für Huginn fehlgeschlagen.${NC}"
    exit 1
fi

# 4. Datenbank konfigurieren (Beispiel für MySQL)
echo -e "${GREEN}3/5: Konfiguriere Datenbank...${NC}"
cp .env.example .env
# Hier müsste der Benutzer die .env Datei anpassen (Datenbank-Zugangsdaten)
echo -e "${YELLOW}Bitte bearbeiten Sie die Datei $HUGINN_DIR/.env und passen Sie die Datenbank-Einstellungen an.${NC}"
read -p "Drücken Sie Enter, nachdem Sie die .env Datei bearbeitet haben..."

# 5. Datenbank initialisieren
echo -e "${GREEN}4/5: Initialisiere Datenbank...${NC}"
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake db:seed

# 6. Huginn starten (Platzhalter)
echo -e "${GREEN}5/5: Huginn Installation abgeschlossen. Starten Sie Huginn manuell oder als Service.${NC}"
echo -e "${YELLOW}Hinweis: Huginn kann mit 'RAILS_ENV=production bundle exec rails server -p 3000' gestartet werden.${NC}"

echo -e "${GREEN}Huginn Installation abgeschlossen.${NC}"
