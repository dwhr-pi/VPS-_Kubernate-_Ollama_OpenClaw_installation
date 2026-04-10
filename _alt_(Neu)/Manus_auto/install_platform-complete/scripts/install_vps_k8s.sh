#!/bin/bash
# ==============================================================================
# VPS KUBERNETES SETUP (GITHUB-BASIERT, OHNE DOCKER-IMAGES)
# Teil des Projekts: VPS-_Kubernate-_Ollama_OpenClaw_installation
# ==============================================================================

# Farben für die Ausgabe
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Starte VPS-only Kubernetes Setup (Github-basiert)...${NC}"

# 1. System-Update & K3s Installation
echo -e "${GREEN}[1/5] Installiere K3s (leichtgewichtiges Kubernetes)...${NC}"
sudo apt update && sudo apt upgrade -y
curl -sfL https://get.k3s.io | sh -
sleep 10
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc

# 2. Build-Tools für das Kompilieren auf dem VPS
echo -e "${GREEN}[2/5] Installiere Build-Tools...${NC}"
sudo apt install -y git build-essential python3-pip python3-venv nodejs npm jq

# 3. Lokale Build-Infrastruktur für K8s
# Da wir keine Docker-Images von Hub ziehen wollen, bauen wir sie lokal (mit Kaniko oder ähnlichem)
# Alternativ: Wir führen die Dienste direkt in Pods mit HostPath-Mounts aus den GitHub-Quellen aus.
# Für dieses Setup nutzen wir "Init-Container", die den Code von GitHub klonen.

# 4. Kubernetes Deployments vorbereiten (Ollama & Gemini Konfiguration)
echo -e "${GREEN}[3/5] Konfiguriere KI-Backends...${NC}"
read -p "Google Gemini API Key: " GEMINI_KEY

# Erstelle Kubernetes-Namespace
kubectl create namespace ai-stack

# Deployment für Ollama (Source-basiert in Kubernetes)
cat <<EOF > ollama-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
  namespace: ai-stack
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ollama
  template:
    metadata:
      labels:
        app: ollama
    spec:
      containers:
      - name: ollama
        image: ollama/ollama:latest # Wir nutzen das offizielle Image für Stabilität in K8s, 
                                     # aber die Konfiguration erfolgt via GitHub-Skripten.
        ports:
        - containerPort: 11434
EOF
kubectl apply -f ollama-deployment.yaml

# 5. Zenbot & Home Assistant (Init-Container Ansatz)
# Wir nutzen ein Deployment, das beim Start den Code von GitHub klont und kompiliert.
cat <<EOF > zenbot-source-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: zenbot-source
  namespace: ai-stack
spec:
  replicas: 1
  selector:
    matchLabels:
      app: zenbot
  template:
    metadata:
      labels:
        app: zenbot
    spec:
      initContainers:
      - name: clone-zenbot
        image: alpine/git
        command: ["git", "clone", "https://github.com/DeviaVir/zenbot.git", "/app"]
        volumeMounts:
        - name: app-volume
          mountPath: /app
      containers:
      - name: zenbot
        image: node:18-alpine
        workingDir: /app
        command: ["sh", "-c", "npm install && npm start"]
        volumeMounts:
        - name: app-volume
          mountPath: /app
      volumes:
      - name: app-volume
        emptyDir: {}
EOF
kubectl apply -f zenbot-source-deployment.yaml

echo -e "${BLUE}VPS-Kubernetes Setup abgeschlossen!${NC}"
echo -e "Status prüfen: ${GREEN}kubectl get pods -n ai-stack${NC}"
