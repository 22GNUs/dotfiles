/**
 * Cyber Editor
 * - ❯ glyph: idle=pink blink, agent=cyan, thinking=cyan↔purple pulse
 * - aboveEditor HUD: cwd · input↑ output↓ · tok/s
 */
import {
  CustomEditor,
  type ExtensionAPI,
  type ExtensionContext,
} from "@mariozechner/pi-coding-agent";
import type { EditorTheme, TUI } from "@mariozechner/pi-tui";
import { truncateToWidth } from "@mariozechner/pi-tui";
import type { KeybindingsManager } from "@mariozechner/pi-coding-agent";

// ─── Colors ────────────────────────────────────────────────────
type RGB = [number, number, number];
const PINK:   RGB = [247, 118, 142];
const CYAN:   RGB = [125, 207, 255];
const PURPLE: RGB = [187, 154, 247];
const DIM:    RGB = [86,  95,  137];
const WHITE:  RGB = [255, 200, 210];
const RESET = "\x1b[39m";

function rgb(c: RGB): string {
  return `\x1b[38;2;${c[0]};${c[1]};${c[2]}m`;
}
function mixRgb(a: RGB, b: RGB, t: number): RGB {
  return [
    Math.round(a[0] + (b[0] - a[0]) * t),
    Math.round(a[1] + (b[1] - a[1]) * t),
    Math.round(a[2] + (b[2] - a[2]) * t),
  ];
}

// ─── Shared state ─────────────────────────────────────────────
type AgentState = "idle" | "running" | "thinking";
let agentState: AgentState = "idle";

// Token tracking
let turnInputTokens  = 0;
let turnOutputTokens = 0;
let outputDeltaCount = 0;   // live output token proxy during streaming
let turnStartMs      = 0;
let tps              = 0;
let isStreaming       = false;

const GLYPH_WIDTH = 2;
const BLINK_MS    = 530;
const ANIM_MS     = 60;
const PULSE_MS    = 350;    // faster pulse period

// ─── Editor ───────────────────────────────────────────────────
class CyberEditorComponent extends CustomEditor {
  private blinkTimer?: ReturnType<typeof setInterval>;
  private animTimer?:  ReturnType<typeof setInterval>;
  private blinkOn   = true;
  private animFrame = 0;
  private wasTyping = false;

  constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
    super(tui, theme, keybindings);
    this.setPaddingX(this.getPaddingX() + GLYPH_WIDTH);
    this.startBlink();
  }

  private startBlink(): void {
    this.blinkTimer = setInterval(() => {
      this.blinkOn = !this.blinkOn;
      this.tui.requestRender();
    }, BLINK_MS);
  }

  private startAnim(): void {
    if (this.animTimer) return;
    this.animFrame = 0;
    this.animTimer = setInterval(() => {
      this.animFrame++;
      this.tui.requestRender();
      if (this.animFrame > 10) this.stopAnim();
    }, ANIM_MS);
  }

  private stopAnim(): void {
    if (this.animTimer) { clearInterval(this.animTimer); this.animTimer = undefined; }
  }

  override handleInput(data: string): void {
    super.handleInput(data);
    const typing = this.getText().length > 0;
    if (typing && !this.wasTyping) this.startAnim();
    this.wasTyping = typing;
  }

  private glyphColor(): RGB {
    if (agentState === "thinking") {
      // Strong pulse: full swing between cyan and purple
      const t = (Math.sin(Date.now() / PULSE_MS) + 1) / 2;
      return mixRgb(CYAN, PURPLE, t);
    }
    if (agentState === "running") return CYAN;
    // idle blink
    if (!this.blinkOn) return DIM;
    // typing burst
    if (this.animTimer) {
      const t = Math.max(0, 1 - this.animFrame / 10);
      return mixRgb(PINK, WHITE, t);
    }
    return PINK;
  }

  override render(width: number): string[] {
    const lines = super.render(width);
    if (lines.length <= 2) return lines;
    const c = this.glyphColor();
    const glyph = `${rgb(c)}❯${RESET} `;
    for (let i = 1; i < lines.length - 1; i++) {
      const line = lines[i]!;
      lines[i] = i === 1
        ? glyph + truncateToWidth(line, width - GLYPH_WIDTH, "")
        : "  "  + truncateToWidth(line, width - GLYPH_WIDTH, "");
    }
    return lines;
  }

  destroy(): void {
    if (this.blinkTimer) clearInterval(this.blinkTimer);
    this.stopAnim();
  }
}

// ─── HUD ──────────────────────────────────────────────────────
function formatTokens(n: number): string {
  if (n < 1_000) return `${n}`;
  if (n < 10_000) return `${(n / 1_000).toFixed(1)}k`;
  return `${Math.round(n / 1_000)}k`;
}

function attachHUD(ctx: ExtensionContext, getLevel: () => string): void {
  ctx.ui.setWidget(
    "cyber-hud",
    (_tui, theme) => ({
      render(width: number): string[] {
        const home = process.env.HOME ?? "";
        const cwd  = ctx.cwd ?? "";
        const shortCwd = home && cwd.startsWith(home) ? "~" + cwd.slice(home.length) : cwd;

        const sep = theme.fg("dim", " ∷ ");
        const pathStr = theme.fg("dim", shortCwd);

        // no data yet — just show cwd
        if (turnInputTokens === 0 && outputDeltaCount === 0) {
          return [truncateToWidth(pathStr, width)];
        }

        // tokens: input from turn_end (accurate), output live chars count
        const displayOutput = outputDeltaCount;
        let tokenStr: string;
        if (turnInputTokens > 0 || displayOutput > 0) {
          const inStr  = theme.fg("muted", `↑${formatTokens(turnInputTokens)}`);
          const outStr = theme.fg("accent", `↓${formatTokens(displayOutput)}`);
          tokenStr = `${inStr} ${outStr}`;
        } else {
          tokenStr = theme.fg("dim", "↑— ↓—");
        }

        // tps — 4-tier color based on speed
        let tpsStr: string;
        if (tps > 0) {
          const tpsColor =
            tps > 300 ? "teal" :    // blazing
            tps > 150 ? "accent" :  // fast
            tps > 50  ? "warning" : // slow
                        "error";    // crawling
          const tpsLabel = theme.fg(tpsColor, `${tps.toFixed(0)}t/s`);
          tpsStr = agentState === "idle" ? theme.fg("dim", `${tps.toFixed(0)}t/s`) : tpsLabel;
        } else {
          tpsStr = theme.fg("dim", "—t/s");
        }

        const line = `${pathStr}${sep}${tokenStr}${sep}${tpsStr}`;
        return [truncateToWidth(line, width)];
      },
    }),
    { placement: "aboveEditor" },
  );
}

// ─── Extension entry ──────────────────────────────────────────
function attach(ctx: ExtensionContext, getLevel: () => string): void {
  if (!ctx.hasUI) return;
  ctx.ui.setEditorComponent((tui, theme, kb) => new CyberEditorComponent(tui, theme, kb));
  attachHUD(ctx, getLevel);
}

export default function cyberEditor(pi: ExtensionAPI) {
  const getLevel = () =>
    typeof pi.getThinkingLevel === "function" ? pi.getThinkingLevel() : "off";

  pi.on("session_start",  async (_e, ctx) => {
    turnInputTokens = turnOutputTokens = outputDeltaCount = tps = 0;
    attach(ctx, getLevel);
  });
  pi.on("session_switch", async (_e, ctx) => {
    turnInputTokens = turnOutputTokens = outputDeltaCount = tps = 0;
    attach(ctx, getLevel);
  });

  pi.on("agent_start", async (_e, ctx) => {
    agentState = "running";
    isStreaming = true;
    // capture input tokens immediately from context usage
    const usage = ctx.getContextUsage?.();
    turnInputTokens  = usage?.tokens ?? 0;
    turnOutputTokens = 0;
    outputDeltaCount = 0;
    tps = 0;
    turnStartMs = Date.now();
  });

  pi.on("agent_end", async () => {
    agentState = "idle";
    isStreaming = false;
  });

  pi.on("tool_call",   async () => { agentState = "thinking"; });
  pi.on("tool_result", async () => { agentState = "running"; });

  // Reset per-message counters when assistant message starts (includes thinking)
  pi.on("message_start", async (event) => {
    if (event.message.role === "assistant") {
      isStreaming = true;
    }
  });

  // Real-time token tracking — count chars as token proxy
  pi.on("message_update", async (event) => {
    const e = event.assistantMessageEvent;
    if (e.type === "text_delta") {
      outputDeltaCount += e.delta.length;
    } else if (e.type === "thinking_delta") {
      outputDeltaCount += e.delta.length;
    }
    const elapsed = (Date.now() - turnStartMs) / 1000;
    if (elapsed > 0) tps = outputDeltaCount / elapsed;
  });

  // turn_end: only update input tokens (accurate), keep output/tps from live count
  pi.on("turn_end", async (event) => {
    isStreaming = false;
    const msg = event.message;
    if (msg.role === "assistant" && msg.usage) {
      turnInputTokens = msg.usage.input ?? 0;
    }
  });
}
