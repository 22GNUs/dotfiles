import { dirname, join } from "node:path";
import { mkdir, readFile, unlink, writeFile } from "node:fs/promises";
import { getAgentDir, type ExtensionAPI, type ExtensionContext } from "@earendil-works/pi-coding-agent";

interface StashEntry {
  text: string;
  savedAt: string;
  cwd: string;
  chars: number;
}

const STASH_PATH = join(getAgentDir(), "pi-stash.json");

async function readStash(): Promise<StashEntry | undefined> {
  try {
    const raw = await readFile(STASH_PATH, "utf8");
    const parsed = JSON.parse(raw) as Partial<StashEntry>;
    if (typeof parsed.text !== "string") return undefined;
    return {
      text: parsed.text,
      savedAt: typeof parsed.savedAt === "string" ? parsed.savedAt : new Date(0).toISOString(),
      cwd: typeof parsed.cwd === "string" ? parsed.cwd : "",
      chars: typeof parsed.chars === "number" ? parsed.chars : parsed.text.length,
    };
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") return undefined;
    throw error;
  }
}

async function writeStash(entry: StashEntry): Promise<void> {
  await mkdir(dirname(STASH_PATH), { recursive: true });
  await writeFile(STASH_PATH, `${JSON.stringify(entry, null, 2)}\n`, "utf8");
}

async function clearStash(): Promise<void> {
  try {
    await unlink(STASH_PATH);
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code !== "ENOENT") throw error;
  }
}

function firstLine(text: string): string {
  const line = text.split("\n", 1)[0] ?? "";
  return line.length <= 60 ? line : `${line.slice(0, 57)}...`;
}

async function save(ctx: ExtensionContext, clearEditor: boolean): Promise<void> {
  const text = ctx.ui.getEditorText();
  if (!text.trim()) {
    ctx.ui.notify("pi-stash: 输入框为空，未保存", "warning");
    return;
  }

  const entry: StashEntry = {
    text,
    savedAt: new Date().toISOString(),
    cwd: ctx.cwd,
    chars: text.length,
  };
  await writeStash(entry);
  if (clearEditor) ctx.ui.setEditorText("");
  ctx.ui.notify(`pi-stash: 已保存 ${entry.chars} chars${clearEditor ? "，已清空输入框" : ""}`, "info");
}

async function restore(ctx: ExtensionContext): Promise<void> {
  const entry = await readStash();
  if (!entry) {
    ctx.ui.notify("pi-stash: 无保存内容", "warning");
    return;
  }

  ctx.ui.setEditorText(entry.text);
  ctx.ui.notify(`pi-stash: 已恢复 ${entry.chars} chars`, "info");
}

async function show(ctx: ExtensionContext): Promise<void> {
  const entry = await readStash();
  if (!entry) {
    ctx.ui.notify("pi-stash: 无保存内容", "warning");
    return;
  }

  ctx.ui.notify(`pi-stash: ${entry.chars} chars · ${entry.savedAt} · ${firstLine(entry.text)}`, "info");
}

export default function piStash(pi: ExtensionAPI) {
  pi.registerShortcut("alt+s", {
    description: "Save current input to persistent pi-stash and clear editor",
    handler: async (ctx) => {
      await save(ctx, true);
    },
  });

  pi.registerShortcut("alt+r", {
    description: "Restore current input from persistent pi-stash",
    handler: async (ctx) => {
      await restore(ctx);
    },
  });

  pi.registerCommand("stash", {
    description: "Save/restore current editor input. Usage: /stash [save|restore|show|clear|keep]",
    handler: async (args, ctx) => {
      const action = args.trim().toLowerCase() || "show";
      if (action === "save") {
        await save(ctx, true);
        return;
      }
      if (action === "keep") {
        await save(ctx, false);
        return;
      }
      if (action === "restore" || action === "pop") {
        await restore(ctx);
        return;
      }
      if (action === "clear") {
        await clearStash();
        ctx.ui.notify("pi-stash: 已清除", "info");
        return;
      }
      if (action === "show") {
        await show(ctx);
        return;
      }

      ctx.ui.notify("pi-stash: 用法 /stash [save|restore|show|clear|keep]", "warning");
    },
  });
}
