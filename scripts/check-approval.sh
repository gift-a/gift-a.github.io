#!/bin/bash
set -euo pipefail

REVIEW_FILE="${1:-review-results.json}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ ! -f "$REVIEW_FILE" ]; then
  echo -e "${RED}Error: Review file not found: ${REVIEW_FILE}${NC}"
  exit 1
fi

# Parse JSON (requires jq)
if ! command -v jq &> /dev/null; then
  echo -e "${RED}Error: jq is required but not installed${NC}"
  exit 1
fi

# Extract data
APPROVED=$(jq -r '.approved' "$REVIEW_FILE")
CRITICAL=$(jq '[.findings[] | select(.severity == "critical")] | length' "$REVIEW_FILE")
HIGH=$(jq '[.findings[] | select(.severity == "high")] | length' "$REVIEW_FILE")
MEDIUM=$(jq '[.findings[] | select(.severity == "medium")] | length' "$REVIEW_FILE")
LOW=$(jq '[.findings[] | select(.severity == "low")] | length' "$REVIEW_FILE")

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Code Review Results"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  Critical: ${CRITICAL}"
echo "  High:     ${HIGH}"
echo "  Medium:   ${MEDIUM}"
echo "  Low:      ${LOW}"
echo ""

# Approval logic
if [ "$CRITICAL" -gt 0 ]; then
  echo -e "${RED}❌ PR BLOCKED: ${CRITICAL} critical issue(s) found${NC}"
  jq -r '.findings[] | select(.severity == "critical") | "  - \(.file):\(.line // "?"): \(.message)"' "$REVIEW_FILE"
  exit 1
elif [ "$HIGH" -gt 0 ]; then
  echo -e "${RED}❌ PR BLOCKED: ${HIGH} high-severity issue(s) found${NC}"
  jq -r '.findings[] | select(.severity == "high") | "  - \(.file):\(.line // "?"): \(.message)"' "$REVIEW_FILE"
  exit 1
elif [ "$MEDIUM" -gt 0 ]; then
  echo -e "${YELLOW}⚠️  Warning: ${MEDIUM} medium-severity issue(s) found${NC}"
  jq -r '.findings[] | select(.severity == "medium") | "  - \(.file):\(.line // "?"): \(.message)"' "$REVIEW_FILE"
  echo ""
  echo -e "${GREEN}✅ PR Approved (with warnings)${NC}"
  exit 0
else
  echo -e "${GREEN}✅ PR Approved${NC}"
  exit 0
fi