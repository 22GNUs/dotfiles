/**
 * Cyber Editor — cyberpunk HUD + ❯ glyph
 *
 * ❯  idle=silver breath · running=steel silver · thinking=steel pulse
 * HUD  cwd ∷ turn ∷ ↑in ↓out ∷ Nt/s
 */
import {
  CustomEditor,
  type ExtensionAPI,
  type ExtensionContext,
} from "@mariozechner/pi-coding-agent";
import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { EditorTheme, TUI } from "@mariozechner/pi-tui";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";
import type { KeybindingsManager } from "@mariozechner/pi-coding-agent";

// ── palette ───────────────────────────────────────────────────
type RGB = [number, number, number];
const PINK: RGB = [247, 118, 142];
const CYAN: RGB = [125, 207, 255];
const PURPLE: RGB = [187, 154, 247];
const TILDE_PINK: RGB = [255, 130, 184];
const SILVER: RGB = [170, 184, 202];
const STEEL: RGB = [92, 104, 124];
const RUNNING_SILVER: RGB = [126, 142, 164];
const THINKING_LOW: RGB = [108, 118, 142];
const THINKING_HIGH: RGB = [148, 160, 184];
const DIM: RGB = [86, 95, 137];
const WHITE: RGB = [214, 224, 236];
const RESET = "\x1b[39m";
const BOLD = "\x1b[1m";
const UNBOLD = "\x1b[22m";

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

function hotPink(text: string): string {
  return `${BOLD}${rgb(TILDE_PINK)}${text}${UNBOLD}${RESET}`;
}

// ── state ─────────────────────────────────────────────────────
type AgentState = "idle" | "running" | "thinking";
let agentState: AgentState = "idle";

// prompt-level accumulators (reset on agent_start)
let promptIn = 0;
let promptOut = 0;
let promptTurns = 0;
let promptActive = false;

// current assistant message
let msgActive = false;
let msgStartMs = 0;
let msgIn: number | undefined;
let msgOut: number | undefined;
let estOut: number | undefined;
let msgHasAccurateOut = false;

// timing
let firstOutMs = 0;
let pausedAt = 0;
let pausedTotal = 0;
let toolDepth = 0;

// display cache
let tps: number | undefined;
let estTps: number | undefined;
let snapOut: number | undefined;
let snapOutEst = false;
let snapTps: number | undefined;
let snapTpsEst = false;

// ── constants ─────────────────────────────────────────────────
const GLYPH_W = 2;
const BREATH_MS = 3200;
const BREATH_FPS = 50;
const ANIM_MS = 60;
const SEP = " ∷ ";
const TURN_ICON = "󰄉";
const PATH_MAX_DEPTH = 3;

// ── editor component ──────────────────────────────────────────
class CyberEditor extends CustomEditor {
  private breath?: ReturnType<typeof setInterval>;
  private anim?: ReturnType<typeof setInterval>;
  private breathT0 = Date.now();
  private frame = 0;
  private typed = false;

  constructor(tui: TUI, theme: EditorTheme, kb: KeybindingsManager) {
    super(tui, theme, kb);
    this.setPaddingX(this.getPaddingX() + GLYPH_W);
    this.breathT0 = Date.now();
    this.breath = setInterval(() => this.tui.requestRender(), BREATH_FPS);
  }

  private alpha(): number {
    const t = ((Date.now() - this.breathT0) % BREATH_MS) / BREATH_MS;
    return (1 - Math.cos(2 * Math.PI * t)) / 2;
  }

  override handleInput(data: string): void {
    super.handleInput(data);
    const t = this.getText().length > 0;
    if (t && !this.typed) this.startAnim();
    this.typed = t;
  }

  private startAnim(): void {
    if (this.anim) return;
    this.frame = 0;
    this.anim = setInterval(() => {
      this.frame++;
      this.tui.requestRender();
      if (this.frame > 10) this.stopAnim();
    }, ANIM_MS);
  }
  private stopAnim(): void {
    if (this.anim) { clearInterval(this.anim); this.anim = undefined; }
  }

  private color(): RGB {
    if (agentState === "running") return RUNNING_SILVER;
    if (agentState === "thinking") return mixRgb(THINKING_LOW, THINKING_HIGH, this.alpha());
    if (this.anim) return mixRgb(SILVER, WHITE, Math.max(0, 1 - this.frame / 10));
    return mixRgb(STEEL, SILVER, this.alpha());
  }

  override render(w: number): string[] {
    const lines = super.render(w);
    if (lines.length <= 2) return lines;
    const g = `${rgb(this.color())}❯${RESET} `;
    for (let i = 1; i < lines.length - 1; i++) {
      lines[i] = i === 1
        ? g + truncateToWidth(lines[i]!, w - GLYPH_W, "")
        : "  " + truncateToWidth(lines[i]!, w - GLYPH_W, "");
    }
    return lines;
  }

  destroy(): void {
    if (this.breath) clearInterval(this.breath);
    this.stopAnim();
  }
}

// ── helpers ───────────────────────────────────────────────────
function fmt(n: number): string {
  if (n < 1_000) return `${n}`;
  if (n < 10_000) return `${(n / 1_000).toFixed(1)}k`;
  if (n < 1_000_000) return `${Math.round(n / 1_000)}k`;
  return `${(n / 1_000_000).toFixed(1)}M`;
}

function tpsColor(v: number): "success" | "accent" | "warning" | "error" {
  return v > 300 ? "success" : v > 150 ? "accent" : v > 50 ? "warning" : "error";
}

function shortenPath(raw: string, maxWidth: number): string {
  if (maxWidth <= 0) return "";

  let prefix = "";
  let parts: string[];
  if (raw === "~") return raw;
  if (raw.startsWith("~/")) {
    parts = ["~", ...raw.slice(2).split("/").filter(Boolean)];
  } else if (raw.startsWith("/")) {
    prefix = "/";
    parts = raw.slice(1).split("/").filter(Boolean);
  } else {
    parts = raw.split("/").filter(Boolean);
  }

  const join = (segments: string[]): string => {
    if (segments.length === 0) return prefix || raw;
    const body = segments.join("/");
    return prefix ? prefix + body : body;
  };

  const foldByDepth = (segments: string[]): string[] => {
    const hasRootMarker = segments[0] === "~";
    const offset = hasRootMarker ? 1 : 0;
    const logicalDepth = Math.max(0, segments.length - offset);
    if (logicalDepth <= PATH_MAX_DEPTH) return segments;
    return [segments[0]!, "…", ...segments.slice(-2)];
  };

  const depthFolded = foldByDepth(parts);
  const full = join(depthFolded);
  if (full.length <= maxWidth) return full;

  if (depthFolded.length > 2) {
    const initialed = depthFolded.map((part, index) => {
      if (part === "…") return part;
      if (index === 0 || index >= depthFolded.length - 2) return part;
      return part[0] ?? part;
    });
    const candidate = join(initialed);
    if (candidate.length <= maxWidth) return candidate;
  }

  if (depthFolded.length >= 2) {
    const tail2 = join([depthFolded[0]!, "…", ...depthFolded.slice(-2)]);
    if (tail2.length <= maxWidth) return tail2;

    const tail1 = join([depthFolded[0]!, "…", depthFolded[depthFolded.length - 1]!]);
    if (tail1.length <= maxWidth) return tail1;
  }

  if (maxWidth === 1) return "…";
  return `…${full.slice(-(maxWidth - 1))}`;
}

function stylePath(theme: any, raw: string): string {
  if (raw.length === 0) return "";

  let prefix = "";
  let parts: string[];
  if (raw.startsWith("~/")) {
    parts = ["~", ...raw.slice(2).split("/").filter(Boolean)];
  } else if (raw === "~") {
    parts = ["~"];
  } else if (raw.startsWith("/")) {
    prefix = theme.fg("dim", "/");
    parts = raw.slice(1).split("/").filter(Boolean);
  } else {
    parts = raw.split("/").filter(Boolean);
  }

  const styled = parts.map((part, index) => {
    if (part === "…") return theme.fg("dim", part);
    const isLast = index === parts.length - 1;
    if (part === "~") return hotPink(part);
    if (isLast) return theme.fg("accent", part);
    return theme.fg("dim", part);
  }).join(theme.fg("dim", "/"));

  return `${prefix}${styled}`;
}

function estTokens(delta: string): number {
  let a = 0, c = 0, o = 0;
  for (const ch of delta) {
    const p = ch.codePointAt(0) ?? 0;
    if ((p >= 0x3400 && p <= 0x9fff) || (p >= 0xf900 && p <= 0xfaff) ||
        (p >= 0x3040 && p <= 0x30ff) || (p >= 0xac00 && p <= 0xd7af)) c++;
    else if (p <= 0x7f) a++;
    else o++;
  }
  return c + Math.ceil(a / 4) + Math.ceil(o / 2);
}

// ── stat management ───────────────────────────────────────────
function resetMsg(): void {
  msgActive = false; msgStartMs = 0;
  msgIn = undefined; msgOut = undefined;
  estOut = undefined; msgHasAccurateOut = false;
}

function resetAll(): void {
  promptIn = promptOut = promptTurns = 0;
  promptActive = false;
  firstOutMs = pausedAt = pausedTotal = toolDepth = 0;
  tps = estTps = snapOut = snapTps = undefined;
  snapOutEst = snapTpsEst = false;
  resetMsg();
}

function elapsed(): number {
  if (!firstOutMs) return 0;
  const ap = pausedAt ? Date.now() - pausedAt : 0;
  return Math.max(0, Date.now() - firstOutMs - pausedTotal - ap);
}

function exactOut(): number | undefined {
  if (msgActive) {
    if (!msgHasAccurateOut || msgOut === undefined) return undefined;
    return promptOut + msgOut;
  }
  return promptOut > 0 ? promptOut : undefined;
}

function estDisplayOut(): number | undefined {
  if (!msgActive || estOut === undefined) return undefined;
  return promptOut + estOut;
}

function exactIn(): number | undefined {
  if (msgActive) {
    if (msgIn === undefined) return promptIn > 0 ? promptIn : undefined;
    return promptIn + msgIn;
  }
  return promptIn > 0 ? promptIn : undefined;
}

function refreshTps(): void {
  const o = exactOut();
  if (o !== undefined && o > 0) { snapOut = o; snapOutEst = false; }
  if (o === undefined || o <= 0 || !firstOutMs) return;
  const s = elapsed() / 1000;
  if (s > 0) { tps = o / s; snapTps = tps; snapTpsEst = false; }
}

function refreshEstTps(): void {
  const o = estDisplayOut();
  if (o !== undefined && o > 0 && snapOut === undefined) { snapOut = o; snapOutEst = true; }
  if (o === undefined || o <= 0 || !firstOutMs) return;
  const s = elapsed() / 1000;
  if (s > 0) {
    estTps = o / s;
    if (snapTps === undefined) { snapTps = estTps; snapTpsEst = true; }
  }
}

function addEst(delta: string): void {
  const n = estTokens(delta);
  if (n <= 0) return;
  estOut = (estOut ?? 0) + n;
  refreshEstTps();
}

function sync(m: AssistantMessage, final = false): void {
  const u = m.usage;
  if (final || u.input > 0) msgIn = u.input;
  if (final || u.output > 0 || msgOut !== undefined) {
    msgOut = u.output;
    if (final || u.output > 0) msgHasAccurateOut = true;
    refreshTps();
  }
}

function commit(): void {
  promptIn += msgIn ?? 0;
  promptOut += msgOut ?? 0;
  estTps = undefined;
  resetMsg();
  refreshTps();
}

// ── HUD ───────────────────────────────────────────────────────
function attachHUD(ctx: ExtensionContext): void {
  ctx.ui.setWidget(
    "cyber-hud",
    (_tui, theme) => ({
      invalidate(): void {},
      render(w: number): string[] {
        const home = process.env.HOME ?? "";
        const cwd = ctx.cwd ?? "";
        const rawPath = home && cwd.startsWith(home) ? "~" + cwd.slice(home.length) : cwd;

        const dOut = exactOut() ?? estDisplayOut() ?? snapOut;
        const dOutEst = exactOut() === undefined && (estDisplayOut() !== undefined || snapOutEst);
        const dTps = tps ?? estTps ?? snapTps;
        const dTpsEst = tps === undefined && (estTps !== undefined || snapTpsEst);

        const s = theme.fg("dim", SEP);

        const turn = promptActive
          ? theme.fg("dim", `${TURN_ICON}${Math.max(1, promptTurns)}`)
          : "";

        // ↑ input tokens
        const inTk = exactIn();
        let inS: string;
        if (inTk !== undefined) {
          inS = theme.fg("muted", `↑${fmt(inTk)}`);
        } else if (promptActive && promptIn > 0) {
          inS = theme.fg("dim", `↑${fmt(promptIn)}+…`);
        } else if (promptActive) {
          inS = theme.fg("dim", "↑…");
        } else {
          inS = "";
        }

        // ↓ output tokens
        let outS = "";
        if (dOut !== undefined) {
          const lbl = `${dOutEst ? "~" : ""}↓${fmt(dOut)}`;
          const frozen = toolDepth > 0;
          outS = frozen ? theme.fg("dim", lbl) : dOutEst ? theme.fg("muted", lbl) : theme.fg("accent", lbl);
        }

        // t/s
        let tpsS = "";
        if (dTps !== undefined && Number.isFinite(dTps) && dTps > 0) {
          const lbl = `${dTpsEst ? "~" : ""}${dTps.toFixed(0)}t/s`;
          tpsS = agentState === "thinking" || agentState === "idle"
            ? theme.fg("dim", lbl)
            : theme.fg(tpsColor(dTps), lbl);
        }

        const stats = [turn, [inS, outS].filter(Boolean).join(" "), tpsS].filter(Boolean);
        const statsText = stats.join(s);

        if (!promptActive && stats.length === 0) {
          return [truncateToWidth(stylePath(theme, shortenPath(rawPath, Math.max(8, w - 2))), w)];
        }

        const reserved = statsText ? visibleWidth(statsText) + visibleWidth(s) : 0;
        const pathBudget = Math.max(10, w - reserved - 1);
        const path = stylePath(theme, shortenPath(rawPath, Math.max(6, pathBudget - 2)));
        const line = statsText ? `${path}${s}${statsText}` : path;
        return [truncateToWidth(line, w)];
      },
    }),
    { placement: "aboveEditor" },
  );
}

// ── attach ────────────────────────────────────────────────────
function attach(ctx: ExtensionContext): void {
  if (!ctx.hasUI) return;
  ctx.ui.setEditorComponent((tui, th, kb) => new CyberEditor(tui, th, kb));
  attachHUD(ctx);
}

// ── extension entry ───────────────────────────────────────────
export default function cyberEditor(pi: ExtensionAPI) {
  pi.on("session_start", async (_e, ctx) => { resetAll(); attach(ctx); });
  pi.on("session_switch", async (_e, ctx) => { resetAll(); attach(ctx); });

  pi.on("agent_start", async () => {
    resetAll();
    promptActive = true;
    agentState = "running";
  });

  pi.on("turn_start", async () => {
    promptTurns++;
    agentState = "running";
  });

  pi.on("agent_end", async () => {
    if (pausedAt) { pausedTotal += Date.now() - pausedAt; pausedAt = 0; }
    promptActive = false;
    agentState = "idle";
    refreshTps(); refreshEstTps();
  });

  pi.on("tool_call", async () => {
    toolDepth++;
    if (firstOutMs && !pausedAt) pausedAt = Date.now();
    agentState = "thinking";
  });

  pi.on("tool_result", async () => {
    toolDepth = Math.max(0, toolDepth - 1);
    if (toolDepth === 0) {
      if (pausedAt) { pausedTotal += Date.now() - pausedAt; pausedAt = 0; }
      refreshTps(); refreshEstTps();
      agentState = "running";
    }
  });

  pi.on("message_start", async (event) => {
    if (event.message.role !== "assistant") return;
    resetMsg();
    msgActive = true;
    msgStartMs = Date.now();
    sync(event.message);
  });

  pi.on("message_update", async (event) => {
    const e = event.assistantMessageEvent;
    if (e.type === "text_delta" || e.type === "thinking_delta" || e.type === "toolcall_delta") {
      if (!firstOutMs) firstOutMs = Date.now();
      addEst(e.delta);
      sync(e.partial);
      return;
    }
    if (e.type === "start" || e.type === "text_start" || e.type === "text_end" ||
        e.type === "thinking_start" || e.type === "thinking_end" ||
        e.type === "toolcall_start" || e.type === "toolcall_end") {
      sync(e.partial);
      return;
    }
    if (e.type === "done") {
      if (!firstOutMs && e.message.usage.output > 0) firstOutMs = msgStartMs || Date.now();
      sync(e.message, true); refreshTps();
      return;
    }
    if (e.type === "error") {
      if (!firstOutMs && e.error.usage.output > 0) firstOutMs = msgStartMs || Date.now();
      sync(e.error, true); refreshTps();
    }
  });

  pi.on("turn_end", async (event) => {
    if (event.message.role !== "assistant") return;
    if (pausedAt) { pausedTotal += Date.now() - pausedAt; pausedAt = 0; }
    if (!firstOutMs && event.message.usage.output > 0) firstOutMs = msgStartMs || Date.now();
    sync(event.message, true);
    commit();
    refreshTps();
  });
}
