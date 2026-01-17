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
# Completion System Initialization
# -----------------------------------------------------------------------------

# Initialize completion system
_init_completion() {
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
# Yarn Workspace Scripts Completion (for yarn v4+)
# -----------------------------------------------------------------------------

_yarn_workspace_scripts() {
  local workspace_name="$1"
  local root_dir

  # Require jq for JSON parsing
  command -v jq &>/dev/null || return 1

  # Find yarn project root
  root_dir=$(pwd)
  while [[ "$root_dir" != "/" ]]; do
    [[ -f "$root_dir/yarn.lock" ]] && break
    root_dir=$(dirname "$root_dir")
  done
  [[ "$root_dir" == "/" ]] && return 1

  # Find workspace package.json
  local pkg_json=""

  # Get workspace patterns from root package.json
  if [[ -f "$root_dir/package.json" ]]; then
    local -a workspace_patterns
    workspace_patterns=("${(@f)$(jq -r '.workspaces // [] | .[]' "$root_dir/package.json" 2>/dev/null)}")

    local pattern
    for pattern in "${workspace_patterns[@]}"; do
      [[ -z "$pattern" ]] && continue
      # Handle glob patterns like "packages/*" or "apps/*"
      local base_dir="${pattern%\*}"
      base_dir="${base_dir%/}"
      if [[ -d "$root_dir/$base_dir" ]]; then
        local dir
        for dir in "$root_dir/$base_dir"/*/; do
          if [[ -f "${dir}package.json" ]]; then
            local name
            name=$(jq -r '.name // ""' "${dir}package.json" 2>/dev/null)
            if [[ "$name" == "$workspace_name" ]]; then
              pkg_json="${dir}package.json"
              break 2
            fi
          fi
        done
      fi
    done
  fi

  [[ -z "$pkg_json" || ! -f "$pkg_json" ]] && return 1

  # Extract scripts using jq
  jq -r '.scripts // {} | keys[]' "$pkg_json" 2>/dev/null
}

# Custom completion wrapper for yarn workspace scripts
_yarn_with_workspace_scripts() {
  # Check if we're completing after "yarn workspace <name>"
  if [[ ${#words[@]} -ge 4 && "${words[2]}" == "workspace" ]]; then
    local workspace_name="${words[3]}"
    local scripts
    scripts=$(_yarn_workspace_scripts "$workspace_name" 2>/dev/null)

    if [[ -n "$scripts" ]]; then
      local -a script_list
      script_list=(${(f)scripts})
      _describe -t scripts 'workspace scripts' script_list && return 0
    fi
  fi

  # Fall back to original _yarn completion
  _yarn "$@"
}

# Hook into yarn completion (preserve original)
_setup_yarn_workspace_completion() {
  # Only set up if _yarn exists
  if (( $+functions[_yarn] )); then
    compdef _yarn_with_workspace_scripts yarn 2>/dev/null || true
  fi
}

# -----------------------------------------------------------------------------
# Initialize Completions
# -----------------------------------------------------------------------------

# Run initialization immediately
_init_completion
_setup_npm_completion
_setup_pnpm_completion
_setup_yarn_workspace_completion

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
