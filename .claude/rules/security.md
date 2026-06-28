---
paths: ["auth/**/**", "src/api/**"]
---

# Security Review Rules

## Critical Checks

1. **Authentication & Authorization**
   - Verify auth middleware is applied
   - Check role-based access controls
   - No auth bypass logic

2. **Input Validation**
   - Sanitize all user inputs
   - Validate types and ranges
   - Check for injection vulnerabilities (SQL, XSS, command)

3. **Secrets Management**
   - No hardcoded API keys, passwords, tokens
   - Use environment variables or secret management
   - No credentials in logs

4. **Data Exposure**
   - No sensitive data in error messages
   - Proper error handling (no stack traces to client)
   - PII handling compliance

## High-Priority Issues

- SQL injection (use parameterized queries)
- XSS vulnerabilities (sanitize HTML)
- CSRF protection on state-changing endpoints
- Rate limiting on public endpoints