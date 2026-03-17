#!/usr/bin/env bash

# Claude Code status line script
# Shows: masked email (blue) | current directory (white) + branch (light yellow) | model (orange) + context usage (green/yellow/red)

# Claude Code passes session data as JSON on stdin
input=$(cat)

# Extract fields from the JSON payload; // empty yields no output if field is absent/null
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')
# Sum raw token counts for exact used-token display (avoids rounding from integer percentage)
ctx_used_tokens=$(echo "$input" | jq -r '
  (.context_window.current_usage.input_tokens // 0) +
  (.context_window.current_usage.cache_creation_input_tokens // 0) +
  (.context_window.current_usage.cache_read_input_tokens // 0)
')

# ANSI colors (256-color palette)
BLUE='\033[38;5;39m'
LIGHT_YELLOW='\033[38;5;228m'
ORANGE='\033[38;5;214m'
WHITE='\033[97m'
RESET='\033[0m'
# Context usage threshold colors
CTX_GREEN='\033[32m'
CTX_YELLOW='\033[33m'
CTX_RED='\033[31m'

# Read OAuth email from ~/.claude.json; suppress errors if file is absent or malformed
email=$(jq -r '.oauthAccount.emailAddress // empty' ~/.claude.json 2>/dev/null)

# Each statusline segment is appended here; printed one per line at the end
parts=()

# Segment 1: masked email (e.g. p****@example.com)
if [ -n "$email" ]; then
  first="${email:0:1}"
  domain="${email#*@}"
  masked="${first}****@${domain}"
  parts+=("$(printf "${BLUE}%s${RESET}" "$masked")")
fi

# Segment 2: directory name + git branch (branch omitted when not in a repo)
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
  cwd=$(basename "$cwd")
  if [ -n "$branch" ]; then
    parts+=("$(printf "${WHITE}%s${RESET} ${LIGHT_YELLOW}[%s]${RESET}" "$cwd" "$branch")")
  else
    parts+=("$(printf "${WHITE}%s${RESET}" "$cwd")")
  fi
fi

# Segment 3: model name + context usage with color-coded percentage
#   green < 50%, yellow 50–79%, red >= 80%
if [ -n "$model" ]; then
  model_part="$(printf "${ORANGE}%s${RESET}" "$model")"
  if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
    ctx_int=$(printf "%.f" "$used_pct")  # round float to integer for comparison
    if [ "$ctx_int" -lt 50 ]; then
      ctx_color="$CTX_GREEN"
    elif [ "$ctx_int" -lt 80 ]; then
      ctx_color="$CTX_YELLOW"
    else
      ctx_color="$CTX_RED"
    fi
    ctx_str="ctx: $(printf "%.0f" "$used_pct")%"
    if [ -n "$ctx_size" ] && [ "$ctx_size" != "null" ]; then
      # Format used tokens from raw counts (exact); total window size rounded to nearest k
      used_k=$(awk "BEGIN { printf \"%.1f\", $ctx_used_tokens / 1000 }")
      total_k=$(awk "BEGIN { printf \"%.0f\", $ctx_size / 1000 }")
      ctx_str="${ctx_str} (${used_k}k / ${total_k}k)"
    fi
    model_part="${model_part} $(printf "${ctx_color}%s${RESET}" "$ctx_str")"
  fi
  parts+=("$model_part")
fi

# Print each segment on its own line; %b interprets the ANSI escape sequences
for part in "${parts[@]}"; do
  printf "%b\n" "$part"
done
