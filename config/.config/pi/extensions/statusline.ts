import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { homedir } from "node:os";
import { relative, resolve, sep } from "node:path";
import { truncateToWidth } from "@earendil-works/pi-tui";

function formatTokens(count: number): string {
  if (count < 1_000) return String(count);
  if (count < 10_000) return `${(count / 1_000).toFixed(1)}k`;
  if (count < 1_000_000) return `${Math.round(count / 1_000)}k`;
  return `${(count / 1_000_000).toFixed(1)}M`;
}

function formatCwd(cwd: string): string {
  const home = homedir();
  const githubPrefix = `${home}${sep}src${sep}github.com${sep}`;
  if (cwd.startsWith(githubPrefix)) return cwd.slice(githubPrefix.length);

  const relativeToHome = relative(resolve(home), resolve(cwd));
  if (relativeToHome === "") return "~";
  if (!relativeToHome.startsWith(`..${sep}`) && relativeToHome !== ".." && !relativeToHome.startsWith(sep)) {
    return `~${sep}${relativeToHome}`;
  }
  return cwd;
}

function getSessionCost(ctx: ExtensionContext): number {
  let cost = 0;
  for (const entry of ctx.sessionManager.getEntries()) {
    if (entry.type === "message" && (entry.message.role === "assistant" || entry.message.role === "toolResult")) {
      cost += entry.message.usage?.cost?.total ?? 0;
    } else if ((entry.type === "branch_summary" || entry.type === "compaction") && entry.usage) {
      cost += entry.usage.cost?.total ?? 0;
    }
  }
  return cost;
}

export default function (pi: ExtensionAPI) {
  let currentContext: ExtensionContext | undefined;
  let usingSubscription = false;

  async function updateSubscription(ctx: ExtensionContext) {
    const model = ctx.model;
    if (!model) {
      usingSubscription = false;
      return;
    }

    // openai-codex is Pi's ChatGPT subscription provider. Anthropic OAuth is
    // also subscription-backed; API-key auth should not be marked as a sub.
    usingSubscription = model.provider === "openai-codex" || model.provider === "kimi-coding";
    if (model.provider === "anthropic") {
      try {
        const auth = await ctx.modelRegistry.getProviderAuth(model.provider);
        usingSubscription = auth?.source === "OAuth";
      } catch {
        usingSubscription = false;
      }
    }
  }

  function installFooter(ctx: ExtensionContext) {
    currentContext = ctx;
    ctx.ui.setFooter((tui, theme, footerData) => ({
      invalidate() {},
      render(width: number): string[] {
        const live = currentContext;
        if (!live) return [];

        const usage = live.getContextUsage();
        const contextWindow = usage?.contextWindow ?? live.model?.contextWindow ?? 0;
        const percent = usage?.percent;
        const percentText = percent == null
          ? theme.fg("muted", "?")
          : theme.fg(percent < 40 ? "success" : percent <= 70 ? "warning" : "error", `${percent.toFixed(1)}%`);
        const costText = theme.fg("muted", `$${getSessionCost(live).toFixed(3)}${usingSubscription ? " (sub)" : ""}`);
        const branch = footerData.getGitBranch();
        const cwd = theme.fg("dim", `${formatCwd(live.cwd)}${branch ? `  ${branch}` : ""}`);

        const line = `${costText}  ${percentText}/${formatTokens(contextWindow)}  ${cwd}`;
        return [truncateToWidth(line, width, theme.fg("dim", "…"))];
      },
      dispose: footerData.onBranchChange(() => tui.requestRender()),
    }));
  }

  pi.on("session_start", async (_event, ctx) => {
    await updateSubscription(ctx);
    installFooter(ctx);
  });

  pi.on("model_select", async (_event, ctx) => {
    await updateSubscription(ctx);
    installFooter(ctx);
  });
}
