{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.myServices.wings;
in
{
  options.myServices.wings = {
    enable = mkEnableOption "Pterodactyl Wings Node";
    fqdn = mkOption {
      type = types.str;
      description = "The domain name for this Wings node.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      trustedInterfaces = [ "pterodactyl0" ];

      allowedTCPPorts = [
        80
        443
      ];
      allowedTCPPortRanges = [
        {
          from = 25000;
          to = 26000;
        }
      ];
      allowedUDPPortRanges = [
        {
          from = 25000;
          to = 26000;
        }
      ];
    };

    services.caddy = {
      enable = true;
      virtualHosts."${cfg.fqdn}".extraConfig = ''
        reverse_proxy 127.0.0.1:9000
      '';
    };

    systemd.tmpfiles.rules = [
      "d /run/wings 0755 root root -"
      "d /tmp/pterodactyl 0755 root root -"
    ];

    virtualisation.oci-containers.containers.wings = {
      image = "ghcr.io/pterodactyl/wings:v1.12.1";
      ports = [
        "127.0.0.1:9000:443" # API proxied by Caddy
        "0.0.0.0:2022:2022" # SFTP exposed directly
      ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"

        "/run/wings:/run/wings"
        "/tmp/pterodactyl:/tmp/pterodactyl"

        "/var/lib/pterodactyl/config.yml:/etc/pterodactyl/config.yml"
        "/var/lib/pterodactyl/volumes:/var/lib/pterodactyl/volumes"
        "/var/lib/pterodactyl/backups:/var/lib/pterodactyl/backups"
      ];
    };
  };
}
