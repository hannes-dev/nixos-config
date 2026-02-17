{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {

    nixosConfigurations = {
      frost = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./modules/common.nix
          ./machines/frost/default.nix
        ];
      };

      minimal-installer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

          ({ pkgs, ... }: {
            users.users.root.openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOEPMl3fFGeNzvprnt5kWBfa9dRahnYCsbD8TNM3i0Jf hannes@tatsu" ];
            networking.networkmanager.enable = true; # dhcp?
            environment.systemPackages = [ pkgs.vim ];
            isoImage.squashfsCompression = "zstd -Xcompression-level 6";
          })
        ];
      };
    };

    packages.x86_64-linux = {
      minimal-iso = self.nixosConfigurations.minimal-installer.config.system.build.isoImage;
    };
  };
}
