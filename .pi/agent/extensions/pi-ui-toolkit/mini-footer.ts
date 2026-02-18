import type {
  ContextUsage,
  ExtensionAPI,
  ExtensionContext,
  ReadonlyFooterDataProvider,
  Theme,
  ThemeColor,
} from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

const ICONS = {
  model: "🐱",
  context: "",
};

const THINKING_HIGH_COLORS: readonly ThemeColor[] = [
  "accent",
  "success",
  "warning",
  "error",
  "muted",
];

const CONTEXT_PERCENT_COLORS: readonly { max: number; color: ThemeColor }[] = [
  { max: 55, color: "success" },
  { max: 75, color: "accent" },
  { max: 90, color: "warning" },
  { max: Number.POSITIVE_INFINITY, color: "error" },
];

const KNOWN_THINKING_LEVELS = new Set([
  "off",
  "minimal",
  "low",
  "medium",
  "high",
  "xhigh",
]);

function rainbow(theme: Theme, text: string): string {
  let out = "";
  let i = 0;

  for (const ch of text) {
    if (ch.trim().length === 0 || ch === ":") {
      out += ch;
      continue;
    }

    const color =
      THINKING_HIGH_COLORS[i % THINKING_HIGH_COLORS.length] ?? "accent";
    out += theme.fg(color, ch);
    i += 1;
  }

  return out;
}

function formatTokens(value: number): string {
  if (value < 1_000) return `${value}`;
  if (value < 10_000) return `${(value / 1_000).toFixed(1)}k`;
  if (value < 1_000_000) return `${Math.round(value / 1_000)}k`;
  if (value < 10_000_000) return `${(value / 1_000_000).toFixed(1)}M`;
  return `${Math.round(value / 1_000_000)}M`;
}

function normalizeThinkingLevel(level: string): string {
  return KNOWN_THINKING_LEVELS.has(level) ? level : "off";
}

function formatModelLabel(
  model: { name?: string; id: string } | undefined,
): string {
  if (!model) return "no-model";
  const name = model.name?.trim();
  if (name && name.length > 0) return name.replace(/^Claude\s+/i, "");
  const slash = model.id.lastIndexOf("/");
  return slash >= 0 ? model.id.slice(slash + 1) : model.id;
}

function thinkingText(theme: Theme, level: string): string {
  const normalized = normalizeThinkingLevel(level);

  if (normalized === "high" || normalized === "xhigh") {
    return rainbow(theme, normalized);
  }

  switch (normalized) {
    case "off":
      return theme.fg("dim", normalized);
    case "minimal":
      return theme.fg("muted", normalized);
    case "low":
      return theme.fg("accent", normalized);
    case "medium":
      return theme.fg("success", normalized);
    default:
      return theme.fg("muted", normalized);
  }
}

function colorForContextPercent(percent: number): ThemeColor {
  for (const step of CONTEXT_PERCENT_COLORS) {
    if (percent <= step.max) return step.color;
  }
  return "error";
}

function formatContextPercent(percent: number): string {
  if (!Number.isFinite(percent)) return "0.00";

  const abs = Math.abs(percent);
  if (abs < 10) return percent.toFixed(2);
  if (abs < 100) return percent.toFixed(1);
  return percent.toFixed(0);
}

function progressBar(theme: Theme, percent: number, width = 12): string {
  const clamped = Math.max(0, Math.min(100, percent));
  const color = colorForContextPercent(clamped);

  // Use 1/8 block steps to make progress changes smoother.
  const totalUnits = width * 8;
  const filledUnits = Math.round((clamped / 100) * totalUnits);
  const fullBlocks = Math.floor(filledUnits / 8);
  const partialIndex = filledUnits % 8;
  const partials = ["", "▏", "▎", "▍", "▌", "▋", "▊", "▉"];

  const partial = partials[partialIndex] ?? "";
  const occupiedCells = fullBlocks + (partial ? 1 : 0);
  const emptyCells = Math.max(0, width - occupiedCells);

  const left = theme.fg("dim", "[");
  const full = fullBlocks > 0 ? theme.fg(color, "█".repeat(fullBlocks)) : "";
  const part = partial ? theme.fg(color, partial) : "";
  const empty = emptyCells > 0 ? theme.fg("dim", "░".repeat(emptyCells)) : "";
  const right = theme.fg("dim", "]");

  return `${left}${full}${part}${empty}${right}`;
}

function contextText(
  theme: Theme,
  usedTokens: number,
  contextWindow: number,
): string {
  const icon = theme.fg("accent", ICONS.context);

  if (contextWindow <= 0) {
    return `${icon} ${theme.fg("dim", formatTokens(usedTokens))}`;
  }

  const percent = (usedTokens / contextWindow) * 100;
  const percentColor = colorForContextPercent(percent);
  const bar = progressBar(theme, percent);
  const usage = theme.fg(
    "dim",
    `${formatTokens(usedTokens)}/${formatTokens(contextWindow)}`,
  );
  const percentNumber = theme.fg(percentColor, formatContextPercent(percent));
  const percentSign = theme.fg("dim", "%");

  return `${icon} ${bar} ${percentNumber}${percentSign} ${usage}`;
}

function getStatusInfo(
  theme: Theme,
  footerData: ReadonlyFooterDataProvider,
): { text: string; signature: string } {
  const entries = Array.from(footerData.getExtensionStatuses().entries())
    .filter(([, value]) => value.trim().length > 0)
    .sort(([a], [b]) => a.localeCompare(b));

  const signature = entries
    .map(([key, value]) => `${key}\u0000${value}`)
    .join("\u0001");
  if (entries.length === 0) {
    return { text: "", signature };
  }

  const first = entries[0]?.[1] ?? "";
  if (entries.length === 1) {
    return {
      text: theme.fg("muted", first),
      signature,
    };
  }

  return {
    text: `${theme.fg("muted", first)}${theme.fg("dim", ` +${entries.length - 1}`)}`,
    signature,
  };
}

/** Cache key components to avoid re-rendering when nothing changed. */
interface CacheKey {
  width: number;
  modelId: string | undefined;
  modelName: string | undefined;
  thinkingLevel: string;
  usedTokens: number;
  contextWindow: number;
  statusSignature: string;
}

function cacheKeyEquals(a: CacheKey | undefined, b: CacheKey): boolean {
  if (!a) return false;
  return (
    a.width === b.width &&
    a.modelId === b.modelId &&
    a.modelName === b.modelName &&
    a.thinkingLevel === b.thinkingLevel &&
    a.usedTokens === b.usedTokens &&
    a.contextWindow === b.contextWindow &&
    a.statusSignature === b.statusSignature
  );
}

function renderLine(
  width: number,
  theme: Theme,
  ctx: ExtensionContext,
  thinkingLevel: string,
  statusText: string,
): string {
  const model = theme.fg(
    "accent",
    `${ICONS.model} ${formatModelLabel(ctx.model)}`,
  );
  const thinking = thinkingText(theme, thinkingLevel);

  const usage: ContextUsage | undefined = ctx.getContextUsage?.();
  const usedTokens = usage?.tokens ?? 0;
  const contextWindow = usage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
  const context = contextText(theme, usedTokens, contextWindow);

  const sep = theme.fg("dim", " · ");
  const left = statusText
    ? `${model}${sep}${thinking}${sep}${statusText}`
    : `${model}${sep}${thinking}`;

  if (visibleWidth(left) + 1 + visibleWidth(context) <= width) {
    const pad = " ".repeat(
      Math.max(1, width - visibleWidth(left) - visibleWidth(context)),
    );
    return truncateToWidth(left + pad + context, width);
  }

  const compact = `${model}${sep}${context}`;
  if (visibleWidth(compact) <= width) {
    return compact;
  }

  return truncateToWidth(`${model} ${context}`, width);
}

function attachFooter(
  ctx: ExtensionContext,
  getThinkingLevel: () => string,
): void {
  ctx.ui.setFooter(
    (_tui, theme: Theme, footerData: ReadonlyFooterDataProvider) => {
      let cachedKey: CacheKey | undefined;
      let cachedLines: string[] | undefined;

      return {
        invalidate() {
          cachedKey = undefined;
          cachedLines = undefined;
        },
        render(width: number): string[] {
          const thinkingLevel = getThinkingLevel();
          const usage: ContextUsage | undefined = ctx.getContextUsage?.();
          const usedTokens = usage?.tokens ?? 0;
          const contextWindow =
            usage?.contextWindow ?? ctx.model?.contextWindow ?? 0;
          const statusInfo = getStatusInfo(theme, footerData);

          const key: CacheKey = {
            width,
            modelId: ctx.model?.id,
            modelName: ctx.model?.name,
            thinkingLevel,
            usedTokens,
            contextWindow,
            statusSignature: statusInfo.signature,
          };

          if (cachedLines && cacheKeyEquals(cachedKey, key)) {
            return cachedLines;
          }

          cachedLines = [
            renderLine(width, theme, ctx, thinkingLevel, statusInfo.text),
          ];
          cachedKey = key;
          return cachedLines;
        },
      };
    },
  );
}

export default function miniFooter(pi: ExtensionAPI) {
  const getThinkingLevel = () => {
    if (typeof pi.getThinkingLevel === "function") return pi.getThinkingLevel();
    return "off";
  };

  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.hasUI) return;
    attachFooter(ctx, getThinkingLevel);
  });

  pi.on("session_switch", async (_event, ctx) => {
    if (!ctx.hasUI) return;
    attachFooter(ctx, getThinkingLevel);
  });
}
