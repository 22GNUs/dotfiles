/**
 * Shared helpers for Cloudflare AI Gateway provider extensions.
 */
export function createCloudflareAIGatewayPricing(input: number, output: number, cacheRead = 0, cacheWrite = 0) {
  const perToken = (value: number) => value / 1_000_000;
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
