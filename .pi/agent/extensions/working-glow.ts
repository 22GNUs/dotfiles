import type {
  ExtensionAPI,
  ExtensionContext,
  Theme,
} from "@mariozechner/pi-coding-agent";

const BASE_WORD = "Working";
const ELLIPSIS = "...";
const FRAME_MS = 80;

const BREATH_PERIOD_MS = 2_400;
const SWEEP_PERIOD_MS = 2_240;
const SWEEP_PADDING = 2;
const SWEEP_WIDTH = 2.2;

const SILVER_STOPS = [
  [120, 127, 138],
  [176, 183, 193],
  [236, 240, 246],
] as const;

const GRAYSCALE_LEVELS_256 = [248, 249, 250, 251, 252, 253, 254, 255] as const;

const WORD_CHARS = Array.from(BASE_WORD);
const TAU = Math.PI * 2;

let timer: ReturnType<typeof setInterval> | null = null;
let frame = 0;

type RGB = readonly [number, number, number];

function clamp01(value: number): number {
  return Math.max(0, Math.min(1, value));
}

function phase(timeMs: number, periodMs: number): number {
  return (timeMs % periodMs) / periodMs;
}

function animationState(currentFrame: number): {
  breath: number;
  center: number;
} {
  const timeMs = currentFrame * FRAME_MS;
  const breath = (1 - Math.cos(TAU * phase(timeMs, BREATH_PERIOD_MS))) / 2;
  const travel = WORD_CHARS.length - 1 + SWEEP_PADDING * 2;
  const center = -SWEEP_PADDING + phase(timeMs, SWEEP_PERIOD_MS) * travel;
  return { breath, center };
}

function sweepWeight(index: number, center: number): number {
  const t = clamp01(1 - Math.abs(index - center) / SWEEP_WIDTH);
  return t * t;
}

function mix(a: number, b: number, t: number): number {
  return Math.round(a + (b - a) * t);
}

function mixRgb(from: RGB, to: RGB, t: number): RGB {
  return [
    mix(from[0], to[0], t),
    mix(from[1], to[1], t),
    mix(from[2], to[2], t),
  ];
}

function silverColor(level: number): RGB {
  const t = clamp01(level);
  if (t <= 0.5) return mixRgb(SILVER_STOPS[0], SILVER_STOPS[1], t * 2);
  return mixRgb(SILVER_STOPS[1], SILVER_STOPS[2], (t - 0.5) * 2);
}

function fgTruecolor([r, g, b]: RGB, text: string): string {
  return `\x1b[38;2;${r};${g};${b}m${text}\x1b[39m`;
}

function fg256(index: number, text: string): string {
  return `\x1b[38;5;${index}m${text}\x1b[39m`;
}

function renderWorkingWordTruecolor(currentFrame: number): string {
  const { breath, center } = animationState(currentFrame);
  let out = "";

  for (let i = 0; i < WORD_CHARS.length; i += 1) {
    const level = clamp01(0.24 + 0.22 * breath + 0.54 * sweepWeight(i, center));
    out += fgTruecolor(silverColor(level), WORD_CHARS[i] ?? "");
  }

  return out;
}

function renderWorkingWord256(currentFrame: number): string {
  const { breath, center } = animationState(currentFrame);
  const max = GRAYSCALE_LEVELS_256.length - 1;
  let out = "";

  for (let i = 0; i < WORD_CHARS.length; i += 1) {
    const level = clamp01(0.28 + 0.18 * breath + 0.3 * sweepWeight(i, center));
    const gray = GRAYSCALE_LEVELS_256[Math.round(level * max)] ?? 252;
    out += fg256(gray, WORD_CHARS[i] ?? "");
  }

  return out;
}

function buildWorkingMessage(theme: Theme, currentFrame: number): string {
  const word =
    theme.getColorMode() === "truecolor"
      ? renderWorkingWordTruecolor(currentFrame)
      : renderWorkingWord256(currentFrame);
  return `${word}${theme.fg("dim", ELLIPSIS)}`;
}

function startAnimation(ctx: ExtensionContext): void {
  if (!ctx.hasUI) return;

  if (timer) clearInterval(timer);

  frame = 0;
  const tick = () => {
    ctx.ui.setWorkingMessage(buildWorkingMessage(ctx.ui.theme, frame));
    frame += 1;
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
