# Codex Context External Memory

This repository contains prompt specifications for building and validating an external-memory workflow for Codex.

The latest iteration (`codex/iterations/two`) defines a complete system that combines:

- **Codex Ultra Memory System (CUMS)** for persistent, low-token memory
- **Delta Context Engine** for task-scoped context packets
- **Telemetry tracking** for estimated context/token/latency/cost savings
- **Validation checklist** for functional and performance verification

## What This Project Is For

The project is used to make Codex more efficient across sessions by:

- reducing repeated context loading
- reusing persistent user preferences and validated project learnings
- retrieving only the smallest relevant memory slice per task
- falling back to normal repo inspection when memory is missing/stale
- tracking estimated optimization impact over time

## Repository Layout

- `codex/iterations/one/`: first generation prompt (`codex_context` model)
- `codex/iterations/two/`: current generation prompts (recommended baseline)
  - `1_codex_ultra_memory_system_prompt.md`
  - `2_codex_context_telemetry_prompt.md`
  - `3_codex_ultra_memory_system_validation_checklist.md`

## How It Works (Latest Iteration)

After you execute the **iteration two prompts** in Codex, the expected flow is:

1. **Memory system bootstrap**
- Codex creates a persistent memory workspace (for example `.codex_ultra_memory/`).
- Small boot artifacts are generated for fast startup (`boot_summary`, `user_defaults`, routing profile).

2. **Session auto-init**
- On each new session, Codex loads only tiny boot files first.
- User preferences and routing defaults are applied automatically.

3. **Task execution with delta retrieval**
- Codex classifies the task.
- It builds a minimal **task packet** with only relevant preferences, constraints, decisions, patterns, and likely file paths.
- It uses this packet before broad repository scanning.

4. **Safe fallback**
- If memory is stale, missing, or contradicted by code/tests/runtime, Codex falls back to standard reasoning and direct repo inspection.

5. **Learning updates**
- After meaningful validated outcomes, Codex writes compact structured records (not transcripts).
- Indexes and boot summaries are refreshed only when needed.

6. **Telemetry updates**
- Task-level optimization estimates are logged.
- Weekly or explicit checkpoints can be generated to summarize estimated savings.

7. **Validation**
- The checklist prompt is used to verify auto-boot, preference persistence, delta retrieval quality, fallback robustness, migration quality, and performance trends.

## Recommended Prompt Execution Order

1. Run `1_codex_ultra_memory_system_prompt.md`
2. Run `2_codex_context_telemetry_prompt.md`
3. Run `3_codex_ultra_memory_system_validation_checklist.md`

This order installs the system, adds measurement, then validates behavior.

## Quick Start

From the project root, open each prompt and execute it in Codex in this order:

```bash
cat codex/iterations/two/1_codex_ultra_memory_system_prompt.md
cat codex/iterations/two/2_codex_context_telemetry_prompt.md
cat codex/iterations/two/3_codex_ultra_memory_system_validation_checklist.md
```

If needed, copy each file content into Codex one by one and run it before moving to the next file.

## Estimated Savings (iepub Experience)

These are **estimated** ranges from practical usage in the iepub project (not exact telemetry export numbers).

**Iteration that produced these results:** `iterations/two` (Ultra Memory + Telemetry workflow).

| Metric | Estimated range | Visual |
|---|---:|---|
| Context reduction | 35-55% | `████████░░` |
| Total token reduction | 25-45% | `███████░░░` |
| Latency improvement | 15-30% | `█████░░░░░` |
| Cost reduction | 20-40% | `██████░░░░` |

Confidence: **medium** (experience-based estimate; exact values should come from `.context_metrics/` checkpoints in the target repo).

## Current State of This Repository

This repository stores the prompt definitions and validation criteria.
It does **not** include the generated memory/telemetry implementation by default; those files are created in the target project when Codex executes the prompts.
