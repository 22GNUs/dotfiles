/**
 * Cloudflare AI Gateway (Packycode) Provider for pi.
 *
 * Environment variables: CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_GATEWAY_ID, CLOUDFLARE_API_TOKEN
 *
 * This extension only registers the `cf-packycode` provider.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

import { createCloudflareAIGatewayPricing } from "./custom-provider-shared";

export default function (pi: ExtensionAPI) {
  const accountId = process.env.CLOUDFLARE_ACCOUNT_ID;
  const gatewayId = process.env.CLOUDFLARE_GATEWAY_ID;
  const apiKey = process.env.CLOUDFLARE_API_TOKEN;
  if (!accountId || !gatewayId || !apiKey) return;

  pi.registerProvider("cf-packycode", {
    baseUrl: `https://gateway.ai.cloudflare.com/v1/${accountId}/${gatewayId}/custom-packycode`,
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
        ...createCloudflareAIGatewayPricing(0.357, 2.14, 0.0357),
      },
      {
        id: "gpt-5.6-terra",
        name: "GPT-5.6 Terra",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 1050000,
        maxTokens: 128000,
        ...createCloudflareAIGatewayPricing(0.179, 1.07, 0.0179),
      },
      {
        id: "gpt-5.6-luna",
        name: "GPT-5.6 Luna",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 1050000,
        maxTokens: 128000,
        ...createCloudflareAIGatewayPricing(0.071, 0.429, 0.0071),
      },
    ],
  });
}
