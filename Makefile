LINT_EXCLUDE := .git .venv skills/authoring/skill-creator

.PHONY: install uninstall fetch-skill-creator python-deps lint tree

# Symlink dirs and files into ~/.claude/
install:
	bash setup/install.sh

# Remove symlinks from ~/.claude/
uninstall:
	bash setup/uninstall.sh

# Clone skill-creator from anthropics/skills
fetch-skill-creator:
	bash setup/fetch-skill-creator.sh

# Install Python dependencies (anthropic, pyyaml, requests, etc.)
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
