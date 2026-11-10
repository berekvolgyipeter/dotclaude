LINT_EXCLUDE := .git .venv

.PHONY: install mcp uninstall lint test tree

# Symlink repo entries and files into ~/.claude/
install:
	bash setup/install.sh

# Register the claude-context and context7 MCP servers at user scope (interactive)
mcp:
	bash setup/install-mcp.sh

# Remove symlinks from ~/.claude/
uninstall:
	bash setup/uninstall.sh

# Display project structure tree (source code only, metafiles excluded)
tree:
	tree -I __pycache__

# Lint .sh files with shellcheck and .py files with ruff
lint:
	shellcheck $$(find . -name '*.sh' $(foreach d,$(LINT_EXCLUDE),-not -path './$(d)/*'))
	uv run ruff check --fix $$(find . -name '*.py' $(foreach d,$(LINT_EXCLUDE),-not -path './$(d)/*'))
	uv run ruff format $$(find . -name '*.py' $(foreach d,$(LINT_EXCLUDE),-not -path './$(d)/*'))

# Run the hook behavior tests
test:
	bash tests/lint-and-test.sh
