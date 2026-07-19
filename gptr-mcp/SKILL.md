# GPT Researcher MCP Server

MCP server enabling LLM applications to perform deep research via the MCP protocol. Higher quality than standard web search — autonomously explores and validates multiple sources.

Use when: adding deep research capabilities to any MCP-compatible agent (Claude Code, opencode, Cursor, n8n).

## Quick Start (Claude Desktop / opencode)

```bash
git clone https://github.com/assafelovic/gpt-researcher.git
cd gpt-researcher/gptr-mcp
pip install -r requirements.txt
```

Config `.mcp.json`:
```json
{
  "mcpServers": {
    "gptr-mcp": {
      "command": "python",
      "args": ["/absolute/path/to/gpt-researcher/gptr-mcp/server.py"],
      "env": {
        "OPENAI_API_KEY": "your-openai-key",
        "TAVILY_API_KEY": "your-tavily-key"
      }
    }
  }
}
```

## MCP Tools

| Tool | Description | Latency |
|---|---|---|
| `deep_research` | Full deep web research on a topic | ~30-40s |
| `quick_search` | Fast web search (Tavily/Bing/Google) | ~2-5s |
| `write_report` | Generate report from research results | ~5-10s |
| `get_research_sources` | Get sources used in research | instant |
| `get_research_context` | Full research context | instant |

## Docker Deployment

```bash
docker compose up -d    # from gptr-mcp directory
```

SSE transport auto-detected in Docker — connects at `http://localhost:8000/sse`.

## Transport Modes

| Mode | Use case |
|---|---|
| STDIO (default) | Claude Desktop, local MCP clients |
| SSE | Docker, web clients, n8n |
| Streamable HTTP | Modern web deployments |

Force a mode:
```bash
export MCP_TRANSPORT=sse
python server.py
```

## Required

- Python >=3.11
- OpenAI API key
- Tavily API key (or other supported retriever)

## n8n Integration

```bash
docker network connect n8n-mcp-net gptr-mcp
# Connect n8n to: http://gptr-mcp:8000/sse
```

## Troubleshooting

| Issue | Fix |
|---|---|
| Server not appearing | Check `.mcp.json` syntax, use absolute paths for command args |
| Tools not showing up | Restart the agent, verify Python >=3.11 |
| API key errors | Keys must be in `env` section of config, not `.env` file |

## References

- Repo: https://github.com/assafelovic/gptr-mcp
- GPT Researcher: https://github.com/assafelovic/gpt-researcher
