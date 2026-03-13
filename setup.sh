#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./setup.sh [mode] [options]

Modes:
  dev               Bootstrap the main development environment.
  virt              Setup a virtualization environment.
  llvm [VERSION]    Setup LLVM toolchain. Defaults to version 20.
  kernel            Setup a kernel development environment.
  rust              Setup a Rust development environment.
  docker            Install and configure Docker.
  default           Run dev + rust + llvm (20).
  help              Show this message.

Examples:
  ./setup.sh
  ./setup.sh dev
  ./setup.sh dev --set-default-shell
  ./setup.sh llvm 20
EOF
}

run_default_stack() {
  setup_dev
  INSTALL_RUST_NIGHTLY="${INSTALL_RUST_NIGHTLY:-N}" setup_rust
  setup_llvm "20"
}

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

source "${SCRIPT_DIR}/scripts/dev.sh"
source "${SCRIPT_DIR}/scripts/virtualization.sh"
source "${SCRIPT_DIR}/scripts/llvm.sh"
source "${SCRIPT_DIR}/scripts/kernel.sh"
source "${SCRIPT_DIR}/scripts/rust.sh"
source "${SCRIPT_DIR}/scripts/docker.sh"

if [[ $# -eq 0 ]]; then
  run_default_stack
  exit 0
fi

MODE="$1"
shift

case "${MODE}" in
  dev)
    setup_dev "$@"
    ;;
  virt)
    setup_virtualization "$@"
    ;;
  llvm)
    setup_llvm "${1:-20}"
    ;;
  kernel)
    setup_kernel_env "$@"
    ;;
  rust)
    setup_rust "$@"
    ;;
  docker)
    setup_docker "$@"
    ;;
  default)
    run_default_stack
    ;;
  help|--help|-h)
    usage
    ;;
  *)
    printf "Error: unknown mode '%s'\n\n" "${MODE}" >&2
    usage
    exit 1
    ;;
esac
