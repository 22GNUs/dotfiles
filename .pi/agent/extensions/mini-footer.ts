import type { ExtensionAPI, Theme } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

const ICONS = {
  model: "🐱",
  context: "",
};

const RAINBOW = [
  "#b281d6",
  "#d787af",
  "#febc38",
  "#e4c00f",
  "#89d281",
  "#00afaf",
  "#178fb9",
];

function toAnsiHex(hex: string): string {
  const value = hex.slice(1);
  const r = Number.parseInt(value.slice(0, 2), 16);
  const g = Number.parseInt(value.slice(2, 4), 16);
  const b = Number.parseInt(value.slice(4, 6), 16);
  return `\u001b[38;2;${r};${g};${b}m`;
}

function rainbow(text: string): string {
  let out = "";
  let i = 0;
  for (const ch of text) {
    if (ch.trim().length === 0 || ch === ":") {
      out += ch;
      continue;
    }
    out += `${toAnsiHex(RAINBOW[i % RAINBOW.length] ?? "#ffffff")}${ch}`;
    i += 1;
  }
  return `${out}\u001b[0m`;
}

function formatTokens(value: number): string {
  if (value < 1_000) return `${value}`;
  if (value < 10_000) return `${(value / 1_000).toFixed(1)}k`;
  if (value < 1_000_000) return `${Math.round(value / 1_000)}k`;
  if (value < 10_000_000) return `${(value / 1_000_000).toFixed(1)}M`;
  return `${Math.round(value / 1_000_000)}M`;
}

function normalizeThinkingLevel(level: string): string {
  const known = new Set(["off", "minimal", "low", "medium", "high", "xhigh"]);
  return known.has(level) ? level : "off";
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
    return rainbow(normalized);
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

function progressBar(theme: Theme, percent: number, width = 10): string {
  const clamped = Math.max(0, Math.min(100, percent));
  const filled = Math.round((clamped / 100) * width);
  const color = clamped >= 90 ? "error" : clamped >= 70 ? "warning" : "success";

  const left = theme.fg("dim", "[");
  const filledPart = filled > 0 ? theme.fg(color, "█".repeat(filled)) : "";
  const emptyPart =
    filled < width ? theme.fg("dim", "░".repeat(width - filled)) : "";
  const right = theme.fg("dim", "]");

  return `${left}${filledPart}${emptyPart}${right}`;
}

function contextText(
  theme: Theme,
  usedTokens: number,
  contextWindow: number,
): string {
  if (contextWindow <= 0) {
    return theme.fg("dim", `${ICONS.context} ${formatTokens(usedTokens)}`);
  }

  const percent = (usedTokens / contextWindow) * 100;
  const bar = progressBar(theme, percent);
  const usage = theme.fg(
    "dim",
    `${formatTokens(usedTokens)}/${formatTokens(contextWindow)}`,
  );
  const icon = theme.fg("dim", `${ICONS.context}`);

  return `${icon} ${bar} ${usage}`;
}

function renderLine(
  width: number,
  theme: Theme,
  ctx: any,
  getThinkingLevel: () => string,
): string {
  const model = theme.fg(
    "accent",
    `${ICONS.model} ${formatModelLabel(ctx.model)}`,
  );
  const thinking = thinkingText(theme, getThinkingLevel());

  const usage = ctx.getContextUsage?.();
  const usedTokens = usage?.tokens ?? 0;
  const contextWindow = ctx.model?.contextWindow ?? 0;
  const context = contextText(theme, usedTokens, contextWindow);

  const sep = theme.fg("dim", " · ");
  const left = `${model}${sep}${thinking}`;

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

function attachFooter(ctx: any, getThinkingLevel: () => string): void {
  ctx.ui.setFooter((_tui: any, theme: Theme) => ({
    invalidate() {},
    render(width: number): string[] {
      return [renderLine(width, theme, ctx, getThinkingLevel)];
    },
  }));
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
