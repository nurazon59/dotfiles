{
  description = "nix-darwin dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      neovim-nightly-overlay,
    }:
    let
      mkSystem =
        user:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit user neovim-nightly-overlay; };
          modules = [
            (
              { pkgs, ... }:
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

                nixpkgs.overlays = [
                  (final: prev: {
                    direnv = prev.direnv.overrideAttrs (_: { doCheck = false; });
                  })
                ];
                nixpkgs.config.allowUnfree = true;

                system.configurationRevision = self.rev or self.dirtyRev or null;
                system.stateVersion = 6;
                nixpkgs.hostPlatform = "aarch64-darwin";
              }
            )
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";
              home-manager.extraSpecialArgs = { inherit user; };
              home-manager.users.${user} = import ../home-manager/home.nix;
            }
          ];
        };
    in
    {
      darwinConfigurations = {
        work = mkSystem "koshiishi";
        personal = mkSystem "itsuki54";
      };
    };
}
