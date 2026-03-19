import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

import miniFooter from "./mini-footer.js";
import workingGlow from "./working-glow.js";
import cyberEditor from "./cyber-editor.js";

export default function uiToolkit(pi: ExtensionAPI) {
  miniFooter(pi);
  workingGlow(pi);
  cyberEditor(pi);
}
