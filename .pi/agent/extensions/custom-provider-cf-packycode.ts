/**
 * Cloudflare AI Gateway (Packycode) Provider for pi
 *
 * 环境变量: CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_GATEWAY_ID, CLOUDFLARE_API_TOKEN
 *
 * Cloudflare AI Gateway OpenAI Native 端点:
 * https://gateway.ai.cloudflare.com/v1/{account_id}/{gateway_id}/packycode
 *
 * 使用 OpenAI Responses API 格式
 *
 * cf-aig-custom-cost Header 格式 (JSON):
 * { "per_token_in": 0.000000438, "per_token_out": 0.0000035 }
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
  const apiKey = process.env.CLOUDFLARE_API_TOKEN;
  if (!accountId || !gatewayId || !apiKey) return;

  pi.registerProvider("cf-packycode", {
    baseUrl: `https://gateway.ai.cloudflare.com/v1/${accountId}/${gatewayId}/custom-packycode`,
    apiKey: "CLOUDFLARE_API_TOKEN",
    api: "openai-responses",
    models: [
      {
        id: "gpt-5.3-codex",
        name: "GPT-5.3 Codex",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 272000,
        maxTokens: 128000,
        ...cost(0.438, 3.5),
      },
    ],
  });
}
