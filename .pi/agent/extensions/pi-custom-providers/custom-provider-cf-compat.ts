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

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

import { createCloudflareAIGatewayPricing } from "./custom-provider-shared";

/**
 * DeepSeek V4 官方 reasoning_effort 只原生支持 high / max，
 * 因此 thinking level 只暴露 off（关闭思考）/ high / max 三档，
 * minimal/low/medium/xhigh 均标记为不支持（null 会在 UI 隐藏）。
 */
const DEEPSEEK_THINKING_LEVEL_MAP: Partial<
  Record<"minimal" | "low" | "medium" | "high" | "xhigh" | "max", string | null>
> = {
  minimal: null,
  low: null,
  medium: null,
  high: "high",
  xhigh: null,
  max: "max",
};

/**
 * pi 的 openai-completions 对 gateway.ai.cloudflare.com URL 默认检测为
 * supportsReasoningEffort: false 且 thinkingFormat: "openai"，
 * 导致不会发送 thinking / reasoning_effort 参数（思考等级完全失效）。
 * 必须显式覆盖为 DeepSeek 格式。
 */
const DEEPSEEK_COMPAT = {
  supportsReasoningEffort: true,
  thinkingFormat: "deepseek",
} as const;

export default function (pi: ExtensionAPI) {
  const accountId = process.env.CLOUDFLARE_ACCOUNT_ID;
  const gatewayId = process.env.CLOUDFLARE_GATEWAY_ID;
  const apiKey = process.env.CLOUDFLARE_API_TOKEN;
  if (!accountId || !gatewayId || !apiKey) return;

  pi.registerProvider("cf-compat", {
    baseUrl: `https://gateway.ai.cloudflare.com/v1/${accountId}/${gatewayId}/compat`,
    apiKey: "$CLOUDFLARE_API_TOKEN",
    api: "openai-completions",
    models: [
      {
        id: "deepseek/deepseek-v4-flash",
        name: "DeepSeek V4 Flash",
        reasoning: true,
        input: ["text"],
        contextWindow: 1000000,
        maxTokens: 384000,
        compat: DEEPSEEK_COMPAT,
        thinkingLevelMap: DEEPSEEK_THINKING_LEVEL_MAP,
        ...createCloudflareAIGatewayPricing(0.14, 0.28, 0.0028),
      },
      {
        id: "deepseek/deepseek-v4-pro",
        name: "DeepSeek V4 Pro",
        reasoning: true,
        input: ["text"],
        contextWindow: 1000000,
        maxTokens: 384000,
        compat: DEEPSEEK_COMPAT,
        thinkingLevelMap: DEEPSEEK_THINKING_LEVEL_MAP,
        ...createCloudflareAIGatewayPricing(0.435, 0.87, 0.0036),
      },
    ],
  });
}
