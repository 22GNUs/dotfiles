/**
 * Cloudflare AI Gateway (Packycode) Provider for pi
 *
 * 环境变量: CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_GATEWAY_ID, CLOUDFLARE_API_TOKEN
 *
 * Cloudflare AI Gateway 端点:
 * - OpenAI Responses: https://gateway.ai.cloudflare.com/v1/{account_id}/{gateway_id}/custom-packycodex
 * - OpenAI Chat Completions: https://gateway.ai.cloudflare.com/v1/{account_id}/{gateway_id}/custom-packycode-aws
 *
 * 后续 packycode 下的新端点/模型统一放在本文件维护。
 *
 * cf-aig-custom-cost Header 格式 (JSON):
 * { "per_token_in": 0.00000175, "per_token_out": 0.000014 }
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

  pi.registerProvider("cf-packycode (sub)", {
    baseUrl: `https://gateway.ai.cloudflare.com/v1/${accountId}/${gatewayId}/custom-packycodex`,
    apiKey: "CLOUDFLARE_API_TOKEN",
    api: "openai-responses",
    // Packycode provider models/endpoints are maintained in this file.
    models: [
      {
        id: "gpt-5.3-codex",
        name: "GPT-5.3 Codex",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 256000,
        maxTokens: 128000,
        ...cost(0, 0),
      },
      {
        id: "gpt-5.4",
        name: "GPT-5.4",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 256000,
        maxTokens: 128000,
        ...cost(0, 0),
      },
    ],
  });

  pi.registerProvider("cf-packycode (aws)", {
    baseUrl: `https://gateway.ai.cloudflare.com/v1/${accountId}/${gatewayId}/custom-packycode-aws`,
    apiKey: "CLOUDFLARE_API_TOKEN",
    api: "anthropic-messages",
    // Packycode provider models/endpoints are maintained in this file.
    models: [
      {
        id: "claude-sonnet-4-6",
        name: "Claude Sonnet 4.6",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 256000,
        maxTokens: 128000,
        ...cost(0.13, 0.64),
      },
    ],
  });
}
