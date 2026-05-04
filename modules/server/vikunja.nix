{
  config,
  lib,
  ...
}:

let
  cfg = config.myServices.vikunja;
in
{
  options.myServices.vikunja = {
    enable = lib.mkEnableOption "Vikunja wrapper";

    domain = lib.mkOption {
      type = lib.types.str;
      default = "todo.klinckaert.be";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 21071;
      description = "Local port to bind the Vikunja service to.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.vikunja = {
      enable = true;

      frontendScheme = "https";
      frontendHostname = cfg.domain;

      port = cfg.port;

      settings = {
        service = {
          enableregistration = false;
        };
      };
    };

    services.caddy = {
      enable = true;
      virtualHosts."${cfg.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };
  };
}
