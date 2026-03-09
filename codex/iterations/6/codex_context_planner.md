# Iteration 6 — Task-Specific Memory

You are implementing **Iteration 6** of `codex_context_engine` inside the **target repository**.

This iteration must extend the existing engine without breaking the current **autoincremental flow**.
The repository may already contain Iterations 1–5. Assume the root orchestrator will continue applying iterations in ascending order and that this iteration must remain compatible with that model.

## Mission
Introduce **task-specific memory** so the engine can specialize retrieval and persistence by task type, instead of treating all reusable knowledge as a single general pool.

The result should make context retrieval more relevant for workflows such as bug fixing, refactoring, testing, performance work, and architecture tasks.

---

## Non-negotiable constraints

- Preserve the existing **autoincremental engine flow**.
- Do **not** rewrite the root orchestration model.
- Do **not** remove or invalidate existing memory, telemetry, metrics, or iteration markers.
- Do **not** break deterministic context packet generation already introduced in previous iterations.
- Prefer **additive and backward-compatible** changes.
- Migrate existing state conservatively.
- Do **not** introduce iteration-bootstrap content into this task. Focus only on implementing Iteration 6 in the target repository.

---

## Iteration 6 goal

Add a **task-aware memory layer** that allows the engine to:

1. infer or accept a task type
2. retrieve memory relevant to that task type
3. persist reusable learnings under that task type
4. keep working when no task type is known
5. remain compatible with the general memory system from prior iterations

This iteration should make the engine better at choosing context for repeated engineering workflows.

---

## Canonical task types

Support a first stable set of task types:

- `bug_fixing`
- `refactoring`
- `tests`
- `performance`
- `architecture`
- `general`

`general` must act as the safe fallback bucket.

If the repository already has conventions that suggest other categories, you may allow the system to be extensible, but the above set must exist as the baseline.

---

## Expected capabilities

### 1. Task type detection / resolution
Implement a lightweight task classification layer.

The engine should resolve task type using the safest available sources, in this order when possible:

1. explicit task type already provided by the engine or user workflow
2. existing engine metadata or packet metadata
3. heuristic inference from the task description and touched files
4. fallback to `general`

Heuristics should be simple, inspectable, and easy to maintain.
Do not over-engineer with opaque logic.

Examples:
- fixing errors, regressions, crashes, broken behavior → `bug_fixing`
- restructuring code, renaming, modularization → `refactoring`
- adding or repairing test coverage → `tests`
- profiling, bottlenecks, heavy queries, token/perf reductions → `performance`
- repo-wide structure, boundaries, conventions, system-level design → `architecture`

### 2. Task-specific storage layout
Extend the repository memory system with a task-specific layer.

Use or introduce a structure conceptually equivalent to:

```text
.codex_task_memory/
  bug_fixing/
  refactoring/
  tests/
  performance/
  architecture/
  general/
```

Inside each task area, store machine-readable memory entries and, if the engine already uses summaries/indexes, keep them consistent with existing conventions.

Do not destroy or replace `.codex_memory/`; task memory complements it.

### 3. Task-aware retrieval
Update context retrieval so that, before building the final context packet, the engine can:

- determine the active task type
- query task-specific memory for that task type
- merge those results with the general memory layer
- preserve deterministic packet behavior as much as existing architecture allows
- degrade gracefully when task-specific memory is absent or empty

The retrieval strategy should prefer:

1. task-specific relevant memory
2. general reusable memory
3. only the minimum amount of overlap necessary

### 4. Task-aware persistence
When the engine records reusable learnings from a task, it should be able to persist them in the appropriate task-specific area.

Examples of reusable task-specific learnings:
- common bug locations
- recurring failure patterns
- stable refactor constraints
- preferred test entry points
- performance hotspots
- architectural boundaries and decisions

Do not store noisy per-session chatter.
Persist only reusable, repo-relevant learnings.

### 5. Fallback compatibility
The system must still function when:

- task type cannot be inferred
- no task memory exists yet
- only legacy memory exists
- the repository is partially upgraded

In those cases, use `general` and maintain the prior flow safely.

---

## Data model guidance

Use the repository’s existing conventions if a schema style already exists.
If no task-memory schema exists yet, introduce a minimal readable structure.

Each task-memory record should be able to represent ideas such as:

- `task_type`
- `title` or short identifier
- `summary`
- `relevance signals` or priority if compatible with the current engine
- `files_involved` or `areas`
- `last_updated`
- optional `source` / `evidence`

Keep the format simple, inspectable, and aligned with current engine artifacts.

---

## Retrieval + packet integration rules

When integrating task-specific memory into the context assembly flow:

- do not bypass the existing engine stages
- insert task-aware retrieval as an extension of the current retrieval/assembly process
- preserve deterministic packet logic from previous iterations
- avoid duplicated entries in the final packet
- prefer concise summaries over raw duplication
- keep packet size disciplined

If packet-building code already has scoring, compaction, or metrics hooks, integrate task memory into those hooks rather than creating a disconnected parallel flow.

---

## Metrics and observability

Where coherent with the existing engine, extend observability so the system can report useful task-memory behavior, such as:

- resolved task type
- whether task-specific memory was used
- number of task-specific records retrieved
- fallback-to-general events
- task-memory write/update counts

Do this in the same spirit as prior telemetry and diagnostics work.
Do not create noisy logs.

---

## Migration strategy

If previous engine artifacts exist, perform a safe additive migration.

Possible migration actions:
- create the task-memory root if missing
- create baseline task folders if missing
- initialize indexes/metadata only when needed
- optionally route a small subset of clearly classifiable existing knowledge into `general`
- leave ambiguous legacy memory untouched rather than guessing aggressively

Prefer conservative migration over brittle reclassification.

---

## AGENTS.md / runtime policy updates

If the target repository uses `AGENTS.md` as the runtime policy layer, update it carefully so future agent runs understand:

- task-specific memory exists
- the engine should resolve a task type when possible
- `general` is the fallback
- task memory complements, not replaces, general memory

Do not overwrite unrelated project instructions.
Merge cleanly.

---

## Validation requirements

Before finishing, verify at least:

1. Iteration 6 artifacts are present and coherent
2. the engine still works if only general memory exists
3. task type resolution falls back safely to `general`
4. task-aware retrieval does not break existing packet generation
5. existing memory/telemetry/metrics remain preserved
6. any installed iteration marker is updated if the engine uses one

Do not claim validation you did not perform.

---

## Deliverables in the target repository

Implement the necessary code, config, schemas, docs, and policy updates required for Iteration 6.
Keep all changes aligned with the repository’s current architecture and naming conventions.

Also update any relevant documentation so the new task-specific memory layer is understandable to future maintainers.

---

## Final response format

At the end, return a concise summary with:

1. how task type is resolved
2. which files/systems were added or changed
3. how task-specific memory is stored
4. how retrieval now combines task-specific and general memory
5. what migration was performed
6. what validation was completed
7. any limitation or follow-up note
