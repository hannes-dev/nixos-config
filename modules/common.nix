{ config, pkgs, ... }:
{
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "nl_BE.UTF-8";
    LC_IDENTIFICATION = "nl_BE.UTF-8";
    LC_MEASUREMENT = "nl_BE.UTF-8";
    LC_MONETARY = "nl_BE.UTF-8";
    LC_NAME = "nl_BE.UTF-8";
    LC_NUMERIC = "nl_BE.UTF-8";
    LC_PAPER = "nl_BE.UTF-8";
    LC_TELEPHONE = "nl_BE.UTF-8";
    LC_TIME = "nl_BE.UTF-8";
  };

  users.users.hannes = {
    shell = pkgs.fish;
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOEPMl3fFGeNzvprnt5kWBfa9dRahnYCsbD8TNM3i0Jf hannes@tatsu" ];
  };

  environment.systemPackages = with pkgs; [
      git
      helix
      htop
      curl
      wget
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
