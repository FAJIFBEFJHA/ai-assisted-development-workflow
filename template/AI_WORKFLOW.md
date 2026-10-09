# AI_WORKFLOW

Use this file as instructions for any AI assistant helping with `{{PROJECT_NAME}}`.

Project-specific settings come from `PROJECT_PROFILE.md`.

## Required reading order

At the beginning of a new/resumed work session, read:

```text
1. PROJECT_PROFILE.md
2. PROJECT_CONTEXT.md
3. relevant ROADMAP.md section
4. DECISIONS.md when architecture/behavior is involved
5. ARCHITECTURE.md when component boundaries/data flow are involved
```

Do not rely on chat memory when these files provide a newer verified checkpoint.

## Source-of-truth hierarchy

Unless `PROJECT_PROFILE.md` explicitly overrides it:

```text
1. Actual source/data/artifacts and executable verification
2. Authoritative external specifications/documentation
3. DECISIONS.md
4. PROJECT_CONTEXT.md
5. ROADMAP.md
6. ARCHITECTURE.md
7. AI/chat suggestions
```

If sources conflict, point out the discrepancy instead of guessing.

## Language and communication

Follow `PROJECT_PROFILE.md` for:

```text
explanation language
technical identifier language
response detail
teaching/review style
```

Prefer clear responsibility and data-flow explanations over unnecessary abstraction.

## Collaboration / authorship policy

Read the collaboration mode in `PROJECT_PROFILE.md`.

Respect it exactly.

Examples:

```text
USER_AUTHORED
    -> explain/design/review
    -> do not provide the complete production implementation unless explicitly allowed

SHARED
    -> implementation may be produced collaboratively

AI_ALLOWED
    -> complete implementation may be provided when useful
```

A request for syntax, one API call, a concrete example, a partial review, or a less abstract explanation does not automatically override a `USER_AUTHORED` production-code policy.

When reviewing user-authored code, describe required changes without silently replacing the whole implementation unless the project's policy or user request allows it.

## Before implementation

For each meaningful feature/change, establish:

```text
OBJECTIVE
DONE WHEN
VERIFICATION
OUT OF SCOPE
```

Define observable behavior and relevant invalid/boundary behavior before implementation.

When resources/state have lifetime concerns, make ownership explicit:

```text
Who creates it?
Who owns it?
How long must it live?
Who releases/disposes/unsubscribes it?
What happens on partial failure?
What concurrency/threading rules apply?
```

## New functions / methods / components

When introducing a new implementation unit, use:

```text
LOCATION:
    exact name/signature/identifier and where it belongs

BELONGS TO:
    owning class/module/component

INPUTS:
    inputs and purpose

OUTPUTS:
    return/output type and meaning

USES:
    existing dependencies/data
    classify relevant values when useful:
        NEW FIELD
        NEW LOCAL
        PARAMETER
        EXISTING
    state exact types when type transitions matter

FLOW:
    short pseudocode directly translatable to implementation
```

The flow should cover the applicable:

```text
normal path
error paths
variable/data scope
state transitions
ownership/lifetime
cleanup
threading/concurrency
```

Do not give an incomplete plan and then add predictable missing requirements only after the user implements it.

Avoid ambiguous data-transfer arrows when source/destination could be confused. Prefer:

```text
destination = source
```

or plain language such as:

```text
store source in destination
```

## Data flow and teaching

When useful, explain:

```text
where a value comes from
its type/shape
which component transforms it
whether an API returns a different object/type
where the result goes
who owns it
how long it lives
```

Use a small concrete trace when that makes the flow easier to understand.

Do not over-explain concepts already demonstrated correctly.

## Design and refactoring

Do not automatically agree with proposed designs.

Evaluate independently:

```text
benefit
implementation cost
complexity
risk
maintainability
timing
```

Reject unnecessary refactors and premature abstractions.

Prefer the smallest helper/abstraction that solves a current real problem.

## External behavior and dependencies

When behavior depends on an external API, library, protocol, format, or specification and is uncertain:

```text
verify authoritative documentation/source
match the exact project version
do not silently assume latest behavior
```

Distinguish verified facts from inference.

## Error handling

Follow the project's established error conventions.

When recommending an error/exception contract, provide the exact form required by the project's collaboration policy, including message/value/context when those are part of the contract.

Do not convert invalid states into valid-looking fallback data without an explicit project decision.

## Verification

Tests/evidence are the primary way to confirm behavior when the project supports them.

Use evidence categories deliberately:

```text
automated regression test
integration verification
manual verification
diagnostic spike
```

Keep normal automated verification hardware-independent when practical.

Never change a correct test solely to make an incorrect implementation pass.

State the expected verification result when it can be determined.

Do not continue to the next functional step until required verification passes or the failure is understood.

## Documentation and continuity

Treat continuity files by responsibility:

```text
PROJECT_CONTEXT.md
    current resumable checkpoint

ROADMAP.md
    planned sequence/stage progress

DECISIONS.md
    stable decisions

ARCHITECTURE.md
    architecture that actually exists

WORKFLOW.md
    human process

AI_WORKFLOW.md
    AI process
```

Do not store hard-coded current stage/test counts in `AI_WORKFLOW.md` or `WORKFLOW.md`.

## Markdown / text-file updates

For tracked existing text files:

```text
partial changes
    -> prefer a reviewable patch when practical

new file
    -> provide complete file

deliberate full replacement
    -> provide complete replacement
```

Before generating a patch, establish the actual target-file base version.

A cached/project/cloud snapshot must not be treated as authoritative if it may be stale.

When applying patches:

```text
dry/check first
apply only if check succeeds
if it fails, inspect divergence
do not force blindly
```

## Automation threshold

Do not automate a process merely because it can be automated.

Prefer manual execution until the workflow and its failure modes are understood and real friction or human-error risk has appeared.

Automate earlier only when needed for correctness, reproducibility, safety, or CI.

## Session starting protocol

1. Read the required continuity files.
2. Confirm current stage/checkpoint.
3. Verify repository/workspace state.
4. Verify the baseline using the commands/policy in `PROJECT_PROFILE.md`.
5. If documentation and actual verification disagree, inspect before continuing.
6. State one concrete objective and Definition of Done.
7. Do not begin unrelated refactors or technical-debt work unless blocking.

## Session closing protocol

When the user says they are stopping/pausing/ending:

1. State the current verified checkpoint.
2. Run or request the project's session-review process.
3. Review actual changes before updating continuity files.
4. Update only documentation whose responsibility actually changed.
5. Record unresolved questions without starting new work.
6. Leave exactly one concrete next task.
7. Prepare commit/push instructions only after required verification is clean.
8. Follow any mirror/synchronization policy in `PROJECT_PROFILE.md`.
9. Do not start a new feature during closing.

## Current checkpoint

Never keep the current checkpoint here.

Always read `PROJECT_CONTEXT.md`.
