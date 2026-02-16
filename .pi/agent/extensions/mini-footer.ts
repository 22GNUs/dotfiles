import type { ExtensionAPI, Theme } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";

const ICONS = {
  model: "🤖",
  thinking: "🧠",
  context: "🪟",
};

const RAINBOW = ["#b281d6", "#d787af", "#febc38", "#e4c00f", "#89d281", "#00afaf", "#178fb9"];

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

function shortThinkingLevel(level: string): string {
  const map: Record<string, string> = {
    off: "off",
    minimal: "min",
    low: "low",
    medium: "med",
    high: "high",
    xhigh: "xhigh",
  };
  return map[level] ?? level;
}

function formatModelLabel(model: { name?: string; id: string } | undefined): string {
  if (!model) return "no-model";
  const name = model.name?.trim();
  if (name && name.length > 0) return name.replace(/^Claude\s+/i, "");
  const slash = model.id.lastIndexOf("/");
  return slash >= 0 ? model.id.slice(slash + 1) : model.id;
}

function thinkingText(theme: Theme, level: string): string {
  const label = `think:${shortThinkingLevel(level)}`;
  if (level === "high" || level === "xhigh") {
    return `${theme.fg("muted", `${ICONS.thinking} `)}${rainbow(label)}`;
  }
  return theme.fg("muted", `${ICONS.thinking} ${label}`);
}

function contextText(theme: Theme, usedTokens: number, contextWindow: number): string {
  const percent = contextWindow > 0 ? (usedTokens / contextWindow) * 100 : 0;
  const core =
    contextWindow > 0
      ? `${formatTokens(usedTokens)}/${formatTokens(contextWindow)} ${percent.toFixed(1)}%`
      : `${formatTokens(usedTokens)}`;

  const color = percent >= 90 ? "error" : percent >= 70 ? "warning" : "dim";
  return theme.fg(color, `${ICONS.context} ${core}`);
}

function renderLine(width: number, theme: Theme, ctx: any, getThinkingLevel: () => string): string {
  const model = theme.fg("accent", `${ICONS.model} ${formatModelLabel(ctx.model)}`);
  const thinking = thinkingText(theme, getThinkingLevel());

  const usage = ctx.getContextUsage?.();
  const usedTokens = usage?.tokens ?? 0;
  const contextWindow = ctx.model?.contextWindow ?? 0;
  const context = contextText(theme, usedTokens, contextWindow);

  const sep = theme.fg("dim", " · ");
  const left = `${model}${sep}${thinking}`;

  if (visibleWidth(left) + 1 + visibleWidth(context) <= width) {
    const pad = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(context)));
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
