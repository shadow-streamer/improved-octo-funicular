# Botpress ADK Debugger

Systematic debugging for ADK agents. Teaches how to read traces and logs, diagnose common failures, debug LLM behavior issues, and follow a structured debug workflow.

Use when: bot isn't responding or behaves unexpectedly, tool calls are failing, workflows are stuck, LLM is hallucinating, build/deploy errors, traces/logs reading.

## Install the Skill

```bash
npx skills add botpress/skills --skill adk-debugger
```

## Traces & Logs

```bash
adk check       # validate project structure
adk logs        # view bot logs
adk traces      # view execution traces
adk chat        # interactive debugging session
```

### Trace Structure

Traces contain spans for each operation:
- `action` — action execution
- `tool_call` — tool invocation
- `workflow_step` — workflow step execution
- `llm` — LLM request/response
- `conversation` — message handling

## Common Failures

| Symptom | Check |
|---|---|
| Bot not responding | LLM config, agent.json, conversation handler |
| Wrong tool selected | LLM prompt, tool descriptions |
| Tool call failing | Input schema, implementation error |
| Workflow stuck | Step transitions, state persistence |
| LLM hallucination | Context size, system prompt |
| Build errors | TypeScript compilation, import paths |

## LLM Debugging

- **Wrong tool selection** — make tool descriptions clearer
- **Hallucinated parameters** — add input validation
- **Refusals** — check content policy and prompt
- **Looping** — add max iterations guard

## Debug Workflow (8-Step Loop)

1. **Validate** — check config and basic connectivity
2. **Reproduce** — get consistent reproduction
3. **Logs** — examine runtime logs
4. **Traces** — read execution traces
5. **Classify** — identify failure category
6. **Fix** — apply the fix
7. **Verify** — test the fix
8. **Prevent** — add tests/guards

## References

- Repo: https://github.com/botpress/skills
- Original skill: `skills/adk-debugger/SKILL.md` in the repo
