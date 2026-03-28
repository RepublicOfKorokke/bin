#!/bin/bash

set -euo pipefail

if [[ $# -eq 0 ]]; then
    printf "No extentions"
    exit 1
else
    exts=("$@")
fi

# fd に渡す -e オプションを作成
fd_args=()
for ext in "${exts[@]}"; do
    fd_args+=(-e "$ext")
done

fd "${fd_args[@]}" | while IFS= read -r file; do
    printf "\`\`\`%s\n" "$file"
    nl -ba "$file"
    printf "\n\`\`\`\n\n"
done
