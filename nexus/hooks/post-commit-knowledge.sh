#!/usr/bin/env bash
set -euo pipefail

# Post-commit hook: passive knowledge capture
# Fires after git commit, prompts Claude to extract learnings

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NEXUS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DB_PATH="$NEXUS_ROOT/nexus.db"

# Get last commit info (fail gracefully)
COMMIT_MSG=$(git log -1 --pretty=format:'%s' 2>/dev/null || echo 'unknown')
COMMIT_HASH=$(git log -1 --pretty=format:'%h' 2>/dev/null || echo 'unknown')
CHANGED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null | head -10 || echo 'unknown')

cat <<EOF

[NEXUS KNOWLEDGE CAPTURE]

Commit: $COMMIT_HASH — $COMMIT_MSG
Files changed:
$CHANGED_FILES

Claude: Review this commit. If it contains a reusable learning (pattern, gotcha,
convention, or decision), capture it with:

sqlite3 "$DB_PATH" "INSERT INTO knowledge (type, fact, recommendation, confidence, source, tags, files) VALUES ('<pattern|gotcha|convention|decision>', '<what happened>', '<what to do next time>', <0.0-1.0>, 'commit:$COMMIT_HASH', '<comma,separated,tags>', '<relevant,files>');"

If this commit has no reusable learning, skip this step.

EOF
