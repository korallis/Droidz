# Droidz Framework Enhancement Plan
## Comprehensive Analysis Based on Factory.ai Documentation Research

**Research Date:** November 18, 2025  
**Version:** 2.6.0  
**Sources:** Factory.ai official docs, exa-code, ref documentation

---

## Executive Summary

After extensive research of Factory.ai's documentation and best practices, I've identified **12 major enhancement areas** that would significantly improve Droidz. This plan prioritizes features that:
1. Are well-documented in Factory.ai
2. Provide immediate value to users
3. Are technically feasible to implement
4. Align with Droidz's current architecture

---

## 🎯 Priority 1: Critical Missing Features

### 1. Hooks System (CRITICAL)
**Status:** ❌ Not implemented  
**Impact:** High - Enables automation and workflow customization

**What Factory.ai Has:**
- `PreToolUse` - Run before any tool execution (e.g., validate files before editing)
- `PostToolUse` - Run after tool execution (e.g., auto-format code)
- `UserPromptSubmit` - Run when user submits a prompt (e.g., inject context)
- `Notification` - Trigger on specific events (e.g., send desktop notifications)

**Implementation Needed:**
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Edit|Write",
      "hooks": [{
        "type": "command",
        "command": "prettier --check $FILE_PATH"
      }]
    }],
    "PostToolUse": [{
      "matcher": "Write",
      "hooks": [{
        "type": "command",
        "command": "git add $FILE_PATH"
      }]
    }]
  }
}
```

**Benefits:**
- Automatic code formatting before edits
- Git tracking of all changes
- Custom validation rules
- Team-wide consistency enforcement

**Files to Create:**
- `.factory/hooks/` directory
- Hook configuration system
- Documentation: `.factory/hooks/README.md`

---

### 2. MCP (Model Context Protocol) Integration
**Status:** ❌ Not implemented  
**Impact:** High - Connects to external tools and services

**What Factory.ai Has:**
MCP servers for:
- **Linear** - Issue tracking
- **Notion** - Documentation
- **Sentry** - Error monitoring
- **Slack** - Team communication
- **GitHub** - Repository management
- **Stripe** - Payment processing
- 100+ community servers

**Implementation Needed:**
```json
{
  "mcpServers": {
    "linear": {
      "type": "http",
      "url": "https://mcp.linear.app/mcp"
    },
    "notion": {
      "type": "http",
      "url": "https://mcp.notion.com/mcp"
    },
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem"]
    }
  }
}
```

**Benefits:**
- Pull context from Linear tickets
- Read Notion documentation
- Access error logs from Sentry
- Automated integrations without custom code

**Files to Create:**
- `.factory/mcp.json` configuration
- MCP server management system
- Documentation: `.factory/mcp/README.md`

---

### 3. Enhanced AGENTS.md Template
**Status:** ⚠️ Partial - Basic structure exists  
**Impact:** Medium - Improves AI context understanding

**What's Missing:**
Factory.ai's AGENTS.md includes:
- Dev environment tips (package manager, jump commands)
- Testing instructions (CI location, test patterns)
- PR instructions (title format, required checks)
- Security guidelines (what never to commit)
- Performance targets (bundle size, response times)

**Current Droidz:** Basic project overview

**Enhanced Template Needed:**
```markdown
# Project Name

## Dev Environment Tips
- Use `bun run where <package>` to jump to package
- Run `bun install --filter <package>` to add dependencies
- Check package.json `name` field for correct package name

## Testing Instructions
- Find CI plan in `.github/workflows/`
- Run `bun test --filter <package>` for all checks
- Focus on one test: `bun vitest run -t "<pattern>"`
- Add tests for code you change, even if not asked

## PR Instructions
- Title format: `[Component] Description`
- Always run `bun check` before committing
- Include: description, testing performed, screenshots for UI

## Security
- All API endpoints must validate input
- Use parameterized queries
- Never log sensitive data
- API keys in environment variables only

## Performance
- Images optimized before committing
- Frontend bundles < 500KB
- API endpoints < 200ms response
- Lazy loading for routes
```

**Benefits:**
- Droids make fewer mistakes
- Consistent code style
- Better test coverage
- Security best practices enforced

**Files to Update:**
- `.factory/templates/AGENTS.md`
- `.factory/docs/agents-md-guide.md`

---

## 🚀 Priority 2: Workflow & Automation

### 4. Headless Execution Mode (Droid Exec)
**Status:** ❌ Not implemented  
**Impact:** High - Enables CI/CD automation

**What Factory.ai Has:**
```bash
# Run in CI/CD
droid exec --auto high "run tests, fix issues, commit changes"

# Batch processing
droid exec --auto medium -f .factory/prompts/cleanup.md

# Piped input
git diff | droid exec "draft release notes"
```

**Implementation Needed:**
- Non-interactive execution mode
- Autonomy levels (low/medium/high)
- Output formats (text/json/stream-json)
- Exit codes for CI/CD integration

**Use Cases:**
- **CI/CD:** Auto-fix linting errors, update dependencies
- **Cron Jobs:** Weekly code cleanup, documentation updates
- **Pre-commit Hooks:** Format code, validate changes
- **Deployment:** Run tests, build, deploy

**Files to Create:**
- `.factory/scripts/exec-mode.ts`
- CI/CD examples: `.factory/examples/ci-cd/`
- Documentation: `.factory/docs/headless-execution.md`

---

### 5. Batch & Parallel Execution Patterns
**Status:** ⚠️ Partial - Orchestrator exists but limited  
**Impact:** Medium - Improves efficiency for large tasks

**Factory.ai Patterns:**
```bash
# Process multiple files
find . -name "*.legacy.js" | \
  xargs -I {} droid exec --auto low "migrate {} to TypeScript"

# Parallel ticket processing
linear issues list | jq '.[] | .id' | \
  xargs -P 4 -I {} droid exec "analyze ticket {}"

# Batch documentation updates
ls packages/*/README.md | \
  xargs -I {} droid exec "update docs in {}"
```

**Implementation Needed:**
- Parallel task queue
- Progress reporting
- Result aggregation
- Error handling and retry logic

**Files to Create:**
- `.factory/orchestrator/batch-processor.ts`
- Examples: `.factory/examples/batch/`

---

### 6. Memory System Enhancement
**Status:** ⚠️ Partial - Basic memory exists  
**Impact:** Medium - Improves context persistence

**Factory.ai Has:**
- **User Memory:** Personal preferences, dev environment, work history
- **Org Memory:** Team conventions, architecture patterns, security rules
- **Session Memory:** Conversation context, decisions made

**Current Droidz:** Limited memory in `.factory/memory/`

**Enhancement Needed:**
```json
{
  "user": {
    "preferences": {
      "diffStyle": "side-by-side",
      "explanationDepth": "concise",
      "testingApproach": "tdd"
    },
    "environment": {
      "os": "macOS",
      "shell": "zsh",
      "editor": "vscode"
    },
    "workHistory": [
      {"repo": "project-a", "lastWorked": "2025-11-18"},
      {"repo": "project-b", "lastWorked": "2025-11-17"}
    ]
  },
  "org": {
    "conventions": {
      "apiEndpoints": "snake_case",
      "commitFormat": "conventional",
      "prProcess": "2-reviewer-approval"
    },
    "architecture": {
      "backend": "microservices",
      "frontend": "react",
      "database": "postgresql"
    }
  }
}
```

**Files to Update:**
- `.factory/memory/user/preferences.json`
- `.factory/memory/org/conventions.json`
- Memory API: `.factory/scripts/memory-manager.ts`

---

## 🔧 Priority 3: Developer Experience

### 7. Interactive MCP Configuration UI
**Status:** ❌ Not implemented  
**Impact:** Low - Quality of life improvement

**What Factory.ai Has:**
- `/mcp` command opens UI to:
  - List all configured servers
  - View available tools per server
  - Enable/disable servers
  - Complete OAuth flows
  - Test connections

**Implementation:**
Terminal UI using `blessed` or `ink` for:
```
┌─ MCP Servers ───────────────────────────────┐
│ ✓ linear         (12 tools)     [Enabled]   │
│ ✓ notion         (8 tools)      [Enabled]   │
│ ✗ sentry         (6 tools)      [Disabled]  │
│ ⚠ github         (needs auth)               │
└─────────────────────────────────────────────┘
```

**Files to Create:**
- `.factory/ui/mcp-manager.tsx`
- Interactive flows for OAuth

---

### 8. Settings Management UI
**Status:** ⚠️ Partial - JSON config exists  
**Impact:** Low - Improves usability

**Factory.ai Has:**
`/settings` command for interactive configuration:
- Model selection
- Autonomy levels
- Diff mode preferences
- Tool allowlist/denylist
- Custom model configuration

**Implementation:**
```
┌─ Settings ──────────────────────────────────┐
│                                              │
│ Model:        [claude-sonnet-4.5]  ▼        │
│ Autonomy:     [●○○] Low                      │
│ Diff Mode:    [unified / side-by-side]      │
│                                              │
│ Tools:                                       │
│  ☑ Read    ☑ Write   ☑ Execute              │
│  ☑ Edit    ☐ Bash    ☐ MultiEdit            │
│                                              │
│           [Save]         [Cancel]            │
└──────────────────────────────────────────────┘
```

**Files to Create:**
- `.factory/ui/settings-manager.tsx`

---

### 9. Enhanced Spec Templates
**Status:** ⚠️ Partial - Basic templates exist  
**Impact:** Medium - Improves spec quality

**Factory.ai Spec Sections:**
1. **User Stories** - As a..., I want..., So that...
2. **Acceptance Criteria** - Given..., When..., Then...
3. **Technical Approach** - Architecture, patterns, libraries
4. **Security Considerations** - OWASP, GDPR, auth
5. **Performance Requirements** - Response times, scalability
6. **Testing Strategy** - Unit, integration, E2E
7. **Rollout Plan** - Phased deployment, feature flags

**Missing in Droidz:**
- Structured user stories
- Acceptance criteria format
- Performance requirements
- Rollout planning

**Files to Update:**
- `.factory/specs/templates/feature-spec.md`
- `.factory/specs/templates/epic-spec.md`
- Add: `.factory/specs/templates/refactor-spec.md`
- Add: `.factory/specs/templates/security-spec.md`

---

## 🏢 Priority 4: Enterprise Features

### 10. Team Collaboration Features
**Status:** ❌ Not implemented  
**Impact:** Low (for solo devs), High (for teams)

**What Factory.ai Has:**
- Shared sessions (team members can collaborate)
- Seat management (admin controls)
- Usage analytics (track droid usage)
- Audit logging (security & compliance)

**Implementation:**
```json
{
  "team": {
    "name": "Engineering Team",
    "members": [
      {"email": "dev1@company.com", "role": "admin"},
      {"email": "dev2@company.com", "role": "member"}
    ],
    "sharedSessions": [
      {"id": "session-123", "name": "Authentication Refactor"}
    ],
    "usage": {
      "tokensUsed": 1500000,
      "tokensLimit": 20000000
    }
  }
}
```

**Benefits:**
- Pair programming with AI
- Knowledge sharing across team
- Usage tracking for billing
- Compliance and audit trails

**Files to Create:**
- `.factory/team/config.json`
- `.factory/team/audit.log`
- Team management scripts

---

### 11. SSO & Enterprise Auth
**Status:** ❌ Not implemented  
**Impact:** Low (open source), High (enterprise)

**What Factory.ai Has:**
- SSO (Okta, Azure AD, Google Workspace)
- SAML/SCIM provisioning
- Role-based access control (RBAC)
- API key management

**Implementation:**
OAuth 2.0 flow for enterprise authentication:
- Company authentication via SSO
- Token refresh logic
- Session management
- Audit logging

**Files to Create:**
- `.factory/auth/sso-config.json`
- Auth flow documentation

---

### 12. Analytics & Monitoring Dashboard
**Status:** ❌ Not implemented  
**Impact:** Low - Nice to have

**What Factory.ai Has:**
```
┌─ Droidz Analytics ──────────────────────────┐
│                                              │
│ This Month:                                  │
│   Tasks Completed: 147                       │
│   Lines Changed:   12,450                    │
│   PRs Created:     23                        │
│   Time Saved:      ~40 hours                 │
│                                              │
│ Most Used Droids:                            │
│   1. droidz-codegen       (89 tasks)         │
│   2. droidz-test          (34 tasks)         │
│   3. droidz-refactor      (24 tasks)         │
│                                              │
│ Token Usage: ████████░░ 78% (15.6M / 20M)   │
└──────────────────────────────────────────────┘
```

**Files to Create:**
- `.factory/analytics/tracker.ts`
- `.factory/analytics/dashboard.tsx`
- `.factory/analytics/reports/`

---

## 📋 Implementation Roadmap

### Phase 1: Foundation (v2.7.0) - 2 weeks
**Goal:** Core infrastructure for hooks and MCP
- [ ] Hooks system architecture
- [ ] MCP configuration format
- [ ] Basic hook examples (format, lint)
- [ ] MCP stdio server support
- [ ] Documentation

**Deliverables:**
- `.factory/hooks/` system
- `.factory/mcp.json` support
- 3-5 example hooks
- Updated documentation

---

### Phase 2: Integration (v2.8.0) - 2 weeks
**Goal:** MCP HTTP servers and real integrations
- [ ] HTTP MCP server support
- [ ] OAuth flow handling
- [ ] Linear integration example
- [ ] Notion integration example
- [ ] Interactive `/mcp` UI

**Deliverables:**
- HTTP transport support
- OAuth authentication
- 2+ working integrations
- MCP management UI

---

### Phase 3: Automation (v2.9.0) - 2 weeks
**Goal:** Headless execution and batch processing
- [ ] `droidz exec` command
- [ ] Autonomy levels (low/medium/high)
- [ ] CI/CD examples
- [ ] Batch processing patterns
- [ ] Output format options

**Deliverables:**
- Headless execution mode
- 5+ CI/CD examples
- Batch processing scripts
- GitHub Actions workflows

---

### Phase 4: Enhancement (v3.0.0) - 3 weeks
**Goal:** Memory system and DX improvements
- [ ] Enhanced memory system
- [ ] Improved AGENTS.md template
- [ ] Better spec templates
- [ ] Settings UI
- [ ] Analytics tracking (basic)

**Deliverables:**
- Memory API
- Enhanced templates
- Interactive UIs
- Usage analytics

---

### Phase 5: Enterprise (v3.1.0) - 4 weeks
**Goal:** Team features and enterprise auth
- [ ] Team collaboration features
- [ ] SSO/OAuth integration
- [ ] Audit logging
- [ ] Analytics dashboard
- [ ] Enterprise documentation

**Deliverables:**
- Team management
- SSO support
- Full analytics
- Enterprise guide

---

## 🎯 Quick Wins (Can implement immediately)

### 1. Enhanced AGENTS.md Template (1-2 hours)
**File:** `.factory/templates/AGENTS.md`
**Benefit:** Better AI context immediately

### 2. Basic Hooks Documentation (1 hour)
**File:** `.factory/hooks/README.md`
**Benefit:** Sets expectations for future feature

### 3. MCP Configuration Template (1 hour)
**File:** `.factory/mcp.json.template`
**Benefit:** Prepares for MCP integration

### 4. Improved Spec Templates (2-3 hours)
**Files:** `.factory/specs/templates/*.md`
**Benefit:** Higher quality specs

### 5. CI/CD Example Workflows (2 hours)
**Files:** `.factory/examples/ci-cd/*.yml`
**Benefit:** Shows automation potential

---

## 📊 Feature Comparison

| Feature | Droidz v2.6.0 | Factory.ai | Priority | Effort |
|---------|---------------|------------|----------|--------|
| Hooks System | ❌ | ✅ | Critical | High |
| MCP Integration | ❌ | ✅ | Critical | High |
| AGENTS.md | ⚠️ Basic | ✅ Complete | High | Low |
| Headless Exec | ❌ | ✅ | High | Medium |
| Batch Processing | ⚠️ Limited | ✅ | Medium | Medium |
| Memory System | ⚠️ Basic | ✅ Advanced | Medium | Medium |
| MCP UI | ❌ | ✅ | Low | Medium |
| Settings UI | ⚠️ JSON only | ✅ Interactive | Low | Low |
| Spec Templates | ⚠️ Basic | ✅ Complete | Medium | Low |
| Team Features | ❌ | ✅ | Low | High |
| SSO/Auth | ❌ | ✅ | Low | High |
| Analytics | ❌ | ✅ | Low | Medium |

---

## 💡 Key Recommendations

### Immediate Actions (This Week)
1. **Create hooks documentation** - Sets expectations
2. **Enhance AGENTS.md template** - Immediate value
3. **Add MCP configuration template** - Prepares for future
4. **Improve spec templates** - Better quality

### Short Term (Next Month)
1. **Implement hooks system** - Foundation for automation
2. **Add MCP stdio support** - Basic integrations
3. **Create CI/CD examples** - Show automation value
4. **Build basic analytics** - Track usage

### Long Term (Next Quarter)
1. **Full MCP HTTP support** - Rich integrations
2. **Headless execution mode** - CI/CD automation
3. **Team collaboration features** - Multi-user support
4. **Enterprise authentication** - Corporate readiness

---

## 🔗 Resources & References

### Factory.ai Documentation
- Hooks: https://docs.factory.ai/cli/configuration/hooks-guide
- MCP: https://docs.factory.ai/cli/configuration/mcp
- AGENTS.md: https://docs.factory.ai/cli/configuration/agents-md
- Droid Exec: https://docs.factory.ai/cli/droid-exec/overview
- Custom Droids: https://docs.factory.ai/cli/configuration/custom-droids

### Community Resources
- MCP Servers: https://mcpservers.org/
- Awesome MCP: https://github.com/punkpeye/awesome-mcp-servers
- Model Context Protocol: https://modelcontextprotocol.io

### Similar Projects
- Claude Code: https://claude.ai/docs
- Cursor: https://cursor.sh
- Cody: https://sourcegraph.com/cody

---

## 📝 Notes & Considerations

### What NOT to Add
1. **Web UI** - CLI-first tool, web adds complexity
2. **Custom AI Training** - Use existing models
3. **Code Review AI** - Too subjective, low ROI
4. **IDE Plugins** - Maintain CLI focus
5. **Built-in Git UI** - Use existing git tools

### Architectural Decisions
1. **Hooks:** Use JSON-RPC format (matches Factory.ai)
2. **MCP:** Support both stdio and HTTP transports
3. **Memory:** JSON files (simple, version-controllable)
4. **Exec Mode:** Subprocess with JSON output
5. **Config:** Hierarchical (user < project < org)

### Success Metrics
- **Adoption:** 100+ GitHub stars in 3 months
- **Usage:** 1000+ hook executions/week
- **Integrations:** 5+ MCP servers available
- **CI/CD:** 50+ GitHub Actions using exec mode
- **Community:** 10+ community contributions

---

## 🤝 Contributing

Want to help implement these features?

1. Pick a feature from Priority 1 or Quick Wins
2. Create an issue on GitHub
3. Submit a PR with implementation
4. Update documentation
5. Add examples

---

**Generated:** November 18, 2025  
**By:** Droid Research Analysis  
**For:** Droidz Framework Enhancement  
**Version:** 2.6.0 → 3.1.0 Roadmap
