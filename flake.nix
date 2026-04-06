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
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      # ホスト名に依存しない汎用構成
      # darwin-rebuild switch --flake . --impure で適用
      # builtins.getEnv は --impure フラグが必要
      username =
        let
          env = builtins.getEnv "USER";
        in
        if env != "" then env else "unknown";
      homeDir =
        let
          env = builtins.getEnv "HOME";
        in
        if env != "" then env else "/Users/${username}";
      dotfilesDir = "${homeDir}/dotfiles";
    in
    {
      darwinConfigurations.default = nix-darwin.lib.darwinSystem {
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
            home-manager.extraSpecialArgs = {
              inherit
                username
                homeDir
                dotfilesDir
                ;
            };
            home-manager.users.${username} = import ./nix/home.nix;
          }
        ];
      };

      # devShell: lintツール群
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          shellcheck
          stylua
          taplo
          ruff
          jq
        ];
      };
    };
}
