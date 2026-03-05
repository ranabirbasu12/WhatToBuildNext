# Nexus — Project State

## Architecture
Nexus is a multi-agent orchestration system running as Claude Code skills.
Claude Code acts as conductor, dispatching to Codex CLI for execution.

## Services
- Claude Code (Opus 4.6): Orchestrator, planner, reviewer, MCP-connected workflows
- Codex CLI (gpt-5.3-codex): Worker, sub-conductor, code auditor

## Recent Decisions
- 2026-03-05: Chose Claude Code extension approach over standalone CLI
- 2026-03-05: Code-first scope, extensible architecture
- 2026-03-05: Inspired by Metaswarm's execution loop and knowledge base, but kept lightweight

## Known Issues
None yet — initial build.
