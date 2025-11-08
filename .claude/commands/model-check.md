---
allowed-tools: @common-tools.pr-review-parallel
description: Validate Claude model usage against current public models
execution: parallel
cache-enabled: true
cache-type: model-docs
analysis-level: fast
mcp-servers: ["context7"]
---

Review the changed files for Claude model usage and validate against current public models.

## Execution Strategy

**Performance Optimizations:**
- **Parallel execution** of `gh pr view` + `gh pr diff`
- **MCP Context7** for real-time model documentation (preferred)
- **Local cache** with 24-hour TTL (fallback)
- **Target time**: <200ms (cache hit), <500ms (cache miss)

## Model Documentation Retrieval

### Strategy 1: Context7 MCP Server (Primary)

**Fast & Always Current:**
```
Use Context7 to fetch latest Claude model information:
--c7 /anthropic/claude/models

Benefits:
- Real-time accuracy
- No cache staleness
- Version-aware lookups
```

### Strategy 2: Cached Documentation (Fallback)

If Context7 unavailable, check local cache:
```
Cache location: .claude/cache/model-docs/
Cache key: models-overview-$(date +%Y%m%d)
TTL: 24 hours
```

Fetch from: `https://docs.anthropic.com/en/docs/about-claude/models`

**Cache invalidation:**
- Daily refresh
- Manual: `.claude/utils/cache-manager.sh invalidate`

## Validation Checks

### 1. **Current Public Models**

Verify all model references are from the current public models list:

**Latest Models (as of context cutoff):**
- `claude-opus-4-20250514` (Opus 4)
- `claude-sonnet-4-20250514` (Sonnet 4)
- `claude-sonnet-3-5-20241022` (Sonnet 3.5)
- `claude-sonnet-3-5-20240620` (Sonnet 3.5 original)
- `claude-3-5-haiku-20241022` (Haiku 3.5)

**Recommended Aliases:**
- `claude-opus-latest`
- `claude-sonnet-latest`
- `claude-haiku-latest`

### 2. **Deprecated Models**

Flag usage of deprecated models:

**Deprecated:**
- ❌ `claude-3-opus-20240229` (use Opus 4 or `claude-opus-latest`)
- ❌ `claude-3-sonnet-20240229` (use Sonnet 3.5/4)
- ❌ `claude-3-haiku-20240307` (use Haiku 3.5)
- ❌ Any Claude 2.x models

### 3. **Internal/Non-Public Models**

Flag any internal or non-public model names:
- Models with internal version suffixes
- Pre-release or beta model names
- Custom fine-tuned model identifiers

### 4. **Best Practices**

**Recommendations:**
- ✅ Use `-latest` aliases for maintainability
- ✅ Include version comments when using specific dates
- ✅ Document model selection rationale
- ✅ Test with current recommended models

## Security Patterns

Check for hardcoded API keys (use patterns from `.claude/config.yaml`):

```python
# Pattern: sk-ant-[a-zA-Z0-9-_]{95}
BAD:  model="claude-sonnet-latest", api_key="sk-ant-api03-xxx"
GOOD: model="claude-sonnet-latest", api_key=os.getenv("ANTHROPIC_API_KEY")
```

## Report Format

See template: `.claude/templates/pr-comment.md`

Provide clear, actionable feedback:

### ✅ Valid Model Usage
- Model name
- Version/date
- Alias recommendation (if applicable)

### ⚠️ Deprecated Models
- Current usage
- Recommended replacement
- Migration guide link

### ❌ Invalid Models
- Non-public model name
- Error type (internal/typo/unknown)
- Correct model name

---

## Post Review

```bash
gh pr comment $PR_NUMBER --body "$(cat <<'EOF'
## Claude Model Usage Review

[Your findings here]

### Metadata
- Models checked: N
- Data source: Context7 | Cache (Xh old) | Fresh fetch
- Execution time: ~Xms
- Cache status: Hit | Miss
EOF
)"
```

## Examples

**Good:**
```python
# Using latest alias for automatic updates
client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-sonnet-latest",  # ✅ Recommended
    max_tokens=1024,
    messages=[...]
)
```

**Needs Update:**
```python
# Using deprecated model
client = anthropic.Anthropic()
response = client.messages.create(
    model="claude-3-opus-20240229",  # ❌ Deprecated
    # Should use: "claude-opus-latest" or "claude-opus-4-20250514"
    max_tokens=1024,
    messages=[...]
)
```
