#!/bin/bash
# Claude Code status line: current directory + git branch (Powerlevel10k-style)

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# Abbreviate $HOME to ~
dir_display="${cwd/#$HOME/~}"

branch=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  fi

  dirty=""
  if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
    dirty="*"
  fi
fi

# Dimmed blue for path, dimmed green for a clean branch, dimmed yellow if dirty
if [ -n "$branch" ]; then
  if [ -n "$dirty" ]; then
    printf '\033[2;34m%s\033[0m \033[2;33m %s%s\033[0m' "$dir_display" "$branch" "$dirty"
  else
    printf '\033[2;34m%s\033[0m \033[2;32m %s\033[0m' "$dir_display" "$branch"
  fi
else
  printf '\033[2;34m%s\033[0m' "$dir_display"
fi
