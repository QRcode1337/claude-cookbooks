#!/bin/bash
# Cache Manager for Claude Code
# Manages cache directory lifecycle and cleanup

set -euo pipefail

CACHE_DIR="$(dirname "$0")/../cache"
CONFIG_FILE="$(dirname "$0")/../config.yaml"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get TTL from config (in seconds)
get_ttl() {
    local cache_type=$1
    case $cache_type in
        model-docs) echo 86400 ;;      # 24 hours
        pr-analysis) echo 604800 ;;    # 7 days
        link-validation) echo 3600 ;;  # 1 hour
        *) echo 86400 ;;               # default 24 hours
    esac
}

# Clean expired cache entries
clean_cache() {
    echo -e "${GREEN}Cleaning expired cache entries...${NC}"
    local cleaned=0

    for cache_type in model-docs pr-analysis link-validation; do
        local dir="$CACHE_DIR/$cache_type"
        if [ ! -d "$dir" ]; then
            continue
        fi

        local ttl=$(get_ttl "$cache_type")
        local count=0

        # Find and delete files older than TTL
        while IFS= read -r -d '' file; do
            rm -f "$file"
            ((count++))
            ((cleaned++))
        done < <(find "$dir" -type f -mtime "+$((ttl / 86400))" -print0 2>/dev/null)

        if [ $count -gt 0 ]; then
            echo -e "  ${YELLOW}$cache_type${NC}: Removed $count expired entries"
        fi
    done

    echo -e "${GREEN}✓ Cleaned $cleaned total entries${NC}"
}

# Clear all cache
clear_cache() {
    echo -e "${YELLOW}Clearing all cache entries...${NC}"
    local total=0

    for cache_type in model-docs pr-analysis link-validation; do
        local dir="$CACHE_DIR/$cache_type"
        if [ -d "$dir" ]; then
            local count=$(find "$dir" -type f 2>/dev/null | wc -l | tr -d ' ')
            rm -rf "$dir"/*
            mkdir -p "$dir"
            total=$((total + count))
            echo -e "  ${YELLOW}$cache_type${NC}: Cleared $count entries"
        fi
    done

    echo -e "${GREEN}✓ Cleared $total total entries${NC}"
}

# Show cache statistics
show_stats() {
    echo -e "${GREEN}Cache Statistics${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local total_size=0
    local total_files=0

    for cache_type in model-docs pr-analysis link-validation; do
        local dir="$CACHE_DIR/$cache_type"
        if [ ! -d "$dir" ]; then
            continue
        fi

        local count=$(find "$dir" -type f 2>/dev/null | wc -l | tr -d ' ')
        local size=$(du -sh "$dir" 2>/dev/null | cut -f1)
        local ttl=$(get_ttl "$cache_type")
        local ttl_human=$((ttl / 3600))

        total_files=$((total_files + count))

        echo -e "\n${YELLOW}$cache_type${NC}"
        echo "  Files: $count"
        echo "  Size: $size"
        echo "  TTL: ${ttl_human}h"

        # Show age of oldest file
        if [ $count -gt 0 ]; then
            local oldest=$(find "$dir" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | head -1 | cut -d' ' -f2-)
            if [ -n "$oldest" ]; then
                local age=$(( ($(date +%s) - $(stat -f %m "$oldest" 2>/dev/null || stat -c %Y "$oldest")) / 3600 ))
                echo "  Oldest: ${age}h ago"
            fi
        fi
    done

    echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}Total Files:${NC} $total_files"

    # Calculate total cache directory size
    if [ -d "$CACHE_DIR" ]; then
        local total_cache_size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
        echo -e "${GREEN}Total Size:${NC} $total_cache_size"
    fi
}

# Invalidate cache for specific commit
invalidate_commit() {
    local commit_sha=$1
    echo -e "${YELLOW}Invalidating cache for commit: $commit_sha${NC}"

    local dir="$CACHE_DIR/pr-analysis"
    if [ ! -d "$dir" ]; then
        echo -e "${RED}No PR analysis cache found${NC}"
        return
    fi

    local count=0
    find "$dir" -type f -name "*${commit_sha}*" -print0 2>/dev/null | while IFS= read -r -d '' file; do
        rm -f "$file"
        ((count++))
    done

    echo -e "${GREEN}✓ Invalidated $count cache entries${NC}"
}

# Main command dispatcher
main() {
    case "${1:-}" in
        clean)
            clean_cache
            ;;
        clear)
            clear_cache
            ;;
        stats)
            show_stats
            ;;
        invalidate)
            if [ -z "${2:-}" ]; then
                echo -e "${RED}Error: commit SHA required${NC}"
                echo "Usage: $0 invalidate <commit-sha>"
                exit 1
            fi
            invalidate_commit "$2"
            ;;
        *)
            echo "Claude Code Cache Manager"
            echo ""
            echo "Usage: $0 <command>"
            echo ""
            echo "Commands:"
            echo "  clean              Clean expired cache entries"
            echo "  clear              Clear all cache"
            echo "  stats              Show cache statistics"
            echo "  invalidate <sha>   Invalidate cache for commit"
            echo ""
            exit 1
            ;;
    esac
}

main "$@"
