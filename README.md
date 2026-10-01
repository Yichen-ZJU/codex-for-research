# Codex for Research

> **Claude Code 与 Codex CLI 双引擎共用的同一套科研技能体系**——本仓库是 [claude-for-research](https://github.com/Yichen-ZJU/claude-for-research) 的 Codex 移植版（公开版），与 Claude 版共用技能设计、研究约定与调研管线。

![engine](https://img.shields.io/badge/engine-Codex%20CLI-blue) ![skills](https://img.shields.io/badge/skills-170-green) ![license](https://img.shields.io/badge/license-MIT-yellow)

## 这是什么

把与 [claude-for-research](https://github.com/Yichen-ZJU/claude-for-research) 同源的完整科研技能体系移植到 **Codex CLI**：170 个技能（调研/实验/写作/评审全流程）+ 研究约定（AGENTS.md）+ arxiv MCP 检索后端。本公开版与 claude-for-research 保持同口径：完整能力中的团队作战与深度攻坚引擎为作者私有部署所保留，公开版专注通用科研流程（调研/实验/写作/评审）。

## 安装（可逆）

```bash
git clone https://github.com/Yichen-ZJU/codex-for-research.git && cd codex-for-research
./setup.sh install     # 自动备份现有 ~/.codex/skills 与 AGENTS.md 到 ~/.codex-research-backups/
./setup.sh uninstall   # 按 manifest 精确移除已装技能，AGENTS.md 自动恢复最近备份
```

- **可逆性**：install 前全量备份；uninstall 只删 manifest 记录的技能，不碰你自己的技能。
- arxiv MCP 注册（`scripts/register-arxiv-mcp.sh`）：幂等追加 `[mcp_servers.arxiv]` 到 `~/.codex/config.toml`，先备份。
- 前置：Codex CLI + `pip install arxiv-mcp-server`（论文检索主后端，无 key 依赖）。

## 双引擎调研规范

1. **调研类任务（深度调研/文献综述/方向扫描/选题论证）禁止绕过管线**：必须按 `deep-research` / `literature-review` 的 SKILL.md 流程执行，产物进 `outputs/` 带 slug + provenance（含工具调用统计）。冒烟级问答豁免。
2. **检索后端优先级**：arxiv MCP（`search_papers`/`download_paper`/`search_paper_text`）→ alphaxiv MCP（可用时增强；401/403 即降级不重试）→ web_search/browser 兜底（降级记 provenance）。
3. **承重声明亲核**：关键论文用 `download_paper` + `search_paper_text` 定位原文，不接受转述定承重结论。
4. **逐候选占位检索**：每个候选方向单独反向检索，覆盖最近一个月，禁"首次"式表述。
5. **子代理链**：researcher（后台 bash/codex exec 分身）→ verifier → reviewer 串行；FATAL 必修。
6. **长任务纪律**：>5 分钟作业独立 tmux/nohup + 日志 + 完成标志文件接力。
7. **双循环 orchestrator**：研究项目走 BOOTSTRAP→Gate 1（FINER）→内循环→外循环（DEEPEN/BROADEN/PIVOT/CONCLUDE）→论文总装线，protocol 先 commit 再跑。

## 与 claude-for-research 的关系

| | claude-for-research | codex-for-research（本仓库） |
|---|---|---|
| 宿主 | Claude Code | Codex CLI |
| 技能体系 | 同一套设计 | 同一套设计，工具名适配（Agent→codex exec 分身、CronCreate→ticker、alphaxiv→arxiv MCP） |
| 规模 | 95 技能 | 170 技能（含 codex 侧新增写作/学术套件） |
| 约定文件 | `~/.claude/CLAUDE.md` | `~/.codex/AGENTS.md` |

两个公开版（Claude 引擎 / Codex 引擎）= 同一套技能体系的双引擎部署。

## 致谢

技能体系熔炼自：Feynman、Orchestra AI-Research-SKILLs、Supervisor-Skills（CC-BY-4.0）、彭思达研究笔记、ARS、karpathy/autoresearch、ARIS（MIT）等，经 claude-for-research 体系演进并由社区移植到 Codex 运行时。各组件许可见原始仓库。
