{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/server/ssh.nix
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.tailscale = {
    enable = true;
    disableUpstreamLogging = true;
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.11";
}
