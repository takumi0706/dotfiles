.PHONY: lint lint-shell lint-lua lint-toml lint-python lint-json install setup switch test

# --- Primary targets ---

install:
	bash .bin/install.sh

setup:
	bash .bin/setup.sh

switch:
	@attr="default"; \
	if [ "$$(uname -m)" = "x86_64" ]; then attr="default-x86"; fi; \
	sudo --preserve-env=USER,HOME darwin-rebuild switch --flake ".#$$attr" --impure

test:
	CI=true bash .bin/setup.sh

# --- Lint (run inside nix develop) ---

lint:
	nix develop --command $(MAKE) _lint

_lint: lint-shell lint-lua lint-toml lint-python lint-json

lint-shell:
	shellcheck .bin/install.sh .bin/setup.sh .config/zsh/ide.zsh

lint-lua:
	stylua --check .config/wezterm/ .config/nvim/

lint-toml:
	taplo check .config/starship.toml

lint-python:
	ruff check .claude/hooks/

lint-json:
	@for f in .claude/settings.json .claude/settings.local.json; do \
		if [ -f "$$f" ]; then jq empty "$$f" && echo "$$f: valid"; fi; \
	done
