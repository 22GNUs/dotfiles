# Pi Agent 配置

## 安装步骤

> `.pi/agent/settings.json` 已纳入 Git；请勿写入敏感信息，以下步骤可在拉取仓库后直接执行。

1. 安装第三方扩展

```bash
pi install npm:checkpoint-pi
```

2. 安装上游资源包（通过 `packages + filter` 方式）

```bash
pi install npm:mitsupi
```

> 本仓库已在 `.pi/agent/settings.json` 中配置筛选，只启用：
>
> - `pi-extensions/answer.ts`
> - `pi-extensions/todos.ts`
> - `skills/commit`

3. 安装本仓库扩展依赖（用于本地扩展开发与类型提示）

```bash
cd .pi/agent/extensions
npm install
```

4. 重新加载扩展/技能

```bash
pi /reload
```

5. 查看已安装包

```bash
pi list
```

---

## 上游同步（packages 方式）

更新 `mitsupi` 到最新版本：

```bash
pi update npm:mitsupi
```

---

## 第三方扩展列表

| 扩展 | 安装源 | 作用 | 入口 |
| --- | --- | --- | --- |
| `checkpoint-pi` | `npm:checkpoint-pi` | 提供对话/任务检查点能力，便于保存与恢复上下文状态。 | `+checkpoint.ts` |
| `mitsupi`（已筛选） | `npm:mitsupi` | 上游扩展/技能包；当前仅启用 `answer.ts`、`todos.ts`、`commit`。 | `answer.ts` / `todos.ts` / `/skill:commit` |

---

## 本仓库内置扩展包

| 扩展包 | 路径 | 作用 |
| --- | --- | --- |
| `pi-custom-providers` | `extensions/pi-custom-providers` | 自定义 Provider：`cf-compat`、`cf-packycode`。 |

## 外部 Pi 包

| 扩展包 | 安装源 | 作用 |
| --- | --- | --- |
| `pi-cyber-ui` | `git:github.com/22GNUs/pi-cyber-ui.git` | 独立的 Pi UI 包：主题 `cyber-ui-dark` + `editor` / `footer` / `working`。 |

---

## Cloudflare Provider 配置

配置 `cf-compat` / `cf-packycode` 前，请先设置环境变量：

```bash
export CLOUDFLARE_ACCOUNT_ID="your-account-id"
export CLOUDFLARE_GATEWAY_ID="your-gateway-id"
export CLOUDFLARE_API_TOKEN="your-api-token"
```

模型配置文件：

- `extensions/pi-custom-providers/custom-provider-cf-compat.ts`
- `extensions/pi-custom-providers/custom-provider-cf-packycode.ts`

---

## 常用命令

```bash
pi /reload                                            # 重新加载扩展
pi list                                               # 查看已安装包
pi update npm:mitsupi                                 # 同步上游包
pi install git:github.com/22GNUs/pi-cyber-ui.git  # 安装独立的 UI 包
pi -e ./.pi/agent/extensions/pi-custom-providers      # 临时加载 Provider 扩展包
```
