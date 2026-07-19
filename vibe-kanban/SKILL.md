# Vibe Kanban

Kanban board UI with agent workspaces. Plan work on a board, launch coding agents in isolated workspaces (branch + terminal + dev server), review diffs inline, and ship PRs.

⚠️ **Sunsetting** — Vibe Kanban is no longer actively maintained but still works in its current state.

Supports opencode among 10+ agents (Claude Code, Codex, Gemini CLI, GitHub Copilot, Amp, Cursor, etc.).

## Quick Start

```bash
# Make sure opencode is authenticated and on PATH
npx vibe-kanban
```

Opens the web UI at a local port. From the UI:
1. Create issues on the kanban board
2. Create a workspace (assigns an agent)
3. Agent gets a branch, terminal, and dev server
4. Review diffs and leave inline comments in the UI

## Connecting opencode

Vibe Kanban auto-detects agents on PATH. If opencode is available, it appears in the agent selector when creating a workspace.

If not detected, ensure opencode is installed globally and on your PATH:
```bash
which opencode  # should return a path
```

## Workflow

1. **Plan** — create kanban issues, prioritise, assign
2. **Launch** — create a workspace with opencode as the agent
3. **Execute** — agent works in an isolated branch with a terminal
4. **Review** — view diffs in the UI, leave inline comments
5. **Ship** — open a PR with AI-generated description via the UI

## Key Features

- Kanban board with drag-and-drop
- Built-in browser with devtools and device emulation
- Inline diff review with comments
- Self-hostable (see self-hosting guide)
- PR creation with AI-generated descriptions

## Custom Port

```bash
PORT=3456 npx vibe-kanban
```

## Env Vars

| Variable | Default | Description |
|---|---|---|
| `PORT` | auto | Server port |
| `HOST` | `127.0.0.1` | Backend host |
| `DISABLE_WORKTREE_CLEANUP` | — | Debug: disable git worktree cleanup |

## Self-Hosting

See the self-hosting guide at https://www.vibekanban.com/

## Troubleshooting

| Issue | Fix |
|---|---|
| Vibe Kanban doesn't detect opencode | Ensure `which opencode` returns a valid path; restart VK |
| npx command fails | Check Node.js >=18 is installed and npx is available |
| Agent workspace not starting | Verify the branch name is valid and repo is clean |
| Workspace port already in use | Change the PORT env var or wait for the workspace to release ports |
| Can't view the app preview | Check the workspace dev server started correctly in the agent terminal |

## References

- Repo: https://github.com/BloopAI/vibe-kanban
- Docs: https://www.vibekanban.com/
