# Looper — Autonomous PR Agent

Use when: setting up Looper, running `looper takeover` on a PR, debugging looperd, or configuring the daemon for automated PR review/merge loops.

Looper turns AI coding agents into an autonomous dev team across GitHub repos — plan, review, fix, and ship PRs on a loop.

## Quick Install (macOS/Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/nexu-io/looper/main/scripts/install.sh | sh
```

## First-Time Setup

```bash
looper bootstrap          # interactive: writes config, installs daemon, starts looperd
looper project add /path/to/your/repo   # register a repo
```

Requirements: `git`, `gh` authenticated, one agent CLI on PATH (opencode, claude-code, codex, cursor-cli, or grok-build).

## Common Commands

### Take over a single PR (most common use)

```bash
looper takeover                         # detect current branch's PR
looper takeover owner/repo#42           # explicit PR
looper takeover owner/repo#42 --merge   # enable auto-merge when green
looper takeover --agent-vendor opencode  # specify agent if ambiguous
```

### Manual loops

```bash
looper plan   --project <id> --issue <num>      # write a spec PR
looper review <owner/repo>#<pr> [--loop]         # review and re-review
looper work   --project <id> --issue <num>       # implement from issue
```

### Inspection & control

```bash
looper status          # daemon + config health
looper ps              # list active loops
looper logs <id>       # stream logs for a loop
looper stop <id>       # stop a running loop
looper takeover list   # list active takeovers
looper takeover stop owner/repo#42   # stop a takeover
looper daemon start|stop|restart     # daemon lifecycle
```

## Config

Canonical path: `~/.looper/config.toml`
Agent vendor is required to run loops (`agent.vendor` — e.g. "opencode").

## Troubleshooting

| Symptom | Fix |
|---|---|
| `looper ps` shows stale loops | `looper run reconcile-stale` |
| daemon won't start | Check `~/.looper/config.toml` syntax, run `looper status` |
| PR not picked up | Verify `gh auth status`, labels (`looper:plan`), assignee |
| agent not found | Set `--agent-vendor opencode` or configure in `~/.looper/config.toml` |

## References

- https://github.com/nexu-io/looper
- Original skills: `skills/looper/SKILL.md` and `skills/pr-takeover/SKILL.md` in the repo
- Config docs: `docs/configuration.md`
