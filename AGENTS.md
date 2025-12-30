# Dotfiles 仓库 - AI 编码助手指南

本仓库是个人配置文件（dotfiles）集合，包含终端、编辑器、窗口管理器等工具的配置。

## 仓库结构

```
.
├── .config/           # 主配置目录
│   ├── fish/         # Fish Shell 配置
│   ├── ghostty/      # Ghostty 终端配置
│   ├── zellij/       # Zellij 终端复用器配置
│   ├── aerospace/    # AeroSpace 窗口管理器配置
│   └── starship.toml # Starship 提示符配置
├── archive/          # 归档的旧配置
│   ├── editors/      # 编辑器配置 (Vim, IntelliJ)
│   ├── macos/        # macOS 工具配置 (Sketchybar)
│   ├── scripts/      # 实用脚本
│   ├── shells/       # 旧 Shell 配置 (Zsh)
│   └── terminals/    # 旧终端配置 (Alacritty, WezTerm)
├── fonts/            # Nerd Fonts 字体文件
├── install.sh        # 安装脚本（从仓库到系统）
├── sync.sh           # 同步脚本（从系统到仓库）
├── .tmux.conf        # Tmux 配置
└── .ideavimrc        # IntelliJ IDEA Vim 插件配置
```

## 注意事项

1. **不要提交敏感信息**：`.gitignore` 已配置排除 `.gitconfig` 等
2. **Fish 变量**：`fish_variables` 是本地状态文件，已被排除
3. **软链接优先**：使用 `install.sh` 创建软链接，而非复制
4. **平台特定**：本配置针对 macOS，使用 `/opt/homebrew` 路径
