#!/bin/bash

echo "═══════════════════════════════════════════════════════"
echo "  Day 4: CI/CD Implementation Validation"
echo "═══════════════════════════════════════════════════════"
echo ""

checks_passed=0
checks_failed=0

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check() {
  if [ $1 -eq 0 ]; then
    echo -e "${GREEN}✅ $2${NC}"
    ((checks_passed++))
  else
    echo -e "${RED}❌ $2${NC}"
    ((checks_failed++))
  fi
}

warn() {
  echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check file existence
echo "Checking file structure..."
[ -f .claude/CLAUDE.md ]; check $? "Project CLAUDE.md exists"
[ -f .claude/rules/typescript-review.md ]; check $? "TypeScript rules exist"
[ -f .claude/rules/security.md ]; check $? "Security rules exist"
[ -f .claude/rules/testing.md ]; check $? "Testing rules exist"
[ -f .claude/skills/pr-review/SKILL.md ]; check $? "PR review skill exists"
[ -f src/review-schema.json ]; check $? "JSON schema exists"
[ -f scripts/ci-review.sh ]; check $? "CI review script exists"
[ -f scripts/check-approval.sh ]; check $? "Approval check script exists"

# Check file permissions
echo ""
echo "Checking file permissions..."
[ -x scripts/ci-review.sh ]; check $? "CI review script is executable"
[ -x scripts/check-approval.sh ]; check $? "Approval check script is executable"

# Validate YAML frontmatter in rules
echo ""
echo "Validating YAML frontmatter..."

if [ -f .claude/rules/typescript-review.md ]; then
  grep -q "^---$" .claude/rules/typescript-review.md && grep -q "^paths:" .claude/rules/typescript-review.md
  check $? "TypeScript rules have YAML frontmatter with paths"
fi

if [ -f .claude/rules/security.md ]; then
  grep -q "^---$" .claude/rules/security.md && grep -q "^paths:" .claude/rules/security.md
  check $? "Security rules have YAML frontmatter with paths"
fi

if [ -f .claude/rules/testing.md ]; then
  grep -q "^---$" .claude/rules/testing.md && grep -q "^paths:" .claude/rules/testing.md
  check $? "Testing rules have YAML frontmatter with paths"
fi

# Validate PR review skill frontmatter
if [ -f .claude/skills/pr-review/SKILL.md ]; then
  grep -q "context: fork" .claude/skills/pr-review/SKILL.md
  check $? "PR review skill uses context: fork"

  grep -q "allowed-tools:" .claude/skills/pr-review/SKILL.md
  check $? "PR review skill has allowed-tools"
fi

# Validate JSON schema
echo ""
echo "Validating JSON schema..."

if command -v jq &> /dev/null; then
  if [ -f src/review-schema.json ]; then
    jq empty src/review-schema.json 2>/dev/null
    check $? "JSON schema is valid JSON"

    jq -e '.required | index("summary")' src/review-schema.json >/dev/null 2>&1
    check $? "Schema requires 'summary' field"

    jq -e '.required | index("findings")' src/review-schema.json >/dev/null 2>&1
    check $? "Schema requires 'findings' field"

    jq -e '.required | index("approved")' src/review-schema.json >/dev/null 2>&1
    check $? "Schema requires 'approved' field"

    jq -e '.properties.findings.items.properties.severity.enum | index("critical")' src/review-schema.json >/dev/null 2>&1
    check $? "Schema has severity enum with 'critical'"
  fi
else
  warn "jq not installed, skipping JSON schema validation"
  warn "Install with: brew install jq (macOS) or sudo apt-get install jq (Ubuntu)"
fi

# Validate shell scripts
echo ""
echo "Validating shell scripts..."

if [ -f scripts/ci-review.sh ]; then
  bash -n scripts/ci-review.sh 2>/dev/null
  check $? "CI review script has valid bash syntax"

  grep -q "set -euo pipefail" scripts/ci-review.sh
  check $? "CI review script uses 'set -euo pipefail' for error handling"

  grep -q "MAX_RETRIES" scripts/ci-review.sh
  check $? "CI review script has retry logic (MAX_RETRIES variable)"

  grep -q -- "--output-format json" scripts/ci-review.sh
  check $? "CI review script uses --output-format json"

  grep -q -- "--json-schema" scripts/ci-review.sh
  check $? "CI review script uses --json-schema"
fi

if [ -f scripts/check-approval.sh ]; then
  bash -n scripts/check-approval.sh 2>/dev/null
  check $? "Approval check script has valid bash syntax"

  grep -q "jq" scripts/check-approval.sh
  check $? "Approval check script uses jq for JSON parsing"
fi

# Summary
echo ""
echo "═══════════════════════════════════════════════════════"
echo "  Summary"
echo "═══════════════════════════════════════════════════════"
echo ""
echo -e "  ${GREEN}Passed:${NC} ${checks_passed}"
echo -e "  ${RED}Failed:${NC} ${checks_failed}"
echo ""

if [ $checks_failed -eq 0 ]; then
  echo -e "${GREEN}🎉 All checks passed! You're ready for practice questions.${NC}"
  echo ""
  echo "Next steps:"
  echo "  1. Review your implementation"
  echo "  2. Compare with ../day4-ci-cd-SOLUTION/ (optional)"
  echo "  3. Answer practice questions in README.md"
  exit 0
else
  echo -e "${RED}Some checks failed. Review IMPLEMENTATION_GUIDE.md for hints.${NC}"
  echo ""
  echo "Common issues:"
  echo "  - Missing files: Follow exercises 1-8 step by step"
  echo "  - Invalid YAML: Check frontmatter format (--- at start and end)"
  echo "  - Bash syntax: Use 'bash -n script.sh' to check syntax"
  echo "  - Missing executable permissions: Use 'chmod +x script.sh'"
  exit 1
fi
