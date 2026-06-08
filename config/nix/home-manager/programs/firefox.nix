{
  pkgs,
  config,
  ...
}:
{
  home.file."Library/Application Support/Mozilla/NativeMessagingHosts/tridactyl.json".source =
    "${pkgs.tridactyl-native}/lib/mozilla/native-messaging-hosts/tridactyl.json";

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;

    profiles.default = {
      id = 0;
      isDefault = true;
      extensions.packages = [
        pkgs.firefox-addons.tridactyl
        pkgs.firefox-addons."1password-x-password-manager"
        pkgs.firefox-addons.wappalyzer
        pkgs.firefox-addons.to-deepl
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
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.visibility" = "always-show";

        "extensions.autoDisableScopes" = 0;
        "extensions.enabledScopes" = 15;

        "browser.startup.homepage" = "about:blank";
        "browser.newtabpage.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.uidensity" = 1;
      };
    };
  };
}
