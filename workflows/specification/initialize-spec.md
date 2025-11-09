# Initialize Specification

Set up the directory structure for a new feature specification.

## Input Required
- Feature name from roadmap (e.g., "User Authentication")

## Process

1. **Create Spec Directory Structure**

```bash
# Convert feature name to slug (lowercase, hyphens)
SPEC_SLUG="[feature-name-slug]"

# Create directory structure
mkdir -p "droidz/specs/${SPEC_SLUG}/planning/visuals"
mkdir -p "droidz/specs/${SPEC_SLUG}/verification/screenshots"
```

2. **Copy Roadmap Item**

Extract the relevant feature from `droidz/product/roadmap.md` and create initial requirements:

```markdown
# Requirements: [Feature Name]

## From Roadmap
[Copy the feature description, dependencies, and effort estimate from roadmap.md]

## Context
[Link to related product documentation]
- Mission: See droidz/product/mission.md
- Tech Stack: See droidz/product/tech-stack.md
- Standards: See standards/*.md

## Status
- Created: [Date]
- Phase: Requirements Gathering
```

Save to `droidz/specs/[spec-slug]/planning/requirements.md`

3. **Prompt for User Input**

Ask the user:
- Are there any visual mockups or wireframes for this feature? (If yes, save to `planning/visuals/`)
- Any additional constraints or requirements beyond the roadmap?
- Any specific user stories or acceptance criteria?

4. **Update Requirements Document**

Add user input to `requirements.md`:

```markdown
## User Stories
- [User story 1]
- [User story 2]

## Additional Requirements
- [Requirement 1]
- [Requirement 2]

## Acceptance Criteria
- [Criteria 1]
- [Criteria 2]

## Constraints
- [Constraint 1]
- [Constraint 2]

## Visuals
[List any files in planning/visuals/]
```

## Output
- ✅ Directory structure created at `droidz/specs/[spec-slug]/`
- ✅ Requirements document created
- ✅ Ready for spec writing phase
