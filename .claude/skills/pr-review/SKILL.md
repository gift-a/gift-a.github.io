---
context: fork
allowed-tools: ["Read", "Grep", "Bash"]
argument-hint: "PR number, branch name, or commit range"
---

# PR Review Skill

Performs comprehensive code review of pull request changes.

## Usage

```bash
/pr-review 123              # Review PR #123
/pr-review feature/auth     # Review branch
/pr-review main..HEAD       # Review commit range
```

## Review Process

1. **Identify changed files** (git diff)
2. **Pass 1: Local analysis**
   - Security issues per file
   - Type safety per file
   - Obvious bugs per file
3. **Pass 2: Integration analysis**
   - Breaking changes across files
   - API contract consistency
   - Database migration safety

## Output

Structured JSON with:
- Summary
- Findings (severity, file, line, message, category)
- Approval recommendation