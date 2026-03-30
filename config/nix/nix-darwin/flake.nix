{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }:
    let
      user = "itsuki54";
    in {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";
      nix.settings.auto-optimise-store = true;

      # Enable alternative shell support in nix-darwin.
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

      system.defaults = {
        dock = {
          autohide = true;
          autohide-delay = 0.2;
          autohide-time-modifier = 0.8;
          orientation = "left";
          tilesize = 42;
          launchanim = false;
        };

        finder = {
          AppleShowAllFiles = true;
          AppleShowAllExtensions = true;
          ShowPathbar = true;
          ShowStatusBar = true;
          FXPreferredViewStyle = "Nlsv";
          FXDefaultSearchScope = "SCcf";
        };

        NSGlobalDomain = {
          AppleInterfaceStyle = "Dark";
          AppleShowAllExtensions = true;
          InitialKeyRepeat = 15;
          KeyRepeat = 2;
          "com.apple.trackpad.forceClick" = false;
          "com.apple.trackpad.scaling" = 2.5;
          _HIHideMenuBar = true;
        };

        trackpad = {
          Clicking = true;
          TrackpadThreeFingerDrag = true;
        };

        screensaver = {
          askForPassword = true;
        };

        screencapture = {
          location = "/Users/${user}/Downloads/Screenshots";
          disable-shadow = true;
        };

        controlcenter = {
          AirDrop = false;
          Bluetooth = false;
          BatteryShowPercentage = false;
          Display = false;
          FocusModes = false;
          NowPlaying = false;
          Sound = false;
        };
      };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    darwinConfigurations."main" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
