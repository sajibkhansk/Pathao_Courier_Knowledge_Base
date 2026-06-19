# Promotion Review

> **Candidate:** [[feedback-inbox-entry|Candidate Reference]]
> **Research:** [[path-to-research/README|Research Artifact]]
> **Review Date:** YYYY-MM-DD
> **Reviewer:** *(Human Oracle)*

## Pre-Promotion Checklist

- [ ] Candidate read and understood
- [ ] Evidence reviewed
- [ ] No conflict with existing canonical knowledge
- [ ] Destination file identified
- [ ] Scope of change is clear
- [ ] All Human Oracle questions answered

## Decision

**Approved** | **Rejected** | **Under Review**

## If Approved

### Destination

```
File: 02_Data_Dictionary/ | 03_Business_Logic/ | 04_SQL_Patterns/ | 06-SYSTEM/semantic-layer/
Path: (exact file)
Section: (where in the file)
```

### Promotion Actions

- [ ] Write canonical content
- [ ] Include source metadata
- [ ] Include evidence reference
- [ ] Update `_INDEX_START_HERE.md` if adding new file
- [ ] Update `00_WORKING_STATE.md` if active HITL topic
- [ ] Mark feedback candidate as `promoted`
- [ ] Add promotion date and reviewer
- [ ] Preserve research artifact

### Canonical Entry Format

```markdown
## (Title)

> **Source:** (research artifact link)
> **Promoted:** YYYY-MM-DD
> **Reviewer:** (name)
> **Confidence:** high

(Content)
```

## If Rejected

- **Reason:**
- [ ] Mark candidate `rejected`
- [ ] Record reviewer and reason
- [ ] Do not delete evidence
- [ ] Do not apply in future queries as a rule

## If Under Review

- **Required evidence:**
- [ ] Continue investigation in existing research folder
- [ ] Mark candidate `under-review`
- [ ] Record required evidence
