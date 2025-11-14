---
description: Orchestrate parallel task execution from a single description  
requires-arguments: true
---

# /parallel - One-Command Orchestration

Analyzes your request, generates tasks, and orchestrates parallel execution - all in one command.

**Usage:** `/parallel "your task description"`

## Example

```
/parallel "create a simple REST API for managing todo items"
```

This will:
1. Analyze your request
2. Generate 3-5 tasks with dependencies
3. Execute them in parallel phases
4. Report results

Use `/status` and `/summary` to monitor progress.

<execute>
# Get the user's request
REQUEST="$ARGUMENTS"

if [ -z "$REQUEST" ]; then
  echo "❌ Please provide a description of what to build"
  echo ""
  echo "Usage: /parallel \"description of what to build\""
  echo ""
  echo "Examples:"
  echo "  /parallel \"create REST API for todo items\""
  echo "  /parallel \"add authentication with login and register\""
  exit 1
fi

echo "🚀 Starting parallel orchestration..."
echo ""
echo "Request: $REQUEST"
echo ""
echo "This will spawn droidz-orchestrator to analyze and execute your request."
echo ""

# The orchestrator agent will:
# 1. Analyze the request
# 2. Generate tasks.json with dependencies
# 3. Run orchestrator.sh
# 4. Monitor and report progress

# Note: This is a placeholder - the actual Task spawning happens via Factory.ai's Task tool
echo "⚠️  Note: This command requires Factory.ai's Task tool to spawn droidz-orchestrator"
echo "The full implementation uses: Task(droidz-orchestrator) with prompt"
</execute>
