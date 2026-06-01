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

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

import { createCloudflareAIGatewayPricing } from "./custom-provider-shared";

export default function (pi: ExtensionAPI) {
  const accountId = process.env.CLOUDFLARE_ACCOUNT_ID;
  const gatewayId = process.env.CLOUDFLARE_GATEWAY_ID;
  const apiKey = process.env.CLOUDFLARE_API_TOKEN;
  if (!accountId || !gatewayId || !apiKey) return;

  pi.registerProvider("cf-compat", {
    baseUrl: `https://gateway.ai.cloudflare.com/v1/${accountId}/${gatewayId}/compat`,
    apiKey: "$CLOUDFLARE_API_TOKEN",
    api: "openai-completions",
    models: [
      {
        id: "deepseek/deepseek-v4-flash",
        name: "DeepSeek V4 Flash",
        reasoning: true,
        input: ["text"],
        contextWindow: 1000000,
        maxTokens: 384000,
        ...createCloudflareAIGatewayPricing(0.14, 0.28, 0.0028),
      },
      {
        id: "deepseek/deepseek-v4-pro",
        name: "DeepSeek V4 Pro",
        reasoning: true,
        input: ["text"],
        contextWindow: 1000000,
        maxTokens: 384000,
        ...createCloudflareAIGatewayPricing(0.435, 0.87, 0.003625),
      },
      {
        id: "openrouter/deepseek/deepseek-v4-flash",
        name: "DeepSeek V4 Flash",
        reasoning: true,
        input: ["text"],
        contextWindow: 1048575,
        maxTokens: 131072,
        ...createCloudflareAIGatewayPricing(0.112, 0.224, 0.022),
      },
      {
        id: "openrouter/deepseek/deepseek-v4-pro",
        name: "DeepSeek V4 Pro",
        reasoning: true,
        input: ["text"],
        contextWindow: 1048576,
        maxTokens: 384000,
        ...createCloudflareAIGatewayPricing(0.435, 0.87, 0.003625),
      },
    ],
  });
}
