# Research Environment Conventions (Codex Edition)

> Product family: **Lemvo** — one research system. Two CLI engines (Claude Code / Codex CLI). 产品族统一名 **Lemvo**。

These conventions apply when doing research work — deep research, literature reviews, paper reading, experiment loops, or any task using the research skills in `~/.codex/skills/`. For ordinary coding tasks, ignore them.

## Research skill library

Full suite migrated from the internal research stack (181 skills incl. research-orchestrator double-loop). Subagents (researcher/verifier/reviewer/writer) are executed via background bash / codex exec instances — Codex has no Agent tool.

## Paper search backend (v3.4 dual-backend)

- Primary: `arxiv` MCP server (tools: `search_papers`, `download_paper`, `search_paper_text`) — local, free, no key.
- alphaxiv MCP when available (auto-degrade on failure, do not retry).
- Fallback: web_search / browser fetch on arxiv.org — record degradation in provenance.

## Dual-engine research norms

1. Broad-scan (discovery phase) → Codex native deep research mode (multi-angle, cross-check, reverse occupy-search).
2. Deep-drill (verification phase) → deep-research pipeline (load SKILL.md → plan → researcher/verifier/reviewer → per-source citations → provenance). Load-bearing claims MUST go through this pipeline.
3. Full-text caching: load-bearing papers via download_paper full text; never settle for abstract-level.
4. Version pinning: cite arXiv version numbers; cross-report comparison checks versions first.
5. Raw evidence on disk: query terms / download lists / recompute scripts / source snapshots all committed with artifacts.
6. Failed-run discrimination: when a residual log stops at "waiting for confirmation", check whether a second successful run exists; count the latter and note the former.
7. Restraint in comparison claims: two lanes may share the same skill backend — do not claim methodology differences from surface execution paths.

## Output locations

- Research outputs → `outputs/` (slug-prefixed files, provenance sidecars).
- Intermediate → `outputs/.drafts/` and `outputs/.notes/`; plans → `outputs/.plans/`.
- Every deep-research output includes a `.provenance.md` sidecar (tool invocation counts, accepted/rejected sources, verification status).
- Never generic names (research.md, draft.md). Concurrent runs must not collide.

## Research discipline (mandatory)

- Protocol commits BEFORE data access (git history is the preregistration audit trail).
- Confirmatory vs exploratory labeling; negative results are progress.
- Sanity-check before analysis; no silent sample drops; unparsed/truncated classified honestly.
- No API keys in any repo or output.
- Long jobs (>5 min) in independent tmux/nohup with logs and completion markers; background processes die with the session.
- On blockers: write BLOCKER.md listing options — never silently skip.

## Skill loading

Read `~/.codex/skills/<name>/SKILL.md` and follow its workflow (Codex has no dedicated Skill tool; file-based loading is the equivalent). Research-type tasks (deep research / literature review / direction scouting) MUST go through the pipeline — no bypassing with raw web_search answers. Smoke-level factual queries are exempt.
