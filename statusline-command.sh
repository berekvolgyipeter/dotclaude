#!/usr/bin/env bash

# Claude Code status line script
# Shows: oauth email (blue) | current directory (yellow) | model (orange) | context usage

input=$(cat)

# Extract fields
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

# ANSI colors
BLUE='\033[38;5;39m'
YELLOW='\033[38;5;220m'
ORANGE='\033[38;5;208m'
GREEN='\033[38;5;76m'
MAGENTA='\033[38;5;201m'
RESET='\033[0m'

# OAuth email: read from ~/.claude.json
email=$(jq -r '.oauthAccount.emailAddress // empty' ~/.claude.json 2>/dev/null)

# Show only the directory name (basename) of cwd
if [ -n "$cwd" ]; then
  cwd=$(basename "$cwd")
fi

# Build output parts
parts=()

if [ -n "$email" ]; then
  parts+=("$(printf "${BLUE}%s${RESET}" "$email")")
fi

if [ -n "$cwd" ]; then
  parts+=("$(printf "${YELLOW}%s${RESET}" "$cwd")")
fi

if [ -n "$model" ]; then
  parts+=("$(printf "${ORANGE}%s${RESET}" "$model")")
fi

if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
  ctx_str="ctx: ${used_pct}%"
  if [ -n "$ctx_size" ] && [ "$ctx_size" != "null" ]; then
    formatted_size=$(printf "%d" "$ctx_size" | rev | sed 's/[0-9]\{3\}/& /g' | rev | sed 's/^ //')
    ctx_str="${ctx_str} (window: ${formatted_size})"
  fi
  parts+=("$(printf "${GREEN}%s${RESET}" "$ctx_str")")
fi

# Print each part on its own line
for part in "${parts[@]}"; do
  printf "%b\n" "$part"
done
