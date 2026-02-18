import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

import miniFooter from "./mini-footer";
import workingGlow from "./working-glow";

export default function uiToolkit(pi: ExtensionAPI) {
  miniFooter(pi);
  workingGlow(pi);
}
