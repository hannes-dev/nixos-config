{
  config,
  lib,
  ...
}:

let
  cfg = config.myServices.silverbullet;
in
{
  options.myServices.silverbullet = {
    enable = lib.mkEnableOption "Silverbullet wrapper";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "notes.klinckaert.be";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 21072;
    };

    envFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    services.silverbullet = {
      enable = true;

      listenPort = cfg.port;
      listenAddress = "127.0.0.1";

      envFile = cfg.envFile;
    };

    services.caddy = {
      enable = true;
      virtualHosts."${cfg.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
