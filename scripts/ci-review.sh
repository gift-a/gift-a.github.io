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
CHANGED_FILES=$(git diff --name-only origin/main...HEAD | grep -E '\.(ts|tsx)$' || true)

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
    
    if claude -p "$prompt" \
        --output-format json \
        --json-schema "$SCHEMA_FILE" \
        --model claude-sonnet-4-5 \
        > "$OUTPUT_FILE" 2>/tmp/claude-error.log; then
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

PASS1_PROMPT="Review PR #${PR_NUMBER} for security, type safety, and obvious bugs.

Changed files:
${CHANGED_FILES}

For each file:
1. Check for security vulnerabilities
2. Verify type safety (no 'any' without justification)
3. Identify obvious bugs

Provide structured findings with severity levels."

if ! review_with_retry "$PASS1_PROMPT"; then
  error "Pass 1 failed"
  exit 1
fi

# Pass 2: Integration analysis (cross-file)
log "Pass 2: Cross-file integration analysis..."

PASS2_PROMPT="Review PR #${PR_NUMBER} for cross-file integration issues.

Changed files:
${CHANGED_FILES}

Check for:
1. Breaking changes to existing APIs
2. Database migration safety
3. Inconsistent API contracts across files

Merge with any findings from Pass 1."

if ! review_with_retry "$PASS2_PROMPT"; then
  warn "Pass 2 failed, using Pass 1 results only"
fi

log "Review complete. Results saved to ${OUTPUT_FILE}"