LINT_EXCLUDE := .git .venv
MAX_LINE_LENGTH := 120

.PHONY: install mcp uninstall lint test tree

# Symlink repo entries and files into ~/.claude/
install:
	bash setup/install.sh

# Register the context7 MCP server at user scope
mcp:
	bash setup/install-mcp.sh

# Remove symlinks from ~/.claude/
uninstall:
	bash setup/uninstall.sh

# Display project structure tree (source code only, metafiles excluded)
tree:
	tree -I __pycache__

# Lint .sh files with shellcheck and .py files with ruff, then fail on code lines longer than MAX_LINE_LENGTH
lint:
	shellcheck $$(find . -name '*.sh' $(foreach d,$(LINT_EXCLUDE),-not -path './$(d)/*'))
	uv run ruff check --fix $$(find . -name '*.py' $(foreach d,$(LINT_EXCLUDE),-not -path './$(d)/*'))
	uv run ruff format $$(find . -name '*.py' $(foreach d,$(LINT_EXCLUDE),-not -path './$(d)/*'))
	@git grep -nIE --untracked '.{$(MAX_LINE_LENGTH)}.' -- '*.sh' '*.py'; rc=$$?; \
		[ $$rc -eq 1 ] || { [ $$rc -eq 0 ] && echo "Lines above exceed $(MAX_LINE_LENGTH) characters"; exit 1; }

# Run the behavior tests, stopping at the first failing script
test:
	@for t in tests/*.sh; do echo "== $$t"; bash "$$t" || exit 1; done
