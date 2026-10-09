# DECISIONS

This file records stable project decisions that should not be casually reopened in every session.

A decision may be changed when new evidence appears, but the change should be deliberate and documented.

## Decision format

Copy this block for each new decision:

```markdown
## DNNN — Short decision title

**Status:** Accepted
**Date:** YYYY-MM-DD

**Context:**

What problem or ambiguity required a decision?

**Decision:**

What is now considered the project rule?

**Reason:**

Why was this option chosen?

**Consequences:**

What does this make easier, harder, required, or out of scope?

**Revisit when:**

What new evidence or condition would justify reopening the decision?
```

---

## D001 — Example: verified behavior outranks stale documentation

**Status:** Template example

**Context:**

Documentation can become outdated while implementation changes.

**Decision:**

When documentation conflicts with current verified implementation behavior, investigate the discrepancy and treat verified behavior as authoritative until documentation is corrected.

**Reason:**

Continuity files should describe reality rather than override it.

**Consequences:**

Documentation discrepancies must be fixed instead of silently rationalized.

**Revisit when:**

Never as a general rule; project-specific exceptions should be recorded separately.

---

Delete the example above when initializing a real project if you do not want example decisions in the project history.
