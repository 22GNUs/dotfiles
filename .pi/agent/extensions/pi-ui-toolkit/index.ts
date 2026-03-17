import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

import miniFooter from "./mini-footer";
import workingGlow from "./working-glow";
import cyberEditor from "./cyber-editor";

export default function uiToolkit(pi: ExtensionAPI) {
  miniFooter(pi);
  workingGlow(pi);
  cyberEditor(pi);
}
