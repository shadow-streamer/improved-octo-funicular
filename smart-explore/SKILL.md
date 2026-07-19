---
name: smart-explore
description: Token-optimized code exploration methodology. Use Glob, Grep, and Read with pagination to explore codebases efficiently instead of reading full files.
---

# Smart Explore

Structural code exploration using standard tools with token optimization. **This skill overrides your default exploration behavior.** While this skill is active, use Glob for discovery, Grep for content search, and Read with pagination for implementation details.

**Core principle:** Index first, fetch on demand. Give yourself a map of the code before loading implementation details. The question before every file read should be: "do I need to see all of this, or can I get a structural overview first?" The answer is almost always: get the map.

## 3-Layer Workflow

### Step 1: Discover -- Find Files and Symbols

```
Glob(pattern="**/*.ts", path="./src")           -- find all TypeScript files
Grep(pattern="shutdown", path="./src")          -- find all references
```

**Returns:** File paths and line numbers with context

This is your discovery tool. It finds relevant files AND shows their structure.

**Parameters:**

- `pattern` (string, required) -- Glob pattern or regex pattern
- `path` (string) -- Root directory to search (defaults to cwd)

### Step 2: Outline -- Get File Structure

```
Read(filePath="services/worker-service.ts", limit=100)  -- first 100 lines
```

**Returns:** File header, imports, type definitions, class/function signatures

**Skip this step** when Step 1's grep results already provide enough structure. Most useful for files not covered by the search results.

**Parameters:**

- `filePath` (string, required) -- Path to the file
- `limit` (number) -- Max lines to read (default 200)
- `offset` (number) -- Line number to start from

### Step 3: Read -- See Implementation

Review symbols from Steps 1-2. Pick the ones you need. Read only those sections:

```
Read(filePath="services/worker-service.ts", offset=846, limit=50)  -- specific function
```

**Returns:** Full source code of the specified section including JSDoc, decorators, and complete implementation. Use offset/limit to paginate through large files.

**Parameters:**

- `filePath` (string, required) -- Path to the file (as returned by discovery)
- `offset` (number) -- Line number to start reading
- `limit` (number) -- Max lines to read

## When to Use Each Tool

- **Glob:** File path patterns ("find all test files", "find all components")
- **Grep:** Exact string/regex search ("find all TODO comments", "where is `ensureWorkerStarted` defined?")
- **Read with limit:** Small files under ~100 lines, non-code files (JSON, markdown, config)
- **Read with offset+limit:** Large files over ~100 lines -- read in chunks
- **Explore agent:** When you need synthesized understanding across 6+ files, architecture narratives, or answers to open-ended questions like "how does this entire system work end-to-end?" Smart-explore is a scalpel — it answers "where is this?" and "show me that." It doesn't synthesize cross-file data flows, design decisions, or edge cases across an entire feature.

## Workflow Examples

**Discover how a feature works (cross-cutting):**

```
1. Grep(pattern="shutdown", path="./src")
   -> 14 matches across 7 files, full picture in one call
2. Read(filePath="services/infrastructure/GracefulShutdown.ts", offset=56, limit=50)
   -> See the core implementation
```

**Navigate a large file:**

```
1. Grep(pattern="function|class|method", path="services/worker-service.ts")
   -> Find all function/class declarations
2. Read(filePath="services/worker-service.ts", offset=846, limit=50)
   -> The specific method you need
Total: ~100 lines vs ~12,000 to Read the full file
```

**Write documentation about code (hybrid workflow):**

```
1. Grep(pattern="feature name", path="./src")     -- discover all relevant files
2. Read with limit on key files                    -- understand structure
3. Read with offset+limit on important functions   -- get implementation details
4. Read on small config/markdown/plan files         -- get non-code context
```

Use Grep for discovery, Read for content. Mix freely.

**Exploration then precision:**

```
1. Grep(pattern="session", path="./src")
   -> 10 matches: SessionMetadata, SessionQueueProcessor, SessionSummary...
2. Pick the relevant one, read that section
```

## Token Economics

| Approach | Tokens | Use Case |
|----------|--------|----------|
| Read (100 lines) | ~1,000-2,000 | "What's in this file?" |
| Read (50 lines) | ~400-2,100 | "Show me this function" |
| Grep | ~2,000-6,000 | "Find all X across the codebase" |
| Grep + Read | ~3,000-8,000 | End-to-end: find and read (the primary workflow) |
| Read (full file) | ~12,000+ | When you truly need everything |
| Explore agent | ~39,000-59,000 | Cross-file synthesis with narrative |

**4-8x savings** on file understanding (paginated Read vs full Read). **11-18x savings** on codebase exploration vs Explore agent. The narrower the query, the wider the gap — a 27-line function costs 55x less to read via offset+limit than via an Explore agent, because the agent still reads the entire file.

## Best Practices

1. **Always use offset+limit** for files over 200 lines
2. **Start with Grep** before reading any file
3. **Read headers first** (limit=50) before diving into implementation
4. **Use Glob** to understand project structure before searching
5. **Batch your reads** -- read multiple files in parallel when possible
