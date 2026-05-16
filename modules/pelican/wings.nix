{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.myServices.wings;
in
{
  options.myServices.wings = {
    enable = mkEnableOption "Pelican Wings Node";
    domain = mkOption {
      type = types.str;
      description = "The domain name for this Wings node.";
    };
  };

  config = mkIf cfg.enable {
    networking.firewall = {
      trustedInterfaces = [ "wings0" ];

      allowedTCPPorts = [
        80
        443
        2022
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
      virtualHosts."${cfg.domain}".extraConfig = ''
        reverse_proxy 127.0.0.1:9000
      '';
    };

    systemd.tmpfiles.rules = [
      "d /etc/pelican 0755 root root -"
      "d /var/lib/pelican 0755 root root -"
      "d /var/log/pelican 0755 root root -"
      "d /tmp/pelican 0755 root root -"
    ];

    systemd.services.init-wings-network = {
      description = "Create Docker network for Pelican Wings";
      after = [
        "network.target"
        "docker.service"
      ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        ${pkgs.docker}/bin/docker network inspect wings0 >/dev/null 2>&1 || \
        ${pkgs.docker}/bin/docker network create \
          --driver bridge \
          --subnet 172.21.0.0/16 \
          -o com.docker.network.bridge.name=wings0 \
          wings0
      '';
    };

    virtualisation.oci-containers.containers.wings = {
      image = "ghcr.io/pelican-dev/wings:latest";
      ports = [
        "127.0.0.1:9000:8080"
        "0.0.0.0:2022:2022"
      ];
      environment = {
        TZ = "UTC";
        WINGS_UID = "988";
        WINGS_GID = "988";
        WINGS_USERNAME = "pelican";
      };
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "/var/lib/docker/containers/:/var/lib/docker/containers/"

        "/etc/pelican/:/etc/pelican/"
        "/var/lib/pelican/:/var/lib/pelican/"
        "/var/log/pelican/:/var/log/pelican/"
        "/tmp/pelican/:/tmp/pelican/"
      ];
      extraOptions = [
        "--network=wings0"
        "--privileged"
        "-t"
      ];
    };
  };
}
