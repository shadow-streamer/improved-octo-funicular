# Claude Code Kanban

Web-based real-time Kanban dashboard for AI coding sessions. Watch tasks move through Pending → In Progress → Completed, view conversation logs, track subagents, and monitor context usage.

Built for Claude Code but can be used alongside opencode — the dashboard watches `~/.claude/` task files, and opencode can be configured to use the same directory or run side-by-side with Claude Code.

## Quick Start

```bash
# Install hooks (one-time setup)
npx claude-code-kanban --install

# Start the dashboard
npx claude-code-kanban --open
```

## How It Works

The dashboard watches task files and conversation logs written to `~/.claude/` and streams updates to the browser via SSE. It never directs agent work — it only observes.

### Using alongside opencode

- If you run both Claude Code and opencode, the kanban board will show Claude Code's sessions
- opencode currently does not write to `~/.claude/` directory, so its tasks won't appear on the kanban
- Best use case: run Claude Code for task tracking, opencode for other tasks — they coexist without conflict
- If you want to use only opencode, the kanban dashboard is still useful for visualizing any Claude Code sessions you may have

## Features

- Real-time task board: Pending → In Progress → Completed
- Session log: full conversation timeline (prompts, replies, tool calls)
- Agent log: subagent tracking with duration and status
- Task detail panel with inline editing and dependency tracking
- Context window monitoring with token/cost breakdown
- 17 color themes (Dracula, Nord, Catppuccin, Gruvbox, Tokyo Night, etc.)
- Keyboard shortcuts: press `?` for the full list

## Custom Port

```bash
PORT=8080 npx claude-code-kanban            # custom port
npx claude-code-kanban --open               # auto-open browser
npx claude-code-kanban --dir=~/.claude-work  # custom config dir
```

## Global Install

```bash
npm install -g claude-code-kanban
claude-code-kanban --open
```

## Context Window Monitoring

The installer copies `context-status.sh` to `~/.claude/hooks/`. Wire it into the statusline in `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/hooks/context-status.sh | npx -y ccstatusline@latest",
    "padding": 0
  }
}
```

## Uninstall

```bash
npx claude-code-kanban --uninstall
```

Non-destructive — existing `~/.claude/settings.json` is preserved.

## Troubleshooting

| Issue | Fix |
|---|---|
| Dashboard shows no tasks | Ensure Claude Code has been run at least once; verify `~/.claude/` exists |
| Port already in use | Set `PORT=8081` or another port to avoid conflict |
| Hooks not working | Re-run `npx claude-code-kanban --install` |
| opencode sessions not appearing | opencode writes to a different format; this dashboard is designed for Claude Code file format |
| Dashboard won't start | Ensure Node.js >=18 is installed |

## References

- Repo: https://github.com/NikiforovAll/claude-code-kanban
- Docs: https://nikiforovall.blog/claude-code-kanban/
