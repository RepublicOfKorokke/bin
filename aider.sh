#!/usr/bin/env bash

# -------------------------------------------------------------
# launch aider with an fzf‑selected prompt
#
# Usage:  ./aider.sh
#
# Assumes:
#   * `fzf` is installed and available on the PATH
#   * The following files exist:
#       ~/.config/aider/.aider.conf.yml
#       ~/.config/aider/models.metadata.json
# -------------------------------------------------------------

set -euo pipefail

CONFIG_FILE="$HOME/.config/aider/.aider.conf.yml"
MODEL_META_FILE="$HOME/.config/aider/models.metadata.json"
CHAT_MODE="ask"

PROMPTS_DIR="$HOME/.config/aider/prompts/"
SELECTED_PROMPT=$(find "$PROMPTS_DIR" -type f -name '*.md' | fzf --prompt="Choose prompt: ")

if [[ -z "$SELECTED_PROMPT" ]]; then
    echo "No prompt selected – aborting." >&2
    exit 1
fi

exec aider \
    --config "$CONFIG_FILE" \
    --model-metadata-file "$MODEL_META_FILE" \
    --chat-mode "$CHAT_MODE" \
    --read "$SELECTED_PROMPT"
