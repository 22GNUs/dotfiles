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
): { texts: string[]; signature: string } {
  const entries = Array.from(footerData.getExtensionStatuses().entries())
    .filter(([, value]) => value.trim().length > 0)
    .sort(([a], [b]) => a.localeCompare(b));

  const signature = entries
    .map(([key, value]) => `${key}\u0000${value}`)
    .join("\u0001");

  return {
    texts: entries.map(([, value]) => theme.fg("muted", value)),
    signature,
  };
}

/**
 * 根据可用宽度，尽量展示更多状态，放不下时折叠为 +N。
 */
function fitStatusText(
  theme: Theme,
  texts: string[],
  availableWidth: number,
): string {
  if (texts.length === 0) return "";

  const sep = theme.fg("dim", " · ");
  const sepWidth = visibleWidth(sep);

  let result = "";
  let shown = 0;

  for (let i = 0; i < texts.length; i++) {
    const candidate = texts[i]!;
    const remaining = texts.length - i - 1;
    const suffix =
      remaining > 0 ? theme.fg("dim", ` +${remaining}`) : "";
    const suffixWidth = remaining > 0 ? visibleWidth(suffix) : 0;

    const needed =
      (shown > 0 ? sepWidth : 0) +
      visibleWidth(candidate) +
      suffixWidth;

    if (visibleWidth(result) + needed <= availableWidth) {
      result += (shown > 0 ? sep : "") + candidate;
      shown++;
    } else {
      // 放不下当前项，折叠剩余
      const collapse = texts.length - shown;
      if (collapse > 0) {
        result += theme.fg("dim", ` +${collapse}`);
      }
      return result;
    }
  }

  return result;
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
  statusCount: number;
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
    a.statusSignature === b.statusSignature &&
    a.statusCount === b.statusCount
  );
}

function renderLine(
  width: number,
  theme: Theme,
  ctx: ExtensionContext,
  thinkingLevel: string,
  statusTexts: string[],
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
  const left = `${model}${sep}${thinking}`;
  const leftWidth = visibleWidth(left);
  const contextWidth = visibleWidth(context);
  const sepWidth = visibleWidth(sep);

  if (statusTexts.length > 0) {
    // 计算 status 可用宽度：总宽 - left - sep - sep - context - 至少1个空格
    const availableForStatus =
      width - leftWidth - sepWidth - sepWidth - contextWidth - 1;
    const statusText =
      availableForStatus > 0
        ? fitStatusText(theme, statusTexts, availableForStatus)
        : "";

    if (statusText) {
      const right = `${statusText}${sep}${context}`;
      const pad = " ".repeat(
        Math.max(1, width - leftWidth - visibleWidth(right)),
      );
      return truncateToWidth(left + pad + right, width);
    }
  }

  // 没有 status 或放不下：只保留 model + thinking + context
  const right = context;
  if (leftWidth + 1 + contextWidth <= width) {
    const pad = " ".repeat(Math.max(1, width - leftWidth - contextWidth));
    return truncateToWidth(left + pad + right, width);
  }

  // 再降级：去掉 thinking
  const compact = `${left}${sep}${context}`;
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
            statusCount: statusInfo.texts.length,
          };

          if (cachedLines && cacheKeyEquals(cachedKey, key)) {
            return cachedLines;
          }

          cachedLines = [
            renderLine(width, theme, ctx, thinkingLevel, statusInfo.texts),
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
