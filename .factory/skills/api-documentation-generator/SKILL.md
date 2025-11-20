---
name: api-documentation-generator
description: Auto-activates when user mentions API documentation, endpoint docs, API reference, or OpenAPI spec. Generates comprehensive API documentation from code.
category: documentation
---

# API Documentation Generator

Automatically generates professional API documentation from your code, including OpenAPI/Swagger specs.

## When This Activates

- User says: "generate API docs", "document this API", "create API reference"
- User mentions: "OpenAPI spec", "Swagger docs", "API documentation"
- Files being worked on: API routes, controllers, endpoints

## Documentation Formats

### 1. OpenAPI 3.0 Spec (Recommended)

```yaml
openapi: 3.0.0
info:
  title: Your API Name
  version: 1.0.0
  description: API for [purpose]
  contact:
    name: API Support
    email: api@example.com

servers:
  - url: https://api.example.com/v1
    description: Production
  - url: https://api-staging.example.com/v1
    description: Staging

paths:
  /users:
    get:
      summary: List all users
      description: Returns a paginated list of users
      tags:
        - Users
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
            maximum: 100
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items:
                      $ref: '#/components/schemas/User'
                  pagination:
                    $ref: '#/components/schemas/Pagination'
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'

components:
  schemas:
    User:
      type: object
      required:
        - id
        - email
        - name
      properties:
        id:
          type: string
          format: uuid
          example: "123e4567-e89b-12d3-a456-426614174000"
        email:
          type: string
          format: email
          example: "user@example.com"
        name:
          type: string
          example: "John Doe"
        createdAt:
          type: string
          format: date-time
          example: "2025-01-01T00:00:00Z"
```

### 2. Markdown API Reference

```markdown
# API Reference

## Authentication

All API requests require authentication via Bearer token:

\`\`\`bash
Authorization: Bearer YOUR_API_KEY
\`\`\`

## Base URL

- Production: `https://api.example.com/v1`
- Staging: `https://api-staging.example.com/v1`

## Endpoints

### List Users

`GET /users`

Returns a paginated list of users.

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | 1 | Page number |
| `limit` | integer | 20 | Items per page (max 100) |
| `sort` | string | `createdAt` | Sort field |
| `order` | string | `desc` | Sort order (`asc` or `desc`) |

**Response:**

\`\`\`json
{
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "email": "user@example.com",
      "name": "John Doe",
      "createdAt": "2025-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
\`\`\`

**Error Responses:**

| Status | Description |
|--------|-------------|
| 400 | Invalid query parameters |
| 401 | Unauthorized (missing or invalid token) |
| 429 | Rate limit exceeded |
| 500 | Internal server error |

**Example:**

\`\`\`bash
curl -H "Authorization: Bearer YOUR_API_KEY" \\
  "https://api.example.com/v1/users?page=1&limit=20"
\`\`\`
```

## Process

1. **Scan API files:**
   - Read route definitions
   - Extract controllers/handlers
   - Find validation schemas
   - Identify auth requirements

2. **Extract metadata:**
   - HTTP methods
   - URL paths
   - Query/body parameters
   - Response types
   - Error codes

3. **Generate documentation:**
   - OpenAPI spec OR Markdown
   - Include examples for every endpoint
   - Document authentication
   - Add rate limiting info
   - Include error responses

4. **Validate:**
   - Check OpenAPI spec validity
   - Ensure all endpoints documented
   - Verify example requests work

## Auto-Detection

### Express.js

```javascript
// Detected pattern:
app.get('/api/users', authMiddleware, async (req, res) => {
  // Auto-document: GET /api/users, requires auth
});
```

### Next.js API Routes

```typescript
// Detected pattern:
export async function GET(request: Request) {
  // Auto-document: GET endpoint in Next.js
}
```

### FastAPI

```python
# Detected pattern:
@app.get("/users", response_model=List[User])
async def list_users(page: int = 1, limit: int = 20):
    # Auto-generate from FastAPI annotations
```

## Code Examples

Generate working examples for every endpoint:

```bash
# cURL
curl -X GET "https://api.example.com/v1/users?page=1" \\
  -H "Authorization: Bearer YOUR_TOKEN"

# JavaScript/Fetch
fetch('https://api.example.com/v1/users?page=1', {
  headers: { 'Authorization': 'Bearer YOUR_TOKEN' }
})
  .then(res => res.json())
  .then(data => console.log(data));

# Python/Requests
import requests
response = requests.get(
  'https://api.example.com/v1/users',
  params={'page': 1},
  headers={'Authorization': 'Bearer YOUR_TOKEN'}
)
print(response.json())
```

## Interactive Docs

If using OpenAPI spec, recommend tools:

```bash
# Generate interactive docs with Swagger UI
npx swagger-ui-watcher openapi.yaml

# Or Redoc
npx redoc-cli serve openapi.yaml

# Or Stoplight Elements
npx @stoplight/elements-dev-portal openapi.yaml
```

## Best Practices

✅ **DO:**
- Include working examples for every endpoint
- Document error responses with examples
- Show authentication requirements
- Explain rate limiting
- Include pagination details
- Add timestamps to examples
- Show both success and error responses

❌ **DON'T:**
- Document without testing endpoints
- Use vague parameter descriptions
- Skip error response documentation
- Forget to document authentication
- Use outdated examples
- Miss query parameters

## Output Files

```
docs/
├── api/
│   ├── openapi.yaml          # OpenAPI 3.0 spec
│   ├── reference.md          # Markdown reference
│   └── examples/
│       ├── authentication.md
│       ├── users.md
│       └── pagination.md
```

## Maintenance

```markdown
## 📌 API Documentation Checklist

When adding new endpoints:
- [ ] Update openapi.yaml
- [ ] Add to reference.md
- [ ] Include curl example
- [ ] Document error responses
- [ ] Test example requests
- [ ] Update changelog
```

**Auto-update docs when API changes detected.**
