/**
 * CLIProxyAPI Codex Provider for pi.
 *
 * Environment variable: CLIPROXYAPI_API_KEY
 *
 * Routes Codex Responses requests through CLIProxyAPI.
 * WebSocket transport is not enabled here; pi-ai defaults to SSE unless transport is set elsewhere.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  const apiKey = process.env.CLIPROXYAPI_API_KEY;
  if (!apiKey) return;

  pi.registerProvider("cliproxyapi", {
    baseUrl: "https://cliproxy.lazycat.vip/v1",
    apiKey: "CLIPROXYAPI_API_KEY",
    api: "openai-responses",
    models: [
      {
        id: "gpt-5.5",
        name: "GPT-5.5",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 272000,
        maxTokens: 128000,
        cost: { input: 5, output: 30, cacheRead: 0.5, cacheWrite: 0 },
      },
      {
        id: "gpt-5.4",
        name: "GPT-5.4",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 272000,
        maxTokens: 128000,
        cost: { input: 2.5, output: 15, cacheRead: 0.25, cacheWrite: 0 },
      },
      {
        id: "gpt-5.4-mini",
        name: "GPT-5.4 Mini",
        reasoning: true,
        input: ["text", "image"],
        contextWindow: 272000,
        maxTokens: 128000,
        cost: { input: 0.75, output: 4.5, cacheRead: 0.075, cacheWrite: 0 },
      },
    ],
  });
}
