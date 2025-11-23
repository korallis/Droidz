# Droidz Instruction Stack

1. **Two-step flow**
   - Install the base instructions into your home directory via `python install.py`.
   - Compile per-project workflows by copying the desired payloads into the tool-specific folders.
2. **Profiles**
   - Start with the `default` profile.
   - Duplicate payload folders to define custom stacks (e.g., `payloads/claude/nextjs`).
3. **Validation Gate**
   - Every platform enforces the same requirement: run `ruff check .` and `pytest` before reporting success.
4. **No external dependencies**
   - All guidance lives in this repository; update payload text files to evolve your workflow.
5. **Top platforms**
   - Claude Code, Droid CLI, Cursor, Cline, Codex CLI, and VS Code receive curated payloads covering commands, agents, prompts, and snippets.
