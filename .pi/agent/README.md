# Pi Agent 配置

## 安装步骤

> `.pi/agent/settings.json` 不纳入 Git；请在本机完成以下安装步骤。

1. 安装第三方扩展

```bash
pi install npm:checkpoint-pi
```

2. 安装本仓库扩展依赖（用于本地扩展开发与类型提示）

```bash
cd .pi/agent/extensions
npm install
```

3. 重新加载扩展

```bash
pi /reload
```

4. 校验安装结果

```bash
pi packages list
```

5. 可选：验证仓库内 Pi 配置状态

```bash
./.pi/setup.sh --validate
```

---

## 外部扩展同步（可选）

仓库提供 `./.pi/setup.sh`，用于同步 `external/agent-stuff` 并链接以下扩展到 `.pi/agent/extensions/`：

- `answer.ts`
- `todos.ts`

执行完整同步：

```bash
./.pi/setup.sh
```

---

## 第三方扩展列表

| 扩展 | 安装源 | 作用 | 入口 |
| --- | --- | --- | --- |
| `checkpoint-pi` | `npm:checkpoint-pi` | 提供对话/任务检查点能力，便于保存与恢复上下文状态。 | `+checkpoint.ts` |

---

## 本仓库内置扩展包

| 扩展包 | 路径 | 作用 |
| --- | --- | --- |
| `pi-ui-toolkit` | `extensions/pi-ui-toolkit` | UI 增强：`mini-footer`、`working-glow`。 |
| `pi-custom-providers` | `extensions/pi-custom-providers` | 自定义 Provider：`cf-compat`、`cf-packycode`。 |

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
pi packages list                                      # 查看已安装扩展
pi -e ./.pi/agent/extensions/pi-ui-toolkit            # 临时加载 UI 扩展包
pi -e ./.pi/agent/extensions/pi-custom-providers      # 临时加载 Provider 扩展包
```
