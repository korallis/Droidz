---
description: Analyze project tech stack and generate framework-specific standards
argument-hint: "[--regenerate] [--framework <name>]"
allowed-tools: Read, LS, Grep, Create, Edit
---

# /analyze-tech-stack

Detects your project's technology stack and automatically generates customized development standards.

## Usage

```bash
# Basic analysis (auto-detects everything)
/analyze-tech-stack

# Force regeneration of all standards
/analyze-tech-stack --regenerate

# Generate standards for specific framework only
/analyze-tech-stack --framework react
/analyze-tech-stack --framework typescript
```

## What It Does

1. **Detects Package Manager**
   - Checks for `bun.lockb`, `pnpm-lock.yaml`, `yarn.lock`, `package-lock.json`
   - Determines: Bun, pnpm, Yarn, or npm

2. **Analyzes package.json** (JavaScript/TypeScript)
   - Frameworks: React, Next.js, Vue, Nuxt, Angular, Svelte, Express, Fastify, NestJS
   - Languages: TypeScript, JavaScript
   - Testing: Jest, Vitest, Playwright, Cypress
   - Build tools: Vite, Webpack, Rollup, esbuild
   - State management: Redux, Zustand, Jotai, Recoil, MobX, Pinia
   - Linters: ESLint, Prettier, Biome

3. **Detects Other Languages**
   - Python: `requirements.txt`, `pyproject.toml`, `*.py` files
   - Rust: `Cargo.toml`, `*.rs` files
   - Go: `go.mod`, `*.go` files

4. **Generates Standards Files**
   - `.claude/standards/react.md` (if React detected)
   - `.claude/standards/typescript.md` (if TypeScript detected)
   - `.claude/standards/security.md` (always)
   - `.claude/standards/testing.md` (based on test framework)
   - Framework-specific best practices

5. **Creates/Updates Root CLAUDE.md**
   - Auto-detected configuration
   - Development commands
   - Project structure
   - Links to framework standards

## Example Output

```
🔍 Analyzing Tech Stack...

📦 Package Manager: bun
✅ Detected Frameworks:
   - React 18.2.0
   - Next.js 14.0.0
   
✅ Detected Languages:
   - TypeScript 5.3.0
   
✅ Detected Tools:
   - Build: Vite 5.0.0
   - Test: Vitest 1.0.0
   - Lint: ESLint, Prettier
   - State: Zustand 4.4.0

📝 Generating Standards...
   ✅ .claude/standards/react.md
   ✅ .claude/standards/nextjs.md
   ✅ .claude/standards/typescript.md
   ✅ .claude/standards/security.md
   ✅ .claude/standards/testing.md
   
📄 Updating CLAUDE.md...
   ✅ Root CLAUDE.md updated

✨ Tech Stack Analysis Complete!

Next Steps:
1. Review generated standards: ls .claude/standards/
2. Customize as needed: edit .claude/standards/*.md
3. Add directory-specific CLAUDE.md files
4. Start coding - standards auto-enforced!
```

## Arguments

- `$1` (optional): `--regenerate` to force regeneration of existing standards
- `$2` (optional): `--framework <name>` to generate specific framework only

## Implementation

**Step 1: Read package.json**
```bash
Read('package.json')
```

**Step 2: Detect stack**
Parse dependencies and devDependencies to identify frameworks, languages, and tools.

**Step 3: Generate standards**
For each detected framework/language, invoke the `tech-stack-analyzer` skill to generate appropriate standards file.

**Step 4: Update CLAUDE.md**
Create or update root CLAUDE.md with detected configuration, commands, and structure.

**Step 5: Report results**
Show summary of detected stack and generated files.

## Output Format

```
STATUS=COMPLETE
DETECTED_FRAMEWORKS=${frameworks}
DETECTED_LANGUAGES=${languages}
GENERATED_FILES=${files}
```

## Error Handling

If package.json not found:
```
⚠️ No package.json found. 

For JavaScript/TypeScript projects:
  Run: bun init (or npm init)
  
For other languages:
  Specify language: /analyze-tech-stack --framework python
```

## Notes

- Generated standards are templates - customize for your team
- Regeneration preserves custom sections marked with `<!-- CUSTOM -->` comments
- Framework detection is based on dependencies, not file structure
