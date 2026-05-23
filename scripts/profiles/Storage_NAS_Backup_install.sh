#!/usr/bin/env bash
set -euo pipefail
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/profile_pack_installer.sh" "Storage_NAS_Backup" "Storage NAS Backup" "restic borgbackup rclone minio"
