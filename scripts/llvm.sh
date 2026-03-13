#!/bin/bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	echo "This script should be sourced, not executed directly."
	exit 1
fi

is_macos_llvm() {
	[[ "$(uname -s)" == "Darwin" ]]
}

install_tools() {
	local VERSION="$1"

	if is_macos_llvm; then
		if ! command -v brew >/dev/null 2>&1; then
			echo "   ❌ Error: Homebrew is required on macOS"
			return 1
		fi

		local formula="llvm@${VERSION}"
		if brew info "${formula}" >/dev/null 2>&1; then
			echo "Installing LLVM via Homebrew formula ${formula}..."
			brew install "${formula}"
		else
			echo "Installing LLVM via Homebrew formula llvm..."
			brew install llvm
		fi
		return 0
	fi

	echo "Updating package lists..."
	sudo apt update >/dev/null 2>&1 || echo "   ❌ Error: Failed to update package list"

	echo "Installing Clang/LLVM toolchain version ${VERSION}..."
	sudo apt install -y \
		clang-${VERSION} \
		clang-tools-${VERSION} \
		lldb-${VERSION} \
		lld-${VERSION} \
		clang-format-${VERSION} \
		clang-tidy-${VERSION} \
		clangd-${VERSION} \
		llvm-${VERSION} \
		llvm-${VERSION}-dev \
		libllvm-${VERSION}-ocaml-dev \
		libc++-${VERSION}-dev \
		libc++abi-${VERSION}-dev >/dev/null 2>&1 || echo "   ❌ Error: Failed to install Clang/LLVM version ${VERSION}"
}

configure_tools() {
	local VERSION="$1"

	if is_macos_llvm; then
		echo "LLVM installed via Homebrew. Add it to PATH if you want it preferred over Apple Clang."
		return 0
	fi

	echo "Configuring update-alternatives for Clang/LLVM tools... ${VERSION}"
	sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${VERSION} 100
	sudo update-alternatives --set clang /usr/bin/clang-${VERSION}
	sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-${VERSION} 100
	sudo update-alternatives --set clang++ /usr/bin/clang++-${VERSION}
	sudo update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-${VERSION} 100
	sudo update-alternatives --set clang-format /usr/bin/clang-format-${VERSION}
	sudo update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-${VERSION} 100
	sudo update-alternatives --set clang-tidy /usr/bin/clang-tidy-${VERSION}

	if [ -x "/usr/bin/clangd-${VERSION}" ]; then
		sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-${VERSION} 100
		sudo update-alternatives --set clangd /usr/bin/clangd-${VERSION}
	fi
	if [ -x "/usr/bin/lldb-${VERSION}" ]; then
		sudo update-alternatives --install /usr/bin/lldb lldb /usr/bin/lldb-${VERSION} 100
		sudo update-alternatives --set lldb /usr/bin/lldb-${VERSION}
	fi
	if [ -x "/usr/bin/lldb-server-${VERSION}" ]; then
		sudo update-alternatives --install /usr/bin/lldb-server lldb-server /usr/bin/lldb-server-${VERSION} 100
		sudo update-alternatives --set lldb-server /usr/bin/lldb-server-${VERSION}
	fi
	if [ -x "/usr/bin/lld-${VERSION}" ]; then
		sudo update-alternatives --install /usr/bin/lld lld /usr/bin/lld-${VERSION} 100
		sudo update-alternatives --set lld /usr/bin/lld-${VERSION}
	fi
	if [ -x "/usr/bin/llvm-strip-${VERSION}" ]; then
		sudo update-alternatives --install /usr/bin/llvm-strip llvm-strip /usr/bin/llvm-strip-${VERSION} 100
		sudo update-alternatives --set llvm-strip /usr/bin/llvm-strip-${VERSION}
	fi
}

verify_installation() {
	local VERSION="$1"
	echo
	echo "Verifying clang installation..."
	clang --version

	echo
	echo "Verifying clang++ installation..."
	clang++ --version

	echo
	echo "Verifying clangd installation..."
	if command -v clangd >/dev/null 2>&1; then
		clangd --version
	else
		echo "clangd command not found."
	fi

	echo
	echo "LLVM/Clang version ${VERSION} installation complete!"
	echo "You can use 'update-alternatives --config clang' to switch versions on Linux."
}

setup_llvm() {
	local VERSION="${1:-20}"
	echo "Installing LLVM/Clang version: ${VERSION}"
	install_tools "${VERSION}"
	configure_tools "${VERSION}"
	verify_installation "${VERSION}"
}
