# RTK - Rust Token Killer (Codex CLI)

**Purpose**: Reduce command output when filtering keeps the information needed for the task.

## Usage

Use RTK for verbose or repetitive output where its summary preserves the useful details. It is especially useful for large diffs and structured data:

```bash
rtk git diff
rtk json large-response.json
rtk test cargo test
```

Use `rtk proxy <cmd>` when exact output matters, including when:

- diagnosing a failed command and the summary omits the underlying cause;
- checking exact paths, line numbers, or whether a search returned no matches;
- inspecting short output that RTK does not meaningfully reduce.

RTK summaries can omit useful details or misrepresent results for some commands. Treat them as a presentation aid, not as proof that a command found nothing or succeeded. If filtered output provides a recall identifier, `rtk recall <hash>` can retrieve the original output when tracking is available.

## Meta Commands

```bash
rtk gain            # Token savings analytics (requires an accessible tracking database)
rtk gain --history  # Recent command savings history
rtk proxy <cmd>     # Run a command without output filtering
```

## Verification

```bash
rtk --version
rtk gain
rtk proxy which rtk
```
