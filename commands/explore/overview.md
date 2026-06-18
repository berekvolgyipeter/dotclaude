---
name: overview
description: Explore and summarize a project's structure, purpose, key files, dependencies, and configuration
disable-model-invocation: true
model: haiku
context: fork
allowed-tools: Read, Grep, Glob, Bash(make *), Bash(ls *)
---

# Project Overview

Efficiently explore this project and produce a concise summary. Minimize file reads — use directory listings and symbol overviews before reading full files.

## Steps

@~/.claude/shared/analyze-project.md

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
