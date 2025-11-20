#!/usr/bin/env bash
set -euo pipefail

# /gh-helper - Helper for GitHub CLI operations with correct field names
# Usage: /gh-helper pr-checks <pr-number>

COMMAND="${1:-}"
shift || true

case "$COMMAND" in
    pr-checks)
        PR_NUM="${1:-}"
        if [ -z "$PR_NUM" ]; then
            echo "Usage: /gh-helper pr-checks <pr-number>"
            exit 1
        fi
        
        # Get PR checks using correct JSON fields
        # Available fields: bucket, name, conclusion, detailsUrl
        # bucket categorizes: pass, fail, pending, skipping, cancel
        gh pr checks "$PR_NUM" --json name,bucket,conclusion,detailsUrl
        ;;
        
    pr-list)
        # List PRs with common fields
        gh pr list --json number,title,headRefName,url,state,author
        ;;
        
    pr-status)
        PR_NUM="${1:-}"
        if [ -z "$PR_NUM" ]; then
            echo "Usage: /gh-helper pr-status <pr-number>"
            exit 1
        fi
        
        # Show comprehensive PR status
        echo "=== PR #$PR_NUM Status ==="
        echo ""
        echo "Details:"
        gh pr view "$PR_NUM" --json number,title,state,author,headRefName,baseRefName | \
            jq -r '"Number: \(.number)\nTitle: \(.title)\nState: \(.state)\nAuthor: \(.author.login)\nBranch: \(.headRefName) -> \(.baseRefName)"'
        
        echo ""
        echo "Checks:"
        gh pr checks "$PR_NUM" --json name,bucket,conclusion | \
            jq -r '.[] | "  \(.name): \(.bucket) (\(.conclusion // "pending"))"'
        ;;
        
    *)
        echo "GitHub Helper Commands"
        echo ""
        echo "Usage: /gh-helper <command> [args]"
        echo ""
        echo "Commands:"
        echo "  pr-checks <number>   - Show PR check status (correct JSON fields)"
        echo "  pr-status <number>   - Show comprehensive PR status"
        echo "  pr-list              - List all PRs"
        echo ""
        echo "Note: This helper uses the correct GitHub CLI JSON fields:"
        echo "  - bucket (not status) - categorizes as pass/fail/pending"
        echo "  - conclusion - detailed result"
        echo "  - name - check name"
        echo "  - detailsUrl - link to details"
        ;;
esac
