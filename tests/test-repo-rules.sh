#!/usr/bin/env bash
# Checks this repo's own rules that a script can verify: every command opts out of model invocation, every linked
# entry is named in README.md, and every linked entry is installed in ~/.claude/.

set -uo pipefail

# shellcheck source=setup/lib/targets.sh
source "$(dirname "${BASH_SOURCE[0]}")/../setup/lib/targets.sh"
FAILS=0

# check <name> <problems> — passes when the problems list is empty
check() {
  if [ -z "$2" ]; then
    echo "ok   - $1"
  else
    echo "FAIL - $1"
    printf '       %s\n' "$2"
    FAILS=$((FAILS + 1))
  fi
}

missing_flag=""
for f in "$REPO_DIR"/commands/*.md; do
  grep -q '^disable-model-invocation: true$' "$f" || missing_flag+="${f#"$REPO_DIR"/} "
done
check "every command has disable-model-invocation: true" "$missing_flag"

not_in_readme=""
not_installed=""
for dir in "${DIRS[@]}"; do
  for source in "$REPO_DIR/$dir"/*; do
    is_git_ignored "$source" && continue
    entry="$dir/$(basename "$source")"
    grep -qE "\\(${entry}[/)]" "$REPO_DIR/README.md" || not_in_readme+="$entry "
    # Ends in the entry rather than equals the source, so a worktree passes against the main checkout's install.
    [[ "$(readlink "$CLAUDE_DIR/$entry")" == */"$entry" ]] || not_installed+="$entry "
  done
done
check "every linked entry is named in README.md" "$not_in_readme"
check "every linked entry is installed in ~/.claude/ (run make install)" "$not_installed"

if [ "$FAILS" -ne 0 ]; then
  echo "$FAILS failed"
  exit 1
fi
echo "all passed"
