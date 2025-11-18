---
description: AI spec generator - transform ideas into execution-ready specifications
argument-hint: "feature description"
---

Generate a comprehensive, executable specification for this feature:

**Feature Request:** $ARGUMENTS

## Specification Requirements

1. **Clarify Ambiguity:**
   - If the request is vague, ask targeted clarifying questions about:
     - Technical requirements (authentication method, API design, data storage, etc.)
     - Scope boundaries (what's included vs future work)
     - Success criteria (how do we know it's done?)
     - Constraints (performance, security, compliance)

2. **Research Best Practices:**
   - Use exa-code and ref tools to research relevant patterns
   - Find framework-specific best practices
   - Identify security requirements (OWASP, GDPR if applicable)

3. **Generate Complete Spec:**
   - **Summary:** One-sentence description
   - **Architecture Diagram:** Mermaid diagram showing system structure
   - **User Flow:** Sequence diagram for key interactions
   - **Requirements:** Functional and non-functional with acceptance criteria
   - **Task Breakdown:** Phases with parallelizable tasks
   - **Security:** OWASP checklist if handling auth/data/APIs
   - **Edge Cases:** 5-10 failure scenarios with handling strategies
   - **Testing Strategy:** Unit, integration, E2E coverage plan
   - **Success Metrics:** How to measure "done"

4. **Save Specification:**
   - Save to `.factory/specs/active/NNN-feature-name.md`
   - Use incremental numbering (001, 002, etc.)

5. **Execution Options:**
   After generating the spec, ask:
   - Review the spec?
   - Execute in parallel (recommended)?
   - Execute sequentially?
   - Modify the spec?
   - Save for later?

Generate the specification now with visual diagrams and complete details.
