{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
  ];
  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ]; # allow binary emulation for aarch64

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    supportedFilesystems = [ "bcachefs" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    networkmanager.enable = true;
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];

    firewall = {
      enable = true;
      allowedTCPPorts = [ 8000 ];
      allowedUDPPorts = [ ];
    };
  };

  hardware.bluetooth.enable = true;

  time.timeZone = "Europe/Brussels";

  security.sudo.extraConfig = "Defaults insults, pwfeedback";
  users.users.hannes = {
    extraGroups = [
      "input"
      "wireshark"
      "dialout"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  programs = {
    nix-ld.enable = true;
    niri.enable = true;
    fish.enable = true;
    steam.enable = true;
    wireshark.enable = true;
  };

  services = {
    tailscale.enable = true;
    printing.enable = true;
    avahi = {
      enable = false;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  system.stateVersion = "24.05";
}
