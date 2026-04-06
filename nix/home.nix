{
  config,
  pkgs,
  lib,
  system,
  username,
  homeDir,
  dotfilesDir,
  ...
}:
let
  flakeAttr = if system == "x86_64-darwin" then "default-x86" else "default";
in

{
  home = {
    stateVersion = "24.11";
    username = username;
    homeDirectory = homeDir;

    packages = with pkgs; [
      fd
      lazygit
      ripgrep
      jq
      nerd-fonts.jetbrains-mono
    ];
  };

  # ------------------------------------------------------------------
  # dotfiles — flake 相対パスで Nix store にコピーしてリンク
  # 設定変更時は make switch で反映
  # ------------------------------------------------------------------
  xdg.configFile = {
    "nvim" = {
      source = ../.config/nvim;
      recursive = true;
    };
    "wezterm" = {
      source = ../.config/wezterm;
      recursive = true;
    };
    "zsh" = {
      source = ../.config/zsh;
      recursive = true;
    };
    "starship.toml".source = ../.config/starship.toml;
    "git/ignore".source = ../.config/git/ignore;
    "gh/config.yml".source = ../.config/gh/config.yml;
  };

  # ------------------------------------------------------------------
  # programs.* DSL
  # ------------------------------------------------------------------

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    # 設定は xdg.configFile."starship.toml" で既存tomlを参照
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    signing.format = null;
  };

  # ------------------------------------------------------------------
  # Zsh
  # ------------------------------------------------------------------
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    shellAliases = {
      switch = "sudo darwin-rebuild switch --flake ${dotfilesDir}#${flakeAttr} --impure";
    };

    initContent = ''
      # ~/.local/bin (claude CLI etc.)
      [[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

      # Package manager completions (npm/yarn/pnpm)
      [[ -f "$HOME/.config/zsh/completions.zsh" ]] && source "$HOME/.config/zsh/completions.zsh"

      # fzf custom config (colors, key bindings, functions)
      [[ -f "$HOME/.config/zsh/fzf.zsh" ]] && source "$HOME/.config/zsh/fzf.zsh"

      # IDE function (WezTerm IDE layout)
      [[ -f "$HOME/.config/zsh/ide.zsh" ]] && source "$HOME/.config/zsh/ide.zsh"

      # Kiro shell integration
      [[ "$TERM_PROGRAM" == "kiro" ]] && command -v kiro &>/dev/null && . "$(kiro --locate-shell-integration-path zsh)"
    '';
  };
}
