# API Design

## Overview

Well-designed APIs are intuitive, consistent, and maintainable. This standard defines REST API design principles for building scalable and developer-friendly APIs.

## When to Apply

- Designing new API endpoints
- Refactoring existing APIs
- Creating API documentation
- Reviewing API pull requests
- Planning API versioning

## Core Principles

1. **RESTful Design** - Use HTTP methods appropriately (GET, POST, PUT, PATCH, DELETE)
2. **Resource-Based URLs** - URLs represent resources, not actions
3. **Consistency** - Predictable patterns across all endpoints
4. **Versioning** - Support API evolution without breaking clients
5. **Clear Documentation** - Self-documenting with examples

## ✅ DO

### DO: Use Resource-Based URLs

**✅ DO**:
```
GET    /api/v1/users           # List users
GET    /api/v1/users/123       # Get specific user
POST   /api/v1/users           # Create user
PUT    /api/v1/users/123       # Update user (full)
PATCH  /api/v1/users/123       # Update user (partial)
DELETE /api/v1/users/123       # Delete user
```

### DO: Return Appropriate Status Codes

**✅ DO**:
```typescript
// Success cases
app.get('/users/:id', async (req, res) => {
  const user = await findUser(req.params.id);
  if (!user) return res.status(404).json({ error: 'User not found' });
  res.status(200).json(user);
});

app.post('/users', async (req, res) => {
  const user = await createUser(req.body);
  res.status(201).json(user); // 201 Created
});

app.delete('/users/:id', async (req, res) => {
  await deleteUser(req.params.id);
  res.status(204).send(); // 204 No Content
});
```

### DO: Use Query Parameters for Filtering

**✅ DO**:
```
GET /api/v1/users?role=admin&status=active&page=2&limit=20
GET /api/v1/products?category=electronics&minPrice=100&sort=price:desc
```

```typescript
app.get('/users', async (req, res) => {
  const { role, status, page = 1, limit = 20 } = req.query;
  const users = await findUsers({ role, status, page, limit });
  res.json({
    data: users,
    pagination: {
      page: Number(page),
      limit: Number(limit),
      total: users.total
    }
  });
});
```

### DO: Version Your API

**✅ DO**:
```
/api/v1/users    # Version 1
/api/v2/users    # Version 2 with breaking changes
```

```typescript
app.use('/api/v1', v1Routes);
app.use('/api/v2', v2Routes);
```

### DO: Include Pagination Metadata

**✅ DO**:
```json
{
  "data": [...],
  "pagination": {
    "page": 2,
    "limit": 20,
    "total": 157,
    "totalPages": 8,
    "hasNext": true,
    "hasPrev": true
  }
}
```

## ❌ DON'T

### DON'T: Use Verbs in URLs

**❌ DON'T**:
```
POST /api/createUser
GET  /api/getUser/123
POST /api/deleteUser/123
```
**Why**: Not RESTful. Use HTTP methods instead of URL verbs.

### DON'T: Return Generic Status Codes

**❌ DON'T**:
```typescript
app.get('/users/:id', async (req, res) => {
  try {
    const user = await findUser(req.params.id);
    res.json(user || {});  // Returns 200 even if not found!
  } catch (error) {
    res.status(500).json({ error: 'Error' });  // Too generic!
  }
});
```
**Why**: Clients can't distinguish between success, not found, and errors.

### DON'T: Nest Resources Too Deeply

**❌ DON'T**:
```
/api/v1/users/123/posts/456/comments/789/likes/012
```
**Why**: Hard to maintain. Limit nesting to 2-3 levels max.

**✅ Better**:
```
/api/v1/comments/789/likes
/api/v1/likes?commentId=789
```

### DON'T: Mix Response Formats

**❌ DON'T**:
```json
// Endpoint 1
{ "user": {...}, "success": true }

// Endpoint 2
{ "data": {...} }

// Endpoint 3
{ "result": {...}, "status": "ok" }
```
**Why**: Inconsistent responses confuse API consumers.

### DON'T: Expose Internal Implementation

**❌ DON'T**:
```
/api/v1/database/users/query
/api/v1/cache/invalidate
```
**Why**: Leaks implementation details. APIs should be implementation-agnostic.

## Patterns & Examples

### Pattern 1: Consistent Error Format

**Use Case**: Standardize error responses across all endpoints

**Implementation**:
```typescript
interface ApiError {
  error: {
    code: string;
    message: string;
    details?: unknown;
    timestamp: string;
  };
}

app.use((err, req, res, next) => {
  const status = err.status || 500;
  res.status(status).json({
    error: {
      code: err.code || 'INTERNAL_ERROR',
      message: err.message,
      details: process.env.NODE_ENV === 'development' ? err.stack : undefined,
      timestamp: new Date().toISOString()
    }
  });
});
```

### Pattern 2: HATEOAS (Hypermedia Links)

**Use Case**: Make API self-discoverable

**Implementation**:
```json
{
  "id": "123",
  "name": "John Doe",
  "email": "john@example.com",
  "_links": {
    "self": { "href": "/api/v1/users/123" },
    "posts": { "href": "/api/v1/users/123/posts" },
    "followers": { "href": "/api/v1/users/123/followers" }
  }
}
```

### Pattern 3: Rate Limiting

**Use Case**: Protect API from abuse

**Implementation**:
```typescript
import rateLimit from 'express-rate-limit';

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per window
  standardHeaders: true,
  legacyHeaders: false,
});

app.use('/api/', limiter);

// Headers returned:
// RateLimit-Limit: 100
// RateLimit-Remaining: 95
// RateLimit-Reset: 1640000000
```

## Common Mistakes

1. **Forgetting to Handle OPTIONS Requests (CORS)**
   - Problem: Preflight requests fail
   - Solution: Configure CORS middleware properly

2. **Not Validating Input**
   - Problem: Invalid data reaches database
   - Solution: Use validation middleware (Joi, Zod, class-validator)

3. **Returning Too Much Data**
   - Problem: Performance and security issues
   - Solution: Use field filtering (`?fields=id,name,email`)

4. **Inconsistent Naming (camelCase vs snake_case)**
   - Problem: Confusing for API consumers
   - Solution: Pick one convention (camelCase for JSON is common)

## Testing Standards

```typescript
describe('Users API', () => {
  it('GET /users should return 200 and user list', async () => {
    const res = await request(app).get('/api/v1/users');
    expect(res.status).toBe(200);
    expect(res.body.data).toBeInstanceOf(Array);
    expect(res.body.pagination).toBeDefined();
  });
  
  it('GET /users/:id should return 404 for non-existent user', async () => {
    const res = await request(app).get('/api/v1/users/999999');
    expect(res.status).toBe(404);
    expect(res.body.error).toBeDefined();
  });
  
  it('POST /users should return 201 and created user', async () => {
    const res = await request(app)
      .post('/api/v1/users')
      .send({ name: 'John', email: 'john@example.com' });
    expect(res.status).toBe(201);
    expect(res.body.id).toBeDefined();
  });
  
  it('POST /users should return 400 for invalid data', async () => {
    const res = await request(app)
      .post('/api/v1/users')
      .send({ email: 'invalid-email' });
    expect(res.status).toBe(400);
  });
});
```

## Resources

- [REST API Tutorial](https://restfulapi.net/)
- [HTTP Status Codes](https://httpstatuses.com/)
- [API Design Guide by Google](https://cloud.google.com/apis/design)
- [Microsoft REST API Guidelines](https://github.com/microsoft/api-guidelines)
- [Zalando RESTful API Guidelines](https://opensource.zalando.com/restful-api-guidelines/)
