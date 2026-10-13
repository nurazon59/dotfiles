import type { AgentMessage } from "@earendil-works/pi-agent-core";
import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { reviewPlan, type PlanStep } from "./tui.ts";

const WRITE_TOOLS = new Set(["edit", "write"]);
const READ_ONLY_COMMANDS = new Set([
  "cat", "head", "tail", "less", "more", "grep", "rg", "find", "fd", "ls", "pwd", "tree",
  "git status", "git log", "git diff", "git show", "git branch", "git remote", "git ls-files",
]);
const SHELL_OPERATORS = /[;|&><`$\n\r]/;
const COMMAND_ESCAPE_FLAGS = /(?:^|\s)(?:-exec(?:dir)?|-delete|-ok(?:dir)?|--pre(?:-glob)?|--output(?:=|\s)|--replace(?:=|\s))/i;

function getAssistantText(message: AgentMessage): string | undefined {
  if (message.role !== "assistant" || !Array.isArray(message.content)) return;
  return (message as AssistantMessage).content
    .filter((block) => block.type === "text")
    .map((block) => block.text)
    .join("\n");
}

function extractPlan(text: string): PlanStep[] {
  const start = text.match(/^\s*\*{0,2}Plan\*{0,2}:\s*$/im);
  if (!start || start.index === undefined) return [];
  const section = text.slice(start.index + start[0].length);
  const steps: PlanStep[] = [];
  for (const match of section.matchAll(/^\s*\d+[.)]\s+(.+?)\s*$/gm)) {
    const step = match[1].replace(/\*\*/g, "").trim();
    if (step) steps.push({ text: step, completed: false });
  }
  return steps;
}

function isReadOnlyCommand(command: string): boolean {
  if (SHELL_OPERATORS.test(command) || COMMAND_ESCAPE_FLAGS.test(command)) return false;
  const normalized = command.trim().replace(/\s+/g, " ");
  if (!normalized) return false;
  return [...READ_ONLY_COMMANDS].some((allowed) => normalized === allowed || normalized.startsWith(`${allowed} `));
}

export default function (pi: ExtensionAPI) {
  let enabled = false;
  let originalTools: string[] | undefined;
  let steps: PlanStep[] = [];

  function render(ctx: ExtensionContext) {
    ctx.ui.setStatus("plan-mode", enabled ? ctx.ui.theme.fg("warning", "plan") : undefined);
    if (!enabled || steps.length === 0) {
      ctx.ui.setWidget("plan-mode", undefined);
      return;
    }
    ctx.ui.setWidget("plan-mode", [
      ctx.ui.theme.fg("accent", "Plan"),
      ...steps.map((step, index) => `${step.completed ? "✓" : "○"} ${index + 1}. ${step.text}`),
    ]);
  }

  function setEnabled(value: boolean, ctx: ExtensionContext) {
    enabled = value;
    if (enabled) {
      originalTools ??= pi.getActiveTools();
      pi.setActiveTools(originalTools.filter((name) => !WRITE_TOOLS.has(name)));
      ctx.ui.notify("Plan mode: write tools disabled.", "info");
    } else {
      if (originalTools) pi.setActiveTools(originalTools);
      originalTools = undefined;
      ctx.ui.notify("Plan mode disabled.", "info");
    }
    render(ctx);
  }

  pi.registerFlag("plan", { description: "Start in read-only plan mode", type: "boolean", default: false });
  pi.registerCommand("plan", {
    description: "Toggle read-only plan mode",
    handler: async (_args, ctx) => setEnabled(!enabled, ctx),
  });

  pi.on("session_start", (_event, ctx) => {
    if (pi.getFlag("plan") === true) setEnabled(true, ctx);
    else render(ctx);
  });

  pi.on("tool_call", (event) => {
    if (!enabled || event.toolName !== "bash") return;
    const command = event.input.command;
    if (typeof command !== "string" || !isReadOnlyCommand(command)) {
      return { block: true, reason: "Plan mode allows only simple, read-only inspection commands. Disable it with /plan to run this command." };
    }
  });

  pi.on("before_agent_start", () => {
    if (!enabled) return;
    return {
      message: {
        customType: "plan-mode-context",
        display: false,
        content: "You are in plan mode. Explore the codebase without making changes. Ask for clarification when needed. Finish with a concise numbered plan under a `Plan:` heading. Do not execute the plan.",
      },
    };
  });

  pi.on("agent_end", async (event, ctx) => {
    if (!enabled || !ctx.hasUI) return;
    const text = [...event.messages].reverse().map(getAssistantText).find(Boolean);
    if (!text) return;
    const proposed = extractPlan(text);
    if (proposed.length === 0) return;
    steps = proposed;
    render(ctx);

    const review = await reviewPlan(ctx, steps);
    if (review.action === "apply") {
      setEnabled(false, ctx);
      const plan = steps.map((step, index) => `${index + 1}. ${step.text}`).join("\n");
      pi.sendUserMessage(`Execute this approved plan in order.\n\n${plan}`, { deliverAs: "followUp" });
    } else if (review.action === "edit" && review.revisedPlan) {
      pi.sendUserMessage(`Revise the plan to match this version, then show it for review again. Do not execute it yet.\n\n${review.revisedPlan}`, { deliverAs: "followUp" });
    }
  });
}
