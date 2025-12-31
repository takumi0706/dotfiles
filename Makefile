.PHONY: lint lint-shell lint-lua lint-toml lint-python lint-json install test

lint: lint-shell lint-lua lint-toml lint-python lint-json

lint-shell:
	shellcheck .bin/install.sh .zshrc

lint-lua:
	stylua --check .config/wezterm/

lint-toml:
	taplo check .config/starship.toml

lint-python:
	ruff check .claude/hooks/

lint-json:
	@for f in .claude/settings.json .claude/settings.local.json; do \
		[ -f "$$f" ] && jq empty "$$f" && echo "$$f: valid"; \
	done

install:
	bash .bin/install.sh

test:
	CI=true bash .bin/install.sh
