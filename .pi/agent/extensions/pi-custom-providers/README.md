# pi-custom-providers

This package splits the Cloudflare provider registrations into separate extension entries so they can be enabled or disabled independently via `pi config`.

## Entries

- `custom-provider-cf-compat.ts` → `cf-compat`
- `custom-provider-cf-packycode.ts` → `cf-packycode`
- `custom-provider-cf-codex.ts` → `cf-codex`
- `custom-provider-cliproxyapi.ts` → `cliproxyapi`

## Required environment variables

- `CLOUDFLARE_ACCOUNT_ID`
- `CLOUDFLARE_GATEWAY_ID`
- `CLOUDFLARE_API_TOKEN`
- `CLIPROXYAPI_API_KEY`
