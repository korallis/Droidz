# 🎯 How Skills & Droids Work in Droidz

This guide explains how Droidz uses **Skills** (auto-activate) and **Droids** (delegated agents) to assist you, and how to know when they're active.

---

## 🔍 Two Types of AI Assistance

Droidz provides two complementary systems:

| Feature | **Skills** (45+) | **Droids** (14) |
|---------|-----------------|----------------|
| **Location** | `.factory/skills/` | `.factory/droids/` |
| **Activation** | Automatic (context-aware) | Explicit (via Task tool or delegation) |
| **Purpose** | Proactive guidance | Specialized execution |
| **You See** | Influence behavior silently | Clearly delegated tasks |
| **Examples** | TypeScript patterns, React hooks, TDD | UI design, API design, security audit |

---

## ⚡ Skills: Silent Auto-Activation

### What Are Skills?

**Skills** are proactive AI assistants that **automatically activate** based on your project context:

- Detect files you're working with (TypeScript, React, Next.js, etc.)
- Load relevant best practices and patterns
- Guide Claude's responses with domain expertise
- Activate **silently in the background**

### Example Skills

| Skill | Auto-Activates When | What It Does |
|-------|---------------------|--------------|
| **design** | Working on UI/UX | Design systems, accessibility, typography, liquid glass effects |
| **react** | `.tsx` / `.jsx` files | React hooks, patterns, performance optimization |
| **typescript** | `.ts` files | Type safety, generics, utility types |
| **test-driven-development** | Writing tests | TDD workflow (red → green → refactor) |
| **systematic-debugging** | Bug fixing | 4-phase debugging framework |
| **brainstorming** | Planning features | Collaborative ideation before coding |

**Total**: 45+ skills covering frameworks, workflows, security, testing, and more!

### How Do You Know a Skill Is Active?

**Skills activate silently** - you won't see explicit notifications. However, you'll notice:

1. **Improved Code Quality**
   - Suggestions follow best practices
   - TypeScript types are more precise
   - React components use proper hooks patterns

2. **Contextual Guidance**
   - Claude mentions patterns from the skill
   - Code examples match your project's framework
   - Security warnings for insecure code

3. **Skill-Specific Language**
   - Design skill → "Let's use design tokens instead of hardcoded values"
   - React skill → "Let's memoize this with useMemo to prevent re-renders"
   - TDD skill → "Let's write the test first before implementing"

4. **Check Loaded Skills** (CLI Command)
   ```bash
   droid
   # Skills auto-load based on your project files
   # You'll see their influence in Claude's responses
   ```

### When Skills Activate

Skills load automatically when Factory detects:

| Trigger | Loaded Skill(s) |
|---------|----------------|
| `package.json` with TypeScript | **typescript** skill |
| `*.tsx` or `*.jsx` files | **react** skill |
| `next.config.js` | **nextjs-16** skill |
| `convex/` directory | **convex** skill |
| Working in `.factory/skills/` | **writing-skills** skill |
| User says "let's brainstorm" | **brainstorming** skill |
| Running tests | **test-driven-development** skill |

**Result**: You get framework-specific expertise **without asking**!

---

## 🤖 Droids: Explicit Delegation

### What Are Droids?

**Droids** are **specialized AI agents** you explicitly invoke for complex tasks:

- Invoked via **Task tool** (`Task({subagent_type: "droidz-ui-designer", ...})`)
- Run independently with their own context
- Return results when complete
- **Clearly visible in Factory UI**

### Available Droids (14)

#### **Core Droids** (7)
1. **droidz-orchestrator** - Parallel task coordination
2. **droidz-codegen** - Feature implementation
3. **droidz-test** - Writing & fixing tests
4. **droidz-refactor** - Code improvements
5. **droidz-infra** - CI/CD, Docker, deployment
6. **droidz-integration** - External API integration
7. **droidz-generalist** - Fallback for misc tasks

#### **Specialized Droids** (7)
8. **droidz-ui-designer** - Modern CSS, design systems, **liquid glass effects**
9. **droidz-ux-designer** - User flows, journey mapping
10. **droidz-api-designer** - REST/GraphQL API design
11. **droidz-database-architect** - Schema design, optimization
12. **droidz-security-auditor** - OWASP Top 10, vulnerability scanning
13. **droidz-performance-optimizer** - Core Web Vitals, caching
14. **droidz-accessibility-specialist** - WCAG 2.2, ARIA, screen readers

### How Do You Know a Droid Is Active?

**Droids are explicitly visible** - you'll always know:

1. **Task Tool Invocation**
   ```
   Claude: "I'll delegate this to the UI designer droid..."
   
   [Task tool call shown in Factory UI]
   Task({
     subagent_type: "droidz-ui-designer",
     description: "Design dashboard UI",
     prompt: "Create a modern dashboard with cards..."
   })
   ```

2. **Factory UI Indicators**
   - Task delegation shows in conversation
   - Subagent name displayed
   - Progress updates appear
   - Results returned when complete

3. **Explicit Mentions**
   - Claude says: "Using droidz-orchestrator to coordinate parallel work"
   - Claude says: "Delegating security audit to droidz-security-auditor"

4. **Visible Results**
   - Droid returns comprehensive report
   - Shows what files were changed
   - Provides deliverables (specs, audits, code)

### When Droids Activate

Droids activate **only when delegated** by:

1. **Main Claude Agent** (orchestration)
   ```
   User: "Build authentication system"
   Claude: "I'll delegate to droids for parallel execution..."
   → Spawns droidz-codegen, droidz-test, droidz-security-auditor
   ```

2. **Orchestrator Pattern**
   ```
   /auto-parallel "implement payment integration"
   → droidz-orchestrator breaks into tasks
   → Spawns specialist droids for each stream
   ```

3. **User Request**
   ```
   User: "Use droidz-ui-designer to create the dashboard"
   Claude: "Delegating to droidz-ui-designer..."
   ```

---

## 🔄 Skills + Droids Working Together

### Example: Building a Feature

```
User: "Add a premium dashboard with glass effects"

1. **brainstorming skill** activates (planning)
   → Guides Claude through feature design

2. **design skill** activates (patterns)
   → Provides liquid glass knowledge, design tokens

3. **droidz-orchestrator droid** invoked (execution)
   → Breaks into parallel tasks

4. **droidz-ui-designer droid** delegated (UI work)
   → Implements glass effects with liquid glass patterns

5. **test-driven-development skill** activates (testing)
   → Guides test-first approach

6. **droidz-test droid** delegated (test implementation)
   → Writes comprehensive test suite

7. **verification-before-completion skill** activates (quality)
   → Ensures tests pass before claiming done
```

**Result**: Seamless collaboration between background skills and delegated droids!

---

## 📍 How to Check What's Active

### Check Loaded Skills
```bash
# Skills load automatically based on project files
ls .factory/skills/

# See which skills exist (45+ total)
```

### Check Available Droids
```bash
droid
/droids

# Shows all 14 droids
# ✓ droidz-orchestrator
# ✓ droidz-ui-designer
# ✓ droidz-security-auditor
# ... etc
```

### Check If Skills Are Enabled
```bash
droid
/settings
# Ensure "Custom Droids" is ON (enables droids)
# Skills are always active by default
```

---

## 🎓 Pro Tips

### For Skills (Silent)
- **Trust the guidance** - Skills influence Claude's responses for better quality
- **Watch for patterns** - Claude mentioning "design tokens" means design skill is active
- **Let them work** - Skills activate automatically based on context
- **No action needed** - Just work naturally, skills enhance responses

### For Droids (Explicit)
- **Watch for delegation** - Claude will say "I'm delegating to droidz-..."
- **Review results** - Droids return comprehensive reports
- **Check Task calls** - Visible in Factory UI conversation
- **Request specific droids** - "Use droidz-security-auditor to check this code"

### Combining Both
- **Skills guide droids** - design skill provides patterns, droidz-ui-designer uses them
- **Best of both worlds** - Background expertise + focused execution
- **Seamless UX** - Skills enhance, droids execute, you approve

---

## 🚀 Quick Reference

| I Want To... | Use... | How It Activates |
|--------------|--------|------------------|
| Get design best practices | **design skill** | Auto (when working on UI) |
| Implement a complex feature | **droidz-codegen** | Explicit delegation |
| Check security | **security skill** + **droidz-security-auditor** | Auto guidance + delegated audit |
| Optimize performance | **droidz-performance-optimizer** | Explicit delegation |
| Follow TDD | **test-driven-development skill** | Auto (when testing) |
| Build in parallel | **droidz-orchestrator** | Explicit delegation |
| Ensure accessibility | **design skill** + **droidz-accessibility-specialist** | Auto patterns + delegated audit |

---

## 💡 Example Session

```
You: "Design a premium dashboard with glass effects"

[design skill activates silently]
Claude: "I'll create a modern dashboard using design tokens and liquid glass effects.
         Let me delegate the UI implementation to our specialist..."

[droidz-ui-designer invoked explicitly]
Task({
  subagent_type: "droidz-ui-designer",
  description: "Premium dashboard UI",
  prompt: "Create dashboard with liquid glass panels, design tokens, responsive grid"
})

[design skill continues guiding]
Claude: "The UI designer will use:
         - Design tokens for consistency
         - Liquid glass with backdrop-filter (cross-browser fallback)
         - 8px grid system
         - Mobile-first responsive breakpoints"

[droidz-ui-designer completes]
Result: Created 5 components:
- Dashboard.tsx (glass panels)
- GlassCard.tsx (liquid glass effects)
- design-tokens.css (color/spacing)
- responsive.css (mobile-first)
- glass-effects.css (backdrop-filter + fallbacks)

[verification-before-completion skill activates]
Claude: "Let me verify this works..."
[Runs build, checks types, tests responsiveness]

Claude: "✅ Complete! Premium dashboard with liquid glass effects implemented.
         All components follow design system patterns."
```

**Notice**:
- Skills: Silent influence (design principles, patterns)
- Droids: Explicit delegation (UI implementation)
- Both work together seamlessly!

---

## 📚 Learn More

- **Skills Directory**: `.factory/skills/` (45+ proactive helpers)
- **Droids Directory**: `.factory/droids/` (14 specialist agents)
- **Enable Custom Droids**: `/settings` → Toggle "Custom Droids" ON
- **View Available Droids**: `/droids` command in Factory CLI

**Happy building with your AI team!** 🚀
