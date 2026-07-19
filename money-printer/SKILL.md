# MoneyPrinter V2

Automate the process of making money online. Can be integrated with opencode by having the agent set it up, configure the JSON, and run the scripts. Features: Twitter bot, YouTube Shorts automator, affiliate marketing (Amazon + Twitter), local business finder & cold outreach.

⚠️ **Educational purposes only.** The author is not responsible for misuse.

Requires Python 3.12.

## Quick Start

```bash
git clone https://github.com/FujiwaraChoki/MoneyPrinterV2.git
cd MoneyPrinterV2
cp config.example.json config.json
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Edit `config.json` with your credentials, then:
```bash
python src/main.py
```

## Features

### Twitter Bot (with CRON Jobs / Scheduler)
- Automated posting
- Content scheduling
- Engagement automation

### YouTube Shorts Automator
- Video generation from content
- Scheduled uploads
- Template-based creation

### Affiliate Marketing
- Amazon product promotion
- Twitter integration
- Link tracking

### Local Business Finder & Cold Outreach
- Scrape local businesses
- Email outreach (requires Go installed)
- CRM integration

## Scripts

```bash
bash scripts/upload_video.sh     # Upload YouTube Short
bash scripts/twitter_post.sh     # Post to Twitter
```

Run from project root directory.

## Configuration

`config.json` contains all settings:
- API keys (Twitter, YouTube, etc.)
- Scheduling intervals
- Content templates
- Target parameters

## Troubleshooting

| Issue | Fix |
|---|---|
| Module not found | Ensure venv activated, `pip install -r requirements.txt` |
| Python 3.12 | Use `pyenv` or conda to install 3.12 |
| Email outreach fails | Install Go programming language |
| API rate limits | Adjust scheduling intervals |

## References

- Repo: https://github.com/FujiwaraChoki/MoneyPrinterV2
- Docs: https://github.com/FujiwaraChoki/MoneyPrinterV2/tree/main/docs
