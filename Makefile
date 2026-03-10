.PHONY: install uninstall fetch-skill-creator skill-creator-deps

install: ## Symlink dirs and files into ~/.claude/
	bash setup/install.sh

uninstall: ## Remove symlinks from ~/.claude/
	bash setup/uninstall.sh

fetch-skill-creator: ## Clone skill-creator from anthropics/skills
	bash setup/fetch-skill-creator.sh

skill-creator-deps: ## Install skill-creator dependencies (anthropic, pyyaml, requests)
	bash setup/install-skill-creator-deps.sh
