# Epic Spec: [Epic Name]

> **Status**: Draft | Planning | In Progress | Completed
> **Created**: YYYY-MM-DD
> **Owner**: [Team/Person]
> **Epic ID**: EPIC-XXX
> **Duration**: [Estimated weeks/months]

---

## Executive Summary

### Vision
<!-- Big picture: What are we building and why? -->

### Goals
<!-- What do we want to achieve? -->

1. Goal 1: [Measurable objective]
2. Goal 2: [Measurable objective]
3. Goal 3: [Measurable objective]

### Success Metrics
<!-- How will we measure success? -->

- **Metric 1**: [Target value]
- **Metric 2**: [Target value]
- **Metric 3**: [Target value]

---

## Scope

### In Scope
<!-- What's included in this epic -->

- Feature/capability 1
- Feature/capability 2
- Feature/capability 3

### Out of Scope
<!-- What's explicitly not included -->

- Item 1
- Item 2
- Item 3

### Phase Breakdown
<!-- If multi-phase delivery -->

**Phase 1 - MVP** (Weeks 1-4)
- Core capability 1
- Core capability 2

**Phase 2 - Enhancement** (Weeks 5-8)
- Additional feature 1
- Additional feature 2

**Phase 3 - Polish** (Weeks 9-12)
- Performance optimization
- UX improvements

---

## Features & Stories

### Feature 1: [Name]
**Priority**: High | Medium | Low
**Estimated effort**: [Story points/weeks]
**Dependencies**: []

**User Stories**:
- As a [user type], I want [action] so that [benefit]
- As a [user type], I want [action] so that [benefit]

**Spec**: Link to detailed feature spec

---

### Feature 2: [Name]
**Priority**: High | Medium | Low
**Estimated effort**: [Story points/weeks]
**Dependencies**: [Feature 1]

**User Stories**:
- As a [user type], I want [action] so that [benefit]
- As a [user type], I want [action] so that [benefit]

**Spec**: Link to detailed feature spec

---

### Feature 3: [Name]
**Priority**: High | Medium | Low
**Estimated effort**: [Story points/weeks]
**Dependencies**: []

**User Stories**:
- As a [user type], I want [action] so that [benefit]

**Spec**: Link to detailed feature spec

---

## Architecture

### High-Level Architecture
<!-- System architecture diagram and description -->

```
[Include architecture diagram or ASCII art]

User → Frontend → API Gateway → Microservices → Database
                              ↓
                       Message Queue
                              ↓
                       Background Jobs
```

### Technology Stack
**Frontend**:
- Framework: [React, Vue, etc.]
- Key libraries: [list]

**Backend**:
- Services: [list microservices]
- Languages: [Node.js, Python, etc.]
- Databases: [PostgreSQL, Redis, etc.]

**Infrastructure**:
- Cloud: [AWS, GCP, Azure]
- CI/CD: [GitHub Actions, etc.]
- Monitoring: [Datadog, etc.]

### Key Technical Decisions
<!-- Major architecture and technology decisions -->

| Decision | Rationale | Trade-offs |
|----------|-----------|------------|
| [Decision] | [Why] | [What we're giving up] |
| [Decision] | [Why] | [What we're giving up] |

---

## Implementation Strategy

### Parallel Workstreams
<!-- How work will be organized -->

**Stream 1: Backend Services**
- Tasks: [list]
- Specialist: droidz-codegen
- Duration: [weeks]

**Stream 2: Frontend Application**
- Tasks: [list]
- Specialist: droidz-codegen
- Duration: [weeks]

**Stream 3: Infrastructure**
- Tasks: [list]
- Specialist: droidz-infra
- Duration: [weeks]

**Stream 4: Testing & QA**
- Tasks: [list]
- Specialist: droidz-test
- Duration: [weeks]

### Orchestration Plan
```json
{
  "epic": "epic-name",
  "features": [
    {
      "name": "Feature 1",
      "tasks": [
        {
          "key": "EPIC-001",
          "title": "Task 1",
          "specialist": "droidz-codegen",
          "priority": 1
        }
      ]
    }
  ]
}
```

### Dependencies
<!-- Cross-feature dependencies -->

```
Feature 1 → Feature 2 → Feature 3
         ↘
          Feature 4
```

---

## Timeline

### Milestones
<!-- Key delivery milestones -->

| Milestone | Target Date | Deliverables | Status |
|-----------|-------------|--------------|--------|
| M1: MVP | YYYY-MM-DD | [List deliverables] | Not Started |
| M2: Beta | YYYY-MM-DD | [List deliverables] | Not Started |
| M3: GA | YYYY-MM-DD | [List deliverables] | Not Started |

### Critical Path
<!-- What must complete on time for success? -->

1. Critical item 1
2. Critical item 2
3. Critical item 3

---

## Acceptance Criteria

### Epic-Level Acceptance
<!-- What must be true for epic to be considered complete? -->

- [ ] All features delivered
- [ ] All acceptance criteria met
- [ ] Success metrics achieved
- [ ] Production deployed
- [ ] User documentation complete
- [ ] Training materials ready

### Quality Gates
<!-- Standards for the entire epic -->

- [ ] Test coverage ≥ 85%
- [ ] Performance benchmarks met
- [ ] Security audit passed
- [ ] Accessibility compliance
- [ ] Load testing completed
- [ ] Disaster recovery tested

---

## Risks & Mitigation

### Technical Risks
| Risk | Likelihood | Impact | Mitigation | Owner |
|------|------------|--------|------------|-------|
| [Risk] | Low/Med/High | Low/Med/High | [Strategy] | [Name] |

### Schedule Risks
| Risk | Likelihood | Impact | Mitigation | Owner |
|------|------------|--------|------------|-------|
| [Risk] | Low/Med/High | Low/Med/High | [Strategy] | [Name] |

### Resource Risks
| Risk | Likelihood | Impact | Mitigation | Owner |
|------|------------|--------|------------|-------|
| [Risk] | Low/Med/High | Low/Med/High | [Strategy] | [Name] |

---

## Resources

### Team
<!-- Who's working on this? -->

- **Epic Owner**: [Name]
- **Tech Lead**: [Name]
- **Engineering**: [Number] developers
- **Design**: [Number] designers
- **QA**: [Number] testers
- **PM**: [Name]

### Budget
<!-- If applicable -->

- Development: [cost]
- Infrastructure: [cost]
- Third-party services: [cost]
- **Total**: [cost]

---

## Communication Plan

### Stakeholders
<!-- Who needs to be kept informed? -->

- **Executive sponsor**: [Name]
- **Product stakeholders**: [Names]
- **Technical stakeholders**: [Names]
- **End users**: [Group]

### Updates
<!-- How and when to communicate progress -->

- **Daily**: Standup within team
- **Weekly**: Status update to stakeholders
- **Bi-weekly**: Demo to stakeholders
- **Monthly**: Executive summary

### Communication Channels
- Slack: #epic-name
- Email: epic-updates@company.com
- Meetings: [Recurring meeting schedule]

---

## Documentation

### Technical Documentation
- [ ] Architecture diagrams
- [ ] API documentation
- [ ] Database schemas
- [ ] Infrastructure documentation
- [ ] Deployment guides

### User Documentation
- [ ] User guides
- [ ] Admin guides
- [ ] API reference
- [ ] FAQ
- [ ] Video tutorials

---

## Post-Launch

### Monitoring Plan
<!-- What to monitor after launch -->

**Performance Metrics**:
- Response times
- Error rates
- Throughput

**Business Metrics**:
- User adoption
- Feature usage
- Success metrics

**Alerts**:
- [Alert condition] → [Action]
- [Alert condition] → [Action]

### Support Plan
<!-- How to support users after launch -->

- L1 Support: [Team/process]
- L2 Support: [Team/process]
- Escalation path: [Process]

### Iteration Plan
<!-- How will we improve based on feedback? -->

- **Week 1-2**: Bug fixes and critical issues
- **Week 3-4**: Quick wins and small improvements
- **Month 2-3**: Bigger enhancements based on feedback

---

## Success Criteria

### Launch Criteria
<!-- What must be true to launch? -->

- [ ] All features complete
- [ ] Performance targets met
- [ ] Security review passed
- [ ] Load testing completed
- [ ] Documentation complete
- [ ] Support team trained
- [ ] Rollback plan tested

### Post-Launch Success
<!-- How will we know if this was successful? -->

**Week 1**:
- [ ] Zero critical bugs
- [ ] < 5 high-priority bugs
- [ ] Response time < 200ms P95

**Month 1**:
- [ ] [Metric target]
- [ ] [Metric target]
- [ ] User satisfaction > 80%

**Month 3**:
- [ ] All success metrics achieved
- [ ] ROI targets met
- [ ] User retention > 85%

---

## Appendix

### Related Documents
- [Product Requirements]
- [Technical Design]
- [Market Research]

### Feature Specs
- [Feature 1 Spec]
- [Feature 2 Spec]
- [Feature 3 Spec]

### Meeting Notes
- [Kickoff Meeting Notes]
- [Architecture Review Notes]
- [Sprint Planning Notes]

---

## Change Log

### [YYYY-MM-DD] - Version 1.2
- Added Feature 4
- Updated timeline

### [YYYY-MM-DD] - Version 1.1
- Clarified scope
- Added resource estimates

### [YYYY-MM-DD] - Version 1.0
- Initial epic spec

---

**Epic Template Version**: 1.0.0
**Last Updated**: 2025-01-12
