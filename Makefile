LINT_EXCLUDE := .git .venv

.PHONY: install uninstall python-deps lint tree

# Symlink dirs and files into ~/.claude/
install:
	bash setup/install.sh

# Remove symlinks from ~/.claude/
uninstall:
	bash setup/uninstall.sh

# Install Python dependencies (pyyaml, python-dotenv, ruff)
python-deps:
	bash setup/install-python-deps.sh

# Display project structure tree (source code only, metafiles excluded)
tree:
	tree -I __pycache__

# Lint .sh files with shellcheck and .py files with ruff
lint:
	shellcheck $$(find . -name '*.sh' $(foreach d,$(LINT_EXCLUDE),-not -path './$(d)/*'))
	ruff check --fix $$(find . -name '*.py' $(foreach d,$(LINT_EXCLUDE),-not -path './$(d)/*'))
	ruff format $$(find . -name '*.py' $(foreach d,$(LINT_EXCLUDE),-not -path './$(d)/*'))
