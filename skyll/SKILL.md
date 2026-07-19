# Skyll — Skill Discovery for AI Agents

REST API and MCP server that lets any AI agent (including opencode) search for and learn agent skills at runtime. Aggregates skills from multiple sources and returns structured JSON for context injection.

Use when: opencode or another agent needs to discover or install new skills on demand, wants to search for skills by capability.

## Quick Start

```bash
pip install skyll
```

```python
from skyll import Skyll

async with Skyll() as client:
    skills = await client.search("react performance", limit=5)
    for skill in skills:
        print(f"{skill.title}: {skill.description}")
        print(skill.content)  # Full SKILL.md content
```

Uses the hosted API at `api.skyll.app` by default — no server setup needed.

## REST API

```bash
# Search skills
curl "https://api.skyll.app/search?q=react+performance&limit=5"

# Get specific skill by name
curl "https://api.skyll.app/skill/react-best-practices"

# Get by full path
curl "https://api.skyll.app/skill/vercel-labs/agent-skills/vercel-react-best-practices"
```

Interactive docs: `api.skyll.app/docs`

## MCP Server (Hosted — No Install)

Add to opencode `.mcp.json` or MCP client config:
```json
{
  "mcpServers": {
    "skyll": {
      "url": "https://api.skyll.app/mcp"
    }
  }
}
```

### MCP Tools

| Tool | Description |
|---|---|
| `search_skills` | Search skills by natural language query |
| `add_skill` | Get a skill by name (like `npx skills add`) |
| `get_skill` | Get specific skill by source/id |
| `get_cache_stats` | Cache statistics |

## Self-Hosted Skyll

```bash
git clone https://github.com/assafelovic/skyll.git
cd skyll
pip install -e ".[server]"
echo "GITHUB_TOKEN=ghp_your_token" > .env
uvicorn src.main:app --port 8000
```

For opencode MCP: point `url` in `.mcp.json` to `http://localhost:8000/mcp`.

## Adding Skills to Community Registry

Edit `registry/SKILLS.md`:
```
your-skill-id | your-username/your-repo | path/to/skill | What your skill does
```

Then submit a PR to https://github.com/assafelovic/skyll.

## Troubleshooting

| Issue | Fix |
|---|---|
| Empty results | Check network access to api.skyll.app, or run self-hosted server |
| MCP not connecting | Verify the URL in `.mcp.json` matches either hosted or self-hosted endpoint |
| Low relevance scores | Make query more specific, use natural language concepts |
| GitHub rate limited | Add `GITHUB_TOKEN` to self-hosted .env |
| Self-hosted server won't start | Ensure Python >=3.10, all dependencies installed, port not in use |

## References

- Repo: https://github.com/assafelovic/skyll
- Hosted API: https://api.skyll.app
- Website: https://skyll.app
