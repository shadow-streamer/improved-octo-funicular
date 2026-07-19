# Botpress ADK

Comprehensive guide for building AI agents with the Botpress Agent Development Kit (ADK) — a convention-based TypeScript framework where file structure maps directly to bot behavior.

Use when: building new features with Botpress ADK, working with Actions/Tools/Workflows, implementing data storage, using Zai for AI operations, configuring integrations.

## Install the Skill

```bash
npx skills add botpress/skills --skill adk
```

## Key Concepts

### Actions — strongly-typed functions
```typescript
// my-bot/src/actions/myAction.ts
import { Action } from "@botpress/adk";

export default new Action({
  name: "myAction",
  input: { /* schema */ },
  output: { /* schema */ },
  async handler({ input, ctx }) {
    // implementation
  },
});
```

### Tools — AI-callable functions
Tools are exposed to the LLM to call autonomously during conversations.

### Workflows — long-running processes
```typescript
// my-bot/src/workflows/onboarding.ts
// Stateful, multi-step processes with error handling
```

### Conversations — message handlers
```typescript
// my-bot/src/conversations/greeting.ts
export default async (req, ctx) => {
  await ctx.respond("Hello! How can I help?");
};
```

### Triggers — event-driven automation

Trigger workflows or actions on events (webhook, schedule, etc.):
```typescript
// my-bot/src/triggers/webhook.ts
export default {
  event: 'webhook:incoming',
  handler: async (event, ctx) => {
    const payload = event.payload;
    // Handle webhook event
    await ctx.triggerWorkflow('onboarding', payload);
  },
};
```

## Data & Content

- **Tables** — structured storage with semantic search
- **Files** — file storage and management
- **Knowledge Bases** — RAG implementation

## AI Features (Zai)

```typescript
import { zai } from "@botpress/adk";

// Extract structured data
const result = await zai.extract(text, schema);

// Check classification
const isSpam = await zai.check(text, "Is this spam?");

// Summarize
const summary = await zai.summarize(longText);
```

## Configuration

- Agent config: `agent.json`
- Integrations and plugins
- Environment variables
- CLI reference

## Dev Tools

```bash
# CLI commands
adk init     # scaffold new project
adk dev      # local development
adk deploy   # deploy to Botpress
```

## Troubleshooting

| Issue | Fix |
|---|---|
| Actions not found | Verify file is in correct `src/actions/` dir and exported as default |
| Workflow stuck | Check state transitions and workflow definition |
| Zai operations fail | Confirm API key is set and LLM provider configured in `agent.json` |
| `adk` CLI commands fail | Ensure ADK is installed and config is valid |
| Tables not returning results | Verify the table schema and that KB is properly populated |

## References

- Repo: https://github.com/botpress/skills
- Original skill: `skills/adk/SKILL.md` in the repo
- Docs: https://botpress.com/docs
