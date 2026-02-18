# Pi Agent 配置

## Cloudflare AI Gateway Provider

**环境变量：**

```bash
export CLOUDFLARE_ACCOUNT_ID="your-account-id"
export CLOUDFLARE_GATEWAY_ID="your-gateway-id"
export CLOUDFLARE_API_TOKEN="your-api-token"
```

**添加模型：** 编辑 `extensions/custom-provider-cf-compat.ts`，复制现有模型配置修改 `id`、`name` 和 `cost()` 参数。

---

## Exa MCP (Web 搜索)

已安装 `@benvargas/pi-exa-mcp`，提供 `web_search_exa` 和 `get_code_context_exa` 工具。

**可选配置（无 key 有 rate limit）：**

```bash
# 方法1: 环境变量
export EXA_API_KEY="your-key"

# 方法2: CLI 参数
pi --exa-mcp-api-key=your-key
```

---

## 常用命令

```bash
pi /reload                          # 重新加载扩展
pi -e ./xxx.ts                      # 临时加载扩展测试
pi -e ~/.pi/agent/extensions/pi-ui-toolkit  # 临时加载 UI 插件包
```

---

## UI 插件包

已将自定义 UI 扩展整合为 `pi-ui-toolkit`：

- `extensions/pi-ui-toolkit/mini-footer.ts`
- `extensions/pi-ui-toolkit/working-glow.ts`
- `extensions/pi-ui-toolkit/index.ts`（统一入口）
- `extensions/pi-ui-toolkit/package.json`（`pi.extensions` 清单）

---

## 扩展开发

在 `~/.pi/agent/extensions/` 目录运行以下命令安装依赖，即可获得 VSCode 类型提示：

```bash
cd ~/.pi/agent/extensions
npm install
```

**关键依赖：** `@mariozechner/pi-coding-agent`（扩展 API）、`@sinclair/typebox`（工具参数 Schema）
