#!/bin/bash
TOOL_NAME="Kubernetes"
TOOL_KEY="Kubernetes"
APT_PACKAGES="apt-transport-https ca-certificates curl"
TOOL_DESCRIPTION="kubectl-Client und Basisschicht für Kubernetes-nahe OpenClaw-Deployments."
TOOL_OPENCLAW_NOTE="Ergänzt das Programmierer- und VPS-Profil um echte Kubernetes-Werkzeuge."
source "$(dirname "$0")/helpers/apt_tool_common.sh"
install_apt_tool
curl -fsSL https://dl.k8s.io/release/stable.txt >/tmp/k8s_version.txt
K8S_VERSION="$(cat /tmp/k8s_version.txt)"
curl -fsSLo kubectl "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl
