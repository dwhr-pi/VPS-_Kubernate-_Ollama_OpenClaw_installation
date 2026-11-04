#!/usr/bin/env bash
# CI-only source build; no release installer, Docker, global PATH or user workspace changes.
set -Eeuo pipefail
umask 077
(($# <= 1)) || exit 2
if [[ "${1:---plan}" == --plan || "${1:-}" == --dry-run ]]; then
  printf '%s\n' 'Plan: build Trivy 0.76.1 from pinned official Git sources in an ephemeral Linux CI runner.'
  exit 0
fi
[[ $# == 1 && $1 == --build && ${GITHUB_ACTIONS:-} == true && ${RUNNER_OS:-} == Linux ]] || {
  printf 'Explicit --build in an ephemeral GitHub Linux runner required.\n' >&2
  exit 2
}
[[ ${RUNNER_TEMP:-} == /* && -d $RUNNER_TEMP && ! -L $RUNNER_TEMP && -n ${GITHUB_PATH:-} ]] || exit 2
((EUID != 0)) || exit 2
for tool in git go mktemp; do command -v "$tool" >/dev/null; done
export GOTOOLCHAIN=local GOENV=off GOWORK=off CGO_ENABLED=0
[[ "$(go env GOVERSION)" == go1.27.3 ]] || {
  printf 'Reviewed Go 1.27.3 SDK required; no implicit toolchain download.\n' >&2
  exit 2
}
export GOPROXY=https://proxy.golang.org GOSUMDB=sum.golang.org
export GOMAXPROCS=2 GOMEMLIMIT=2GiB
unset GOFLAGS GOPRIVATE GONOPROXY GONOSUMDB
export GIT_TERMINAL_PROMPT=0 GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null
stage=$(mktemp -d "$RUNNER_TEMP/trivy-source.XXXXXXXX")
export GOMODCACHE="$stage/go-mod" GOCACHE="$stage/go-cache"
mkdir -m 700 "$stage/bin"
pin=e713f67f7d54decdcd9b3132c9751833dcced698
git -c core.hooksPath=/dev/null init "$stage/source"
git -C "$stage/source" remote add origin https://github.com/aquasecurity/trivy.git
git -c credential.helper= -C "$stage/source" fetch --depth=1 origin "$pin"
git -c core.hooksPath=/dev/null -C "$stage/source" checkout --detach FETCH_HEAD
[[ "$(git -C "$stage/source" rev-parse HEAD)" == "$pin" ]]
(
  cd "$stage/source"
  go mod download
  go mod verify
  git diff --exit-code -- go.mod go.sum
  go build -mod=readonly -trimpath -buildvcs=false -p=2 \
    -ldflags '-X github.com/aquasecurity/trivy/pkg/version/app.ver=0.76.1' \
    -o "$stage/bin/trivy" ./cmd/trivy
)
"$stage/bin/trivy" --version
printf '%s\n' "$stage/bin" >>"$GITHUB_PATH"
# The disposable runner owns build/cache cleanup; never recursively remove caller-supplied paths.
