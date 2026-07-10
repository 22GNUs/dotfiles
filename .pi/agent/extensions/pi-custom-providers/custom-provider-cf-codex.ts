/**
 * Cloudflare AI Gateway (Codex) Provider for pi.
 *
 * Environment variables: CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_GATEWAY_ID, CLOUDFLARE_API_TOKEN
 *
 * Proxies an OpenAI Responses-compatible Codex endpoint through Cloudflare AI Gateway.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

import { createCloudflareAIGatewayPricing } from "./custom-provider-shared";

export default function (pi: ExtensionAPI) {
  const accountId = process.env.CLOUDFLARE_ACCOUNT_ID;
  const gatewayId = process.env.CLOUDFLARE_GATEWAY_ID;
  const apiKey = process.env.CLOUDFLARE_API_TOKEN;
  if (!accountId || !gatewayId || !apiKey) return;

  pi.registerProvider("cf-codex", {
    baseUrl: `https://gateway.ai.cloudflare.com/v1/${accountId}/${gatewayId}/custom-codex`,
    apiKey: "$CLOUDFLARE_API_TOKEN",
    api: "openai-responses",
    models: [
      {
        id: "gpt-5.6-sol",
        name: "GPT-5.6 Sol",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 1050000,
        maxTokens: 128000,
        ...createCloudflareAIGatewayPricing(5, 30, 0.5, 6.25),
      },
      {
        id: "gpt-5.6-terra",
        name: "GPT-5.6 Terra",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 1050000,
        maxTokens: 128000,
        ...createCloudflareAIGatewayPricing(2.5, 15, 0.25, 3.125),
      },
      {
        id: "gpt-5.6-luna",
        name: "GPT-5.6 Luna",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 1050000,
        maxTokens: 128000,
        ...createCloudflareAIGatewayPricing(1, 6, 0.1, 1.25),
      },
      {
        id: "grok-4.3",
        name: "Grok 4.3",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 1000000,
        maxTokens: 30000,
        ...createCloudflareAIGatewayPricing(1.25, 2.5, 0.2),
      },
      {
        id: "grok-composer-2.5-fast",
        name: "Grok Composer 2.5 Fast",
        reasoning: false,
        input: ["text", "image"],
        contextWindow: 256000,
        maxTokens: 256000,
        ...createCloudflareAIGatewayPricing(0.5, 2.5, 0.2),
      },
    ],
  });
}
