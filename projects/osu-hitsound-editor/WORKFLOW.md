# WORKFLOW

This is the project-specific development workflow for `osu-hitsound-editor`.

The product and the maintainer/AI workflow now have separate repositories:

```text
PRODUCT REPOSITORY
    FAJIFBEFJHA/osu-hitsound-editor

WORKFLOW REPOSITORY
    FAJIFBEFJHA/ai-assisted-development-workflow
    projects/osu-hitsound-editor/
```

The product repository contains the software, tests, CI, and documentation that any contributor may need.

The workflow repository contains the maintainer-specific development process, AI instructions, continuity checkpoint, and workflow tools.

Project-specific stable configuration is defined in:

```text
PROJECT_PROFILE.md
```

---

## Repository roles

### Product repository

Owns:

```text
src/
tests/
.github/
.editorconfig
README.md
CONTRIBUTING.md
LICENSE
docs/ROADMAP.md
docs/DECISIONS.md
docs/architecture.md
```

This repository is authoritative for:

```text
implementation
tests
product architecture
product decisions
product roadmap
public/contributor documentation
```

### Workflow repository

For this project, owns:

```text
projects/osu-hitsound-editor/PROJECT_PROFILE.md
projects/osu-hitsound-editor/PROJECT_CONTEXT.md
projects/osu-hitsound-editor/WORKFLOW.md
projects/osu-hitsound-editor/AI_WORKFLOW.md
projects/osu-hitsound-editor/scripts/
```

This repository is authoritative for:

```text
maintainer/AI continuity
learning/collaboration rules
session process
workflow tooling
```

Do not duplicate product `ROADMAP.md`, `DECISIONS.md`, or `architecture.md` into the workflow repository.

---


## Start of a session

Identify the two local clones without hard-coding their paths in tracked files.

Example local variables:

```powershell
$productRepo = "<local path to osu-hitsound-editor>"
$workflowRepo = "<local path to ai-assisted-development-workflow>"
```

When switching devices or when remote updates are expected, check for local changes first:

```powershell
git -C $productRepo status --short
git -C $workflowRepo status --short
```

Only if the affected repositories are in an expected state, pull the needed updates:

```powershell
git -C $productRepo pull
git -C $workflowRepo pull
```

Do not pull over unexpected local modifications. For a chat-only handoff on an unchanged device, skip unnecessary synchronization.

Check both working states when needed:

```powershell
git -C $productRepo status
git -C $workflowRepo status
```

Before product development, run or reuse a passing baseline for the current source and test state:

```powershell
Push-Location $productRepo
dotnet test
Pop-Location
```

Skip product tests for workflow-only documentation changes or a chat-only handoff when nothing relevant changed. Do not start new functional work if a needed baseline is unexpectedly failing.

Then read, in this order:

```text
1. workflow repository:
       projects/osu-hitsound-editor/PROJECT_PROFILE.md

2. workflow repository:
       projects/osu-hitsound-editor/PROJECT_CONTEXT.md

3. product repository:
       docs/ROADMAP.md

4. product repository:
       docs/DECISIONS.md
       when the task involves architecture/design/established behavior

5. product repository:
       docs/architecture.md
       when the task crosses architectural boundaries
```

Compare the `Product checkpoint` commit recorded in `PROJECT_CONTEXT.md` with the current product `main` commit.

```powershell
git -C $productRepo rev-parse HEAD
```

If they differ:

```text
do not assume the checkpoint still describes current main
inspect what changed
reconcile PROJECT_CONTEXT before relying on stale assumptions
```

Choose one small functional objective and define how the session will end.

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

Avoid combining:

```text
new feature
+ large refactor
+ architecture rewrite
```

in one step unless the task genuinely requires all three.

---

## Before implementing a new method

First define the behavior contract:

```text
NORMAL:
    what observable result should happen

INVALID / BOUNDARY:
    relevant states that must be rejected or handled

VERIFICATION:
    automated regression test and/or focused manual/integration check
```

If the method creates or retains a resource such as an `IDisposable`, `Stream`, `WaveStream`, file handle, audio device, or event subscription, also answer:

```text
Who creates it?
Who owns it?
How long must it live?
Who releases it?
What happens if initialization fails partway through?
What concurrency/threading rules apply?
```

Then define the method using exactly:

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
    When relevant, classify implementation data as:
        FIELD NUEVO
        LOCAL NUEVA
        PARAMETER
        EXISTENTE
    State its exact type, declaration location, scope when relevant, and responsibility.

FLUJO:
    Short pseudocode directly translatable to code.
```


`FLUJO` must be short and directly translatable to code.

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

Then implement the complete method.

Do not split the normal process into:

```text
write signature
-> review
-> write body
```

unless the signature itself is the concept being studied.

Diagnostic or temporary-tool code may be complete, but it must not be copied into `src/` as a shortcut around the learning workflow.

When working with an AI mentor:

```text
production code under src/
    -> author writes it

less abstract explanation
single pseudocode line
syntax example
partial-method review
    -> not permission for a complete production implementation
```

Small snippets are acceptable for explaining one expression, one API call, or one exception, but they must not be assembled into a de facto complete production method unless the author explicitly asks for the full implementation.

`FLUJO` must expose important intermediate transformations. In particular:

```text
builder
    -> configure builder
    -> Build()
    -> concrete result object
```

must not be compressed into an ambiguous instruction such as "create the result using the builder" when the intermediate type change matters.

Before implementation, verify that the proposed flow covers the applicable:

```text
normal path
error paths
variable scope
ownership / lifetime
cleanup
state transitions
threading / concurrency
```

Avoid ambiguous assignment arrows when source and destination could be confused.

Prefer:

```text
destination = source
```

or explicitly say:

```text
guardar source en destination
```

Do not introduce a predictable requirement from this review only after the author has already implemented the method, unless new evidence genuinely appeared later.

---

## Modifying existing methods

Use the **current method body** as the starting point, not a generic pseudocode replacement. If the method is not available or may have changed, obtain it first.

Describe edits in existing-code order using `[CONSERVAR]`, `[AGREGAR]`, `[REEMPLAZAR]`, and `[ELIMINAR]`. For each addition or replacement, identify the exact location and concrete identifiers/types. Show the revised `FLUJO` only as needed to make the modifications directly implementable.

Check validation before acquiring disposable resources, and review every affected `try/catch`, cleanup path, state transition, and call site. Do not overlook references to a replaced provider or object in dictionaries, mixer inputs, event handlers, or rollback logic.

The author updates the production method. Keep unaffected code unchanged; provide complete exception expressions when appropriate and focused tests after reviewing the change. See `AI_WORKFLOW.md` for the detailed rule.

---

## While implementing

Keep track of data flow:

```text
Where does this value come from?
What type is it?
Which method transforms it?
Does that call return a different type/object?
Who owns the result and how long must it live?
Where does the result go?
```

If confused, use a concrete trace:

```text
variable                  value
--------------------------------
slider.Time               1500
spanDuration              500
edgeIndex                 1
edgeTime                  2000
```

When using an external library and the API behavior is uncertain, verify the official documentation/source for the exact package version referenced by the project before building further instructions on top of it.

When a type transition itself is part of what is being learned, prefer an explicit type in the example. `var` is fine when the inferred type is obvious on the same line and does not hide an important transformation.

---

## Error handling

Do not hide impossible states with plausible-looking return values.

Use appropriate exceptions.

When using `ArgumentOutOfRangeException`, prefer constructors that include:

```text
nameof(parameter)
actual invalid value
exact English message
```

Example:

```csharp
throw new ArgumentOutOfRangeException(
    nameof(edgeIndex),
    edgeIndex,
    $"The slider edge index must be between 0 and {slider.Slides}.");
```

Exception messages and technical identifiers are written in English.

---

## Tests

After implementing behavior:

1. Add tests for the normal case.
2. Add relevant boundary/error cases.
3. Run tests covering the affected behavior. Run the full product suite when establishing a meaningful regression checkpoint:

```powershell
Set-Location $productRepo
dotnet test
```

Do not change a correct test merely to make an incorrect implementation pass.

Keep the standard automated suite independent of physical hardware when possible.

If behavior requires a real audio device or another machine-specific resource:

```text
hardware-independent contract
    -> automated test

real device path
    -> focused manual/integration verification
```

Do not make ordinary CI depend on hardware unless the project deliberately introduces an appropriate integration-test environment.

If a real-device verification is written as a temporary integration test:

```text
verify the behavior
remove the temporary test
if production and permanent tests remain unchanged
    -> reuse the latest valid passing permanent-suite result
otherwise, or if prior verification was invalidated
    -> rerun the affected checks
```

Use the evidence type deliberately:

```text
automated regression test
    -> deterministic project behavior

manual/integration verification
    -> hardware, OS integration, or external environment

diagnostic spike
    -> temporary API/behavior research
    -> not production code
```

Decide the required evidence before implementation rather than after the code is already written.

If tests fail:

```text
What did I expect?
What actually happened?
Which variable first became incorrect?
Where did that variable get its value?
Which method produced the first unexpected value?
```

Use the stack trace before changing code.

---

## Refactoring rule

Do not refactor merely because the code could look cleaner.

Ask:

```text
Is there a real problem now?
    no -> do not refactor
    yes
        -> does the refactor help the current task,
           remove real duplication,
           reduce risk,
           or clarify an actual responsibility boundary?
```

Evaluate:

```text
benefit
implementation cost
complexity
risk
maintainability
timing
```

When duplication is real, use the smallest helper that removes it.

Do not turn a simple repeated precondition into a generic delegate/callback/interface abstraction unless the current feature actually benefits from that extra flexibility.

Use this only as a signal:

```text
first occurrence
    -> normally keep local

second similar occurrence
    -> observe

third identical/simple repetition
    -> explicitly evaluate a small helper
```

This is not a mathematical rule.

A real responsibility boundary can justify a helper earlier, while superficially similar code can remain separate when its semantics differ.

Prefer functional progress over premature abstraction.

---

## Automation threshold

Do not automate a workflow merely because automation is possible.

Use the manual process first long enough to understand:

```text
the steps
failure modes
actual repetition/friction
human-error risk
```

Automate only when that experience demonstrates a concrete benefit, unless automation is required for correctness, reproducibility, safety, or CI.

---

## Documentation updates and patches

Documentation now belongs to two different repositories.

### Product documentation

Update in `osu-hitsound-editor`:

```text
README.md
CONTRIBUTING.md
docs/ROADMAP.md
docs/DECISIONS.md
docs/architecture.md
```

### Maintainer/AI workflow documentation

Update in `ai-assisted-development-workflow`:

```text
projects/osu-hitsound-editor/PROJECT_PROFILE.md
projects/osu-hitsound-editor/PROJECT_CONTEXT.md
projects/osu-hitsound-editor/WORKFLOW.md
projects/osu-hitsound-editor/AI_WORKFLOW.md
```

Do not copy a document into both repositories merely for convenience.

For partial changes to an existing tracked text/documentation file, prefer a Git patch over replacing the entire file.

```text
existing tracked file + partial changes
    -> .patch

new/untracked file
    -> complete file

deliberate full replacement
    -> complete replacement file
```

The patch must be generated against the version the user actually has locally.

If the target file has uncommitted local changes, do not use a stale repository or Project/Drive snapshot as the base.

Apply patches in two steps:

```powershell
git apply --check .\change.patch
git apply .\change.patch
```

If the check fails:

```text
stop
do not force
identify the base-version mismatch
regenerate/reconcile the patch
```

---

## Verification proportional to risk

Do not repeat expensive verification mechanically when the latest change cannot affect behavior.

```text
production / permanent tests / executable script logic changed
    -> run checks covering the affected behavior
    -> run the full product suite for a meaningful regression checkpoint

meaningful product documentation change
    -> inspect the product-repository diff

meaningful workflow documentation change
    -> inspect the workflow-repository diff

workflow script behavior changed
    -> verify the script against the intended repository
    -> verify failure behavior where practical

formatting-only correction after an already reviewed report
    -> git diff --check
    -> git status --short
    -> no automatic full report/test rerun
```

If a change touches executable semantics, dependency versions, generated artifacts, or configuration behavior, it is not formatting-only.

Removing an already-verified temporary hardware test does not require repeating a successful permanent-suite run unless the change affects test discovery/build or otherwise invalidates prior evidence. Diagnose failed checks and expand verification only where needed.

---

## Working across multiple devices

Use Git/GitHub, not a synchronized folder, as repository transport.

Both repositories need their own clone on a device where the maintainer workflow will be used.

Before switching devices:

```text
PRODUCT REPOSITORY
    -> verify current product work
    -> commit if changed
    -> push
    -> confirm expected status

WORKFLOW REPOSITORY
    -> update continuity checkpoint
    -> commit if changed
    -> push
    -> confirm expected status
```

On the receiving device:

```text
check status of both repositories for local modifications
only if local states are expected, git pull both repositories
check status of both repositories after pulling
run product baseline verification
compare PROJECT_CONTEXT product checkpoint with current product HEAD
continue
```

Rules:

- Do not place either Git repository itself inside Google Drive/OneDrive as a synchronization strategy.
- Do not copy repository folders between devices to transfer changes.
- Avoid modifying the same checkpoint on two devices at once.
- Prefer stable checkpoints on `main` before switching devices.
- If unfinished product work is not appropriate for `main`, push it on a temporary branch.
- `git stash` is local and is not a cross-device transfer mechanism.
- Never force-push `main`.
- Unexpected local changes or conflicts must be inspected before destructive Git commands are used.

---

## Portable scripts and local configuration

Tracked scripts must not contain:

```text
drive letters
user-profile paths
absolute repository paths
device-specific Google Drive mount paths
machine-specific secrets
```

Use:

```text
$PSScriptRoot
Git repository discovery
explicit parameters
environment variables for unavoidable machine-local paths
```

Routine repository scripts target Windows PowerShell 5.1 compatibility unless a newer runtime is materially required.

Before introducing a newer PowerShell/.NET API:

```text
Is the newer API materially required?
    no
        -> use a Windows PowerShell 5.1-compatible alternative

    yes
        -> document the required PowerShell version
        -> fail clearly when the required version is unavailable
```

The Google Drive continuity mirror uses:

```text
OSU_HITSOUND_CONTEXT_MIRROR
```

Configure that variable separately on each device.

The workflow repository stores only the variable name, never the actual local path.

Generic setup form:

```powershell
[Environment]::SetEnvironmentVariable(
    "OSU_HITSOUND_CONTEXT_MIRROR",
    "<local-mirror-directory>",
    "User")
```

Open a new PowerShell session after changing a user-level environment variable.

### Project-specific script interface

The project-specific scripts live at:

```text
projects/osu-hitsound-editor/scripts/
```

They must derive the workflow repository from `$PSScriptRoot`.

Because the product repository is separate, they must receive or otherwise explicitly resolve the product repository instead of assuming that the script itself lives inside it.

Target invocation:

```powershell
& "$workflowRepo\projects\osu-hitsound-editor\scripts\New-SessionReview.ps1" `
    -ProductRepository $productRepo
```

and:

```powershell
& "$workflowRepo\projects\osu-hitsound-editor\scripts\Sync-ProjectContext.ps1" `
    -ProductRepository $productRepo
```

The review script belongs to the **workflow repository**, not the product repository.
Its `-ProductRepository` parameter is required and must point to the local product clone.
It can be invoked from any working directory after `$workflowRepo` and `$productRepo`
have been set to their respective clone paths. Do not run
`.\scripts\New-SessionReview.ps1` from the product repository.

If the script is not found, check the workflow-clone path first:

```powershell
Test-Path -LiteralPath "$workflowRepo\projects\osu-hitsound-editor\scripts\New-SessionReview.ps1"
```

Do not hard-code `$productRepo` or `$workflowRepo` into tracked files.

---

## Switching chats without ending the session

Changing chats is a continuity handoff, not a Git checkpoint. Ensure `PROJECT_CONTEXT.md` contains the current unresolved task; update it only if required. In the new chat, ask the assistant to read `PROJECT_PROFILE.md`, `PROJECT_CONTEXT.md`, and `AI_WORKFLOW.md` from `ai-assisted-development-workflow`, then resume the exact task. An unchanged chat handoff needs no tests, reports, commits, or mirror refresh. See `AI_WORKFLOW.md` for the complete protocol.

---

## Before ending a session

Do not use a large interactive terminal `git diff` as the normal closing-review workflow.

For meaningful product changes, run:

```powershell
& "$workflowRepo\projects\osu-hitsound-editor\scripts\New-SessionReview.ps1" `
    -ProductRepository $productRepo
```

For workflow-documentation-only changes, inspect the affected diff and run `git diff --check` once instead. Reuse prior product test evidence when source and tests have not changed. A full session review is unnecessary for that case.

When needed for meaningful product changes, `New-SessionReview.ps1` deliberately runs the full product suite once as part of closing the checkpoint. Do not rerun the script solely after documentation-only or formatting-only corrections.

When used, the session review should gather enough information to review the complete development checkpoint without manually navigating large terminal diffs.

At minimum it should report:

```text
PRODUCT REPOSITORY
    dotnet test result
    git status --short
    git diff --stat
    git diff --check
    unstaged tracked diff
    staged diff
    relevant untracked text-file contents

WORKFLOW REPOSITORY
    git status --short
    git diff --stat
    git diff --check
    relevant tracked/untracked workflow changes
```

The report remains local history and must be stored outside both repositories.

Preserve the established timestamp rule:

```text
the timestamp inside the report
and
the timestamp in the filename
    -> come from the same captured DateTime value
```

Review the report before finalizing continuity documentation.

### Update product documentation when needed

Update:

```text
docs/ROADMAP.md
    -> when product stage/progress meaningfully changes

docs/DECISIONS.md
    -> when an architectural/behavioral decision becomes stable

docs/architecture.md
    -> when actual architecture/boundaries change

README.md / CONTRIBUTING.md
    -> when their public information becomes inaccurate
```

### Update workflow documentation when needed

Update:

```text
PROJECT_CONTEXT.md
    -> every resumable checkpoint change

PROJECT_PROFILE.md
    -> stable project/workflow configuration changes

WORKFLOW.md / AI_WORKFLOW.md
    -> only when the development process itself changes
```

`PROJECT_CONTEXT.md` is a checkpoint, not a diary.

Keep it current and focused on information needed to resume development. Update it only when meaningful checkpoint information changes; do not rewrite an unchanged product SHA or checkpoint during workflow-only edits.

### Commit order

If the product repository changed:

```text
1. verify product behavior
2. update required product documentation
3. review product changes
4. commit product repository
5. push product repository
6. obtain the pushed product commit SHA
7. update workflow PROJECT_CONTEXT.md with that exact Product checkpoint
```

Then:

```text
8. review workflow-repository changes
9. commit workflow repository
10. push workflow repository
```

If only workflow files changed, the recorded product checkpoint remains unchanged.

After both authoritative repositories are pushed, synchronize the optional continuity mirror:

```powershell
& "$workflowRepo\projects\osu-hitsound-editor\scripts\Sync-ProjectContext.ps1" `
    -ProductRepository $productRepo
```

Do not synchronize the mirror before the authoritative repositories are in the intended pushed state.

---

## Continuity mirror

Google Drive is an optional read-only continuity mirror for AI access, not the source of truth.

The mirror is assembled from the authoritative locations instead of requiring all source files to exist in one repository.

Expected sources:

```text
WORKFLOW REPOSITORY
    PROJECT_PROFILE.md
    PROJECT_CONTEXT.md
    WORKFLOW.md
    AI_WORKFLOW.md

PRODUCT REPOSITORY
    docs/ROADMAP.md
    docs/DECISIONS.md
    docs/architecture.md
```

The mirror may contain copies of both categories for convenience, but those copies are not authoritative.

When verifying continuity:

```text
product repository / pushed main
    -> authoritative product state

workflow repository / pushed main
    -> authoritative maintainer/AI workflow state

live Google Drive
    -> continuity mirror

Project snapshot exposed to AI
    -> potentially stale cached/indexed copy
```

Do not diagnose a synchronization failure from a Project snapshot alone.

If freshness matters, verify the live mirror directly or compare its metadata first.

---

## Recovery when stuck

Reduce the problem.

Instead of:

```text
How do I implement slider timing?
```

ask:

```text
What value do I need next?
What data produces that value?
Can I test that transformation independently?
```

If an experiment becomes messy, use the smallest useful product checks first:

```powershell
git -C $productRepo status --short
git -C $productRepo diff --stat
git -C $productRepo diff --check

Set-Location $productRepo
dotnet test
```

For workflow problems:

```powershell
git -C $workflowRepo status --short
git -C $workflowRepo diff --stat
git -C $workflowRepo diff --check
```

Return to the last known-good checkpoint when necessary.

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
7. AI/chat advice
```

An AI suggestion never overrides verified project behavior silently.
