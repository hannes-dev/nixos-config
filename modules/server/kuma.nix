{ config, lib, ... }:

with lib;
let
  cfg = config.myServices.kuma;
in
{
  options.myServices.kuma = {
    enable = mkEnableOption "Uptime Kuma";
  };

  config = mkIf cfg.enable {
    services.uptime-kuma = {
      enable = true;
      settings = {
        PORT = "21067";
      };
    };

    services.caddy = {
      enable = true;
      virtualHosts."uptime.klinckaert.be".extraConfig = ''
        reverse_proxy 127.0.0.1:21067
      '';
    };
  };
}
