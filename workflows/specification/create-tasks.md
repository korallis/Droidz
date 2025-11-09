# Create Tasks List

Break down the specification into parallelizable, independent task groups.

## Prerequisites
- `droidz/specs/[spec-slug]/spec.md` must exist
- `droidz/product/tech-stack.md` must exist
- `standards/*.md` should be reviewed

## Process

### 1. Analyze Specification

Read the complete spec and identify:
- All components that need to be built
- Database/API work that needs to be done
- UI components that need to be created
- Integration points
- Testing requirements

### 2. Identify Dependencies

Create a dependency graph:
- What must be built first? (foundational work)
- What can be built in parallel? (independent features)
- What requires integration? (must come after parallel work)

Example dependency analysis:
```
Foundation (Sequential):
- Database schema
- API types/interfaces

Parallel Work (Independent):
- Component A (uses types)
- Component B (uses types)
- Service X (uses types)
- Service Y (uses types)

Integration (Sequential, after parallel):
- Wire components together
- Integration tests
```

### 3. Create Task Groups

Write `droidz/specs/[spec-slug]/tasks.md`:

```markdown
# Tasks: [Feature Name]

## Phase 1: Foundation (Sequential)

These tasks must be completed in order before parallel work begins.

### Task 1.1: Database Schema
- [ ] Create [table/collection] with fields: [...]
- [ ] Add indexes for [...]
- [ ] Create migration file
- Dependencies: None

### Task 1.2: API Types & Interfaces
- [ ] Define [Type] interface
- [ ] Create [API] request/response types
- [ ] Export from types file
- Dependencies: Task 1.1

---

## Phase 2: Parallel Implementation

These task groups are INDEPENDENT and can be worked on simultaneously.

### Task Group A: [Component/Feature Name]
**Assignable to: Worker 1**
- [ ] Create [component file]
- [ ] Implement [functionality]
- [ ] Add [styling/UI elements]
- [ ] Write unit tests
- Dependencies: Phase 1 complete
- Estimated: [S/M/L]

### Task Group B: [Another Component/Feature]
**Assignable to: Worker 2**
- [ ] Create [service file]
- [ ] Implement [API calls]
- [ ] Add error handling
- [ ] Write unit tests
- Dependencies: Phase 1 complete
- Estimated: [S/M/L]

### Task Group C: [Another Independent Feature]
**Assignable to: Worker 3**
- [ ] Create [another component]
- [ ] Implement [feature logic]
- [ ] Add [UI elements]
- [ ] Write unit tests
- Dependencies: Phase 1 complete
- Estimated: [S/M/L]

[Up to 10 parallel task groups]

---

## Phase 3: Integration (Sequential)

These tasks integrate the parallel work and must be done after Phase 2.

### Task 3.1: Wire Components Together
- [ ] Connect [Component A] to [Service X]
- [ ] Add routing/navigation
- [ ] Implement state management
- Dependencies: All Phase 2 tasks

### Task 3.2: Integration Testing
- [ ] Test [user flow 1]
- [ ] Test [user flow 2]
- [ ] Test error scenarios
- Dependencies: Task 3.1

### Task 3.3: Documentation
- [ ] Add comments to complex logic
- [ ] Update README if needed
- [ ] Document API endpoints
- Dependencies: All tasks complete

---

## Parallelization Summary

**Sequential Phases:**
- Phase 1: Foundation (1 worker)
- Phase 3: Integration (1 worker)

**Parallel Phase:**
- Phase 2: [N] independent task groups can run simultaneously

**Estimated Total Time:**
- Sequential: [Time for Phase 1 + Phase 3]
- Parallel: [Max time among Phase 2 groups]
- Total: [Sequential + Parallel]

**Safe Concurrency:** Up to [N] workers for Phase 2
```

### 4. Validate Task Breakdown

- ✅ Each parallel task group is truly independent (no shared files)
- ✅ Dependencies are clearly marked
- ✅ Foundation work is minimal but complete
- ✅ Each task group has clear deliverables
- ✅ Task groups are balanced in size/complexity
- ✅ All spec requirements are covered by tasks

### 5. Add Implementation Guidance

For each task group, add a "Context" section referencing:
- Relevant sections from spec.md
- Documentation URLs from Ref research
- Code examples from Exa research
- Patterns from standards/*.md

## Output
- ✅ Complete tasks breakdown at `droidz/specs/[spec-slug]/tasks.md`
- ✅ Clear parallelization strategy
- ✅ Ready for parallel implementation phase
