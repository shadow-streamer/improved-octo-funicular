# Botpress ADK Evals

Complete reference for writing, running, and iterating on evals (automated conversation tests) for ADK agents. Covers eval file format, all assertion types, CLI usage, and per-primitive testing patterns.

Use when: writing automated tests for an ADK agent, learning the eval file format, running evals and interpreting results, integrating evals into CI pipelines.

## Install the Skill

```bash
npx skills add botpress/skills --skill adk-evals
```

## Eval File Format

```yaml
turns:
  - user: "Hello"
    responses:
      - text: "Hi! How can I help you today?"
    tools_called: []
    
  - user: "Create a ticket for login bug"
    responses:
      - text: "I'll create that ticket for you."
    tools_called:
      - name: "createTicket"
        input:
          title: "Login bug"
```

## Assertion Types

| Type | Description |
|---|---|
| `response` | Match response text |
| `tools` | Verify tool calls and their inputs |
| `state` | Check workflow/agent state |
| `tables` | Verify table data |
| `workflow` | Assert workflow progress |
| `timing` | Assert response time constraints |

## Running Evals

```bash
adk eval path/to/eval.yaml   # run a single eval
adk eval ./evals/             # run all evals in directory
adk eval --watch              # watch mode (re-runs on change)
```

## Testing Patterns

- **Actions** — test that actions produce correct outputs
- **Tools** — verify LLM selects the right tool with correct parameters
- **Workflows** — test multi-step flows end-to-end
- **Conversations** — test dialog flows
- **Tables** — verify data CRUD
- **State** — test state transitions

## CI Integration

```yaml
# .github/workflows/evals.yml
- run: adk eval ./evals/
```

## Troubleshooting

| Issue | Fix |
|---|---|
| Eval not running | Check that `adk` CLI is installed and the bot is running locally |
| Assertion always fails | Use `adk eval --watch` and iterate on the test interactively |
| Tools not being called | Verify the tool is implemented and the bot's LLM configuration calls it |
| CI failing | Ensure the `adk` CLI is available in the CI environment |

## References

- Repo: https://github.com/botpress/skills
- Original skill: `skills/adk-evals/SKILL.md` in the repo
