/**
 * Cyber Editor
 * - ❯ glyph: idle breathes pink, running=cyan, thinking=cyan↔purple
 * - aboveEditor HUD: cwd · per-prompt tokens · accurate usage when available,
 *   estimated output while streaming otherwise
 */
import {
  CustomEditor,
  type ExtensionAPI,
  type ExtensionContext,
} from "@mariozechner/pi-coding-agent";
import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { EditorTheme, TUI } from "@mariozechner/pi-tui";
import { truncateToWidth } from "@mariozechner/pi-tui";
import type { KeybindingsManager } from "@mariozechner/pi-coding-agent";

type RGB = [number, number, number];
const PINK: RGB = [247, 118, 142];
const CYAN: RGB = [125, 207, 255];
const PURPLE: RGB = [187, 154, 247];
const DIM: RGB = [86, 95, 137];
const WHITE: RGB = [255, 200, 210];
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

type AgentState = "idle" | "running" | "thinking";
let agentState: AgentState = "idle";

let promptInputTokensTotal = 0;
let promptOutputTokensTotal = 0;
let promptTurnCount = 0;
let promptActive = false;

let currentMessageActive = false;
let currentMessageStartMs = 0;
let currentInputTokens: number | undefined;
let currentOutputTokens: number | undefined;
let estimatedCurrentOutputTokens: number | undefined;
let currentMessageHasAccurateOutput = false;

let firstOutputMs = 0;
let pausedAtMs = 0;
let pausedTotalMs = 0;
let activeToolCalls = 0;

let tps: number | undefined;
let estimatedTps: number | undefined;
let lastKnownOutputTokens: number | undefined;
let lastKnownOutputIsEstimate = false;
let lastKnownTps: number | undefined;
let lastKnownTpsIsEstimate = false;

const GLYPH_WIDTH = 2;
const BREATH_PERIOD = 2800;
const BREATH_FPS_MS = 50;
const ANIM_MS = 60;

class CyberEditorComponent extends CustomEditor {
  private breathTimer?: ReturnType<typeof setInterval>;
  private animTimer?: ReturnType<typeof setInterval>;
  private breathStart = Date.now();
  private animFrame = 0;
  private wasTyping = false;

  constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
    super(tui, theme, keybindings);
    this.setPaddingX(this.getPaddingX() + GLYPH_WIDTH);
    this.startBreath();
  }

  private startBreath(): void {
    this.breathStart = Date.now();
    this.breathTimer = setInterval(() => {
      this.tui.requestRender();
    }, BREATH_FPS_MS);
  }

  private breathAlpha(): number {
    const t = ((Date.now() - this.breathStart) % BREATH_PERIOD) / BREATH_PERIOD;
    const raw = (1 - Math.cos(2 * Math.PI * t)) / 2;
    return raw * raw * (3 - 2 * raw);
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
    if (this.animTimer) {
      clearInterval(this.animTimer);
      this.animTimer = undefined;
    }
  }

  override handleInput(data: string): void {
    super.handleInput(data);
    const typing = this.getText().length > 0;
    if (typing && !this.wasTyping) this.startAnim();
    this.wasTyping = typing;
  }

  private glyphColor(): RGB {
    if (agentState === "running") return CYAN;
    if (agentState === "thinking") return mixRgb(CYAN, PURPLE, this.breathAlpha());
    if (this.animTimer) {
      const t = Math.max(0, 1 - this.animFrame / 10);
      return mixRgb(PINK, WHITE, t);
    }
    return mixRgb(DIM, PINK, this.breathAlpha());
  }

  override render(width: number): string[] {
    const lines = super.render(width);
    if (lines.length <= 2) return lines;

    const glyph = `${rgb(this.glyphColor())}❯${RESET} `;
    for (let i = 1; i < lines.length - 1; i++) {
      const line = lines[i]!;
      lines[i] = i === 1
        ? glyph + truncateToWidth(line, width - GLYPH_WIDTH, "")
        : "  " + truncateToWidth(line, width - GLYPH_WIDTH, "");
    }
    return lines;
  }

  destroy(): void {
    if (this.breathTimer) clearInterval(this.breathTimer);
    this.stopAnim();
  }
}

function formatTokens(n: number): string {
  if (n < 1_000) return `${n}`;
  if (n < 10_000) return `${(n / 1_000).toFixed(1)}k`;
  if (n < 1_000_000) return `${Math.round(n / 1_000)}k`;
  return `${(n / 1_000_000).toFixed(1)}M`;
}

function resetCurrentMessageStats(): void {
  currentMessageActive = false;
  currentMessageStartMs = 0;
  currentInputTokens = undefined;
  currentOutputTokens = undefined;
  estimatedCurrentOutputTokens = undefined;
  currentMessageHasAccurateOutput = false;
}

function resetPromptStats(): void {
  promptInputTokensTotal = 0;
  promptOutputTokensTotal = 0;
  promptTurnCount = 0;
  promptActive = false;
  firstOutputMs = 0;
  pausedAtMs = 0;
  pausedTotalMs = 0;
  activeToolCalls = 0;
  tps = undefined;
  estimatedTps = undefined;
  lastKnownOutputTokens = undefined;
  lastKnownOutputIsEstimate = false;
  lastKnownTps = undefined;
  lastKnownTpsIsEstimate = false;
  resetCurrentMessageStats();
}

function noteOutputStarted(): void {
  if (!firstOutputMs) firstOutputMs = Date.now();
}

function estimateDeltaTokens(delta: string): number {
  let ascii = 0;
  let cjk = 0;
  let other = 0;

  for (const ch of delta) {
    const code = ch.codePointAt(0) ?? 0;
    if (
      (code >= 0x3400 && code <= 0x9fff) ||
      (code >= 0xf900 && code <= 0xfaff) ||
      (code >= 0x3040 && code <= 0x30ff) ||
      (code >= 0xac00 && code <= 0xd7af)
    ) {
      cjk++;
    } else if (code <= 0x7f) {
      ascii++;
    } else {
      other++;
    }
  }

  return cjk + Math.ceil(ascii / 4) + Math.ceil(other / 2);
}

function addEstimatedOutput(delta: string): void {
  const next = estimateDeltaTokens(delta);
  if (next <= 0) return;
  estimatedCurrentOutputTokens = (estimatedCurrentOutputTokens ?? 0) + next;
  recomputeEstimatedTps();
}

function getEffectiveElapsedMs(now = Date.now()): number {
  if (!firstOutputMs) return 0;
  const activePause = pausedAtMs ? now - pausedAtMs : 0;
  return Math.max(0, now - firstOutputMs - pausedTotalMs - activePause);
}

function pauseTps(): void {
  if (!firstOutputMs || pausedAtMs) return;
  pausedAtMs = Date.now();
}

function resumeTps(): void {
  if (!pausedAtMs) return;
  pausedTotalMs += Date.now() - pausedAtMs;
  pausedAtMs = 0;
}

function getExactDisplayOutputTokens(): number | undefined {
  if (currentMessageActive) {
    if (!currentMessageHasAccurateOutput || currentOutputTokens === undefined) return undefined;
    return promptOutputTokensTotal + currentOutputTokens;
  }
  return promptOutputTokensTotal > 0 ? promptOutputTokensTotal : undefined;
}

function getEstimatedDisplayOutputTokens(): number | undefined {
  if (!currentMessageActive) return undefined;
  if (estimatedCurrentOutputTokens === undefined) return undefined;
  return promptOutputTokensTotal + estimatedCurrentOutputTokens;
}

function getExactDisplayInputTokens(): number | undefined {
  if (currentMessageActive) {
    if (currentInputTokens === undefined) return promptInputTokensTotal > 0 ? promptInputTokensTotal : undefined;
    return promptInputTokensTotal + currentInputTokens;
  }
  return promptInputTokensTotal > 0 ? promptInputTokensTotal : undefined;
}

function getInputPlaceholder(): string {
  if (!promptActive || !currentMessageActive) return "↑…";
  if (promptInputTokensTotal > 0) return `↑${formatTokens(promptInputTokensTotal)}+…`;
  return "↑…";
}

function recomputeTps(): void {
  const output = getExactDisplayOutputTokens();
  if (output !== undefined && output > 0) {
    lastKnownOutputTokens = output;
    lastKnownOutputIsEstimate = false;
  }
  if (output === undefined || output <= 0 || !firstOutputMs) return;
  const elapsed = getEffectiveElapsedMs() / 1000;
  if (elapsed > 0) {
    tps = output / elapsed;
    lastKnownTps = tps;
    lastKnownTpsIsEstimate = false;
  }
}

function recomputeEstimatedTps(): void {
  const output = getEstimatedDisplayOutputTokens();
  if (output !== undefined && output > 0 && lastKnownOutputTokens === undefined) {
    lastKnownOutputTokens = output;
    lastKnownOutputIsEstimate = true;
  }
  if (output === undefined || output <= 0 || !firstOutputMs) return;
  const elapsed = getEffectiveElapsedMs() / 1000;
  if (elapsed > 0) {
    estimatedTps = output / elapsed;
    if (lastKnownTps === undefined) {
      lastKnownTps = estimatedTps;
      lastKnownTpsIsEstimate = true;
    }
  }
}

function getTpsColor(tpsValue: number): "success" | "accent" | "warning" | "error" {
  return tpsValue > 300 ? "success" :
    tpsValue > 150 ? "accent" :
    tpsValue > 50 ? "warning" :
    "error";
}

function syncUsage(message: AssistantMessage, isFinal = false): void {
  const usage = message.usage;

  if (isFinal || usage.input > 0) {
    currentInputTokens = usage.input;
  }

  if (isFinal || usage.output > 0 || currentOutputTokens !== undefined) {
    currentOutputTokens = usage.output;
    if (isFinal || usage.output > 0) {
      currentMessageHasAccurateOutput = true;
    }
    recomputeTps();
  }
}

function commitCurrentMessage(): void {
  promptInputTokensTotal += currentInputTokens ?? 0;
  promptOutputTokensTotal += currentOutputTokens ?? 0;
  estimatedTps = undefined;
  resetCurrentMessageStats();
  recomputeTps();
}

function attachHUD(ctx: ExtensionContext): void {
  ctx.ui.setWidget(
    "cyber-hud",
    (_tui, theme) => ({
      invalidate(): void {},
      render(width: number): string[] {
        const home = process.env.HOME ?? "";
        const cwd = ctx.cwd ?? "";
        const shortCwd = home && cwd.startsWith(home) ? "~" + cwd.slice(home.length) : cwd;

        const pathStr = theme.fg("dim", shortCwd);
        const inputTokens = getExactDisplayInputTokens();
        const exactOutputTokens = getExactDisplayOutputTokens();
        const estimatedOutputTokens = getEstimatedDisplayOutputTokens();
        const displayOutputTokens = exactOutputTokens ?? estimatedOutputTokens ?? lastKnownOutputTokens;
        const displayOutputIsEstimate = exactOutputTokens === undefined &&
          (estimatedOutputTokens !== undefined || lastKnownOutputIsEstimate);
        const displayTps = tps ?? estimatedTps ?? lastKnownTps;
        const displayTpsIsEstimate = tps === undefined && (estimatedTps !== undefined || lastKnownTpsIsEstimate);

        if (
          !promptActive &&
          inputTokens === undefined &&
          displayOutputTokens === undefined &&
          displayTps === undefined
        ) {
          return [truncateToWidth(pathStr, width)];
        }

        const sep = theme.fg("dim", " ∷ ");
        const turnStr = theme.fg("dim", `↻${Math.max(1, promptTurnCount)}`);
        const inStr = inputTokens === undefined
          ? theme.fg("dim", getInputPlaceholder())
          : theme.fg("muted", `↑${formatTokens(inputTokens)}`);

        let outStr = theme.fg("dim", "↓-");
        if (displayOutputTokens !== undefined) {
          const label = `${displayOutputIsEstimate ? "~" : ""}↓${formatTokens(displayOutputTokens)}`;
          outStr = displayOutputIsEstimate
            ? theme.fg(activeToolCalls > 0 ? "dim" : "muted", label)
            : theme.fg(activeToolCalls > 0 ? "dim" : "accent", label);
        }

        let tpsStr = theme.fg("dim", "-t/s");
        if (displayTps !== undefined && Number.isFinite(displayTps) && displayTps > 0) {
          const label = `${displayTpsIsEstimate ? "~" : ""}${displayTps.toFixed(0)}t/s`;
          const tpsColor = getTpsColor(displayTps);
          tpsStr = agentState === "thinking" || agentState === "idle"
            ? theme.fg("dim", label)
            : theme.fg(tpsColor, label);
        }

        const line = `${pathStr}${sep}${turnStr}${sep}${inStr} ${outStr}${sep}${tpsStr}`;
        return [truncateToWidth(line, width)];
      },
    }),
    { placement: "aboveEditor" },
  );
}

function attach(ctx: ExtensionContext): void {
  if (!ctx.hasUI) return;
  ctx.ui.setEditorComponent((tui, theme, kb) => new CyberEditorComponent(tui, theme, kb));
  attachHUD(ctx);
}

export default function cyberEditor(pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    resetPromptStats();
    attach(ctx);
  });

  pi.on("session_switch", async (_event, ctx) => {
    resetPromptStats();
    attach(ctx);
  });

  pi.on("agent_start", async () => {
    resetPromptStats();
    promptActive = true;
    agentState = "running";
  });

  pi.on("turn_start", async () => {
    promptTurnCount++;
    agentState = "running";
  });

  pi.on("agent_end", async () => {
    resumeTps();
    promptActive = false;
    agentState = "idle";
    recomputeTps();
    recomputeEstimatedTps();
  });

  pi.on("tool_call", async () => {
    activeToolCalls++;
    pauseTps();
    agentState = "thinking";
  });

  pi.on("tool_result", async () => {
    activeToolCalls = Math.max(0, activeToolCalls - 1);
    if (activeToolCalls === 0) {
      resumeTps();
      recomputeTps();
      recomputeEstimatedTps();
      agentState = "running";
    }
  });

  pi.on("message_start", async (event) => {
    if (event.message.role !== "assistant") return;

    resetCurrentMessageStats();
    currentMessageActive = true;
    currentMessageStartMs = Date.now();
    syncUsage(event.message);
  });

  pi.on("message_update", async (event) => {
    const e = event.assistantMessageEvent;

    if (e.type === "text_delta" || e.type === "thinking_delta" || e.type === "toolcall_delta") {
      noteOutputStarted();
      addEstimatedOutput(e.delta);
      syncUsage(e.partial);
      return;
    }

    if (
      e.type === "start" ||
      e.type === "text_start" ||
      e.type === "text_end" ||
      e.type === "thinking_start" ||
      e.type === "thinking_end" ||
      e.type === "toolcall_start" ||
      e.type === "toolcall_end"
    ) {
      syncUsage(e.partial);
      return;
    }

    if (e.type === "done") {
      if (!firstOutputMs && e.message.usage.output > 0) {
        firstOutputMs = currentMessageStartMs || Date.now();
      }
      syncUsage(e.message, true);
      recomputeTps();
      return;
    }

    if (e.type === "error") {
      if (!firstOutputMs && e.error.usage.output > 0) {
        firstOutputMs = currentMessageStartMs || Date.now();
      }
      syncUsage(e.error, true);
      recomputeTps();
    }
  });

  pi.on("turn_end", async (event) => {
    if (event.message.role !== "assistant") return;

    resumeTps();
    if (!firstOutputMs && event.message.usage.output > 0) {
      firstOutputMs = currentMessageStartMs || Date.now();
    }
    syncUsage(event.message, true);
    commitCurrentMessage();
    recomputeTps();
  });
}
