{
  description = "NixOS configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      agenix,
      nix-index-database,
      ...
    }@inputs:
    let
      mkMachine =
        {
          hostname,
          system ? "x86_64-linux",
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            { networking.hostName = hostname; }
            agenix.nixosModules.default
            ./modules/common.nix
            ./machines/${hostname}/default.nix
            nix-index-database.nixosModules.default
          ];
        };

      isoConfig =
        { pkgs, ... }:
        {
          users.users.root.openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOEPMl3fFGeNzvprnt5kWBfa9dRahnYCsbD8TNM3i0Jf"
          ];
          environment.systemPackages = [ pkgs.vim ];
          isoImage.squashfsCompression = "zstd -Xcompression-level 6";
        };
    in
    {
      nixosConfigurations = {
        frost = mkMachine { hostname = "frost"; };
        puk = mkMachine { hostname = "puk"; };
        tatsu = mkMachine { hostname = "tatsu"; };

        kotpi = mkMachine {
          hostname = "kotpi";
          system = "aarch64-linux";
        };

        minimal-installer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            isoConfig
          ];
        };
      };

      packages."x86_64-linux" = {
        minimal-iso = self.nixosConfigurations.minimal-installer.config.system.build.isoImage;
      };
    };
}
