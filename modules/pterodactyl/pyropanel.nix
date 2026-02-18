{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.myServices.pyropanel;
in {
  options.myServices.pyropanel = {
    enable = mkEnableOption "Pyrodactyl Panel Stack";
    fqdn = mkOption {
      type = types.str;
      description = "The domain name for the Panel.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    services.caddy = {
      enable = true;
      virtualHosts."${cfg.fqdn}".extraConfig = ''
        reverse_proxy 127.0.0.1:8000
      '';
    };

    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
    };

    systemd.services.init-pterodactyl-network = {
      description = "Create Docker network for Pterodactyl";
      after = [ "network.target" "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.docker}/bin/docker network inspect pterodactyl-net >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create pterodactyl-net
      '';
    };

    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers = {
      database = {
        image = "mariadb:10.5";
        extraOptions = [ "--network=pterodactyl-net" ];
        environment = {
          MYSQL_DATABASE = "panel";
          MYSQL_USER = "pterodactyl";
        };
        environmentFiles = [ "/var/lib/pterodactyl/panel.env" ];
        volumes = [ "/var/lib/pterodactyl/database:/var/lib/mysql" ];
        cmd = [ "--default-authentication-plugin=mysql_native_password" ];
      };

      cache = {
        image = "redis:alpine";
        extraOptions = [ "--network=pterodactyl-net" ];
      };

      panel = {
        image = "ghcr.io/pyrodactyl-oss/pyrodactyl:v5.0.1";
        extraOptions = [ "--network=pterodactyl-net" ];
        ports = [ "127.0.0.1:8000:80" ];
        environment = {
          APP_ENV = "production";
          APP_ENVIRONMENT_ONLY = "false";
          APP_TIMEZONE = "UTC";

          DB_CONNECTION = "mariadb";
          DB_HOST = "database";
          DB_PORT = "3306";
          DB_USERNAME = "pterodactyl";

          CACHE_DRIVER = "redis";
          SESSION_DRIVER = "redis";
          QUEUE_DRIVER = "redis";
          REDIS_HOST = "cache";

          TRUSTED_PROXIES = "*";

          MAIL_DRIVER = "log";
        };
        environmentFiles = [ "/var/lib/pterodactyl/panel.env" ];
        volumes = [
          "/var/lib/pterodactyl/var/:/app/var/"
          "/var/lib/pterodactyl/nginx/:/etc/nginx/http.d/"
          "/var/lib/pterodactyl/certs/:/etc/letsencrypt/"
          "/var/lib/pterodactyl/logs/:/app/storage/logs"
        ];
        dependsOn = [ "database" "cache" ];
      };
    };
  };
}
