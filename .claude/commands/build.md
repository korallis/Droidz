---
description: Meta-prompted spec generator - transforms ideas into comprehensive, execution-ready specifications using adaptive reasoning
argument-hint: "feature description"
---

# Meta-Prompted Specification Generator

Transform your feature request into a comprehensive, executable specification using meta prompting techniques.

**Feature Request:** $ARGUMENTS

---

## 🔍 Phase 1: Meta-Analysis (Understanding the Request)

Before generating the specification, I will analyze your request using adaptive reasoning:

### 1.1 Request Classification

**Analyze the feature request along these dimensions:**

- **Complexity Level:**
  - Simple: Single component, clear requirements, < 3 files affected
  - Moderate: Multiple components, some ambiguity, 3-10 files
  - Complex: System-wide changes, many unknowns, > 10 files, cross-cutting concerns
  - Expert: Novel architecture, requires research, significant risk

- **Domain Type:**
  - Frontend: UI/UX, components, styling, user interactions
  - Backend: APIs, business logic, data processing, services
  - Full-stack: Both frontend and backend coordination
  - Infrastructure: Deployment, CI/CD, monitoring, DevOps
  - Data: Database schema, migrations, data pipelines
  - Integration: Third-party services, webhooks, external APIs

- **Stakeholder Concerns:**
  - End users (UX, performance, accessibility)
  - Developers (maintainability, testability, documentation)
  - Security (auth, data protection, compliance)
  - Business (metrics, ROI, time-to-market)
  - Operations (monitoring, scaling, reliability)

- **Reasoning Type Needed:**
  - Deductive: Apply known patterns to new problem
  - Inductive: Identify patterns from similar systems
  - Abductive: Find best approach given constraints
  - Analogical: Reason by comparison to similar features

**Output this analysis in a structured format:**

```
### Request Analysis

**Complexity:** [Simple/Moderate/Complex/Expert]
**Domain:** [Frontend/Backend/Full-stack/Infrastructure/Data/Integration]
**Primary Stakeholders:** [List]
**Reasoning Approach:** [Deductive/Inductive/Abductive/Analogical]
**Key Uncertainties:** [List 3-5 major unknowns]
**Research Areas:** [List topics requiring investigation]
```

---

### 1.2 Recursive Question Generation (5 Whys + Clarification)

Based on the meta-analysis, generate intelligent clarifying questions:

**Instructions:**
1. If complexity = Simple AND domain is clear → Skip to Phase 2
2. If complexity ≥ Moderate OR key uncertainties exist → Generate questions
3. Organize questions by priority (Critical → Important → Nice-to-have)
4. Use "5 Whys" technique to dig into intent
5. Build a knowledge graph as answers come in

**Question Categories:**

**A. Intent & Goals (WHY)**
- Why is this feature needed now?
- What problem does it solve for users?
- What does success look like?
- What are the business metrics?

**B. Technical Scope (WHAT)**
- What are the core requirements vs nice-to-haves?
- What existing systems does this integrate with?
- What data needs to be stored/accessed?
- What are performance requirements?

**C. Constraints & Context (HOW)**
- What are the security/compliance requirements?
- What is the timeline/deadline?
- What are acceptable trade-offs?
- What should be excluded from this scope?

**D. Stakeholder Perspectives (WHO)**
- Who are the end users?
- Who will maintain this code?
- Who needs to approve this?
- Who has domain expertise to consult?

**Output Format:**

```
### Clarifying Questions (Prioritized)

#### 🔴 Critical (Must Answer)
1. [Question about core requirement]
2. [Question about security/compliance]

#### 🟡 Important (Should Answer)
3. [Question about integration]
4. [Question about performance]

#### 🟢 Nice-to-Have (Optional)
5. [Question about edge cases]
```

**After receiving answers:**
- Update the knowledge graph
- Identify new questions that emerged
- Ask follow-up questions if needed
- Proceed to Phase 2 when sufficient clarity achieved

---

## 🔬 Phase 2: Research & Pattern Discovery

Based on the meta-analysis and clarifications, research best practices:

### 2.1 Automated Research

**Use parallel research calls:**

```
Research in parallel using these tools:
- exa-code: "[domain] [technology stack] best practices implementation"
- exa-code: "[domain] [specific pattern] architecture examples"
- ref: "[framework] [feature type] documentation patterns"
- ref: "OWASP [security concern] guidelines" (if security-sensitive)
```

**Research Focus Areas (based on complexity):**

- **Simple:** Framework conventions, common patterns
- **Moderate:** Architecture patterns, testing strategies
- **Complex:** System design, scalability patterns, trade-off analysis
- **Expert:** Research papers, novel approaches, proof-of-concepts

### 2.2 Pattern Synthesis

After research, synthesize findings:

```
### Research Findings

**Recommended Patterns:**
1. [Pattern name] - [Why it fits this use case]
2. [Pattern name] - [Why it fits this use case]

**Technology Choices:**
- [Choice 1]: [Rationale based on research]
- [Choice 2]: [Rationale based on research]

**Security Considerations:**
- [Finding from OWASP/research]
- [Framework-specific security pattern]

**Performance Considerations:**
- [Caching strategy]
- [Optimization technique]
```

---

## 📝 Phase 3: Specification Generation (Multi-Perspective)

Generate the specification using multi-perspective analysis:

### 3.1 Core Specification Structure

**Adaptive Template Selection:**
- Simple features: Lightweight spec (< 2 pages)
- Moderate features: Standard spec (2-4 pages)
- Complex features: Comprehensive spec (4-8 pages)
- Expert features: Research-backed spec (8+ pages with appendices)

**Generate specification with these sections:**

```markdown
# [Feature Name] - Specification

## 📋 Executive Summary
[One-paragraph overview: problem, solution, impact]

## 🎯 Goals & Success Criteria

### Primary Goals
1. [Goal 1 with measurable outcome]
2. [Goal 2 with measurable outcome]

### Success Metrics
- [Metric 1]: [Target value]
- [Metric 2]: [Target value]

### Out of Scope (Explicitly)
- [What we're NOT doing in this iteration]
- [Future work explicitly deferred]

## 🏗️ Architecture Overview

### System Context (Mermaid Diagram)
[Generate C4 Context or Component diagram showing how this fits in the system]

### Data Flow (Mermaid Sequence Diagram)
[Show key interactions between components]

### Technology Stack
- **Frontend:** [Technologies + rationale]
- **Backend:** [Technologies + rationale]
- **Database:** [Technologies + rationale]
- **Infrastructure:** [Technologies + rationale]

## 📐 Detailed Design

### Component Breakdown
[For each major component:]

#### Component: [Name]
- **Purpose:** [What it does]
- **Responsibilities:** [List]
- **Dependencies:** [What it depends on]
- **Interfaces:** [APIs, props, contracts]
- **State Management:** [If applicable]

### Data Models
[Schema definitions with field descriptions]

### API Contracts
[Endpoint definitions if applicable]

## 👤 User Experience

### User Flows (Mermaid User Journey)
[Diagram showing user interaction paths]

### UI/UX Requirements
- [Interaction patterns]
- [Accessibility requirements (WCAG 2.1 AA)]
- [Responsive design breakpoints]
- [Loading states & error handling]

## 🔐 Security Analysis (Multi-Perspective)

### Threat Model
- **Assets:** [What needs protection]
- **Threats:** [What could go wrong]
- **Mitigations:** [How we protect]

### OWASP Checklist (if applicable)
- [ ] Input validation implemented
- [ ] Authentication/authorization verified
- [ ] Sensitive data encrypted
- [ ] CSRF protection enabled
- [ ] Rate limiting configured
- [ ] Security headers set
- [ ] SQL injection prevented
- [ ] XSS protection enabled

### Compliance Requirements
[GDPR, HIPAA, SOC2, etc. if applicable]

## ⚡ Performance Requirements

### Performance Budget
- **Page Load:** [Target time]
- **API Response:** [Target latency]
- **Database Queries:** [Max query time]
- **Bundle Size:** [Max size]

### Scalability Considerations
- [Expected load]
- [Horizontal/vertical scaling strategy]
- [Caching strategy]

### Monitoring & Alerts
- [Metrics to track]
- [Alert thresholds]

## 🧪 Testing Strategy

### Test Coverage Requirements
- **Unit Tests:** [Coverage target %]
- **Integration Tests:** [Key flows to test]
- **E2E Tests:** [Critical user paths]
- **Performance Tests:** [Load testing scenarios]

### Test Cases (Prioritized)

#### P0 - Critical Paths (Must Pass)
1. [Test case covering happy path]
2. [Test case covering critical error handling]

#### P1 - Important Scenarios
3. [Test case covering edge case]
4. [Test case covering integration]

#### P2 - Edge Cases
5. [Test case covering uncommon scenario]

## 🚨 Edge Cases & Error Handling

### Error Scenarios
1. **[Error Type]**
   - Trigger: [What causes it]
   - User Experience: [What user sees]
   - System Behavior: [How system recovers]
   - Logging: [What gets logged]

2. **[Error Type]**
   [Same structure]

### Boundary Conditions
- [Maximum values, empty states, etc.]

## 📦 Implementation Plan

### Task Breakdown (Dependency-Ordered)

#### Phase A: Foundation (Parallelizable)
- [ ] Task 1: [Description] (Est: [time], Owner: [TBD])
- [ ] Task 2: [Description] (Est: [time], Owner: [TBD])

#### Phase B: Core Implementation (Depends on A)
- [ ] Task 3: [Description] (Est: [time], Owner: [TBD])
- [ ] Task 4: [Description] (Est: [time], Owner: [TBD])

#### Phase C: Integration & Testing (Depends on B)
- [ ] Task 5: [Description] (Est: [time], Owner: [TBD])
- [ ] Task 6: [Description] (Est: [time], Owner: [TBD])

### Estimated Timeline
- **Total Effort:** [X developer-days]
- **With [N] developers in parallel:** [Y calendar days]
- **Critical Path:** [Longest dependency chain]

## 📚 Documentation Requirements

### Developer Documentation
- [ ] Architecture decision records (ADRs)
- [ ] API documentation (if applicable)
- [ ] Setup/installation guide
- [ ] Code comments for complex logic

### User Documentation
- [ ] User guide (if applicable)
- [ ] FAQ
- [ ] Troubleshooting guide

## 🔄 Rollout & Migration Strategy

### Deployment Plan
- [Deployment strategy: blue-green, canary, rolling]
- [Feature flags configuration]
- [Rollback procedure]

### Migration Requirements (if applicable)
- [Data migration steps]
- [Backward compatibility plan]

## 📊 Monitoring & Observability

### Key Metrics to Track
- [Business metrics]
- [Technical metrics]
- [Error rates]

### Dashboards to Create
- [Dashboard 1]: [Metrics shown]
- [Dashboard 2]: [Metrics shown]

## ❓ Open Questions & Risks

### Open Questions
1. [Question requiring stakeholder decision]
2. [Technical uncertainty requiring spike/POC]

### Identified Risks
| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| [Risk 1] | High/Med/Low | High/Med/Low | [Strategy] |
| [Risk 2] | High/Med/Low | High/Med/Low | [Strategy] |

## 📎 Appendices

### A. Research References
- [Link to research findings]
- [Framework documentation references]

### B. Alternatives Considered
| Approach | Pros | Cons | Decision |
|----------|------|------|----------|
| [Alt 1] | [List] | [List] | ✅/❌ [Why] |
| [Alt 2] | [List] | [List] | ✅/❌ [Why] |

### C. Glossary
- **[Term]**: [Definition]
```

---

## 🔄 Phase 4: Self-Verification & Refinement

After generating the spec, perform recursive self-improvement:

### 4.1 Specification Quality Checklist

**Evaluate the generated specification against these criteria:**

```
### Spec Quality Assessment

**Completeness (Critical):**
- [ ] All user stories have acceptance criteria
- [ ] All components have clear responsibilities
- [ ] All APIs have contracts defined
- [ ] All edge cases have handling strategies
- [ ] All security concerns addressed
- [ ] All performance requirements specified

**Clarity (Important):**
- [ ] Technical terms are defined
- [ ] Diagrams clearly show relationships
- [ ] No ambiguous requirements
- [ ] Examples provided for complex concepts

**Testability (Critical):**
- [ ] All requirements have measurable outcomes
- [ ] Test cases cover happy paths
- [ ] Test cases cover error scenarios
- [ ] Performance targets are specific

**Actionability (Critical):**
- [ ] Tasks are granular enough (< 1 day each)
- [ ] Dependencies are explicit
- [ ] Estimates are reasonable
- [ ] Parallel work is identified

**Quality Score:** [X/20 checks passed]
```

### 4.2 Recursive Refinement Process

**If quality score < 18/20:**

1. **Identify Gaps:**
   ```
   ### Identified Gaps
   - [Missing component X]
   - [Ambiguous requirement Y]
   - [Untestable success criterion Z]
   ```

2. **Generate Improvements:**
   ```
   ### Refinements
   
   **Gap 1: [Description]**
   - Current state: [What's missing/unclear]
   - Improved version: [Better specification]
   - Rationale: [Why this is better]
   
   **Gap 2: [Description]**
   [Same structure]
   ```

3. **Re-integrate Improvements:**
   - Update the specification sections
   - Re-run quality checklist
   - Repeat until quality score ≥ 18/20

### 4.3 Peer Review Simulation

**Simulate reviews from different perspectives:**

```
### Simulated Peer Reviews

**👨‍💻 Senior Engineer Review:**
[What would a senior engineer question or improve?]

**🔒 Security Engineer Review:**
[What security concerns are raised?]

**👤 UX Designer Review:**
[How could the user experience be better?]

**⚙️ DevOps Review:**
[What deployment/operational concerns exist?]

**✅ QA Engineer Review:**
[What test coverage gaps exist?]
```

**Address all critical feedback before finalizing.**

---

## 💾 Phase 5: Finalization & Storage

### 5.1 Generate Spec Number

Find the next available spec number:

```bash
# Check existing specs
ls -1 .factory/specs/active/ | grep -E '^[0-9]{3}-' | sort | tail -1

# Increment for new spec
# Example: 001-auth-system.md → use 002 for new spec
```

### 5.2 Save Specification

Save the final specification:

```
File: .factory/specs/active/NNN-[feature-name-kebab-case].md
```

### 5.3 Generate Execution Summary

Create a concise execution summary:

```markdown
# Specification Complete: [Feature Name]

**Spec File:** `.factory/specs/active/NNN-feature-name.md`

**Summary:**
- **Complexity:** [Simple/Moderate/Complex/Expert]
- **Estimated Effort:** [X developer-days]
- **Phases:** [N phases with M parallelizable tasks]
- **Key Risks:** [Top 2-3 risks]

**Key Decisions Made:**
1. [Decision 1] - [Rationale]
2. [Decision 2] - [Rationale]

**Critical Path:**
[Phase X] → [Phase Y] → [Phase Z] ([N days])

**Recommended Next Steps:**
1. Review spec with stakeholders
2. Execute in parallel (estimated [X] days with [N] devs)
3. Set up monitoring dashboards
```

---

## 🎯 Phase 6: Execution Options

After generating and verifying the specification, present options:

```
╔════════════════════════════════════════════════════════════╗
║           SPECIFICATION GENERATED SUCCESSFULLY             ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║  📄 Spec saved to: .factory/specs/active/NNN-name.md      ║
║  📊 Quality Score: 19/20 ✅                                ║
║  ⏱️  Estimated: X developer-days                           ║
║  🔀 Parallelizable: Y tasks can run concurrently           ║
║                                                            ║
╠════════════════════════════════════════════════════════════╣
║                     WHAT'S NEXT?                           ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║  1️⃣  REVIEW SPEC                                           ║
║     → Read the full specification                          ║
║     → Ask questions or request changes                     ║
║     → Stakeholder review                                   ║
║                                                            ║
║  2️⃣  EXECUTE IN PARALLEL (⚡ Recommended)                  ║
║     → Use droidz-orchestrator for max speed                ║
║     → Estimated completion: [Y] calendar days              ║
║     → Spawns specialist agents for each phase              ║
║     → Command: /parallel .factory/specs/active/NNN-name.md ║
║                                                            ║
║  3️⃣  EXECUTE SEQUENTIALLY                                  ║
║     → Step-by-step implementation with reviews             ║
║     → Estimated completion: [X] calendar days              ║
║     → More controlled but slower                           ║
║                                                            ║
║  4️⃣  MODIFY SPEC                                           ║
║     → Make changes before execution                        ║
║     → Re-run refinement process                            ║
║                                                            ║
║  5️⃣  SAVE FOR LATER                                        ║
║     → Spec is saved and ready when you are                 ║
║     → Can execute anytime with /parallel                   ║
║                                                            ║
╚════════════════════════════════════════════════════════════╝

What would you like to do?
```

---

## 🧠 Meta Prompting Techniques Used

This command employs several advanced meta prompting techniques:

1. **Adaptive Reasoning Orchestrator**
   - Analyzes request complexity and domain
   - Selects appropriate reasoning approach
   - Adjusts template based on characteristics

2. **Recursive Question Generation**
   - Uses "5 Whys" to dig into intent
   - Prioritizes questions by importance
   - Builds knowledge graph as answers come in

3. **Multi-Perspective Analysis**
   - Security perspective
   - Performance perspective
   - UX perspective
   - Maintainability perspective

4. **Self-Verification Loops**
   - Quality checklist evaluation
   - Identifies gaps in specification
   - Recursively improves until threshold met

5. **Simulated Peer Review**
   - Reviews from different expert perspectives
   - Catches issues before execution

6. **Chain-of-Thought Reasoning**
   - Explicit analysis before generation
   - Documented decision-making process

## 🔧 Configuration Options

You can customize the behavior with these environment patterns:

```yaml
# Adjust quality threshold
SPEC_QUALITY_THRESHOLD: 18  # Default: 18/20

# Skip clarification for simple features
AUTO_SKIP_CLARIFICATION: true  # Default: false

# Research depth
RESEARCH_DEPTH: deep  # Options: shallow, moderate, deep

# Template preference
TEMPLATE_STYLE: comprehensive  # Options: lightweight, standard, comprehensive
```

---

**Now processing your request...**
