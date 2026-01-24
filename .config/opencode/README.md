# OpenCode 配置仓库

这份仓库包含了 OpenCode 的核心配置文件、自定义 Agent 以及相关的 Prompt 设置。

## 目录结构

- `opencode.jsonc`: 核心配置文件，包含模型配置、MCP 服务器设置、插件列表等。
- `agent/`: 自定义 Agent 的定义文件。
  - `semantic-git-committer.md`: 语义化 Git 提交助手。
  - `typescript-developer.md`: TypeScript 开发专家。
- `AGENTS.md`: 通用的 Agent 行为准则（如语言偏好）。

## 快速安装与同步

我们提供了一个一键安装脚本，它会自动将本仓库克隆到 OpenCode 的默认配置目录 (`~/.config/opencode`)，并清理过期的插件缓存。

**使用方法：**

1. 下载脚本（或者如果你已经有了脚本）：
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

2. 脚本执行流程：
   - 检查 `~/.config/opencode`。
   - 如果不存在，自动从 `https://github.com/22GNUs/opencode_config.git` 克隆。
   - 如果已存在且是 Git 仓库，自动执行 `git pull` 更新。
   - 自动清理插件缓存，确保使用最新版本。
   - 检查必要的环境变量。

## 插件说明

本配置使用 **`@plannotator/opencode`** 插件，提供智能代码注释生成功能。

如需清理插件缓存，请运行：

```bash
rm -rf ~/.cache/opencode/node_modules/@plannotator/opencode
```

## 环境变量配置

本配置依赖以下环境变量。请确保在运行 OpenCode 之前，这些变量已经在你的 Shell 环境中生效。

### 必须配置

- **`CONTEXT7_API_KEY`**: 用于连接 Context7 MCP 服务器 (文档/知识库检索)。

**Bash / Zsh** (编辑 `~/.zshrc` 或 `~/.bashrc`):
```bash
export CONTEXT7_API_KEY="your_key_here"
```

**Fish** (编辑 `~/.config/fish/config.fish`):
```fish
set -gx CONTEXT7_API_KEY "your_key_here"
```

### Web Search (可选)

- **`OPENCODE_ENABLE_EXA`**: 设为 `true` 开启 Exa web search 功能。

**Bash / Zsh** (编辑 `~/.zshrc` 或 `~/.bashrc`):
```bash
export OPENCODE_ENABLE_EXA="true"
```

**Fish** (编辑 `~/.config/fish/config.fish`):
```fish
set -Ux OPENCODE_ENABLE_EXA true
```

### 模型服务配置 (可选/根据实际情况)

- **Anthropic / Claude**:
  ```bash
  # Bash/Zsh
  export ANTHROPIC_API_KEY="sk-ant-..."
  # Fish
  set -gx ANTHROPIC_API_KEY "sk-ant-..."
  ```

- **OpenAI**:
  ```bash
  # Bash/Zsh
  export OPENAI_API_KEY="sk-..."
  # Fish
  set -gx OPENAI_API_KEY "sk-..."
  ```

## MCP 服务配置

如果你需要在特定项目中使用 MCP 服务（如 Context7 或 gh_grep），请将以下配置复制并粘贴到项目根目录下的 `opencode.jsonc` 文件中：

```jsonc
  "mcp": {
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp",
      "headers": {
        "CONTEXT7_API_KEY": "{env:CONTEXT7_API_KEY}"
      }
    },
    "gh_grep": {
      "type": "remote",
      "url": "https://mcp.grep.app"
    }
  }
```
