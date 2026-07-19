# Botpress ADK Frontend

Production-tested patterns for building frontend applications that integrate with Botpress ADK bots. Covers authentication, type-safe API calls, client management, and type generation workflows.

Use when: building a frontend that connects to a Botpress bot, implementing authentication with PATs, setting up `@botpress/client`, calling bot actions from React/Next.js via opencode.

## Install the Skill

```bash
npx skills add botpress/skills --skill adk-frontend
```

## Authentication

Use Personal Access Tokens (PATs) stored in cookies:

```typescript
// Cookie-based PAT storage
import { getCookie, setCookie } from "cookies-next";

export function storePat(pat: string) {
  setCookie("bp_pat", pat, { maxAge: 86400 * 30, secure: true });
}

export function getPat(): string | undefined {
  return getCookie("bp_pat");
}
```

OAuth flow for user login:
```typescript
// Redirect user to Botpress OAuth endpoint
const oauthUrl = `https://api.botpress.dev/oauth/authorize?client_id=...&redirect_uri=...`;
window.location.href = oauthUrl;
```

## Client Management

```typescript
import { BotpressClient } from "@botpress/client";

const createClient = (pat: string) =>
  new BotpressClient({
    botId: process.env.NEXT_PUBLIC_BOT_ID!,
    pat,
  });
```

Use Zustand for client state management:

```typescript
import { create } from "zustand";

interface ClientState {
  client: BotpressClient | null;
  pat: string | null;
  setClient: (pat: string) => void;
}

export const useClientStore = create<ClientState>((set) => ({
  client: null,
  pat: null,
  setClient: (pat) => set({ client: createClient(pat), pat }),
}));
```

## Type Generation

Generate types by running the ADK CLI, then reference them:

```typescript
/// <reference types="./.botpress/types" />
import type { BotAction } from "./.botpress/types";

// Use generated types for type-safe action calls
```

## Action Calls (React Query)

```typescript
import { useMutation } from "@tanstack/react-query";
import { useClientStore } from "@/stores/client";

export function useCallAction(actionName: string) {
  const client = useClientStore((s) => s.client);

  return useMutation({
    mutationFn: (input: Record<string, unknown>) =>
      client.callAction(actionName, input),
  });
}

// Usage in a component
function CreateTicketButton() {
  const { mutate, isLoading } = useCallAction("createTicket");
  return (
    <button onClick={() => mutate({ title: "Bug fix" })} disabled={isLoading}>
      Create Ticket
    </button>
  );
}
```

## Key Technologies

- `@botpress/client` — official TypeScript client
- TypeScript triple-slash references for types
- React Query (recommended for mutations)
- Zustand (client state management)

## Troubleshooting

| Issue | Fix |
|---|---|
| Client instantiation fails | Verify botId and PAT are correct, check CORS settings |
| Types not found | Run `botpress typegen` or ensure `.botpress/types` is generated |
| React Query mutation hangs | Check that the client is initialized before calling actions |
| PAT expired | Generate a new PAT in Botpress admin panel |

## References

- Repo: https://github.com/botpress/skills
- Original skill: `skills/adk-frontend/SKILL.md` in the repo
- Botpress client SDK: https://www.npmjs.com/package/@botpress/client
