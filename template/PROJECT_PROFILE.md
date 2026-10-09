# PROJECT_PROFILE

This file contains the project-specific settings used by the otherwise generic workflow documents.

Fill this file first when starting a new project.

## Identity

```text
Project name:
Repository:
Primary purpose:
Target users:
Current maturity:
```

## Technology

```text
Primary language(s):
Framework/runtime:
Target platform(s):
Primary editor/IDE:
Package/dependency manager:
```

## Repository layout

```text
Production/source directory:
Test directory:
Documentation directory:
Scripts/tools directory:
Generated-artifact directories:
```

Use `N/A` when a category does not exist.

## Commands

```text
Sync/update command:
Build command:
Test command:
Lint/format command:
Run command:
Integration-test command:
Session-review command:
Documentation-check command:
```

Commands may be `N/A`.

Do not invent commands in `AI_WORKFLOW.md` or `WORKFLOW.md`; use the commands defined here.

## Collaboration mode

Choose the policy that applies to this project.

```text
Production implementation:
    USER_AUTHORED
    SHARED
    AI_ALLOWED

Tests:
    USER_AUTHORED
    SHARED
    AI_ALLOWED

Configuration:
    USER_AUTHORED
    SHARED
    AI_ALLOWED

Documentation:
    USER_AUTHORED
    SHARED
    AI_ALLOWED
```

Explain any important restrictions:

```text
[project-specific collaboration rules]
```

## Communication

```text
Explanation language:
Technical identifier language:
Preferred response detail:
Preferred teaching/review style:
```

## Verification policy

Define what evidence is normally expected.

```text
Unit/regression tests:
Integration tests:
Manual verification:
Hardware/device-dependent verification:
CI:
```

If the project has no automated tests yet, state that explicitly rather than pretending it does.

## External-source policy

When behavior depends on an external format, API, protocol, library, regulation, or specification:

```text
Primary authoritative source:
Secondary authoritative source:
Version that must be matched:
```

Prefer authoritative sources and the exact dependency/specification version used by the project.

## Git / version-control policy

```text
Primary branch:
Commit convention:
Branch convention:
Multi-device workflow:
Force-push policy:
```

## Documentation policy

```text
README purpose:
PROJECT_CONTEXT purpose:
ROADMAP purpose:
DECISIONS purpose:
ARCHITECTURE purpose:
```

Add project-specific rules only when they are stable enough to help future work.
