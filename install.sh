#!/bin/sh
# claude-kit installer — 把 user/ 底下的檔案 symlink 進 ~/.claude/
# idempotent：已是正確 symlink 則跳過；既有實體檔先備份成 .bak 再連結。
set -eu

KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"

link_tree() {
  src_root="$1"; dst_root="$2"
  find "$src_root" -type f | while read -r src; do
    rel="${src#"$src_root"/}"
    dst="$dst_root/$rel"
    mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
      echo "ok      $dst"
      continue
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
      mv "$dst" "$dst.bak"
      echo "backup  $dst -> $dst.bak"
    fi
    ln -s "$src" "$dst"
    echo "link    $dst -> $src"
  done
}

link_tree "$KIT_DIR/user/rules" "$CLAUDE_DIR/rules"
link_tree "$KIT_DIR/user/refs"  "$CLAUDE_DIR/refs"

echo ""
echo "done. rules 於下個 claude session 自動載入（所有專案）；refs 不自動載入，由 rules 按路徑指向、按需讀取。"
