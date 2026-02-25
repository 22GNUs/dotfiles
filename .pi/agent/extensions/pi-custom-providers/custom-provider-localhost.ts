/**
 * Localhost Gemini-native Provider for pi
 *
 * Endpoint: http://localhost:7861/v1
 * API key: "pwd" (literal string)
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerProvider("localhost", {
    baseUrl: "http://localhost:7861/v1",
    // For google-generative-ai, pi uses Google-style auth (x-goog-api-key).
    apiKey: "pwd",
    api: "google-generative-ai",
    models: [
      {
        id: "gemini-3.1-pro-preview",
        name: "Gemini 3.1 Pro Preview",
        reasoning: true,
        input: ["text", "image"],
        cost: {
          input: 0,
          output: 0,
          cacheRead: 0,
          cacheWrite: 0,
        },
        contextWindow: 1_000_000,
        maxTokens: 64_000,
      },
      {
        id: "gemini-3-flash-preview",
        name: "Gemini 3 Flash Preview",
        reasoning: true,
        input: ["text", "image"],
        cost: {
          input: 0,
          output: 0,
          cacheRead: 0,
          cacheWrite: 0,
        },
        contextWindow: 1_048_576,
        maxTokens: 65_536,
      },
    ],
  });
}
