# Dotfiles 仓库 - AI 编码助手指南

本仓库是个人配置文件（dotfiles）集合，包含终端、编辑器、窗口管理器等工具的配置。

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

## Pi Agent

配置目录：`.pi/agent/`

详见 `.pi/agent/AGENTS.md`。

---

## 注意事项

1. **不要提交敏感信息**：`.gitignore` 已配置排除 `.gitconfig` 等
2. **Fish 变量**：`fish_variables` 是本地状态文件，已被排除
3. **软链接优先**：使用 `install.sh` 创建软链接，而非复制
4. **平台特定**：本配置针对 macOS，使用 `/opt/homebrew` 路径
5. **External 目录**：`external/` 包含其他仓库的引用，通过软链接使用，已加入 `.gitignore`
6. **官方配置目录优先**：涉及 fish / starship / tmux 等配置时，优先改写仓库内对应的官方配置路径（例如 `.config/fish/`、`.config/starship.toml`、`.tmux.conf`），不要在脚本或配置里硬编码绝对路径、临时路径或环境变量的固定值；如需懒加载/缓存，请统一放在官方配置目录或其约定缓存目录中实现。
