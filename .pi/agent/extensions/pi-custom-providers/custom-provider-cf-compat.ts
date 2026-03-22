/**
 * Cloudflare AI Gateway (compat) Provider for pi.
 *
 * 环境变量: CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_GATEWAY_ID, CLOUDFLARE_API_TOKEN
 *
 * Cloudflare AI Gateway compat 端点格式:
 * https://gateway.ai.cloudflare.com/v1/{account_id}/{gateway_id}/compat
 *
 * This extension is registered on its own so it can be enabled/disabled independently.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

import { createCloudflareAIGatewayPricing } from "./custom-provider-shared";

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
        ...createCloudflareAIGatewayPricing(0.27, 0.4, 0.135),
      },
      {
        id: "openrouter/stepfun/step-3.5-flash:free",
        name: "step-3.5-flash(free)",
        reasoning: true,
        input: ["text"],
        contextWindow: 256000,
        maxTokens: 64000,
        ...createCloudflareAIGatewayPricing(0, 0),
      },
      {
        id: "custom-chutes/zai-org/GLM-5-Turbo",
        name: "GLM 5 Turbo",
        reasoning: true,
        input: ["text"],
        contextWindow: 202752,
        maxTokens: 65535,
        ...createCloudflareAIGatewayPricing(0, 0),
      },
      {
        id: "custom-chutes/moonshotai/Kimi-K2.5-TEE",
        name: "Kimi K2.5 TEE",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 262144,
        maxTokens: 65535,
        ...createCloudflareAIGatewayPricing(0, 0),
      },
      {
        id: "custom-chutes/MiniMaxAI/MiniMax-M2.5-TEE",
        name: "MiniMax M2.5 TEE",
        reasoning: true,
        input: ["text"],
        contextWindow: 196608,
        maxTokens: 65536,
        ...createCloudflareAIGatewayPricing(0, 0),
      },
      {
        id: "custom-chutes/zai-org/GLM-5-TEE",
        name: "GLM 5 TEE",
        reasoning: true,
        input: ["text"],
        contextWindow: 202752,
        maxTokens: 65535,
        ...createCloudflareAIGatewayPricing(0, 0),
      },
    ],
  });
}
