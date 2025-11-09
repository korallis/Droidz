# Parallel Implementation

Execute specification tasks using multiple parallel droids with git worktrees for isolation.

## Prerequisites
- `droidz/specs/[spec-slug]/tasks.md` must exist with clear phase breakdown
- `droidz/specs/[spec-slug]/spec.md` must exist
- Git repository must be initialized
- Standards must be reviewed from `standards/*.md`

## Process Overview

```
Phase 1 (Sequential) → Phase 2 (Parallel) → Phase 3 (Sequential)
     1 worker      →    N workers        →      1 worker
```

## Phase 1: Foundation Work (Sequential)

Execute foundation tasks that everything else depends on:

1. Read foundation tasks from `tasks.md` Phase 1
2. Implement each task in sequence on main branch
3. Commit after each completed foundation task
4. Mark tasks complete in `tasks.md` with `[x]`

```bash
# Example foundation work
git checkout main
# ... implement database schema ...
git add .
git commit -m "feat: add database schema for [feature]"
# ... implement API types ...
git add .
git commit -m "feat: add API types for [feature]"
```

## Phase 2: Parallel Implementation (CONCURRENT)

This is where the magic happens - multiple droids work simultaneously.

### Step 1: Analyze Parallel Task Groups

```typescript
// Read tasks.md and extract Phase 2 task groups
const taskGroups = parsePhase2TaskGroups('droidz/specs/[spec-slug]/tasks.md');

// Verify they're truly independent
validateIndependence(taskGroups); // checks for file conflicts

// Determine worker count (from config or auto-detect)
const maxWorkers = Math.min(taskGroups.length, config.parallel.max_concurrent_tasks);
```

### Step 2: Prepare Workspaces

For each parallel task group, create an isolated workspace:

```bash
# Create worktrees for parallel work
SPEC_SLUG="[spec-slug]"
FEATURE_NAME="[feature-name]"

for i in {1..N}; do
  TASK_GROUP="group-$i"
  WORKTREE_PATH=".droidz/worktrees/${SPEC_SLUG}/${TASK_GROUP}"
  BRANCH_NAME="feat/${FEATURE_NAME}-${TASK_GROUP}"
  
  # Create worktree from main
  git worktree add "${WORKTREE_PATH}" -b "${BRANCH_NAME}" main
  
  echo "✅ Worktree ready: ${WORKTREE_PATH}"
done
```

### Step 3: Launch Parallel Droids

Use Droid CLI's Task tool to spawn concurrent workers:

```typescript
// For each task group, spawn a parallel droid
const workers = taskGroups.map((group, index) => {
  const worktreePath = `.droidz/worktrees/${specSlug}/group-${index + 1}`;
  const branchName = `feat/${featureName}-group-${index + 1}`;
  
  return {
    id: `worker-${index + 1}`,
    taskGroup: group,
    worktree: worktreePath,
    branch: branchName,
    prompt: buildImplementationPrompt(group, spec, standards)
  };
});

// Launch all workers in parallel using Task tool
// Each worker receives:
// - Their specific task group
// - The full spec context
// - Standards to follow
// - Isolated worktree path
await Promise.all(workers.map(worker => 
  spawnImplementerDroid(worker)
));
```

### Step 4: Worker Implementation (per droid)

Each parallel droid executes independently:

1. **Change to worktree directory**
   ```bash
   cd [worktree-path]
   ```

2. **Read assigned tasks and context**
   - Task group from `tasks.md`
   - Requirements from `spec.md`
   - Standards from `standards/*.md`
   - Documentation references

3. **Implement with research**
   ```typescript
   // Use Ref for just-in-time documentation lookup
   const docs = await ref___ref_read_url({
     url: "[doc-url-from-spec]"
   });
   
   // Use Exa for implementation examples if needed
   const examples = await exa___get_code_context_exa({
     query: "[specific implementation question]",
     tokensNum: 3000
   });
   ```

4. **Follow standards**
   - Check `standards/coding-conventions.md`
   - Follow patterns from `standards/architecture.md`
   - Apply security rules from `standards/security.md`

5. **Self-test**
   - Run unit tests for implemented code
   - Verify functionality works
   - Check TypeScript/linter passes

6. **Commit work**
   ```bash
   git add .
   git commit -m "feat([feature]): implement [task group name]"
   ```

7. **Mark tasks complete**
   Update `tasks.md` in main directory (careful synchronization):
   ```bash
   # Mark your group's tasks as done
   # Use git to safely update the shared tasks.md
   ```

### Step 5: Monitor and Collect Results

Track parallel execution:

```typescript
// Watch for completion
const results = await Promise.allSettled(workerPromises);

// Analyze results
const completed = results.filter(r => r.status === 'fulfilled');
const failed = results.filter(r => r.status === 'rejected');

console.log(`✅ Completed: ${completed.length}/${workers.length}`);
if (failed.length > 0) {
  console.log(`❌ Failed: ${failed.length}`);
  // Handle failures
}
```

## Phase 3: Integration Work (Sequential)

After all parallel work completes, integrate everything:

### Step 1: Merge Parallel Branches

```bash
# Return to main branch
cd [project-root]
git checkout main

# Merge each parallel branch
for branch in feat/[feature]-group-*; do
  echo "Merging ${branch}..."
  git merge --no-ff "${branch}" -m "feat: merge [feature] ${branch}"
  
  # Run tests after each merge to catch integration issues early
  npm test || yarn test || bun test
done
```

### Step 2: Execute Integration Tasks

Implement Phase 3 tasks from `tasks.md`:
- Wire components together
- Add integration points
- Implement end-to-end flows
- Run integration tests

### Step 3: Cleanup

```bash
# Remove worktrees
git worktree list | grep ".droidz/worktrees" | while read -r worktree; do
  git worktree remove "$(echo $worktree | awk '{print $1}')"
done

# Delete merged branches (optional)
git branch -d feat/[feature]-group-*
```

## Safety and Coordination

### File Conflict Prevention
- Task breakdown ensures no two workers edit same files
- Each worker gets independent modules/components
- Shared files (types, config) are in Phase 1 foundation

### Progress Tracking
- Each worker logs to `.droidz/logs/worker-[id].log`
- Central coordinator tracks completion
- tasks.md shows real-time progress

### Error Handling
- If worker fails, other workers continue
- Failed task group can be retried manually
- Integration phase catches any issues

## Output

- ✅ All Phase 2 tasks completed in parallel
- ✅ Branches merged into main
- ✅ Integration tasks completed
- ✅ All tests passing
- ✅ Feature complete and ready for review
