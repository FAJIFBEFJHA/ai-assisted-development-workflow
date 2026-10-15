# PROJECT_PROFILE

## Identity

```text
Project name:
    osu-hitsound-editor

Product repository:
    https://github.com/FAJIFBEFJHA/osu-hitsound-editor

Workflow repository:
    https://github.com/FAJIFBEFJHA/ai-assisted-development-workflow

Primary purpose:
    Build a Windows desktop hitsound editor for osu!standard with a DAW-like workflow.

Target users:
    Primarily osu!standard beatmap creators.

Current maturity:
    Active development.
```

## Technology

```text
Primary language:
    C#

Framework/runtime:
    .NET 10

Target platform:
    Windows

Primary editor/IDE:
    Visual Studio Code

Audio dependencies:
    NAudio 3.1.0
    NAudio.Vorbis 3.0.0

Test framework:
    xUnit

Planned desktop UI:
    WPF unless a materially better reason emerges.
```

Visual Studio is not required while VS Code remains sufficient. Recommend Visual Studio only if it becomes materially advantageous or necessary.

## Product repository layout

```text
Production/source directory:
    src/

Test directory:
    tests/

Product documentation directory:
    docs/

GitHub/CI configuration:
    .github/
```

The product repository should contain documentation that another developer needs to understand, build, test, modify, or contribute to the software.

Maintainer-specific AI continuity and personal development workflow belong in the workflow repository instead.

## Workflow repository layout

```text
Reusable workflow template:
    template/

Project-specific workflow:
    projects/osu-hitsound-editor/

Project-specific scripts:
    projects/osu-hitsound-editor/scripts/
```

The project-specific workflow directory is the continuity source for the AI-assisted development process.

## Commands

Run product commands from the root of the `osu-hitsound-editor` repository.

```text
Sync/update:
    Check local repository status before any git pull; follow WORKFLOW.md, "Start of a session".

Build:
    dotnet build

Tests:
    dotnet test

Repository status:
    git status

Diff validation:
    git diff --check

Run:
    Defined when the project has a concrete executable workflow that should be launched directly.

Integration/manual verification:
    Defined per feature when hardware, WASAPI, UI, or another real environment is required.

Session review:
    & "$workflowRepo\projects\osu-hitsound-editor\scripts\New-SessionReview.ps1" `
        -ProductRepository $productRepo

Continuity mirror synchronization:
    & "$workflowRepo\projects\osu-hitsound-editor\scripts\Sync-ProjectContext.ps1" `
        -ProductRepository $productRepo
```

Do not invent replacement commands in `AI_WORKFLOW.md` or `WORKFLOW.md`. Update this profile when the real commands change.

## Collaboration mode

```text
Production implementation:
    USER_AUTHORED

Tests:
    AI_ALLOWED

Configuration:
    AI_ALLOWED

Diagnostics / temporary tools:
    AI_ALLOWED

Documentation:
    SHARED
```

### Production-code rule

The project owner writes production code under `src/`.

The AI assistant may:

```text
- explain responsibilities and data flow
- define method contracts and pseudocode
- review user-written production code
- provide syntax/API examples for focused parts
- provide complete exception expressions/messages
```

The AI assistant must not provide a complete production implementation under `src/` unless explicitly requested.

A request for syntax, an API call, an example, a partial review, or a less abstract explanation is not permission to provide the complete production method.

### Code review rule

When the project owner submits production code:

```text
review the implementation
identify concrete changes
explain why they are needed
do not silently replace the complete method unless explicitly requested
```

## Communication

```text
Explanation language:
    Spanish

Technical identifiers:
    English

Exception messages:
    English

Git commit messages:
    English

Preferred teaching style:
    Focus on responsibility, data flow, ownership, and where values come from and go.

Expected knowledge level:
    Beginner/intermediate C#
```

Do not over-explain syntax the project owner has already demonstrated correctly.

## New production methods

When introducing a new production method, use exactly this structure:

```text
SECCIÓN:
    Where the method belongs in the current class/file.

PERTENECE A:
    Owning class.

RECIBE:
    Parameters and purpose.

DEVUELVE:
    Return type and meaning.

UTILIZA:
    Existing properties, methods, classes, or data.
    When relevant, classify values as:
        FIELD NUEVO
        LOCAL NUEVA
        PARAMETER
        EXISTENTE
    State exact types when type transitions matter.

FLUJO:
    Concise pseudocode directly translatable to implementation.
```

Before asking for implementation, cover the applicable:

```text
normal path
error paths
variable scope
ownership/lifetime
cleanup
state before/after
threading/concurrency
```

Avoid ambiguous assignment arrows. Prefer:

```text
destination = source
```

or:

```text
guardar source en destination
```

## Error handling

When recommending an exception, provide the complete exception-related code ready to use.

Include when applicable:

```text
exception type
nameof(...)
actual invalid value
exact English message
appropriate constructor
```

Invalid states should not silently become plausible-looking valid data.

## Verification policy

Tests are the primary verification mechanism. GitHub Actions runs the product test suite.

For test design, hardware independence, temporary device checks and expected test counts, follow `AI_WORKFLOW.md` (`Tests and verification`). For when to run or reuse verification, follow `WORKFLOW.md` (`Tests` and `Verification proportional to risk`). Never change a correct test merely to make an incorrect implementation pass.

## External-source policy

For uncertain osu! behavior, verify official osu! documentation or the official open-source implementation. For third-party library behavior, verify against the **installed package version**, not an assumed latest version. Current dependency versions are recorded in `Technology` above.

See `AI_WORKFLOW.md` (`External behavior and dependencies`) for the detailed instruction.

## Architecture / design rules

The `.osu` parser, osu! timing logic, and logical hitsound representation are implemented within this project. The exporter and optimizer are planned as project-owned implementations. External libraries are acceptable for audio, UI and platform infrastructure.

Keep logical sample identity independent of physical `.osu` `SampleSet`, `SampleIndex` and filenames. Do not introduce CP-SAT or another global optimizer before deterministic `parse -> logical representation -> export -> reload -> logical equivalence verification` is established.

For design trade-offs, refactoring discipline and the existing `Beatmap.cs` organization, follow `AI_WORKFLOW.md` (`Design and refactoring`, `Code organization`, `Project-specific rules`). Established product decisions belong in `docs/DECISIONS.md`.

## Git / version-control policy

Primary branch: `main`. Avoid force-pushing `main`. Do not suggest commits after every small change; prepare one on explicit request or when the user stops, pauses or closes the session.

The product repository owns product code, tests and product documentation. The workflow repository owns maintainer/AI procedures and continuity files. Follow `WORKFLOW.md` (`Start of a session`, `Working across multiple devices`, `Commit order`) for status checks, safe pulls, commits and pushes.

## Documentation policy

Product-owned: `README.md`, `CONTRIBUTING.md`, `docs/ROADMAP.md`, `docs/DECISIONS.md` and `docs/architecture.md`.

Workflow-owned: `PROJECT_PROFILE.md` (stable configuration), `PROJECT_CONTEXT.md` (resumable checkpoint), `AI_WORKFLOW.md` (assistant rules) and `WORKFLOW.md` (human process).

Follow `WORKFLOW.md` (`Documentation updates and patches`, `Update product documentation when needed`, `Update workflow documentation when needed`) for detailed responsibilities. Do not duplicate authoritative product documents into the workflow repository.

## Documentation editing workflow

Follow `WORKFLOW.md` (`Documentation updates and patches`) and `AI_WORKFLOW.md` (`Markdown output and documentation edits`). For changes to tracked files, base the patch on the user's **actual local file**; check with `git apply --check`, and never force a failed patch. Use complete files for new documents or deliberate full replacements.

Do not introduce automation without demonstrated need; see `AI_WORKFLOW.md` (`Automation threshold`).

## Obsidian / notes

Reuse relevant existing Obsidian notes before creating new ones, as specified in `AI_WORKFLOW.md` (`Obsidian`).

## Source-of-truth order

When project sources disagree:

```text
1. Tests and actual source code
2. Official osu! documentation / official open-source implementation
3. Product repository docs/DECISIONS.md
4. Workflow repository PROJECT_CONTEXT.md
5. Product repository docs/ROADMAP.md
6. Product repository docs/architecture.md
7. Chat history or AI suggestions
```

Point out discrepancies rather than guessing.

## Migration status

The two-repository migration is **COMPLETE**. There is no product-repository fallback for maintainer/AI workflow files. The product repository owns source and product documentation; the workflow repository owns the maintainer/AI process and continuity. Historical migration verification is retained in Git history; `PROJECT_CONTEXT.md` records the current checkpoint, not migration-era history.
