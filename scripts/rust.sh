#!/bin/bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "This script should be sourced, not executed directly."
	exit 1
fi

is_macos_rust() {
	[[ "$(uname -s)" == "Darwin" ]]
}

install_prerequisite() {
	echo "📦 Installing system dependencies..."

	if is_macos_rust; then
		if ! command -v brew >/dev/null 2>&1; then
			echo "   ❌ Error: Homebrew is required on macOS"
			return 1
		fi
		brew install pkg-config openssl cmake >/dev/null 2>&1 || echo "   ❌ Error: Failed to install macOS Rust dependencies"
	else
		sudo apt update >/dev/null 2>&1 || echo "   ❌ Error: Failed to update package list"
		sudo apt install -y build-essential curl git pkg-config libssl-dev libclang-dev cmake >/dev/null 2>&1 || echo "   ❌ Error: Failed to install dependencies"
	fi
}

install_rustup() {
	if ! command -v rustup >/dev/null 2>&1; then
		echo "📥 Installing rustup (Rust toolchain manager)..."
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y >/dev/null 2>&1 || {
			echo "   ❌ Error: Failed to install rustup"
			return 1
		}
	else
		echo "✅ rustup already installed."
	fi
}

install_rust() {
	source "$HOME/.cargo/env"

	echo "📦 Installing stable Rust toolchain and tools..."
	rustup install stable >/dev/null 2>&1 || {
		echo "   ❌ Error: Failed to install stable toolchain"
		return 1
	}
	rustup default stable >/dev/null 2>&1 || {
		echo "   ❌ Error: Failed to set stable toolchain as default"
		return 1
	}
}

install_dev_tools() {
	rustup component add clippy rustfmt rust-analyzer >/dev/null 2>&1

	local yn="${INSTALL_RUST_NIGHTLY:-}"
	if [[ -z "${yn}" ]]; then
		read -r -p "🌙 Do you want to install the nightly toolchain as well? [y/N]: " yn
	fi

	if [[ "${yn}" =~ ^[Yy]$ ]]; then
		rustup install nightly >/dev/null 2>&1
		rustup component add clippy rustfmt rust-analyzer --toolchain nightly >/dev/null 2>&1
	fi
}

verify() {
	echo "✅ Rust environment setup complete:"
	rustc --version
	cargo --version
	rustup show
	shell_name="$(basename "$SHELL")"

	echo "To reconfigure current shell, run: "
	case "$shell_name" in
	fish)
		echo 'source "$HOME/.cargo/env.fish"'
		;;
	nu)
		echo 'source "$HOME/.cargo/env.nu"'
		;;
	*)
		echo '. "$HOME/.cargo/env"   # For sh/bash/zsh/ash/dash/pdksh'
		;;
	esac
	echo "🛠️ You can now start building with Cargo!"
}

setup_rust() {
	echo "🦀 Setting up full Rust development environment..."
	install_prerequisite
	install_rustup
	install_rust
	install_dev_tools
	verify
}
