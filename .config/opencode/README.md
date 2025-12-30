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

本配置使用 **`opencode-antigravity-auth@1.2.4`** 插件，提供：

- **Google OAuth 认证**：通过 `opencode auth login` 支持多账户管理
- **双配额池**：Antigravity 和 Gemini CLI 配额自动切换，有效翻倍 Gemini 配额
- **多模型支持**：包括 Gemini 3 系列和 Claude 4.5 系列（含 thinking 模型）
- **自动负载均衡**：多账户自动轮换，最大化速率限制

### 插件清理/重装

如果遇到插件问题需要清理缓存重装，请运行：

```bash
cd ~ && sed -i.bak '/opencode-antigravity-auth/d' .cache/opencode/package.json && \
rm -rf .cache/opencode/node_modules/opencode-antigravity-auth && \
echo "Plugin cache cleared. Restart OpenCode to reinstall."
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

- **Google Gemini & Antigravity**:
  ```bash
  opencode auth login
  # 选择 Google → OAuth with Google (Antigravity)
  # Project ID 提示时按 Enter 跳过
  # 在浏览器中完成 Google 登录
  ```
  
  **可用模型**：
  - `google/gemini-3-pro-high` - Gemini 3 Pro High
  - `google/gemini-3-pro-low` - Gemini 3 Pro Low
  - `google/gemini-3-flash` - Gemini 3 Flash
  - `google/claude-sonnet-4-5` - Claude Sonnet 4.5
  - `google/claude-sonnet-4-5-thinking` - Claude Sonnet 4.5 (带思考)
  - `google/claude-opus-4-5-thinking` - Claude Opus 4.5 (带思考)
  - `google/gpt-oss-120b-medium` - GPT-OSS 120B Medium
  
  **多账户支持**：添加 2-10 个 Google 账户以最大化速率限制：
  ```bash
  opencode auth login  # 重复运行添加更多账户
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
