# WORKFLOW

This is the default development workflow for `{{PROJECT_NAME}}`, with or without AI assistance.

Project-specific commands and policies come from `PROJECT_PROFILE.md`.

---

## Start of a session

1. Synchronize/update the working copy using the command defined in `PROJECT_PROFILE.md`.
2. Check repository/workspace status.
3. Run the baseline verification defined for the project.
4. Do not start new functional work if an existing expected verification is unexpectedly failing.

Then read:

```text
1. PROJECT_PROFILE.md
2. PROJECT_CONTEXT.md
3. relevant ROADMAP.md section
4. DECISIONS.md when architecture/behavior is involved
5. ARCHITECTURE.md when component boundaries/data flow are involved
```

Define one small objective:

```text
OBJECTIVE:
    one concrete goal

DONE WHEN:
    observable completion conditions

VERIFICATION:
    evidence required

OUT OF SCOPE:
    nearby work that must not expand the task
```

Avoid combining a new feature, large refactor, and architecture rewrite in one step unless the task genuinely requires all three.

---

## Before implementation

Define the behavior contract first:

```text
NORMAL:
    expected observable behavior

INVALID / BOUNDARY:
    relevant invalid or edge conditions

VERIFICATION:
    automated, integration, manual, or other evidence
```

When resources/state have meaningful lifetime:

```text
Who creates it?
Who owns it?
How long must it live?
Who releases it?
What happens on partial failure?
What concurrency/threading rules apply?
```

When introducing a new function/method/component, describe it before implementation:

```text
LOCATION:
    exact function/method/component and where it belongs

BELONGS TO:
    owning class/module/component

INPUTS:
    inputs and their purpose

OUTPUTS:
    return/output type and meaning

USES:
    existing dependencies/data
    relevant NEW FIELD / NEW LOCAL / PARAMETER / EXISTING values
    exact types when type transitions matter

FLOW:
    short pseudocode directly translatable to implementation
```

The flow must cover the applicable normal path, error paths, state transitions, ownership/cleanup, variable scope, and concurrency concerns before implementation begins.

Do not introduce predictable missing requirements only after the implementation is already written.

---

## While implementing

Track data flow:

```text
Where does this value come from?
What type/shape is it?
Which function/component transforms it?
Does the call return a different object/type?
Who owns the result?
Where does the result go?
```

Prefer concrete traces when the flow becomes hard to follow.

If an external API or format behavior is uncertain, verify the authoritative documentation/source for the exact version used by the project.

---

## Error handling

Follow the project's actual error-handling conventions.

Do not hide impossible states using plausible-looking success values.

When errors are part of a public contract, verify:

```text
error/exception type
invalid value/context
exact message when message stability matters
cleanup after failure
state after failure
```

---

## Verification

Use evidence proportional to the behavior:

```text
automated regression test
    -> deterministic project behavior

integration verification
    -> multiple real components/services

manual verification
    -> UI, hardware, physical device, or behavior unsuitable for automation

diagnostic spike
    -> temporary API/behavior research
    -> not production implementation
```

Keep the ordinary automated suite independent of machine-specific hardware when practical.

If a temporary device/environment-dependent test is created only for focused verification, remove it afterward unless the project deliberately maintains an integration-test environment.

Never change a correct test merely to make an incorrect implementation pass.

---

## Refactoring

Do not refactor merely because the code could look cleaner.

Evaluate:

```text
actual benefit
implementation cost
complexity
risk
maintainability
timing
```

Prefer the smallest abstraction that solves a real current problem.

Do not introduce future-oriented interfaces/helpers/layers without a current responsibility or consumer.

---

## Automation threshold

Do not automate a workflow merely because it can be automated.

Prefer:

```text
perform manually
    -> understand steps and failure modes
    -> experience real repetition/friction
    -> identify human-error risk
    -> automate only the part with demonstrated benefit
```

Automation may be introduced earlier when required for correctness, reproducibility, safety, or CI.

---

## Documentation changes

Update:

```text
PROJECT_CONTEXT.md
    -> when the resumable checkpoint changes

ROADMAP.md
    -> when stage/progress meaningfully changes

DECISIONS.md
    -> when a stable decision is established/replaced

ARCHITECTURE.md
    -> when actual architecture/boundaries change

AI_WORKFLOW.md / WORKFLOW.md
    -> only when the development process itself changes
```

For partial edits to tracked text files, prefer a patch when that preserves reviewability.

Before applying a patch:

```text
confirm the patch base matches the user's actual file
run the version-control dry/check command
do not force a patch that does not apply
investigate divergence first
```

---

## Verification proportional to risk

```text
production/test/script semantics changed
    -> run relevant verification

dependency/configuration semantics changed
    -> run relevant verification

meaningful documentation/workflow change
    -> review the actual diff

formatting-only edit after a clean review
    -> lightweight status/diff validation may be sufficient
```

---

## End of a session

1. Run the project's session-review process if one exists.
2. Verify the final behavior/checkpoint.
3. Review repository/workspace status and diffs.
4. Update continuity documentation to match what is actually about to be committed.
5. Record unresolved questions without starting new work.
6. Leave exactly one concrete next task.
7. Commit only after the required verification is clean.
8. Push/synchronize according to `PROJECT_PROFILE.md`.
9. Confirm a clean working state when practical.

Do not use session closing as an excuse to begin another feature.

---

## Multi-device work

Use the project's version-control system as the synchronization mechanism unless `PROJECT_PROFILE.md` says otherwise.

Before switching devices:

```text
verify
commit or push a temporary branch
push
confirm expected state
```

On the receiving device:

```text
sync/update
check status
run baseline verification
continue
```

Do not rely on local-only stashes or untracked files as a cross-device transfer mechanism.

---

## Recovery when stuck

Reduce the problem:

```text
What value/result do I need next?
What data produces it?
What is the smallest transformation involved?
Can that transformation be verified independently?
What was the last known-good checkpoint?
```

Prefer returning to a verified checkpoint over stacking guesses.
