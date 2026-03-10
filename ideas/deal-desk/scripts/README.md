# scripts/

Automation scripts for this idea.

## Common Scripts

| Script | Purpose |
|--------|---------|
| `setup.sh` | One-time setup (install deps, create DB, seed data) |
| `dev.sh` | Start development environment |
| `deploy.sh` | Deploy to staging/production |
| `seed.sh` | Seed database with sample data |
| `migrate.sh` | Run database migrations |
| `benchmark.sh` | Performance benchmarks |

## Guidelines

- Every script should work from the idea's root directory
- Use `set -euo pipefail` at the top of bash scripts
- Print what you're doing: `echo "Installing dependencies..."`
- Check for required tools before running: `command -v node >/dev/null || { echo "Node required"; exit 1; }`
- Support `--dry-run` where destructive operations are involved
