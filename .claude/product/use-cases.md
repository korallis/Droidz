# Droidz Use Cases

Real-world scenarios where Droidz delivers exceptional value.

---

## Use Case 1: Building a Complete Authentication System

**Scenario**: Solo developer needs to add authentication to an existing web app.

**Traditional Approach** (Sequential):
1. Design auth API endpoints (1 hour)
2. Implement backend auth logic (4 hours)
3. Build login/register UI (3 hours)
4. Create password reset flow (2 hours)
5. Write comprehensive tests (3 hours)
6. Update documentation (1 hour)

**Total Time**: 14 hours sequential

**Droidz Approach** (Parallel):

```bash
# Create spec first
/create-spec feature auth-system

# Orchestrate parallel execution
/orchestrate spec:.claude/specs/active/auth-system.md
```

**Parallel Tasks**:
- **Task 1** (droidz-codegen): Backend API - 4 hours
- **Task 2** (droidz-codegen): Frontend UI - 3 hours
- **Task 3** (droidz-test): Test suite - 3 hours
- **Task 4** (droidz-integration): Email service integration - 2 hours

**Total Time**: ~4 hours (longest task) + 1 hour overhead = **5 hours**

**Speedup**: 2.8x faster ⚡

---

## Use Case 2: Sprint Planning Automation

**Scenario**: Team has 12 tickets ready for development in the current sprint.

**Traditional Approach**:
- Developer picks ticket
- Creates branch
- Implements feature
- Waits for review
- Picks next ticket
- Repeat...

**Droidz Approach**:

```bash
# Auto-fetch sprint tickets
/orchestrate linear:"sprint:current AND status:Todo AND label:auto-droidz"

# Creates 12 parallel worktrees
# Assigns specialist to each
# All work happens simultaneously
```

**Result**:
- 12 tickets → 12 worktrees
- 4-5 can be worked on simultaneously
- Completion time reduced from weeks to days

---

## Use Case 3: Major Refactoring Project

**Scenario**: Refactor legacy codebase to use new architecture pattern across 50+ files.

**Challenge**:
- Complex interdependencies
- Can't break existing functionality
- Need comprehensive testing

**Droidz Approach**:

```bash
# Create refactoring spec
/create-spec refactor legacy-to-modern

# Parse into tasks
/spec-to-tasks .claude/specs/active/legacy-to-modern.md

# Orchestrate
/orchestrate file:refactor-tasks.json
```

**Tasks** (8 parallel):
1. **droidz-refactor**: Update data models
2. **droidz-refactor**: Refactor API layer
3. **droidz-refactor**: Update UI components
4. **droidz-test**: Create migration tests
5. **droidz-test**: Update integration tests
6. **droidz-codegen**: Build backward compatibility layer
7. **droidz-codegen**: Create migration scripts
8. **droidz-generalist**: Update documentation

**Outcome**: Safe, tested refactoring in fraction of the time.

---

## Use Case 4: Microservices Development

**Scenario**: Building a new microservice with API, database, tests, and deployment.

**Components Needed**:
- REST API with 10 endpoints
- Database schema and migrations
- Unit tests
- Integration tests
- Docker configuration
- CI/CD pipeline
- API documentation

**Droidz Orchestration**:

```json
{
  "tasks": [
    {
      "key": "SVC-API",
      "title": "REST API Implementation",
      "specialist": "droidz-codegen"
    },
    {
      "key": "SVC-DB",
      "title": "Database Schema & Migrations",
      "specialist": "droidz-codegen"
    },
    {
      "key": "SVC-TESTS",
      "title": "Test Suite",
      "specialist": "droidz-test"
    },
    {
      "key": "SVC-DOCKER",
      "title": "Docker & Deployment",
      "specialist": "droidz-infra"
    },
    {
      "key": "SVC-DOCS",
      "title": "API Documentation",
      "specialist": "droidz-generalist"
    }
  ]
}
```

**Result**: Complete microservice in one orchestration session.

---

## Use Case 5: Bug Bash / Technical Debt Sprint

**Scenario**: Team dedicates sprint to fixing accumulated bugs and tech debt.

**Traditional Approach**:
- Prioritize bugs
- Assign to developers
- Fix one at a time
- Long feedback cycles

**Droidz Approach**:

```bash
# Fetch all high-priority bugs
/orchestrate linear:"label:bug AND priority:high AND status:Todo"

# Also handle tech debt
/orchestrate linear:"label:tech-debt AND sprint:current"
```

**Advantages**:
- All bugs tackled simultaneously
- Isolated worktrees prevent conflicts
- Fast feedback loop
- Complete sprint work in days instead of weeks

---

## Use Case 6: Multi-Framework Application

**Scenario**: Building app with React frontend, Python backend, and mobile app.

**Challenges**:
- Different tech stacks
- Different specialists needed
- Complex coordination

**Droidz Solution**:

```json
{
  "tasks": [
    {
      "key": "APP-WEB",
      "title": "React Web Application",
      "specialist": "droidz-codegen",
      "standards": ["react", "typescript", "tailwind"]
    },
    {
      "key": "APP-API",
      "title": "Python FastAPI Backend",
      "specialist": "droidz-codegen",
      "standards": ["python", "fastapi"]
    },
    {
      "key": "APP-MOBILE",
      "title": "React Native Mobile App",
      "specialist": "droidz-codegen",
      "standards": ["react-native", "typescript"]
    },
    {
      "key": "APP-INFRA",
      "title": "Shared Infrastructure",
      "specialist": "droidz-infra"
    }
  ]
}
```

Each specialist works with appropriate standards template.

---

## Use Case 7: Integration Sprint

**Scenario**: Integrate 5 different third-party services (Stripe, SendGrid, Twilio, AWS S3, Auth0).

**Complexity**:
- Different APIs
- Different authentication patterns
- Need error handling
- Comprehensive testing

**Droidz Orchestration**:

```bash
# Create integration tasks
/orchestrate file:integrations.json
```

5 parallel workspaces, each handling one integration:
- **droidz-integration** specialist for each
- Standards enforce: no hardcoded secrets, proper error handling
- Tests verify each integration
- All complete simultaneously

**Result**: All integrations done in time of one.

---

## Use Case 8: Code Quality Improvement Campaign

**Scenario**: Improve code quality across entire codebase.

**Goals**:
- Increase test coverage
- Reduce code duplication
- Improve type safety
- Update dependencies

**Droidz Approach**:

```bash
# Analyze and create improvement tasks
/orchestrate file:quality-improvements.json
```

**Parallel Tasks**:
1. **droidz-test**: Add tests to untested modules
2. **droidz-refactor**: Extract duplicated code
3. **droidz-codegen**: Add TypeScript types
4. **droidz-infra**: Update dependencies safely
5. **droidz-test**: Add integration tests

Each task in isolated worktree, merged when quality gates pass.

---

## Use Case 9: Emergency Hotfix Deployment

**Scenario**: Critical bug in production, need urgent fix across multiple services.

**Challenge**:
- Time-sensitive
- Multiple components affected
- Need thorough testing
- Can't break other features

**Droidz Response**:

```bash
# Create hotfix orchestration
/orchestrate file:hotfix-tasks.json
```

```json
{
  "tasks": [
    {
      "key": "HOTFIX-API",
      "title": "Fix API Bug",
      "specialist": "droidz-codegen",
      "priority": 1
    },
    {
      "key": "HOTFIX-UI",
      "title": "Fix UI Issue",
      "specialist": "droidz-codegen",
      "priority": 1
    },
    {
      "key": "HOTFIX-TESTS",
      "title": "Regression Tests",
      "specialist": "droidz-test",
      "priority": 1
    },
    {
      "key": "HOTFIX-DEPLOY",
      "title": "Emergency Deployment",
      "specialist": "droidz-infra",
      "priority": 2
    }
  ]
}
```

**Result**: Parallel fix + test + deploy. Hours instead of days.

---

## Use Case 10: Learning New Framework

**Scenario**: Developer learning new framework, wants to build example projects.

**Traditional Approach**:
- Read docs
- Follow tutorial
- Build one example
- Repeat...

**Droidz Approach**:

```bash
# Create learning projects
/orchestrate file:learning-projects.json
```

```json
{
  "tasks": [
    {
      "key": "LEARN-TODO",
      "title": "Build Todo App",
      "specialist": "droidz-codegen",
      "description": "Classic todo app with CRUD"
    },
    {
      "key": "LEARN-BLOG",
      "title": "Build Blog Platform",
      "specialist": "droidz-codegen",
      "description": "Multi-author blog with auth"
    },
    {
      "key": "LEARN-ECOM",
      "title": "Build E-commerce Store",
      "specialist": "droidz-codegen",
      "description": "Product catalog with cart"
    }
  ]
}
```

**Benefit**: Learn framework patterns from multiple perspectives simultaneously.

---

## Common Patterns

### Pattern 1: Parallel Feature Branches
```
Main Branch
├── worktree/FEAT-001 (frontend)
├── worktree/FEAT-002 (backend)
├── worktree/FEAT-003 (tests)
└── worktree/FEAT-004 (docs)
```

### Pattern 2: Specialist Assignment
- Complex logic → droidz-codegen
- Test coverage → droidz-test
- API integration → droidz-integration
- CI/CD → droidz-infra
- Code cleanup → droidz-refactor
- Misc tasks → droidz-generalist

### Pattern 3: Supervised Gates
1. Spec creation & review
2. Orchestration plan approval
3. Parallel execution
4. Individual task review
5. Integration approval
6. Final merge

---

## Anti-Patterns (What NOT to Do)

### ❌ Over-Parallelization
Don't parallelize dependent tasks.

**Bad**:
```json
{
  "tasks": [
    {"key": "DB-SCHEMA", "title": "Create schema"},
    {"key": "DB-QUERIES", "title": "Write queries using schema"}
  ]
}
```

Queries depend on schema. Run sequentially.

### ❌ Under-Specification
Don't orchestrate without clear specs.

**Bad**: "Build authentication" (too vague)

**Good**: Detailed spec with requirements, acceptance criteria, architecture decisions.

### ❌ Ignoring Conflicts
Don't merge worktrees with conflicts blindly.

**Solution**: Review each worktree, test integration before merging.

### ❌ Wrong Specialist
Don't assign specialists incorrectly.

**Bad**: droidz-test for feature implementation

**Good**: droidz-codegen for implementation, droidz-test for tests.

---

*Last Updated: 2025-01-12*
*Version: 1.0.0*
