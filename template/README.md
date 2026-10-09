# Generic Project Guidance Template

This folder is a reusable continuity and development-workflow template for software projects that use an AI assistant.

The goal is to keep project state, architectural decisions, workflow rules, and AI behavior outside chat history so work can resume reliably across sessions and devices.

## Files

```text
PROJECT_PROFILE.md
    Project-specific configuration and collaboration rules.

PROJECT_CONTEXT.md
    Current checkpoint: what is true now and what happens next.

ROADMAP.md
    Planned sequence of meaningful stages or milestones.

DECISIONS.md
    Stable architectural/product decisions that should not be reopened casually.

ARCHITECTURE.md
    Current system boundaries, components, data flow, ownership, and constraints.

WORKFLOW.md
    Human development process from session start to verification and commit.

AI_WORKFLOW.md
    Instructions for any AI assistant helping with the project.

SESSION_REVIEW_TEMPLATE.md
    Generic structure for reviewing a session before committing.
```

## Recommended source-of-truth order

Unless the project deliberately chooses another order:

```text
1. Actual source/data/artifacts and executable verification
2. Official specifications/documentation relevant to the project
3. DECISIONS.md
4. PROJECT_CONTEXT.md
5. ROADMAP.md
6. ARCHITECTURE.md
7. AI/chat suggestions
```

The implementation and verified behavior always win over stale documentation.

## First-time setup

1. Copy this folder into the new repository, usually under `docs/`.
2. Fill in `PROJECT_PROFILE.md`.
3. Replace placeholders such as `{{PROJECT_NAME}}`.
4. Create the initial `PROJECT_CONTEXT.md`.
5. Define the first few roadmap stages.
6. Record only already-established decisions in `DECISIONS.md`.
7. Delete template/example text that does not apply.
8. Keep the files short enough that they remain useful.

## Important rule

Do not turn continuity documents into a diary.

They should answer:

```text
What project is this?
What is true right now?
What are the important established decisions?
What is the planned sequence?
What exactly should happen next?
How should the work be performed and verified?
```
