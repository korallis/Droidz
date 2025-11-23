# Codex CLI Sequential Playbook

1. `/prompts:init` – load instructions + validation summary.
2. `/prompts:implement` – execute each task, pausing for `/prompts:validate` checkpoints.
3. `/prompts:handoff` – provide summary + validator output paths.
