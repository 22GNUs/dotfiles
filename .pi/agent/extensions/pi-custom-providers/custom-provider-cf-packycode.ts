/**
 * Cloudflare AI Gateway (Packycode) Provider for pi.
 *
 * Environment variables: CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_GATEWAY_ID, CLOUDFLARE_API_TOKEN
 *
 * This extension only registers the `cf-packycode` provider.
 * The AWS variant lives in `custom-provider-cf-packycode-aws.ts`.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

import { createCloudflareAIGatewayPricing } from "./custom-provider-shared";

export default function (pi: ExtensionAPI) {
  const accountId = process.env.CLOUDFLARE_ACCOUNT_ID;
  const gatewayId = process.env.CLOUDFLARE_GATEWAY_ID;
  const apiKey = process.env.CLOUDFLARE_API_TOKEN;
  if (!accountId || !gatewayId || !apiKey) return;

  pi.registerProvider("cf-packycode", {
    baseUrl: `https://gateway.ai.cloudflare.com/v1/${accountId}/${gatewayId}/custom-packycodex`,
    apiKey: "CLOUDFLARE_API_TOKEN",
    api: "openai-responses",
    models: [
      {
        id: "gpt-5.3-codex",
        name: "GPT-5.3 Codex",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 400000,
        maxTokens: 128000,
        ...createCloudflareAIGatewayPricing(0, 0),
      },
      {
        id: "gpt-5.4",
        name: "GPT-5.4",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 400000,
        maxTokens: 128000,
        ...createCloudflareAIGatewayPricing(0, 0),
      },
      {
        id: "gpt-5.4-fast",
        name: "GPT-5.4 Fast",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 400000,
        maxTokens: 128000,
        ...createCloudflareAIGatewayPricing(0, 0),
      },
      {
        id: "gpt-5.4-mini",
        name: "GPT-5.4 Mini",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 400000,
        maxTokens: 128000,
        ...createCloudflareAIGatewayPricing(0, 0),
      },
    ],
  });
}
