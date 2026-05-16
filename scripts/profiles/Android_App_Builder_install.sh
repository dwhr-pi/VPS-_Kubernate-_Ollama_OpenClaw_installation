#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"
mkdir -p "$HOME/.openclaw_ultimate_user_data/profiles/android-app-builder/projects"
echo "Android SDK/Gradle sind als geplanter Advanced-Baustein dokumentiert und werden nicht blind installiert."
mark_profile_installed "Android_App_Builder"
