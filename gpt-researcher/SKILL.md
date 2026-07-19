# GPT Researcher

Autonomous deep research agent. Produces detailed, factual, unbiased research reports with citations from web and local documents.

Use when: conducting deep web research on any topic, generating comprehensive research reports, analyzing multiple sources.

## Quick Install

```bash
# Install as pip package
pip install gpt-researcher

# Or install as a Claude/opencode skill
npx skills add assafelovic/gpt-researcher
```

## Required API Keys

```bash
export OPENAI_API_KEY=your_openai_api_key
export TAVILY_API_KEY=your_tavily_api_key
```

## Usage

```python
from gpt_researcher import GPTResearcher

query = "why is Nvidia stock going up?"
researcher = GPTResearcher(query=query)
research_result = await researcher.conduct_research()
report = await researcher.write_report()
```

## CLI

```bash
python -m uvicorn main:app --reload    # start web server (from repo)
# Visit http://localhost:8000
```

## Deep Research Mode

Advanced recursive research with tree-like exploration, configurable depth and breadth:

```bash
# Enable in .env or as env vars
export DEEP_RESEARCH_DEPTH=2    # How deep to go in subtopics (default: 2)
export DEEP_RESEARCH_BREADTH=3  # How many subtopics per level (default: 3)
```

```python
# With GPTResearcher class
researcher = GPTResearcher(
    query="impact of AI on healthcare",
    report_type="deep",
)
# Takes ~5 min, costs ~$0.4 (using o3-mini high reasoning effort)
report = await researcher.write_report()
```

## Features

- Web & local document research (PDF, text, CSV, Excel, Markdown, PPT, Word)
- Export to PDF, Word, Markdown
- Smart image scraping and filtering
- JavaScript-enabled web scraping
- MCP integration (connect to GitHub, databases, custom APIs)
- Multi-agent assistant (LangGraph/AG2)

## Local Documents

```bash
export DOC_PATH="./my-docs"
```
Then use `report_source="local"` when instantiating `GPTResearcher`.

## Troubleshooting

| Issue | Fix |
|---|---|
| Python version | Requires >=3.11 (3.12+ recommended) |
| API errors | Verify OPENAI_API_KEY and TAVILY_API_KEY are set |
| Rate limits | Add more API quota or use different providers |
| Token limits | Use `write_report()` with appropriate report type |

## References

- Repo: https://github.com/assafelovic/gpt-researcher
- Docs: https://docs.gptr.dev
- Original skill: `skills/gpt-researcher/SKILL.md` in the repo
