---
description: Orchestrates complex multi-step features with sequential execution
argument-hint: FEATURE=<description>
---

# Orchestrator - Complex Feature Workflow

Orchestrate implementation of: **$FEATURE**

---

## 🎯 Your Role

You coordinate complex, multi-step feature implementation by:
1. Breaking work into logical phases
2. Executing tasks in dependency order
3. Tracking progress with todos
4. Synthesizing results

**Note**: Codex CLI doesn't support parallel agent spawning. Work sequentially through tasks.

---

## 📊 Step 1: Analyze Complexity

Assess if orchestration is needed:

### ✅ Needs Orchestration When:
- Feature involves 5+ files across different domains
- Multiple independent components (frontend + backend + tests)
- Requires specialized expertise (UI, API, database, security)
- Benefits from phased approach with validation between steps
- User said: "build", "implement system", "create application"

### ❌ Skip Orchestration When:
- Single file modification
- Simple bug fix
- Documentation update
- Quick refactor (<30 minutes)

**If simple → Proceed directly without orchestration.**  
**If complex → Continue with breakdown.**

---

## 🔬 Step 2: Break Down into Phases

Organize work into sequential phases with clear dependencies:

### Example Breakdown:

```markdown
## Feature: Authentication System

### Phase 1: Foundation (No dependencies)
**Tasks:**
- Task 1.1: Database schema for users table
- Task 1.2: Environment variables setup
- Task 1.3: JWT utility functions

**Estimated**: 2-3 hours
**Files**: db/schema.sql, .env.example, src/utils/jwt.ts

### Phase 2: Backend API (Depends on Phase 1)
**Tasks:**
- Task 2.1: Register endpoint
- Task 2.2: Login endpoint
- Task 2.3: Auth middleware
- Task 2.4: Token refresh endpoint

**Estimated**: 4-5 hours
**Files**: src/api/auth.ts, src/middleware/auth.ts, src/routes/auth.ts

### Phase 3: Frontend (Depends on Phase 2)
**Tasks:**
- Task 3.1: Auth context provider
- Task 3.2: Login form component
- Task 3.3: Register form component
- Task 3.4: Protected route wrapper

**Estimated**: 3-4 hours
**Files**: src/contexts/AuthContext.tsx, src/components/LoginForm.tsx, src/components/RegisterForm.tsx, src/components/ProtectedRoute.tsx

### Phase 4: Testing (Depends on Phase 2, 3)
**Tasks:**
- Task 4.1: API tests (register, login, refresh)
- Task 4.2: Component tests (forms, context)
- Task 4.3: Integration tests (end-to-end flow)

**Estimated**: 3-4 hours
**Files**: tests/api/auth.test.ts, tests/components/auth.test.tsx, tests/e2e/auth.test.ts

### Phase 5: Documentation & Deployment (Depends on Phase 4)
**Tasks:**
- Task 5.1: API documentation
- Task 5.2: Setup instructions
- Task 5.3: Security audit
- Task 5.4: Deployment checklist

**Estimated**: 1-2 hours
**Files**: docs/API.md, docs/AUTH_SETUP.md
```

---

## 📝 Step 3: Create Todo List

Use a todo list to track progress:

```markdown
## Auth System Implementation - Progress

### Phase 1: Foundation
- [x] Task 1.1: Database schema ✓
- [x] Task 1.2: Environment variables ✓
- [x] Task 1.3: JWT utilities ✓

### Phase 2: Backend API
- [x] Task 2.1: Register endpoint ✓
- [x] Task 2.2: Login endpoint ✓
- [ ] Task 2.3: Auth middleware (in progress)
- [ ] Task 2.4: Token refresh endpoint

### Phase 3: Frontend
- [ ] Task 3.1: Auth context
- [ ] Task 3.2: Login form
- [ ] Task 3.3: Register form
- [ ] Task 3.4: Protected routes

### Phase 4: Testing
- [ ] Task 4.1: API tests
- [ ] Task 4.2: Component tests
- [ ] Task 4.3: Integration tests

### Phase 5: Documentation
- [ ] Task 5.1: API docs
- [ ] Task 5.2: Setup guide
- [ ] Task 5.3: Security audit
- [ ] Task 5.4: Deployment checklist

**Progress**: 5/20 tasks complete (25%)
**Current Phase**: Phase 2 (Backend API)
```

---

## 🔄 Step 4: Execute Sequentially

Work through phases in order:

### For Each Phase:

1. **Execute all tasks in the phase**
2. **Validate work:**
   - Run linter
   - Run type checker
   - Run tests for completed code
3. **Update todo list**
4. **Commit changes:** `git commit -m "feat: [phase name]"`
5. **Move to next phase**

### Validation Between Phases

After completing each phase:
```bash
# Quick validation
npx eslint src/
npx tsc --noEmit
npm test

# Should all pass before moving to next phase
```

---

## 📊 Step 5: Synthesize Results

After all phases complete, provide comprehensive summary:

```markdown
## Feature Implementation Complete ✨

### Summary
Implemented full authentication system with JWT tokens, including:
- Backend API (register, login, refresh, logout)
- Frontend components (forms, context, protected routes)
- Comprehensive test coverage (95%)
- API documentation
- Security audit completed

### Statistics
- **Total Time**: ~15 hours (estimated 13-18h)
- **Files Created**: 12
- **Files Modified**: 4
- **Lines Added**: 1,245
- **Tests Written**: 28 (all passing ✅)
- **Test Coverage**: 95%

### Phase Breakdown
| Phase | Tasks | Status | Time |
|-------|-------|--------|------|
| Foundation | 3 | ✅ Complete | 2.5h |
| Backend API | 4 | ✅ Complete | 5h |
| Frontend | 4 | ✅ Complete | 4h |
| Testing | 3 | ✅ Complete | 3.5h |
| Documentation | 4 | ✅ Complete | 1.5h |

### Files Created
**Backend:**
- `db/migrations/001_users_table.sql` - User schema
- `src/api/auth.ts` - Auth API functions
- `src/middleware/auth.ts` - JWT middleware
- `src/routes/auth.ts` - Auth routes
- `src/utils/jwt.ts` - JWT utilities

**Frontend:**
- `src/contexts/AuthContext.tsx` - Auth state management
- `src/components/LoginForm.tsx` - Login UI
- `src/components/RegisterForm.tsx` - Registration UI
- `src/components/ProtectedRoute.tsx` - Route protection

**Tests:**
- `tests/api/auth.test.ts` - API tests (12 tests)
- `tests/components/LoginForm.test.tsx` - UI tests (8 tests)
- `tests/e2e/auth-flow.test.ts` - E2E tests (8 tests)

### Validation Results
✅ ESLint: 0 errors, 0 warnings
✅ TypeScript: No type errors
✅ Prettier: All files formatted
✅ Tests: 28/28 passed (95% coverage)
✅ Security: OWASP checklist verified

### Security Measures Implemented
- Passwords hashed with bcrypt (cost factor 12)
- JWT tokens signed with HS256
- httpOnly cookies for token storage
- CSRF protection enabled
- Rate limiting on auth endpoints (5 req/min)
- Input validation with Zod schemas
- SQL injection prevention (parameterized queries)

### Next Steps
1. Review code changes: `git diff origin/main`
2. Test manually in development environment
3. Run full validation: `/prompts:validate`
4. Create PR: `gh pr create --fill`
5. Request code review

### Notes
- All secrets in environment variables (.env.example provided)
- Token expiry: 15 minutes (refresh: 7 days)
- Refresh token rotation implemented for security
- Rate limiting prevents brute force attacks
```

---

## 🎯 Orchestration Best Practices

**DO:**
- ✅ Start with smallest, foundational tasks
- ✅ Validate after each phase
- ✅ Keep todo list updated
- ✅ Commit frequently (after each phase)
- ✅ Test continuously, not just at the end

**DON'T:**
- ❌ Jump ahead without completing dependencies
- ❌ Skip validation between phases
- ❌ Create massive commits (commit per phase)
- ❌ Ignore test failures "to move faster"
- ❌ Skip security considerations

---

## 🚨 When to Ask for Help

Stop and ask user for clarification when:
- Requirements are ambiguous or contradictory
- Security implications are uncertain
- Technology choice requires stakeholder input
- Scope seems larger than described
- Blocked by missing credentials/access

---

## 🎯 Success Criteria

Orchestration is successful when:
- ✅ All phases completed in order
- ✅ All tasks in each phase finished
- ✅ Validation passed between phases
- ✅ Tests pass with good coverage (80%+)
- ✅ Code follows project standards
- ✅ Security measures implemented
- ✅ Documentation complete
- ✅ Ready for review and deployment
