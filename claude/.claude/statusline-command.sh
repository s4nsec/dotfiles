#!/bin/bash
# Claude Code status line: directory + git branch (Powerlevel10k-style) + model/context

input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# Abbreviate $HOME to ~
dir_display="${cwd/#$HOME/~}"

# Git segment: single git invocation, skip optional locks, degrade silently.
git_segment=""
if git_status=$(git -C "$cwd" --no-optional-locks status --porcelain --branch 2>/dev/null); then
  branch=$(printf '%s\n' "$git_status" | head -1 | sed -e 's/^## //' -e 's/\.\.\..*//' -e 's/ (no branch)//')
  if [ -n "$branch" ]; then
    # More than the branch header line means the tree is dirty
    if [ "$(printf '%s\n' "$git_status" | wc -l | tr -d ' ')" -gt 1 ]; then
      git_segment=$(printf '\033[2;33m %s*\033[0m' "$branch")
    else
      git_segment=$(printf '\033[2;32m %s\033[0m' "$branch")
    fi
  fi
fi

# Model + remaining context
model=$(echo "$input" | jq -r '.model.display_name')
window_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
used_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')

model_segment="$model"
if [ -n "$window_size" ] && [ "$window_size" -gt 0 ] 2>/dev/null; then
  remaining=$(( window_size - used_tokens ))
  [ "$remaining" -lt 0 ] && remaining=0
  model_segment="${model} · $(( (remaining + 500) / 1000 ))k left"
fi

# Dimmed blue path, dimmed green/yellow branch, dimmed grey model
printf '\033[2;34m%s\033[0m' "$dir_display"
[ -n "$git_segment" ] && printf ' %s' "$git_segment"
printf ' \033[2;37m%s\033[0m' "$model_segment"
