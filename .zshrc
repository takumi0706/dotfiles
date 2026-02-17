# shellcheck shell=bash
# shellcheck disable=SC1090,SC1091
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Added by Windsurf
export PATH="/Users/takumi0706/.codeium/windsurf/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="/opt/homebrew/Caskroom/flutter/3.29.3/flutter/bin:$PATH"
export PATH="/Library/TeX/texbin:$PATH"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

. "$HOME/.local/bin/env"

# Package manager completions (npm/yarn/pnpm)
[[ -f "$HOME/.config/zsh/completions.zsh" ]] && source "$HOME/.config/zsh/completions.zsh"

# fzf integration
[[ -f "$HOME/.config/zsh/fzf.zsh" ]] && source "$HOME/.config/zsh/fzf.zsh"

# IDE function (WezTerm IDE layout)
[[ -f "$HOME/.config/zsh/ide.zsh" ]] && source "$HOME/.config/zsh/ide.zsh"

eval "$(starship init zsh)"

