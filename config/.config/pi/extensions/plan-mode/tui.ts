import type { ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Key, matchesKey, visibleWidth, wrapTextWithAnsi } from "@earendil-works/pi-tui";

export interface PlanStep {
  text: string;
  completed: boolean;
}

export type PlanAction = "apply" | "edit" | "continue";

export async function reviewPlan(
  ctx: ExtensionContext,
  steps: PlanStep[],
): Promise<{ action: PlanAction; revisedPlan?: string }> {
  const action = await ctx.ui.custom<PlanAction>((tui, theme, _keybindings, done) => {
    const choices: { label: string; action: PlanAction }[] = [
      { label: "Apply and execute (exit Plan mode)", action: "apply" },
      { label: "Edit plan", action: "edit" },
      { label: "Keep planning", action: "continue" },
    ];
    let cursor = 0;
    let cachedLines: string[] | undefined;

    function refresh() {
      cachedLines = undefined;
      tui.requestRender();
    }

    function handleInput(data: string) {
      if (matchesKey(data, Key.up) || data === "k" || data === "K") {
        cursor = Math.max(0, cursor - 1);
        refresh();
        return;
      }
      if (matchesKey(data, Key.down) || data === "j" || data === "J") {
        cursor = Math.min(choices.length - 1, cursor + 1);
        refresh();
        return;
      }
      if (matchesKey(data, Key.enter)) {
        done(choices[cursor].action);
        return;
      }
      if (matchesKey(data, Key.escape)) done("continue");
    }

    function render(width: number): string[] {
      if (cachedLines) return cachedLines;
      const renderWidth = Math.max(1, width);
      const lines = [theme.fg("accent", "Plan ready")];
      lines.push("");
      for (let i = 0; i < choices.length; i++) {
        const selected = i === cursor;
        const prefix = selected ? theme.fg("accent", "> ") : "  ";
        const label = theme.fg(selected ? "accent" : "text", choices[i].label);
        const prefixWidth = visibleWidth(prefix);
        const wrapped = wrapTextWithAnsi(label, Math.max(1, renderWidth - prefixWidth));
        for (let line = 0; line < wrapped.length; line++) {
          lines.push(`${line === 0 ? prefix : " ".repeat(prefixWidth)}${wrapped[line]}`);
        }
      }
      lines.push("");
      lines.push(...wrapTextWithAnsi(theme.fg("dim", "↑↓/jk navigate • Enter select • Esc keep planning"), renderWidth));
      cachedLines = lines;
      return lines;
    }

    return {
      render,
      invalidate: () => {
        cachedLines = undefined;
      },
      handleInput,
    };
  });

  if (action !== "edit") return { action };

  const currentPlan = steps.map((step, index) => `${index + 1}. ${step.text}`).join("\n");
  const revisedPlan = await ctx.ui.editor("Edit the plan, then submit to review it again", currentPlan);
  return revisedPlan?.trim() ? { action: "edit", revisedPlan: revisedPlan.trim() } : { action: "continue" };
}
