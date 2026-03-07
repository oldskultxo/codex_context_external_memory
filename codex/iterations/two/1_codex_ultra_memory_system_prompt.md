# Codex Ultra Memory System — Single Prompt for Codex

Use this prompt directly in Codex. It is designed to replace or supersede the current `codex_context` approach with a more efficient system optimized for context savings first, token savings second, and speed third, while preserving safe fallback to normal Codex behavior.

---

## PROMPT START

You are implementing a **persistent, self-booting, low-token, high-speed external memory and delta-context system for Codex**.

The primary goal is to make Codex significantly more efficient over time by minimizing:
1. active context usage
2. total token usage beyond context
3. latency / time-to-first-useful-action

Priority order is strict:
1. **maximize context savings** with safe fallback to normal behavior
2. **reduce total token usage**
3. **improve speed**

This system must work across sessions and chats, must initialize automatically at the beginning of every new Codex session, and must continuously learn from project evolution, user preferences, and validated technical outcomes.

The new system may either fully replace `codex_context` or absorb and optimize it. Choose the option that best achieves the goals above. In practice, prefer **replacement with migration** unless keeping specific pieces of `codex_context` is clearly more efficient.

---

## NON-NEGOTIABLE REQUIREMENTS

### 1) Auto-initialization on every new Codex session
The system must be designed so Codex automatically initializes it at the beginning of every new session or chat, **without the user having to ask for it**.

The boot process must be lightweight and deterministic.

### 2) Persistent user preferences
The system must store user preferences that are relevant for future work and silently apply them by default in future sessions.

These preferences must:
- survive across sessions
- be queryable cheaply
- be applied automatically
- be overridable when the user explicitly asks otherwise in the current turn

### 3) Continuous learning updates
The system must be updated whenever there are meaningful learnings in any of these categories:
- functional learnings about the project
- technical learnings
- structural / architectural learnings
- stable debugging patterns
- repeated workflow preferences from the user

Update rules must prefer **compact incremental updates** over verbose summaries.

### 4) Fallback to normal Codex behavior
If the memory system is missing relevant knowledge, stale, uncertain, or contradicted by the repository/runtime/current request, Codex must fall back gracefully to normal repository inspection, testing, reasoning, and standard task execution.

### 5) Automatic model selection
The system may automatically switch models depending on task complexity.

### 6) Permission to create files anywhere
The implementation may add files or directories anywhere, including inside project directories.

If anything is added under Git version control and should not be committed, the implementation must automatically update `.gitignore` appropriately.

### 7) Migration from codex_context
If `codex_context` exists, all relevant learnings already captured there must be migrated into the new system before removal or archival.

No valuable learning should be lost.

---

## HIGH-LEVEL STRATEGY

Implement a system called **Codex Ultra Memory System (CUMS)** with a built-in **Delta Context Engine**.

This system should not store raw conversation history as its primary memory. Instead, it should store **compressed operational knowledge** and only reconstruct the minimum context needed for the current task.

The architecture should follow this principle:

> Do not retrieve “everything known”. Retrieve only the smallest validated slice of knowledge needed to solve the current task safely.

The design must optimize for:
- tiny boot cost
- tiny retrieval cost
- high reuse of validated project knowledge
- minimal duplication
- minimal stale memory
- minimal prompt bloat

---

## REQUIRED OUTCOME

Build a production-usable external memory subsystem with:
- automatic boot on each new session
- compact knowledge storage
- delta retrieval for tasks
- memory updates after validated learnings
- migration tooling from `codex_context`
- cheap CLI access for Codex
- maintenance scripts
- optional model routing rules
- automatic `.gitignore` hygiene for generated/memory artifacts when appropriate

The final result must be directly usable by Codex inside the repository without requiring the user to remember a startup phrase.

---

## CORE DESIGN

# 1. Replace transcript-style memory with compressed operational memory
Store knowledge in normalized structured records rather than long natural-language notes whenever possible.

Use a hybrid model:
- **indexes and records in JSON / JSONL** for cheap machine lookup
- **short markdown notes** only for higher-value synthesized learnings that benefit from prose
- **small generated views** for fast boot

Knowledge should be categorized into these types:
- `user_preference`
- `project_fact`
- `architecture_decision`
- `workflow_rule`
- `debugging_pattern`
- `failure_mode`
- `validation_recipe`
- `task_pattern`
- `naming_convention`
- `constraint`
- `open_question`
- `staleness_warning`

Every record should be minimal, explicit, and queryable.

### Example record shape
```json
{
  "id": "pref.output.markdown_downloadable",
  "type": "user_preference",
  "scope": "global",
  "project": null,
  "tags": ["output", "format"],
  "value": "Prefer downloadable .md files for prompts/specs when requested.",
  "priority": "high",
  "confidence": "high",
  "last_verified": "2026-03-07",
  "source": "migrated_from_codex_context",
  "override_rule": "explicit_user_instruction_wins"
}
```

# 2. Add a Delta Context Engine
The system must not inject a whole project summary into context for every task.

Instead, implement a delta strategy:
- infer task type
- retrieve only the minimal relevant memory slice
- compare against task-specific repository area
- construct a tiny “working context packet”
- use that packet first
- expand only if necessary

The **working context packet** should contain only:
- relevant preferences
- relevant project constraints
- relevant architecture decisions
- relevant debugging patterns / validation recipes
- only the specific repo paths likely needed

This packet is ephemeral and task-scoped.

# 3. Optimize for tiny boot
At session start, Codex should not read the full memory store.

Instead, boot should only read a tiny precomputed file such as:
- `boot/boot_summary.json`
- `boot/user_defaults.json`
- `boot/project_registry.json`
- `boot/model_routing.json`

These files must be very small and derived from the larger memory store.

# 4. Retrieval before reasoning
For each task, Codex must:
1. classify the task
2. retrieve the smallest relevant memory slice
3. inspect only the most relevant code paths
4. reason / test / modify
5. update memory only if something meaningful was learned

# 5. Write memory only from validated outcomes
Do not store speculation.
Do not store every conversation.
Do not store redundant summaries.
Store only durable, reusable, validated learnings.

---

## DIRECTORY / FILE LAYOUT

Choose a root such as one of these:
- `.codex_memory/`
- `.codex_ultra_memory/`
- `tools/codex_memory/`

Pick the location that best balances portability, discoverability, and low risk of polluting project code.

Recommended structure:

```text
.codex_ultra_memory/
  README.md
  protocol.md
  boot/
    boot_summary.json
    user_defaults.json
    project_registry.json
    model_routing.json
  store/
    global_records.jsonl
    user_preferences.jsonl
    project_records/
      <project_key>.jsonl
    notes/
      common/
      projects/
        <project_key>/
  indexes/
    by_tag.json
    by_type.json
    by_project.json
    by_path.json
    by_symptom.json
    by_preference.json
    recent_learnings.json
  delta/
    task_packet_schema.json
    last_packets/
  migration/
    codex_context_migration_report.md
    codex_context_import_map.json
  logs/
    change_journal.md
    maintenance_log.md
  scripts/
    boot.py
    query.py
    packet.py
    update_memory.py
    consolidate.py
    detect_stale.py
    migrate_codex_context.py
    model_route.py
    ensure_gitignore.py
    prune.py
    touch.py
    note_new.py
  bin/
    ctx
    ctx-boot
    ctx-query
    ctx-packet
    ctx-update
    ctx-route
```

Implementation language should be the simplest reliable option already comfortable in the repo environment. Prefer Python for the scripts unless there is a strong repository-level reason not to.

---

## BOOT SYSTEM

Implement a boot mechanism that Codex can invoke automatically at session start.

The boot flow must:
1. detect repository / project identity
2. load tiny boot files only
3. load user defaults
4. load model routing rules
5. prepare a session state file if useful
6. not load the full store unless needed

The boot result should give Codex the equivalent of:
- who the user is from a workflow perspective
- what this repo/project is
- what defaults must be respected
- where to query for more
- how to route model choice

### Required boot outputs
Create a small boot summary with fields like:
```json
{
  "version": 1,
  "default_behavior": {
    "memory_first": true,
    "fallback_to_normal_codex": true,
    "explicit_user_override_wins": true
  },
  "preferred_output_patterns": [...],
  "active_projects": [...],
  "model_routing_profile": "default",
  "last_maintenance": "2026-03-07"
}
```

### Auto-init behavior
Implement the system so Codex can reliably execute the equivalent of `ctx-boot` first in each new session.

If there is any existing session bootstrap convention in the repo, integrate with it.
If not, create a lightweight clearly documented bootstrap path and make the README/protocol explicit about first-step usage.

The implementation must be optimized so the boot step is cheap enough that always doing it is rational.

---

## QUERY / RETRIEVAL SYSTEM

Implement fast query tools.

### Required CLI behavior
Examples:
- `ctx-query prefs`
- `ctx-query architecture editor import pipeline`
- `ctx-query symptom "cursor not changing on draggable elements"`
- `ctx-packet --task "add import menu for Ink"`
- `ctx-route --task "rename two labels in UI"`

### Retrieval rules
Ranking must prefer, in order:
1. explicit user preference records relevant to the task
2. project-specific learnings over global learnings
3. narrow validated records over broad summaries
4. recent verified learnings over old ones
5. architecture decisions / constraints over generic patterns
6. validation recipes that reduce repo inspection cost

### Task packet generation
`packet.py` must generate a tiny task-scoped JSON packet.

Example shape:
```json
{
  "task_type": "feature_implementation",
  "project": "iewriter",
  "user_preferences": [...],
  "constraints": [...],
  "architecture_decisions": [...],
  "relevant_paths": [
    "iewriter/...",
    "shared/..."
  ],
  "relevant_patterns": [...],
  "validation_recipes": [...],
  "model_suggestion": "medium"
}
```

This packet should be the main context bridge between memory and active task execution.

---

## USER PREFERENCES SYSTEM

Persist user preferences as first-class records.

Examples of preference categories:
- output formats
- coding style preferences
- architectural defaults
- project-specific conventions
- language preferences
- workflow preferences
- tolerance for added dependencies
- naming style
- prompt style

Rules:
- preferences are applied silently by default
- explicit user instructions in the current turn override them
- preferences should only be stored if durable and future-useful
- preferences must be queryable with near-zero overhead

Implement both:
- a canonical store (`user_preferences.jsonl`)
- a tiny derived boot view (`boot/user_defaults.json`)

---

## MODEL ROUTING

Implement simple automatic model routing rules.

The purpose is not to overcomplicate routing. The purpose is to avoid using heavy reasoning when not needed.

Suggested levels:
- `light`: trivial edits, naming, formatting, small localized tasks
- `medium`: standard implementation or debugging in a bounded area
- `heavy`: architectural redesign, large migrations, deep debugging, cross-system changes

Routing should use signals like:
- number of files likely touched
- ambiguity level
- expected reasoning depth
- whether debugging spans multiple layers
- whether the task requires synthesis from multiple prior learnings

Store routing rules in `boot/model_routing.json`.

Provide a script that can output a model suggestion for a task.

Keep it rule-based and transparent.

---

## MEMORY UPDATE RULES

After meaningful work, update memory only if the result produced a reusable durable learning.

A learning is worth storing when it is one or more of:
- likely to recur
- likely to save future context
- likely to save future debugging loops
- architectural and stable
- a durable user preference
- a stable validation shortcut
- a naming or structure convention that future work depends on

Do **not** store:
- raw logs unless distilled
- temporary debugging branches
- speculative guesses
- long transcripts
- trivial one-off edits with no reusable value

### Update pipeline
1. extract candidate learning
2. classify its type
3. decide project/global scope
4. deduplicate against existing records
5. store compactly
6. update derived indexes
7. update boot summary only if needed
8. log the change in `logs/change_journal.md`

---

## STALENESS / TRUST MANAGEMENT

Memory must never become a source of false confidence.

Implement trust controls:
- every record has `last_verified`
- every record has `confidence`
- records can be marked `stale_suspected`
- contradictions discovered in code/tests/runtime should reduce trust
- stale records should remain queryable but de-ranked

Provide a maintenance script to detect:
- very old records
- duplicate records
- conflicting records
- records referencing paths that no longer exist

---

## MIGRATION FROM `codex_context`

This is mandatory if `codex_context` exists.

### Migration steps
1. detect whether `codex_context` exists
2. inspect its structure and contents
3. extract all meaningful learnings
4. classify them into the new normalized schema
5. deduplicate and merge with any existing new-store records
6. write a migration report
7. only then archive or remove `codex_context`

### Rules for deciding replacement vs retention
Prefer **full replacement** if `codex_context` is:
- prompt-heavy
- note-heavy without strong retrieval structure
- optimized for human reading more than cheap machine retrieval
- not delta-oriented
- not boot-optimized

Retain only if there are components that are already efficient and reusable.

### Required outputs
- `migration/codex_context_migration_report.md`
- `migration/codex_context_import_map.json`

### Post-migration action
Unless there is a strong reason to keep `codex_context`, archive or remove it.
If archived, place it in a clearly named location and exclude it from default retrieval.
If removed, ensure all useful learnings are already imported.

---

## GITIGNORE HYGIENE

If the implementation adds generated files, caches, temporary packets, session state, or maintenance artifacts under tracked directories, ensure `.gitignore` is updated automatically when appropriate.

Create a script such as `ensure_gitignore.py` that:
- detects generated / local-only artifacts
- adds missing ignore entries idempotently
- avoids ignoring source files that should remain versioned

Be conservative and explicit.

---

## IMPLEMENTATION PRINCIPLES

- optimize for simplicity and robustness over cleverness
- optimize for low read cost over rich prose
- optimize for tiny session boot over exhaustive preload
- optimize for selective retrieval over giant summary files
- optimize for durable knowledge over chat history
- prefer append-friendly stores plus derived indexes
- prefer deterministic scripts
- avoid dependency bloat unless clearly justified

---

## WHAT TO BUILD

Implement all of the following:

1. The memory root directory and documented structure
2. Boot files and `boot.py`
3. Query CLI and packet-generation CLI
4. Update-memory pipeline
5. Deduplication / consolidation logic
6. Staleness detection
7. Model routing logic
8. Migration tooling from `codex_context`
9. `.gitignore` maintenance script
10. Clear README and protocol docs
11. Any small helper scripts needed for practical usage

The system should be immediately usable by Codex after implementation.

---

## README REQUIREMENTS

The generated README must explain:
- what the system is
- why it exists
- boot process
- retrieval flow
- delta packet concept
- update rules
- migration behavior
- how user preferences are handled
- how explicit user overrides work
- how model routing works
- what gets stored vs what does not
- maintenance commands

---

## PROTOCOL REQUIREMENTS

The generated protocol must state the runtime behavior Codex should follow:

1. boot first
2. apply user defaults silently
3. retrieve small relevant memory slice
4. generate tiny task packet
5. inspect only relevant repo area
6. execute task normally if memory is missing/stale/insufficient
7. update memory after validated reusable learnings
8. respect explicit user overrides over stored preferences

---

## ACCEPTANCE CRITERIA

The implementation is only complete if all of the following are true:

1. A new Codex session can initialize the system cheaply and predictably
2. User preferences persist and are auto-applied in future sessions
3. Explicit user instructions override stored preferences
4. Memory lookup happens before deep repo analysis
5. The task packet / delta context flow exists and is operational
6. The system stores compact reusable knowledge rather than transcript-like memory
7. `codex_context` learnings are migrated with no meaningful loss
8. `codex_context` is either safely archived or safely removed after migration
9. Generated/local artifacts are handled with `.gitignore` when appropriate
10. The system degrades gracefully to normal Codex behavior whenever memory is insufficient
11. The implementation is documented and maintainable

---

## DELIVERABLES EXPECTED FROM THE IMPLEMENTATION

At the end, produce:
1. the implemented file/directory structure
2. a short summary of architecture decisions
3. the migration outcome for `codex_context`
4. the boot command / entry point
5. examples of query usage
6. examples of packet generation
7. examples of preference storage and override behavior
8. examples of model routing
9. any `.gitignore` updates made

---

## EXECUTION STYLE

Do the work directly.
Do not just describe the plan.
Create or modify files as needed.
Prefer replacement-with-migration over trying to preserve an inefficient old system.
Be aggressive about optimization, but conservative about correctness.
Keep the system cheap, compact, and maintainable.

## PROMPT END

---

## Optional note for the human operator

If Codex asks itself whether to keep `codex_context` or replace it, the correct default is:

**Replace it with the new system after full migration of valuable learnings, unless a specific component of `codex_context` is already structurally superior for low-cost retrieval.**
