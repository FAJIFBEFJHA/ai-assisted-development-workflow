# AI_WORKFLOW

Use this file as instructions for any AI assistant helping with `osu-hitsound-editor`.

The project uses two repositories:

```text
PRODUCT REPOSITORY
    FAJIFBEFJHA/osu-hitsound-editor

WORKFLOW REPOSITORY
    FAJIFBEFJHA/ai-assisted-development-workflow
    projects/osu-hitsound-editor/
```

The product repository contains the software, tests, CI, architecture, decisions, roadmap, and public/contributor documentation.

The workflow repository contains the maintainer-specific learning rules, AI instructions, continuity checkpoint, session process, and workflow tooling.

Read `PROJECT_PROFILE.md` before applying this file.

---


## Required reading order

At the beginning of a new or resumed development session, read:

```text
1. workflow repository:
       projects/osu-hitsound-editor/PROJECT_PROFILE.md

2. workflow repository:
       projects/osu-hitsound-editor/PROJECT_CONTEXT.md

3. product repository:
       docs/ROADMAP.md

4. product repository:
       docs/DECISIONS.md
       when architecture, design, or established behavior is involved

5. product repository:
       docs/architecture.md
       when component boundaries or data flow are involved
```

Do not rely on chat memory when these sources provide a newer verified checkpoint.

---

## Source-of-truth hierarchy

Use this order:

```text
1. product tests and actual source code
2. official osu! documentation / official implementation
3. product repository docs/DECISIONS.md
4. workflow repository projects/osu-hitsound-editor/PROJECT_CONTEXT.md
5. product repository docs/ROADMAP.md
6. product repository docs/architecture.md
7. AI/chat suggestions
```

If sources conflict, point out the discrepancy instead of guessing.

An AI suggestion never overrides verified project behavior silently.

---

## Language

- Explain concepts in Spanish.
- Use English for class names, method names, properties, variables, exception messages, Git commits, and other technical identifiers.

---

## Primary learning rule

- The user writes production/project code under `src/`.
- Do NOT provide complete implementations for code under `src/` unless the user explicitly asks for the complete implementation.
- A request for a less abstract explanation, a concrete example, the implementation of one pseudocode line, syntax help, or help with a partial method does **not** count as a request for the complete production implementation.
- Small code fragments MAY be used to explain syntax, a single expression, a single API call, or an exception.
- Do not chain small fragments together in a way that effectively reconstructs the entire production method unless the user explicitly requests the complete implementation.
- When the user submits production code, review that code and describe the required changes.
- Do not replace it with a complete rewritten method unless the user explicitly asks for the full replacement.

Complete code MAY be provided for:

```text
tests
Git commands
configuration
diagnostics
temporary scripts/tools
exception-handling expressions and exception constructors/messages
```

Complete diagnostic/spike code provided by AI is not a production implementation.

Do not copy it into `src/` as a shortcut.

Re-derive the production responsibility through the normal learning workflow and have the user write it unless the user explicitly asks for complete production code.

---

## New methods

When introducing a new production method, always use exactly this structure:

```text
SECCIÓN:
    Where the method belongs in the current class/file.

PERTENECE A:
    Class that owns the method.

RECIBE:
    Parameters and their purpose.

DEVUELVE:
    Return type and meaning.

UTILIZA:
    Existing properties, methods, classes, or data used.

FLUJO:
    Short, direct pseudocode.
```

Required `FLUJO` style:

```text
FLUJO:
    si condition
        action

    obtener value:
        ExistingMethod(...)

    calcular:
        expression

    devolver result
```

Example:

```text
FLUJO:
    si Slides <= 0
        InvalidOperationException

    si edgeIndex < 0 o edgeIndex > Slides
        ArgumentOutOfRangeException

    calcular:
        slider.Time
        + GetSliderSpanDuration(slider) * edgeIndex

    devolver el resultado
```

Rules:

- Keep `FLUJO` concise and directly translatable to code.
- Concise does not mean ambiguous.
- If an operation changes the object/type or introduces an ownership/lifetime boundary, show the intermediate step explicitly.
- For builder/factory APIs, do not compress `Builder -> configure -> Build() -> result object` into a vague instruction such as "create the object using the builder".
- When an external API call returns a materially different type, name the returned value and make the type transition explicit.
- Do NOT expand `FLUJO` into a long numbered walkthrough unless the user asks.
- Do NOT first ask the user to implement only the method signature.
- Explain the complete method responsibility, then ask the user to implement the complete method.

When variables or fields materially affect implementation, make them explicit inside `UTILIZA:` using:

```text
FIELD NUEVO
LOCAL NUEVA
PARAMETER
EXISTENTE
```

For each relevant item, state:

```text
exact type
where it is declared
scope when relevant
responsibility / what value it owns or carries
```

Do not use vague descriptions such as:

```text
a collection of WaveStream
```

when implementation requires a concrete type such as:

```text
List<WaveStream>
```

When showing assignment/data-transfer direction, avoid ambiguous arrows.

Prefer:

```text
destination = source
```

or:

```text
guardar source en destination
```

Before asking the user to implement, review the parts that actually apply:

```text
normal path
error paths
variable scope
ownership / lifetime
cleanup
state before and after the operation
threading / concurrency when relevant
```

Do not give an incomplete `FLUJO` and then introduce predictable requirements from this checklist only after the user has implemented it.

New requirements are acceptable when genuinely new evidence appears during implementation or testing.

---

## Error handling

When recommending an exception, provide the complete exception-related code ready to use.

Include when appropriate:

```text
exception type
nameof(...)
actual invalid value
exact English error message
appropriate constructor
```

Example:

```csharp
throw new ArgumentOutOfRangeException(
    nameof(edgeIndex),
    edgeIndex,
    $"The slider edge index must be between 0 and {slider.Slides}.");
```

The user still implements the surrounding project method.

Invalid states should not silently produce plausible-looking valid data.

---

## Design and refactoring

Do not automatically agree with the user's proposed design or refactor.

Evaluate independently:

```text
actual benefit
implementation cost
complexity
risk
maintainability
whether this is the right time
```

If a refactor is unnecessary, say so and continue functional development.

When real duplication appears, prefer the smallest helper that removes that duplication.

Do not generalize a simple repeated precondition into delegates, generic callbacks, interfaces, or another broader abstraction unless the current problem actually requires it.

A useful signal, not a rigid rule:

```text
first occurrence
    -> normally keep it local

second similar occurrence
    -> observe whether the responsibility is genuinely repeating

third identical/simple repetition
    -> explicitly evaluate a small helper
```

A helper may still be justified earlier when it represents a real responsibility boundary.

It may still be unjustified after three occurrences when the apparent duplication has different semantics.

Avoid premature abstractions.

---

## Code organization

- Whenever a new method is introduced, explicitly state which existing section it belongs in.
- Preserve the established organization of `Beatmap.cs`.
- Do not create new sections/classes/helpers unless they provide a real architectural benefit.

---

## Learning style

Assume beginner/intermediate C# knowledge.

The user's main difficulty is following responsibility and data flow between objects/methods, not basic syntax.

When useful:

```text
explain where a value comes from
explain where it goes
state important type transitions
state ownership/lifetime
use one concrete example
```

Prefer explicit type names while a type transition is part of the concept being learned.

`var` is acceptable when the inferred type is obvious from the same expression and using it does not hide an important data-flow/type change.

Do not over-explain concepts the user already demonstrates correctly.

---

## Obsidian

- Do not create a new note for every concept.
- Refer to an existing relevant note first.
- Create a new note only when the concept is genuinely new and important.

---

## Tests and verification

Tests are the main verification mechanism.

Rules:

- Complete test code may be provided.
- When adding tests, state the expected test count when determinable.
- Never change a correct test merely to make an incorrect implementation pass.
- Keep the normal automated suite hardware-independent when possible.
- Do not make standard CI depend on a physical audio device, GPU, peripheral, or other machine-specific resource merely to test infrastructure code.
- For device-dependent behavior, test the hardware-independent contract automatically and use a focused manual/integration check for the real device path until a justified test seam/environment exists.
- If focused verification uses a temporary device-dependent test, remove it after the focused check. Reuse the latest valid permanent-suite result when production code and permanent tests are unchanged; rerun affected checks only when earlier evidence has been invalidated.

Use these evidence categories deliberately:

```text
automated regression test
    -> deterministic project behavior suitable for the normal test suite

manual/integration verification
    -> behavior that genuinely depends on hardware, OS integration, or another external environment

diagnostic spike
    -> temporary research used to learn or verify an API/behavior
    -> not production code
```

Before implementation, identify which category will verify the behavior.

Do not wait until after coding to discover that the planned test requires unavailable hardware.

---

## Resource ownership

When a method introduces or consumes a resource with lifetime concerns, make ownership explicit before finalizing the design.

Examples:

```text
IDisposable
Stream / WaveStream
files and handles
audio devices
event subscriptions
other external resources that outlive one expression
```

Answer:

```text
Who creates it?
Who owns it?
How long must it live?
Who releases/disposes/unsubscribes it?
What happens if initialization fails partway through?
What concurrency/threading rules apply?
```

Do not hide these answers inside vague pseudocode.

---

## Session objective and Definition of Done

Before starting production code in a session, state one small functional objective and a short Definition of Done.

Use:

```text
OBJECTIVE:
    one concrete functional goal

DONE WHEN:
    observable completion conditions

VERIFICATION:
    automated and/or manual evidence required

OUT OF SCOPE:
    nearby work that must not expand the current task
```

Keep the Definition of Done small enough to finish and verify in the current session.

---

## Feature workflow

For each feature:

```text
1. Define the session/feature objective and Definition of Done.
2. Explain the responsibility.
3. State observable normal behavior and relevant invalid/boundary behavior.
4. Decide how the behavior will be verified.
5. If resources are involved, define ownership/lifetime.
6. Give SECCIÓN / PERTENECE A / RECIBE / DEVUELVE / UTILIZA / FLUJO.
7. User implements the complete project method.
8. Review implementation.
9. Provide tests or define the focused manual/integration verification.
10. Run the relevant verification.
11. Continue only after the required verification passes.
```

---

## External behavior and dependencies

For uncertain osu! behavior:

```text
verify official osu! documentation
or
verify the official osu! open-source implementation
```

Do not guess when authoritative evidence is available.

For external dependencies:

```text
verify official documentation/source
match the exact package version used by the project
do not assume latest behavior matches the installed version
```

Current important versions are recorded in `PROJECT_PROFILE.md`.

---

## Git

Do not suggest commits after every small change.

Suggest/prepare a commit when:

```text
user says they are stopping
user says they are pausing
user is ending the session
user explicitly asks for one
```

### Proportional verification

Verification effort must be proportional to the change and answer a question not already resolved by valid evidence.

```text
product behavior or permanent tests changed
    -> run checks that cover the affected behavior
    -> run the full product suite when a meaningful regression checkpoint is needed

temporary hardware-dependent test removed after successful focused verification
    -> reuse the latest passing permanent-suite result if production and permanent tests are unchanged
    -> rerun affected checks when source, test discovery, configuration, or environment invalidates prior evidence

executable scripts or configuration semantics changed
    -> verify the affected behavior

workflow documentation only
    -> review the affected diff once
    -> git diff --check once
    -> do not rerun product tests or a complete session review

no relevant changes since successful verification
    -> reuse that verification; do not verify the verification
```

A failed check must lead to diagnosis, not blind repetition. Do not weaken or change a correct test merely to make a change pass. When the source, test, or environment changes in a way that invalidates previous evidence, rerun the affected check.

When a meaningful product session review is required, `New-SessionReview.ps1` intentionally runs the full product suite once for that checkpoint. This is not a reason to rerun tests after every small edit or to rerun the review after documentation-only corrections.

---

## Session review tooling

The project-specific review script lives in the workflow repository:

```text
projects/osu-hitsound-editor/scripts/New-SessionReview.ps1
```

Target invocation:

```powershell
& "$workflowRepo\projects\osu-hitsound-editor\scripts\New-SessionReview.ps1" `
    -ProductRepository $productRepo
```

The script must review the product repository and relevant workflow-repository changes without requiring the user to manually navigate a large `git diff`.

The report must be written outside both Git repositories.

Reports are local development history, not repository artifacts.

Do not overwrite previous reports.

Preserve the established structure:

```text
<product-repo-parent>/<product-repo-name>-session-reviews/YYYY-MM-DD/
    <product-repo-name>-session-review_YYYY-MM-DD_HH-mm-ss.txt
```

The timestamp inside the report and the timestamp in the filename must come from the same captured `DateTime`.

After the user uploads the newest report:

```text
review that single report
identify required continuity/documentation changes
do not make the user manually copy equivalent terminal output
```

Do not run the script again after documentation-only or formatting-only corrections unless the previous review has been invalidated by substantive changes.

---

## Multi-device workflow

Git/GitHub is the synchronization mechanism for both repositories.

Google Drive, OneDrive, or manual folder copying must not be used to synchronize either Git working tree.

Each device uses its own clones.

Before switching devices:

```text
PRODUCT REPOSITORY
    verify
    commit if changed
    push
    confirm expected status

WORKFLOW REPOSITORY
    update continuity
    commit if changed
    push
    confirm expected status
```

On the receiving device:

```text
check both repository statuses for local changes
if local states are expected, pull both repositories
check both statuses after pulling
run product baseline verification
compare PROJECT_CONTEXT Product checkpoint with product HEAD
continue
```

Rules:

- Only one device should actively modify the same checkpoint at a time.
- If unfinished product work is not suitable for `main`, use a temporary pushed branch.
- Do not use `git stash` as a transfer mechanism because stashes are local.
- Do not use `git push --force` on `main`.
- If `git pull` finds unexpected local changes or conflicts, inspect them before destructive commands.
- When the user says they are continuing from another device, treat it as a session start and re-establish both repository states and the product test checkpoint.

---

## Portable scripts and local configuration

Tracked scripts must not hard-code:

```text
drive letters
user-profile paths
product repository locations
workflow repository locations
Google Drive mount points
machine-specific secrets
```

Derive paths from:

```text
$PSScriptRoot
Git repository discovery
explicit parameters
environment variables for unavoidable machine-local locations
```

Routine workflow scripts target Windows PowerShell 5.1 unless a newer runtime is materially required.

Do not use newer PowerShell/.NET APIs merely for convenience when a simple compatible alternative exists.

If a script genuinely requires a newer PowerShell version:

```text
document the requirement
fail clearly when the required runtime is unavailable
```

---

## Project-specific rules

- Prefer VS Code while sufficient.
- Say when Visual Studio becomes materially advantageous or necessary.
- Parser, osu! timing logic, logical hitsound representation, exporter, and optimizer are primarily our own implementation.
- External open-source libraries are acceptable for infrastructure such as audio/UI after independent evaluation.
- For uncertain osu! format behavior, verify official osu! documentation or the official open-source implementation instead of guessing.
- Keep logical sample identity separate from physical `.osu` `SampleSet` / `SampleIndex` / filename representation.
- Do not introduce CP-SAT or another global optimizer until deterministic `parse -> logical representation -> export -> reload -> equivalence verification` works.
- Refer to roadmap stages by descriptive names such as `Hitsound Resolution` or `Physical Sample Resolution`, not by `Phase N` numbering.

---

## Markdown output and documentation edits

When Markdown is intended for direct copy-paste into a project file:

- preserve exact Markdown source formatting
- if the content itself contains fenced code blocks, use four backticks for the outer fence
- never nest a triple-backtick Markdown block inside another triple-backtick block
- prefer generating a `.md` file for large document replacements
- do not escape Markdown syntax merely to make it display as plain text when the user intends to copy it

For tracked text/documentation files:

```text
existing file + partial changes
    -> prefer a .patch against the user's current known version

new/untracked file
    -> provide the complete file

deliberate full replacement
    -> provide the complete replacement file
```

Before generating a patch, establish the correct base version:

```text
target file unchanged locally
    -> current pushed repository version may be used

target file has uncommitted local changes
    -> use the actual local version, an uploaded copy, or sufficiently complete session-review evidence

cached Project/Drive snapshot
    -> do not use as patch base when it may be stale
```

When providing a patch:

```powershell
git apply --check <patch-file>
git apply <patch-file>
```

If `git apply --check` fails:

```text
do not force the patch
inspect why the target differs from the patch base
regenerate or reconcile against the actual current version
```

---

## Automation threshold

Do not automate a development workflow merely because it can be automated.

Prefer:

```text
perform it manually
understand the steps and failure modes
experience the workflow enough to identify real friction
identify repetitive work and/or human-error risk
automate only the part with demonstrated benefit
```

A new helper script should normally wait until this threshold is met unless automation is required for correctness, reproducibility, CI, or safety.

### Task boundaries and escalation

Before tool-heavy work, identify the exact deliverable, affected files, one sufficient verification, and what is outside scope. The user controls which source areas, symbols, or research targets are investigated. Do not scan additional areas, implement adjacent features, or run autonomous investigations without authorization.

For a simple administrative change, prefer a direct edit or a single checked patch over generating a new updater script. After **two failed corrective attempts**, or **15 minutes without meaningful progress** on a task expected to be short, stop. State what failed, check the current state once, and propose the smallest manual correction. Obtain approval before expanding scope or producing another automation layer.

When mentoring, the goal is the user's understanding and user-authored production code, not maximal autonomous output. Explain responsibility and data flow, then let the user implement and validate.

---

## Continuity responsibilities

### Product repository

Treat these as product-owned:

```text
docs/DECISIONS.md
    -> established architectural/product decisions

docs/ROADMAP.md
    -> planned product sequence and stage progress

docs/architecture.md
    -> architecture that actually exists
```

### Workflow repository

Treat these as maintainer/AI-owned:

```text
PROJECT_PROFILE.md
    -> stable project-specific workflow configuration

PROJECT_CONTEXT.md
    -> current resumable development checkpoint

WORKFLOW.md
    -> human development/session process

AI_WORKFLOW.md
    -> instructions for the AI assistant
```

Do not duplicate a document into both repositories merely for convenience.

---

## Product checkpoint validation

`PROJECT_CONTEXT.md` records the exact product commit it describes.

At session start, compare it with the actual product repository:

```powershell
git -C $productRepo rev-parse HEAD
```

If it differs from `Product checkpoint`:

```text
do not assume PROJECT_CONTEXT is current
inspect product changes
reconcile the checkpoint
then continue
```

The commit SHA is evidence that the workflow context corresponds to a concrete product state.

---

## Google Drive synchronization

Google Drive is an optional read-only mirror for AI continuity.

It is not the source of truth.

The mirror is assembled from authoritative sources in both repositories.

Expected workflow-repository sources:

```text
PROJECT_PROFILE.md
PROJECT_CONTEXT.md
WORKFLOW.md
AI_WORKFLOW.md
```

Expected product-repository sources:

```text
docs/ROADMAP.md
docs/DECISIONS.md
docs/architecture.md
```

The synchronization script lives in the workflow repository:

```text
projects/osu-hitsound-editor/scripts/Sync-ProjectContext.ps1
```

Target invocation:

```powershell
& "$workflowRepo\projects\osu-hitsound-editor\scripts\Sync-ProjectContext.ps1" `
    -ProductRepository $productRepo
```

The mirror directory is configured per device through:

```text
OSU_HITSOUND_CONTEXT_MIRROR
```

Rules:

- No device-specific path belongs in tracked files.
- The AI must not modify Google Drive mirror files directly.
- Synchronize only after the authoritative repositories are in the intended pushed state.
- Never merge divergent repository/mirror files automatically.
- A cached Project snapshot exposed to ChatGPT may be stale.
- Do not use a cached snapshot to override or diagnose current repository state.
- When freshness matters, verify the live mirror or repository directly.
- If repository and mirror differ, the authoritative repositories win.

---

## External skills

Use the project-specific `EXTERNAL_SKILLS.md` registry to decide whether a third-party skill is relevant. Load or inspect only the skill needed for the active task. Its advice is lower priority than user instructions, this workflow, product decisions, actual tests, and official specifications. Never install a plugin, run an upstream script, grant browser/account access, or adopt upstream updates automatically. ChatGPT may inspect a skill as reference without claiming it is installed. Codex is optional and must not take ownership of user-authored production code.

---

## Chat handoff protocol

Changing ChatGPT conversations is **not** ending a development session. When the chat approaches its length limit or the user asks to switch chats:

1. Update `PROJECT_CONTEXT.md` only if a meaningful, unsaved checkpoint or decision would otherwise be lost. Do not turn the chat transcript into a diary.
2. If no repository content changed, do not create a commit, run tests, generate a session review, or synchronize the mirror merely because the chat changes.
3. In the new chat, read `PROJECT_PROFILE.md`, `PROJECT_CONTEXT.md`, `AI_WORKFLOW.md`, and the relevant product documents from their authoritative repositories; prefer the latest live files over stale snapshots.
4. Confirm the exact next task and resume without rechecking unchanged evidence. Check Git state only when freshness or divergence is in doubt.

If this handoff also changes devices or code, apply the normal Git synchronization and affected-product verification rules. Do not treat a chat-only handoff as a new product build.

---

## Session starting protocol

When the user starts or resumes a development session:

1. Read `PROJECT_PROFILE.md` from the workflow repository.
2. Read `PROJECT_CONTEXT.md` from the workflow repository.
3. Read the relevant part of `docs/ROADMAP.md` from the product repository.
4. Read `docs/DECISIONS.md` if the next task involves architecture/design or established behavior.
5. Read `docs/architecture.md` when component boundaries/data flow matter.
6. Confirm:
   - current stage
   - expected verification checkpoint
   - last completed functionality
   - exact next product task
7. Check repository freshness when changing devices, when local/remote divergence is plausible, or before modifying files. Reuse known clean state for a chat-only handoff.
8. Compare the product `HEAD` with `PROJECT_CONTEXT.md` `Product checkpoint` when the product may have changed.
9. For product development, run or reuse a `dotnet test` baseline that covers the current source and tests. For documentation-only workflow work or an unchanged chat handoff, do not rerun it.
10. Compare test results with the checkpoint only if new product verification was needed.
11. If the commit or test checkpoint differs:
   - do not guess why
   - inspect current source/tests/history
   - treat actual code/tests as implementation truth
   - update/reconcile `PROJECT_CONTEXT.md` after the discrepancy is understood
12. Restate the next task in one short sentence.
13. Define `OBJECTIVE / DONE WHEN / VERIFICATION / OUT OF SCOPE`.
14. If a new method is required, use the required method format.
15. Do not start unrelated refactors or technical-debt work unless it blocks the current task.
16. Do not begin implementation until the existing product baseline is passing or the reason for an existing failure is understood.

---

## Session closing protocol

When the user says they are stopping, pausing, going to sleep, or ending the session:

1. State the current product stage and exact verified test/verification checkpoint.
2. For meaningful product changes, run/request `New-SessionReview.ps1` from the workflow repository; for documentation-only changes, review the affected diff and `git diff --check` instead.
3. Review the session-review report only when one was required; do not generate another report to confirm an unchanged result.
4. Summarize only functionality completed in this session.
5. Identify which product documentation changed responsibility-wise.
6. Identify which workflow documentation changed responsibility-wise.
7. Record unresolved questions or technical debt without starting new work.
8. Give exactly one concrete next product task.
9. If product changes exist:
   - verify product
   - commit product
   - push product
   - obtain exact pushed product commit SHA
10. Update workflow `PROJECT_CONTEXT.md` only if meaningful resumable checkpoint information changed. When the product commit changed, record its exact pushed SHA; for workflow-only changes, keep the existing product SHA.
11. Review workflow changes once, using the smallest relevant diff.
12. Commit/push workflow repository if changes exist.
13. If mirrored authoritative files changed, synchronize the optional mirror once after pushing. Do not synchronize it solely to repeat a successful check.
14. Do not start a new feature during closing.


## Current checkpoint

Do not store a hard-coded current stage, test count, or next product feature in this file.

Always read:

```text
workflow repository:
    projects/osu-hitsound-editor/PROJECT_CONTEXT.md
```

for:

```text
current stage
current passing test/verification checkpoint
last completed functionality
exact next workflow task, when applicable
exact next product task
Product checkpoint commit
```

This prevents `AI_WORKFLOW.md` from becoming stale whenever development advances.
