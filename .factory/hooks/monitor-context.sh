#!/bin/bash
# Context usage monitor - runs on each user prompt
# Suggests optimization if context window is filling up

set -e

# This would ideally get actual context usage from Claude
# For now, we'll provide a placeholder that can be enhanced

echo "📊 Monitoring context usage..."

# In real implementation, this would:
# 1. Get current token count from Claude API
# 2. Calculate percentage of max context window
# 3. Suggest optimization if >70%

# Placeholder logic:
# Check if session has been running for a while
session_length=$(ps -o etime= -p $$ 2>/dev/null | tr -d ' ' || echo "00:00")

# Convert to minutes
if [[ "$session_length" =~ ^([0-9]+):([0-9]+):([0-9]+)$ ]]; then
  hours="${BASH_REMATCH[1]}"
  minutes="${BASH_REMATCH[2]}"
  total_minutes=$((hours * 60 + minutes))
elif [[ "$session_length" =~ ^([0-9]+):([0-9]+)$ ]]; then
  minutes="${BASH_REMATCH[1]}"
  total_minutes=$minutes
else
  total_minutes=0
fi

# Suggest optimization if session is long (>30 min as proxy for context usage)
if [ "$total_minutes" -gt 30 ]; then
  echo "⚠️  Session has been running for ${total_minutes} minutes"
  echo "💡 Consider running /optimize-context to improve performance"
fi

exit 0
