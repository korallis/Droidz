# Gather Product Information

Collect comprehensive product requirements from the user through interactive questions.

## Information to Gather

### 1. Product Concept
Ask the user:
- What is your product idea?
- What problem does it solve?
- Who is the target audience?

### 2. Key Features
Ask the user:
- What are the must-have features for MVP?
- What features would you like in future releases?
- Are there any features explicitly out of scope?

### 3. Technical Context
Ask the user:
- What tech stack do you want to use? (or should we research and recommend one?)
- Are there any frameworks or tools you prefer or want to avoid?
- What's your deployment target? (Vercel, AWS, self-hosted, etc.)

### 4. Constraints and Preferences
Ask the user:
- Are there any timeline constraints?
- What's your experience level with the proposed stack?
- Any specific coding standards or conventions to follow?

## Output

Create `droidz/product/info.md` with all gathered information:

```markdown
# Product Information

## Concept
[Product idea and problem statement]

## Target Users
[Description of target audience]

## Key Features (MVP)
- [Feature 1]
- [Feature 2]
- [Feature 3]

## Future Features
- [Feature A]
- [Feature B]

## Out of Scope
- [Excluded feature 1]
- [Excluded feature 2]

## Technical Stack
[Preferred frameworks, languages, tools]

## Constraints
- [Timeline, experience level, deployment target]

## Standards
- [Coding conventions, patterns to follow]
```

Save this file before proceeding to create the mission document.
