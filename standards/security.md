# Security Standards

Security requirements that all Droidz implementations must follow.

## Critical Rules

### 1. Never Commit Secrets

```bash
# ❌ NEVER commit these
API_KEY=abc123
DATABASE_URL=postgres://user:pass@host/db
PRIVATE_KEY=...

# ✅ Use environment variables
# .env (gitignored)
API_KEY=abc123

# .env.example (committed)
API_KEY=your_api_key_here
```

### 2. Environment Variables Only

```typescript
// ✅ Good: Environment variables
const apiKey = process.env.API_KEY;
const dbUrl = process.env.DATABASE_URL;

// ❌ Bad: Hardcoded secrets
const apiKey = 'sk_live_abc123';
```

### 3. Client vs Server

```typescript
// ❌ Bad: Secret in client code
export function ClientComponent() {
  const data = await fetch('/api/data', {
    headers: { 'X-API-Key': process.env.SECRET_KEY }
  });
}

// ✅ Good: Secret only on server
// API route
export async function GET() {
  const data = await externalAPI(process.env.SECRET_KEY);
  return Response.json(data);
}
```

## Input Validation

### Validate ALL User Input

```typescript
// ✅ Validate and sanitize
function createUser(input: unknown) {
  const schema = z.object({
    email: z.string().email(),
    age: z.number().min(18).max(120),
  });
  
  const validated = schema.parse(input);
  return db.users.create(validated);
}

// ❌ No validation
function createUser(input: any) {
  return db.users.create(input);
}
```

### SQL Injection Prevention

```typescript
// ✅ Use parameterized queries or ORM
db.query('SELECT * FROM users WHERE id = ?', [userId]);

// Or with ORM
db.users.findUnique({ where: { id: userId } });

// ❌ NEVER string concatenation
db.query(`SELECT * FROM users WHERE id = ${userId}`);
```

### XSS Prevention

```typescript
// ✅ Framework handles escaping (React, etc.)
<div>{userInput}</div>

// ⚠️ Dangerous HTML: sanitize first
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{ 
  __html: DOMPurify.sanitize(userHTML) 
}} />

// ❌ NEVER use unsanitized HTML
<div dangerouslySetInnerHTML={{ __html: userHTML }} />
```

## Authentication

### Password Handling

```typescript
// ✅ Hash passwords (use bcrypt, argon2)
import bcrypt from 'bcrypt';

async function createUser(email: string, password: string) {
  const hashedPassword = await bcrypt.hash(password, 10);
  return db.users.create({ email, password: hashedPassword });
}

// ❌ NEVER store plain text passwords
db.users.create({ email, password }); // NO!
```

### Session Management

```typescript
// ✅ Use secure session libraries
import { getServerSession } from 'next-auth';

export async function GET() {
  const session = await getServerSession();
  if (!session) {
    return new Response('Unauthorized', { status: 401 });
  }
  // ...
}

// ✅ Set secure cookie flags
res.cookie('session', token, {
  httpOnly: true,
  secure: true, // HTTPS only
  sameSite: 'strict',
  maxAge: 3600000,
});
```

## Authorization

```typescript
// ✅ Check permissions
async function deletePost(postId: string, userId: string) {
  const post = await db.posts.findUnique({ where: { id: postId } });
  
  if (post.authorId !== userId) {
    throw new UnauthorizedError('You can only delete your own posts');
  }
  
  return db.posts.delete({ where: { id: postId } });
}

// ❌ Missing authorization check
async function deletePost(postId: string) {
  return db.posts.delete({ where: { id: postId } });
}
```

## HTTPS Only

```typescript
// ✅ Enforce HTTPS in production
if (process.env.NODE_ENV === 'production' && !req.secure) {
  return res.redirect(`https://${req.hostname}${req.url}`);
}
```

## CORS Configuration

```typescript
// ✅ Specific origins
const corsOptions = {
  origin: ['https://yourapp.com', 'https://www.yourapp.com'],
  credentials: true,
};

// ❌ Don't use wildcard in production
const corsOptions = {
  origin: '*', // Only for development!
};
```

## Rate Limiting

```typescript
// ✅ Implement rate limiting
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
});

app.use('/api/', limiter);
```

## Logging

```typescript
// ✅ Log security events (sanitized)
logger.info('Login attempt', { 
  userId: user.id,
  ip: req.ip,
  success: true 
});

// ❌ NEVER log sensitive data
logger.info('Login', { 
  password: password,  // NO!
  creditCard: card,    // NO!
});
```

## File Uploads

```typescript
// ✅ Validate file types
const allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];

function validateFile(file: File) {
  if (!allowedTypes.includes(file.type)) {
    throw new Error('Invalid file type');
  }
  
  if (file.size > 5 * 1024 * 1024) {
    throw new Error('File too large');
  }
  
  return true;
}
```

## Dependencies

```bash
# ✅ Keep dependencies updated
npm audit
npm update

# ✅ Use lock files
npm ci  # Uses package-lock.json exactly
```

## Security Headers

```typescript
// ✅ Set security headers
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Strict-Transport-Security', 'max-age=31536000');
  next();
});
```

## Security Checklist

Before marking a feature complete:

- [ ] No secrets in code or commits
- [ ] All user input validated
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (proper escaping)
- [ ] Passwords hashed (never plain text)
- [ ] Authentication implemented
- [ ] Authorization checked
- [ ] HTTPS enforced (production)
- [ ] CORS configured properly
- [ ] Rate limiting implemented
- [ ] Security headers set
- [ ] File uploads validated
- [ ] Dependencies audited
- [ ] Sensitive data not logged

## Customization

**To customize for your project**, edit this file to add specific security requirements (PCI compliance, HIPAA, etc.).
