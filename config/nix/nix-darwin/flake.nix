{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
    }:
    let
      configuration =
        { pkgs, ... }:
        let
          user = "koshiishi";
        in
        {
          imports = [
            ./system.nix
            ./packages.nix
            ./homebrew.nix
          ];

          nix.settings.experimental-features = "nix-command flakes";
          nix.settings.auto-optimise-store = true;

          programs.fish.enable = true;
          system.primaryUser = user;

          security.pam.services.sudo_local.touchIdAuth = true;

          nix.gc = {
            automatic = true;
            interval = {
              Hour = 3;
              Minute = 15;
            };
            options = "--delete-older-than 30d";
          };

          users.users.${user}.home = "/Users/${user}";

          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.stateVersion = 6;
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      darwinConfigurations."main" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bak";
            home-manager.users.koshiishi = import ../home-manager/home.nix;
          }
        ];
      };
    };
}
