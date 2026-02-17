{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.forceInstall = true;

  networking.hostName = "frost";
  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no"; # for root
    settings.PasswordAuthentication = false; # for other users
    openFirewall = true;
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.11";
}
