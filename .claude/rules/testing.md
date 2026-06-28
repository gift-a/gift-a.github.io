---
paths: ["**/**.spec.ts", "**/**.test.md"]
---

# Test Convention Rules

## Test Structure

1. **Naming:** `describe('ComponentName', () => { it('should behavior', ...) })`
2. **Arrange-Act-Assert** pattern
3. **One assertion per test** (when possible)

## Coverage Requirements

- All public functions tested
- Edge cases covered (null, undefined, empty, max values)
- Error paths tested (not just happy path)

## Common Issues

- Tests too brittle (over-mocking)
- Missing cleanup (database, files, timers)
- Flaky tests (race conditions, timeouts)
- Tests testing implementation instead of behavior