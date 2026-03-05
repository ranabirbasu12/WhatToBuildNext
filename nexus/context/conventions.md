# Project Conventions

## Code Style
- Shell scripts: Use bash, set -euo pipefail, quote all variables
- JSON: 2-space indent, camelCase keys
- Skills: Markdown with clear section headers

## Commit Style
- Conventional commits: feat:, fix:, docs:, refactor:
- Co-authored-by line for AI contributions

## Testing
- Every dispatch script must be testable with a dry-run flag
- Validate JSON structures with jq before writing
