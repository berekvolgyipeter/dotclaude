---
name: primer
description: Explore and summarize a project's structure, purpose, key files, dependencies, and configuration
disable-model-invocation: true
model: haiku
context: fork
allowed-tools: Read, Grep, Glob, Bash(make *), Bash(ls *)
---

# Project Primer

Efficiently explore this project and produce a concise summary. Minimize file reads — use directory listings and symbol overviews before reading full files.

## Steps

1. Run `make tree` to get the project structure.
2. Read `.claude/CLAUDE.md` for project-specific instructions and conventions.
3. Read `README.md` for project purpose, setup, and architecture.
4. Identify entry points and key source files from the directory structure — read only the most important 3-5 files, not everything.
5. Check for dependency manifests (`package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, etc.) and note key dependencies.
6. Check for configuration files (CI/CD, linting, build config) and note any non-obvious setup.

## Output format

Summarize findings in this structure:

### Project Overview
One-paragraph description of what the project does and why.

### Structure
Brief description of the directory layout and architecture.

### Key Files
Table of the most important files with a one-line purpose for each.

### Dependencies
Notable external dependencies and what they're used for.

### Configuration
Important config files and any required environment setup.
