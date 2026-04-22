# Installing hum L3 大文件备份 — guide for AI agents

> 如果你是 AI agent 在帮用户配 hum 的大文件备份（L3）。
> **前提**：用户已装 L1；在 hum vault 目录下。用户愿意把 PDF/PPT 等大文件放进一个 GitHub **private** repo 备份。
> **效果**：vault 下建 `Attachments.nosync/`，放大文件自动 commit + push 到 GitHub。

## 你要做的事

1. 前提 + 问用户偏好
2. 生成 SSH key + macOS Keychain 集成
3. 经 GitHub API 上传 SSH 公钥 + 建 private repo
4. 建 `Attachments.nosync/` + git init + 首推
5. 写 `sync_attachments.sh` 脚本
6. 写 Automator Folder Action 工作流
7. 引导用户做最后 3 次点击：绑定 folder action + 授权完全磁盘访问
8. 验证 + 擦手

**多数步骤 AI 可直接脚本执行**；第 7 步因 macOS Folder Actions 的 binding 用 bookmark 存储，需用户手动点几下 GUI。

## 1. 前提 + 问用户偏好

```bash
# 在 hum vault 目录
ls AGENTS.md >/dev/null 2>&1 || { echo "✗ 不在 hum vault"; exit 1; }

# macOS?
[ "$(uname)" = "Darwin" ] || { echo "✗ 仅支持 macOS"; exit 1; }
```

问用户：

- **GitHub 用户名**（用来组合 SSH URL 和 repo 名）
- **GitHub PAT**（如果没有，引导他建一个带 `repo` 和 `admin:public_key` 的 classic PAT）。让用户粘贴时用 `read -s -p "PAT: " PAT; echo`，不要在屏幕或 log 留痕
- **备份 repo 叫什么名字**？默认 `attachments`
- **邮箱**（生成 SSH key 时做注释用）

## 2. 生成 SSH key + Keychain

**先检查是否已有 key**：
```bash
if [ -f ~/.ssh/id_ed25519 ]; then
  echo "检测到已有 ~/.ssh/id_ed25519"
  # 问用户：复用（推荐）/ 生成新的（会覆盖，三思）
fi
```

如果要**新生成**：
```bash
ssh-keygen -t ed25519 -C "<email>" -f ~/.ssh/id_ed25519 -N ""
# -N "" 表示空 passphrase；launchd/Automator 跑后台脚本不方便输密码
```

**加到 Keychain**：
```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

**配 ~/.ssh/config**（追加，幂等检查）：
```bash
if ! grep -q "Host github.com" ~/.ssh/config 2>/dev/null; then
  mkdir -p ~/.ssh && chmod 700 ~/.ssh
  cat >> ~/.ssh/config << 'EOF'

Host github.com
  HostName github.com
  User git
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
fi
```

## 3. 上传 SSH 公钥 + 建 private repo

**上传公钥**：
```bash
KEY_TITLE="$(hostname) $(date +%Y-%m-%d)"
curl -sL -X POST \
  -H "Authorization: Bearer $PAT" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/keys \
  -d "{\"title\":\"$KEY_TITLE\",\"key\":\"$(cat ~/.ssh/id_ed25519.pub)\"}" \
  | grep -qE '"id"\s*:\s*[0-9]+' && echo "✓ 公钥已上传" \
  || { echo "✗ 公钥上传失败，可能 PAT 没 admin:public_key scope"; exit 1; }
```

**建 private repo**（不要 auto_init，省得首推冲突）：
```bash
REPO_NAME="attachments"
curl -sL -X POST \
  -H "Authorization: Bearer $PAT" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/repos \
  -d "{\"name\":\"$REPO_NAME\",\"private\":true,\"auto_init\":false}" \
  | grep -q '"full_name"' && echo "✓ repo 已建" \
  || { echo "✗ repo 建失败（可能同名已存在）"; }
```

**测 SSH 连通**：
```bash
ssh -T git@github.com -o StrictHostKeyChecking=accept-new 2>&1 \
  | grep -q "successfully authenticated" && echo "✓ SSH 通了"
```

## 4. 建 Attachments.nosync + git init + 首推

```bash
# 当前在 hum vault 目录
mkdir -p "Attachments.nosync"
cd "Attachments.nosync"

# 双保险：目录名 .nosync + 目录内放 .nosync 空文件
touch .nosync

# git init
git init -q
git branch -m main
git remote add origin "git@github.com:$GITHUB_USER/$REPO_NAME.git"

# 首推
echo ".DS_Store" > .gitignore
git add .
git commit -q -m "init"
git push -u origin main

cd ..
echo "✓ Attachments.nosync 已连上 GitHub"
```

## 5. 写 sync_attachments.sh

```bash
SCRIPT=~/sync_attachments.sh
VAULT_ABS="$(pwd)"  # 朋友的 vault 绝对路径

cat > "$SCRIPT" << EOF
#!/bin/bash
LOG_FILE="\$HOME/sync_attachments.log"
TARGET_DIR="$VAULT_ABS/Attachments.nosync"

# 自清理：log 超 50KB 就截到后半
if [ -f "\$LOG_FILE" ] && [ "\$(stat -f%z "\$LOG_FILE" 2>/dev/null)" -gt 50000 ]; then
  tail -c 25000 "\$LOG_FILE" > "\$LOG_FILE.tmp" && mv "\$LOG_FILE.tmp" "\$LOG_FILE"
fi

exec >> "\$LOG_FILE" 2>&1
echo "---- \$(date) ----"

cd "\$TARGET_DIR" || { echo "ERROR: cd failed"; exit 1; }
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:\$PATH"

git add -A
if [[ -n \$(git status -s) ]]; then
  git commit -m "Auto-sync: \$(date +'%Y-%m-%d %H:%M:%S')"
  git push origin main && echo "sync done"
else
  echo "no changes"
fi
EOF

chmod +x "$SCRIPT"
echo "✓ 写好 $SCRIPT"
```

注意：heredoc 用 `EOF`（无引号）所以脚本里 bash 变量要 `\$` 转义，但 `$VAULT_ABS` 不转义（想展开成具体路径）。

## 6. 写 Automator Folder Action 工作流

Folder Action 本质是个 `.workflow` bundle（目录）。AI 可以直接写：

```bash
WORKFLOW_DIR="$HOME/Library/Workflows/Applications/Folder Actions/Sync Attachments.workflow/Contents"
mkdir -p "$WORKFLOW_DIR"

# Info.plist（最小骨架）
cat > "$WORKFLOW_DIR/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSServices</key>
	<array/>
</dict>
</plist>
EOF

# document.wflow：里面塞一个 "Run Shell Script" action，跑 ~/sync_attachments.sh
# 简化版 workflow（Automator 读 .wflow 是 plist 格式）
cat > "$WORKFLOW_DIR/document.wflow" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AMApplicationBuild</key><string>521</string>
	<key>AMApplicationVersion</key><string>2.10</string>
	<key>AMDocumentVersion</key><string>2</string>
	<key>actions</key>
	<array>
		<dict>
			<key>action</key>
			<dict>
				<key>AMActionVersion</key><string>2.0.3</string>
				<key>ActionBundlePath</key><string>/System/Library/Automator/Run Shell Script.action</string>
				<key>ActionName</key><string>Run Shell Script</string>
				<key>ActionParameters</key>
				<dict>
					<key>COMMAND_STRING</key><string>$HOME/sync_attachments.sh</string>
					<key>CheckedForUserDefaultShell</key><true/>
					<key>inputMethod</key><integer>0</integer>
					<key>shell</key><string>/bin/bash</string>
					<key>source</key><string></string>
				</dict>
				<key>BundleIdentifier</key><string>com.apple.RunShellScript</string>
				<key>ClassName</key><string>RunShellScriptAction</string>
			</dict>
		</dict>
	</array>
	<key>workflowMetaData</key>
	<dict>
		<key>workflowTypeIdentifier</key><string>com.apple.Automator.folder</string>
	</dict>
</dict>
</plist>
EOF

echo "✓ Workflow bundle 写好：$WORKFLOW_DIR"
```

> ⚠️ Folder Action 的 **binding**（告诉系统"这个 workflow 监听哪个目录"）存在 `~/Library/Preferences/com.apple.FolderActionsDispatcher.plist` 里，用 macOS bookmark 格式编码，AI 不方便脚本生成。所以下面第 7 步让用户手动点。

## 7. 让用户做最后的 GUI 操作

告诉用户**照做**：

**A. 绑定 Folder Action 到 Attachments.nosync**

1. 打开 Finder，cd 到 vault → 找到刚建的 `Attachments.nosync` 文件夹
2. 右键 → Services → "Folder Actions Setup..."
3. 弹出的窗口选刚写好的 `Sync Attachments.workflow`
4. 确认 "Enable Folder Actions" 勾上
5. 确认 workflow 列表里 `Sync Attachments` 也勾上

**B. 授权 Automator "完全磁盘访问"**（macOS Ventura+ 必做）

1. System Settings → Privacy & Security → Full Disk Access
2. 点 `+` → 加入 **Automator** 和 **FolderActionsDispatcher**（在 `/System/Library/CoreServices/FolderActionsDispatcher.app`）
3. 两个都 toggle 成开

## 8. 验证

让用户**扔一个测试文件**（如 `echo test > Attachments.nosync/test.txt`），然后：

```bash
# 等 3-5 秒
tail -20 ~/sync_attachments.log
```

期望看到：
```
---- <日期时间> ----
sync done
```

再访问 `https://github.com/<username>/attachments`，应该看到新的 `Auto-sync:` commit。

## 失败速查

| 症状 | 原因 | 处理 |
|---|---|---|
| `ssh: Permission denied` | 公钥没上传成功或 keychain 没加载 | 重跑 `ssh-add --apple-use-keychain` + 验证 `ssh -T git@github.com` |
| API 上传公钥 `Resource not accessible` | PAT 缺 `admin:public_key` / `write:public_key` scope | 编辑 PAT 勾上再重跑 |
| 首推 `fatal: refusing to merge unrelated histories` | GitHub 建 repo 时 auto_init=true 带了 README | 用 `auto_init:false` 重建 repo；或 `git pull --allow-unrelated-histories` |
| 扔文件后 log 没动 | Folder Action 没绑定 / Full Disk Access 没给 | 回第 7 步检查两项 |
| log 里 git push 报 SSH 错 | launchd/Automator 拿不到 keychain SSH key | `~/.ssh/config` 要有 `UseKeychain yes` 且 `AddKeysToAgent yes` |

## 擦手

别在 shell history 里留 PAT。建议：
```bash
unset PAT
history -c 2>/dev/null  # 清当前 session 历史（可选）
```
