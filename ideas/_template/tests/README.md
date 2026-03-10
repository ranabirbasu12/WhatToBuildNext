# tests/

Tests go here. Match the structure of `src/`.

## Naming Convention

- `<module>.test.ts` — unit tests
- `<feature>.integration.test.ts` — integration tests
- `<flow>.e2e.test.ts` — end-to-end tests

## Test Runners by Language

| Language | Runner | Config File |
|----------|--------|-------------|
| TypeScript/JS | Vitest | `vitest.config.ts` |
| Python | Pytest | `pyproject.toml` or `pytest.ini` |
| Rust | Cargo test | `Cargo.toml` |
| Go | Go test | Built-in |
| Shell | Bash assertions | `test-*.sh` |

## What to Test

### Always test:
- Happy path (does it work?)
- Edge cases (empty input, null, max values)
- Error handling (does it fail gracefully?)
- Public API (every exported function)

### Don't test:
- Private implementation details
- Third-party library behavior
- Trivial getters/setters

## Coverage

Aim for meaningful coverage, not a number. 80% of real bugs are caught by testing the critical paths, not by chasing 100%.
