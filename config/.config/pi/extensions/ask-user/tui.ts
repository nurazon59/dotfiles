import type { ExtensionContext } from "@earendil-works/pi-coding-agent";
import {
  Editor,
  type EditorTheme,
  Key,
  matchesKey,
  visibleWidth,
  wrapTextWithAnsi,
} from "@earendil-works/pi-tui";

export interface QuestionOption {
  label: string;
  description?: string;
}

export interface Question {
  question: string;
  options: QuestionOption[];
  multiSelect?: boolean;
  allowOther?: boolean;
}

export interface QuestionAnswer {
  question: string;
  selected: string[];
  custom: boolean;
}

export interface QuestionResult {
  answers: QuestionAnswer[];
  cancelled: boolean;
}

async function askOne(ctx: ExtensionContext, question: Question): Promise<QuestionAnswer | null> {
  const options = [...question.options];
  if (question.allowOther !== false) options.push({ label: "Other (enter a custom answer)" });

  const selected = await ctx.ui.custom<string[] | null>((tui, theme, _keybindings, done) => {
    let cursor = 0;
    let inputMode = false;
    let cachedLines: string[] | undefined;
    const checked = new Set<number>();
    const editorTheme: EditorTheme = {
      borderColor: (text) => theme.fg("accent", text),
      selectList: {
        selectedPrefix: (text) => theme.fg("accent", text),
        selectedText: (text) => theme.fg("accent", text),
        description: (text) => theme.fg("muted", text),
        scrollInfo: (text) => theme.fg("dim", text),
        noMatch: (text) => theme.fg("warning", text),
      },
    };
    const editor = new Editor(tui, editorTheme);

    function refresh() {
      cachedLines = undefined;
      tui.requestRender();
    }

    function finish(values: string[]) {
      done(values);
    }

    editor.onSubmit = (value) => {
      const answer = value.trim();
      if (!answer) return;
      const values = question.multiSelect
        ? [...Array.from(checked).sort((a, b) => a - b).map((index) => options[index].label), answer]
        : [answer];
      finish(values);
    };

    function handleInput(data: string) {
      if (inputMode) {
        if (matchesKey(data, Key.escape)) {
          inputMode = false;
          editor.setText("");
          refresh();
          return;
        }
        editor.handleInput(data);
        refresh();
        return;
      }

      if (matchesKey(data, Key.up) || matchesKey(data, "k")) {
        cursor = Math.max(0, cursor - 1);
        refresh();
        return;
      }
      if (matchesKey(data, Key.down) || matchesKey(data, "j")) {
        cursor = Math.min(options.length - 1, cursor + 1);
        refresh();
        return;
      }
      if (question.multiSelect && matchesKey(data, "space")) {
        if (cursor < question.options.length) {
          checked.has(cursor) ? checked.delete(cursor) : checked.add(cursor);
          refresh();
        }
        return;
      }
      if (matchesKey(data, Key.enter)) {
        if (cursor >= question.options.length) {
          inputMode = true;
          refresh();
        } else if (question.multiSelect) {
          const indexes = checked.size > 0 ? Array.from(checked).sort((a, b) => a - b) : [cursor];
          finish(indexes.map((index) => options[index].label));
        } else {
          finish([options[cursor].label]);
        }
        return;
      }
      if (matchesKey(data, Key.escape)) done(null);
    }

    function render(width: number): string[] {
      if (cachedLines) return cachedLines;
      const lines: string[] = [];
      const renderWidth = Math.max(1, width);

      function addWrapped(text: string) {
        lines.push(...wrapTextWithAnsi(text, renderWidth));
      }

      function addWrappedWithPrefix(prefix: string, text: string) {
        const prefixWidth = visibleWidth(prefix);
        if (prefixWidth >= renderWidth) {
          addWrapped(prefix + text);
          return;
        }
        const wrapped = wrapTextWithAnsi(text, renderWidth - prefixWidth);
        const continuation = " ".repeat(prefixWidth);
        for (let i = 0; i < wrapped.length; i++) {
          lines.push(`${i === 0 ? prefix : continuation}${wrapped[i]}`);
        }
      }

      lines.push(theme.fg("accent", "─".repeat(renderWidth)));
      addWrappedWithPrefix(" ", theme.fg("text", question.question));
      lines.push("");

      for (let i = 0; i < options.length; i++) {
        const option = options[i];
        const active = i === cursor;
        const checkedMark = checked.has(i) ? "[x]" : "[ ]";
        const prefix = active ? theme.fg("accent", "> ") : "  ";
        const label = question.multiSelect
          ? `${checkedMark} ${option.label}`
          : `${i + 1}. ${option.label}`;
        addWrappedWithPrefix(prefix, theme.fg(active ? "accent" : "text", label));
        if (option.description) addWrappedWithPrefix("     ", theme.fg("muted", option.description));
      }

      if (inputMode) {
        lines.push("");
        addWrappedWithPrefix(" ", theme.fg("muted", "Your answer:"));
        for (const line of editor.render(Math.max(1, renderWidth - 2))) lines.push(` ${line}`);
        addWrappedWithPrefix(" ", theme.fg("dim", "Enter to submit • Esc to return to options"));
      } else {
        lines.push("");
        const help = question.multiSelect
          ? "↑↓/jk navigate • Space toggle • Enter confirm • Esc cancel"
          : "↑↓/jk navigate • Enter select • Esc cancel";
        addWrappedWithPrefix(" ", theme.fg("dim", help));
      }
      lines.push(theme.fg("accent", "─".repeat(renderWidth)));
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

  if (!selected) return null;
  return {
    question: question.question,
    selected,
    custom: selected.some((answer) => !question.options.some((option) => option.label === answer)),
  };
}

export async function askQuestions(
  ctx: ExtensionContext,
  questions: Question[],
): Promise<QuestionResult> {
  const answers: QuestionAnswer[] = [];
  for (const question of questions) {
    const answer = await askOne(ctx, question);
    if (!answer) return { answers, cancelled: true };
    answers.push(answer);
  }
  return { answers, cancelled: false };
}
