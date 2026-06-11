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
        pkgs.firefox-addons.to-deepl
        pkgs.firefox-addons.vimium
        pkgs.firefox-addons.violentmonkey
        pkgs.firefox-addons.refined-github
        pkgs.firefox-addons.ublock-origin
        pkgs.firefox-addons.ghostery
      ];
      search = {
        force = true;
        default = "ddg";
      };
      settings = {
        "extensions.autoDisableScopes" = 0;
        "extensions.enabledScopes" = 15;

        # Essentials / pinned tab をクリック時までロードしない（メモリ節約）
        "browser.sessionstore.restore_pinned_tabs_on_demand" = true;
        "browser.sessionstore.restore_on_demand" = true;

        # ブックマークバー常時表示
        "browser.toolbars.bookmarks.visibility" = "always";
      };
    };
  };
}
