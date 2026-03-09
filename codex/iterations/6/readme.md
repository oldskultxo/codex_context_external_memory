# Iteration 6 — Task-Specific Memory

Iteration 6 adds a **task-specific memory layer** to `codex_context_engine`.

Until Iteration 5, the engine already knew how to persist general repository knowledge, score relevance, compact context, and expose global diagnostics. Iteration 6 pushes the model further: memory is no longer only global, but also **specialized by workflow type**.

## Goal

Different engineering tasks need different kinds of reusable knowledge.

A bug-fixing session benefits from recurring error patterns, fragile modules, and common failure locations.
A refactor benefits from structure constraints, rename patterns, and module boundaries.
A testing task benefits from known test entry points, flaky areas, and coverage conventions.

Iteration 6 introduces a layer that allows the engine to retrieve and persist that kind of knowledge in a task-aware way.

## Core idea

The engine now resolves an active `task_type` and uses it to enrich context retrieval before execution.

Conceptually:

```text
User Task
  ↓
Task Type Resolution
  ↓
Task-Specific Memory Retrieval
  +
General Memory Retrieval
  ↓
Deterministic Context Packet
  ↓
Codex Execution
```

## Baseline task types

The stable baseline for this iteration is:

- `bug_fixing`
- `refactoring`
- `tests`
- `performance`
- `architecture`
- `general`

`general` is the mandatory fallback bucket.

## Expected storage model

Task-specific memory is stored separately from the main general memory layer, using a structure equivalent to:

```text
.codex_task_memory/
  bug_fixing/
  refactoring/
  tests/
  performance/
  architecture/
  general/
```

This layer complements `.codex_memory/`. It does not replace it.

## What this iteration adds

- task type resolution
- task-aware context retrieval
- task-aware persistence of reusable learnings
- safe fallback to `general`
- compatibility with existing deterministic packet assembly
- observability around task-memory usage

## Examples of reusable task memory

### bug_fixing
- recurring failure patterns
- fragile modules
- common root causes
- typical fix locations

### refactoring
- naming conventions
- module boundaries
- known coupling problems
- safe migration constraints

### tests
- test entry points
- flaky areas
- common setup patterns
- existing test conventions

### performance
- hotspots
- expensive flows
- query bottlenecks
- token-heavy or slow analysis areas

### architecture
- subsystem boundaries
- important design decisions
- known layering rules
- cross-cutting constraints

## Design constraints

Iteration 6 must preserve the **autoincremental engine model**.
It should be additive, backward-compatible, and safe for in-place upgrades.

That means:

- no destructive reset of prior memory
- no breaking changes to earlier retrieval flow
- no bypass of deterministic packet generation
- no dependence on a fresh install

## Benefits

- more relevant context retrieval
- better specialization by task category
- less noise in large repositories
- stronger reuse of repository-specific working knowledge
- safer repeated debugging, refactoring, and testing workflows

## Notes

This iteration is intentionally conservative.
It introduces specialized memory while still preserving the general memory path as the universal fallback.
That keeps the engine resilient even when classification is uncertain or task-specific memory is still sparse.
