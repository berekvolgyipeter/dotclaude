---
name: overview
description: Explore and summarize a project's structure, purpose, key files, dependencies, and configuration
disable-model-invocation: true
model: haiku
context: fork
allowed-tools: Read, Bash(grep *), Bash(find *), Bash(make *), Bash(ls *)
---

# Project Overview

Efficiently explore this project and produce a concise summary. Minimize file reads — use directory listings and symbol overviews before reading full files.

## Steps

1. Run `make tree` to get the project structure.
2. Find and read the project's top-level docs — agent instructions (e.g. `CLAUDE.md`, `AGENTS.md`) and overview docs (e.g. `README`, `docs/`) — wherever this project keeps them, for its purpose, conventions, setup, and architecture.
3. Identify entry points and key source files from the directory structure — read only the most important 3-5 files, not everything.
4. Check for dependency manifests (`package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, etc.) and note key dependencies.
5. Check for configuration files (CI/CD, linting, build config) and note any non-obvious setup.

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
