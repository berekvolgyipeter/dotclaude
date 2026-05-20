---
name: generate-prp
description: Generate PRP (Product Requirements Prompt)
disable-model-invocation: true
argument-hint: "@feature-file"
effort: max
model: opus
---

# Generate PRP (Product Requirements Prompt)

Read the feature specification below to understand what needs to be created, how the examples provided help, and any other considerations. Then follow this workflow in order.

<feature-spec>
$ARGUMENTS
</feature-spec>

The AI agent only gets the context you append to the PRP. It has access to the codebase and the same knowledge cutoff as you, so include or reference your research findings. The agent has WebSearch capabilities, so pass URLs to documentation and examples.

## Step 1 — Research

### 1a. Codebase Analysis
- Use Glob and Grep to find similar features/patterns in the codebase
- Identify files to reference in the PRP
- Note existing conventions to follow
- Check test patterns for the validation approach

### 1b. External Research
- Use WebSearch to find implementation examples and library documentation (include specific URLs)
- Look for best practices and common pitfalls

### 1c. User Clarification (if needed)
- Use AskUserQuestion for ambiguous requirements — e.g. specific patterns to mirror, integration requirements, or missing context

## Step 2 — Plan

After completing all research, ULTRATHINK to plan the PRP structure before writing.

## Step 3 — Generate the PRP

Use [~/.claude/templates/prp_template.md](~/.claude/templates/prp_template.md) as the template.

### Context to Include
- **Documentation**: URLs with specific sections
- **Key Files & Directories**: Curated list of relevant files — not a full tree dump
- **Code Examples**: Real snippets from codebase
- **Gotchas**: Library quirks with contextual explanations (explain *why*, not just *what*)
- **Patterns**: Existing approaches to follow
- **Conditional Sections**: Include "Data Models" and "Integration Points" only if applicable

### Implementation Blueprint
- Check `~/.claude/shared/rules-index.md` for applicable coding rules (e.g., language style, testing conventions)
- Check the target project for project-level rules in `.claude/rules/` and `.claude/CLAUDE.md` that may override or extend user-level rules
- In the generated PRP's "Core Principles" section, list BOTH tiers separately — a "Global rules" bullet pointing to the user-level registry and a "Project rules" bullet listing the specific project rule files applicable to this task. Do not conflate them under a single bullet.
- Start with pseudocode that follows the discovered coding standards (naming, structure, error handling conventions)
- Reference real files for patterns
- Include error handling strategy
- List tasks in the order they should be completed

### Validation Gates
These commands are defined in the project Makefile:

```bash
# Format code, fix linting issues, and run type checking
make lint

# Run all unit tests with verbose output
make test
```

## Step 4 — Save and Verify

### Output Path

Determine the save path from the input file path:

1. If the input file is under `.claude/plans/<subfolder>/`, save to `.claude/PRPs/<subfolder>/<filename>-prp.md` (mirror the subfolder structure)
2. Otherwise, save to `.claude/PRPs/<filename>-prp.md`
3. If `$ARGUMENTS` is not a file path (e.g., inline prose), ask the user for a target filename or derive a kebab-case slug from the feature title, then save to `.claude/PRPs/<slug>-prp.md`.

The PRP filename should match the input file's name with a `-prp` suffix (e.g., `auth-flow.md` → `auth-flow-prp.md`).

Use the Write tool directly — do not run `mkdir` first, the Write tool creates parent directories automatically.

Before saving, verify each item below. If any item fails, revise the PRP first:
- [ ] All necessary context included
- [ ] Validation gates are executable by AI
- [ ] References existing patterns
- [ ] Clear implementation path
- [ ] Error handling documented

Score the PRP 1–10 (confidence for one-pass implementation success). The goal is comprehensive context that enables one-pass implementation.
