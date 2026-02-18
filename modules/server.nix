{ config, pkgs, ... }:
{
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no"; # for root
    settings.PasswordAuthentication = false; # for other users
    openFirewall = true;
  };

  networking.firewall.logRefusedConnections = false;
  services.fail2ban = {
    enable = true;
    bantime = "12h";
    maxretry = 2;
  };

  security.sudo.wheelNeedsPassword = false;
  users.users.hannes.extraGroups = [ "docker" ];
}
