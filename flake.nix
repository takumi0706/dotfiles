{
  description = "takumi0706 dotfiles — nix-darwin + home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
    }:
    let
      darwinSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];

      # devShell はどのアーキテクチャでも使えるように
      forAllDarwinSystems = f: nixpkgs.lib.genAttrs darwinSystems f;

      # sudo 経由で実行された場合は SUDO_USER から元ユーザーを取得
      # 直接実行の場合は USER を使用
      # pure evaluation（CI）では空文字→ fallback
      username =
        let
          sudoUser = builtins.getEnv "SUDO_USER";
          user = builtins.getEnv "USER";
        in
        if sudoUser != "" then sudoUser else if user != "" then user else "unknown";
      homeDir = "/Users/${username}";
      dotfilesDir = "${homeDir}/dotfiles";

      # darwin 構成を生成する関数
      mkDarwinConfig =
        system:
        nix-darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit
              inputs
              self
              username
              homeDir
              dotfilesDir
              ;
          };
          modules = [
            ./nix/darwin.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-backup";
              home-manager.extraSpecialArgs = {
                inherit
                  system
                  username
                  homeDir
                  dotfilesDir
                  ;
              };
              home-manager.users.${username} = import ./nix/home.nix;
            }
          ];
        };
    in
    {
      # sudo darwin-rebuild switch --flake .#default --impure で適用
      darwinConfigurations.default = mkDarwinConfig "aarch64-darwin";
      darwinConfigurations.default-x86 = mkDarwinConfig "x86_64-darwin";

      # devShell: lintツール群（pure evaluation で動作）
      devShells = forAllDarwinSystems (system: {
        default =
          let
            pkgs = nixpkgs.legacyPackages.${system};
          in
          pkgs.mkShell {
            packages = with pkgs; [
              shellcheck
              stylua
              taplo
              ruff
              jq
            ];
          };
      });
    };
}
