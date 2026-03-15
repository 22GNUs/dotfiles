/**
 * Cloudflare AI Gateway (compat) Provider for pi
 *
 * 环境变量: CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_GATEWAY_ID, CLOUDFLARE_API_TOKEN
 *
 * Cloudflare AI Gateway compat 端点格式:
 * https://gateway.ai.cloudflare.com/v1/{account_id}/{gateway_id}/compat
 *
 * 模型通过请求体中的 model 字段路由，例如:
 * { "model": "custom-synthetic/hf:nvidia/Kimi-K2.5-NVFP4" }
 *
 * cf-aig-custom-cost Header 格式 (JSON):
 * { "per_token_in": 0.00000055, "per_token_out": 0.00000219 }
 *
 * 注意: 价格为 per-token (非 per-million)
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

/**
 * 生成 cost 配置和 cf-aig-custom-cost header
 * @param input 输入价格 ($/million)
 * @param output 输出价格 ($/million)
 * @param cacheRead 缓存读取 ($/million, pi 内部使用)
 * @param cacheWrite 缓存写入 ($/million, pi 内部使用)
 */
function cost(input: number, output: number, cacheRead = 0, cacheWrite = 0) {
  const perToken = (v: number) => v / 1_000_000;
  return {
    cost: { input, output, cacheRead, cacheWrite },
    headers: {
      "cf-aig-custom-cost": JSON.stringify({
        per_token_in: perToken(input),
        per_token_out: perToken(output),
      }),
    },
  };
}

export default function (pi: ExtensionAPI) {
  const accountId = process.env.CLOUDFLARE_ACCOUNT_ID;
  const gatewayId = process.env.CLOUDFLARE_GATEWAY_ID;
  if (!accountId || !gatewayId) return;

  pi.registerProvider("cf-compat", {
    baseUrl: `https://gateway.ai.cloudflare.com/v1/${accountId}/${gatewayId}/compat`,
    apiKey: "CLOUDFLARE_API_TOKEN",
    api: "openai-completions",
    models: [
      {
        id: "openrouter/deepseek/deepseek-v3.2",
        name: "deepseek-v3.2",
        reasoning: true,
        input: ["text"],
        contextWindow: 164000,
        maxTokens: 64000,
        ...cost(0.27, 0.4, 0.135),
      },
      {
        id: "custom-chutes/zai-org/GLM-5-Turbo",
        name: "GLM 5 Turbo",
        reasoning: true,
        input: ["text"],
        contextWindow: 202752,
        maxTokens: 65535,
        ...cost(0, 0),
      },
      {
        id: "custom-chutes/moonshotai/Kimi-K2.5-TEE",
        name: "Kimi K2.5 TEE",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 262144,
        maxTokens: 65535,
        ...cost(0, 0),
      },
      {
        id: "custom-chutes/MiniMaxAI/MiniMax-M2.5-TEE",
        name: "MiniMax M2.5 TEE",
        reasoning: true,
        input: ["text"],
        contextWindow: 196608,
        maxTokens: 65536,
        ...cost(0, 0),
      },
      {
        id: "custom-chutes/zai-org/GLM-5-TEE",
        name: "GLM 5 TEE",
        reasoning: true,
        input: ["text"],
        contextWindow: 202752,
        maxTokens: 65535,
        ...cost(0, 0),
      },
    ],
  });
}
