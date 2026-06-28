#!/bin/bash
set -euo pipefail

# Configuration
PR_NUMBER="${1:-}"
OUTPUT_FILE="review-results.json"
SCHEMA_FILE="src/review-schema.json"
MAX_RETRIES=3
RETRY_DELAY=2

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
  echo -e "${GREEN}[CI-Review]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

# Validate PR number
if [ -z "$PR_NUMBER" ]; then
  error "Usage: $0 <PR_NUMBER>"
  exit 1
fi

log "Starting review of PR #${PR_NUMBER}"

# Get changed files
log "Identifying changed files..."
# In GitHub Actions, we need to fetch the base branch and use origin/master
if [ -n "${GITHUB_ACTIONS:-}" ]; then
  git fetch origin master:master 2>/dev/null || true
  BASE_REF="origin/master"
else
  BASE_REF="master"
fi
CHANGED_FILES=$(git diff --name-only ${BASE_REF}...HEAD | grep -E '\.(ts|tsx)$' || true)

if [ -z "$CHANGED_FILES" ]; then
  log "No TypeScript files changed. Skipping review."
  echo '{"summary":"No TypeScript files changed","findings":[],"approved":true}' > "$OUTPUT_FILE"
  exit 0
fi

FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l | xargs)
log "Found ${FILE_COUNT} TypeScript file(s) to review"

# Multi-pass review with retry logic
review_with_retry() {
  local prompt="$1"
  local attempt=1

  while [ $attempt -le $MAX_RETRIES ]; do
    log "Attempt ${attempt}/${MAX_RETRIES}..."

    # Run claude CLI and capture full output
    if claude -p "$prompt" \
        --output-format json \
        --json-schema "$(cat "$SCHEMA_FILE")" \
        --model claude-sonnet-4-5 \
        > /tmp/claude-full-output.json 2>/tmp/claude-error.log; then

      # Extract just the structured_output field which contains the validated schema
      jq '.structured_output' /tmp/claude-full-output.json > "$OUTPUT_FILE"

      log "Review completed successfully"
      return 0
    fi
    
    # Check error type
    if grep -q "429" /tmp/claude-error.log; then
      warn "Rate limit exceeded. Retrying in $((RETRY_DELAY ** attempt)) seconds..."
      sleep $((RETRY_DELAY ** attempt))
    elif grep -q "validation" /tmp/claude-error.log; then
      error "Schema validation failed:"
      cat /tmp/claude-error.log
      return 1
    else
      error "Unknown error occurred:"
      cat /tmp/claude-error.log
      return 1
    fi
    
    ((attempt++))
  done
  
  error "Failed after ${MAX_RETRIES} retries"
  return 1
}

# Pass 1: Local analysis (per-file)
log "Pass 1: Per-file local analysis..."

# Get actual file contents
FILE_CONTENTS=""
for file in $CHANGED_FILES; do
  if [ -f "$file" ]; then
    FILE_CONTENTS="${FILE_CONTENTS}

=== File: ${file} ===
$(cat "$file")
"
  fi
done

PASS1_PROMPT="Review the following code changes from PR #${PR_NUMBER} for security, type safety, and obvious bugs.

${FILE_CONTENTS}

Analyze each file for:
1. Security vulnerabilities (SQL injection, XSS, hardcoded secrets, etc.)
2. Type safety issues (use of 'any' without justification, missing type annotations)
3. Obvious bugs (null/undefined checks, logic errors, off-by-one errors)

Provide structured findings with severity levels, categorize each issue, and indicate whether the PR should be approved based on the severity of issues found."

if ! review_with_retry "$PASS1_PROMPT"; then
  error "Pass 1 failed"
  exit 1
fi

# Pass 2: Integration analysis (cross-file)
log "Pass 2: Cross-file integration analysis..."

# Read existing findings
PASS1_FINDINGS=$(cat "$OUTPUT_FILE" 2>/dev/null || echo '{"findings":[]}')

PASS2_PROMPT="Review the following code changes from PR #${PR_NUMBER} for cross-file integration issues.

${FILE_CONTENTS}

Previous findings from Pass 1:
${PASS1_FINDINGS}

Check for:
1. Breaking changes to existing APIs (function signature changes, removed exports)
2. Database migration safety (schema changes, data integrity)
3. Inconsistent API contracts across files
4. Missing integration tests for cross-file dependencies

Merge any new integration issues with the findings from Pass 1. Update the summary and approval status if needed based on all findings."

if ! review_with_retry "$PASS2_PROMPT"; then
  warn "Pass 2 failed, using Pass 1 results only"
fi

log "Review complete. Results saved to ${OUTPUT_FILE}"