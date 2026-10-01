#!/usr/bin/env bash
# codex-for-research 可逆安装器
# 用法: ./setup.sh install   （备份现有 ~/.codex/skills 与 AGENTS.md 后安装，可一键回退）
#       ./setup.sh uninstall （按 manifest 移除已装技能，恢复备份）
set -euo pipefail
CODEX_DIR="$HOME/.codex"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="$HOME/.codex-research-backups"
MANIFEST="$CODEX_DIR/.codex-for-research-manifest"

do_install() {
  local ts; ts="$(date +%Y%m%d-%H%M%S)"
  local bak="$BACKUP_ROOT/$ts"
  mkdir -p "$bak"
  # 1) 备份原版
  if [ -d "$CODEX_DIR/skills" ]; then cp -r "$CODEX_DIR/skills" "$bak/skills"; fi
  if [ -f "$CODEX_DIR/AGENTS.md" ]; then cp "$CODEX_DIR/AGENTS.md" "$bak/AGENTS.md"; fi
  echo "✓ 原版已备份: $bak"
  # 2) 安装技能（同名覆盖，记录 manifest）
  mkdir -p "$CODEX_DIR/skills"
  : > "$MANIFEST"
  local n=0
  for s in "$REPO_DIR/skills"/*/; do
    name="$(basename "$s")"
    rm -rf "$CODEX_DIR/skills/$name"
    cp -r "$s" "$CODEX_DIR/skills/$name"
    echo "$name" >> "$MANIFEST"; n=$((n+1))
  done
  # 3) AGENTS.md
  cp "$REPO_DIR/AGENTS.md" "$CODEX_DIR/AGENTS.md"
  # 4) arxiv MCP 注册
  bash "$REPO_DIR/scripts/register-arxiv-mcp.sh" || echo "（arxiv MCP 注册跳过/失败，见上）"
  echo "✓ 安装完成: $n 个技能 + AGENTS.md。回退: ./setup.sh uninstall 或从 $bak 手动恢复"
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
  *) echo "用法: ./setup.sh install | uninstall"; exit 1 ;;
esac
