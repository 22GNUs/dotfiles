import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

import cfCompatProvider from "./custom-provider-cf-compat";
import cfPackycodeProvider from "./custom-provider-cf-packycode";

export default function customProviders(pi: ExtensionAPI) {
  cfCompatProvider(pi);
  cfPackycodeProvider(pi);
}
