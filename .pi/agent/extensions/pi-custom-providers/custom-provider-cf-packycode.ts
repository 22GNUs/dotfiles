/**
 * Cloudflare AI Gateway (Packycode) Provider for pi
 *
 * Environment variables: CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_GATEWAY_ID, CLOUDFLARE_API_TOKEN
 *
 * Cloudflare AI Gateway endpoints:
 * - OpenAI Responses: https://gateway.ai.cloudflare.com/v1/{account_id}/{gateway_id}/custom-packycodex
 * - Anthropic Messages: https://gateway.ai.cloudflare.com/v1/{account_id}/{gateway_id}/custom-packycode-aws
 *
 * Packycode endpoints/models are maintained in this file.
 *
 * cf-aig-custom-cost header format (JSON):
 * { "per_token_in": 0.00000175, "per_token_out": 0.000014 }
 *
 * Note: header pricing is per-token, not per-million.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

function pricing(input: number, output: number, cacheRead = 0, cacheWrite = 0) {
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

  pi.registerProvider("cf-packycode-sub", {
    baseUrl: `https://gateway.ai.cloudflare.com/v1/${accountId}/${gatewayId}/custom-packycodex`,
    apiKey: "CLOUDFLARE_API_TOKEN",
    api: "openai-responses",
    models: [
      {
        id: "gpt-5.3-codex",
        name: "GPT-5.3 Codex",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 272000,
        maxTokens: 128000,
        ...pricing(1.75, 14, 0.175),
      },
      {
        id: "gpt-5.4",
        name: "GPT-5.4",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 272000,
        maxTokens: 128000,
        ...pricing(2.5, 15, 0.25),
      },
      {
        id: "gpt-5.4-fast",
        name: "GPT-5.4 Fast",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 272000,
        maxTokens: 128000,
        ...pricing(2.5, 15, 0.25),
      },
    ],
  });

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
        ...pricing(0.13, 0.64),
      },
    ],
  });
}
