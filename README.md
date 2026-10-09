# AI-Assisted Development Workflow

A reusable development workflow for software projects that use an AI assistant while keeping project state, verification, decisions, and collaboration rules outside chat history.

The goal is not to make an AI assistant the source of truth. The goal is to make AI-assisted development reproducible, reviewable, portable across sessions and devices, and subordinate to the actual project state.

## Why this repository exists

Chat history is a poor place to store the authoritative state of a software project.

Important information can become fragmented across sessions:

```text
current implementation state
next task
architectural decisions
verification status
collaboration rules
AI-specific instructions
session-closing procedures
```

This repository moves that information into version-controlled files.

The intended model is:

```text
actual source/tests/artifacts
    -> implementation truth

project documentation
    -> product architecture, roadmap, and decisions

workflow documentation
    -> current maintainer/AI context and working process

AI/chat
    -> assistant, not authority
```

## Repository structure

```text
ai-assisted-development-workflow/
├── README.md
├── template/
│   ├── README.md
│   ├── PROJECT_PROFILE.md
│   ├── PROJECT_CONTEXT.md
│   ├── ROADMAP.md
│   ├── DECISIONS.md
│   ├── ARCHITECTURE.md
│   ├── WORKFLOW.md
│   ├── AI_WORKFLOW.md
│   └── SESSION_REVIEW_TEMPLATE.md
└── projects/
    └── osu-hitsound-editor/
        ├── PROJECT_PROFILE.md
        ├── PROJECT_CONTEXT.md
        ├── WORKFLOW.md
        ├── AI_WORKFLOW.md
        └── scripts/
            ├── New-SessionReview.ps1
            └── Sync-ProjectContext.ps1
```

## `template/`

`template/` is the reusable part of the repository.

It provides a generic structure for projects that want to keep development continuity outside individual AI conversations.

The main files have separate responsibilities:

```text
PROJECT_PROFILE.md
    stable project-specific configuration and collaboration rules

PROJECT_CONTEXT.md
    current resumable checkpoint and exact next task

ROADMAP.md
    planned sequence of meaningful project stages

DECISIONS.md
    stable decisions that should not be reopened casually

ARCHITECTURE.md
    architecture and responsibility boundaries that actually exist

WORKFLOW.md
    human development process

AI_WORKFLOW.md
    instructions for an AI assistant

SESSION_REVIEW_TEMPLATE.md
    generic structure for reviewing a development checkpoint
```

The template is intentionally project-agnostic. Projects should adapt it rather than blindly copying every example or rule.

## `projects/`

`projects/` contains concrete project-specific workflow configurations.

It demonstrates how the generic template can be adapted when the real product repository and the maintainer/AI workflow repository are intentionally separate.

### osu-hitsound-editor

The current real example is:

```text
projects/osu-hitsound-editor/
```

Product repository:

```text
https://github.com/FAJIFBEFJHA/osu-hitsound-editor
```

The product repository owns:

```text
source code
tests
CI
product architecture
product decisions
product roadmap
public/contributor documentation
```

This workflow repository owns the maintainer-specific:

```text
AI collaboration rules
learning constraints
session process
continuity checkpoint
workflow tooling
```

This separation keeps personal/maintainer workflow requirements out of the product repository while remaining transparent and publicly inspectable.

## Source-of-truth principle

The workflow is designed so an AI assistant cannot silently override verified project behavior.

A typical precedence order is:

```text
1. actual implementation/data/artifacts and executable verification
2. authoritative external specifications/documentation
3. stable project decisions
4. current project checkpoint
5. roadmap
6. architecture documentation
7. AI/chat suggestions
```

Individual projects can refine this order in `PROJECT_PROFILE.md`.

## Collaboration modes

The generic template supports explicit authorship policies such as:

```text
USER_AUTHORED
    the project owner writes the implementation
    AI may explain, design, review, and provide focused examples

SHARED
    implementation may be produced collaboratively

AI_ALLOWED
    complete implementation may be generated when useful
```

These modes make it possible to use the same workflow for a learning project, a professional project, or a more automation-heavy project without assuming the same AI role everywhere.

## Verification before continuity updates

The intended order is:

```text
change
    -> verify
    -> inspect repository state
    -> update continuity documentation
    -> commit
    -> push
```

Continuity files should describe a verified checkpoint, not an intended or guessed future state.

## Session reviews

Projects may provide a review script that collects the information needed to close a development session without manually navigating a large terminal diff.

For `osu-hitsound-editor`, the project-specific script is:

```text
projects/osu-hitsound-editor/scripts/New-SessionReview.ps1
```

Its current interface is:

```powershell
& "$workflowRepo\projects\osu-hitsound-editor\scripts\New-SessionReview.ps1" `
    -ProductRepository $productRepo
```

The script reviews both the product repository and the workflow repository while writing the generated report outside both Git repositories.

## Continuity mirrors

A project may optionally maintain a read-only external mirror for AI continuity or cross-tool access.

For `osu-hitsound-editor`, synchronization is handled by:

```text
projects/osu-hitsound-editor/scripts/Sync-ProjectContext.ps1
```

Its current interface is:

```powershell
& "$workflowRepo\projects\osu-hitsound-editor\scripts\Sync-ProjectContext.ps1" `
    -ProductRepository $productRepo
```

The mirror is not authoritative.

The authoritative state remains in the pushed Git repositories.

## Multi-device use

The workflow assumes Git/GitHub is the transport mechanism between devices.

```text
DEVICE A
    -> verify
    -> commit
    -> push

DEVICE B
    -> pull
    -> verify baseline
    -> continue
```

Repository working trees should not be synchronized through Google Drive, OneDrive, or manual directory copying.

Machine-specific paths belong in local configuration such as environment variables rather than tracked workflow files.

## Using the template for another project

Start with:

```text
template/
```

Then:

1. Copy the template files into an appropriate workflow location.
2. Fill in `PROJECT_PROFILE.md` first.
3. Define the initial `PROJECT_CONTEXT.md`.
4. Replace template placeholders.
5. Remove example material that does not apply.
6. Define the project's actual verification commands.
7. Decide the AI collaboration mode explicitly.
8. Keep continuity documents focused on information needed to resume work.

Do not automate the workflow merely because automation is possible. Add scripts when they improve correctness, reproducibility, or a repeatedly observed source of friction.

## What this repository is not

This repository is not intended to:

```text
replace tests
replace source control
replace product documentation
make AI output authoritative
hide AI-assisted development
impose one person's learning workflow on unrelated contributors
```

It also intentionally does not use a product-root `AGENTS.md` as the storage location for maintainer-specific learning rules. Those rules belong to the workflow layer rather than being automatically imposed on every contributor to the product repository.

## Current status

The reusable template and the first project-specific workflow are under active development.

The `osu-hitsound-editor` workflow currently demonstrates:

```text
separate product/workflow repositories
explicit source-of-truth hierarchy
project checkpoint validation
user-authored production-code policy
session review across both repositories
portable PowerShell workflow scripts
optional continuity-mirror synchronization
multi-device Git workflow
```

The `osu-hitsound-editor` workflow migration is complete: the workflow repository is pushed and independently retrievable, the project-specific scripts operate from their new location, the continuity mirror has been verified, and the old workflow copies have been removed from the product repository.
