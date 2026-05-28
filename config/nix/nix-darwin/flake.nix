{
  description = "nix-darwin dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-claude-code.url = "github:ryoppippi/nix-claude-code";
    nix-your-shell = {
      url = "github:MercuryTechnologies/nix-your-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    arto = {
      url = "github:arto-app/Arto";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agent-skills.url = "github:Kyure-A/agent-skills-nix";
    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
    skills = {
      url = "github:nurazon59/skills";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nix-index-database,
      home-manager,
      neovim-nightly-overlay,
      firefox-addons,
      nix-your-shell,
      arto,
      ...
    }:
    let
      mkSystem =
        user:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit user neovim-nightly-overlay arto; };
          modules = [
            (
              { config, ... }:
              {
                imports = [
                  ./system.nix
                  ./packages.nix
                  ./homebrew.nix
                ];

                nix.settings.experimental-features = "nix-command flakes";
                nix.settings.auto-optimise-store = true;
                nix.extraOptions = ''
                  !include /Users/${user}/.config/nix/access-tokens.conf
                '';

                programs.fish.enable = true;
                environment.interactiveShellInit = ''
                  . "${
                    config."home-manager".users.${user}.home.sessionVariablesPackage
                  }/etc/profile.d/hm-session-vars.sh"
                '';
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
                  (_final: prev: {
                    direnv = prev.direnv.overrideAttrs (_: {
                      doCheck = false;
                    });
                  })
                  firefox-addons.overlays.default
                  nix-your-shell.overlays.default
                ];
                nixpkgs.config.allowUnfree = true;

                system.configurationRevision = self.rev or self.dirtyRev or null;
                system.stateVersion = 6;
                nixpkgs.hostPlatform = "aarch64-darwin";
              }
            )
            nix-index-database.darwinModules.nix-index
            { programs.nix-index-database.comma.enable = true; }
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";
              home-manager.extraSpecialArgs = { inherit user inputs; };
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
