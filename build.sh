#!/usr/bin/env bash

set -a
source config.sh
set +a

GO_TOOLCHAIN=go${BUILD_GOVER}.${BUILD_GOOS}-${BUILD_GOARCH}
if [ ! -d "$GO_TOOLCHAIN" ]; then
    echo "$GO_TOOLCHAIN not present! Downloading..."
    wget "https://go.dev/dl/${GO_TOOLCHAIN}.tar.gz"
    mkdir "${GO_TOOLCHAIN}"
    tar xvf "${GO_TOOLCHAIN}.tar.gz" -C "${GO_TOOLCHAIN}"
    rm "${GO_TOOLCHAIN}.tar.gz"
fi

echo "Setting Go toolchain paths"

export GOPATH=$(realpath "${GO_TOOLCHAIN}/gopath")
mkdir -p "${GOPATH}"
export PATH="$(realpath "${GO_TOOLCHAIN}/go/bin"):${GOPATH}/bin:${PATH}"

echo "Installing xcaddy"
go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

echo "Building Caddy"
ARGS_XCADDY=()
for module in "${CADDY_MODULES[@]}"; do
    ARGS_XCADDY+=("--with" "$module")
done

GOOS=${CADDY_GOOS} GOARCH=${CADDY_GOARCH} xcaddy build "${ARGS_XCADDY[@]}"
