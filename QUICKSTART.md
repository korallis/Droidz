# Droidz Quick Start

Get started in 2 minutes.

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/main/scripts/install.sh | bash
```

**Verify:**
```bash
ls .claude/agents/  # Should see 5 droids
```

---

## Use

```bash
droid
```

Then:
```
@droidz-orchestrator I want to build a recipe app with Next.js 14 and Supabase
```

---

## What Happens

### 1. Planning (with Exa research)
```
→ Research similar products
→ Create mission.md
→ Create roadmap.md  
→ Choose tech stack
```

### 2. Specification (with Ref docs)
```
→ Pick a feature
→ Research documentation
→ Create detailed spec.md
→ Break into parallel tasks
```

### 3. Implementation (parallel)
```
→ Foundation work (sequential)
→ 5 workers execute simultaneously
→ Each in isolated git worktree
→ Integration work (sequential)
```

### 4. Verification
```
→ Run all tests
→ Check standards
→ Functional testing
→ Generate report
```

---

## The 5 Droids

| Droid | Purpose |
|-------|---------|
| `@droidz-orchestrator` | **Start here** - Coordinates everything |
| `@droidz-planner` | Product planning with Exa research |
| `@droidz-spec-writer` | Specifications with Ref docs |
| `@droidz-implementer` | Parallel workers (spawned automatically) |
| `@droidz-verifier` | Quality assurance |

---

## Key Files

```
.claude/agents/          # 5 custom droids
workflows/               # How each phase works
  ├── planning/
  ├── specification/
  └── implementation/
standards/              # Project conventions (customize!)
  ├── coding-conventions.md
  ├── architecture.md
  └── security.md
droidz/                 # Generated specs and products
config.yml              # Configuration
```

---

## Common Commands

**Planning only:**
```
@droidz-planner Create a product plan for [idea]
```

**Spec only:**
```
@droidz-spec-writer Create spec for "User Authentication"
```

**Verify work:**
```
@droidz-verifier Verify droidz/specs/user-auth/
```

**Full workflow:**
```
@droidz-orchestrator Build [feature]
```

---

## Configuration

Edit `config.yml` to customize:

```yaml
parallel:
  enabled: true
  max_concurrent_tasks: 5    # Change this! (Default: 5, Range: 1-10)
  workspace_mode: worktree   # worktree | clone | branch
  
use_exa_research: true       # Enable Exa for research
use_ref_docs: true           # Enable Ref for docs
```

**Customize Parallel Workers:**
- **Default: 5 workers** (good for most projects)
- **Increase to 8-10** for large features with many independent tasks
- **Decrease to 2-3** for tightly coupled work or limited resources

More details in [README.md](README.md#customizing-parallel-execution)

---

## Troubleshooting

**Empty directories after install?**
→ GitHub CDN cache. Use commit SHA:
```bash
curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/ce26341/scripts/install.sh | bash
```

**Droids not showing?**
→ Check: `ls .claude/agents/` should show 5 files

**Need help?**
→ [INSTALL.md](INSTALL.md) - Complete guide
→ [README.md](README.md) - Full documentation
→ [Issues](https://github.com/korallis/Droidz/issues) - Report bugs

---

## Example Session

```
You:
@droidz-orchestrator I want to build a bookmark manager with tags and sharing

Orchestrator:
Let's plan your product! I'll research similar bookmark managers...

[Uses Exa to research]
[Creates mission, roadmap, tech stack]

Your roadmap has 6 features:
1. User Authentication
2. Bookmark CRUD
3. Tagging System
4. Search & Filter
5. Sharing
6. Browser Extension

Let's implement: "User Authentication"

[Delegates to @droidz-spec-writer]
[Spec writer researches auth docs with Ref]
[Creates detailed spec with 4 parallel task groups]

Launching 4 parallel workers in isolated worktrees...

Worker 1: ✅ Login Component
Worker 2: ✅ Auth Service
Worker 3: ✅ Session Management
Worker 4: ✅ User Profile

Merging work... Running integration tests...

[Delegates to @droidz-verifier]

Verifier: ✅ All tests passing
Verifier: ✅ Standards compliant
Verifier: ✅ Feature complete

Feature "User Authentication" is done! Next feature?
```

---

## Links

- **GitHub:** https://github.com/korallis/Droidz
- **Full README:** [README.md](README.md)
- **Installation Guide:** [INSTALL.md](INSTALL.md)
- **Workflows:** [workflows/](workflows/)
- **Standards:** [standards/](standards/)

---

Built for developers who want **structured, research-driven, parallel AI development** 🚀
