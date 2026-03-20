# Codex Configuration Notes

## Purpose

`~/.codex` には永続設定と実行時データが混在するため、静的設定だけを dotfiles で管理する。

## Managed Files

- `config.toml`
- `rules/default.rules`
- `AGENTS.md`
- `instructions.md`

## Runtime Files

次はローカル実行時データとして扱い、dotfiles に含めない。

- `auth.json`
- `history.jsonl`
- `models_cache.json`
- `*.sqlite*`
- `sessions/`
- `shell_snapshots/`
- `skills/`
- `tmp/`
- `memories/`
