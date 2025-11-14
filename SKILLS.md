# Droidz Skills System

## 📚 Table of Contents

- [What Are Skills?](#what-are-skills)
- [How Skills Work](#how-skills-work)
- [Creating Your Own Skills](#creating-your-own-skills)
- [Best Practices](#best-practices)
- [Skill Template](#skill-template)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

---

## What Are Skills?

**Skills** are markdown files containing coding standards, patterns, and best practices that are automatically injected into Factory.ai droid's context when relevant. Think of them as contextual knowledge that guides the AI to write better, more consistent code.

### Benefits

✅ **Consistent Code Quality** - All code follows your project's standards  
✅ **Automatic Enforcement** - No need to repeat guidelines in every prompt  
✅ **Context-Aware** - Right skill loaded at the right time  
✅ **Team Alignment** - Everyone (including AI) follows the same patterns  
✅ **Framework-Specific** - Different standards for different technologies

---

## How Skills Work

Droidz uses **Factory.ai hooks** to inject skills automatically:

### 1. **UserPromptSubmit Hook** (Prompt-based)
When you type a prompt mentioning "TypeScript" or "Tailwind", relevant skills are injected:

```bash
User: "Create a TypeScript component with Tailwind styling"
↓
Hook detects: "TypeScript" + "Tailwind"
↓
Injects: typescript.md + tailwind-4.md
↓
Droid sees your prompt + coding standards
```

### 2. **PreToolUse Hook** (File-based)
When droid writes/edits a file, skills are injected based on file type:

```bash
Droid: "I'll edit `components/Button.tsx`"
↓
Hook detects: .tsx file
↓
Injects: typescript.md + react.md
↓
Code follows TypeScript + React standards
```

### 3. **SessionStart Hook** (Project-level)
When you start droid, project-relevant skills are loaded once:

```bash
Session starts
↓
Hook detects: tsconfig.json, tailwind.config.ts, convex/
↓
Loads: TypeScript, Tailwind, Convex skills
↓
Standards available throughout session
```

---

## Creating Your Own Skills

### Step 1: Create a Skill File

Skills live in `.factory/skills/` and use markdown format:

```bash
.factory/skills/your-skill-name.md
```

**Naming Convention:**
- Lowercase with hyphens: `my-framework.md`
- Descriptive: `python-django.md` not just `python.md`
- Technology-specific: `vue-3-composition.md`

### Step 2: Structure Your Skill

Use this proven structure:

```markdown
# [Technology] Best Practices

## Core Principles

1. **Principle 1** - Brief explanation
2. **Principle 2** - Brief explanation  
3. **Principle 3** - Brief explanation

## [Topic Area 1]

### ✅ Good
\`\`\`[language]
// Example of correct pattern
const example = "with comments explaining why";
\`\`\`

### ❌ Bad
\`\`\`[language]
// Example of what NOT to do
const badExample = "with explanation of why it's wrong";
\`\`\`

## [Topic Area 2]

[Repeat pattern above]

## Common Pitfalls

1. **Mistake**: How to avoid it
2. **Anti-pattern**: Better alternative

**ALWAYS follow these [Technology] standards in every file you create or modify.**
```

### Step 3: Write Clear, Actionable Content

#### ✅ DO:
- Use **concrete code examples** (not pseudocode)
- Show **both good (✅) and bad (❌) patterns**
- **Explain WHY**, not just what
- Include **specific version numbers** when relevant
- Add **comments in code examples**
- Use **bold** for key terminology
- End with a **strong directive** (ALWAYS, NEVER, etc.)

#### ❌ DON'T:
- Write vague advice like "write clean code"
- Use placeholder code like `// your code here`
- Assume knowledge without examples
- Include outdated patterns
- Forget to specify the language in code blocks

### Step 4: Configure Hook Detection

Edit `.factory/hooks/inject-skills.sh` to detect when your skill should load:

```bash
# Add detection pattern
if echo "$prompt" | grep -qiE "your-tech|related-keywords"; then
    skill=$(read_skill "$skills_dir/your-skill-name.md")
    if [ -n "$skill" ]; then
        skills="${skills}\n\n### Your Tech Standards\n${skill}"
    fi
fi
```

**Detection Patterns:**
- **Technology names**: `django|flask|fastapi`
- **File extensions**: `\.vue|\.svelte`
- **Keywords**: `database|orm|migration`
- **Commands**: `docker|kubernetes|deploy`

### Step 5: Test Your Skill

```bash
# Start droid
droid

# Test prompt-based injection
> "Create a [your-tech] component"

# You should see your skill injected in the context
```

---

## Best Practices

### 1. Keep It Focused

**✅ Good**: One skill per technology/framework
```
- typescript.md
- react.md
- vue-3.md
```

**❌ Bad**: One massive skill file
```
- frontend.md  (too broad!)
```

### 2. Use Examples Extensively

Every rule should have a code example:

```markdown
## State Management

### ✅ Good
\`\`\`tsx
// Use useState for simple state
const [count, setCount] = useState<number>(0);

// Use reducer for complex state
const [state, dispatch] = useReducer(reducer, initialState);
\`\`\`

### ❌ Bad
\`\`\`tsx
// Don't mutate state directly
state.count++  // ❌ Never mutate!
\`\`\`
```

### 3. Include Context

Tell the AI **when** and **why** to use patterns:

```markdown
## When to Use This Pattern

- ✅ **Use** for user-facing forms with validation
- ✅ **Use** when you need real-time validation feedback
- ❌ **Don't use** for simple read-only displays
- ❌ **Don't use** in server components (Next.js)
```

### 4. Version-Specific Guidance

Be explicit about versions:

```markdown
# Vue 3 Composition API Patterns

**This skill is for Vue 3.3+ using `<script setup>`**

❌ Don't use Options API patterns from Vue 2:
\`\`\`vue
// Vue 2 style - DON'T USE
export default {
  data() { return { count: 0 } }
}
\`\`\`

✅ Use Composition API with setup:
\`\`\`vue
// Vue 3 style - USE THIS
<script setup lang="ts">
import { ref } from 'vue';
const count = ref(0);
</script>
\`\`\`
```

### 5. Framework-Specific Best Practices

Research official docs and community standards:

```markdown
# Research Checklist

Before writing a skill, check:
1. ✅ Official documentation
2. ✅ GitHub awesome lists (e.g., awesome-react)
3. ✅ Popular style guides (e.g., Airbnb, Google)
4. ✅ Framework release notes
5. ✅ Community best practices articles
```

### 6. Performance & Security

Always include performance and security considerations:

```markdown
## Performance

- ✅ Use `useMemo` for expensive calculations
- ✅ Use `useCallback` for stable function references
- ❌ Don't create functions in render

## Security

- ✅ Always sanitize user input with DOMPurify
- ✅ Use Content Security Policy
- ❌ NEVER use `dangerouslySetInnerHTML` with user data
```

---

## Skill Template

Copy this template to get started:

```markdown
# [Technology/Framework] Best Practices

**Version**: [Specify version, e.g., "React 18+", "Python 3.11+"]  
**Last Updated**: [Date]

## Core Principles

1. **[Principle Name]** - [Brief explanation]
2. **[Principle Name]** - [Brief explanation]
3. **[Principle Name]** - [Brief explanation]

## [Topic Area 1: e.g., "Component Structure"]

### ✅ Good
\`\`\`[language]
// Concrete working example
// Include comments explaining WHY this is good
const example = {
  pattern: "correct",
  reason: "clear and maintainable"
};
\`\`\`

### ❌ Bad
\`\`\`[language]
// Example of what NOT to do
// Include comments explaining WHY this is bad
var badExample = {
  pattern: "incorrect",
  reason: "prone to bugs"
};
\`\`\`

### Why This Matters

[1-2 sentences explaining the impact]

## [Topic Area 2]

[Repeat structure above]

## Common Pitfalls

1. **[Pitfall Name]**: [How to avoid it]
2. **[Pitfall Name]**: [Better alternative]

## Dependencies

If this requires specific packages:

\`\`\`bash
# Install required dependencies
npm install [package]@[version]
\`\`\`

## When to Use

- ✅ **Use when**: [Specific scenario]
- ✅ **Use when**: [Specific scenario]
- ❌ **Don't use when**: [Specific scenario]

## Additional Resources

- [Official Docs](URL)
- [Style Guide](URL)
- [Community Standards](URL)

**ALWAYS follow these [Technology] standards in every file you create or modify.**
```

---

## Examples

### Example 1: Python Django Skill

```markdown
# Django Best Practices

**Version**: Django 4.2+  
**Last Updated**: 2025-01-14

## Core Principles

1. **Fat Models, Thin Views** - Business logic in models, not views
2. **Use Class-Based Views** - For reusability and DRY
3. **Security First** - Always use Django's built-in security features

## Model Definitions

### ✅ Good
\`\`\`python
from django.db import models
from django.core.validators import MinValueValidator
from django.utils import timezone

class Product(models.Model):
    """Product model with proper validation and methods."""
    
    name = models.CharField(max_length=200, db_index=True)
    price = models.DecimalField(
        max_digits=10, 
        decimal_places=2,
        validators=[MinValueValidator(0.01)]
    )
    created_at = models.DateTimeField(default=timezone.now)
    
    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['name', 'created_at']),
        ]
    
    def __str__(self):
        return self.name
    
    def get_absolute_url(self):
        return reverse('product-detail', kwargs={'pk': self.pk})
\`\`\`

### ❌ Bad
\`\`\`python
class Product(models.Model):
    name = models.CharField(max_length=200)
    price = models.FloatField()  # ❌ Use DecimalField for money!
    # ❌ Missing __str__, indexes, validators
\`\`\`

## View Patterns

### ✅ Good
\`\`\`python
from django.views.generic import ListView, CreateView
from django.contrib.auth.mixins import LoginRequiredMixin

class ProductListView(LoginRequiredMixin, ListView):
    model = Product
    template_name = 'products/list.html'
    context_object_name = 'products'
    paginate_by = 20
    
    def get_queryset(self):
        return Product.objects.select_related('category')
\`\`\`

### ❌ Bad
\`\`\`python
def product_list(request):
    products = Product.objects.all()  # ❌ No pagination, no optimization
    return render(request, 'list.html', {'products': products})
\`\`\`

**ALWAYS use Django best practices: Fat models, class-based views, proper validation, and security features.**
```

### Example 2: Docker Skill

```markdown
# Docker Best Practices

**Version**: Docker 24+, Docker Compose 2.0+  
**Last Updated**: 2025-01-14

## Core Principles

1. **Multi-Stage Builds** - Smaller final images
2. **Layer Caching** - Optimize build times
3. **Security** - Non-root users, minimal base images
4. **12-Factor App** - Environment-based configuration

## Dockerfile Structure

### ✅ Good
\`\`\`dockerfile
# Multi-stage build for Node.js app
FROM node:20-alpine AS builder

WORKDIR /app

# Install dependencies (cached layer)
COPY package*.json ./
RUN npm ci --only=production

# Copy source code
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine

# Security: Run as non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

WORKDIR /app

# Copy only production files
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

USER nodejs

EXPOSE 3000

CMD ["node", "dist/index.js"]
\`\`\`

### ❌ Bad
\`\`\`dockerfile
FROM node:20  # ❌ Use alpine for smaller size

WORKDIR /app

COPY . .  # ❌ This invalidates cache on every file change!

RUN npm install  # ❌ Installs dev dependencies too

# ❌ Running as root is a security risk
CMD ["node", "index.js"]
\`\`\`

## Docker Compose

### ✅ Good
\`\`\`yaml
version: '3.9'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: production  # Use multi-stage target
    ports:
      - "3000:3000"
    environment:
      NODE_ENV: production
      DATABASE_URL: postgresql://postgres:password@db:5432/myapp
    depends_on:
      db:
        condition: service_healthy
    restart: unless-stopped
    
  db:
    image: postgres:16-alpine
    volumes:
      - db-data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: myapp
      POSTGRES_PASSWORD: password
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  db-data:
\`\`\`

**ALWAYS use multi-stage builds, non-root users, .dockerignore, and health checks in Docker.**
```

---

## Troubleshooting

### Skills Not Loading

**Problem**: Skills aren't being injected

**Solutions**:
1. Check file location: Must be in `.factory/skills/`
2. Check file extension: Must be `.md`
3. Check hook script permissions:
   ```bash
   chmod +x .factory/hooks/*.sh
   ```
4. Check hook configuration in `.factory/settings.json`
5. Test detection pattern:
   ```bash
   echo "test typescript prompt" | grep -qiE "typescript" && echo "Match!"
   ```

### Hook Script Errors

**Problem**: Hooks failing silently

**Solutions**:
1. Run droid with debug mode:
   ```bash
   droid --debug
   ```
2. Test hook script manually:
   ```bash
   echo '{"prompt":"test typescript","cwd":"."}' | .factory/hooks/inject-skills.sh
   ```
3. Check script syntax:
   ```bash
   bash -n .factory/hooks/inject-skills.sh
   ```

### Skills Too Verbose

**Problem**: Context window filling up

**Solutions**:
1. **Be concise**: Focus on most important patterns
2. **Split skills**: Create focused files (`react-hooks.md`, `react-components.md`)
3. **Remove duplication**: Link to external docs for details
4. **Conditional loading**: Only load skills when truly relevant

---

## Next Steps

1. ✅ **Review existing skills** in `.factory/skills/`
2. ✅ **Create your first custom skill** using the template
3. ✅ **Test it** with a droid session
4. ✅ **Iterate** based on results
5. ✅ **Share** successful skills with your team

**Want more examples?** Check out the pre-built skills:
- `typescript.md` - TypeScript standards
- `tailwind-4.md` - Tailwind CSS patterns
- `convex.md` - Convex best practices
- `security.md` - Security guidelines

---

## Contributing

Found a great pattern? Created an amazing skill? **Share it!**

1. Add your skill to `.factory/skills/`
2. Document it in this file
3. Submit a PR to the Droidz repo

**Together we make AI coding better for everyone!** 🚀
