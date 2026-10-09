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
    git pull

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

Tests are the primary verification mechanism.

```text
Unit/regression tests:
    Required for deterministic project behavior when practical.

Integration tests:
    Used when multiple real components must be verified together.

Manual verification:
    Used for UI, physical audio devices, WASAPI behavior, or other behavior unsuitable for normal automation.

Hardware/device-dependent verification:
    Keep focused and temporary unless the project deliberately establishes a permanent integration-test environment.

CI:
    GitHub Actions runs the test suite on the product repository.
```

If a temporary hardware-dependent test is used only for focused verification:

```text
verify the behavior
remove the temporary test
run the permanent suite again
```

Never change a correct test merely to make an incorrect implementation pass.

State the expected test count when it can be determined.

## External-source policy

For uncertain osu! behavior:

```text
Primary authoritative source:
    Official osu! documentation.

Secondary authoritative source:
    Official osu! open-source implementation.

Rule:
    Do not guess format/timing/hitsound behavior when authoritative evidence is available.
```

For external libraries:

```text
Verify behavior against the exact installed package version when version-specific behavior matters.
```

Current important versions:

```text
NAudio:
    3.1.0

NAudio.Vorbis:
    3.0.0
```

## Architecture / design rules

Evaluate proposed designs and refactors independently.

Consider:

```text
actual benefit
implementation cost
complexity
risk
maintainability
timing
```

Do not introduce abstractions, helpers, classes, or architectural layers only because they might be useful later.

Preserve the established organization of existing classes unless a change has a real architectural benefit.

Core project logic is primarily implemented by this project:

```text
.osu parsing
osu! timing logic
logical hitsound representation
exporter
sample optimization
```

External libraries are acceptable for infrastructure such as:

```text
audio
UI
platform integration
```

Keep logical sample identity separate from physical `.osu` representation such as `SampleSet`, `SampleIndex`, and filenames.

Do not introduce CP-SAT or another global optimizer before deterministic:

```text
parse
-> logical representation
-> export
-> reload
-> logical equivalence verification
```

works.

## Git / version-control policy

```text
Primary branch:
    main

Commit timing:
    Do not suggest commits after every small change.
    Prepare/suggest a commit when the user is stopping, pausing, ending the session, or explicitly asks.

Multi-device workflow:
    verify
    commit
    push
    switch device
    git pull
    git status
    run baseline verification

Force-push policy:
    Avoid force-pushing main.
```

The product repository is the authoritative source for product code and product documentation.

The workflow repository is the authoritative source for maintainer/AI workflow files.

## Documentation policy

```text
README.md:
    Public introduction, high-level capabilities, build/use information, project status, links.

CONTRIBUTING.md:
    Rules that apply to any contributor.

docs/architecture.md:
    Architecture that actually exists.

docs/DECISIONS.md:
    Stable product/architectural decisions.

docs/ROADMAP.md:
    Planned product sequence and milestone status.

PROJECT_CONTEXT.md in workflow repository:
    Current resumable maintainer/AI checkpoint.

WORKFLOW.md in workflow repository:
    Human development/session process.

AI_WORKFLOW.md in workflow repository:
    Instructions for the AI assistant.

PROJECT_PROFILE.md in workflow repository:
    Stable project-specific configuration for the generic workflow.
```

Do not duplicate `ROADMAP.md`, `DECISIONS.md`, or `architecture.md` into the workflow repository unless a future requirement demonstrates a real need.

## Documentation editing workflow

For existing tracked documentation with partial changes:

```text
prefer a patch against the actual current file
run git apply --check first
apply only when the check succeeds
```

If the check fails:

```text
stop
do not force
identify the base mismatch
regenerate or reconcile against the actual current version
```

For:

```text
new file
    -> complete file

deliberate full replacement
    -> complete replacement file
```

Do not automate this workflow until repeated friction or human-error risk demonstrates that automation would help, unless automation is required for correctness, reproducibility, safety, or CI.

## Obsidian / notes

Do not create a new note for every concept.

Prefer:

```text
use an existing relevant note
```

Create a new note only when the concept is genuinely new and important.

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

The workflow split is **COMPLETE**.

Verified state:

```text
workflow repository
    -> pushed and independently retrievable
    -> authoritative for maintainer/AI workflow and continuity

New-SessionReview.ps1
    -> receives -ProductRepository
    -> reviews both repositories
    -> runs the product test suite
    -> writes a portable external report
    -> verified after removal of the old product-side workflow files

Sync-ProjectContext.ps1
    -> receives -ProductRepository
    -> assembles seven continuity files from both repositories
    -> verifies every copy with SHA256
    -> verified against the real continuity mirror

product repository
    -> old workflow/context documents removed
    -> old workflow scripts removed
    -> migration commit 398aa417fb4d26fdfe76232f518a2383fff4f34b
```

There is no product-repository workflow fallback anymore. Maintainer/AI workflow changes belong in this workflow repository.
