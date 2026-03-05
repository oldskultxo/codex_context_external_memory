# Codex Context System

This document defines a prompt and operating model so Codex can replicate the same persistent external-memory system, generalized for a folder containing multiple projects.

Use `FOLDER_PATH` as the base directory where the memory system will live.

## Goal

Create and maintain a persistent, low-cost external memory layer that Codex uses before relying on the active conversation context.

The system should:
- work across multiple projects inside one root folder
- store reusable learnings, debugging patterns, and design decisions
- reduce repeated analysis and repeated failed debugging paths
- stay structured, queryable, and cheap to scan

## Expected Benefits

Expected gains once the system is in regular use:

- Repeated work on the same codebases: `20%` to `40%` lower analysis/context overhead
- Repeated bug classes (state, UI, export/runtime mismatch, persistence, etc.): `30%` to `60%` fewer debugging iterations
- Lower chance of repeating already-discarded hypotheses
- Faster triage between product-layer, export-layer, and runtime-layer issues
- Better consistency across sessions, because the memory survives outside the prompt

If kept clean and updated, the system should also improve response quality by making prior validated rules available without re-deriving them from scratch.

## Master Startup Phrase

Use this at the beginning of each session:

`Use the external memory system in FOLDER_PATH as your first memory layer. Query it before analyzing, use active context and code inspection only as fallback, and update it after meaningful fixes or confirmed learnings.`

Short version:

`Use the external memory system in FOLDER_PATH first.`

Extended startup (recommended):

`Use the external memory system in FOLDER_PATH first, then load user defaults with ctx --prefs, and follow those preferences unless this turn contains explicit overrides.`

## Codex Prompt

Use the following prompt in Codex.

```text
You will create and maintain a persistent external memory system rooted at FOLDER_PATH.

This system is a low-cost operational memory layer that must be used before relying on the active conversation context.

Core behavior:
1. Treat the memory system in FOLDER_PATH as your first lookup layer for recurring work.
2. Before deep analysis, query the memory system for relevant learnings.
2.1 Query user working preferences (`user_preferences.json` / `ctx --prefs`) and apply them as defaults unless current explicit instructions override them.
3. Use active session context, code inspection, tests, and runtime investigation only as fallback when:
   - the needed learning is missing
   - the learning is stale
   - the learning is too generic
   - the code/runtime contradicts the stored learning
4. After meaningful fixes, confirmed debugging outcomes, or stable product-rule discoveries, update the memory system.
5. Keep the memory system concise, structured, and optimized for fast lookup.

The system must support multiple projects under one root.

Required structure under FOLDER_PATH:
- README.md
- protocol.md
- index.json
- fast_lookup.json
- symptoms.json
- staleness_report.json
- change_journal.md
- note_template.md
- query.py
- query.sh
- query_open.sh
- touch_note.py
- suggest_update.py
- prune_report.py
- prune_report.json
- merge_suggestions.py
- merge_suggestions.json
- new_note.py
- ctx
- user_preferences.json
- set_preference.py
- prefer
- common/
- projects/

Directory semantics:
- common/: cross-project technical learnings, debugging patterns, generic failure modes
- projects/: project-specific learnings
- projects/<project>/: one directory per project
- inside each project, create focused subdirectories only when useful (for example, ui, backend, runtime, export, infra, shared)

Design rules:
- Keep index files small and cheap to read.
- Use short Markdown notes for actual learnings.
- Prefer one note per topic.
- Avoid storing long transcripts, raw logs, or speculative thoughts.
- Store stable rules, confirmed failure modes, debugging heuristics, validation paths, and architecture decisions.
- Prefer editing and consolidating existing notes over creating duplicates.

Each Markdown learning note should ideally contain front matter:
- priority: critical | important | reference
- confidence: high | medium | low
- last_verified: YYYY-MM-DD
- tags: comma-separated tags

Then a compact body covering:
- Problem
- Invariant
- Known failure modes
- Fastest validation

Required system features:
1. Main index:
   - `index.json` listing projects, subareas, common notes, and tag groups
2. Fast lookup:
   - `fast_lookup.json` for high-frequency topic shortcuts
3. Symptom lookup:
   - `symptoms.json` mapping real bug symptoms to likely notes
4. Query:
   - `query.py` and `query.sh` for ranked lookup by keyword or symptom
   - `query.py --json` for machine-readable output
   - `query.py --prefs` for user working preferences
   - `query_open.sh` to open the best matching note
   - `ctx` as the default short alias
5. Freshness:
   - `generate_staleness_report.py` (or equivalent) to rebuild `staleness_report.json`
   - stale notes should be detectable via `last_verified`
6. Maintenance:
   - `touch_note.py` to refresh `last_verified`
   - `suggest_update.py` to suggest which existing note should be updated
   - `prune_report.py` to detect overlapping notes
   - `merge_suggestions.py` to turn overlaps into concrete merge candidates
   - `new_note.py` to create new notes from `note_template.md`
7. Audit:
   - `change_journal.md` should log one-line structural changes to the memory system

Ranking and lookup behavior:
- Prefer project-specific notes over common notes when both are relevant.
- Prefer narrower, more specific notes over broad summary notes.
- Use symptoms and fast-lookup mappings to increase ranking confidence.
- Use tags to improve matching by layer or concern (for example: ui, state, backend, api, infra, runtime, persistence).

Operational rules:
- On each task, read `index.json` first, identify the smallest relevant note, and read that note directly.
- Read `user_preferences.json` at session start and apply preferences silently.
- `ctx`/`query.py` are optional CLI helpers; direct file reads are the primary workflow.
- Preference precedence:
  - current explicit user instruction > stored `user_preferences.json` > assistant defaults.
- If the same user preference is repeated and stable, persist it by updating `user_preferences.json` (or via `prefer` / `set_preference.py`).
- Read only the smallest relevant note or notes.
- If the memory is missing something, inspect code and runtime normally.
- If code/runtime disproves the memory, trust code/runtime and then update the memory system.
- After closing a non-trivial fix, either:
  - update an existing note
  - add a new note
  - or update open-edges / decision notes if the issue affects future risk
- Never ask the user to trigger memory updates manually; do them proactively.

Quality bar:
- Keep the system append-light and edit-heavy.
- Consolidate when overlap grows.
- If the memory stops saving time, simplify it.
- The system should remain faster to query than re-reading the chat history.

When you initialize the system:
1. Create the directory structure under FOLDER_PATH
2. Create all required index/utility files
3. Create a README and protocol
4. Seed it with general-purpose common notes if project-specific learnings are not available yet
5. Ensure the query tools work immediately

When you use the system in future tasks:
- default to direct reads (`index.json` + relevant note + `user_preferences.json`) at task start
- treat it as the first external memory layer
- keep it updated without needing explicit user reminders
- if user workflow habits become consistent, record them in `user_preferences.json` so they carry across sessions
- only surface memory contents in responses when they directly affect execution decisions

Only stop using this system if the user explicitly tells you to disable it.

Recommended Initialization Sequence

When Codex first receives the prompt:

1. Create `FOLDER_PATH`
2. Create the base file structure
3. Create the query and maintenance scripts
4. Add the protocol and template
5. Seed `common/` with generic debugging and UI/state pitfalls
6. Create `projects/` and let project-specific notes accumulate over time
7. Test:
   - verify `index.json` and `user_preferences.json` can be read directly
   - verify one targeted note can be read directly
   - use CLI checks (`ctx`, `ctx --json`) only as optional sanity checks

Practical Notes

- This system should remain general across many repositories, not tied to a single product.
- Project-specific notes should be added only when validated by actual work.
- Common notes should capture patterns that genuinely repeat across projects.
- If a note becomes stale or noisy, it should be merged, tightened, or removed.
- For automatic usage across repositories, place an `AGENTS.md` in a common ancestor directory (for example `/Users/santisantamaria/Documents/projects/AGENTS.md`) with explicit instructions to always read `index.json` and `user_preferences.json` first.
- In that `AGENTS.md`, encode preference precedence and the rule to persist repeated user habits (`no intermediate feedback`, `always run tests`, `always run build`, `always update docs`, etc.).


Useful cross-project tags:

- `ui`
- `state`
- `runtime`
- `backend`
- `api`
- `persistence`
- `auth`
- `export`
- `build`
- `testing`
- `validation`
- `infra`
- `performance`
- `debugging`
- `workflow`

## Closing Guidance

This system is worth using if it stays:

- faster than re-reading old context
- smaller than a wiki
- more operational than documentation
- disciplined enough to prevent duplicate or stale learnings

If it grows without curation, it loses value. If it stays concise and updated, it becomes a durable multiplier for multi-session engineering work.

```
