# Research Environment Conventions

These conventions apply **when doing research work** — deep research, literature reviews, paper reading/writing, replications, experiment loops, or any task using the research skills in `~/.codex/skills/`. For ordinary coding tasks, ignore them.

**论文检索后端（优先级 + 自动降级，探测结果记 provenance）**：arxiv MCP（工具：search_papers / download_paper / search_paper_text，主后端，无 key）→ alphaxiv MCP（可用时优先语义发现；401/403 即降级不重试）→ web_search / browser 兜底（降级须明示）。覆盖 arXiv，不含 PubMed/clinical，生物医学主题用 web_search 补充。

## Output locations

- Research outputs go in `outputs/`.
- Paper-style drafts go in `papers/`.
- Session logs go in `notes/`.
- The workspace-level lab notebook lives at `CHANGELOG.md`.
- Plan artifacts for long-running workflows go in `outputs/.plans/`.
- Intermediate research artifacts (drafts, per-source notes) go in `outputs/.drafts/` and `outputs/.notes/`.
- Intermediate artifacts are written to disk by subagents and read by the lead agent. They are not returned inline unless the user explicitly asks.
- Long-running workflows should treat the plan artifact as externalized working memory — keep task status and verification state there as the run evolves.

## File naming

Every research workflow that produces artifacts must derive a short **slug** from the topic (lowercase, hyphens, no filler words, ≤5 words — e.g. `cloud-sandbox-pricing`). All files in a single run use that slug as a prefix:

- Plan: `outputs/.plans/<slug>.md`
- Intermediate research: `<slug>-research-web.md`, `<slug>-research-papers.md`, etc.
- Draft: `outputs/.drafts/<slug>-draft.md`
- Cited brief: `<slug>-brief.md`
- Verification: `<slug>-verification.md`
- Final output: `outputs/<slug>.md` or `papers/<slug>.md`
- Provenance: `<slug>.provenance.md` (next to the final output)

Never use generic names like `research.md`, `draft.md`, `brief.md`, or `summary.md`. Concurrent runs must not collide.

## Workspace changelog

- `CHANGELOG.md` is a lab notebook, not release notes.
- Read `CHANGELOG.md` before resuming substantial work when it exists.
- Append concise entries after meaningful progress, failed approaches, major verification results, or new blockers.
- Each entry should identify the active slug or objective and end with the next recommended step.
- Mark verification state honestly with labels such as `verified`, `unverified`, `blocked`, or `inferred` only when they match the underlying evidence.
- Do not create or update `CHANGELOG.md` for trivial one-shot tasks.

## Provenance and verification

- Every deep-research and literature-review output must include a `.provenance.md` sidecar.
- Provenance sidecars record source accounting and verification status.
- Source verification and citation cleanup belong in the `verifier` stage, not in ad hoc edits after delivery.
- Verification passes happen before delivery when the workflow calls for them.
- If a workflow uses the words `verified`, `confirmed`, or `checked`, the underlying artifact should record what was actually checked and how.
- For quantitative or code-backed outputs, keep raw artifact paths, scripts, or logs that support the final claim. Do not rely on polished summaries alone.
- Never smooth over missing checks. Mark work as `blocked`, `unverified`, or `inferred` when that is the honest status.
- Never fabricate sources, results, figures, benchmarks, or datasets. No URL = not included.

## Delegation rules

- The lead agent plans, delegates, synthesizes, and delivers.
- Research subagents（`researcher` 证据收集 / `verifier` 引用核验 / `reviewer` 对抗审查 / `writer` 起草）：codex 无 Agent 工具，用后台 bash 起独立 `codex exec` 分身承担，提示词与材料走文件交接。
- Use subagents when the work is meaningfully decomposable; do not spawn them for trivial work.
- Prefer file-based handoffs over dumping large intermediate results back into parent context.
- The lead agent is responsible for reconciling task completion. Subagents may not silently skip assigned tasks; skipped or merged tasks must be recorded in the plan artifact.
- For critical claims, require at least one adversarial verification pass after synthesis. Fix fatal issues before delivery or surface them explicitly.

## Codex 适配说明（2026-09-30 移植）

本仓库为 codex-for-research 公开版（170 个技能，已去除 pro 专属组件）。适配口径：
- 工具名映射：web_search（检索）/ browser fetch（网页）/ arxiv MCP（论文：search_papers、download_paper、search_paper_text）
- Skill 加载：读取 ~/.codex/skills/<name>/SKILL.md 按其流程执行（codex 无显式 Skill tool，等效）
- 子代理：用后台 bash / codex exec 分身承担 researcher→verifier→reviewer 链
- 调研类任务（深度研究/文献综述/找方向/查文献）禁止绕过管线直接 web_search 拼报告——必须按 deep-research 或 literature-review 的 SKILL.md 流程执行，产物进 outputs/ 带 slug + provenance（含工具调用统计）
- 长任务（>5分钟）独立 tmux/nohup + 日志 + 完成标志（进程会随轮次死）
