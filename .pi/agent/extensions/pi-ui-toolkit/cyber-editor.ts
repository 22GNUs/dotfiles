/**
 * Cyber Editor — adds a ❯ prompt glyph before input content
 * Uses tokyo-night magenta (#bb9af7) for the glyph color.
 */
import { CustomEditor, type ExtensionAPI, type ExtensionContext, type KeybindingsManager } from "@mariozechner/pi-coding-agent";
import type { TUI, EditorTheme } from "@mariozechner/pi-tui";
import { visibleWidth, truncateToWidth } from "@mariozechner/pi-tui";

// tokyo-night red/pink (#f7768e)
const MAGENTA = "\x1b[38;2;247;118;142m";
const RESET = "\x1b[39m";
const GLYPH = `${MAGENTA}❯${RESET} `;
const GLYPH_WIDTH = 2; // "❯ " = 2 visible chars

class CyberEditorComponent extends CustomEditor {
  constructor(tui: TUI, theme: EditorTheme, keybindings: KeybindingsManager) {
    super(tui, theme, keybindings);
    // Add left padding to make room for the glyph
    this.setPaddingX(this.getPaddingX() + GLYPH_WIDTH);
  }

  override render(width: number): string[] {
    const lines = super.render(width);
    if (lines.length <= 2) return lines; // only borders, no content

    // lines[0] = top border, lines[last] = bottom border
    // content lines are in between
    for (let i = 1; i < lines.length - 1; i++) {
      const line = lines[i]!;
      if (i === 1) {
        // First content line: prepend glyph, trim to fit
        const trimmed = truncateToWidth(line, width - GLYPH_WIDTH, "");
        lines[i] = GLYPH + trimmed;
      } else {
        // Continuation lines: indent to align with glyph
        const indent = "  "; // 2 spaces to match "❯ "
        const trimmed = truncateToWidth(line, width - GLYPH_WIDTH, "");
        lines[i] = indent + trimmed;
      }
    }

    return lines;
  }
}

function attach(ctx: ExtensionContext): void {
  if (!ctx.hasUI) return;
  ctx.ui.setEditorComponent((tui, theme, kb) =>
    new CyberEditorComponent(tui, theme, kb)
  );
}

export default function cyberEditor(pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => attach(ctx));
  pi.on("session_switch", async (_event, ctx) => attach(ctx));
}
