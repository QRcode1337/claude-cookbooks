# Cache Directory

This directory stores temporary cache files for Claude Code slash commands to improve performance.

## Structure

```
cache/
├── model-docs/       # Cached Claude model documentation (TTL: 24h)
├── pr-analysis/      # Cached PR analysis results (TTL: 7d)
└── link-validation/  # Cached link validation results (TTL: 1h)
```

## Cache Keys

- **model-docs**: Keyed by documentation URL hash
- **pr-analysis**: Keyed by commit SHA + file path
- **link-validation**: Keyed by URL hash

## Management

Use the cache management utility:

```bash
# Clean expired cache entries
.claude/utils/cache-manager.sh clean

# Clear all cache
.claude/utils/cache-manager.sh clear

# Show cache statistics
.claude/utils/cache-manager.sh stats
```

## Configuration

Cache settings are configured in `.claude/config.yaml`:
- TTL durations
- Invalidation rules
- Max cache size

## Notes

- Cache files are automatically ignored by git
- Cache is invalidated on force-push or file changes
- Maximum cache age: 30 days
