# RTK - Rust Token Killer

**Purpose**: Reduce command output when filtering preserves the information needed for the task.

## Usage

Use RTK for verbose or repetitive output where its summary keeps the useful details. It is especially useful for large diffs and structured data:

```bash
rtk git diff
rtk json large-response.json
rtk test cargo test
```

Use the raw command when exact output matters, including when diagnosing a failure, checking paths or line numbers, confirming that a search returned no matches, or inspecting short output. If RTK is used, `rtk proxy <cmd>` skips output filtering.

RTK summaries can omit useful details or misrepresent results for some commands. Do not treat a summary alone as proof that a command succeeded or found nothing. If filtered output provides a recall identifier, `rtk recall <hash>` can retrieve the original output when tracking is available.

## Meta Commands

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover          # Analyze Claude Code history for missed opportunities
rtk proxy <cmd>       # Run a command without output filtering
```

## Installation Verification

```bash
rtk --version         # Should show: rtk X.Y.Z
rtk gain              # Requires an accessible tracking database
rtk proxy which rtk   # Verify correct binary
```

⚠️ **Name collision**: If `rtk --version` does not report an RTK version, another `rtk` binary such as reachingforthejack/rtk (Rust Type Kit) may be installed.

## Explicit Usage

Commands are not automatically rewritten. Prefix a command with `rtk` when its output benefits from filtering; use `rtk proxy` when exact output is needed.

Refer to CLAUDE.md for project instructions.
