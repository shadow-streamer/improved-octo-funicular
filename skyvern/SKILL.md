# Skyvern — AI Browser Automation

Automate browser-based workflows using LLMs and computer vision. Skyvern provides a Playwright-compatible SDK that adds AI functionality on top of Playwright.

Use when: automating any browser workflow, form filling, data extraction, file downloads, login flows, multi-step web tasks.

## Quick Install

```bash
# Python SDK + local server + UI (recommended)
pip install "skyvern[all]"

# Start everything
skyvern quickstart
# Open http://localhost:8080
```

Or with Docker:
```bash
git clone https://github.com/skyvern-ai/skyvern.git && cd skyvern
docker compose up -d
# Open http://localhost:8080
```

## Python SDK

```python
from skyvern import Skyvern

# Local mode
skyvern = Skyvern.local()

# Or connect to Skyvern Cloud
skyvern = Skyvern(api_key="your-api-key")

# Run a task
task = await skyvern.run_task(
    prompt="Find the top post on hackernews today",
)

# Or use the browser SDK
browser = await skyvern.launch_cloud_browser()
page = await browser.get_working_page()
await page.goto("https://example.com")

# AI-powered commands
await page.act("Click the login button and wait for dashboard")
result = await page.extract("Get product name and price")
is_logged = await page.validate("Check if user is logged in")
```

## AI-Augmented Playwright

All standard Playwright actions support AI element location via `prompt`:

```python
await page.click(prompt="Click the green Submit button")
await page.fill(prompt="Email field", value="user@example.com")
await page.select_option(prompt="Country dropdown", value="US")
```

## Multi-Step Tasks

```python
await page.agent.run_task("Complete checkout with: John Snow, 12345")
await page.agent.login(credential_type="skyvern", credential_id="cred_123")
await page.agent.download_files(prompt="Download latest invoice")
```

## Control Your Own Chrome

Enable remote debugging in Chrome at `chrome://inspect/#remote-debugging`, then:

```python
skyvern = Skyvern(
    browser_address="http://127.0.0.1:9222",
)
```

## Cloud vs Local

| Feature | Local | Cloud |
|---|---|---|
| Anti-bot detection | Basic | Advanced |
| Proxy network | None | Included |
| CAPTCHA solvers | None | Included |
| Parallel execution | Limited | Unlimited |
| Cost | Free (AGPL) | Paid |

## Troubleshooting

| Issue | Fix |
|---|---|
| `sqlite3.OperationalError` | `rm ~/.skyvern/data.db && pip install --upgrade skyvern` |
| `pip install` fails | Use `uv pip install skyvern` instead |
| Browser not launching | Check Docker or Chrome remote debugging config |
| LLM errors | Configure .env with valid API keys |

## References

- Repo: https://github.com/Skyvern-AI/skyvern
- Original skill: `skills/skyvern/SKILL.md` in the repo
- Docs: https://docs.skyvern.com
