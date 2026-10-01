#!/usr/bin/env bash
# 在 ~/.codex/config.toml 幂等注册 arxiv MCP server（备份后操作）
set -euo pipefail
CFG="$HOME/.codex/config.toml"
SERVER_BIN="${ARXIV_MCP_SERVER:-$HOME/.local/bin/arxiv-mcp-server}"

if [ ! -f "$CFG" ]; then echo "未找到 $CFG，跳过（codex 未配置？）"; exit 0; fi
if grep -q '^\[mcp_servers\.arxiv\]' "$CFG"; then echo "arxiv MCP 已注册，跳过"; exit 0; fi
if [ ! -x "$SERVER_BIN" ]; then echo "未找到 $SERVER_BIN。安装: pip install arxiv-mcp-server"; exit 0; fi

cp "$CFG" "$CFG.bak.$(date +%Y%m%d-%H%M%S)"
cat >> "$CFG" << EOF

[mcp_servers.arxiv]
command = "$SERVER_BIN"
args = []
EOF
echo "✓ arxiv MCP 已注册到 $CFG（原文件已备份）"
