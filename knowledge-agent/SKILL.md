---
name: knowledge-agent
description: Build and query knowledge bases from code and documentation. Use when users want to create focused "brains" from their codebase, ask questions about past work patterns, or compile expertise on specific topics.
---

# Knowledge Agent

Build and query knowledge bases from code and documentation.

## What Are Knowledge Agents?

Knowledge agents are filtered collections of code, documentation, and decisions compiled into a focused context. Build a corpus from your codebase, prime it (loads the knowledge into context), then ask it questions conversationally.

Think of them as custom "brains": "everything about hooks", "all decisions from the last month", "all bugfixes for the worker service".

## Workflow

### Step 1: Build a corpus

Use Grep and Glob to discover relevant files:

```
Grep(pattern="hook|lifecycle", path="./src")           -- find hook-related code
Glob(pattern="**/*hook*.ts", path="./src")             -- find hook files
Grep(pattern="hook", path="./docs")                    -- find hook documentation
```

Filter options:
- `pattern` — regex pattern to search for
- `path` — root directory to search
- `include` — file pattern filter (e.g., "*.ts", "*.md")

### Step 2: Prime the corpus

Read the discovered files with pagination:

```
Read(filePath="src/hooks/index.ts", limit=100)        -- read hook exports
Read(filePath="src/hooks/useAuth.ts", limit=100)       -- read auth hook
Read(filePath="docs/hooks.md", limit=100)              -- read hook docs
```

This creates a focused context loaded with all the corpus knowledge. Takes a moment for large corpora.

### Step 3: Query

Ask questions about the loaded knowledge:

```
"What are the 5 lifecycle hooks and when does each fire?"
"How is authentication implemented in the hooks?"
"What are the best practices for custom hooks?"
```

The knowledge agent answers from its corpus. Follow-up questions maintain context.

### Step 4: List corpora

```
Glob(pattern="**/*.md", path="./docs")
Grep(pattern="TODO|FIXME", path="./src")
```

Shows all relevant files with stats and context.

## Tips

- **Focused corpora work best** — "hooks architecture" beats "everything ever"
- **Prime once, query many times** — the context persists across queries
- **Reprime for fresh context** — if the conversation drifts, reprime to reset
- **Rebuild to update** — when new files are added, rebuild then reprime

## Maintenance

### Rebuild a corpus (refresh with new files)

```
Grep(pattern="hook|lifecycle", path="./src")
Glob(pattern="**/*hook*.ts", path="./src")
```

After rebuilding, re-prime to load the updated knowledge:

### Reprime (fresh session)

```
Read(filePath="src/hooks/index.ts", limit=100)
Read(filePath="src/hooks/useAuth.ts", limit=100)
```

Clears prior Q&A context and reloads the corpus into a new session.

## Advanced Techniques

### Create Topic-Specific Corpora

```
# Authentication corpus
Grep(pattern="auth|login|session|token", path="./src")

# Performance corpus
Grep(pattern="performance|optimize|cache|memo", path="./src")

# Testing corpus
Glob(pattern="**/*.test.ts", path="./src")
Grep(pattern="describe|it|test|expect", path="./src")
```

### Cross-Reference Multiple Sources

```
# Code + Documentation
Grep(pattern="hook", path="./src")
Grep(pattern="hook", path="./docs")

# Code + Tests
Grep(pattern="useAuth", path="./src")
Grep(pattern="useAuth", path="./src/__tests__")
```

### Export Knowledge Base

```
Bash(command="find ./src -name '*.ts' -exec grep -l 'hook' {} \; > hooks-corpus.txt")
```
