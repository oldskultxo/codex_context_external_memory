#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "fileutils"
require "pathname"
require "time"

SCRIPT_DIR = File.expand_path(__dir__).freeze
DEFAULT_ENGINE_REPO = File.expand_path("..", SCRIPT_DIR).freeze
HOME_DIR = Dir.home.freeze
PROJECTS_DIR = File.expand_path(ENV.fetch("CODEX_PROJECTS_DIR", File.join(HOME_DIR, "projects"))).freeze
ENGINE_REPO = File.expand_path(ENV.fetch("CODEX_ENGINE_REPO", DEFAULT_ENGINE_REPO)).freeze
ENGINE_STATE = File.join(ENGINE_REPO, ".codex_context_engine", "state.json").freeze
PROJECTS_INDEX = File.join(ENGINE_REPO, ".codex_global_metrics", "projects_index.json").freeze
TIMESTAMP = Time.now.utc.iso8601
AGENTS_BEGIN = "<!-- CODEX_CONTEXT_ENGINE:BEGIN -->".freeze
AGENTS_END = "<!-- CODEX_CONTEXT_ENGINE:END -->".freeze
LEGACY_ENGINE_PATH = "/Users/santisantamaria/Documents/projects/codex_context".freeze

def git_repos
  Dir.glob(File.join(PROJECTS_DIR, "**", ".git"))
    .select { |path| File.directory?(path) }
    .map { |path| File.dirname(path) }
    .reject { |path| File.expand_path(path) == LEGACY_ENGINE_PATH }
    .uniq
    .sort
end

def engine_iteration
  JSON.parse(File.read(ENGINE_STATE)).fetch("installed_iteration")
end

def engine_block(repo_path)
  <<~MARKDOWN
    #{AGENTS_BEGIN}
    ## Codex Context Engine

    This repository uses `codex_context_engine` in cross-project mode.

    - Initialize the integration by reading [.codex_context_engine/state.json](#{repo_path}/.codex_context_engine/state.json).
    - Then read the shared engine state at [#{ENGINE_STATE}](#{ENGINE_STATE}).
    - Treat the shared engine repository at `#{ENGINE_REPO}` as the authoritative storage for memory, planner outputs, graph data, cost rules, and telemetry.
    - Use the shared layers `.codex_memory/`, `.codex_planner/`, `.codex_task_memory/`, `.codex_failure_memory/`, `.codex_memory_graph/`, `.codex_cost/`, `.context_metrics/`, and `.codex_global_metrics/`.
    - Resolve a task type before retrieval when possible and fall back to `general` when classification is weak.
    - Use graph expansion only in a bounded, budget-aware way.
    - Do not create duplicate repository-local memory stores unless a migration away from cross-project mode is explicitly requested.
    - Preserve existing global metrics, telemetry, memory, and failure history during maintenance.
    #{AGENTS_END}
  MARKDOWN
end

def managed_agents_content(repo_path)
  <<~MARKDOWN
    # Codex Context Engine Runtime Policy

    This repository uses `codex_context_engine` in cross-project mode.

    #{engine_block(repo_path)}
  MARKDOWN
end

def state_payload(repo_path, installed_iteration)
  {
    "engine_id" => "codex_context_engine",
    "project_name" => File.basename(repo_path),
    "repo_path" => repo_path,
    "installed_iteration" => installed_iteration,
    "integration_mode" => "cross_project",
    "engine_repo_path" => ENGINE_REPO,
    "shared_state_path" => ENGINE_STATE,
    "shared_layers" => {
      "memory_dir" => File.join(ENGINE_REPO, ".codex_memory"),
      "planner_dir" => File.join(ENGINE_REPO, ".codex_planner"),
      "task_memory_dir" => File.join(ENGINE_REPO, ".codex_task_memory"),
      "failure_memory_dir" => File.join(ENGINE_REPO, ".codex_failure_memory"),
      "memory_graph_dir" => File.join(ENGINE_REPO, ".codex_memory_graph"),
      "cost_dir" => File.join(ENGINE_REPO, ".codex_cost"),
      "telemetry_dir" => File.join(ENGINE_REPO, ".context_metrics"),
      "global_metrics_dir" => File.join(ENGINE_REPO, ".codex_global_metrics")
    },
    "local_runtime_policy" => "AGENTS.md",
    "registered_in_global_metrics" => true,
    "last_integrated_at" => TIMESTAMP,
    "notes" => [
      "This repository consumes a shared codex_context_engine installation.",
      "Repository-local state is limited to integration metadata and runtime policy.",
      "Do not create duplicate local memory layers unless cross-project mode is explicitly removed."
    ]
  }
end

def write_json(path, payload)
  FileUtils.mkdir_p(File.dirname(path))
  File.write(path, JSON.pretty_generate(payload) + "\n")
end

def strip_legacy_codex_context_sections(content)
  cleaned = content.dup
  cleaned.gsub!(/^## External Memory Required.*?(?=^## |\z)/m, "")
  cleaned.gsub!(/^## Global Metrics Compatibility.*?(?=^## |\z)/m, "")
  cleaned = cleaned.lines.reject do |line|
    line.include?(LEGACY_ENGINE_PATH) || (line.match?(/\bcodex_context\b/) && !line.include?("codex_context_engine"))
  end.join
  cleaned.gsub!(/\n{3,}/, "\n\n")
  cleaned.strip
end

def upsert_agents(repo_path)
  agents_path = File.join(repo_path, "AGENTS.md")
  block = engine_block(repo_path).strip

  unless File.exist?(agents_path)
    File.write(agents_path, managed_agents_content(repo_path))
    return :created
  end

  content = File.read(agents_path)
  content = strip_legacy_codex_context_sections(content) unless content.include?(AGENTS_BEGIN)
  replacement = "#{block}\n"

  updated =
    if content.include?(AGENTS_BEGIN) && content.include?(AGENTS_END)
      content.sub(/#{Regexp.escape(AGENTS_BEGIN)}.*?#{Regexp.escape(AGENTS_END)}\n?/m, replacement)
    elsif content.include?("codex_context_engine")
      content
    else
      "#{content.rstrip}\n\n#{replacement}"
    end

  return :unchanged if updated == content

  File.write(agents_path, updated)
  :updated
end

def install_repo(repo_path, installed_iteration)
  if File.expand_path(repo_path) == ENGINE_REPO
    return {
      repo_path: repo_path,
      created_agents: false,
      updated_agents: false,
      updated_state: false,
      skipped_engine_repo: true
    }
  end

  state_path = File.join(repo_path, ".codex_context_engine", "state.json")
  agents_result = upsert_agents(repo_path)
  payload = state_payload(repo_path, installed_iteration)
  updated_state = false

  if !File.exist?(state_path) || File.read(state_path) != JSON.pretty_generate(payload) + "\n"
    write_json(state_path, payload)
    updated_state = true
  end

  {
    repo_path: repo_path,
    created_agents: agents_result == :created,
    updated_agents: agents_result == :updated,
    updated_state: updated_state
  }
end

def update_projects_index(repos, installed_iteration)
  existing = File.exist?(PROJECTS_INDEX) ? JSON.parse(File.read(PROJECTS_INDEX)) : { "projects" => [] }
  projects = existing.fetch("projects", [])
  by_path = projects.each_with_object({}) do |entry, acc|
    normalized_key = entry["repo_path"] == "." ? ENGINE_REPO : entry["repo_path"]
    next if File.expand_path(normalized_key) == LEGACY_ENGINE_PATH
    acc[normalized_key] = entry.merge("repo_path" => entry["repo_path"])
  end

  repos.each do |repo_path|
    by_path[repo_path] = {
      "name" => File.basename(repo_path),
      "repo_path" => repo_path == ENGINE_REPO ? "." : repo_path,
      "telemetry_dir" => ".context_metrics/",
      "memory_dir" => ".codex_memory/",
      "installed_iteration" => installed_iteration,
      "last_seen_at" => TIMESTAMP
    }
  end

  normalized = by_path.values.sort_by do |entry|
    entry["repo_path"] == "." ? "" : entry["repo_path"]
  end

  write_json(PROJECTS_INDEX, { "projects" => normalized })
end

abort("Projects directory not found: #{PROJECTS_DIR}") unless Dir.exist?(PROJECTS_DIR)
abort("Engine state not found: #{ENGINE_STATE}") unless File.exist?(ENGINE_STATE)

installed_iteration = engine_iteration
repos = git_repos
results = repos.map { |repo_path| install_repo(repo_path, installed_iteration) }
update_projects_index(repos, installed_iteration)

puts JSON.pretty_generate(
  {
    scanned_repositories: repos.size,
    created_agents: results.count { |result| result[:created_agents] },
    updated_agents: results.count { |result| result[:updated_agents] },
    updated_state_files: results.count { |result| result[:updated_state] },
    projects_dir: PROJECTS_DIR,
    engine_repo: ENGINE_REPO
  }
)
