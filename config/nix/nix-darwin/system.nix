{ user, ... }:
{
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
      "com.apple.keyboard.fnState" = true;
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
      location = "/Users/${user}/Screenshots";
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
}
