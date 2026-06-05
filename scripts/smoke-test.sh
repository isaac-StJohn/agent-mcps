#!/bin/bash
# smoke-test.sh - Validate MCP server entrypoints
# Prints "OK <name>" for each server with valid entrypoint
# Exits non-zero if any entrypoint is missing

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Common entrypoint filenames
ENTRYPOINT_FILES=("index.js" "main.js" "index.ts" "main.ts" "index.py" "main.py" "app.py" "server.js" "server.py")

has_entrypoint() {
    local dir="$1"
    for entrypoint in "${ENTRYPOINT_FILES[@]}"; do
        if [[ -f "$dir/$entrypoint" ]]; then
            return 0
        fi
    done
    return 1
}

# Find all directories in the repo root (exclude hidden dirs, scripts, node_modules, etc.)
failed=0
for dir in "$REPO_ROOT"/*/; do
    [[ ! -d "$dir" ]] && continue
    
    # Skip non-server directories
    dirname=$(basename "$dir")
    [[ "$dirname" == "scripts" ]] && continue
    [[ "$dirname" == "node_modules" ]] && continue
    [[ "$dirname" == "venv" ]] && continue
    [[ "$dirname" == ".git" ]] && continue
    [[ "$dirname" == .* ]] && continue
    
    if has_entrypoint "$dir"; then
        echo "OK $dirname"
    else
        echo "FAIL $dirname: no entrypoint found (expected one of: ${ENTRYPOINT_FILES[*]})"
        failed=1
    fi
done

if [[ $failed -eq 0 ]]; then
    echo "All servers validated."
    exit 0
else
    echo "Some servers failed validation."
    exit 1
fi
