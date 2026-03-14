#!/bin/bash
# InstructionsLoaded hook: log every instruction file load to ~/.claude/.logs/instructions-loaded.log
#
# Fields logged (from the hook's stdin JSON):
#   - timestamp         — current date and time
#   - file_path         — absolute path to the loaded instruction file
#   - memory_type       — scope: User | Project | Local | Managed
#   - load_reason       — why it was loaded: session_start | nested_traversal | path_glob_match | include
#   - globs             — path glob patterns from frontmatter (path_glob_match loads only)
#   - trigger_file_path — file whose access triggered the load (lazy loads only)
#   - parent_file_path  — parent instruction file that included this one (include loads only)

# Exit early if logging is not enabled
[ "${LOG_INSTRUCTIONS_LOADED_ENABLED:-}" = "1" ] || exit 0

INPUT=$(cat)

FILE_PATH=$(jq -r '.file_path // ""' <<< "$INPUT")
MEMORY_TYPE=$(jq -r '.memory_type // ""' <<< "$INPUT")
LOAD_REASON=$(jq -r '.load_reason // ""' <<< "$INPUT")
GLOBS=$(jq -r '.globs // ""' <<< "$INPUT")
TRIGGER_FILE=$(jq -r '.trigger_file_path // ""' <<< "$INPUT")
PARENT_FILE=$(jq -r '.parent_file_path // ""' <<< "$INPUT")

LOG_DIR=".claude/.logs"
LOG_FILE="$LOG_DIR/instructions-loaded.log"

mkdir -p "$LOG_DIR"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Extract just filenames for readability
FILE_PATH="${FILE_PATH##*/}"
TRIGGER_FILE="${TRIGGER_FILE##*/}"
PARENT_FILE="${PARENT_FILE##*/}"

printf "%s | file_path=%s | memory_type=%s | load_reason=%s | globs=%s | trigger_file_path=%s | parent_file_path=%s\n" \
  "$TIMESTAMP" "$FILE_PATH" "$MEMORY_TYPE" "$LOAD_REASON" "$GLOBS" "$TRIGGER_FILE" "$PARENT_FILE" >> "$LOG_FILE"
