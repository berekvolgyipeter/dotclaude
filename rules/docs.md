---
paths:
  - "**/*.md"
---

# Documentation Guidelines

Best practices for writing and maintaining project documentation.

## Core Principles

Documentation should be **timeless and high-level**, focusing on architecture and patterns rather than implementation details.

1. **No Code Examples in Architecture Docs** - Architecture docs describe a project's structure, component relationships, and data flow. Code changes frequently, making embedded examples outdated.
   - ✅ GOOD: "Scrapers use `prepare_download_directory()` for overwrite handling"
   - ❌ BAD: Including the full function implementation in `CLAUDE.md`
   - **Exception**: Best-practice and guideline docs (e.g., rule files, style guides) — generalized code examples ARE allowed and encouraged to illustrate patterns and conventions

2. **Avoid Volatile Details** - Magic numbers and specifics that frequently change
   - ✅ GOOD: "OpenAI Vision API"
   - ❌ BAD: "OpenAI GPT-5-mini Vision API" or "10 scrapers" or "version 3.2.1"
   - **Examples of volatile details**: Model names, file counts, version numbers, specific URLs
   - **Rationale**: These change frequently, breaking documentation accuracy

**Remember**: Outdated documentation is worse than no documentation. Keep docs high-level, architectural, and resistant to code changes.
