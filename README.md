# Codex Context Engine

**Codex Context Engine** is a prompt-driven system that improves how Codex (and similar coding agents) manage context when working with real software repositories.

Instead of repeatedly sending large prompts explaining the project, the engine installs a **persistent context system** inside the repository.
This allows Codex to reuse knowledge across sessions, reduce token usage, and reason more efficiently about the codebase.

The project evolves through **incremental iterations**, each adding new capabilities to the engine.

---

# Core Idea

AI coding agents normally restart every session with no persistent memory of the project.

That means they must repeatedly learn:
- project architecture
- debugging patterns
- coding conventions
- workflow decisions
- user preferences

This leads to:
- large prompts
- wasted tokens
- slower responses
- inconsistent results

Codex Context Engine introduces a different approach:

> Treat context as a **persistent system** instead of a repeated prompt.

The engine stores useful knowledge in the repository and retrieves only the relevant information when a task is executed.

---

# How It Works

The system is installed using a **root orchestrator prompt**:

```text
codex_context_engine.md
```

This root prompt does not implement the engine itself.
Instead, it:
1. detects which engine iteration is already installed in the repository
2. discovers available iterations in this repo
3. executes any missing iterations in order
4. upgrades the engine safely without destroying existing state

This design allows the system to evolve without rewriting the installer every time a new iteration is added.

---

# Repository Structure

```text
codex_context_engine
│
├─ codex_context_engine.md
│  Root installer / upgrader prompt
│
├─ README.md
│  Project documentation
│
└─ codex/
   └─ iterations/
      ├─ 1/
      │  ├─ readme.md
      │  └─ prompt.md
      │
      ├─ 2/
      │  ├─ readme.md
      │  └─ prompt.md
      │
      ├─ 3/
      │  ├─ readme.md
      │  └─ prompt.md
      │
      ├─ 4/
      │  ├─ readme.md
      │  └─ prompt.md
      │
      ├─ 5/
      │  ├─ readme.md
      │  └─ prompt.md
      │
      └─ ...
```

Each iteration introduces a new layer of capabilities.
The **root orchestrator automatically applies all missing iterations**.

---

# Installation

To install or upgrade the engine in a repository:

1. Open the root prompt:

```text
codex_context_engine.md
```

2. Execute it inside the target repository using Codex.

The prompt will:
- detect existing installations
- determine the current iteration
- apply the missing iterations
- upgrade the engine safely

This works for both:
- fresh installations
- upgrading existing installations

---

# Iteration Model

The engine evolves through incremental iterations.
Each iteration adds new functionality while preserving compatibility with previous ones.

## Iteration 1 — External Memory Foundation

Introduces the concept of **persistent context memory** stored inside the repository.

Main ideas:
- reusable project knowledge
- persistent preferences
- graceful fallback behavior

---

## Iteration 2 — Structured Context System

Adds structure and observability.

New capabilities:
- structured `.codex_memory`
- telemetry for token/context savings
- validation and system diagnostics

---

## Iteration 3 — Smart Context Selection

Improves how context is selected and maintained.

Features:
- deterministic context packets
- relevance scoring for memory entries
- memory compaction

---

## Iteration 4 — Global Metrics & Diagnostics

Adds cross-project observability and system health monitoring.

Features:
- global telemetry aggregation
- system health checks
- cross-project savings reporting

---

## Iteration 5 — Context Cost Optimizer

Adds a budget-aware optimization layer between packet assembly and model injection.

Features:
- estimated packet cost before injection
- context budget thresholds
- value-aware trimming and compression
- optimization reports and cost observability

---

# Design Principles

The engine follows several key principles.

### Minimal Context

Only the information needed for the current task should enter the model context.

### Persistent Knowledge

Useful project knowledge should survive across sessions.

### Incremental Evolution

The system evolves through iterations rather than large rewrites.

### Safe Upgrades

Upgrades should preserve:
- memory
- telemetry
- project configuration

### Transparent Operation

The system should be understandable and inspectable inside the repository.

---

# Active Roadmap

The roadmap is now ordered by **impact and operational need**.

| Iteration | Feature |
|-----------|---------|
| 5 | Context Cost Optimizer |
| 6 | Context Planner |
| 7 | Failure Memory |
| 8 | Task-Specific Memory |
| 9 | Memory Graph |

This order reflects a practical strategy:
1. reduce context cost first
2. improve planning next
3. learn from repeated failures
4. specialize memory by task type
5. evolve toward graph-based knowledge

---

# Summary

Codex Context Engine explores a simple but powerful idea:

> Context should behave like a system, not like a repeated prompt.

By storing useful knowledge inside repositories and retrieving only relevant information, AI coding agents can become faster, cheaper, and more consistent across sessions.

With Iteration 5, the engine begins optimizing not only **what it knows**, but also **how much of that knowledge reaches the model at execution time**.
