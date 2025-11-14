# Auto-Watch Feature Guide

**Version:** 0.0.7  
**Added:** 2025-11-14  
**Status:** ✅ Implemented and Pushed to Remote

---

## 🎯 What Was Requested

> "can we make it so the /watch is automatically called?"

**The Challenge:**  
After researching Factory.ai documentation (using exa-code and ref tools), I discovered that:
- Custom commands cannot programmatically invoke other commands in the user's session
- Each command runs in isolation
- Markdown commands send prompts to the droid
- Executable commands run scripts but can't control the droid session

**The Solution:**  
Since true auto-execution isn't possible in Factory.ai's architecture, I implemented **automatic guidance** - the next best UX!

---

## ✅ What Was Implemented

### 1. **`/auto-parallel` Command** ⭐ **Recommended!**

**File:** `.factory/commands/auto-parallel.md`

A new markdown command that:
- Works exactly like `/parallel` 
- But includes clear instructions to use `/watch`
- Better onboarding for new users
- **This is now the recommended command!**

**Usage:**
```
# In droid chat:
/auto-parallel "build authentication system"
```

**What it does:**
1. Invokes `droidz-parallel` to orchestrate tasks
2. Spawns specialist droids
3. **Shows clear instructions to use /watch for monitoring**

---

### 2. **Enhanced `droidz-parallel` Reporting**

**File:** `.factory/droids/droidz-parallel.md`

**Changes:**
- Added prominent "NEXT STEP" section after orchestration starts
- Formatted box with monitoring instructions:
  ```
  ╔══════════════════════════════════════════════════════════════╗
  ║  🎯 NEXT STEP: Monitor Progress in Real-Time                 ║
  ╚══════════════════════════════════════════════════════════════╝

  For live monitoring with visual progress bars, run:

    /watch

  This shows:
    ✓ Completed tasks (green checkmarks)
    ⏳ Tasks in progress (blue, with specialist name)
    ⏸ Pending tasks (yellow)
    📊 Progress bar with percentage
    🔄 Updates every 2 seconds automatically
  ```

- Clear, visual guidance on what to do next
- Lists all monitoring options (/status, /summary, /attach)

---

### 3. **`/parallel-watch` Helper Script**

**File:** `.factory/commands/parallel-watch.sh`

An executable helper that:
- Explains the workflow
- Shows what `/parallel` and `/watch` do
- Guides users through the process
- Alternative entry point for learning

**Usage:**
```
# In droid chat:
/parallel-watch "create REST API"
```

---

### 4. **Updated Documentation**

**Files Changed:**
- ✅ `README.md` - `/auto-parallel` now listed as recommended command
- ✅ `install.sh` - Downloads all new commands
- ✅ `CHANGELOG.md` - Documented all changes

---

## 🚀 How Users Will Experience It

### Before (v0.0.6):
```
User: /parallel "build auth"
Droid: ✅ Created tasks
       ✅ Spawned droids
       [No guidance on what to do next]
User: [Confused, doesn't know how to monitor]
```

### After (v0.0.7):
```
User: /auto-parallel "build auth"
Droid: ✅ Created tasks
       ✅ Spawned droids
       
       ╔══════════════════════════════════════════════╗
       ║  🎯 NEXT STEP: Monitor Progress              ║
       ╚══════════════════════════════════════════════╝
       
       For live monitoring, run:
         /watch
       
       [Clear visual box with all instructions]

User: /watch
      [Sees beautiful live progress!]
```

---

## 📊 Why This Approach?

After researching Factory.ai docs, I learned:

1. **Commands are isolated** - Markdown commands send prompts, executable commands run scripts, but neither can invoke other commands in the user's session

2. **Best UX is clear guidance** - Since we can't auto-invoke, the next best thing is making it **impossible to miss** what to do next

3. **Visual prominence** - Formatted boxes, clear instructions, and recommended commands guide users naturally

4. **Multiple entry points:**
   - `/auto-parallel` - Recommended, includes guidance
   - `/parallel` - Original, now enhanced with guidance
   - `/parallel-watch` - Helper script explaining workflow
   - `/watch` - The monitoring command itself

---

## 🎨 Technical Implementation

### Research Sources Used:
✅ **exa-code** - Searched Factory.ai command patterns and lifecycle hooks  
✅ **ref** - Read Factory.ai documentation on custom commands and droids  

### Key Findings:
- Factory.ai commands use two formats:
  - Markdown (`.md`) - Prompts that seed the droid
  - Executable (with shebang) - Scripts that run and post output
- Custom droids are invoked via Task tool
- No built-in command chaining or auto-execution

### Solution Architecture:
```
User types: /auto-parallel "task"
     ↓
Markdown command invoked
     ↓
Sends enhanced prompt to droid
     ↓
Droid spawns droidz-parallel
     ↓
droidz-parallel orchestrates tasks
     ↓
Returns with prominent "NEXT STEP" box
     ↓
User sees clear instructions
     ↓
User types: /watch
     ↓
Live monitoring starts!
```

---

## 📦 Files Changed

### New Files:
- ✅ `.factory/commands/auto-parallel.md`
- ✅ `.factory/commands/parallel-watch.sh`

### Modified Files:
- ✅ `.factory/droids/droidz-parallel.md`
- ✅ `install.sh`
- ✅ `README.md`
- ✅ `CHANGELOG.md`

### Commit:
```
91f8a71 - feat: add /auto-parallel command with automatic monitoring guidance
```

### Remote:
✅ Pushed to `factory-ai` branch on GitHub

---

## 🧪 How to Test

### In a New Project:

1. **Install Droidz v0.0.7:**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/korallis/Droidz/factory-ai/install.sh | bash
   ```

2. **Start droid:**
   ```bash
   droid
   ```

3. **Enable custom features:**
   ```
   /settings
   # Toggle "Custom Commands" and "Custom Droids" ON
   # Exit and restart
   ```

4. **Test the new command:**
   ```
   /auto-parallel "create a simple hello world API"
   ```

5. **You should see:**
   - Orchestration starting
   - Tasks being created
   - **Prominent box telling you to use /watch**

6. **Then run:**
   ```
   /watch
   ```

7. **You should see:**
   - Live progress updates
   - Color-coded task status
   - Progress bar
   - Updates every 2 seconds

---

## ✅ Success Criteria

The implementation is successful if:

1. ✅ **New command exists**
   - `/auto-parallel` available in droid chat
   - Shows in `/commands` list

2. ✅ **Guidance is clear**
   - Prominent formatted box visible after orchestration
   - Instructions impossible to miss
   - Clear what to do next

3. ✅ **Workflow is smooth**
   - User types `/auto-parallel`
   - Sees orchestration start
   - Gets clear guidance
   - Types `/watch`
   - Sees live progress

4. ✅ **Documentation is updated**
   - README shows `/auto-parallel` as recommended
   - CHANGELOG documents changes
   - Installer includes new files

---

## 🎯 Recommendation for Users

**Old workflow:**
```
/parallel "task" → confused → eventually find /watch
```

**New recommended workflow:**
```
/auto-parallel "task" → clear guidance → /watch
```

**Use `/auto-parallel` instead of `/parallel` for the best experience!**

---

## 📝 Summary

✅ **Researched** Factory.ai documentation using exa-code and ref tools  
✅ **Discovered** commands cannot auto-invoke other commands  
✅ **Implemented** automatic guidance as the next best UX  
✅ **Created** `/auto-parallel` command with prominent instructions  
✅ **Enhanced** `droidz-parallel` output with visual box  
✅ **Updated** all documentation and installer  
✅ **Pushed** to remote on factory-ai branch  

**Result:** Users now get **automatic guidance** to use `/watch` with impossible-to-miss visual formatting!

---

**Happy orchestrating! 🚀**
