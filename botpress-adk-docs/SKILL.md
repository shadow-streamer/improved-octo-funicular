# Botpress ADK Docs

Guidelines and commands for creating, reviewing, updating, and maintaining documentation for your ADK bot. Helps document workflows, actions, and features with accurate, searchable guides.

Use when: creating documentation for bot features, reviewing existing docs, updating docs after code changes, verifying docs are in sync with implementation.

## Install the Skill

```bash
npx skills add botpress/skills --skill adk-docs
```

## Quick Commands

```bash
# Create documentation for a feature
adk doc:create my-feature

# Review existing docs for accuracy
adk doc:review

# Update docs after code changes
adk doc:update

# Check if docs are in sync with code
adk doc:sync

# Search project documentation
adk doc:search "authentication"
```

## Documentation Standards

### Document Types

1. **Reference** — API docs, config schemas, command lists
2. **Conceptual** — explanations of how things work
3. **Comprehensive** — end-to-end guides with examples

### Quality Checklist

- [ ] Code examples are verified against actual bot code
- [ ] All links resolve to existing pages
- [ ] Searchable with relevant keywords
- [ ] Follows template structure

## Creation Workflow

1. **Research** — understand the feature by reading source code
2. **Outline** — structure the document
3. **Write** — with verified code examples from the actual bot
4. **Review** — for accuracy, completeness, searchability

## Maintenance

```bash
adk doc:sync              # compare docs vs implementation
adk doc:update            # update after code changes
adk doc:search "keyword"  # find relevant docs
```

## Troubleshooting

| Issue | Fix |
|---|---|
| Doc not showing up after creation | Verify the file is in correct directory and named properly |
| Code examples outdated | Run `adk doc:sync` to compare docs with implementation |
| adk doc:* commands not found | Ensure `adk` CLI is installed in the development environment |
| Search not returning results | Broaden keywords or check the doc file format |

## References

- Repo: https://github.com/botpress/skills
- Original skill: `skills/adk-docs/SKILL.md` in the repo
