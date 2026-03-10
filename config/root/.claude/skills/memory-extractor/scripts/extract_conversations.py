#!/usr/bin/env python3
"""
extract_conversations.py — セッションJSONLから会話テキストを抽出する。

セッションログからuser/assistantのテキストのみを抽出し、
knowledge extraction用のコンパクトなJSONを出力する。

Usage:
    python3 extract_conversations.py <project-path> [options]

Arguments:
    project-path    "all" or working directory path or encoded project name

Options:
    --days N        直近N日間のみ対象 (default: 14)
    --output PATH   出力先 (default: ./conversations.json)
    --min-turns N   最小ターン数 (default: 2)
    --max-chars N   assistantメッセージの最大文字数 (default: 500)
    --verbose       詳細出力
"""

import json
import os
import sys
import glob
import argparse
from datetime import datetime, timedelta, timezone
from pathlib import Path


def encode_project_path(working_dir: str) -> str:
    abs_path = os.path.abspath(os.path.expanduser(working_dir))
    encoded = abs_path.replace("/", "-").replace(".", "-")
    if not encoded.startswith("-"):
        encoded = "-" + encoded
    return encoded


def find_project_dirs(project_path: str) -> list[str]:
    claude_projects = os.path.expanduser("~/.claude/projects")

    if project_path == "all":
        if not os.path.isdir(claude_projects):
            return []
        return [
            os.path.join(claude_projects, d)
            for d in os.listdir(claude_projects)
            if os.path.isdir(os.path.join(claude_projects, d))
        ]

    if os.path.isdir(project_path) and project_path.startswith(claude_projects):
        return [project_path]

    direct = os.path.join(claude_projects, project_path)
    if os.path.isdir(direct):
        return [direct]

    encoded = encode_project_path(project_path)
    encoded_path = os.path.join(claude_projects, encoded)
    if os.path.isdir(encoded_path):
        return [encoded_path]

    return []


def auto_detect_project(cwd: str) -> str | None:
    claude_projects = os.path.expanduser("~/.claude/projects")
    if not os.path.isdir(claude_projects):
        return None

    available = set(os.listdir(claude_projects))
    abs_cwd = os.path.abspath(os.path.expanduser(cwd))

    encoded = encode_project_path(abs_cwd)
    basename = os.path.basename(encoded) if "/" in encoded else encoded
    if basename in available:
        return os.path.join(claude_projects, basename)

    current = abs_cwd
    while current != os.path.dirname(current):
        current = os.path.dirname(current)
        enc = encode_project_path(current)
        name = os.path.basename(enc) if "/" in enc else enc
        if name in available:
            return os.path.join(claude_projects, name)

    return None


def extract_text_from_content(content) -> str:
    """contentフィールドからテキストのみ抽出する。"""
    if isinstance(content, str):
        return content.strip()
    if isinstance(content, list):
        texts = []
        for block in content:
            if isinstance(block, dict) and block.get("type") == "text":
                texts.append(block.get("text", ""))
        return " ".join(t for t in texts if t).strip()
    return ""


def parse_session(filepath: str, max_chars: int = 500) -> dict | None:
    """セッションJSONLからuser/assistantの会話ペアを抽出する。"""
    session_id = Path(filepath).stem
    conversations = []
    first_ts = None
    last_ts = None

    current_user_msg = None
    current_assistant_parts = []

    try:
        with open(filepath, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                except json.JSONDecodeError:
                    continue

                msg_type = obj.get("type", "")

                # タイムスタンプ取得
                for key in ("timestamp", "created_at", "ts"):
                    if key in obj:
                        ts = str(obj[key])
                        if first_ts is None:
                            first_ts = ts
                        last_ts = ts
                        break

                inner = obj.get("message", {})
                if isinstance(inner, dict):
                    role = inner.get("role", msg_type)
                    content = inner.get("content", "")
                else:
                    role = msg_type
                    content = ""

                if role in ("user", "human"):
                    # 前のペアを保存
                    if current_user_msg is not None and current_assistant_parts:
                        assistant_text = "\n".join(current_assistant_parts)
                        if assistant_text:
                            conversations.append({
                                "user": current_user_msg,
                                "assistant": assistant_text[:max_chars],
                            })

                    text = extract_text_from_content(content)
                    # ビルトインコマンドはスキップ
                    if text.startswith("/") and text.split()[0].lstrip("/") in {
                        "help", "clear", "compact", "model", "usage", "cost",
                        "login", "logout", "status", "config", "permissions",
                        "doctor", "fast", "slow", "quit", "exit", "diff",
                        "undo", "resume", "ide", "add-dir", "tools", "tasks",
                        "mcp", "vim", "emacs", "memory",
                    }:
                        current_user_msg = None
                        current_assistant_parts = []
                        continue

                    current_user_msg = text
                    current_assistant_parts = []

                elif role == "assistant":
                    text = extract_text_from_content(content)
                    if text and current_user_msg is not None:
                        current_assistant_parts.append(text)

        # 最後のペア
        if current_user_msg is not None and current_assistant_parts:
            assistant_text = "\n".join(current_assistant_parts)
            if assistant_text:
                conversations.append({
                    "user": current_user_msg,
                    "assistant": assistant_text[:max_chars],
                })

    except Exception as e:
        print(f"  ERROR reading {filepath}: {e}", file=sys.stderr)
        return None

    if not conversations:
        return None

    return {
        "session_id": session_id,
        "project_dir": _extract_project_dir(filepath),
        "first_timestamp": first_ts,
        "last_timestamp": last_ts,
        "turn_count": len(conversations),
        "conversations": conversations,
    }


def _extract_project_dir(filepath: str) -> str | None:
    parts = Path(filepath).parts
    for i, part in enumerate(parts):
        if part == "projects" and i + 1 < len(parts):
            return parts[i + 1]
    return None


def filter_by_date(sessions: list[dict], days: int) -> list[dict]:
    if days <= 0:
        return sessions

    cutoff = datetime.now(timezone.utc) - timedelta(days=days)
    filtered = []

    for s in sessions:
        ts = s.get("first_timestamp")
        if ts is None:
            filtered.append(s)
            continue
        try:
            dt = datetime.fromisoformat(ts.replace("Z", "+00:00"))
            if dt >= cutoff:
                filtered.append(s)
        except (ValueError, TypeError):
            try:
                dt = datetime.fromtimestamp(float(ts) / 1000, tz=timezone.utc)
                if dt >= cutoff:
                    filtered.append(s)
            except (ValueError, TypeError):
                filtered.append(s)

    return filtered


def collect(
    project_path: str,
    days: int = 14,
    min_turns: int = 2,
    max_chars: int = 500,
    verbose: bool = False,
) -> dict:
    project_dirs = find_project_dirs(project_path)
    if not project_dirs:
        return {"error": f"Project not found: {project_path}"}

    all_sessions = []

    for pdir in project_dirs:
        jsonl_files = glob.glob(os.path.join(pdir, "*.jsonl"))
        if verbose:
            print(f"Scanning {pdir}: {len(jsonl_files)} files", file=sys.stderr)

        for fp in sorted(jsonl_files):
            if Path(fp).name == "history.jsonl":
                continue

            session = parse_session(fp, max_chars=max_chars)
            if session and session["turn_count"] >= min_turns:
                all_sessions.append(session)

    if days > 0:
        before = len(all_sessions)
        all_sessions = filter_by_date(all_sessions, days)
        if verbose:
            print(f"Date filter: {before} -> {len(all_sessions)} sessions", file=sys.stderr)

    all_sessions.sort(key=lambda s: s.get("first_timestamp") or "", reverse=True)

    total_turns = sum(s["turn_count"] for s in all_sessions)

    # プロジェクト別集計
    by_project = {}
    for s in all_sessions:
        p = s.get("project_dir", "unknown")
        by_project[p] = by_project.get(p, 0) + 1

    return {
        "collected_at": datetime.now(timezone.utc).isoformat(),
        "config": {"days": days, "min_turns": min_turns, "max_chars": max_chars},
        "sessions": all_sessions,
        "summary": {
            "total_sessions": len(all_sessions),
            "total_turns": total_turns,
            "sessions_by_project": by_project,
        },
    }


def main():
    parser = argparse.ArgumentParser(
        description="セッションから会話テキストを抽出"
    )
    parser.add_argument(
        "project_path", nargs="?", default=None,
        help='"all", working directory, or encoded project name',
    )
    parser.add_argument("--cwd", default=None)
    parser.add_argument("--days", type=int, default=14)
    parser.add_argument("--output", default="./conversations.json")
    parser.add_argument("--min-turns", type=int, default=2)
    parser.add_argument("--max-chars", type=int, default=500)
    parser.add_argument("--verbose", action="store_true")

    args = parser.parse_args()

    project_path = args.project_path
    if project_path is None and args.cwd:
        detected = auto_detect_project(args.cwd)
        if detected:
            project_path = detected
        else:
            print("ERROR: Could not auto-detect project", file=sys.stderr)
            sys.exit(1)
    elif project_path is None:
        print("ERROR: No project path specified", file=sys.stderr)
        sys.exit(1)

    result = collect(
        project_path,
        days=args.days,
        min_turns=args.min_turns,
        max_chars=args.max_chars,
        verbose=args.verbose,
    )

    if "error" in result:
        print(json.dumps(result, indent=2), file=sys.stderr)
        sys.exit(1)

    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    with open(args.output, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2, ensure_ascii=False, default=str)

    s = result["summary"]
    print(f"Extracted {s['total_sessions']} sessions, {s['total_turns']} turns")
    print(f"Output: {args.output}")


if __name__ == "__main__":
    main()
