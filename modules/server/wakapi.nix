{ config, lib, ... }:

with lib;
let
  cfg = config.myServices.wakapi;
in
{
  options.myServices.wakapi = {
    enable = mkEnableOption "Wakapi";
  };

  config = mkIf cfg.enable {
    services.wakapi = {
      enable = true;
      database.dialect = "sqlite3";
      passwordSalt = "wakapi";
      settings = {
        server = {
          port = 9090;
        };
        app = {
          leaderboard_enabled = false;
        };
        security = {
          allow_signup = false;
          disable_frontpage = true;
          insecure_cookies = false;
        };
      };
    };

    services.caddy = {
      enable = true;
      virtualHosts."waka.klinckaert.be".extraConfig = ''
        reverse_proxy 127.0.0.1:9090
      '';
    };
  };
}
