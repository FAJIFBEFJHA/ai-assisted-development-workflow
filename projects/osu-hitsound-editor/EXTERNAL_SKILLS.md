# EXTERNAL_SKILLS

Third-party skills provide task-specific guidance. They are **optional references**, not independent agents or sources of authority. A GitHub link does not mean a skill is installed in ChatGPT. Do not copy an entire upstream repository or execute its installation scripts automatically.

## Priority and loading

User instructions, verified product source/tests, official specifications, product decisions, and this project's workflow take precedence over external skills. Read only the relevant skill when the active task calls for it. If instructions conflict, preserve project learning rules and explain the conflict. Upstream updates require deliberate review before adoption.

| Skill | Status | Use only when | Project adaptation |
| --- | --- | --- | --- |
| [Ponytail — design](https://github.com/DietrichGebert/ponytail/blob/main/skills/ponytail/SKILL.md) | Selectively adopted | Nontrivial design decisions, methods or refactors; after inspecting the affected current code | Check existing reuse before adding code. Borrow the minimum-complete-change criteria, not the full-session persona; retain all validation, tests, detailed teaching and author ownership under `src/` |
| [Ponytail — review](https://github.com/DietrichGebert/ponytail/blob/main/skills/ponytail-review/SKILL.md) | Selectively adopted | Review of a specific actual diff/method with its callers and tests available | Require concrete failure cases and evidence before labeling a finding; report recommendations without rewriting user-authored production code |
| [Ponytail — audit](https://github.com/DietrichGebert/ponytail/blob/main/skills/ponytail-audit/SKILL.md) | On demand | Explicit bounded codebase audit, not routine development | Trace real usage before calling code redundant or unused; do not scan unrelated files automatically |
| [i-have-adhd](https://github.com/ayghri/i-have-adhd) | Presentation guidance | Multi-step instructions, debugging, migrations | Lead with an actionable step, show current state, avoid tangents; do not assume a diagnosis or shorten essential teaching explanations |
| [Humanizer](https://github.com/blader/humanizer) | On demand | Public README, user-facing prose, release notes | Improve clarity without altering claims, citations, technical identifiers, or factual meaning; not an AI-detection evasion tool |
| [UI/UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | Deferred | Desktop Editor / Timeline UI stage, once WPF stack is confirmed | Use its WPF/desktop and accessibility guidance selectively; no UI dependency installation by default |
| [Browser Use](https://github.com/browser-use/browser-use) | Not needed currently | Real web interaction that existing tools cannot handle | Requires separate tool installation and permissions; do not enable for simple documentation or GitHub research |

## Runtime differences

- **ChatGPT conversation:** read the relevant upstream `SKILL.md` when accessible and use its compatible guidance; do not claim the third-party skill is installed or executable in ChatGPT.
- **Codex CLI / other skill-capable agents:** installation requires explicit user approval. Installed skills do not grant permission to explore the project autonomously, edit `src/`, perform browser actions, or expand the research scope.
- **No skill needed:** continue with the existing workflow. Do not turn skill selection itself into a separate administrative task.
