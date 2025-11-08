---
allowed-tools: @common-tools.pr-review-parallel
description: Comprehensive review of Jupyter notebooks and Python scripts
execution: parallel
cache-enabled: true
cache-type: pr-analysis
analysis-level: thorough
---

Review the changes to Jupyter notebooks and Python scripts in this PR.

## Execution Strategy

**Performance Optimizations:**
- **Parallel execution** of `gh pr view` + `gh pr diff`
- **Incremental analysis** (diff-only mode for large notebooks)
- **Progressive disclosure** levels: fast → standard → thorough
- **Cache key**: `{commit-sha}-{file-path}`
- **Target time**: <600ms (thorough), <300ms (standard), <100ms (fast)

```bash
# Parallel PR data fetch
gh pr view $PR_NUMBER &
gh pr diff $PR_NUMBER &
wait
```

## Analysis Levels

Use `--level [1|2|3]` to control depth vs. speed:

### Level 1: Fast Security Scan (~100ms)
- Hardcoded API keys and secrets only
- Critical security patterns

### Level 2: Standard Review (~300ms) [DEFAULT]
- Security scan
- Code quality basics
- Notebook structure

### Level 3: Thorough Analysis (~600ms)
- All Level 2 checks
- Best practices validation
- Educational quality assessment
- Detailed recommendations

## Code Quality

### Python Conventions
- ✅ **PEP 8 compliance** (line length, naming, spacing)
- ✅ **Type hints** for functions (Python 3.5+)
- ✅ **Docstrings** for complex functions
- ✅ **Error handling** with try/except blocks
- ✅ **Clear variable names** (descriptive, not `x`, `temp`, `data`)
- ✅ **No magic numbers** (use named constants)

### Documentation Quality
- ✅ **Clear imports** with comments explaining purpose
- ✅ **Function documentation** with parameters and return types
- ✅ **Inline comments** for complex logic
- ✅ **Cell outputs preserved** for educational value

## Notebook Structure

### Educational Excellence
1. **Introduction Cell**
   - What the notebook demonstrates
   - Why it's useful/relevant
   - Prerequisites and assumptions

2. **Configuration Section**
   - How to set up API keys (`ANTHROPIC_API_KEY`)
   - Required dependencies with versions
   - Installation instructions

3. **Flow and Clarity**
   - Logical progression: simple → complex
   - Connecting explanations between cells
   - Clear markdown separating sections
   - Code cells focused on single concepts

4. **Outputs and Examples**
   - Preserved outputs showing expected results
   - Error handling demonstrations
   - Edge case examples

## Security Scanning

**Enhanced Pattern Detection** (from `.claude/config.yaml`):

### Primary Secret Patterns

```python
# Anthropic API Keys
PATTERN: sk-ant-[a-zA-Z0-9-_]{95}
BAD:  api_key = "sk-ant-api03-xxx"
GOOD: api_key = os.getenv("ANTHROPIC_API_KEY")

# GitHub Tokens
PATTERN: ghp_[a-zA-Z0-9]{36}
PATTERN: github_pat_[a-zA-Z0-9_]{82}

# AWS Credentials
PATTERN: AKIA[0-9A-Z]{16}

# OpenAI Keys
PATTERN: sk-[a-zA-Z0-9]{48}

# Private Keys
PATTERN: -----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----
```

### Excluded Patterns (False Positives)

**Educational examples** are acceptable if clearly marked:
```python
# Example of what NOT to do:
# api_key = "sk-ant-api03-..." # ❌ Never hardcode
api_key = os.getenv("ANTHROPIC_API_KEY")  # ✅ Always use env vars
```

**Exclude these patterns:**
- `# Example: sk-ant-`
- `# NOT: sk-ant-`
- `# Don't use: sk-ant-`
- `"placeholder"`
- `"your-api-key-here"`

### Security Checklist

- ❌ **No hardcoded API keys** (any service)
- ❌ **No tokens or passwords** in plain text
- ❌ **No private keys** committed
- ✅ **Use environment variables** (`os.getenv`, `os.environ`)
- ✅ **Safe input handling** (validation, sanitization)
- ✅ **Secure defaults** (HTTPS, latest SDKs)

## Best Practices

### Dependency Management
```python
# ✅ Good: Explicit imports with versions
import anthropic  # anthropic>=0.21.0
from anthropic import Anthropic, HUMAN_PROMPT, AI_PROMPT

# ⚠️ Avoid: Wildcard imports
from anthropic import *  # Makes dependencies unclear
```

### Error Handling
```python
# ✅ Good: Specific exception handling
try:
    response = client.messages.create(...)
except anthropic.APIError as e:
    print(f"API Error: {e}")
    # Handle gracefully
except Exception as e:
    print(f"Unexpected error: {e}")
    raise

# ❌ Bad: Silent failures
try:
    response = client.messages.create(...)
except:
    pass  # Never silently fail
```

### API Key Management
```python
# ✅ Best: Environment variable with validation
import os
api_key = os.getenv("ANTHROPIC_API_KEY")
if not api_key:
    raise ValueError("ANTHROPIC_API_KEY environment variable not set")

# ✅ Good: Environment variable with default
api_key = os.environ.get("ANTHROPIC_API_KEY", "")

# ❌ Bad: Hardcoded key
api_key = "sk-ant-api03-..."  # Never do this
```

## Report Format

See template: `.claude/templates/pr-comment.md`

Provide structured summary:

### ✅ What Looks Good
- Well-implemented features
- Good practices observed
- Clear documentation

### ⚠️ Suggestions for Improvement
- Code quality enhancements
- Structure improvements
- Best practices recommendations

### ❌ Critical Issues (Must Fix)
- Security vulnerabilities
- Broken functionality
- Missing essential documentation

---

## Post Review

```bash
gh pr comment $PR_NUMBER --body "$(cat <<'EOF'
## Jupyter Notebook & Python Review

[Your review content]

### Analysis Summary
- **Level**: Thorough (Level 3)
- **Files analyzed**: N notebooks, M scripts
- **Security scan**: N secrets checked, 0 found
- **Code quality**: X/10 score
- **Execution time**: ~Xms
- **Cache status**: Hit | Miss

### Security Patterns Checked
- Anthropic API keys: ✓
- GitHub tokens: ✓
- AWS credentials: ✓
- OpenAI keys: ✓
- Private keys: ✓

EOF
)"
```

## Examples

### Security - Good vs Bad

**❌ BAD: Hardcoded API Key**
```python
client = anthropic.Anthropic(
    api_key="sk-ant-api03-xxxxxxxxxxxxx"  # NEVER!
)
```

**✅ GOOD: Environment Variable**
```python
import os
client = anthropic.Anthropic(
    api_key=os.getenv("ANTHROPIC_API_KEY")
)
```

### Structure - Good vs Bad

**❌ BAD: No Introduction**
```python
import anthropic
client = anthropic.Anthropic()
# Code with no explanation...
```

**✅ GOOD: Clear Introduction**
```markdown
# Claude Streaming Example

This notebook demonstrates streaming responses from Claude using the Messages API.

## What You'll Learn
- How to use streaming for real-time responses
- Handling streaming events
- Error recovery in streaming contexts

## Setup
Set your API key: `export ANTHROPIC_API_KEY=your_key_here`
```

```python
import os
import anthropic

# Initialize client with error handling
api_key = os.getenv("ANTHROPIC_API_KEY")
if not api_key:
    raise ValueError("Set ANTHROPIC_API_KEY environment variable")

client = anthropic.Anthropic(api_key=api_key)
```
