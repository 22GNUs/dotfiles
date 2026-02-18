/**
 * Working Glow — Premium AI working animation
 *
 * A sci-fi inspired metallic shimmer effect with ice-blue accents,
 * ping-pong sweep, ambient glow, and cross-fade message transitions.
 * Designed for vibe coding aesthetics.
 */
import type {
  ExtensionAPI,
  ExtensionContext,
  Theme,
} from "@mariozechner/pi-coding-agent";

// ─── Timing ────────────────────────────────────────────────────
const FRAME_MS = 70;
const BREATH_PERIOD_MS = 4_200;
const SWEEP_PERIOD_MS = 3_400;
const AMBIENT_PERIOD_MS = 6_000;
const DOT_PERIOD_MS = 2_000;

// ─── Sweep Geometry ────────────────────────────────────────────
const SWEEP_WIDTH = 3.4;
const SWEEP_PADDING = 4;
const AMBIENT_WIDTH = 9;

// ─── Message Rotation ──────────────────────────────────────────
const MSG_ROTATE_FRAMES = 160; // ~11.2s at 70ms
const FADE_FRAMES = 12; // ~0.84s cross-fade

// ─── Color Palette (deep tech-silver → ice-blue) ──────────────
type RGB = readonly [number, number, number];

const C = {
  shadow: [68, 76, 92] as RGB,
  dim: [100, 110, 128] as RGB,
  mid: [152, 160, 176] as RGB,
  bright: [216, 222, 234] as RGB,
  ice: [164, 206, 250] as RGB,
  frost: [196, 224, 255] as RGB,
  white: [246, 250, 255] as RGB,
} as const;

const GRAY_256 = [
  238, 240, 242, 244, 246, 248, 249, 250, 251, 252, 253, 254, 255,
] as const;

// ─── Messages ──────────────────────────────────────────────────
// 20–28 chars for optimal sweep coverage
const MESSAGES = [
  "Synthesizing a solution",
  "Weaving logic together",
  "Analyzing the codebase",
  "Composing the response",
  "Tracing through patterns",
  "Reasoning step by step",
  "Assembling the pieces",
  "Exploring possibilities",
  "Building understanding",
  "Mapping the architecture",
  "Crafting with precision",
  "Following the thread",
  "Distilling the essence",
  "Connecting the signals",
  "Navigating the context",
  "Shaping the approach",
  "Unwinding complexity",
  "Iterating toward clarity",
  "Reading between the lines",
  "Orchestrating the flow",
  "Resolving the structure",
  "Considering every angle",
  "Parsing the landscape",
  "Refining the strategy",
  "Searching for the answer",
] as const;

// ─── Math ──────────────────────────────────────────────────────
const TAU = Math.PI * 2;

function clamp01(v: number): number {
  return v < 0 ? 0 : v > 1 ? 1 : v;
}

function smoothstep(t: number): number {
  const c = clamp01(t);
  return c * c * (3 - 2 * c);
}

function phase(timeMs: number, periodMs: number): number {
  return (timeMs % periodMs) / periodMs;
}

function mix(a: number, b: number, t: number): number {
  return Math.round(a + (b - a) * t);
}

function mixRgb(a: RGB, b: RGB, t: number): RGB {
  return [mix(a[0], b[0], t), mix(a[1], b[1], t), mix(a[2], b[2], t)];
}

// ─── Animation State ───────────────────────────────────────────
let timer: ReturnType<typeof setInterval> | null = null;
let frame = 0;
let currentMsg = "";
let lastRotateFrame = 0;

function pickMessage(exclude: string): string {
  let msg: string;
  do {
    msg = MESSAGES[Math.floor(Math.random() * MESSAGES.length)]!;
  } while (msg === exclude && MESSAGES.length > 1);
  return msg;
}

// Cross-fade multiplier: dims before rotation, brightens after
function fadeFactor(f: number): number {
  const since = f - lastRotateFrame;
  if (since < FADE_FRAMES) {
    return 0.25 + 0.75 * smoothstep(since / FADE_FRAMES);
  }
  const until = MSG_ROTATE_FRAMES - since;
  if (until >= 0 && until < FADE_FRAMES) {
    return 0.25 + 0.75 * smoothstep(until / FADE_FRAMES);
  }
  return 1.0;
}

// ─── Truecolor Renderer ───────────────────────────────────────
function renderTruecolor(text: string, f: number): string {
  const chars = Array.from(text);
  const len = chars.length;
  const timeMs = f * FRAME_MS;
  const fade = fadeFactor(f);

  // Breath: gentle sinusoidal pulse
  const breath = (1 - Math.cos(TAU * phase(timeMs, BREATH_PERIOD_MS))) / 2;

  // Primary sweep: ping-pong with smoothstep easing
  const rawSweep = phase(timeMs, SWEEP_PERIOD_MS);
  const pingPong =
    rawSweep < 0.5
      ? smoothstep(rawSweep * 2)
      : smoothstep(1 - (rawSweep - 0.5) * 2);
  const travel = len - 1 + SWEEP_PADDING * 2;
  const sweepCenter = -SWEEP_PADDING + pingPong * travel;

  // Ambient: slow wide secondary glow
  const ambientPhase = phase(timeMs, AMBIENT_PERIOD_MS);
  const ambientCenter =
    -AMBIENT_WIDTH + ambientPhase * (len - 1 + AMBIENT_WIDTH * 2);

  let out = "";
  for (let i = 0; i < len; i++) {
    // Sweep intensity
    const sweepDist = Math.abs(i - sweepCenter);
    const sweep = smoothstep(clamp01(1 - sweepDist / SWEEP_WIDTH));

    // Ambient intensity
    const ambDist = Math.abs(i - ambientCenter);
    const ambient = clamp01(1 - ambDist / AMBIENT_WIDTH) * 0.12;

    // Combined brightness
    const base = 0.08 + 0.1 * breath;
    const level = clamp01((base + ambient + 0.8 * sweep) * fade);

    // 4-tier silver gradient
    let color: RGB;
    if (level < 0.25) {
      color = mixRgb(C.shadow, C.dim, level / 0.25);
    } else if (level < 0.5) {
      color = mixRgb(C.dim, C.mid, (level - 0.25) / 0.25);
    } else if (level < 0.75) {
      color = mixRgb(C.mid, C.bright, (level - 0.5) / 0.25);
    } else {
      color = mixRgb(C.bright, C.white, (level - 0.75) / 0.25);
    }

    // Ice-blue accent at sweep peak
    if (sweep > 0.45) {
      const iceT = smoothstep((sweep - 0.45) / 0.55) * 0.42;
      color = mixRgb(color, C.ice, iceT);
    }

    // Frost at very top
    if (sweep > 0.82) {
      const frostT = ((sweep - 0.82) / 0.18) * 0.28;
      color = mixRgb(color, C.frost, frostT);
    }

    out += `\x1b[38;2;${color[0]};${color[1]};${color[2]}m${chars[i]}\x1b[39m`;
  }

  return out;
}

// ─── 256-color Fallback ───────────────────────────────────────
function render256(text: string, f: number): string {
  const chars = Array.from(text);
  const len = chars.length;
  const timeMs = f * FRAME_MS;
  const fade = fadeFactor(f);
  const maxIdx = GRAY_256.length - 1;

  const breath = (1 - Math.cos(TAU * phase(timeMs, BREATH_PERIOD_MS))) / 2;
  const rawSweep = phase(timeMs, SWEEP_PERIOD_MS);
  const pingPong =
    rawSweep < 0.5
      ? smoothstep(rawSweep * 2)
      : smoothstep(1 - (rawSweep - 0.5) * 2);
  const travel = len - 1 + SWEEP_PADDING * 2;
  const center = -SWEEP_PADDING + pingPong * travel;

  let out = "";
  for (let i = 0; i < len; i++) {
    const sweep = smoothstep(clamp01(1 - Math.abs(i - center) / SWEEP_WIDTH));
    const level = clamp01((0.12 + 0.1 * breath + 0.65 * sweep) * fade);
    const gray = GRAY_256[Math.round(level * maxIdx)] ?? 250;
    out += `\x1b[38;5;${gray}m${chars[i]}\x1b[39m`;
  }

  return out;
}

// ─── Pulsing Dots ─────────────────────────────────────────────
function renderDots(f: number, truecolor: boolean): string {
  const timeMs = f * FRAME_MS;
  const fade = fadeFactor(f);
  let out = " ";

  for (let d = 0; d < 3; d++) {
    // Stagger each dot by ~180ms for a wave effect
    const p = phase(timeMs + d * 180, DOT_PERIOD_MS);
    const pulse = (1 - Math.cos(TAU * p)) / 2;

    if (truecolor) {
      const level = (0.15 + 0.55 * pulse) * fade;
      const color = mixRgb(C.shadow, C.mid, clamp01(level));
      out += `\x1b[38;2;${color[0]};${color[1]};${color[2]}m·\x1b[39m`;
    } else {
      const maxIdx = GRAY_256.length - 1;
      const idx = Math.round(clamp01(pulse * fade) * maxIdx);
      out += `\x1b[38;5;${GRAY_256[idx] ?? 248}m·\x1b[39m`;
    }
  }

  return out;
}

// ─── Build Final Message ──────────────────────────────────────
function buildMessage(theme: Theme, f: number): string {
  const tc = theme.getColorMode() === "truecolor";
  const text = tc ? renderTruecolor(currentMsg, f) : render256(currentMsg, f);
  const dots = renderDots(f, tc);
  return text + dots;
}

// ─── Lifecycle ─────────────────────────────────────────────────
function startAnimation(ctx: ExtensionContext): void {
  if (!ctx.hasUI) return;
  if (timer) clearInterval(timer);

  frame = 0;
  lastRotateFrame = 0;
  currentMsg = pickMessage("");

  const tick = () => {
    // Rotate message
    if (frame - lastRotateFrame >= MSG_ROTATE_FRAMES) {
      currentMsg = pickMessage(currentMsg);
      lastRotateFrame = frame;
    }

    ctx.ui.setWorkingMessage(buildMessage(ctx.ui.theme, frame));
    frame++;
  };

  tick();
  timer = setInterval(tick, FRAME_MS);
}

function stopAnimation(ctx: ExtensionContext): void {
  if (timer) {
    clearInterval(timer);
    timer = null;
  }
  frame = 0;
  if (ctx.hasUI) ctx.ui.setWorkingMessage();
}

export default function workingGlow(pi: ExtensionAPI) {
  pi.on("agent_start", (_event, ctx) => startAnimation(ctx));
  pi.on("agent_end", (_event, ctx) => stopAnimation(ctx));
  pi.on("session_shutdown", (_event, ctx) => stopAnimation(ctx));
  pi.on("session_switch", (_event, ctx) => stopAnimation(ctx));
}
