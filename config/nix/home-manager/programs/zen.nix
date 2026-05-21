{
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [ inputs.zen-browser.homeModules.beta ];

  programs.zen-browser = {
    enable = true;
    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      DisablePocket = true;
      OfferToSaveLogins = false;
      PasswordManagerEnabled = false;
      DownloadDirectory = "${config.home.homeDirectory}/Downloads";
    };
    profiles.default = {
      id = 0;
      isDefault = true;
      extensions.packages = [
        pkgs.firefox-addons."1password-x-password-manager"
        pkgs.firefox-addons.wappalyzer
      ];
      search = {
        force = true;
        default = "ddg";
      };
      settings = {
        "extensions.autoDisableScopes" = 0;
        "extensions.enabledScopes" = 15;
      };
    };
  };
}
