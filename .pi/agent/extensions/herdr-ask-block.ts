// herdr-ask-block.ts
//
// Bridges the @eko24ive/pi-ask `ask_user` tool to herdr's BLOCK state.
//
// Why a pi extension and not a herdr plugin (herdr-plugin.toml)?
//   herdr plugins run commands on actions / panes / events and cannot see pi's
//   internal tool lifecycle, so they cannot reliably tell when pi is sitting in
//   an `ask_user` call waiting for input. The official herdr Pi integration
//   (herdr-agent-state.ts, installed beside this file) already exposes a custom
//   event-bus channel `herdr:blocked` as the designed extension point for this:
//
//     pi.events.emit("herdr:blocked", { active: true,  label: "ask_user" })  // -> BLOCK
//     pi.events.emit("herdr:blocked", { active: false })                     // -> unblock
//
//   Its handler keeps a refcount, so one `active:true` per ask_user start and
//   one `active:false` per ask_user end balance out correctly, even with
//   nested / parallel calls.
//
// This extension only emits; it owns no state authority. The herdr integration
// still owns idle/working/blocked semantics and session restore.
//
// Reload after editing with `/reload` (or restart pi).

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const ASK_TOOL_NAME = "ask_user";

function enabled(): boolean {
  // Only act when pi is running inside a herdr pane. The herdr integration sets
  // these; outside herdr the `herdr:blocked` channel has no listener anyway.
  return process.env.HERDR_ENV === "1";
}

export default function (pi: ExtensionAPI) {
  if (!enabled()) {
    return;
  }

  // Track outstanding ask_user toolCallIds so we can clean up if a normal
  // tool_execution_end is missed (abort, shutdown, etc.).
  const activeAskCalls = new Set<string>();

  function block(label: string): void {
    pi.events.emit("herdr:blocked", { active: true, label });
  }

  function unblock(): void {
    pi.events.emit("herdr:blocked", { active: false });
  }

  pi.on("tool_execution_start", (event) => {
    if (event.toolName !== ASK_TOOL_NAME) {
      return;
    }
    activeAskCalls.add(event.toolCallId);
    block(ASK_TOOL_NAME);
  });

  pi.on("tool_execution_end", (event) => {
    if (event.toolName !== ASK_TOOL_NAME) {
      return;
    }
    // Only unblock for calls we actually marked blocked, to keep the herdr
    // refcount balanced even if duplicate/late end events arrive.
    if (activeAskCalls.delete(event.toolCallId)) {
      unblock();
    }
  });

  // Safety nets: if a turn ends or the session shuts down while ask_user is
  // still open, release every outstanding block so the pane does not get
  // stuck on BLOCK.
  pi.on("agent_end", () => {
    for (const id of activeAskCalls) {
      activeAskCalls.delete(id);
      unblock();
    }
  });

  pi.on("session_shutdown", () => {
    for (const id of activeAskCalls) {
      activeAskCalls.delete(id);
      unblock();
    }
  });
}
