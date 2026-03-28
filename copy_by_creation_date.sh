#!/usr/bin/env bash
# copy_by_creation_date.sh
# Usage: ./copy_by_creation_date.sh /path/to/source_dir

set -euo pipefail

# ── 1️⃣ Validate arguments ──────────────────────────────
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <source_dir>" >&2
    exit 1
fi

SRC_DIR="$1"

if [[ ! -d "$SRC_DIR" ]]; then
    echo "Error: $SRC_DIR is not a directory" >&2
    exit 1
fi

# ── 2️⃣ Prepare output directory ─────────────────────────
OUTPUT_DIR="${SRC_DIR%/}/output"
mkdir -p "$OUTPUT_DIR"

# ── 3️⃣ Process each file (non‑recursive) ───────────────
#   Use find with -maxdepth 1 to stay non‑recursive.
#   -type f to get only regular files.
while IFS= read -r -d '' file; do
    # Get creation time (birth time).  `stat` options differ per OS.
    if stat -f "%B" "$file" 2>/dev/null; then
        # macOS / BSD
        birth_ts=$(stat -f "%B" "$file")
    else
        # GNU stat
        birth_ts=$(stat -c %W "$file")
    fi

    # If creation time is unavailable (e.g., older filesystem), fallback to
    # modification time.
    if [[ -z "$birth_ts" || "$birth_ts" -eq 0 ]]; then
        birth_ts=$(stat -c %Y "$file")
    fi

    # Format as YYYY-MM-DD
    date_str=$(date -u -d "@$birth_ts" +"%Y-%m-%d" 2>/dev/null ||
        date -u -r "$birth_ts" +"%Y-%m-%d")

    # Destination sub‑directory
    dst_dir="$OUTPUT_DIR/${date_str}_"
    mkdir -p "${dst_dir}"

    # Copy (overwrite if exists)
    cp -pv "$file" "$dst_dir/"
done < <(find "$SRC_DIR" -maxdepth 1 -type f -print0)

echo "Done. Files copied to $OUTPUT_DIR."
