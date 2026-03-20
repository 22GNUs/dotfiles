/**
 * Cloudflare AI Gateway (Packycode AWS) Provider for pi.
 *
 * Environment variables: CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_GATEWAY_ID, CLOUDFLARE_API_TOKEN
 *
 * This extension only registers the `cf-packycode (aws)` provider.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

import { createCloudflareAIGatewayPricing } from "./custom-provider-shared";

export default function (pi: ExtensionAPI) {
  const accountId = process.env.CLOUDFLARE_ACCOUNT_ID;
  const gatewayId = process.env.CLOUDFLARE_GATEWAY_ID;
  const apiKey = process.env.CLOUDFLARE_API_TOKEN;
  if (!accountId || !gatewayId || !apiKey) return;

  pi.registerProvider("cf-packycode (aws)", {
    baseUrl: `https://gateway.ai.cloudflare.com/v1/${accountId}/${gatewayId}/custom-packycode-aws`,
    apiKey: "CLOUDFLARE_API_TOKEN",
    api: "anthropic-messages",
    models: [
      {
        id: "claude-sonnet-4-6",
        name: "Claude Sonnet 4.6",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 256000,
        maxTokens: 128000,
        ...createCloudflareAIGatewayPricing(0.13, 0.64),
      },
    ],
  });
}
