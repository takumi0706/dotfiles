# =============================================================================
# fzf Configuration for Zsh
# =============================================================================
# Features:
# - Ctrl+R: Enhanced history search
# - Ctrl+T: File search
# - Alt+C: Directory navigation
# - Catppuccin-inspired color scheme
# =============================================================================

# Check if fzf is installed
if ! command -v fzf &>/dev/null; then
  return
fi

# -----------------------------------------------------------------------------
# Basic Configuration
# -----------------------------------------------------------------------------

# Default fzf options
export FZF_DEFAULT_OPTS="
  --height=40%
  --layout=reverse
  --border=rounded
  --info=inline
  --margin=1
  --padding=1
  --prompt='❯ '
  --pointer='▶'
  --marker='✓'
  --bind='ctrl-y:accept'
  --bind='ctrl-u:preview-half-page-up'
  --bind='ctrl-d:preview-half-page-down'
"

# Use fd if available for better performance
if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
fi

# -----------------------------------------------------------------------------
# Catppuccin-inspired Color Scheme
# -----------------------------------------------------------------------------

# Colors that complement the Catppuccin theme
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
  --color=border:#6c7086
"

# -----------------------------------------------------------------------------
# Key Bindings
# -----------------------------------------------------------------------------

# Ctrl+R: Enhanced history search with preview
export FZF_CTRL_R_OPTS="
  --preview='echo {}'
  --preview-window=down:3:wrap
  --bind='ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --header='Press CTRL-Y to copy command to clipboard'
"

# Ctrl+T: File search with preview
export FZF_CTRL_T_OPTS="
  --preview='[[ -f {} ]] && bat --style=numbers --color=always {} 2>/dev/null || ls -la {}'
  --preview-window=right:60%:wrap
  --bind='ctrl-/:toggle-preview'
"

# Alt+C: Directory navigation with preview
export FZF_ALT_C_OPTS="
  --preview='ls -la {} | head -20'
  --preview-window=right:50%:wrap
"

# -----------------------------------------------------------------------------
# Shell Integration
# -----------------------------------------------------------------------------

# Source fzf key bindings and completion
if [[ -f "/opt/homebrew/opt/fzf/shell/key-bindings.zsh" ]]; then
  source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
fi

if [[ -f "/opt/homebrew/opt/fzf/shell/completion.zsh" ]]; then
  source "/opt/homebrew/opt/fzf/shell/completion.zsh"
fi

# -----------------------------------------------------------------------------
# Custom Functions
# -----------------------------------------------------------------------------

# fzf-powered git branch switching
fzf-git-branch() {
  local branches branch
  branches=$(git branch --all 2>/dev/null | grep -v HEAD) || return
  branch=$(echo "$branches" | fzf --height=40% --reverse --prompt="branch> ") || return
  git checkout "$(echo "$branch" | sed 's/.* //' | sed 's#remotes/[^/]*/##')"
}

# fzf-powered git log viewer
fzf-git-log() {
  git log --oneline --color=always 2>/dev/null |
    fzf --ansi --height=80% --reverse \
      --preview='git show --color=always {1}' \
      --preview-window=right:60%:wrap \
      --bind='enter:execute(git show {1})'
}

# Aliases for git functions
alias gbf='fzf-git-branch'
alias glf='fzf-git-log'
