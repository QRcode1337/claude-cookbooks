---
allowed-tools: @common-tools.pr-review-parallel
description: Review links in changed files for quality and security issues
execution: parallel
cache-enabled: true
cache-type: link-validation
analysis-level: standard
---

Review the links in the changed files and check for potential issues.

## Execution Strategy

**Parallel Execution Enabled**: Run `gh pr view` and `gh pr diff` concurrently for optimal performance (~300ms vs ~600ms sequential).

```bash
# Fetch PR info and diff in parallel
gh pr view $PR_NUMBER &
gh pr diff $PR_NUMBER &
wait
```

## Link Quality Checks

### 1. **Broken Links**
Identify any links that might be broken or malformed:
- 404 errors or unreachable URLs
- Malformed URL syntax
- Missing protocol (http/https)

### 2. **Outdated Links**
Check for links to deprecated resources:
- Old documentation versions
- Archived or moved content
- Sunset APIs or services

### 3. **Security**
Ensure no links to suspicious or potentially harmful sites:
- Mixed content (HTTP in HTTPS pages)
- Known malicious domains
- Unverified external resources

### 4. **Best Practices**
- ✅ Links should use HTTPS where possible
- ✅ Internal links should use relative paths
- ✅ External links should be to stable, reputable sources
- ✅ Documentation links should include version numbers when relevant

## Specific Checks for Anthropic Content

- **Claude Documentation**: Point to latest versions at docs.anthropic.com
- **API Documentation**: Use current API reference URLs
- **Model Documentation**: Reference current models (no deprecated versions)
- **GitHub Links**: Use correct repository paths (anthropics/anthropic-sdk-*)

## Cache Strategy

Link validation results are cached for 1 hour to improve performance:
- **Cache Key**: URL hash
- **TTL**: 1 hour
- **Invalidation**: Force-refresh if link content changes

## Report Format

See template: `.claude/templates/pr-comment.md`

Provide a clear summary with:
- ✅ **Valid and well-formed links** (count + examples)
- ⚠️ **Links that might need attention** (e.g., HTTP instead of HTTPS)
- ❌ **Broken or problematic links** that must be fixed

If all links look good, provide a brief confirmation with count.

---

## Post Review

**Execute in parallel with comment posting:**
```bash
# Generate review and post in one operation
gh pr comment $PR_NUMBER --body "$(cat <<'EOF'
[Your review content here]
EOF
)"
```

**Metadata to include:**
- Total links checked: N
- Cache hits: N
- Execution time: ~Xms
- Analysis level: Standard
