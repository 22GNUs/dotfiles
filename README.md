# Dotfiles 配置文件集合

个人配置文件仓库，包含终端、编辑器、窗口管理器等工具的配置。

## 仓库结构

```
.
├── .config/               # 主配置目录
│   ├── fish/             # Fish Shell 配置
│   ├── ghostty/          # Ghostty 终端配置
│   ├── zellij/           # Zellij 终端复用器配置
│   ├── aerospace/        # AeroSpace 窗口管理器配置
│   ├── nvim/             # Neovim (LazyVim) 配置
│   ├── opencode/         # OpenCode AI 助手配置
│   └── starship.toml     # Starship 提示符配置
├── archive/              # 归档的旧配置
│   ├── editors/          # 编辑器配置 (Vim, IntelliJ)
│   ├── macos/            # macOS 工具配置 (Sketchybar)
│   ├── scripts/          # 实用脚本
│   ├── shells/           # 旧 Shell 配置 (Zsh)
│   └── terminals/        # 旧终端配置 (Alacritty, WezTerm)
├── fonts/                # Nerd Fonts 字体文件
├── external/             # 外部仓库引用（通过软链接使用）
├── install.sh            # 安装脚本（从仓库到系统）
├── .tmux.conf            # Tmux 配置
└── .ideavimrc            # IntelliJ IDEA Vim 插件配置
```

## Neovim (LazyVim)

基于 [LazyVim](https://github.com/LazyVim/LazyVim) 的 Neovim 配置。

### 依赖安装

```sh
# Node.js (JSON LSP)
brew install node

# Lazygit (可选)
brew install lazygit

# Glow (可选，用于 Markdown 预览)
brew install glow
```

### 推荐字体

```sh
brew tap homebrew/cask-fonts && brew install --cask font-fantasque-sans-mono-nerd-font
```

### 清理缓存

```sh
~/.config/nvim/clean.sh
```

该脚本会备份并清理：

- `~/.local/share/nvim`
- `~/.local/state/nvim`
- `~/.cache/nvim`

### Claude Code 集成

配置了 `<leader>a` 前缀的 AI 辅助快捷键，支持与 Claude Code 集成。

---

## OpenCode

OpenCode AI 助手的核心配置，包含自定义 Agent 和技能设置。

### 快速安装

```bash
chmod +x .config/opencode/setup.sh
./setup.sh
```

脚本会自动：

1. 检查 `~/.config/opencode` 目录
2. 从本仓库克隆/更新配置
3. 清理插件缓存

### 插件

本配置使用 **`opencode-antigravity-auth@1.2.6`** 插件，提供：

- **Google OAuth 认证**：支持多账户管理
- **双配额池**：Antigravity 和 Gemini CLI 配额自动切换
- **多模型支持**：包括 Gemini 3 系列和 Claude 4.5 系列

### 环境变量

在 Shell 配置文件中设置：

```bash
# 必须配置
export CONTEXT7_API_KEY="your_key_here"

# 可选
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
```

---

## Pi Agent

AI 助手 Pi 的配置目录。

```bash
# 安装/更新
./.pi/setup.sh

# 验证
./.pi/setup.sh --validate
```

详见 `.pi/agent/README.md`。

---

## 安装与同步

### 安装（仓库 → 系统）

```bash
./install.sh
```

该脚本会将仓库中的配置文件通过软链接安装到用户目录。冲突文件会备份到 `~/.dotfiles_backup/`。

### 注意事项

1. **不要提交敏感信息**：`.gitignore` 已配置排除 `.gitconfig` 等
2. **Fish 变量**：`fish_variables` 是本地状态文件，已被排除
3. **软链接优先**：使用 `install.sh` 创建软链接，而非复制
4. **平台特定**：本配置针对 macOS，使用 `/opt/homebrew` 路径
