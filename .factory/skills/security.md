# Security Best Practices

## Core Principles

1. **Never Trust User Input** - Always validate and sanitize
2. **Defense in Depth** - Multiple layers of security
3. **Principle of Least Privilege** - Minimum necessary permissions
4. **Secure by Default** - Security should be the default state
5. **Keep Secrets Secret** - Never commit credentials

## Environment Variables & Secrets

### ✅ Good
```typescript
// Use environment variables
const apiKey = process.env.API_KEY;
if (!apiKey) {
  throw new Error("API_KEY environment variable is required");
}

// Type-safe environment variables
interface Env {
  DATABASE_URL: string;
  API_KEY: string;
  JWT_SECRET: string;
}

function getEnv(): Env {
  const required = ['DATABASE_URL', 'API_KEY', 'JWT_SECRET'];
  const missing = required.filter(key => !process.env[key]);
  
  if (missing.length > 0) {
    throw new Error(`Missing required env vars: ${missing.join(', ')}`);
  }
  
  return process.env as unknown as Env;
}
```

### ❌ Bad
```typescript
// NEVER hardcode secrets
const apiKey = "sk-abc123";  // ❌ NEVER DO THIS

// NEVER commit .env files
// Add .env to .gitignore!

// NEVER log secrets
console.log('API Key:', process.env.API_KEY);  // ❌ Exposed in logs
```

## Input Validation

### ✅ Good
```typescript
import { z } from "zod";

// Validate all inputs with Zod
const UserSchema = z.object({
  email: z.string().email().max(255),
  password: z.string().min(12).max(128),
  age: z.number().int().min(13).max(120),
});

function createUser(input: unknown) {
  // Validate throws if invalid
  const data = UserSchema.parse(input);
  
  // Now safe to use
  return db.users.create(data);
}

// Sanitize HTML input
import DOMPurify from 'isomorphic-dompurify';

function sanitizeHtml(html: string): string {
  return DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'a', 'p'],
    ALLOWED_ATTR: ['href'],
  });
}
```

### ❌ Bad
```typescript
// No validation
function createUser(input: any) {
  return db.users.create(input);  // ❌ Accepts anything!
}

// Direct HTML injection
function renderComment(comment: string) {
  return <div dangerouslySetInnerHTML={{ __html: comment }} />;  // ❌ XSS!
}
```

## SQL Injection Prevention

### ✅ Good
```typescript
// Use parameterized queries
const user = await db.query(
  'SELECT * FROM users WHERE email = $1',
  [email]  // Parameterized
);

// Use query builders (Prisma, Drizzle)
const user = await db.user.findUnique({
  where: { email },  // Safe with ORM
});
```

### ❌ Bad
```typescript
// NEVER concatenate user input into SQL
const user = await db.query(
  `SELECT * FROM users WHERE email = '${email}'`  // ❌ SQL injection!
);
```

## Authentication & Authorization

### ✅ Good
```typescript
import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';

// Hash passwords properly
async function hashPassword(password: string): Promise<string> {
  const saltRounds = 12;  // Adjust based on security needs
  return await bcrypt.hash(password, saltRounds);
}

// Verify passwords securely
async function verifyPassword(
  password: string, 
  hash: string
): Promise<boolean> {
  return await bcrypt.compare(password, hash);
}

// Generate secure JWTs
function generateToken(userId: string): string {
  const secret = process.env.JWT_SECRET!;
  return jwt.sign(
    { userId },
    secret,
    { expiresIn: '7d', algorithm: 'HS256' }
  );
}

// Verify JWTs
function verifyToken(token: string): { userId: string } {
  const secret = process.env.JWT_SECRET!;
  try {
    return jwt.verify(token, secret) as { userId: string };
  } catch (error) {
    throw new Error('Invalid token');
  }
}

// Check authorization
async function checkPermission(
  userId: string, 
  resource: string, 
  action: string
): Promise<boolean> {
  const user = await db.user.findUnique({ where: { id: userId } });
  if (!user) return false;
  
  // Role-based access control
  const permissions = {
    admin: ['read', 'write', 'delete'],
    user: ['read', 'write'],
    guest: ['read'],
  };
  
  return permissions[user.role]?.includes(action) ?? false;
}
```

### ❌ Bad
```typescript
// NEVER store passwords in plain text
await db.user.create({
  email,
  password,  // ❌ Plain text!
});

// Weak hashing
const hash = crypto.createHash('md5').update(password).digest('hex');  // ❌ MD5 is broken!

// No expiration on tokens
const token = jwt.sign({ userId }, secret);  // ❌ Never expires!
```

## CORS & CSP

### ✅ Good
```typescript
// Strict CORS configuration
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['https://myapp.com'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Content Security Policy
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],  // Minimize inline scripts
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", "https://api.myapp.com"],
    },
  },
}));
```

## Rate Limiting

### ✅ Good
```typescript
import rateLimit from 'express-rate-limit';

// API rate limiting
const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,  // 15 minutes
  max: 100,  // Limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP',
  standardHeaders: true,
  legacyHeaders: false,
});

app.use('/api/', apiLimiter);

// Stricter limits for sensitive endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,  // 5 login attempts per 15 minutes
  skipSuccessfulRequests: true,
});

app.post('/api/login', authLimiter, loginHandler);
```

## File Upload Security

### ✅ Good
```typescript
import multer from 'multer';
import path from 'path';

const upload = multer({
  limits: {
    fileSize: 5 * 1024 * 1024,  // 5MB limit
  },
  fileFilter: (req, file, cb) => {
    // Whitelist allowed extensions
    const allowedExtensions = ['.jpg', '.jpeg', '.png', '.pdf'];
    const ext = path.extname(file.originalname).toLowerCase();
    
    if (allowedExtensions.includes(ext)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type'));
    }
  },
  storage: multer.diskStorage({
    destination: 'uploads/',
    filename: (req, file, cb) => {
      // Generate unique, safe filename
      const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
      const ext = path.extname(file.originalname);
      cb(null, `file-${uniqueSuffix}${ext}`);
    },
  }),
});
```

### ❌ Bad
```typescript
// No validation
const upload = multer({ dest: 'uploads/' });  // ❌ No limits or filtering!

// Using original filename
filename: (req, file, cb) => {
  cb(null, file.originalname);  // ❌ Path traversal risk!
}
```

## Security Headers

```typescript
import helmet from 'helmet';

// Use Helmet for security headers
app.use(helmet());

// Specific headers
app.use(helmet.hsts({
  maxAge: 31536000,  // 1 year
  includeSubDomains: true,
  preload: true,
}));

app.use(helmet.noSniff());
app.use(helmet.frameguard({ action: 'deny' }));
```

## Dependency Security

```bash
# Regular audits
npm audit
npm audit fix

# Use Snyk or similar
npx snyk test

# Keep dependencies updated
npm outdated
npm update
```

## .gitignore Essentials

```
# ALWAYS ignore
.env
.env.local
.env.*.local
*.key
*.pem
secrets/

# Sensitive config
config/production.json
```

**NEVER commit secrets. ALWAYS validate input. ALWAYS use HTTPS. ALWAYS keep dependencies updated.**
