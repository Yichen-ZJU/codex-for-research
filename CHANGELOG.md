# CHANGELOG — codex-for-research

## v1.0-codex-engine（2026-09-30）

- 首个公开版：与 claude-for-research 同源的技能体系 Codex 移植（170 技能；按公开版口径去除团队作战/深度攻坚引擎及路由引用、个人 infra 组件）。
- AGENTS.md：研究约定 + Codex 适配说明（修复移植漂移：双后端文案、`~/.codex/skills` 路径、codex exec 委托、技能计数）。
- 可逆安装器 setup.sh（install/uninstall，备份+manifest 精确回退）+ arxiv MCP 幂等注册脚本。
- 论文检索后端：arxiv MCP 主（无 key）→ alphaxiv 增强（自动降级）→ web_search/browser 兜底。

## 2026-10-03 系统性修复与改进（与 claude-for-research 同批，verified）

A 队列 / B 契约 / C setup.sh+register-arxiv-mcp.sh / D 引用 / F 许可 / G 规则全部同步落地（内容与 claude 仓对应 commit 一致；E1 本仓保持 Codex 适配不变）。关键差异：setup.sh 备份唯一化+staging 原子替换+失败回滚；register-arxiv-mcp.sh 退出码语义（0 成功/3 跳过/1 失败）+写后回读验证。技能集合保持 115。未打 tag、未发 release。

## 2026-10-03 系统性修复与改进（与 claude-for-research 同批，verified）

H 队列 / I setup.sh 事务回滚+互斥锁+SIGTERM 回滚 / J shared-references 随包交付+forge 契约随包 / K rsync 白名单+远端计数 / L ARS 自检解耦 / M 日志命名+快照语义 / N AUTHORSHIP+MIT 附录 / O watchdog 加固+路径穿越拒绝+测试套件——与 claude 仓对应 commit 一致。tests/run_tests.sh 一键回归（引擎相关场景按 Codex 宿主语义执行）。已知限制节见 claude 仓 CHANGELOG（F06/F08/V04/S01/D01）。

### 已知限制（同步记录）

- F06 断点恢复协议 / F08 split 与指标来源核验 / V04 ARS 运行依赖 doctor / S01 preset 进程内 exec / D01 forge description 元数据——处置与理由同 claude-for-research 仓 CHANGELOG。

## 2026-10-03 评审语义修正：近邻存在 ≠ 否决

与 claude-for-research 同批：idea-evaluator 与 research-orchestrator 增加"近邻存在 ≠ 否决"一节（delta 声明四要件 + 决策规则），修正发现近邻即降分/绕开的隐性偏置。v1.2 增量构思的前置补丁。

## 2026-10-09 装载器修复 + 实验路由自动选择

codex 0.160.0 字段报告驱动：experiment-forge 补 description（0.160.0 必填、argument-hint 可选）；全舰队 589 个 SKILL.md 按最严 schema lint 清零（含 anti-defensive-writing-en 的 frontmatter 内嵌段修复）；orchestrator 增加可验证的实验引擎分流判据（有包/有会话→autoresearch；新课题无包→先 forge；pro 单目标→Arbor、开放方向→AutoScientists），交接显式传预算与停止条件。138.6/140.30 热修文本与上游统一。
