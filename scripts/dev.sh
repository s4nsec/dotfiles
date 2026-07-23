#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "This script is meant to be sourced from setup.sh."
  exit 1
fi

set -euo pipefail

DEV_SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "${DEV_SCRIPT_DIR}/.." && pwd)"
EZSH_REPO_URL="${EZSH_REPO_URL:-https://github.com/vjabrayilov/ezsh.git}"
EZSH_DIR="${EZSH_DIR:-${HOME}/.cache/dotfiles/ezsh}"
DOTFILES_BACKUP_DIR=""
DEV_SKIP_NODE=false
DEV_SKIP_NEOVIM=false
DEV_SET_DEFAULT_SHELL=false

log_section() {
  printf '\n==> %s\n' "$1"
}

log_info() {
  printf '  - %s\n' "$1"
}

log_warn() {
  printf '  ! %s\n' "$1" >&2
}

log_success() {
  printf '  + %s\n' "$1"
}

die() {
  printf 'Error: %s\n' "$1" >&2
  return 1
}

is_macos() {
  [[ "$(uname -s)" == "Darwin" ]]
}

is_linux() {
  [[ "$(uname -s)" == "Linux" ]]
}

ensure_backup_dir() {
  if [[ -z "${DOTFILES_BACKUP_DIR}" ]]; then
    DOTFILES_BACKUP_DIR="${HOME}/.local/state/dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
    mkdir -p "${DOTFILES_BACKUP_DIR}"
  fi
}

path_managed_by_repo() {
  local path="$1"
  if [[ ! -L "${path}" ]]; then
    return 1
  fi

  local target
  target="$(readlink "${path}")"
  if [[ "${target}" != /* ]]; then
    target="$(cd -- "$(dirname "${path}")" && cd -- "$(dirname "${target}")" && pwd)/$(basename "${target}")"
  fi
  [[ "${target}" == "${REPO_ROOT}"* ]]
}

path_managed_by_ezsh() {
  local path="$1"
  [[ -f "${path}" ]] || return 1
  grep -q "This file is created by ezsh setup." "${path}"
}

backup_if_needed() {
  local path="$1"
  if [[ ! -e "${path}" && ! -L "${path}" ]]; then
    return 0
  fi

  if path_managed_by_repo "${path}" || path_managed_by_ezsh "${path}"; then
    return 0
  fi

  ensure_backup_dir
  mkdir -p "${DOTFILES_BACKUP_DIR}/$(dirname "${path#${HOME}/}")"
  mv "${path}" "${DOTFILES_BACKUP_DIR}/${path#${HOME}/}"
  log_info "Backed up ${path} to ${DOTFILES_BACKUP_DIR}/${path#${HOME}/}"
}

ensure_local_bin_shims() {
  mkdir -p "${HOME}/.local/bin"

  if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    ln -sfn "$(command -v fdfind)" "${HOME}/.local/bin/fd"
    log_info "Created fd shim in ~/.local/bin"
  fi

  if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    ln -sfn "$(command -v batcat)" "${HOME}/.local/bin/bat"
    log_info "Created bat shim in ~/.local/bin"
  fi
}

install_packages_apt() {
  local packages=(
    bat
    curl
    eza
    fd-find
    fontconfig
    gcc
    g++
    git
    luarocks
    make
    python3
    python3-venv
    ripgrep
    stow
    tmux
    unzip
    wget
    xz-utils
    zsh
  )

  sudo apt-get update
  sudo apt-get install -y "${packages[@]}"
}

install_packages_brew() {
  local packages=(
    bat
    eza
    fd
    fontconfig
    gcc
    git
    luarocks
    ripgrep
    stow
    terminal-notifier
    tmux
    wget
    zsh
  )

  brew install "${packages[@]}"
}

check_dependencies() {
  log_section "Installing system dependencies"

  if is_macos; then
    command -v brew >/dev/null 2>&1 || die "Homebrew is required on macOS."
    install_packages_brew
  elif is_linux; then
    command -v apt-get >/dev/null 2>&1 || die "Only apt-based Linux is supported right now."
    install_packages_apt
  else
    die "Unsupported platform: $(uname -s)"
  fi

  ensure_local_bin_shims
  log_success "Base dependencies are installed"
}

clone_or_update_repo() {
  local repo_url="$1"
  local dest_dir="$2"

  if [[ -d "${dest_dir}/.git" ]]; then
    git -C "${dest_dir}" pull --ff-only >/dev/null
    return 0
  fi

  mkdir -p "$(dirname "${dest_dir}")"
  rm -rf "${dest_dir}"
  git clone --depth 1 "${repo_url}" "${dest_dir}" >/dev/null
}

resolve_ezsh_dir() {
  clone_or_update_repo "${EZSH_REPO_URL}" "${EZSH_DIR}"
  printf '%s\n' "${EZSH_DIR}"
}

install_or_update_plugin() {
  local repo_url="$1"
  local dest_dir="$2"

  clone_or_update_repo "${repo_url}" "${dest_dir}"
}

install_oh_my_zsh() {
  install_or_update_plugin \
    "https://github.com/ohmyzsh/ohmyzsh.git" \
    "${HOME}/.config/ezsh/oh-my-zsh"
}

install_oh_my_zsh_plugins() {
  local custom_plugins="${HOME}/.config/ezsh/oh-my-zsh/custom/plugins"
  mkdir -p "${custom_plugins}"

  install_or_update_plugin \
    "https://github.com/zsh-users/zsh-autosuggestions" \
    "${custom_plugins}/zsh-autosuggestions"
  install_or_update_plugin \
    "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "${custom_plugins}/zsh-syntax-highlighting"
  install_or_update_plugin \
    "https://github.com/zsh-users/zsh-completions" \
    "${custom_plugins}/zsh-completions"
  install_or_update_plugin \
    "https://github.com/zsh-users/zsh-history-substring-search" \
    "${custom_plugins}/zsh-history-substring-search"
  install_or_update_plugin \
    "https://github.com/supercrabtree/k" \
    "${custom_plugins}/k"
  install_or_update_plugin \
    "https://github.com/Aloxaf/fzf-tab" \
    "${custom_plugins}/fzf-tab"
}

install_powerlevel10k_theme() {
  install_or_update_plugin \
    "https://github.com/romkatv/powerlevel10k.git" \
    "${HOME}/.config/ezsh/oh-my-zsh/custom/themes/powerlevel10k"
}

install_fzf() {
  local fzf_dir="${HOME}/.config/ezsh/fzf"
  install_or_update_plugin "https://github.com/junegunn/fzf.git" "${fzf_dir}"
  "${fzf_dir}/install" --all --key-bindings --completion --no-update-rc >/dev/null
}

install_ezsh() {
  log_section "Installing ezsh base"

  local ezsh_source_dir
  ezsh_source_dir="$(resolve_ezsh_dir)"
  log_info "Using ezsh source from ${ezsh_source_dir}"

  backup_if_needed "${HOME}/.zshrc"

  mkdir -p "${HOME}/.config/ezsh/zshrc"
  mkdir -p "${HOME}/.cache/zsh"
  cp -f "${ezsh_source_dir}/.zshrc" "${HOME}/.zshrc"
  cp -f "${ezsh_source_dir}/ezshrc.zsh" "${HOME}/.config/ezsh/ezshrc.zsh"

  install_oh_my_zsh
  install_oh_my_zsh_plugins
  install_powerlevel10k_theme
  install_fzf

  log_success "ezsh base is installed"
}

install_neovim() {
  if [[ "${DEV_SKIP_NEOVIM}" == true ]]; then
    log_info "Skipping Neovim installation"
    return 0
  fi

  log_section "Installing Neovim"

  if is_macos; then
    brew install neovim
  else
    local archive="nvim-linux-x86_64.tar.gz"
    curl -fsSLO "https://github.com/neovim/neovim/releases/latest/download/${archive}"
    sudo rm -rf /opt/nvim-linux-x86_64
    sudo tar -C /opt -xzf "${archive}"
    rm -f "${archive}"
  fi

  log_success "Neovim is installed"
}

install_node() {
  if [[ "${DEV_SKIP_NODE}" == true ]]; then
    log_info "Skipping Node.js installation"
    return 0
  fi

  log_section "Installing Node.js"

  if is_macos; then
    if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
      log_info "Node.js is already available"
      return 0
    fi
    brew install node
  else
    local node_major=0
    if command -v node >/dev/null 2>&1; then
      node_major="$(node -p 'process.versions.node.split(".")[0]')"
    fi

    if (( node_major < 20 )); then
      curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
      sudo apt-get install -y nodejs
    elif command -v npm >/dev/null 2>&1; then
      log_info "Node.js is already available"
      return 0
    fi
  fi

  log_success "Node.js is installed"
}

install_ai_cli_tools() {
  log_section "Installing AI CLI tools"

  if ! command -v npm >/dev/null 2>&1; then
    log_warn "npm is not available; skipping Codex and Claude CLI installation."
    return 0
  fi

  npm install --global --prefix "${HOME}/.local" @openai/codex @anthropic-ai/claude-code >/dev/null
  log_success "Installed Codex and Claude Code CLIs into ~/.local/bin"
}

install_tmux_plugin_manager() {
  if [[ -d "${HOME}/.tmux/plugins/tpm/.git" ]]; then
    git -C "${HOME}/.tmux/plugins/tpm" pull --ff-only >/dev/null
    log_info "Updated tmux plugin manager"
    return 0
  fi

  git clone --depth 1 https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm" >/dev/null
  log_success "Installed tmux plugin manager"
}

install_fzf_git() {
  clone_or_update_repo "https://github.com/junegunn/fzf-git.sh" "${HOME}/fzf-git.sh"
  log_success "fzf-git is installed"
}

build_fzf_tab_module() {
  if ! command -v zsh >/dev/null 2>&1; then
    return 0
  fi

  /bin/zsh -i -c '(( $+functions[build-fzf-tab-module] )) && build-fzf-tab-module' >/dev/null 2>&1 || \
    log_warn "fzf-tab native module did not build automatically; the plugin will still load without it."
}

install_shell_tools() {
  log_section "Installing shell tools"
  install_fzf_git
  build_fzf_tab_module
}

stow_package() {
  local package="$1"
  stow --target="${HOME}" --restow "${package}"
  log_info "Applied ${package}"
}

stow_package_no_folding() {
  local package="$1"
  stow --target="${HOME}" --restow --no-folding "${package}"
  log_info "Applied ${package}"
}

install_pi_packages() {
  local package="npm:@heyhuynhgiabuu/pi-search@0.3.0"

  if ! command -v pi >/dev/null 2>&1; then
    log_warn "Pi is not available; skipping ${package}."
    return 0
  fi

  if pi list 2>/dev/null | grep -Fq "${package}"; then
    log_info "Pi package ${package} is already installed"
    return 0
  fi

  pi install "${package}" >/dev/null
  log_info "Installed Pi package ${package}"
}

apply_ai_dotfiles() {
  log_section "Applying AI tool dotfiles"

  backup_if_needed "${HOME}/.config/opencode/opencode.jsonc"
  backup_if_needed "${HOME}/.config/opencode/agents/reddit-researcher.md"
  backup_if_needed "${HOME}/.config/opencode/plugins/notification.ts"
  backup_if_needed "${HOME}/.claude/settings.json"
  backup_if_needed "${HOME}/.claude/settings.local.json"
  backup_if_needed "${HOME}/.claude/statusline-command.sh"
  backup_if_needed "${HOME}/.codex/config.toml"
  backup_if_needed "${HOME}/.pi/agent/agents/reddit-researcher.md"
  backup_if_needed "${HOME}/.pi/agent/extensions/subagent/index.ts"
  backup_if_needed "${HOME}/.pi/agent/extensions/subagent/agents.ts"

  (
    cd "${REPO_ROOT}"
    stow_package "opencode"
    stow_package "claude"
    stow_package "codex"
    stow_package_no_folding "pi"
  )

  install_pi_packages
  log_success "AI tool dotfiles are applied"
}

apply_dotfiles() {
  log_section "Applying dotfiles"

  backup_if_needed "${HOME}/.gitconfig"
  backup_if_needed "${HOME}/.tmux.conf"
  backup_if_needed "${HOME}/.config/nvim"
  backup_if_needed "${HOME}/.config/ezsh/p10k.zsh"
  backup_if_needed "${HOME}/.config/ezsh/zshrc/local.zsh"

  (
    cd "${REPO_ROOT}"
    stow_package "gitconfig"
    stow_package "commit"
    stow_package "nvim"
    stow_package "zsh"
    stow_package "p10k"
    stow_package "tmux"
  )

  install_tmux_plugin_manager
  log_success "Dotfiles are applied"

  apply_ai_dotfiles
}

set_default_shell() {
  if [[ "${DEV_SET_DEFAULT_SHELL}" != true ]]; then
    log_info "Leaving the default shell unchanged. Re-run with --set-default-shell to switch to zsh."
    return 0
  fi

  if [[ "${SHELL:-}" == "$(command -v zsh)" ]]; then
    log_info "zsh is already the default shell"
    return 0
  fi

  chsh -s "$(command -v zsh)"
  log_success "Default shell updated to zsh"
}

parse_dev_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-node)
        DEV_SKIP_NODE=true
        ;;
      --skip-neovim)
        DEV_SKIP_NEOVIM=true
        ;;
      --set-default-shell)
        DEV_SET_DEFAULT_SHELL=true
        ;;
      --help|-h)
        cat <<'EOF'
Usage: ./setup.sh dev [options]

Options:
  --skip-node          Do not install Node.js.
  --skip-neovim        Do not install Neovim.
  --set-default-shell  Run chsh so new terminals open in zsh.
EOF
        return 2
        ;;
      *)
        die "Unknown dev option: $1"
        ;;
    esac
    shift
  done
}

setup_dev() {
  local parse_status=0
  parse_dev_args "$@" || parse_status=$?
  case "${parse_status}" in
    0) ;;
    2) return 0 ;;
    *) return 1 ;;
  esac

  log_section "Starting development machine setup"
  log_info "Repo root: ${REPO_ROOT}"

  check_dependencies
  install_ezsh
  install_neovim
  install_node
  install_ai_cli_tools
  install_shell_tools
  apply_dotfiles
  set_default_shell

  log_section "Next steps"
  log_info "Open a new terminal or run: exec zsh"
  log_info "If your terminal font looks wrong, switch it to a Nerd Font."
  if [[ -n "${DOTFILES_BACKUP_DIR}" ]]; then
    log_info "Backups from replaced files are in ${DOTFILES_BACKUP_DIR}"
  fi
}
