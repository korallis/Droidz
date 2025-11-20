# Droidz Specialist Routing System

## Summary

The Droidz framework now includes an **intelligent routing system** that automatically delegates tasks to specialized AI agents based on the domain of work. This solves the problem of the framework defaulting to only `droidz-infra` and `droidz-codegen` for all tasks.

## Problem Solved

**Before:** The main assistant would handle all work directly or default to generic agents (codegen/infra), missing the opportunity to use domain specialists like UI designer, database architect, security auditor, etc.

**After:** Every user request automatically triggers a routing check that identifies which specialist should handle the work, ensuring optimal results with domain-specific expertise.

## How It Works

### 1. SessionStart Hook

When a Factory.ai session starts in a Droidz-enabled project, the `.factory/settings.json` file automatically injects **routing instructions** via a `SessionStart` hook.

**Location:** `.factory/settings.json`

```json
{
  "hooks": {
    "SessionStart": [
      {
        "name": "specialist-routing-system",
        "type": "prompt",
        "prompt": "🤖 DROIDZ SPECIALIST ROUTING SYSTEM..."
      }
    ]
  }
}
```

This hook:
- Loads at the start of every session
- Teaches the assistant about all available specialists
- Provides a routing decision tree
- Explains how to use the Task tool for delegation

### 2. UserPromptSubmit Hook

Before processing **every user request**, a mandatory routing check executes:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "name": "check-specialist-routing",
        "type": "prompt",
        "prompt": "🎯 ROUTING CHECK (MANDATORY)..."
      }
    ]
  }
}
```

This hook forces the assistant to ask:
- "Does this involve UI work?" → droidz-ui-designer
- "Does this involve database work?" → droidz-database-architect
- "Does this involve security?" → droidz-security-auditor
- And so on for all 14 specialists

### 3. Updated using-droidz Skill

The `.factory/skills/using-droidz/skill.md` file now includes:
- Complete routing decision tree (12-point checklist)
- Table of all specialists with their domains and keywords
- Examples of how to delegate using the Task tool
- Explanation of why specialists matter

## Available Specialists

| Specialist | Domain | Trigger Keywords |
|------------|--------|------------------|
| droidz-ui-designer | UI, components, styling | UI, button, form, modal, component, CSS, Tailwind |
| droidz-ux-designer | User flows, experience | UX, user journey, onboarding, usability |
| droidz-database-architect | Database, schemas, queries | database, schema, SQL, migration, Prisma |
| droidz-api-designer | API design, endpoints | API design, REST, GraphQL, OpenAPI |
| droidz-integration | External APIs, webhooks | integrate, Stripe, OAuth, webhook |
| droidz-test | Testing, coverage | test, coverage, E2E, Jest, Vitest |
| droidz-refactor | Code quality, tech debt | refactor, cleanup, tech debt |
| droidz-security-auditor | Security reviews | security, audit, XSS, OWASP |
| droidz-performance-optimizer | Performance tuning | optimize, slow query, bundle size |
| droidz-accessibility-specialist | Accessibility | a11y, WCAG, screen reader |
| droidz-infra | CI/CD, deployment | CI/CD, Docker, GitHub Actions |
| droidz-orchestrator | Complex multi-component | build auth (API + UI + tests) |
| droidz-codegen | Feature implementation | implement feature, bugfix |
| droidz-generalist | Unclear/mixed | exploratory work |

## Why This Approach?

### No AGENTS.md Conflicts

**Problem:** Users might already have an `AGENTS.md` file. We can't overwrite it.

**Solution:** Use Factory.ai hooks system to inject routing instructions at runtime, keeping the user's `AGENTS.md` intact.

### Automatic and Mandatory

The routing check happens **automatically before every request**, so specialists are never accidentally skipped.

### Skill-Based Documentation

The `using-droidz` skill provides comprehensive routing documentation that:
- Is version-controlled with the project
- Can be read by the assistant when needed
- Serves as both documentation and instruction

## Usage Examples

### Example 1: UI Work

```
User: "Build a login form with email and password"

Assistant's Internal Check (from hooks):
- Does this involve UI? YES
- Route to: droidz-ui-designer

Assistant Response:
"I'll delegate this to the UI Designer specialist..."

[Task tool call]
Task({
  subagent_type: "droidz-ui-designer",
  description: "Build login form",
  prompt: `Build a React login form with email/password inputs,
validation, submit handler, and error messages.`
});
```

### Example 2: Database Work

```
User: "Design the schema for users and posts"

Assistant's Internal Check:
- Does this involve database/schema? YES
- Route to: droidz-database-architect

Assistant Response:
"I'll delegate this to the Database Architect specialist..."

[Task tool call]
Task({
  subagent_type: "droidz-database-architect",
  description: "Design user/posts schema",
  prompt: `Design PostgreSQL schema for users and posts with
proper relationships, indexes, and migrations.`
});
```

### Example 3: Complex Feature (Orchestrator)

```
User: "Build a complete authentication system"

Assistant's Internal Check:
- Complex feature with API + UI + tests? YES
- Route to: droidz-orchestrator

Assistant Response:
"This requires multiple specialists working in parallel.
I'll use the Orchestrator to coordinate..."

[Task tool call]
Task({
  subagent_type: "droidz-orchestrator",
  description: "Build auth system",
  prompt: `Build complete authentication system with:
- Backend: JWT auth API
- Frontend: Login/register forms
- Tests: API + UI + E2E tests`
});
```

## Benefits

### 1. Better Results
- **Domain expertise:** Each specialist has optimized prompts for their domain
- **Consistent patterns:** Same specialist = same quality standards
- **Best practices:** Specialists follow industry-standard patterns

### 2. Faster Execution
- **Parallel work:** Multiple specialists can work simultaneously
- **Focused context:** No context pollution from unrelated domains
- **Efficient prompts:** No need to explain domain basics

### 3. Automatic Routing
- **No user action needed:** Routing happens transparently
- **No manual routing:** Assistant automatically picks the right specialist
- **No missed opportunities:** Every request checked

## Configuration Files

### `.factory/settings.json`
Contains the routing system hooks:
- `SessionStart` → Load routing instructions
- `UserPromptSubmit` → Check routing before every request

### `.factory/skills/using-droidz/skill.md`
Comprehensive routing documentation:
- 12-point routing checklist
- Specialist reference table
- Task tool usage examples

### `.factory/droids/*.md`
Individual specialist definitions:
- Each specialist's expertise and capabilities
- PROACTIVELY USED descriptions
- Auto-invoke triggers

## Troubleshooting

### Specialist Not Being Used

**Problem:** Main assistant handles work directly instead of delegating.

**Solutions:**
1. Check hooks are present in `.factory/settings.json`
2. Verify specialist exists in `.factory/droids/`
3. Use more specific language (trigger keywords)
4. Explicitly request: "Use the UI designer to..."

### Wrong Specialist Selected

**Problem:** Task delegated to wrong specialist.

**Solutions:**
1. Use clearer language in request
2. Explicitly name the specialist you want
3. Provide more domain context
4. Check if there's a more appropriate specialist

### Specialist Not Available

**Problem:** Routing suggests specialist that doesn't exist.

**Solutions:**
1. Run `/droids` to see available specialists
2. Check `.factory/droids/` directory
3. Install missing specialists from Droidz repo
4. Fall back to `droidz-generalist`

## Testing the Routing System

To verify the routing system works:

1. **Start a new session** in a Droidz-enabled project
2. **Make a UI request:** "Build a button component"
3. **Observe:** Assistant should delegate to `droidz-ui-designer`
4. **Make a database request:** "Design users table schema"
5. **Observe:** Assistant should delegate to `droidz-database-architect`

## Migration Guide

### For Existing Droidz Users

If you already have Droidz installed:

1. **Pull latest changes:**
   ```bash
   cd /path/to/Droidz
   git pull origin factory-ai
   ```

2. **Verify `.factory/settings.json` has routing hooks:**
   ```bash
   grep -A 10 "specialist-routing-system" .factory/settings.json
   ```

3. **Restart Factory.ai session:**
   ```bash
   # Exit current session
   # Start new session
   droid
   ```

4. **Test routing:**
   Make a UI or database request and verify delegation

### For New Installations

The routing system is automatically included when you install Droidz using the install script.

## Future Enhancements

Potential improvements to the routing system:

1. **Analytics:** Track which specialists are used most
2. **Custom routing rules:** Let users define custom routing logic
3. **Multi-specialist detection:** Auto-use orchestrator for complex requests
4. **Learning routing:** Improve routing based on user feedback

## References

- [Factory.ai Skills Documentation](https://docs.factory.ai/cli/configuration/skills)
- [Factory.ai Custom Droids](https://docs.factory.ai/cli/configuration/custom-droids)
- [Factory.ai Hooks System](https://docs.factory.ai/reference/hooks-reference)
- [Droidz GitHub Repository](https://github.com/yourusername/Droidz)

---

**Created:** 2025-11-20  
**Last Updated:** 2025-11-20  
**Status:** Production Ready ✅
