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
decision, or anti-pattern), capture it with:

sqlite3 "$DB_PATH" "INSERT INTO knowledge (id, type, fact, recommendation, confidence, source, tags, files, expires_at, created_at) VALUES ((SELECT printf('k_%03d', COALESCE(MAX(CAST(SUBSTR(id,3) AS INTEGER)),0)+1) FROM knowledge), '<pattern|gotcha|decision|anti-pattern>', '<what was learned>', '<what to do next time>', 'medium', 'claude', '[\"tag1\",\"tag2\"]', '[]', datetime('now', '+90 days'), datetime('now'));"

If this commit has no reusable learning (trivial fix, formatting), skip.

EOF
