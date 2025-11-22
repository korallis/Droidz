# Feature Spec: Real-Time Notification System

> **Status**: Example/Reference
> **Created**: 2025-11-22
> **Author**: Droidz Team
> **Spec ID**: EXAMPLE-000

---

## Overview

### Purpose
Build a real-time notification system that alerts users to important events across the application, including new messages, mentions, system alerts, and activity updates.

### User Story
As a platform user,
I want to receive instant notifications when important events happen,
So that I can stay informed and respond quickly without constantly refreshing the page.

### Business Value
- **Improved engagement**: Users stay active longer when receiving real-time updates
- **Better UX**: Eliminates need for manual page refreshes
- **Increased retention**: Timely notifications bring users back to the platform
- **Competitive advantage**: Modern real-time experience expected by users

---

## Requirements

### Functional Requirements

- [ ] Display notifications in a dropdown panel accessible from header
- [ ] Support notification types: message, mention, system, activity
- [ ] Show unread count badge on notification icon
- [ ] Mark notifications as read when viewed
- [ ] Support "mark all as read" action
- [ ] Persist notifications across sessions (stored in database)
- [ ] Send real-time push notifications via WebSocket
- [ ] Allow users to configure notification preferences
- [ ] Support notification grouping (e.g., "3 new messages")
- [ ] Include deep links to relevant content

### Non-Functional Requirements

- [ ] Performance: Notifications appear within 1 second of event
- [ ] Performance: Initial notification load < 500ms
- [ ] Security: Users can only see their own notifications
- [ ] Scalability: Support 10,000+ concurrent WebSocket connections
- [ ] Accessibility: WCAG 2.1 AA compliant, screen reader friendly
- [ ] Browser support: Chrome 90+, Firefox 88+, Safari 14+, Edge 90+
- [ ] Mobile responsive: Full functionality on mobile devices

### Constraints

- Must work with existing authentication system
- Cannot exceed $100/month in infrastructure costs initially
- Must integrate with current PostgreSQL database
- Should reuse existing UI component library

---

## Architecture

### Technical Approach

**Frontend**:
- Framework: React 18+ with TypeScript
- State management: Zustand for notification state
- WebSocket client: Socket.io-client v4
- UI library: Radix UI for dropdown, Tailwind CSS for styling
- Animations: Framer Motion for smooth transitions

**Backend**:
- Runtime: Node.js 20+ with TypeScript
- Framework: Express.js for REST API
- WebSocket: Socket.io v4 for real-time communication
- Database: PostgreSQL 15+ with Prisma ORM
- Queue: Redis for notification queue and pub/sub

**Infrastructure**:
- Hosting: Vercel for frontend, Railway for backend
- Database: Neon (serverless Postgres)
- Cache: Upstash Redis (serverless)
- CI/CD: GitHub Actions

### Key Components

1. **NotificationDropdown** (Frontend)
   - Displays notification list in dropdown panel
   - Handles mark as read, clear all actions
   - Manages WebSocket connection lifecycle

2. **NotificationService** (Backend)
   - Creates and persists notifications
   - Broadcasts to connected clients via Socket.io
   - Handles notification preferences

3. **WebSocket Server** (Backend)
   - Authenticates connections via JWT
   - Manages user rooms/channels
   - Emits notifications to specific users

4. **NotificationQueue** (Backend)
   - Queues notifications for bulk processing
   - Handles retries for failed deliveries
   - Aggregates similar notifications

### Data Model

```prisma
model Notification {
  id          String   @id @default(cuid())
  userId      String
  type        NotificationType
  title       String
  message     String
  link        String?
  read        Boolean  @default(false)
  readAt      DateTime?
  metadata    Json?
  createdAt   DateTime @default(now())
  
  user        User     @relation(fields: [userId], references: [id])
  
  @@index([userId, read])
  @@index([createdAt])
}

enum NotificationType {
  MESSAGE
  MENTION
  SYSTEM
  ACTIVITY
}

model NotificationPreference {
  id          String   @id @default(cuid())
  userId      String   @unique
  emailNotif  Boolean  @default(true)
  pushNotif   Boolean  @default(true)
  types       Json     // { MESSAGE: true, MENTION: true, ... }
  
  user        User     @relation(fields: [userId], references: [id])
}
```

### API Endpoints

**REST API**:
- `GET /api/notifications` - Fetch user's notifications (paginated)
- `GET /api/notifications/unread-count` - Get unread notification count
- `PATCH /api/notifications/:id/read` - Mark notification as read
- `PATCH /api/notifications/read-all` - Mark all notifications as read
- `DELETE /api/notifications/:id` - Delete a notification
- `GET /api/notifications/preferences` - Get notification preferences
- `PATCH /api/notifications/preferences` - Update preferences

**WebSocket Events**:
- `notification:new` - Server → Client (new notification)
- `notification:read` - Client → Server (mark as read)
- `notification:read-all` - Client → Server (mark all as read)

### Architecture Decisions

**Decision**: Use Socket.io instead of native WebSockets
**Rationale**: Socket.io provides automatic reconnection, fallback to long-polling, and built-in room support
**Trade-offs**: Slightly larger bundle size (~10KB), but better developer experience and reliability
**Alternatives considered**: Native WebSockets (more control but more boilerplate), Server-Sent Events (unidirectional only)

**Decision**: Store notifications in PostgreSQL
**Rationale**: Need persistence, complex queries, and already using Postgres for main database
**Trade-offs**: More database load vs Redis (in-memory only)
**Alternatives considered**: MongoDB (overkill for simple schema), Redis (no persistence)

**Decision**: Use JWT for WebSocket authentication
**Rationale**: Reuse existing auth system, stateless, secure
**Trade-offs**: Token expiration requires reconnection handling
**Alternatives considered**: Session-based (stateful, harder to scale), API key (less secure)

---

## User Experience

### User Flow

1. User logs in → WebSocket connection established with JWT
2. Event occurs (e.g., someone sends a message) → Backend creates notification
3. Backend broadcasts notification via Socket.io to user's room
4. Frontend receives event → Updates notification store
5. UI shows unread badge count, notification appears in dropdown
6. User clicks notification icon → Dropdown opens showing notifications
7. User clicks notification → Marks as read, navigates to content
8. Backend persists read status → Updates database

### UI/UX Requirements

- **Layout**: 
  - Bell icon in header with unread badge
  - Dropdown panel (350px wide, max 500px tall)
  - List of notifications, most recent first
  - Empty state for no notifications

- **Key interactions**:
  - Click bell icon → Toggle dropdown
  - Click notification → Mark as read + navigate to link
  - Hover notification → Show full text (if truncated)
  - Click "Mark all as read" → Clear all unread
  - Smooth animations for new notifications

- **Responsiveness**: 
  - Desktop: Dropdown from header
  - Mobile: Full-screen panel slides in from right

- **Accessibility**:
  - Keyboard navigation (Tab, Enter, Escape)
  - ARIA labels for screen readers
  - Focus management when opening dropdown
  - Announce new notifications to screen readers

### Wireframes/Mockups

```
┌─────────────────────────────────────┐
│  Logo    Search...    🔔(3)  Avatar │  ← Header
└─────────────────────────────────────┘
                           │
                           ▼
              ┌─────────────────────────┐
              │ Notifications     •••   │
              ├─────────────────────────┤
              │ 🔵 John mentioned you   │
              │    "Great work on..."   │
              │    2 min ago            │
              ├─────────────────────────┤
              │ ⚫ New message from      │
              │    Sarah                │
              │    15 min ago           │
              ├─────────────────────────┤
              │ 🔵 System: Update       │
              │    available            │
              │    1 hour ago           │
              ├─────────────────────────┤
              │ [Mark all as read]      │
              └─────────────────────────┘
```

---

## Implementation Plan

### Task Breakdown

#### Task 1: Database Schema & Migrations
- **Specialist**: droidz-database-architect
- **Estimated effort**: 2 hours
- **Dependencies**: []
- **Description**: 
  - Create Prisma schema for Notification and NotificationPreference models
  - Generate and test migrations
  - Add necessary indexes for performance
  - Seed test data for development

#### Task 2: Backend REST API
- **Specialist**: droidz-codegen
- **Estimated effort**: 4 hours
- **Dependencies**: [Task 1]
- **Description**:
  - Implement REST endpoints for CRUD operations
  - Add authentication middleware
  - Implement pagination for notification list
  - Add validation with Zod
  - Write unit tests for all endpoints

#### Task 3: WebSocket Server
- **Specialist**: droidz-codegen
- **Estimated effort**: 4 hours
- **Dependencies**: [Task 1]
- **Description**:
  - Set up Socket.io server with Express
  - Implement JWT authentication for WebSocket connections
  - Create user rooms/channels
  - Implement notification broadcasting
  - Add connection error handling and logging
  - Write integration tests

#### Task 4: Frontend State Management
- **Specialist**: droidz-codegen
- **Estimated effort**: 3 hours
- **Dependencies**: []
- **Description**:
  - Create Zustand store for notifications
  - Implement actions (add, mark read, clear)
  - Add WebSocket client connection logic
  - Handle reconnection and error states
  - Write unit tests for store

#### Task 5: UI Components
- **Specialist**: droidz-ui-designer
- **Estimated effort**: 6 hours
- **Dependencies**: [Task 4]
- **Description**:
  - Build NotificationDropdown component with Radix UI
  - Build NotificationItem component
  - Build NotificationBadge component
  - Implement animations with Framer Motion
  - Add keyboard navigation
  - Make responsive for mobile
  - Write component tests

#### Task 6: Accessibility Audit
- **Specialist**: droidz-accessibility-specialist
- **Estimated effort**: 2 hours
- **Dependencies**: [Task 5]
- **Description**:
  - Run accessibility audit (axe-core)
  - Test with screen reader (NVDA/VoiceOver)
  - Fix any WCAG violations
  - Add ARIA labels where needed
  - Test keyboard navigation flows

#### Task 7: Integration Tests
- **Specialist**: droidz-test
- **Estimated effort**: 4 hours
- **Dependencies**: [Task 2, Task 3, Task 5]
- **Description**:
  - Write E2E tests for full notification flow
  - Test WebSocket reconnection scenarios
  - Test notification preferences
  - Test real-time delivery across multiple clients
  - Test error scenarios and edge cases

#### Task 8: Performance Optimization
- **Specialist**: droidz-performance-optimizer
- **Estimated effort**: 3 hours
- **Dependencies**: [Task 7]
- **Description**:
  - Optimize database queries with indexes
  - Implement Redis caching for unread counts
  - Add virtual scrolling for long notification lists
  - Optimize WebSocket message payload size
  - Run load tests for 1000+ concurrent users
  - Document performance benchmarks

#### Task 9: Documentation
- **Specialist**: droidz-generalist
- **Estimated effort**: 2 hours
- **Dependencies**: [All tasks]
- **Description**:
  - Write API documentation (OpenAPI spec)
  - Create user guide for notification preferences
  - Document WebSocket event types
  - Add inline code comments
  - Update README with setup instructions

### Dependencies

- [ ] JWT authentication system must be working
- [ ] User database models must exist
- [ ] Redis instance for production (Upstash account)
- [ ] WebSocket support in hosting environment

### Risks & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| WebSocket connections drop frequently | Medium | High | Implement automatic reconnection with exponential backoff |
| Database query performance degrades with many notifications | Medium | High | Add pagination, indexes, and archive old notifications |
| High infrastructure costs for WebSocket servers | Low | Medium | Use serverless Redis, monitor costs, implement connection pooling |
| Browser notifications blocked by users | High | Low | Provide clear value proposition, graceful degradation |
| Race conditions with mark-as-read | Medium | Medium | Use optimistic updates + server confirmation |

---

## Acceptance Criteria

### Core Functionality

- [ ] Users receive real-time notifications within 1 second of event
- [ ] Notifications persist across browser sessions
- [ ] Unread count displays correctly and updates in real-time
- [ ] Mark as read works both individually and in bulk
- [ ] Notification preferences save and apply correctly
- [ ] Deep links navigate to correct content
- [ ] Works seamlessly on mobile and desktop
- [ ] Handles WebSocket reconnection automatically

### Quality Gates

- [ ] All unit tests pass (Jest)
- [ ] All integration tests pass (Playwright)
- [ ] Code coverage ≥ 80%
- [ ] Performance: Initial load < 500ms
- [ ] Performance: Real-time latency < 1s
- [ ] Security: No unauthorized access to notifications
- [ ] Accessibility: axe-core audit passes with 0 violations
- [ ] Accessibility: Manual screen reader test passes
- [ ] Code review approved by 2+ engineers
- [ ] Documentation complete (API + user guide)

### Definition of Done

- [ ] Code merged to main branch
- [ ] Deployed to staging environment
- [ ] QA tested on staging
- [ ] Deployed to production with feature flag
- [ ] Monitored for 48 hours with no critical issues
- [ ] User documentation published
- [ ] Analytics tracking implemented
- [ ] Stakeholders notified

---

## Testing Strategy

### Unit Tests

- **Backend API**: 
  - Create notification → Returns correct data
  - Fetch notifications → Returns only user's notifications
  - Mark as read → Updates database correctly
  - Preferences → Save and retrieve correctly

- **WebSocket Server**:
  - JWT authentication → Rejects invalid tokens
  - Room management → Users join correct rooms
  - Broadcasting → Notifications reach correct users

- **Frontend Store**:
  - Add notification → Updates state correctly
  - Mark as read → Updates optimistically
  - WebSocket events → Handled correctly

### Integration Tests

- **API + Database**: Full CRUD flow with real database
- **WebSocket + API**: Real-time notification delivery
- **Frontend + Backend**: End-to-end user flow

### End-to-End Tests

- **Happy path**: 
  1. User logs in
  2. Another user triggers notification event
  3. Real-time notification appears
  4. User clicks notification
  5. Navigates to content

- **Error scenarios**:
  - WebSocket connection lost → Reconnects automatically
  - Backend down → Shows error state
  - Invalid notification data → Handled gracefully

- **Edge cases**:
  - 100+ unread notifications → Virtual scrolling works
  - Rapid notification bursts → No UI lag
  - Multiple browser tabs → State syncs

### Performance Tests

- **Target metrics**: 
  - 10,000 concurrent WebSocket connections
  - < 500ms notification list load time
  - < 1s real-time delivery latency
  - < 100ms mark-as-read response time

- **Test scenarios**:
  - Load test with Artillery (simulate 1000+ users)
  - Stress test notification creation (1000 notifs/sec)
  - Database query performance (1M+ notification records)

---

## Deployment

### Deployment Strategy

- [ ] Deploy backend to Railway with environment variables
- [ ] Deploy frontend to Vercel with Socket.io client
- [ ] Run database migrations on Neon
- [ ] Configure Redis on Upstash
- [ ] Enable feature flag: `notifications_enabled`
- [ ] Gradual rollout: 10% → 50% → 100% over 3 days
- [ ] Monitor error rates and WebSocket connection metrics

### Rollback Plan

1. Disable feature flag: `notifications_enabled=false`
2. If database migration issue: Rollback migration via Prisma
3. If critical bug: Revert git commit, redeploy previous version
4. Notify users of temporary unavailability via status page

### Monitoring

- **Metrics**:
  - WebSocket connection count (gauge)
  - Notification creation rate (counter)
  - Notification delivery latency (histogram)
  - Mark-as-read success rate (counter)
  - API endpoint response times (histogram)
  - Database query performance (histogram)

- **Alerts**:
  - WebSocket connections > 9000 (approaching limit)
  - Notification delivery latency > 2s (SLA breach)
  - API error rate > 5% (critical issue)
  - Database connection pool exhausted

- **Dashboards**:
  - Grafana dashboard: Real-time notification metrics
  - Vercel Analytics: Frontend performance
  - Railway logs: Backend errors and warnings

---

## Documentation

### User Documentation

- [ ] User guide: "How to manage notifications"
- [ ] Tutorial: "Setting up notification preferences"
- [ ] FAQ: Common notification questions
- [ ] Video demo: 2-minute walkthrough

### Developer Documentation

- [ ] API documentation: OpenAPI spec in `/docs/api`
- [ ] Architecture diagram: Mermaid diagram in README
- [ ] WebSocket events: Full event reference
- [ ] Code comments: JSDoc for all public functions
- [ ] README updates: Setup and development instructions

---

## Timeline

### Estimated Timeline
- **Spec creation**: Nov 22, 2025
- **Implementation**: Nov 23-28, 2025 (5 days with parallel execution)
- **Testing**: Nov 29-30, 2025 (2 days)
- **Deployment**: Dec 1, 2025

### Milestones
- [ ] M1: Backend API + Database complete - Nov 25
- [ ] M2: Frontend components complete - Nov 27
- [ ] M3: All tests passing - Nov 30
- [ ] M4: Production deployment - Dec 1

---

## Open Questions

1. **Should we support email notifications in addition to real-time?**
   - **Status**: Answered
   - **Answer**: Yes, but as a follow-up feature in v2. Focus on real-time for v1.

2. **Do we need notification sound effects?**
   - **Status**: Answered
   - **Answer**: Yes, but optional (user can disable in preferences)

3. **How long should we keep read notifications?**
   - **Status**: Answered
   - **Answer**: 30 days, then archive to cold storage

4. **Should admins be able to send broadcast notifications?**
   - **Status**: Open
   - **Answer**: TBD - discuss with product team

---

## Change Log

### [2025-11-22] - Version 1.0
- Initial spec creation
- Defined full architecture and implementation plan
- Added comprehensive testing strategy

---

## Appendix

### References
- [Socket.io Documentation](https://socket.io/docs/)
- [Prisma Best Practices](https://www.prisma.io/docs/guides)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [WebSocket Security](https://owasp.org/www-community/vulnerabilities/WebSocket)

### Related Specs
- AUTH-001: Authentication System (JWT implementation)
- DB-002: Database Schema v2.0 (User models)
- UI-005: Component Library (Radix UI integration)

---

**Spec Template Version**: 1.0.0
**Last Updated**: 2025-11-22
**Parallel Execution**: Ready ✅ (9 independent tasks)
