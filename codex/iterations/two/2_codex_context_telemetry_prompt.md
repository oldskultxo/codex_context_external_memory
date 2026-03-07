
# Codex Context Optimization Telemetry System
## Single Prompt for Codex Implementation

You are tasked with implementing a **Context Optimization Telemetry System** for this repository.

Your goal is to measure and estimate the real performance improvements produced by context optimization systems such as:

- external memory
- delta context retrieval
- task packets
- preference reuse
- architecture decision reuse
- reduced repo scanning
- lighter model routing

The system must track improvements in:

- context size
- token usage
- response latency
- estimated cost

The user must be able to ask Codex questions like:

- "Give me the savings report"
- "Context savings report"
- "Compare savings with last week"
- "Create a checkpoint"
- "How much context reduction have we achieved?"

Codex must be able to answer using telemetry and stored historical estimates.

You must automatically create or update the necessary files in the repository.

Never break existing project functionality.

---

# Implementation Steps

You must perform the following steps automatically.

---

# 1 Update or Create AGENTS.md

Locate an existing `AGENTS.md` file.

If it exists:
append the **Context Optimization Monitoring section**.

If it does not exist:
create it.

Add the following section:

## Context / Token Savings Monitoring

Codex must maintain an ongoing estimation of:

- context reduction
- token reduction
- latency improvements
- approximate cost savings

Whenever the user asks for:

- savings report
- context savings
- token savings
- performance report
- optimization report

Codex must generate an estimated performance report.

Report format:

### Savings Report

Period: [today / last 7 days / last 14 days / all tracked usage]

Estimated context reduction: X–Y %  
Estimated total token reduction: X–Y %  
Estimated latency improvement: X–Y %  
Estimated cost reduction: X–Y %

Confidence: low / medium / high

Basis for estimate:

- number of tracked tasks
- repeated task patterns
- retrieved task packet size vs full context estimate
- reuse of preferences and architecture decisions
- reduction of repo exploration
- model routing to lighter models

Codex must **never claim exact numbers unless telemetry exists**.

---

# 2 Create Metrics Ledger

Create the file:

CONTEXT_SAVINGS.md

Structure:

# Context Optimization Metrics

## Baseline

baseline_mode: no external memory optimization  
baseline_date: YYYY-MM-DD

## Checkpoints

### YYYY-MM-DD

tasks_sampled:  
repeated_tasks:  
avg_full_context_estimate_tokens:  
avg_task_packet_tokens:  
estimated_context_reduction:  
estimated_total_token_reduction:  
estimated_latency_improvement:  
estimated_cost_reduction:  
confidence:  
notes:

Codex must update this file when meaningful data exists.

Preferred checkpoint frequency: weekly.

---

# 3 Create Telemetry Directory

Create directory:

.context_metrics/

Inside create:

.context_metrics/
    task_logs.jsonl
    weekly_summary.json
    baseline_estimates.json

Purpose:

task_logs.jsonl  
stores telemetry per task.

weekly_summary.json  
stores aggregated metrics.

baseline_estimates.json  
stores baseline assumptions for comparison.

---

# 4 Telemetry Log Format

Each entry in `task_logs.jsonl` must follow:

{
 "timestamp": "",
 "task_type": "",
 "estimated_full_context_tokens": "",
 "task_packet_tokens": "",
 "model_used": "",
 "estimated_reasoning_cycles": "",
 "notes": ""
}

If real token counts exist use them.

Otherwise estimate based on:

- prompt size
- number of retrieved memory records
- number of files inspected
- reasoning complexity

---

# 5 Metrics Analyzer Script

Create:

scripts/context_metrics_analyzer.js

Responsibilities:

1 Aggregate telemetry from task_logs.jsonl

2 Calculate:

context reduction

(avg_full_context_tokens - avg_task_packet_tokens) / avg_full_context_tokens

token reduction

estimated difference between full-context prompting and optimized prompting

latency improvement estimate

based on reduction in reasoning cycles and prompt size

cost reduction estimate

based on model usage and token reduction

3 Update:

weekly_summary.json

4 Generate suggested checkpoint data for CONTEXT_SAVINGS.md

The script must be simple and dependency-free (Node.js only).

---

# 6 Automatic Checkpoint Rules

Create a checkpoint when:

- 7 days passed since last checkpoint
- at least 20 meaningful tasks recorded
- a major optimization system changed
- the user explicitly asks for a checkpoint

Avoid excessive checkpoints.

---

# 7 Estimation Method

When estimating savings, compare:

baseline behavior (no optimization)

vs

optimized task packet context.

Context reduction factors include:

- smaller prompts
- reuse of preferences
- reuse of architecture decisions
- reduced repository scanning
- reduced repeated explanations

Token reduction includes:

- reduced prompt size
- reduced reasoning loops
- reduced model usage

Latency improvement includes:

- smaller prompts
- reduced analysis scope
- reuse of prior knowledge

Cost reduction includes:

- token reduction
- lighter model routing

---

# 8 Noise Protection

Do not record trivial tasks.

Examples of trivial tasks:

- spelling corrections
- tiny edits
- formatting only

Record tasks that meaningfully exercise reasoning or repo exploration.

---

# 9 Git Safety

If any telemetry files are created inside a Git repository:

Add the following entries to `.gitignore` if they do not exist:

.context_metrics/
CONTEXT_SAVINGS.md

Ask the user before tracking them in version control.

---

# 10 System Behavior

The system must:

- run silently in the background
- never interrupt normal coding work
- store telemetry compactly
- avoid storing conversations
- store only metrics

---

# 11 User Queries

When the user asks for:

"savings report"

Codex must:

1 read telemetry
2 estimate improvements
3 present a structured report
4 optionally suggest creating a checkpoint

---

# Success Criteria

The implementation is successful if:

- Codex can estimate context savings
- token usage reduction is trackable
- weekly checkpoints exist
- the system runs automatically
- telemetry storage remains small
