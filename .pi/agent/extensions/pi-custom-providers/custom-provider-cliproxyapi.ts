/**
 * CLIProxyAPI Codex Provider for pi.
 *
 * Environment variable: CLIPROXYAPI_API_KEY
 *
 * Uses pi-ai's built-in OpenAI Codex Responses transport, including WebSocket
 * support, while authenticating to CLIProxyAPI with X-Api-Key. The fake JWT is
 * only for pi-ai's local account-id extraction; CLIProxyAPI ignores it and
 * validates CLIPROXYAPI_API_KEY via X-Api-Key.
 * To enable websocet support, add `websockets: true` to ~/.cli-proxy-api/codex-*.json configs.
 */

import { Buffer } from "node:buffer";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

function base64(input: string): string {
  return Buffer.from(input, "utf8").toString("base64");
}

function fakeCodexToken(): string {
  const header = base64(JSON.stringify({ alg: "none", typ: "JWT" }));
  const payload = base64(
    JSON.stringify({
      "https://api.openai.com/auth": {
        chatgpt_account_id: "cliproxyapi",
      },
    }),
  );
  return `${header}.${payload}.cliproxyapi`;
}

export default function (pi: ExtensionAPI) {
  if (!process.env.CLIPROXYAPI_API_KEY) return;

  pi.registerProvider("cliproxyapi", {
    baseUrl: "https://cliproxy.lazycat.vip/backend-api",
    apiKey: fakeCodexToken(),
    headers: {
      "X-Api-Key": "CLIPROXYAPI_API_KEY",
    },
    api: "openai-codex-responses",
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
