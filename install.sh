#!/bin/sh
# hum installer — 在当前目录（一个已存在的空 Obsidian vault）铺 hum 骨架
#
# 用法：cd 到你的空 vault，然后：
#   curl -fsSL https://cdn.jsdelivr.net/gh/novaez/hum@main/install.sh | sh
#
# 平台：macOS（sed -i '' 写法）
set -e

BASE="https://cdn.jsdelivr.net/gh/novaez/hum@main/skeleton"

# ------------------------------------------------------------
# 1. 冲突检测
# ------------------------------------------------------------
if [ -f "README.md" ] || [ -f "AGENTS.md" ]; then
  echo "✗ 当前目录已有 README.md 或 AGENTS.md，先移走或清理再跑"
  exit 1
fi

# ------------------------------------------------------------
# 2. 建 6 个目录 + .claude/commands
# ------------------------------------------------------------
mkdir -p \
  "10 Inbox 📥" \
  "11 Journal 📓" \
  "20 Wiki 📖" \
  "21 Garden 🌱" \
  "30 Projects 🎯" \
  "31 Areas 🔄" \
  ".claude/commands"

# ------------------------------------------------------------
# 3. 下载文件（硬编码列表）
# ------------------------------------------------------------
curl -fsSL "$BASE/AGENTS.md" -o "AGENTS.md"
curl -fsSL "$BASE/README.md" -o "README.md"
curl -fsSL "$BASE/.claude/commands/compile.md" -o ".claude/commands/compile.md"
curl -fsSL "$BASE/.claude/commands/lint.md" -o ".claude/commands/lint.md"

# ------------------------------------------------------------
# 4. 建 symlink：CLAUDE.md / GEMINI.md → AGENTS.md
# ------------------------------------------------------------
ln -s AGENTS.md CLAUDE.md
ln -s AGENTS.md GEMINI.md

# ------------------------------------------------------------
# 5. 替换 README 里的占位符和相对图片路径
# ------------------------------------------------------------
VAULT_NAME="$(basename "$(pwd)")"

# {{VAULT_NAME}} → 当前目录名
sed -i '' "s/{{VAULT_NAME}}/${VAULT_NAME}/g" README.md

# images/xxx.svg → CDN URL（朋友 vault 里没有 images/ 子目录，走 jsdelivr）
sed -i '' "s|(images/|(https://cdn.jsdelivr.net/gh/novaez/hum@main/skeleton/images/|g" README.md

# ------------------------------------------------------------
# 6. 打印下一步
# ------------------------------------------------------------
cat << 'EOF'

✓ hum 骨架已铺到当前目录

接下来：
  1. 刷新 Obsidian，打开 vault 里的 README.md 看"第一次使用 hum"
  2. 还没装 Claude Code 的话：https://claude.com/claude-code
  3. 在这个目录下跑 `claude` 启动会话

💡 hum 可以跟 cast（个人身份锚点系统）配合，给你更"知道你是谁"的 AI 协作。
   cast 还在开发中，稳定后会告诉你怎么装。

EOF
