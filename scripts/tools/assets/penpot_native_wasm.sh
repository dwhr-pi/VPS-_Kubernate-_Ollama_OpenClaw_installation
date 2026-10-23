#!/usr/bin/env bash
# Use installed SDKs; never call upstream setup/setup_rust (they change global rustup state).
set -euo pipefail
checkout="${1:?Checkout required}"
prefix="${2:?Private build prefix required}"
target="${3:?frontend or export required}"
case "$target" in frontend|export) ;; *) exit 2 ;; esac
: "${PENPOT_EMSDK_ENV:?Existing Emscripten SDK required}"
: "${SKIA_BINARIES_URL:?Verified local Skia asset required}"
: "${RUSTUP_TOOLCHAIN:?Existing absolute Rust toolchain required}"
case "$SKIA_BINARIES_URL" in file://*) ;; *) echo 'Local verified Skia archive required.' >&2; exit 2 ;; esac

# emsdk_env.sh only activates the already installed SDK in this subprocess.
set +u
source "$PENPOT_EMSDK_ENV"
set -u
cd "$checkout/render-wasm"
export BUILD_MODE=release NODE_ENV=production
source ./_build_env "$target" --locked
export EM_CACHE="$prefix/_build/emscripten-cache"
if [ "$RUST_VERSION" != "1.99.0" ] || [ "$CARGO_BUILD_TARGET" != "wasm32-unknown-emscripten" ]; then
    echo 'Pinned Penpot WASM build contract changed; no SDK installation.' >&2
    exit 1
fi
command -v emcc >/dev/null
build
copy_target_artifacts
