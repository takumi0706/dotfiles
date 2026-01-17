# =============================================================================
# Zsh Completion Configuration for npm/yarn/pnpm
# =============================================================================
# Features:
# - Lazy loading for minimal shell startup impact
# - Menu selection UI (git-style Tab completion)
# - npm, yarn (v1/v2+), pnpm completions
# - Workspace support for monorepos
# - Silent fallback on errors
# =============================================================================

# -----------------------------------------------------------------------------
# FPATH Configuration
# -----------------------------------------------------------------------------

# Homebrew zsh-completions (includes yarn)
if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
  FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
fi

# Custom completions directory
FPATH="$HOME/.local/share/zsh/completions:$FPATH"

# -----------------------------------------------------------------------------
# Completion System Initialization (Lazy Loading)
# -----------------------------------------------------------------------------

# Flag to track if compinit has been run
typeset -g _completions_initialized=0

# Initialize completion system
_init_completion() {
  (( _completions_initialized )) && return

  # Load completion system
  autoload -Uz compinit

  # Use cached .zcompdump if less than 24 hours old
  local zcompdump="$HOME/.zcompdump"
  local zcompcache="$HOME/.zcompcache"

  # Create cache directory if needed
  [[ -d "$zcompcache" ]] || mkdir -p "$zcompcache"

  # Check if .zcompdump needs regeneration (once per day)
  if [[ -n "$zcompdump"(#qN.mh+24) ]]; then
    compinit -i -d "$zcompdump"
  else
    compinit -C -d "$zcompdump"
  fi

  _completions_initialized=1

  # Apply completion styles after compinit
  _setup_completion_styles
}

# -----------------------------------------------------------------------------
# Completion Styles (Menu Selection)
# -----------------------------------------------------------------------------

_setup_completion_styles() {
  # Enable menu selection (git-style)
  zstyle ':completion:*' menu select

  # Case-insensitive matching
  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

  # Group completions by type
  zstyle ':completion:*' group-name ''
  zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
  zstyle ':completion:*:warnings' format '%F{red}No matches found%f'

  # Enable completion caching
  zstyle ':completion:*' use-cache on
  zstyle ':completion:*' cache-path "$HOME/.zcompcache"

  # Colors for file completions
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

  # Better directory navigation
  zstyle ':completion:*' special-dirs true

  # Fuzzy matching for typos
  zstyle ':completion:*' completer _complete _match _approximate
  zstyle ':completion:*:match:*' original only
  zstyle ':completion:*:approximate:*' max-errors 1 numeric
}

# -----------------------------------------------------------------------------
# npm Completion
# -----------------------------------------------------------------------------

_setup_npm_completion() {
  # npm's built-in completion
  if command -v npm &>/dev/null; then
    # npm completion outputs a script that can be sourced
    eval "$(npm completion 2>/dev/null)" 2>/dev/null || true
  fi
}

# -----------------------------------------------------------------------------
# pnpm Completion
# -----------------------------------------------------------------------------

_setup_pnpm_completion() {
  if ! command -v pnpm &>/dev/null; then
    return
  fi

  local pnpm_completion="$HOME/.local/share/zsh/completions/_pnpm"

  # Generate pnpm completion if not exists or pnpm version changed
  if [[ ! -f "$pnpm_completion" ]] || \
     [[ "$(pnpm --version 2>/dev/null)" != "$(head -1 "$pnpm_completion" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')" ]]; then
    {
      echo "# pnpm $(pnpm --version 2>/dev/null)"
      pnpm completion zsh 2>/dev/null
    } > "$pnpm_completion" 2>/dev/null || true
  fi

  # Source pnpm completion
  [[ -f "$pnpm_completion" ]] && source "$pnpm_completion" 2>/dev/null || true
}

# -----------------------------------------------------------------------------
# Lazy Loading Trigger
# -----------------------------------------------------------------------------

# Override Tab key to initialize completions on first use
_lazy_completion() {
  # Remove this widget after first run
  zle -D _lazy_completion 2>/dev/null

  # Initialize completion system
  _init_completion

  # Setup package manager completions
  _setup_npm_completion
  _setup_pnpm_completion

  # Bind normal Tab behavior
  zle -N expand-or-complete

  # Execute the original Tab action
  zle expand-or-complete
}

# Bind lazy loading to Tab key
zle -N _lazy_completion
bindkey '^I' _lazy_completion

# -----------------------------------------------------------------------------
# Helper Functions (Available Immediately)
# -----------------------------------------------------------------------------

# Force reload completions (useful after installing new packages)
reload-completions() {
  _completions_initialized=0
  rm -f "$HOME/.zcompdump"*
  rm -f "$HOME/.local/share/zsh/completions/_pnpm"
  exec zsh
}
