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
        id: "custom-synthetic/hf:nvidia/Kimi-K2.5-NVFP4",
        name: "Kimi 2.5",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 262144,
        maxTokens: 16384,
        compat: { maxTokensField: "max_tokens", thinkingFormat: "openai" },
        ...cost(0.55, 2.19),
      },
    ],
  });
}
