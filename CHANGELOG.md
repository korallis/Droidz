# Changelog

All notable changes to Droidz will be documented in this file.

## [2.0.0] - 2025-01-10

### 🎉 MAJOR RELEASE - Factory-Native Multi-Agent System

Complete rewrite of Droidz. V1 (shell-based) is retired.

### ✨ Added

- **Orchestrator Droid** - Central coordinator using Factory's Task tool
- **Specialist Droids** - codegen, test, refactor, infra, integration
- **Real-time Progress** - TodoWrite shows live status
- **LLM-driven Routing** - Smart specialist selection
- **Helper Scripts** - linear-fetch, linear-update, worktree-setup, task-coordinator
- **Git Worktrees** - True isolation for parallel work
- **Comprehensive Docs** - Simple README, architecture guides

### 🔄 Changed

- Complete architecture: Shell-based → Factory-native
- Task tool delegation replaces process spawning
- Custom droids replace shell workers
- Helper scripts for Linear integration

### 🗑️ Removed

- V1 shell-based orchestrator (deprecated)
- Direct process spawning
- All V1-specific code

### 📊 Performance

- ~18 minutes for 10 tickets
- 5-10 parallel specialists
- Real-time visibility

---

## [1.0.0] - 2024-12-15 (DEPRECATED)

Initial shell-based release. No longer supported.
