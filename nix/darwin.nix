{
  pkgs,
  username,
  homeDir,
  ...
}:

{
  # ユーザー設定
  system.primaryUser = username;
  users.users.${username} = {
    home = homeDir;
  };

  # Nix 設定
  nix = {
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 3;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  # セキュリティ — Touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # macOS システム設定
  system.defaults = {
    # Dock
    dock.autohide = true;
    dock.mru-spaces = false;
    dock.show-recents = false;
    dock.tilesize = 48;

    # Finder
    finder.AppleShowAllExtensions = true;
    finder.ShowPathbar = true;
    finder.ShowStatusBar = true;
    finder.FXPreferredViewStyle = "clmv";
    finder.FXEnableExtensionChangeWarning = false;

    # キーボード — キーリピート有効化（Vim使い必須）
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain.InitialKeyRepeat = 15;
    NSGlobalDomain.KeyRepeat = 2;

    # スクリーンショット
    screencapture.location = "${homeDir}/Pictures/screenshots";

    # ログイン
    loginwindow.GuestEnabled = false;
  };

  # キーボードリマップ
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  # 必須: nix-darwin が管理するシステムバージョン
  system.stateVersion = 6;
}
