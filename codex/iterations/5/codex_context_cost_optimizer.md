# Codex Context Engine — Iteration 5 Implementation Prompt

You are working inside the **`codex_context_engine` source repository**.
Your task is to implement **Iteration 5 — Context Cost Optimizer** as the next cumulative iteration of the engine.

This repository already follows an **autoincremental iteration model**:
- the root orchestrator discovers numeric iteration folders dynamically
- missing iterations are applied in ascending order
- each iteration is cumulative, not destructive
- upgrades must preserve existing state and capabilities

That behavior must remain intact.

Do **not** rewrite the engine as a monolith.
Do **not** break the incremental installer / upgrader model.
Do **not** hardcode assumptions that would make future Iteration 6+ harder.

---

# PRIMARY OBJECTIVE

Add a new **Iteration 5** that introduces a **Context Cost Optimizer** layer.

The optimizer must act **after context retrieval / assembly** and **before model injection**.
Its purpose is to estimate the size and cost of the context packet and reduce it when necessary, while preserving the most valuable information.

This iteration must fit the already established engine flow and preserve the existing cumulative behavior.

Target outcome:

```text
Task
  ↓
Existing context selection / retrieval
  ↓
Deterministic context packet
  ↓
Context Cost Optimizer
  ↓
Budget-compliant optimized context packet
  ↓
Codex execution
```

---

# IMPORTANT CONSTRAINTS

## 1. Preserve the autoincremental engine flow

The engine must still behave as an additive sequence of iterations.

That means:
- root discovery remains dynamic
- iteration folders remain numeric
- Iteration 5 must be installable on top of 1–4
- future iterations must still be able to extend the system without redesigning this one
- no destructive replacement of previous telemetry, memory, diagnostics, or selection artifacts

## 2. Optimize context, not just document it

This iteration must add **real system artifacts and runtime rules** for cost optimization.
It must not be only a conceptual README.

## 3. Keep the system prompt-driven and repository-native

The engine is not a compiled framework.
Its behavior should remain understandable and inspectable from repository artifacts and prompts.

## 4. Be conservative with destructive behavior

Never delete useful memory by default.
When trimming, prefer:
- exclusion from the current packet
- summarized representation
- ranking-based drop policy
- explicit reporting of what was omitted

## 5. Keep compatibility with prior deterministic behavior

Iteration 3 introduced deterministic context packet behavior.
Iteration 5 must **optimize deterministically**, or as close to deterministic as practical.
Given the same packet + same budget + same metadata, the optimizer should produce the same result.

---

# ITERATION 5 — DESIGN INTENT

This iteration corresponds to the roadmap item we fixed as:

**Iteration 5 — Context Cost Optimizer**

Core idea:

> Before context reaches the model, estimate its cost and reduce it to fit a budget without losing the highest-value knowledge.

The optimizer should help the engine answer questions like:
- Is the current context packet too large?
- Which entries are redundant?
- Which items have the weakest value-to-cost ratio?
- Can some entries be compressed instead of removed?
- What was preserved, compressed, or excluded?

---

# CAPABILITIES TO ADD

Implement the iteration so the engine gains these capabilities.

## A. Context budget model

Introduce a lightweight budget model for context packets.

It should support concepts such as:
- target token budget
- soft budget threshold
- hard budget threshold
- estimated packet size
- optimization status

A practical model is enough. It does **not** need exact tokenizer integration.
A heuristic estimate is acceptable if clearly documented.

Example conceptual fields:

```yaml
budget_target_tokens: 3000
soft_limit_tokens: 2600
hard_limit_tokens: 3200
estimated_tokens_before: 4870
estimated_tokens_after: 2890
status: optimized
```

## B. Cost estimation layer

Add a deterministic estimation mechanism for packet size.

This may be based on:
- character count
- word count
- section count
- weighted heuristics

But it must be:
- explicit
- inspectable
- stable
- documented

## C. Optimization policy

Add a policy that decides how to reduce packet size when budgets are exceeded.

The policy should prioritize keeping:
1. highest-value entries
2. highest relevance / score entries
3. required structural context
4. recent / important records when useful

Possible reduction actions:
- drop low-score entries
- collapse duplicates / near-duplicates
- replace verbose memory with short summaries
- keep only top-N entries within a category
- preserve mandatory packet sections while trimming optional sections

## D. Value-aware trimming

Optimization must not be naive first-in-first-out trimming.

The design should reflect **value per cost**.
Examples:
- a small, high-signal architectural decision should beat a long, repetitive note
- a compact failure pattern may be worth more than a verbose historical log
- duplicate facts should be merged or reduced

## E. Optimization artifacts / observability

Add inspectable artifacts showing what the optimizer did.

At minimum, create a new cost-focused subsystem, such as:

```text
.codex_cost/
  optimizer_config.yaml
  latest_optimization_report.md
  cost_estimation_rules.md
  packet_budget_status.json
```

Exact filenames may differ, but the subsystem must be coherent and easy to inspect.

## F. Optimization reports

The engine should be able to produce a concise optimization report containing things like:
- estimated packet size before optimization
- estimated packet size after optimization
- budget used
- entries preserved
- entries compressed
- entries omitted
- rationale summary

## G. Compatibility with existing telemetry

Do not replace previous telemetry.
Extend it when appropriate.

If there is an existing telemetry area, add cost optimization metrics in a compatible way.
Possible examples:
- optimization events count
- average estimated reduction
- average kept ratio
- repeated over-budget situations

---

# EXPECTED REPOSITORY CHANGES

Implement the iteration by modifying the **source repository** itself.

## 1. Add the Iteration 5 prompt

This prompt must be the authoritative prompt that a future root orchestrator execution can apply to a target repository.

It should instruct Codex how to:
- detect whether cost optimization already exists
- install / upgrade the optimizer safely
- preserve prior state
- create needed cost artifacts
- wire the optimizer into the context flow
- leave behind a clear iteration marker update

## 2. Add the Iteration 5 README

Document:
- what problem this iteration solves
- the architecture change introduced
- major improvements
- observability additions
- impact on the engine evolution

Keep tone and style aligned with previous iteration READMEs.

## 3. Update the root README

Update repository-level documentation so it reflects that:
- Iteration 5 now exists
- Iteration 5 is Context Cost Optimizer
- the active roadmap order is now:
  - 5 Context Cost Optimizer
  - 6 Context Planner
  - 7 Failure Memory
  - 8 Task-Specific Memory
  - 9 Memory Graph

Do not turn the README into a massive rewrite.
Update it cleanly and consistently.

## 4. Update any root-level roadmap references that are necessary

If there are root-level references that would become misleading after adding Iteration 5, update them carefully.
Do not perform speculative edits beyond what is needed for consistency.

---

# IMPLEMENTATION REQUIREMENTS FOR THE ITERATION 5 PROMPT

The new `prompt.md` for Iteration 5 should be strong enough that Codex can execute it inside a target repository.
It must include the following operational rules.

## A. Installation detection

The Iteration 5 prompt must first inspect whether the target repo already has cost optimization artifacts.

Possible detection signals:
- `.codex_cost/`
- budget config files
- optimization reports
- packet budget metadata
- optimizer sections merged into existing engine files
- explicit iteration marker >= 5

If clearly installed, it should upgrade/normalize rather than blindly reinstall.

## B. Safe upgrade behavior

If prior engine state exists:
- preserve memory
- preserve telemetry
- preserve diagnostics
- preserve packet-related metadata where compatible
- normalize malformed cost artifacts if needed
- avoid duplicating sections in `AGENTS.md`

## C. Budget-first optimization flow

The prompt should install a runtime policy that conceptually works like this:

1. build / collect deterministic packet
2. estimate packet size
3. compare against configured budget
4. if under budget, keep packet and record status
5. if over budget, optimize using deterministic trim/compression rules
6. record the outcome in cost artifacts

## D. Deterministic optimization order

Define a stable optimization order, for example:
1. remove duplicates
2. remove low-value optional entries
3. compress verbose entries
4. trim within categories by score
5. preserve mandatory packet skeleton

The exact order can differ, but it must be explicit and deterministic.

## E. Honest reporting

The system must never pretend the packet fits if it still exceeds the hard limit.
If the optimized packet remains oversized, the report must say so clearly.

## F. Machine-readable state

Leave behind machine-readable artifacts so future iterations can build on them.
Examples:
- optimizer config
- budget state JSON
- optimization history JSONL
- compact status markers

---

# PREFERRED ARTIFACT MODEL

Use a simple, inspectable artifact model like this unless the repository already suggests a better compatible structure:

```text
.codex_cost/
  optimizer_config.yaml
  packet_budget_status.json
  optimization_history.jsonl
  latest_optimization_report.md
```

Suggested meanings:
- `optimizer_config.yaml`: configured thresholds and policy
- `packet_budget_status.json`: latest machine-readable optimization result
- `optimization_history.jsonl`: append-only optimization events
- `latest_optimization_report.md`: human-readable summary

If there is a better way to integrate with current repo conventions, do so.
But preserve the same conceptual capabilities.

---

# WHAT THE OPTIMIZER SHOULD CONSIDER HIGH VALUE

Where metadata exists, prefer keeping content that is:
- high relevance score
- architecture-defining
- directly task-linked
- compact but information-dense
- recent if recency matters
- historically useful for repeated tasks

Prefer trimming content that is:
- duplicated
- verbose but low-signal
- stale and weakly relevant
- low-score optional memory
- redundant summaries of already-kept facts

---

# DO NOTS

Do not:
- convert the system into a non-iterative architecture
- hardcode “latest iteration = 5” inside the root orchestrator logic
- delete previous iteration artifacts just because new ones exist
- invent exact tokenizer precision if not available
- implement opaque magic behavior with no inspectable artifacts
- overwrite unrelated project instructions in `AGENTS.md`
- break existing telemetry or global metrics behavior from Iteration 4

---

# VALIDATION EXPECTATIONS

After implementing the repository changes, validate that:
- Iteration 5 exists as a numeric iteration folder
- the new prompt is present and usable
- the new README is present
- the root README mentions Iteration 5 correctly
- the root orchestrator can still discover iterations dynamically
- no prior iteration folders were broken
- the new iteration preserves the cumulative upgrade model

If you identify ambiguity in the current repository structure, resolve it conservatively and explain your choice briefly in the final summary.

---

# OUTPUT FORMAT

When you finish, return a concise implementation summary containing:
1. files added
2. files updated
3. the chosen cost artifact structure
4. how the autoincremental flow was preserved
5. any compatibility caveat

Do not return a long essay.
Do the repository work.

---

# EXECUTE NOW

Implement **Iteration 5 — Context Cost Optimizer** in this repository as the next cumulative iteration.
Preserve the autoincremental engine model.
Update the repository documentation accordingly.
