import { getAgentDir, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { AutocompleteItem, AutocompleteProvider, AutocompleteSuggestions } from "@earendil-works/pi-tui";
import { execFile } from "node:child_process";
import { mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { dirname, join } from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
const CONFIG_PATH = join(getAgentDir(), "simple-rewind.json");
const STORE_REF = "refs/pi-simple-rewind/store";
const STATUS_KEY = "simple-rewind";
const EMPTY_TREE = "4b825dc642cb6eb9a060e54bf8d69288fbee4904";
const ZERO = "0000000000000000000000000000000000000000";

interface Config {
  enabled: boolean;
  status: boolean;
  maxSteps: number;
  async: boolean;
}

interface Point {
  v: 1;
  entryId: string;
  prompt: string;
  commit: string;
  tree: string;
  ts: number;
}

type Entry = {
  type?: string;
  id?: string;
  timestamp?: string;
  customType?: string;
  data?: unknown;
  message?: { role?: string; content?: unknown };
};

const DEFAULT_CONFIG: Config = { enabled: true, status: true, maxSteps: 5, async: true };
const REWIND_COMPLETIONS: AutocompleteItem[] = [
  { value: "clean", label: "clean", description: "Delete checkpoints" },
  { value: "status", label: "status", description: "Show rewind status" },
  { value: "status on", label: "status on", description: "Show status bar item" },
  { value: "status off", label: "status off", description: "Hide status bar item" },
  { value: "on", label: "on", description: "Enable checkpoints" },
  { value: "off", label: "off", description: "Disable checkpoints" },
  { value: "max ", label: "max N", description: "Set max checkpoints, 1..50" },
  { value: "async on", label: "async on", description: "Capture checkpoints without blocking prompt" },
  { value: "async off", label: "async off", description: "Capture checkpoints before agent starts" },
];
const UNDO_COMPLETIONS: AutocompleteItem[] = [
  { value: "all", label: "all", description: "Files + conversation" },
  { value: "files", label: "files", description: "Files only" },
  { value: "conversation", label: "conversation", description: "Conversation only" },
];

function completeArgs(items: AutocompleteItem[], prefix = ""): AutocompleteItem[] | null {
  const normalized = prefix.trimStart().toLowerCase();
  if (!normalized) return items;
  const filtered = items.filter((item) => item.value.toLowerCase().startsWith(normalized) || item.label?.toLowerCase().startsWith(normalized));
  return filtered.length > 0 ? filtered : null;
}

function createRewindAutocompleteProvider(current: AutocompleteProvider): AutocompleteProvider {
  return {
    async getSuggestions(lines, cursorLine, cursorCol, options): Promise<AutocompleteSuggestions | null> {
      const line = lines[cursorLine] ?? "";
      const beforeCursor = line.slice(0, cursorCol);
      const match = beforeCursor.match(/^\/(rewind|undo)\s+(.*)$/);
      if (!match || !options.force) return current.getSuggestions(lines, cursorLine, cursorCol, options);
      const command = match[1];
      const argPrefix = match[2] ?? "";
      const items = completeArgs(command === "rewind" ? REWIND_COMPLETIONS : UNDO_COMPLETIONS, argPrefix);
      return items ? { items, prefix: argPrefix } : current.getSuggestions(lines, cursorLine, cursorCol, options);
    },

    applyCompletion(lines, cursorLine, cursorCol, item, prefix) {
      return current.applyCompletion(lines, cursorLine, cursorCol, item, prefix);
    },

    shouldTriggerFileCompletion(lines, cursorLine, cursorCol) {
      const line = lines[cursorLine] ?? "";
      const beforeCursor = line.slice(0, cursorCol);
      if (/^\/(rewind|undo)(?:\s+.*)?$/.test(beforeCursor)) return true;
      return current.shouldTriggerFileCompletion?.(lines, cursorLine, cursorCol) ?? true;
    },
  };
}

function isPoint(value: unknown): value is Point {
  if (!value || typeof value !== "object") return false;
  const data = value as Partial<Point>;
  return data.v === 1 && typeof data.entryId === "string" && typeof data.commit === "string" && typeof data.tree === "string";
}

async function readConfig(): Promise<Config> {
  try {
    const raw = await readFile(CONFIG_PATH, "utf8");
    const parsed = JSON.parse(raw) as Partial<Config>;
    return {
      enabled: parsed.enabled !== false,
      status: parsed.status !== false,
      maxSteps: Number.isFinite(parsed.maxSteps) && (parsed.maxSteps ?? 0) > 0 ? Math.floor(parsed.maxSteps!) : DEFAULT_CONFIG.maxSteps,
      async: parsed.async !== false,
    };
  } catch {
    return { ...DEFAULT_CONFIG };
  }
}

async function writeConfig(config: Config): Promise<void> {
  await mkdir(dirname(CONFIG_PATH), { recursive: true });
  await writeFile(CONFIG_PATH, `${JSON.stringify(config, null, 2)}\n`, "utf8");
}

async function git(cwd: string, args: string[], env?: NodeJS.ProcessEnv): Promise<string> {
  const { stdout } = await execFileAsync("git", args, { cwd, env: env ? { ...process.env, ...env } : process.env });
  return stdout.trim();
}

async function isGitRepo(cwd: string): Promise<boolean> {
  try {
    return (await git(cwd, ["rev-parse", "--is-inside-work-tree"])) === "true";
  } catch {
    return false;
  }
}

function getText(content: unknown): string {
  if (typeof content === "string") return content;
  if (!Array.isArray(content)) return "";
  return content
    .filter((item): item is { type?: string; text?: string } => Boolean(item) && typeof item === "object")
    .filter((item) => item.type === "text")
    .map((item) => item.text ?? "")
    .join("\n");
}

function trimOneLine(text: string, max = 70): string {
  const one = text.replace(/\s+/g, " ").trim();
  return one.length <= max ? one : `${one.slice(0, max - 1)}…`;
}

function userEntries(ctx: ExtensionContext): Entry[] {
  return (ctx.sessionManager.getEntries() as Entry[]).filter((entry) => entry.type === "message" && entry.message?.role === "user");
}

function pointsFromSession(ctx: ExtensionContext): Point[] {
  const points: Point[] = [];
  let lastCleanTs = 0;
  for (const entry of ctx.sessionManager.getEntries() as Entry[]) {
    if (entry.type === "custom" && entry.customType === "simple-rewind-clean") {
      const ts = typeof entry.data === "object" && entry.data && "ts" in entry.data ? Number((entry.data as { ts?: unknown }).ts) : 0;
      if (Number.isFinite(ts)) lastCleanTs = Math.max(lastCleanTs, ts);
    }
    if (entry.type === "custom" && entry.customType === "simple-rewind-point" && isPoint(entry.data)) {
      points.push(entry.data);
    }
  }
  const latestByEntry = new Map<string, Point>();
  for (const point of points) {
    if (point.ts <= lastCleanTs) continue;
    latestByEntry.set(point.entryId, point);
  }
  return [...latestByEntry.values()].sort((a, b) => b.ts - a.ts);
}

function findLatestUserEntry(ctx: ExtensionContext, prompt: string): Entry | undefined {
  const users = userEntries(ctx);
  for (let i = users.length - 1; i >= 0; i--) {
    const entry = users[i];
    if (getText(entry.message?.content) === prompt) return entry;
  }
  return users.at(-1);
}

async function captureTree(root: string): Promise<string> {
  const tempDir = await mkdtemp(join(tmpdir(), "pi-simple-rewind-"));
  const index = join(tempDir, "index");
  const env = { GIT_INDEX_FILE: index };
  try {
    const head = await git(root, ["rev-parse", "--verify", "HEAD"]).catch(() => "");
    if (head) await git(root, ["read-tree", head], env);
    await git(root, ["add", "-A"], env);
    return await git(root, ["write-tree"], env);
  } finally {
    await rm(tempDir, { recursive: true, force: true }).catch(() => {});
  }
}

async function captureSnapshot(root: string, message: string): Promise<{ commit: string; tree: string }> {
  const tree = await captureTree(root);
  const commit = await git(root, ["commit-tree", tree, "-m", message]);
  return { commit, tree };
}

async function getStoreHead(root: string): Promise<string | undefined> {
  return git(root, ["rev-parse", "--verify", STORE_REF]).catch(() => undefined);
}

async function rewriteStore(root: string, commits: string[]): Promise<void> {
  const unique = [...new Set(commits.filter(Boolean))];
  if (unique.length === 0) {
    await git(root, ["update-ref", "-d", STORE_REF]).catch(() => "");
    return;
  }
  let head: string | undefined;
  for (const commit of unique) {
    const args = ["commit-tree", EMPTY_TREE];
    if (head) args.push("-p", head);
    args.push("-p", commit, "-m", "pi simple rewind store");
    head = await git(root, args);
  }
  const old = await getStoreHead(root);
  if (old) await git(root, ["update-ref", STORE_REF, head!, old]);
  else await git(root, ["update-ref", STORE_REF, head!, ZERO]);
}

async function commitExists(root: string, commit: string): Promise<boolean> {
  try {
    await git(root, ["cat-file", "-e", `${commit}^{commit}`]);
    return true;
  } catch {
    return false;
  }
}

async function restore(root: string, commit: string): Promise<void> {
  const currentTree = await captureTree(root);
  const targetTree = await git(root, ["show", "-s", "--format=%T", commit]);
  const deleted = await git(root, ["diff", "--name-only", "--diff-filter=D", "-z", currentTree, targetTree]).catch(() => "");
  const paths = deleted.split("\0").filter(Boolean);
  for (const path of paths) await rm(join(root, path), { recursive: true, force: true }).catch(() => {});
  await git(root, ["restore", `--source=${commit}`, "--worktree", "--", "."]);
}

async function clean(root: string): Promise<void> {
  await git(root, ["update-ref", "-d", STORE_REF]).catch(() => "");
  await git(root, ["gc", "--auto"]).catch(() => "");
}

function updateStatus(ctx: ExtensionContext, cfg: Config, count: number, gitOk: boolean) {
  if (!ctx.hasUI) return;
  if (!cfg.status || !cfg.enabled || !gitOk) {
    ctx.ui.setStatus(STATUS_KEY, undefined);
    return;
  }
  ctx.ui.setStatus(STATUS_KEY, `↶${count}/${cfg.maxSteps}`);
}

async function choosePoint(ctx: ExtensionContext, points: Point[]): Promise<Point | undefined> {
  const shown = points.slice(0, 25);
  const items = shown.map((p, i) => `#${i + 1} ${new Date(p.ts).toLocaleTimeString()} ${trimOneLine(p.prompt)}`);
  const choice = await ctx.ui.select("Rewind user checkpoint", items);
  if (!choice) return undefined;
  return shown[items.indexOf(choice)];
}

type RestoreMode = "Files + conversation" | "Files only" | "Conversation only";

async function restorePoint(root: string, ctx: ExtensionContext & { navigateTree?: (id: string, opts?: unknown) => Promise<void> }, point: Point, mode: RestoreMode): Promise<void> {
  if (mode === "Files + conversation" || mode === "Files only") {
    await restore(root, point.commit);
    ctx.ui.notify("rewind: files restored", "info");
  }
  if (mode === "Files + conversation" || mode === "Conversation only") {
    try {
      if (typeof ctx.navigateTree === "function") await ctx.navigateTree(point.entryId, { summarize: false });
      else throw new Error("navigateTree unavailable");
    } catch {
      ctx.ui.notify("rewind: conversation navigation failed", "warning");
    }
  }
}

export default function simpleRewind(pi: ExtensionAPI) {
  let cfg: Config = { ...DEFAULT_CONFIG };
  let root: string | null = null;
  let gitOk = false;
  let activePrompt = "";
  let pending: { promise: Promise<{ commit: string; tree: string }>; prompt: string; ts: number } | null = null;
  let redoPoint: { commit: string; tree: string; ts: number; entryId?: string } | null = null;
  let undoCursorTs: number | null = null;

  function uniqueRecent(points: Point[]): Point[] {
    const seen = new Set<string>();
    const result: Point[] = [];
    for (const point of points.sort((a, b) => b.ts - a.ts)) {
      if (seen.has(point.entryId)) continue;
      seen.add(point.entryId);
      result.push(point);
      if (result.length >= cfg.maxSteps) break;
    }
    return result;
  }

  async function livePoints(ctx: ExtensionContext, extra: Point[] = []): Promise<Point[]> {
    if (!root) return [];
    const live: Point[] = [];
    for (const point of uniqueRecent([...extra, ...pointsFromSession(ctx)])) {
      if (await commitExists(root, point.commit)) live.push(point);
    }
    return live;
  }

  function currentBranchLeafId(ctx: ExtensionContext): string | undefined {
    const branch = ctx.sessionManager.getBranch() as Entry[];
    for (let i = branch.length - 1; i >= 0; i--) {
      const id = branch[i]?.id;
      if (id) return id;
    }
    return undefined;
  }

  async function refresh(ctx: ExtensionContext) {
    cfg = await readConfig();
    gitOk = await isGitRepo(ctx.cwd);
    root = gitOk ? await git(ctx.cwd, ["rev-parse", "--show-toplevel"]) : null;
    updateStatus(ctx, cfg, (await livePoints(ctx)).length, gitOk);
  }

  async function rewriteLiveStore(ctx: ExtensionContext) {
    if (!root) return;
    const commits = (await livePoints(ctx)).map((p) => p.commit);
    if (redoPoint) commits.unshift(redoPoint.commit);
    await rewriteStore(root, commits);
  }

  pi.on("session_start", async (_event, ctx) => {
    ctx.ui.addAutocompleteProvider((current) => createRewindAutocompleteProvider(current));
    await refresh(ctx);
  });

  pi.on("before_agent_start", async (event) => {
    activePrompt = String(event.prompt ?? "");
  });

  pi.on("turn_start", async (event, ctx) => {
    if (!cfg.enabled || !gitOk || !root || event.turnIndex !== 0) return;
    undoCursorTs = null;
    redoPoint = null;
    const prompt = activePrompt;
    const ts = Date.now();
    const promise = captureSnapshot(root, "pi simple rewind user checkpoint");
    promise.catch(() => {});
    if (cfg.async) {
      pending = { promise, prompt, ts };
      return;
    }
    try {
      const snap = await promise;
      pending = { promise: Promise.resolve(snap), prompt, ts };
      const count = Math.min(cfg.maxSteps, (await livePoints(ctx)).length + 1);
      updateStatus(ctx, cfg, count, gitOk);
    } catch (error) {
      pending = null;
      if (ctx.hasUI) ctx.ui.notify(`rewind: checkpoint failed: ${error instanceof Error ? error.message : String(error)}`, "warning");
    }
  });

  pi.on("agent_end", async (_event, ctx) => {
    if (!pending || !root) return;
    const current = pending;
    try {
      const snap = await current.promise;
      const user = findLatestUserEntry(ctx, current.prompt);
      if (!user?.id) return;
      const point: Point = { v: 1, entryId: user.id, prompt: current.prompt, commit: snap.commit, tree: snap.tree, ts: current.ts };
      pi.appendEntry("simple-rewind-point", point);
      const points = await livePoints(ctx, [point]);
      await rewriteStore(root, points.map((p) => p.commit));
      updateStatus(ctx, cfg, points.length, gitOk);
    } catch (error) {
      if (ctx.hasUI) ctx.ui.notify(`rewind: checkpoint failed: ${error instanceof Error ? error.message : String(error)}`, "warning");
    } finally {
      if (pending === current) pending = null;
      activePrompt = "";
    }
  });

  pi.registerCommand("rewind", {
    description: "User-only rewind. Usage: /rewind [clean|status|on|off|async on|async off|status on|status off|max N]",
    getArgumentCompletions: (prefix: string): AutocompleteItem[] | null => completeArgs(REWIND_COMPLETIONS, prefix),
    handler: async (args, ctx) => {
      await refresh(ctx as unknown as ExtensionContext);
      const action = args.trim().toLowerCase();
      if (!root || !gitOk) {
        ctx.ui.notify("rewind: not a git repo", "warning");
        return;
      }

      if (action === "clean") {
        const ok = await ctx.ui.confirm("Delete all simple-rewind checkpoints for this repo?", "This only deletes refs/pi-simple-rewind/store; session log remains.");
        if (!ok) return;
        await clean(root);
        pi.appendEntry("simple-rewind-clean", { v: 1, ts: Date.now() });
        updateStatus(ctx as unknown as ExtensionContext, cfg, 0, gitOk);
        ctx.ui.notify("rewind: checkpoints cleaned", "info");
        return;
      }

      if (action === "status") {
        const points = await livePoints(ctx as unknown as ExtensionContext);
        ctx.ui.notify(`rewind: ${cfg.enabled ? "on" : "off"}, status ${cfg.status ? "on" : "off"}, async ${cfg.async ? "on" : "off"}, ${points.length}/${cfg.maxSteps} points`, "info");
        return;
      }

      if (action === "async on" || action === "async off") {
        cfg.async = action.endsWith("on");
        await writeConfig(cfg);
        ctx.ui.notify(`rewind async: ${cfg.async ? "on" : "off"}`, "info");
        return;
      }

      if (action === "on" || action === "off") {
        cfg.enabled = action === "on";
        await writeConfig(cfg);
        updateStatus(ctx as unknown as ExtensionContext, cfg, pointsFromSession(ctx as unknown as ExtensionContext).length, gitOk);
        ctx.ui.notify(`rewind: ${action}`, "info");
        return;
      }

      if (action === "status on" || action === "status off") {
        cfg.status = action.endsWith("on");
        await writeConfig(cfg);
        updateStatus(ctx as unknown as ExtensionContext, cfg, pointsFromSession(ctx as unknown as ExtensionContext).length, gitOk);
        ctx.ui.notify(`rewind status: ${cfg.status ? "on" : "off"}`, "info");
        return;
      }

      if (action.startsWith("max ")) {
        const n = Number(action.slice(4).trim());
        if (!Number.isFinite(n) || n < 1 || n > 50) {
          ctx.ui.notify("rewind: max must be 1..50", "warning");
          return;
        }
        cfg.maxSteps = Math.floor(n);
        await writeConfig(cfg);
        const points = pointsFromSession(ctx as unknown as ExtensionContext).slice(0, cfg.maxSteps);
        await rewriteStore(root, points.map((p) => p.commit));
        updateStatus(ctx as unknown as ExtensionContext, cfg, points.length, gitOk);
        ctx.ui.notify(`rewind: maxSteps=${cfg.maxSteps}`, "info");
        return;
      }

      const points = await livePoints(ctx as unknown as ExtensionContext);
      if (points.length === 0) {
        ctx.ui.notify("rewind: no checkpoints", "warning");
        return;
      }

      const point = await choosePoint(ctx as unknown as ExtensionContext, points);
      if (!point) return;
      const mode = await ctx.ui.select("Restore mode", ["Files + conversation", "Files only", "Conversation only", "Cancel"]);
      if (!mode || mode === "Cancel") return;
      await restorePoint(root, ctx as unknown as ExtensionContext & { navigateTree?: (id: string, opts?: unknown) => Promise<void> }, point, mode as RestoreMode);
    },
  });

  pi.registerCommand("undo", {
    description: "Undo latest user turn. Creates one redo slot. Usage: /undo [all|files|conversation]",
    getArgumentCompletions: (prefix: string): AutocompleteItem[] | null => completeArgs(UNDO_COMPLETIONS, prefix),
    handler: async (args, ctx) => {
      await refresh(ctx as unknown as ExtensionContext);
      if (!root || !gitOk) {
        ctx.ui.notify("undo: not a git repo", "warning");
        return;
      }

      let points = await livePoints(ctx as unknown as ExtensionContext);
      if (undoCursorTs !== null) points = points.filter((p) => p.ts < undoCursorTs!);
      const point = points[0];
      if (!point) {
        ctx.ui.notify("undo: no checkpoint", "warning");
        return;
      }

      const arg = args.trim().toLowerCase();
      let mode: RestoreMode | undefined;
      if (!arg || arg === "all" || arg === "both") mode = "Files + conversation";
      if (arg === "files" || arg === "file" || arg === "code") mode = "Files only";
      if (arg === "conversation" || arg === "chat" || arg === "ctx" || arg === "context") mode = "Conversation only";
      if (!mode) {
        ctx.ui.notify("undo: usage /undo [all|files|conversation]", "warning");
        return;
      }

      if (mode === "Files + conversation" || mode === "Files only") {
        redoPoint = {
          ...(await captureSnapshot(root, "pi simple rewind redo slot")),
          ts: Date.now(),
          entryId: currentBranchLeafId(ctx as unknown as ExtensionContext),
        };
        await rewriteLiveStore(ctx as unknown as ExtensionContext);
      }

      await restorePoint(root, ctx as unknown as ExtensionContext & { navigateTree?: (id: string, opts?: unknown) => Promise<void> }, point, mode);
      undoCursorTs = point.ts;
      ctx.ui.notify(`undo: ${trimOneLine(point.prompt, 50)}${redoPoint ? " · redo ready" : ""}`, "info");
    },
  });

  pi.registerCommand("redo", {
    description: "Redo state captured by latest /undo. One-shot.",
    handler: async (_args, ctx) => {
      await refresh(ctx as unknown as ExtensionContext);
      if (!root || !gitOk) {
        ctx.ui.notify("redo: not a git repo", "warning");
        return;
      }
      if (!redoPoint) {
        ctx.ui.notify("redo: nothing to redo; run /undo first", "warning");
        return;
      }
      if (!(await commitExists(root, redoPoint.commit))) {
        redoPoint = null;
        await rewriteLiveStore(ctx as unknown as ExtensionContext);
        ctx.ui.notify("redo: snapshot missing", "warning");
        return;
      }

      const targetEntryId = redoPoint.entryId;
      await restore(root, redoPoint.commit);
      redoPoint = null;
      undoCursorTs = null;
      await rewriteLiveStore(ctx as unknown as ExtensionContext);
      if (targetEntryId) {
        try {
          await ctx.navigateTree(targetEntryId, { summarize: false });
        } catch {
          ctx.ui.notify("redo: conversation navigation failed", "warning");
        }
      }
      ctx.ui.notify("redo: restored; redo slot cleared", "info");
    },
  });
}
