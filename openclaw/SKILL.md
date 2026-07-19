---
name: openclaw
description: Set up and configure AI gateway integration for persistent memory and context injection. Use when the user wants to configure AI providers, set up context injection, or manage gateway settings.
---

# OpenClaw Gateway Integration

Generic guide for setting up AI gateway integration for persistent memory and context injection.

## When to Use

- Setting up AI provider configuration
- Configuring context injection for AI agents
- Managing gateway settings and credentials
- Setting up real-time data feeds

## Quick Setup

### 1. Check Dependencies

```bash
# Check for required tools
which node || echo "Node.js not found"
which npm || echo "npm not found"
which git || echo "git not found"
```

### 2. Install Dependencies

```bash
# Install Node.js if not present
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install npm packages
npm install
```

### 3. Configure AI Provider

Create a configuration file `~/.config/ai-gateway/config.json`:

```json
{
  "provider": "openai|anthropic|google|azure",
  "api_key": "your_api_key",
  "model": "gpt-4|claude-3|gemini-pro",
  "max_tokens": 4096,
  "temperature": 0.7
}
```

### 4. Environment Variables

Create a `.env` file:

```bash
# AI Provider
AI_PROVIDER="openai"
AI_API_KEY="your_api_key"
AI_MODEL="gpt-4"

# Gateway Settings
GATEWAY_PORT=3000
GATEWAY_HOST="localhost"

# Memory Settings
MEMORY_ENABLED=true
MEMORY_PATH="./memory"
```

## Configuration Options

### Provider Configuration

```json
{
  "providers": {
    "openai": {
      "api_key": "sk-...",
      "organization": "org-..."
    },
    "anthropic": {
      "api_key": "sk-ant-..."
    },
    "google": {
      "api_key": "AIza..."
    }
  }
}
```

### Context Injection

```json
{
  "context": {
    "enabled": true,
    "max_tokens": 8000,
    "injection_point": "system_prompt",
    "memory_layers": ["file_context", "project_context", "user_preferences"]
  }
}
```

### Memory Configuration

```json
{
  "memory": {
    "enabled": true,
    "storage": "sqlite|json|redis",
    "path": "./memory.db",
    "max_size": "100MB",
    "retention_days": 30
  }
}
```

## Implementation Patterns

### File-based Context

```javascript
// Load context from files
const fs = require('fs');
const path = require('path');

function loadContext(contextDir) {
  const context = [];
  const files = fs.readdirSync(contextDir);
  
  for (const file of files) {
    if (file.endsWith('.md') || file.endsWith('.txt')) {
      const content = fs.readFileSync(path.join(contextDir, file), 'utf8');
      context.push({ file, content });
    }
  }
  
  return context;
}
```

### Memory Storage

```javascript
// Simple JSON-based memory
const memory = {
  observations: [],
  addObservation(obs) {
    this.observations.push({
      id: Date.now(),
      timestamp: new Date().toISOString(),
      ...obs
    });
  },
  search(query) {
    return this.observations.filter(obs => 
      obs.content.includes(query) || obs.tags?.includes(query)
    );
  }
};
```

## Monitoring

```bash
# Check gateway status
curl http://localhost:3000/health

# Check memory usage
ls -la ./memory/

# Check logs
tail -f logs/gateway.log
```

## Troubleshooting

### Common Issues

1. **API key invalid** - Verify key in provider dashboard
2. **Rate limiting** - Implement exponential backoff
3. **Memory full** - Check retention policies
4. **Context too large** - Reduce max_tokens or trim context

### Debug Mode

```bash
# Enable verbose logging
export DEBUG=true
export LOG_LEVEL=debug

# Run with debug output
node gateway.js --verbose
```

## Security Best Practices

1. **Never commit API keys** - Use environment variables
2. **Use secrets managers** - AWS Secrets Manager, HashiCorp Vault
3. **Rotate keys regularly** - Implement key rotation policy
4. **Monitor usage** - Track API calls and costs
5. **Implement rate limiting** - Prevent abuse

## See Also

- `learn-codebase` - Understand project structure
- `make-plan` - Plan implementation
- `smart-explore` - Explore codebase efficiently
