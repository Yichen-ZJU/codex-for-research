#!/usr/bin/env bash
# codex-for-research 可逆安装器
# 用法: ./setup.sh install   （备份现有 ~/.codex/skills 与 AGENTS.md 后安装，可一键回退）
#       ./setup.sh uninstall （按 manifest 移除已装技能，恢复备份）
#       ./setup.sh -h|--help
#
# 设计要点：C1 参数先于写入; C2 备份目录唯一（时间戳+PID，存在即拒）;
# C3 staging+原子替换、失败自动恢复; C4 MCP 注册如实报告、部分失败退出码非 0。
set -euo pipefail
CODEX_DIR="$HOME/.codex"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="$HOME/.codex-research-backups"
MANIFEST="$CODEX_DIR/.codex-for-research-manifest"

usage() {
  cat <<'EOF'
用法: ./setup.sh install | uninstall | -h|--help

  install    备份现有 ~/.codex/skills 与 AGENTS.md 后安装（可回退）
  uninstall  按 manifest 移除已装技能，AGENTS.md 恢复最近备份
EOF
}

do_install() {
  # C2: 唯一备份目录
  local bak="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)-$$"
  if [ -e "$bak" ]; then
    echo "错误: 备份目录已存在（秒级+PID 碰撞）: $bak —— 拒绝覆盖旧备份。" >&2
    exit 1
  fi
  mkdir -p "$bak"

  # C3: 失败自动恢复
  restore_all() {
    echo "==> 安装失败，正在从备份恢复 ..."
    [ -d "$bak/skills" ] && cp -r "$bak/skills/." "$CODEX_DIR/skills/" 2>/dev/null || true
    [ -f "$bak/AGENTS.md" ] && cp "$bak/AGENTS.md" "$CODEX_DIR/AGENTS.md" || true
    echo "==> 已恢复（备份保留在 $bak）"
  }
  trap restore_all ERR

  # 1) 备份原版
  if [ -d "$CODEX_DIR/skills" ]; then cp -r "$CODEX_DIR/skills" "$bak/skills"; fi
  if [ -f "$CODEX_DIR/AGENTS.md" ]; then cp "$CODEX_DIR/AGENTS.md" "$bak/AGENTS.md"; fi
  echo "✓ 原版已备份: $bak"

  # 2) 安装技能（C3: staging -> 原子替换；记录 manifest）
  mkdir -p "$CODEX_DIR/skills"
  : > "$MANIFEST"
  local n=0
  for s in "$REPO_DIR/skills"/*/; do
    name="$(basename "$s")"
    local stage="$CODEX_DIR/skills/.staging-$name-$$"
    rm -rf "$stage"
    cp -r "$s" "$stage"
    rm -rf "$CODEX_DIR/skills/$name"
    mv -T "$stage" "$CODEX_DIR/skills/$name"
    echo "$name" >> "$MANIFEST"; n=$((n+1))
  done

  # 3) AGENTS.md
  local stage_md="$CODEX_DIR/AGENTS.md.new-$$"
  cp "$REPO_DIR/AGENTS.md" "$stage_md"
  mv -T "$stage_md" "$CODEX_DIR/AGENTS.md"

  trap - ERR

  # 4) arxiv MCP 注册（C4: 如实报告，失败退出码非 0）
  local mcp_status=ok
  set +e
  bash "$REPO_DIR/scripts/register-arxiv-mcp.sh"
  local rc=$?
  set -e
  case $rc in
    0) mcp_status=ok ;;
    3) mcp_status=skipped ;;
    *) mcp_status=failed ;;
  esac

  echo
  echo "==> 安装结果汇总"
  echo "    skills:     ok ($n 个)"
  echo "    AGENTS.md:  ok"
  echo "    MCP arxiv:  $mcp_status"
  echo "    备份:       $bak"
  echo "    回退: ./setup.sh uninstall"
  if [ "$mcp_status" = failed ]; then
    echo "⚠️  arxiv MCP 注册失败（见上方输出），退出码 1。" >&2
    exit 1
  fi
}

do_uninstall() {
  if [ ! -f "$MANIFEST" ]; then echo "未找到 manifest（非本安装器安装），拒绝盲删。"; exit 1; fi
  local n=0
  while read -r name; do
    [ -n "$name" ] && rm -rf "$CODEX_DIR/skills/$name" && n=$((n+1))
  done < "$MANIFEST"
  rm -f "$MANIFEST"
  # AGENTS.md 恢复最近备份
  local last; last="$(ls -1d "$BACKUP_ROOT"/* 2>/dev/null | sort | tail -1)"
  if [ -n "$last" ] && [ -f "$last/AGENTS.md" ]; then cp "$last/AGENTS.md" "$CODEX_DIR/AGENTS.md"; echo "✓ AGENTS.md 已从 $last 恢复"; fi
  echo "✓ 已卸载 $n 个技能。备份保留在 $BACKUP_ROOT（手动删除以彻底清理）"
}

case "${1:-}" in
  install)   do_install ;;
  uninstall) do_uninstall ;;
  -h|--help) usage ;;
  *) echo "错误: 未知参数 '${1:-}'" >&2; usage >&2; exit 2 ;;
esac
