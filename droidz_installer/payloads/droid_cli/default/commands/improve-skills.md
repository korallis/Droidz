I want you to help me improve the files that make up your Skills by rewriting their descriptions so that they can be more readily discovered and used when working on coding tasks.

You can refer to the skills documentation here: https://docs.claude.com/en/docs/claude-code/skills

All of the Skills in our project are located in `.factory/skills/`. Each Skill has its own folder and inside each Skill folder is a file called `SKILL.md`.

## Using the skill-creator Skill

**IMPORTANT**: Use the `skill-creator` skill to improve each SKILL.md file. The skill-creator provides templates, best practices, and patterns for creating high-quality skills.

To activate: The skill-creator skill will automatically activate when you start working on skill improvement tasks.

LOOP through each `SKILL.md` file and FOR EACH use the following process to revise its content and improve it:

## Skill Improvement Process

### Step 1: Confirm which skills to improve

First, ask the user to confirm whether they want ALL of their skills to be improved, or only select Skills.  Assume the answer will be "all" but ask the user to confirm by displaying the following message, then WAIT for the user's response before proceeding to Step 2:

```
Before I proceed with improving your Skills, can you confirm that you want me to revise and improve ALL Skills in your .factory/skills/ folder?

If not, then please specify which Skills I should include or exclude.
```

### Step 2: Analyze what this Skill does

**Use the skill-creator skill** to analyze and understand each skill file.

Analyze and read the skill file to understand what it is, what it should be used for, and when it should be used. The skill-creator skill provides guidance on:
- Proper skill structure and format
- Clear activation criteria
- Effective examples and patterns
- Resource links and documentation

Look to these places to read and understand each skill:
- The Skill's name and file name.
- The Skill.md contains a link that points to `droidz/standards/...` — Follow that link and read its contents.
- Use skill-creator's templates to guide improvements

### Step 3: Rewrite the Skill description

**Use the skill-creator skill** to rewrite the description following best practices.

The most important element of a skill.md file that impacts its discoverability and trigger-ability is the content we write in the `description` in the skill.md frontmatter.

The skill-creator provides templates and patterns for effective descriptions. Rewrite this description using the following guidelines:

- The first sentence should clearly describe what this skill is. For example: "Write Tailwind CSS code and structure front-end UIs using Tailwind CSS utility classes."
- The second sentence and subsequent sentences should clearly and directly describe multiple examples where and when this skill should be used.
- The use case examples can include "When writing or editing [file types]" where [file types] can be a list of file extensions or types of files or components commonly found in software projects.
- The use case examples can also include situations or areas or tools where using this skill should come into play.
- The description text can be long. There is no maximum character or word limit.
- Focus on adding examples where the skill SHOULD be used. Do not include instructions on when NOT to use a skill (our goal is for the Skill to be readily found and used frequently).

### Step 4: Insert a section for 'When to use this skill'

**Use the skill-creator skill's structure template** to format this section properly.

At the top of the content of skill.md, below the frontmatter, insert an H2 heading, "When to use this skill" followed by a list of use case examples.

The skill-creator provides guidance on writing clear activation criteria. The use case examples can repeat the same one(s) listed in the description and/or expand on them.

Example:
```markdown
## When to use this skill:

- [Descriptive example A]
- [Descriptive example B]
- [Descriptive example C]
...
```

### Step 5: Advise the user on improving their skills further

After revising ALL Skill.md files located in the project's `.factory/skills/` folder, display the following message to the user to advise them on how to improve their Skills further:

```
All Skills have been analyzed and revised using the skill-creator skill! ✅

RECOMMENDATION 👉 Review and revise them further using these tips:

- Make Skills as descriptive as possible
- Use their 'description' frontmatter to describe when this skill should proactively be used.
- Include all relevant instructions, details and directives within the content of the Skill.
- You can link to other files (like your Droidz standards files) using markdown links.
- You can consolidate multiple similar skills into single skills where it makes sense to find and use them together.

💡 The skill-creator skill was used to ensure proper structure, clear activation criteria, and effective patterns.

For more best practices, refer to:
- Skills documentation: https://docs.claude.com/en/docs/claude-code/skills
- The skill-creator skill in your skills directory for templates and examples
```
