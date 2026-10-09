# PROJECT_CONTEXT

Last updated: {{YYYY-MM-DD}}

## Project

`{{PROJECT_NAME}}`

```text
Repository:
Primary purpose:
Target platform/users:
```

## Current stage

**{{CURRENT_STAGE}}**

Current verification checkpoint:

```text
{{CURRENT_TEST_OR_VERIFICATION_STATUS}}
```

If there is no numeric test count, record the strongest verified checkpoint instead.

## Current objective

Describe the single active objective in a few sentences.

```text
{{CURRENT_OBJECTIVE}}
```

## Current implementation / project state

Record only information needed to resume work correctly.

Examples:

```text
- completed behavior
- important existing components
- current data flow
- current public APIs
- current ownership/lifetime rules
- important constraints
```

Do not copy the whole codebase into this file.

## Verification boundary

State what is verified automatically and what still requires integration/manual evidence.

```text
Automated:
    ...

Integration/manual:
    ...

Not yet verified:
    ...
```

## Important open questions / technical debt

Only include items that matter for future decisions.

```text
- ...
- ...
```

Do not mix unrelated cleanup into the current feature unless it becomes a blocker.

## Exact next task

Give exactly one concrete next task.

```text
{{NEXT_TASK}}
```

Include the required completion evidence:

```text
DONE WHEN:
    ...

VERIFICATION:
    ...

OUT OF SCOPE:
    ...
```

## Resume checklist

At the beginning of the next session:

```text
1. Read PROJECT_PROFILE.md.
2. Read this file.
3. Read the relevant ROADMAP.md section.
4. Read DECISIONS.md if architecture/behavior is involved.
5. Read ARCHITECTURE.md if component boundaries are involved.
6. Verify repository/workspace state.
7. Verify the recorded checkpoint before new work.
```

## Source-of-truth order

```text
1. Actual implementation/data/artifacts + executable verification
2. Authoritative external specifications/documentation
3. DECISIONS.md
4. PROJECT_CONTEXT.md
5. ROADMAP.md
6. ARCHITECTURE.md
7. AI/chat advice
```
