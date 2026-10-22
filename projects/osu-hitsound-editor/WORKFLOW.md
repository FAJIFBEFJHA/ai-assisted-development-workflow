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

Read the current project instructions and checkpoint using the single authoritative reading order in `AI_WORKFLOW.md` (`Required reading order`). Consult the relevant portion of `docs/ROADMAP.md` and the conditional product documents for the session's actual task. `WORKFLOW.md` supplies operational steps; it need not be read in full at every opening.

Identify the two local clones without hard-coding their paths in tracked files.

Example local variables:

```powershell
$productRepo = "<local path to osu-hitsound-editor>"
$workflowRepo = "<local path to ai-assisted-development-workflow>"
```

When changing devices or expecting remote updates, inspect both local repository states **before any pull**:

```powershell
git -C $productRepo status --short
git -C $workflowRepo status --short
```

Only pull the affected repositories when their local states are understood and safe for synchronization:

```powershell
git -C $productRepo pull
git -C $workflowRepo pull
```

Do not pull over unexpected local modifications. If synchronization changes a workflow document, consult its new version before following it. For an unchanged chat-only handoff, do not perform unnecessary synchronization.

When needed, inspect the full working states:

```powershell
git -C $productRepo status
git -C $workflowRepo status
```

When product source may have changed, compare its current `HEAD` with the `Product checkpoint` recorded in `PROJECT_CONTEXT.md`:

```powershell
git -C $productRepo rev-parse HEAD
```

If the commits differ, inspect the actual changes and reconcile the checkpoint before relying on it. GitHub reflects published revisions, not unpublished local work.

Before **product development**, run or reuse a passing test baseline covering the current source and tests:

```powershell
Push-Location $productRepo
dotnet test
Pop-Location
```

Skip product tests for workflow-only documentation work or an unchanged chat handoff with valid prior verification. Do not start new product functionality if a needed baseline fails unexpectedly; investigate the failure first.

Organize sessions around verifiable roadmap objectives and milestones, not an arbitrary duration. Choose one session objective, whether product development or workflow maintenance, and define:

```text
OBJECTIVE:
    one concrete goal

DONE WHEN:
    observable completion conditions

VERIFICATION:
    automated and/or manual evidence required

OUT OF SCOPE:
    nearby work that must not expand the task
```

Also define a **sufficient progress point** for the session: a small, concrete, verifiable milestone within its objective that would make the session's progress meaningful even if the broader functionality remains unfinished. This is a scope guide, not a deadline, minimum productivity quota, or automatic stop.

When the point is reached, acknowledge the verified progress and do not begin the next functionality by inertia. Continue only if the project owner chooses to extend the scope. Ending the session earlier is equally valid; record the work actually completed. A partial milestone does not waive the verification needed to claim production behavior is complete.

Avoid combining a new feature, a large refactor and an architectural rewrite in one step unless truly required.

---

## Before implementing a new method

Define the observable method contract before production implementation:

```text
NORMAL:
    Expected behavior.

INVALID / BOUNDARY:
    Invalid inputs and relevant boundary cases.

VERIFICATION:
    Regression tests and/or focused integration verification.
```

When resources are involved, establish creation, ownership, lifetime, disposal, partial-failure cleanup and concurrency requirements before implementation.

`AI_WORKFLOW.md` (`New methods`, `Resource ownership`, `Primary learning rule`) is authoritative for the six mandatory sections, concrete types and scopes, directly translatable `FLUJO`, intermediate transformations, and the user's authorship of complete production methods.

Do not turn a method into a signature-only exercise unless the signature itself is the learning objective. The author implements production code under `src/`; examples and diagnostics do not implicitly authorize full production implementations.

---

## Modifying existing methods

Obtain the actual current method body before prescribing changes. The user updates production code. Follow `AI_WORKFLOW.md` (`Modifying existing methods`) for ordered `[CONSERVAR]`, `[AGREGAR]`, `[REEMPLAZAR]`, `[ELIMINAR]` instructions, exact identifiers and types, relevant call sites, resource/error paths, unchanged behavior and focused verification.

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

Invalid states must not be hidden by plausible-looking values. Follow `AI_WORKFLOW.md` (`Error handling`) for appropriate exceptions with complete English `throw` expressions, exact messages, `nameof(...)`, actual invalid values and correct constructors.

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

Refactor only for a demonstrated benefit, not merely to make code appear cleaner. Check the existing responsibility, affected callers, actual duplication, implementation cost and maintenance risk. Preserve semantic distinctions and avoid speculative helpers or abstractions.

For the complete decision criteria, reuse thresholds, and the pre-implementation design gate, follow `AI_WORKFLOW.md` (`Design and refactoring`, `Pre-implementation design gate`). The user remains the author of production changes.

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

Update product and workflow documentation only during session closing, not after each individual development milestone. This includes technical documentation, architectural decisions, roadmap, AI instructions, and continuity files. During development, implement, review, and verify functionality; this rule does not restrict code, tests, or configuration needed for that work.

Preserve decisions and results for closing through available session evidence, actual code, tests, and review reports. Do not reconstruct technical facts from conversation memory alone. Update only the documents that actually need changes.

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

During closing, Codex may directly edit explicitly authorized documents using a consolidated request. Follow `AI_WORKFLOW.md` (`Bounded Codex documentation editing`) for scope, profiles, evidence, and independent review.

When delivering partial changes for the user to apply to an existing tracked text/documentation file, prefer a Git patch over replacing the entire file.

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
    -> git diff --check
    -> no product tests or full session report for workflow-documentation-only work

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
run or reuse the product baseline only when product source/tests changed or product development resumes
compare PROJECT_CONTEXT product checkpoint with current product HEAD when the product may have changed
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

## Optional local code inspection (Codex)

Use VS Code for editing and keep the product and workflow repositories in separate integrated PowerShell terminals. Codex is **not** part of the mandatory start-up routine; open a third terminal only when the assistant needs unpublished local source and the user has agreed to a bounded inspection. On a configured machine, `codex-inspect` is an optional personal PowerShell-profile shortcut; otherwise verify Codex CLI and start it with read-only/no-approval permissions. Check `/status` before inspecting.

ChatGPT supplies a scoped inspection request naming the minimum files and questions. Codex reads only what that request authorizes, does not edit or execute product tests, and stops after the evidence report. The user normally transfers only the short final report back to ChatGPT; terminal transcripts or source excerpts are requested only to resolve ambiguity. No automatic agent startup, repository syncing, uploads, new helper scripts, or implied permission to modify `src/`.

Keep model choice, permissions and session quotas explicit. Limits shown by `/status` can be rounded; do not claim a precise token saving from remaining-quota percentages. The optional shortcut belongs outside version control and must not embed device-specific paths in tracked workflow files.

---

## Switching chats without ending the session

Changing chats is a **prompt-only handoff**, not a Git checkpoint or session close. The old chat generates one provisional chronology and recovery prompt, with direct links to the authoritative project sources. It does **not** update `PROJECT_CONTEXT.md`, write a handoff file, run tests, commit, push, or synchronize a mirror merely for the transition. The prompt must warn that messages may already be missing; see `AI_WORKFLOW.md` (`Chat handoff and recovery protocol`).

The new chat reads the current authoritative files, rather than trusting the prompt as a complete record:

- [PROJECT_PROFILE.md](https://github.com/FAJIFBEFJHA/ai-assisted-development-workflow/blob/main/projects/osu-hitsound-editor/PROJECT_PROFILE.md)
- [PROJECT_CONTEXT.md](https://github.com/FAJIFBEFJHA/ai-assisted-development-workflow/blob/main/projects/osu-hitsound-editor/PROJECT_CONTEXT.md)
- [AI_WORKFLOW.md](https://github.com/FAJIFBEFJHA/ai-assisted-development-workflow/blob/main/projects/osu-hitsound-editor/AI_WORKFLOW.md)
- [WORKFLOW.md](https://github.com/FAJIFBEFJHA/ai-assisted-development-workflow/blob/main/projects/osu-hitsound-editor/WORKFLOW.md)
- Product repository: https://github.com/FAJIFBEFJHA/osu-hitsound-editor

When local changes or uncertainty require Git reconciliation, run the bounded **read-only** resume diagnostic from the **workflow repository**, with the same mandatory `-ProductRepository` argument used by other workflow scripts. Before running the command, define `$workflowRepo` and `$productRepo` in the current PowerShell session as the absolute local paths to the workflow and product repositories, respectively. Do not assume variables from a previous terminal session are still available:

```powershell
& "$workflowRepo\projects\osu-hitsound-editor\scripts\Get-ResumeState.ps1" `
    -ProductRepository $productRepo
```

Optional `-RecentCommits` (default `5`) and `-MaxFiles` (default `20`) cap the report. The script prints to the console and does **not** run `dotnet test`, change tracked files, generate reports, fetch, or synchronize. Inspect its output before sharing; repository-relative filenames can be sensitive. Its upstream comparison uses **locally cached references**, not fresh remote verification.

Interpret checkpoint-relative committed changes, local modifications, touched test files, and historical suite results separately. If the script is missing or cannot run, request only the smallest necessary read-only evidence; never fabricate a diagnostic. If new source/tests require actual verification, handle that under the ordinary resumed development process, **not** the handoff. Use optional scoped Codex inspection only for unresolved technical questions, following `Optional local code inspection (Codex)`; a full architectural audit is not a default recovery step.

An unchanged chat-only handoff requires no tests, session review, commits, or mirror refresh. A device change still requires repository-state checks before pulling, as described in `Working across multiple devices`.

---

## Before ending a session

Avoid large interactive terminal diffs as the normal closing-review workflow; use the session-review report for product verification and context when required. ChatGPT must also inspect the actual documentation diffs against available evidence; a Codex summary alone is insufficient.

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

Keep it focused on information needed to resume development, without personal schedules, rituals, or preferences unrelated to development. Update it during closing only when meaningful checkpoint information changes; do not rewrite an unchanged product SHA or checkpoint during workflow-only edits.

### Commit order

If the product repository changed:

```text
1. run the required verification and review its report once
2. Codex updates necessary product documents through one consolidated request
3. ChatGPT reviews all actual product changes (code, tests, and documentation) against the session-review report and available evidence before the user authorizes commit and push
4. user authorizes product commit and push; publish only with that authorization
5. obtain the actual published product SHA; Codex updates the workflow checkpoint with it
```

Then:

```text
6. ChatGPT reviews the actual workflow diff against the evidence
7. user authorizes workflow commit and push; publish only with that authorization
8. synchronize the optional mirror once after the publications
```

Codex must not execute Git operations that modify a repository or its history, including staging, without explicit user authorization.

For workflow-documentation-only closing, keep the product checkpoint unchanged, review the actual workflow diff and run `git diff --check`; do not repeat product tests or generate a full session report. Product verification/publication steps do not apply. Workflow commit and push still require user authorization.

After the affected authoritative repositories are published, synchronize the optional continuity mirror once:

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
