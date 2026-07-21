#!/usr/bin/env -S deno run --allow-read --allow-write --allow-env

// PreToolUse hook: 単一パターンのgrep/rg呼び出しが3回連続したらブロックし、
// バッチ化（rg -e pat1 -e pat2 ...）かサブエージェント委譲を促す。
// Edit/Write系ツールや、既にバッチ化されたgrep呼び出しはカウンタをリセットする。

const STREAK_THRESHOLD = 3;

interface HookInput {
  session_id?: string;
  tool_name?: string;
  tool_input?: {
    command?: string;
    pattern?: string;
  };
}

function isBatchedPattern(pattern: string): boolean {
  return /\|/.test(pattern);
}

function isBatchedBashGrep(command: string): boolean {
  const eFlagCount = (command.match(/-e\s+\S/g) ?? []).length;
  return eFlagCount >= 2 || /\|/.test(command);
}

async function readStreak(streakFile: string): Promise<number> {
  try {
    const text = await Deno.readTextFile(streakFile);
    const n = Number.parseInt(text.trim(), 10);
    return Number.isNaN(n) ? 0 : n;
  } catch {
    return 0;
  }
}

async function writeStreak(streakFile: string, value: number): Promise<void> {
  await Deno.writeTextFile(streakFile, String(value));
}

async function main() {
  const stdinText = await new Response(Deno.stdin.readable).text();
  let input: HookInput;
  try {
    input = JSON.parse(stdinText);
  } catch {
    Deno.exit(0);
  }

  const sessionId = input.session_id ?? "unknown";
  const stateDir = `/tmp/claude-hooks-${sessionId}`;
  await Deno.mkdir(stateDir, { recursive: true });
  const streakFile = `${stateDir}/grep_streak`;

  const toolName = input.tool_name ?? "";

  if (["Edit", "Write", "MultiEdit", "NotebookEdit"].includes(toolName)) {
    await writeStreak(streakFile, 0);
    Deno.exit(0);
  }

  let isGrepLike = false;
  let isBatched = false;
  if (toolName === "Grep") {
    const pattern = input.tool_input?.pattern ?? "";
    isGrepLike = pattern.length > 0;
    isBatched = isBatchedPattern(pattern);
  } else if (toolName === "Bash") {
    const command = input.tool_input?.command ?? "";
    if (/^\s*(grep|rg)\b/.test(command)) {
      isGrepLike = true;
      isBatched = isBatchedBashGrep(command);
    }
  }

  if (!isGrepLike) {
    // grep/rg以外のツール呼び出しはカウンタに影響しない（中立）
    Deno.exit(0);
  }

  if (isBatched) {
    // バッチ化されたクエリは望ましい挙動としてカウンタをリセットする
    await writeStreak(streakFile, 0);
    Deno.exit(0);
  }

  const streak = (await readStreak(streakFile)) + 1;

  if (streak >= STREAK_THRESHOLD) {
    await writeStreak(streakFile, 0);
    console.error(
      "直近で単一パターンのgrep/rg呼び出しが3回連続しています。関連シンボルはまとめて1回のコマンド（rg -e pat1 -e pat2 ...）で検索するか、Explore/researchサブエージェントに委譲してください。",
    );
    Deno.exit(2);
  }

  await writeStreak(streakFile, streak);
  Deno.exit(0);
}

await main();
