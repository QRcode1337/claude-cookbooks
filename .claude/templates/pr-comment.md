# PR Review Template

## Report Format

Provide a clear summary with:
- ✅ **What looks good** - Positive findings and well-implemented features
- ⚠️ **Needs attention** - Suggestions for improvement (non-blocking)
- ❌ **Must fix** - Critical issues that must be addressed before merge

---

## Usage Instructions

**Post review as PR comment:**
```bash
gh pr comment $PR_NUMBER --body "$(cat review.md)"
```

**Or for inline review:**
```bash
gh pr comment $PR_NUMBER --body "Your review content here"
```

---

## Review Metadata

- **Reviewer**: Claude Code
- **Analysis Level**: [Fast/Standard/Thorough]
- **Execution Time**: [X]ms
- **Files Analyzed**: [N]
- **Cache Status**: [Hit/Miss]
