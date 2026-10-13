import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import { askQuestions, type QuestionResult } from "./tui.ts";

const QuestionOptionSchema = Type.Object({
  label: Type.String({ description: "Option text shown to the user" }),
  description: Type.Optional(Type.String({ description: "Optional explanation for this option" })),
});

const AskUserParams = Type.Object({
  questions: Type.Array(
    Type.Object({
      question: Type.String({ description: "Question to ask the user" }),
      options: Type.Array(QuestionOptionSchema, { description: "Options the user can choose from" }),
      multiSelect: Type.Optional(Type.Boolean({ description: "Allow selecting multiple options" })),
      allowOther: Type.Optional(Type.Boolean({ description: "Allow a custom answer; defaults to true" })),
    }),
    { description: "Questions to present to the user in sequence" },
  ),
});

export default function (pi: ExtensionAPI) {
  pi.registerTool({
    name: "ask_user",
    label: "Ask user",
    description:
      "Ask the user one or more questions using interactive TUI choices. Use when a decision or clarification is needed before proceeding. Supports single or multiple selections and custom answers.",
    parameters: AskUserParams,
    exposure: "model-only",
    executionMode: "sequential",

    async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
      if (ctx.mode !== "tui") {
        return {
          content: [{ type: "text", text: "Cannot ask questions: interactive TUI is unavailable." }],
          details: { answers: [], cancelled: true } satisfies QuestionResult,
          isError: true,
        };
      }
      if (params.questions.length === 0) {
        return {
          content: [{ type: "text", text: "Cannot ask questions: no questions were provided." }],
          details: { answers: [], cancelled: true } satisfies QuestionResult,
          isError: true,
        };
      }
      if (params.questions.some((question) => question.options.length === 0 && question.allowOther === false)) {
        return {
          content: [{ type: "text", text: "Each question needs at least one option or must allow a custom answer." }],
          details: { answers: [], cancelled: true } satisfies QuestionResult,
          isError: true,
        };
      }

      const result = await askQuestions(ctx, params.questions);
      const text = result.cancelled
        ? `User cancelled after answering ${result.answers.length} of ${params.questions.length} question(s).`
        : result.answers.map((answer) => `${answer.question}\nAnswer: ${answer.selected.join(", ")}`).join("\n\n");

      return {
        content: [{ type: "text", text }],
        details: result,
      };
    },

    renderCall(args, theme) {
      const questions = Array.isArray(args.questions) ? args.questions : [];
      return new Text(
        theme.fg("toolTitle", theme.bold("ask_user ")) +
          theme.fg("muted", `${questions.length} question(s)`),
        0,
        0,
      );
    },

    renderResult(result, _options, theme) {
      const details = result.details as QuestionResult | undefined;
      if (!details) {
        const content = result.content[0];
        return new Text(content?.type === "text" ? content.text : "", 0, 0);
      }
      if (details.cancelled) return new Text(theme.fg("warning", "Cancelled"), 0, 0);
      return new Text(
        details.answers
          .map((answer) => `${theme.fg("success", "✓ ")}${theme.fg("accent", answer.question)}: ${answer.selected.join(", ")}`)
          .join("\n"),
        0,
        0,
      );
    },
  });
}
