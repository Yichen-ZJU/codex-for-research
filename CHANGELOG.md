# CHANGELOG — codex-for-research

## v1.0-codex-engine（2026-09-30）

- 首个公开版：与 claude-for-research 同源的技能体系 Codex 移植（170 技能；按公开版口径去除团队作战/深度攻坚引擎及路由引用、个人 infra 组件）。
- AGENTS.md：研究约定 + Codex 适配说明（修复移植漂移：双后端文案、`~/.codex/skills` 路径、codex exec 委托、技能计数）。
- 可逆安装器 setup.sh（install/uninstall，备份+manifest 精确回退）+ arxiv MCP 幂等注册脚本。
- 论文检索后端：arxiv MCP 主（无 key）→ alphaxiv 增强（自动降级）→ web_search/browser 兜底。

## 2026-10-03 系统性修复与改进（与 claude-for-research 同批，verified）

A 队列 / B 契约 / C setup.sh+register-arxiv-mcp.sh / D 引用 / F 许可 / G 规则全部同步落地（内容与 claude 仓对应 commit 一致；E1 本仓保持 Codex 适配不变）。关键差异：setup.sh 备份唯一化+staging 原子替换+失败回滚；register-arxiv-mcp.sh 退出码语义（0 成功/3 跳过/1 失败）+写后回读验证。技能集合保持 115。未打 tag、未发 release。
