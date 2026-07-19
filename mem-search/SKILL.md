---
name: mem-search
description: Search and retrieve information efficiently using token-optimized workflows. Use when you need to find specific code, documentation, or past decisions without reading entire files.
---

# Memory Search

Search and retrieve information efficiently. Simple workflow: search -> filter -> fetch.

## When to Use

Use when you need to find specific information without reading everything:

- "Where is authentication implemented?"
- "How did we solve X last time?"
- "What changes were made to this file?"

## 3-Layer Workflow (ALWAYS Follow)

**NEVER fetch full details without filtering first. 10x token savings.**

### Step 1: Search - Get Index with Locations

Use Grep and Glob for discovery:

```
Grep(pattern="authentication", path="./src")     -- find all references
Glob(pattern="**/*.ts", path="./src")            -- find all TypeScript files
```

**Returns:** File paths and line numbers with context (~50-100 tokens/result)

```
src/auth/jwt.ts:15: export function verifyToken(token: string)
src/auth/session.ts:42: const session = await createSession(user)
src/middleware/auth.ts:8: if (!req.headers.authorization)
```

**Parameters:**

- `pattern` (string) - Search term or regex
- `path` (string) - Root directory to search
- `include` (string, optional) - File pattern filter

### Step 2: Filter - Get Context Around Interesting Results

Review the grep results. Pick relevant files. Read headers first:

```
Read(filePath="src/auth/jwt.ts", limit=50)      -- first 50 lines
Read(filePath="src/auth/session.ts", limit=50)   -- first 50 lines
```

**Returns:** File imports, type definitions, function signatures (~200-500 tokens each)

**Skip this step** when grep results already provide enough context.

**Parameters:**

- `filePath` (string, required) - Path to the file
- `limit` (number) - Max lines to read (default 50)

### Step 3: Fetch - Get Full Details ONLY for Filtered Files

Review headers from Step 2. Pick relevant files. Read only those sections:

```
Read(filePath="src/auth/jwt.ts", offset=15, limit=30)  -- specific function
```

**Returns:** Complete function implementation including JSDoc, decorators, and logic (~400-2100 tokens)

**Parameters:**

- `filePath` (string, required) - Path to the file
- `offset` (number) - Line number to start reading
- `limit` (number) - Max lines to read

## Examples

**Find recent bug fixes:**

```
Grep(pattern="TODO|FIXME|BUG", path="./src")
```

**Find what happened to a file:**

```
Bash(command="git log --oneline -10 -- src/auth/jwt.ts")
```

**Understand context around a discovery:**

```
Read(filePath="src/auth/jwt.ts", limit=100)
```

**Batch fetch details:**

```
Read(filePath="src/auth/jwt.ts", offset=15, limit=30)
Read(filePath="src/auth/session.ts", offset=42, limit=30)
```

## Why This Workflow?

- **Grep index:** ~50-100 tokens per result
- **Full file read:** ~500-1000 tokens each
- **Batch read:** Parallel requests vs sequential
- **10x token savings** by filtering before fetching

## Advanced Techniques

### Git History Search

```
Bash(command="git log --oneline --all --grep='authentication' -20")
Bash(command="git diff HEAD~5..HEAD -- src/auth/")
```

### Documentation Search

```
Grep(pattern="authentication", path="./docs")
Glob(pattern="**/*.md", path="./docs")
```

### Cross-Reference Search

```
Grep(pattern="import.*from.*auth", path="./src")
Grep(pattern="export.*function.*auth", path="./src")
```
