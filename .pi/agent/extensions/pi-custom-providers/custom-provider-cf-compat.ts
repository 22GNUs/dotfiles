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
        id: "custom-fireworks/accounts/fireworks/routers/kimi-k2p5-turbo",
        name: "k2p5-turbo",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 256000,
        maxTokens: 256000,
        ...createCloudflareAIGatewayPricing(0, 0),
      },
      {
        id: "custom-fireworks/accounts/fireworks/models/gpt-oss-20b",
        name: "GPT OSS 20B",
        reasoning: true,
        input: ["text"],
        contextWindow: 131072,
        maxTokens: 32768,
        ...createCloudflareAIGatewayPricing(0.05, 0.2),
      },
      {
        id: "custom-synthetic/hf:MiniMaxAI/MiniMax-M2.5",
        name: "MiniMax-M2.5",
        reasoning: true,
        input: ["text"],
        contextWindow: 191488,
        maxTokens: 65536,
        ...createCloudflareAIGatewayPricing(0.6, 3, 0.6),
      },
      {
        id: "custom-synthetic/hf:deepseek-ai/DeepSeek-V3.2",
        name: "DeepSeek V3.2",
        reasoning: true,
        input: ["text"],
        contextWindow: 162816,
        maxTokens: 8000,
        ...createCloudflareAIGatewayPricing(0.27, 0.4, 0.27, 0),
      },
      {
        id: "custom-synthetic/hf:openai/gpt-oss-120b",
        name: "GPT OSS 120B",
        reasoning: true,
        input: ["text"],
        contextWindow: 128000,
        maxTokens: 32768,
        ...createCloudflareAIGatewayPricing(0.1, 0.1),
      },
      {
        id: "custom-synthetic/hf:nvidia/Kimi-K2.5-NVFP4",
        name: "Kimi K2.5 (NVFP4)",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 262144,
        maxTokens: 65536,
        ...createCloudflareAIGatewayPricing(0.55, 2.19),
      },
      {
        id: "custom-synthetic/hf:zai-org/GLM-4.7-Flash",
        name: "GLM-4.7-Flash",
        reasoning: true,
        input: ["text"],
        contextWindow: 196608,
        maxTokens: 65536,
        ...createCloudflareAIGatewayPricing(0.06, 0.4, 0.06),
      },
      {
        id: "custom-synthetic/hf:zai-org/GLM-5.1",
        name: "GLM 5.1",
        reasoning: true,
        input: ["text"],
        contextWindow: 196608,
        maxTokens: 65536,
        ...createCloudflareAIGatewayPricing(1, 3, 1),
      },
    ],
  });
}
