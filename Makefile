LINT_EXCLUDE := .git .venv skills/skill-creator

.PHONY: install uninstall fetch-skill-creator python-deps lint

install: ## Symlink dirs and files into ~/.claude/
	bash setup/install.sh

uninstall: ## Remove symlinks from ~/.claude/
	bash setup/uninstall.sh

fetch-skill-creator: ## Clone skill-creator from anthropics/skills
	bash setup/fetch-skill-creator.sh

python-deps: ## Install Python dependencies (anthropic, pyyaml, requests, etc.)
	bash setup/install-python-deps.sh

lint: ## Lint .sh files with shellcheck and .py files with ruff
	shellcheck $$(find . -name '*.sh' $(foreach d,$(LINT_EXCLUDE),-not -path './$(d)/*'))
	ruff check --fix $$(find . -name '*.py' $(foreach d,$(LINT_EXCLUDE),-not -path './$(d)/*'))
	ruff format $$(find . -name '*.py' $(foreach d,$(LINT_EXCLUDE),-not -path './$(d)/*'))
