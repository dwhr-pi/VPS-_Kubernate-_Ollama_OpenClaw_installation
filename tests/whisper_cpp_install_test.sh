#!/usr/bin/env bash
set -euo pipefail
USER=whisper-test-user
repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
eval "$(sed -n '/^install_whisper_cpp() {/,$p' "$repo_dir/scripts/tools/whisper_cpp_install.sh" | sed '$d')"
log_info() { :; }
log_error() { :; }
log_success() { :; }
begin_measurement() { :; }
end_measurement() { result="$1"; }
ensure_user_workspace() { :; }
require_disk_mb() { :; }
ensure_base_apt_packages() {
    [[ "$*" == 'git build-essential cmake' ]]
    deps_ready=true
}
sudo() { :; }
clone_or_update_git_target() { :; }
cmake() {
    [[ "$deps_ready" == true ]]
    if [[ "$1" == --build ]]; then
        [[ "$*" == "--build /opt/whisper_cpp/build --config Release --parallel $expected_jobs" ]]
        return "$build_result"
    fi
    [[ "$*" == '-S /opt/whisper_cpp -B /opt/whisper_cpp/build -DCMAKE_BUILD_TYPE=Release -DGGML_CUDA=OFF' ]]
}
function /opt/whisper_cpp/build/bin/whisper-cli {
    [[ "$1" == --help ]]
    return "$smoke_result"
}
mark_tool_installed() { marked=true; }

WHISPER_CPP_BUILD_JOBS=2 expected_jobs=2 build_result=0 smoke_result=0
deps_ready=false marked=false result=''
install_whisper_cpp
[[ "$marked" == true && "$result" == success ]]
WHISPER_CPP_BUILD_JOBS=1 expected_jobs=1
install_whisper_cpp
build_result=1 marked=false result=''
if install_whisper_cpp; then echo 'FAIL: build error accepted'; exit 1; fi
[[ "$marked" == false && "$result" == failed ]]
build_result=0 smoke_result=1 marked=false
if install_whisper_cpp; then echo 'FAIL: smoke error accepted'; exit 1; fi
[[ "$marked" == false ]]
WHISPER_CPP_BUILD_JOBS='"2"'
if install_whisper_cpp; then echo 'FAIL: quoted job count accepted'; exit 1; fi
echo 'PASS: CMake dependencies, build jobs, failures and CLI smoke test checked.'
