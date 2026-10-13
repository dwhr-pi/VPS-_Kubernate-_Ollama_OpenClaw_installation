#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$repo_dir/scripts/lib/apt_lock_wait.sh"
sudo() {
    [[ "$1" == env && "$2" == LC_ALL=C && "$3" == apt-get && "$4" == -o ]]
    case "$scenario" in
        retry)
            if [[ "$5" == 'DPkg::Lock::Timeout=10' ]]; then
                echo 'E: Could not get lock /var/lib/dpkg/lock-frontend'; return 100
            fi
            return 0 ;;
        timeout) echo 'E: Unable to acquire the dpkg frontend lock'; return 100 ;;
        failure) echo 'E: Unable to locate package missing'; return 100 ;;
    esac
}
sleep() { SECONDS=$((SECONDS + $1)); }
# Disable Bash's real clock so slow filesystem reads cannot affect this test.
unset SECONDS
SECONDS=0 scenario=retry APT_LOCK_WAIT_SECONDS=10
run_apt_with_lock_wait install -y curl >/dev/null
[[ "$SECONDS" -eq 5 ]]
scenario=timeout APT_LOCK_WAIT_SECONDS=0
if run_apt_with_lock_wait install -y curl >/dev/null 2>&1; then
    echo 'FAIL: permanent lock accepted'; exit 1
fi
scenario=failure APT_LOCK_WAIT_SECONDS=10
SECONDS=0
if run_apt_with_lock_wait install -y missing >/dev/null 2>&1; then
    echo 'FAIL: unrelated apt failure accepted'; exit 1
fi
[[ "$SECONDS" -eq 0 ]]
APT_LOCK_WAIT_SECONDS=invalid
if run_apt_with_lock_wait update >/dev/null 2>&1; then
    echo 'FAIL: invalid timeout accepted'; exit 1
fi
echo 'PASS: lock retry, timeout and immediate non-lock failure handled.'
