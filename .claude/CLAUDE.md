# Project: CI/CD Code Review System

## Project Standards

### TypeScript Conventions
- Strict type checking enabled
- No `any` types without justification comment
- Prefer interfaces over types for object shapes
- Use `readonly` for immutable properties

### Testing Requirements
- All new functions must have unit tests
- Integration tests for API endpoints
- Test coverage minimum: 80%

### Security Standards
- No hardcoded credentials or API keys
- Sanitize all user inputs
- Use parameterized queries (no SQL injection)
- Validate all external data

### Code Review Criteria
- Type safety
- Error handling
- Test coverage
- Security vulnerabilities
- Performance implications
- Breaking changes

## CI/CD Behavior

When running in CI mode (`-p` flag):
- Use multi-pass review strategy
- Output structured JSON findings
- Apply severity-based approval logic
- Focus on actionable issues only