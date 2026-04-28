/**
 * Cloudflare AI Gateway (Codex) Provider for pi.
 *
 * Environment variables: CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_GATEWAY_ID, CLOUDFLARE_API_TOKEN
 *
 * Proxies an OpenAI Responses-compatible Codex endpoint through Cloudflare AI Gateway.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

import { createCloudflareAIGatewayPricing } from "./custom-provider-shared";

export default function (pi: ExtensionAPI) {
  const accountId = process.env.CLOUDFLARE_ACCOUNT_ID;
  const gatewayId = process.env.CLOUDFLARE_GATEWAY_ID;
  const apiKey = process.env.CLOUDFLARE_API_TOKEN;
  if (!accountId || !gatewayId || !apiKey) return;

  pi.registerProvider("cf-codex", {
    baseUrl: `https://gateway.ai.cloudflare.com/v1/${accountId}/${gatewayId}/custom-codex`,
    apiKey: "CLOUDFLARE_API_TOKEN",
    api: "openai-responses",
    models: [
      {
        id: "gpt-5.5",
        name: "GPT-5.5",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 272000,
        maxTokens: 128000,
        ...createCloudflareAIGatewayPricing(5, 30, 0.5),
      },
      {
        id: "gpt-5.4",
        name: "GPT-5.4",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 272000,
        maxTokens: 128000,
        ...createCloudflareAIGatewayPricing(2.5, 15, 0.25),
      },
      {
        id: "gpt-5.4-mini",
        name: "GPT-5.4 Mini",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 272000,
        maxTokens: 128000,
        ...createCloudflareAIGatewayPricing(0.75, 4.5, 0.075),
      },
    ],
  });
}
