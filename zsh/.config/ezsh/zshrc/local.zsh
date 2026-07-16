path_prepend_if_dir() {
  if [[ -d "$1" && ":$PATH:" != *":$1:"* ]]; then
    export PATH="$1:$PATH"
  fi
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

path_prepend_if_dir "$HOME/.local/bin"
path_prepend_if_dir "$HOME/.cargo/bin"
path_prepend_if_dir "/opt/nvim-linux-x86_64/bin"

if command_exists fd; then
  export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

  _fzf_compgen_path() {
    fd --hidden --exclude .git . "$1"
  }

  _fzf_compgen_dir() {
    fd --type=d --hidden --exclude .git . "$1"
  }
fi

if [[ -r "$HOME/fzf-git.sh/fzf-git.sh" ]]; then
  source "$HOME/fzf-git.sh/fzf-git.sh"
fi

export BAT_THEME="${BAT_THEME:-Dracula}"

if command_exists eza; then
  __fzf_dir_preview='eza --tree --color=always {} | head -200'
  alias ls='eza --color=always --long --git --icons=always'
else
  __fzf_dir_preview='ls -la {} | head -200'
fi

if command_exists bat; then
  __fzf_file_preview='bat -n --color=always --line-range :500 {}'
else
  __fzf_file_preview='sed -n "1,200p" {}'
fi

show_file_or_dir_preview="if [ -d {} ]; then ${__fzf_dir_preview}; else ${__fzf_file_preview}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview '${__fzf_dir_preview}'"

_fzf_comprun() {
  local command="$1"
  shift

  case "$command" in
    cd)
      fzf --preview "${__fzf_dir_preview}" "$@"
      ;;
    export|unset)
      fzf --preview 'printenv {}' "$@"
      ;;
    ssh)
      if command_exists dig; then
        fzf --preview 'dig {}' "$@"
      else
        fzf "$@"
      fi
      ;;
    *)
      fzf --preview "$show_file_or_dir_preview" "$@"
      ;;
  esac
}

VI_MODE_SET_CURSOR=true
plugins+=(vi-mode)
