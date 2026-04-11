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
    ],
  });
}
