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
      codex
      nodejs_22
    ];

    # Skills は ~/.agents/skills/ (複数AIツール共通の標準パス)
    file.".agents/skills".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.agents/skills";

    # secrets.zsh / codex/config.toml はテンプレから初回のみコピー (既存は絶対上書きしない)
    # codex は config.toml に [projects.*] 等の実行時状態を追記するため symlink にできない
    activation.copyTemplates = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run mkdir -p "$HOME/.config/zsh"
      if [ ! -f "$HOME/.config/zsh/secrets.zsh" ]; then
        # install -m 600 で atomic に正しい権限で作成 (cp+chmod の race を回避)
        run install -m 600 "${dotfilesDir}/.config/zsh/secrets.zsh.example" \
                           "$HOME/.config/zsh/secrets.zsh"
      fi
      # 既存ファイルでも権限は常に 600 に矯正
      run chmod 600 "$HOME/.config/zsh/secrets.zsh"

      # codex は ~/.codex/auth.json に OAuth/APIキーを保存するため restrictive に作成
      run install -d -m 700 "$HOME/.codex"
      if [ ! -f "$HOME/.codex/config.toml" ]; then
        run install -m 600 "${dotfilesDir}/.config/codex/config.toml" \
                           "$HOME/.codex/config.toml"
      fi
      run chmod 600 "$HOME/.codex/config.toml"
    '';
  };

  # ------------------------------------------------------------------
  # dotfiles — mkOutOfStoreSymlink で既存設定をそのままリンク
  # rebuild 不要で設定変更が即反映される
  # ------------------------------------------------------------------
  xdg.configFile = {
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/nvim";
    "wezterm".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/wezterm";
    "zsh".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/zsh";
    "starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/starship.toml";
    "git/ignore".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/git/ignore";
    "gh/config.yml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/.config/gh/config.yml";
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

      # API keys / secrets (gitignored, copied from template on first switch)
      [[ -f "$HOME/.config/zsh/secrets.zsh" ]] && source "$HOME/.config/zsh/secrets.zsh"

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
