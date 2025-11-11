# Droidz → Claude Code 2: Advanced Context Management & Auto-Standards

## 🎯 Enhanced Vision

Transform Droidz into the **smartest Claude Code framework** by implementing:
1. **Multi-layer hierarchical context** (inspired by Factory.ai)
2. **Automatic tech stack detection & standards generation**
3. **Intelligent context optimization** across all agents
4. **Git worktree parallel execution** (keep existing strength)

---

## 📚 Context Management: The Factory.ai Way

### **Multi-Layer Context Architecture**

Factory.ai uses 4 context layers. We'll implement all 4 + enhancements:

#### **Layer 1: Hierarchical CLAUDE.md Files**

**Current Approach (Droidz):**
- Single `.claude/CLAUDE.md` at root
- All standards in one file

**Enhanced Approach (inspired by Factory + Claude Code):**
```
project/
├── CLAUDE.md                    # Root: Project-wide standards
├── .claude/
│   ├── standards/              # NEW: Auto-generated standards
│   │   ├── react.md           # Framework-specific rules
│   │   ├── typescript.md      # Language-specific rules
│   │   ├── security.md        # Security best practices
│   │   └── testing.md         # Testing standards
│   ├── memory/                # NEW: Persistent agent memory
│   │   ├── user/              # Per-user preferences
│   │   └── org/               # Team-wide knowledge
│   └── agents/                # Subagent definitions
├── src/
│   ├── CLAUDE.md              # Frontend-specific standards
│   ├── components/
│   │   └── CLAUDE.md          # Component-specific patterns
│   └── api/
│       └── CLAUDE.md          # Backend-specific standards
└── tests/
    └── CLAUDE.md              # Testing-specific standards
```

**How It Works:**
1. **Auto-merging:** When agent works on `src/components/Button.tsx`:
   - Loads `/CLAUDE.md` (root)
   - Merges `src/CLAUDE.md` (frontend)
   - Merges `src/components/CLAUDE.md` (components)
   - Loads `.claude/standards/react.md` (framework)
   - Loads `.claude/standards/typescript.md` (language)

2. **Inheritance:** Child CLAUDE.md files extend parent standards
3. **Specificity wins:** More specific context overrides general

#### **Layer 2: Auto-Generated Standards from Tech Stack**

**Skill: `tech-stack-analyzer`** (Auto-activates on new projects)

```typescript
// Detects tech stack and generates standards
class TechStackAnalyzer {
  async analyze(): Promise<ProjectStandards> {
    // 1. Detect package manager
    const pkgManager = this.detectPackageManager(); // bun, npm, pnpm, yarn
    
    // 2. Parse package.json
    const packageJson = await this.readPackageJson();
    
    // 3. Detect frameworks
    const frameworks = this.detectFrameworks(packageJson);
    // React, Vue, Next.js, Nuxt, Express, Fastify, NestJS, etc.
    
    // 4. Detect languages
    const languages = this.detectLanguages(packageJson);
    // TypeScript, JavaScript, Python, Rust, Go
    
    // 5. Detect testing frameworks
    const testFramework = this.detectTestFramework(packageJson);
    // Jest, Vitest, Playwright, Cypress
    
    // 6. Detect build tools
    const buildTool = this.detectBuildTool(packageJson);
    // Vite, Webpack, Rollup, esbuild, Bun
    
    // 7. Detect linters/formatters
    const linters = this.detectLinters(packageJson);
    // ESLint, Prettier, Biome
    
    // 8. Generate framework-specific standards
    return this.generateStandards({
      pkgManager,
      frameworks,
      languages,
      testFramework,
      buildTool,
      linters
    });
  }
  
  detectFrameworks(pkg: PackageJson): string[] {
    const deps = { ...pkg.dependencies, ...pkg.devDependencies };
    const detected = [];
    
    if (deps['react']) detected.push('react');
    if (deps['next']) detected.push('nextjs');
    if (deps['vue']) detected.push('vue');
    if (deps['nuxt']) detected.push('nuxt');
    if (deps['@angular/core']) detected.push('angular');
    if (deps['svelte']) detected.push('svelte');
    if (deps['express']) detected.push('express');
    if (deps['fastify']) detected.push('fastify');
    if (deps['@nestjs/core']) detected.push('nestjs');
    
    return detected;
  }
  
  async generateStandards(stack: TechStack): Promise<void> {
    // Generate React standards if React detected
    if (stack.frameworks.includes('react')) {
      await this.generateReactStandards(stack);
    }
    
    // Generate TypeScript standards if TS detected
    if (stack.languages.includes('typescript')) {
      await this.generateTypeScriptStandards(stack);
    }
    
    // Generate testing standards based on framework
    await this.generateTestingStandards(stack);
    
    // Generate security standards
    await this.generateSecurityStandards(stack);
    
    // Generate performance standards
    await this.generatePerformanceStandards(stack);
  }
  
  async generateReactStandards(stack: TechStack): Promise<void> {
    const standards = `
# React Development Standards

## Component Patterns

### Functional Components (Required)
- Use functional components with hooks
- Avoid class components unless legacy
- Co-locate component logic with UI

### Hooks Best Practices
\`\`\`typescript
// ✅ Good: Custom hooks for reusable logic
function useUserData(userId: string) {
  const [user, setUser] = useState<User | null>(null);
  
  useEffect(() => {
    fetchUser(userId).then(setUser);
  }, [userId]);
  
  return user;
}

// ❌ Bad: Logic in component
function UserProfile({ userId }: Props) {
  const [user, setUser] = useState<User | null>(null);
  
  useEffect(() => {
    fetch(\`/api/users/\${userId}\`).then(r => r.json()).then(setUser);
  }, [userId]);
  
  return <div>{user?.name}</div>;
}
\`\`\`

### State Management
${stack.frameworks.includes('nextjs') ? `
- **Server Components:** Use React Server Components by default (Next.js 13+)
- **Client State:** useState/useReducer for local state
- **Global State:** Context API for simple cases, ${this.detectStateManager(stack)} for complex
` : `
- **Local State:** useState/useReducer
- **Global State:** ${this.detectStateManager(stack)}
`}

### Performance
- Memoize expensive computations with useMemo
- Memoize callbacks with useCallback when passed to memoized children
- Use React.memo for pure components that re-render often
- Lazy load routes and heavy components

## File Structure
\`\`\`
src/
├── components/
│   ├── ui/              # Reusable UI components
│   ├── features/        # Feature-specific components
│   └── layouts/         # Layout components
├── hooks/               # Custom hooks
├── utils/               # Utility functions
├── types/               # TypeScript types
└── app/ or pages/       # Routes
\`\`\`

## Testing
- Test user behavior, not implementation
- Use ${stack.testFramework || 'React Testing Library'}
- Avoid testing library internals
- Test accessibility

## Never
- Never mutate state directly (use setters)
- Never use index as key in lists (unless static)
- Never ignore ESLint warnings without justification
- Never skip accessibility attributes (aria-*, role)
`;
    
    await this.writeFile('.claude/standards/react.md', standards);
  }
  
  async generateTypeScriptStandards(stack: TechStack): Promise<void> {
    const standards = `
# TypeScript Development Standards

## Type Safety

### Strict Mode (Required)
\`\`\`json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
\`\`\`

### Type Annotations
\`\`\`typescript
// ✅ Good: Explicit types for clarity
function calculateTotal(items: CartItem[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// ❌ Bad: any type
function processData(data: any): any {
  return data.map((x: any) => x.value);
}

// ✅ Good: Proper generics
function processData<T extends { value: number }>(data: T[]): number[] {
  return data.map(x => x.value);
}
\`\`\`

### Avoid \`any\`
- Use \`unknown\` when type is truly unknown
- Use \`never\` for impossible states
- Create proper types/interfaces

### Utility Types
\`\`\`typescript
// Partial, Required, Pick, Omit, Record, etc.
type UpdateUserDTO = Partial<User>;
type UserKeys = keyof User;
type UserWithoutPassword = Omit<User, 'password'>;
\`\`\`

## Naming Conventions
- **Types/Interfaces:** PascalCase (\`UserProfile\`, \`ApiResponse\`)
- **Enums:** PascalCase (\`UserRole\`, \`Status\`)
- **Variables/Functions:** camelCase (\`userId\`, \`fetchUser\`)
- **Constants:** SCREAMING_SNAKE_CASE (\`MAX_RETRY_COUNT\`)

## Never
- Never use \`@ts-ignore\` (fix the type issue instead)
- Never use \`as any\` (use proper type narrowing)
- Never leave unused imports
`;
    
    await this.writeFile('.claude/standards/typescript.md', standards);
  }
  
  async generateSecurityStandards(stack: TechStack): Promise<void> {
    const standards = `
# Security Best Practices

## Environment Variables
\`\`\`typescript
// ✅ Good: Environment variables for secrets
const apiKey = process.env.API_KEY;

// ❌ Bad: Hardcoded secrets
const apiKey = 'sk_live_abc123'; // NEVER
\`\`\`

## Input Validation
${stack.frameworks.includes('express') || stack.frameworks.includes('fastify') ? `
### API Endpoints
\`\`\`typescript
import { z } from 'zod';

const UserSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

app.post('/users', async (req, res) => {
  // Validate before processing
  const result = UserSchema.safeParse(req.body);
  if (!result.success) {
    return res.status(400).json({ errors: result.error });
  }
  
  const user = await createUser(result.data);
  res.json(user);
});
\`\`\`
` : ''}

## SQL Injection Prevention
\`\`\`typescript
// ✅ Good: Parameterized queries
db.query('SELECT * FROM users WHERE id = $1', [userId]);

// ❌ Bad: String concatenation
db.query(\`SELECT * FROM users WHERE id = '\${userId}'\`); // VULNERABLE
\`\`\`

## XSS Prevention
${stack.frameworks.includes('react') ? `
\`\`\`typescript
// ✅ Good: React escapes by default
<div>{userInput}</div>

// ❌ Bad: Dangerous HTML insertion
<div dangerouslySetInnerHTML={{ __html: userInput }} /> // Only with sanitized HTML
\`\`\`
` : ''}

## Authentication
- Store passwords with bcrypt (12+ rounds)
- Use JWTs with short expiration
- Implement rate limiting on auth endpoints
- Require HTTPS in production

## Never
- Never commit API keys or secrets
- Never trust user input without validation
- Never use MD5 or SHA1 for passwords
- Never expose stack traces to users in production
`;
    
    await this.writeFile('.claude/standards/security.md', standards);
  }
}
```

**Automatic Triggers:**
- **SessionStart hook:** Run tech stack analyzer
- **File changes in package.json:** Re-analyze and update standards
- **New framework added:** Generate new standards file

#### **Layer 3: Dynamic Context Selection**

**Skill: `context-optimizer`** (Auto-activates when context >70% full)

```typescript
// Intelligently manages context window
class ContextOptimizer {
  async optimize(currentContext: ContextWindow): Promise<OptimizedContext> {
    // 1. Identify what's critical for current task
    const taskContext = this.extractTaskContext(currentContext);
    
    // 2. Hierarchical summarization of old conversation
    const recentTurns = currentContext.messages.slice(-10); // Keep last 10 verbatim
    const olderTurns = currentContext.messages.slice(0, -10);
    const summary = await this.summarize(olderTurns);
    
    // 3. Selective code context
    const relevantFiles = this.rankFilesByRelevance(currentContext.files, taskContext);
    const topFiles = relevantFiles.slice(0, 5); // Keep top 5 most relevant
    
    // 4. Compact tool outputs
    const compactedTools = this.compactToolResults(currentContext.toolCalls);
    
    return {
      summary,           // Compressed old context
      recentTurns,      // Recent verbatim
      topFiles,         // Most relevant code
      compactedTools,   // Compressed tool outputs
      standards: currentContext.standards // Always keep standards
    };
  }
  
  rankFilesByRelevance(files: CodeFile[], task: TaskContext): CodeFile[] {
    // Rank by:
    // 1. Semantic similarity to current task
    // 2. Recently accessed files
    // 3. Import relationships
    // 4. Test files for code under test
    return files
      .map(file => ({
        file,
        score: this.calculateRelevanceScore(file, task)
      }))
      .sort((a, b) => b.score - a.score)
      .map(x => x.file);
  }
  
  async summarize(turns: ConversationTurn[]): Promise<string> {
    // Progressive summarization: older = more compressed
    const grouped = this.groupByPhase(turns);
    
    return grouped.map(phase => {
      if (phase.age < 10) return phase.verbatim; // Recent: keep full
      if (phase.age < 50) return this.mediumSummary(phase); // Medium: brief summary
      return this.compactSummary(phase); // Old: very brief
    }).join('\n\n');
  }
}
```

#### **Layer 4: Persistent Agent Memory**

**File: `.claude/memory/user/<username>.json`**
```json
{
  "preferences": {
    "diffViewStyle": "split",
    "explanationDepth": "detailed",
    "testingApproach": "tdd",
    "namingConventions": {
      "functions": "camelCase",
      "components": "PascalCase"
    }
  },
  "workHistory": {
    "repositories": [
      "org/project-a",
      "org/project-b"
    ],
    "commonPatterns": [
      "Prefers custom hooks over inline logic",
      "Uses Zod for validation",
      "Follows Repository pattern for data access"
    ]
  },
  "developmentEnvironment": {
    "os": "macOS",
    "editor": "VSCode",
    "terminal": "iTerm2",
    "containerRuntime": "Docker"
  }
}
```

**File: `.claude/memory/org/<org-name>.json`**
```json
{
  "standards": {
    "codeStyle": "Prettier with 2-space indents",
    "branchNaming": "feature/{ticket}-{description}",
    "commitFormat": "Conventional Commits",
    "prRequirements": [
      "Tests must pass",
      "Coverage must not decrease",
      "Must have approval from 1 reviewer",
      "Must pass linting"
    ]
  },
  "architecture": {
    "patterns": [
      "Event-driven for async operations",
      "Repository pattern for data access",
      "CQRS for complex domains"
    ],
    "decisions": {
      "database": "PostgreSQL",
      "caching": "Redis",
      "messaging": "RabbitMQ",
      "hosting": "AWS ECS"
    }
  },
  "security": {
    "requireMFA": true,
    "secretsManager": "AWS Secrets Manager",
    "allowedLicenses": ["MIT", "Apache-2.0", "BSD-3-Clause"]
  }
}
```

**Skill: `memory-manager`** (Auto-activates to save/load memory)

```typescript
// Automatically remembers decisions and preferences
class MemoryManager {
  async recordDecision(decision: Decision): Promise<void> {
    const memory = await this.loadOrgMemory();
    
    memory.decisions.push({
      timestamp: new Date().toISOString(),
      category: decision.category,
      decision: decision.text,
      rationale: decision.rationale,
      participants: decision.participants
    });
    
    await this.saveOrgMemory(memory);
  }
  
  async loadRelevantMemory(task: TaskContext): Promise<MemoryContext> {
    const userMemory = await this.loadUserMemory();
    const orgMemory = await this.loadOrgMemory();
    
    // Filter to relevant subset
    return {
      userPreferences: userMemory.preferences,
      relatedPatterns: this.findRelatedPatterns(task, userMemory),
      relevantDecisions: this.findRelatedDecisions(task, orgMemory),
      standards: orgMemory.standards
    };
  }
}
```

---

## 🧬 Enhanced CLAUDE.md Template

**Root `/CLAUDE.md`:** (Auto-generated from tech stack)

```markdown
# ${PROJECT_NAME}

> **Last Generated:** ${TIMESTAMP}
> **Tech Stack:** ${DETECTED_FRAMEWORKS.join(', ')}
> **Languages:** ${DETECTED_LANGUAGES.join(', ')}

## Auto-Detected Configuration

**Package Manager:** ${PACKAGE_MANAGER}
**Build Tool:** ${BUILD_TOOL}
**Testing Framework:** ${TEST_FRAMEWORK}
**Linter:** ${LINTER}

## Development Commands

\`\`\`bash
# Install dependencies
${PACKAGE_MANAGER} install

# Start dev server
${PACKAGE_MANAGER} ${DEV_COMMAND}

# Run tests
${PACKAGE_MANAGER} ${TEST_COMMAND}

# Build for production
${PACKAGE_MANAGER} ${BUILD_COMMAND}

# Lint code
${PACKAGE_MANAGER} ${LINT_COMMAND}
\`\`\`

## Project Structure

\`\`\`
${PROJECT_ROOT}/
${DIRECTORY_STRUCTURE}
\`\`\`

## Framework-Specific Standards

${FRAMEWORK_STANDARDS_LINKS}

## Code Style

${AUTO_DETECTED_CODE_STYLE}

## Testing Strategy

${AUTO_DETECTED_TESTING_APPROACH}

## Never

${AUTO_GENERATED_ANTI_PATTERNS}

---

📝 **Note:** This file was auto-generated by Droidz tech-stack-analyzer.
To regenerate: Run \`/analyze-tech-stack\`
To customize: Edit manually (changes will be preserved on re-generation)
```

---

## 🔄 Slash Commands for Context Management

**`/analyze-tech-stack`**
- Scans package.json, lockfiles, config files
- Detects frameworks, languages, tools
- Generates framework-specific standards in `.claude/standards/`
- Updates root CLAUDE.md with detected config
- Creates directory-specific CLAUDE.md files

**`/optimize-context`**
- Analyzes current context window usage
- Shows token breakdown by category
- Suggests optimizations
- Optionally runs compaction

**`/load-memory [scope]`**
- Loads user or org memory into context
- Scope: `user`, `org`, `all`
- Shows relevant past decisions and patterns

**`/save-decision [category] [description]`**
- Saves architectural decision to org memory
- Categories: `architecture`, `security`, `performance`, `tooling`
- Accessible to all future sessions

---

## 🎯 Skills Enhancement

### **Skill: `standards-enforcer`**

**Auto-activates when:** Code changes detected

```markdown
---
name: standards-enforcer
description: Automatically enforces project standards from hierarchical CLAUDE.md files and generated framework-specific rules. Proactively activates when code is written or modified to ensure compliance.
---

You are the Standards Enforcer. Your job is to ensure all code follows project standards.

## Process

1. **Load all applicable standards:**
   - Root CLAUDE.md
   - Directory-specific CLAUDE.md files
   - Generated framework standards (.claude/standards/*.md)
   - Org memory (.claude/memory/org/*.json)

2. **Check code against standards:**
   - Code style compliance
   - Framework best practices
   - Security patterns
   - Performance guidelines
   - Testing requirements

3. **Report violations:**
   - List each violation with reference to standard
   - Suggest fix with code example
   - Prioritize by severity (critical, high, medium, low)

4. **Auto-fix when possible:**
   - Code formatting issues
   - Import organization
   - Common anti-patterns

## Example Output

\`\`\`
⚠️ Standards Violations Found:

1. CRITICAL: Hardcoded API key detected
   Location: src/api/client.ts:15
   Standard: .claude/standards/security.md - Environment Variables
   Fix: Move to process.env.API_KEY

2. HIGH: Missing error handling
   Location: src/api/fetchUser.ts:22
   Standard: src/api/CLAUDE.md - Error Handling Required
   Fix: Wrap in try-catch and return Result<User, Error>

3. MEDIUM: Component not memoized
   Location: src/components/UserList.tsx:45
   Standard: .claude/standards/react.md - Performance
   Fix: Wrap with React.memo()
\`\`\`
```

### **Skill: `context-compactor`**

**Auto-activates when:** Context window >80% full

```markdown
---
name: context-compactor
description: Automatically compacts context when window fills. Uses hierarchical summarization to preserve critical information while reducing token count.
---

You are the Context Compactor. Preserve essential information while reducing context size.

## Strategy

1. **Keep verbatim:**
   - Last 10 conversation turns
   - Current task description
   - All CLAUDE.md standards
   - Currently open files

2. **Summarize:**
   - Older conversation (11-50 turns): Brief summary per topic
   - Ancient conversation (50+ turns): One-line summary per phase

3. **Compress:**
   - Tool call results: Keep only final output, remove intermediate
   - Code examples: Keep interface, remove implementation unless relevant
   - Error messages: Keep error type and fix, remove full stack trace

4. **Archive to memory:**
   - Important decisions → .claude/memory/org/decisions.json
   - User preferences → .claude/memory/user/preferences.json
   - Architectural patterns discovered → .claude/memory/org/patterns.json

## Output

Provide compacted context that:
- Maintains task continuity
- Preserves all standards
- Keeps recent history verbatim
- Summarizes older context
- Reduces tokens by 60-80%
```

---

## 📊 Expected Improvements

### **Context Efficiency**
- **Before:** 50k tokens for 30-turn conversation
- **After:** 15k tokens (70% reduction) with better quality
- **Benefit:** Longer sessions, faster responses, lower costs

### **Standards Compliance**
- **Before:** Manual enforcement, inconsistent
- **After:** Auto-enforced on every file change
- **Benefit:** Higher code quality, fewer PR rejections

### **Onboarding Speed**
- **Before:** Manual CLAUDE.md creation (hours)
- **After:** Auto-generated from tech stack (seconds)
- **Benefit:** Instant project understanding

### **Team Alignment**
- **Before:** Standards in docs, inconsistently followed
- **After:** Enforced automatically via org memory
- **Benefit:** Consistent codebase, faster reviews

---

## 🛠️ Implementation Roadmap

### **Week 1: Foundation**
- [ ] Implement hierarchical CLAUDE.md loading
- [ ] Create tech stack analyzer skill
- [ ] Generate React standards template
- [ ] Generate TypeScript standards template

### **Week 2: Auto-Generation**
- [ ] Implement framework detection logic
- [ ] Create standards generator for 10 popular frameworks
- [ ] Build security standards generator
- [ ] Build testing standards generator

### **Week 3: Memory System**
- [ ] Implement user memory (preferences)
- [ ] Implement org memory (decisions)
- [ ] Create memory-manager skill
- [ ] Add memory hooks (SessionStart, Decision Made)

### **Week 4: Context Optimization**
- [ ] Implement context-optimizer skill
- [ ] Implement context-compactor skill
- [ ] Add context monitoring hooks
- [ ] Create /optimize-context command

### **Week 5: Integration & Testing**
- [ ] Integrate with existing orchestrator
- [ ] Test on real projects (React, Next.js, Express)
- [ ] Measure context efficiency gains
- [ ] Document all features

---

## 🎁 Bonus Features

### **1. Automatic Dependency Security Scanning**

**Skill: `dependency-auditor`** (Auto-activates on package.json change)

Scans dependencies for:
- Known vulnerabilities (CVE database)
- License violations (against org policy)
- Outdated packages (suggest updates)
- Unused dependencies (suggest removal)

### **2. Performance Budget Enforcement**

**Skill: `performance-guardian`** (Auto-activates on build)

Monitors:
- Bundle size (warn if >500KB)
- Lighthouse score (enforce >90)
- Core Web Vitals (LCP, FID, CLS)
- API response times (<200ms target)

### **3. Accessibility Compliance**

**Skill: `a11y-enforcer`** (Auto-activates on UI changes)

Checks:
- Semantic HTML usage
- ARIA attributes
- Keyboard navigation
- Screen reader compatibility
- Color contrast ratios

### **4. Documentation Auto-Update**

**Skill: `docs-updater`** (Auto-activates on code changes)

Updates:
- README.md (when commands change)
- API docs (when endpoints change)
- CHANGELOG.md (on version bump)
- Type definitions (JSDoc/TSDoc)

---

## ✅ Success Metrics

### **Quantitative:**
- ✅ 70% reduction in context token usage
- ✅ 90% standards compliance (up from 60%)
- ✅ 5-minute project onboarding (down from 2 hours)
- ✅ 80% fewer manual CLAUDE.md updates

### **Qualitative:**
- ✅ Developers can start contributing faster
- ✅ Codebase remains consistent across team
- ✅ Security issues caught before PR review
- ✅ Performance regressions prevented automatically

---

## 🚀 Next Steps

Once you approve this plan, we'll:
1. **Create `Claude-Code` branch**
2. **Implement tech stack analyzer** (Week 1-2)
3. **Build memory system** (Week 3)
4. **Add context optimization** (Week 4)
5. **Test & refine** (Week 5)
6. **Publish plugin** to community

This will make Droidz the **most intelligent Claude Code framework**, combining:
- ✅ Factory.ai's multi-layer context
- ✅ Automatic standards generation
- ✅ Intelligent context optimization
- ✅ Persistent cross-session memory
- ✅ Git worktree parallel execution

**The result:** A framework that understands your tech stack, enforces best practices automatically, and gets smarter over time. 🧠✨