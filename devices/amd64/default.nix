{
  description = "A simple flake for managing amd64 devices";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devos.url = "github:divnix/devos";
    std.url = "github:divnix/std";
    liminix.url = "github:liminix/liminix";
  };

  outputs = { self, nixpkgs, flake-utils, devos, std, liminix }: {
    nixosConfigurations = flake-utils.lib.eachDefaultSystem (system: {
      inherit system;
      modules = [
        ./hardware-configuration.nix
        ./configuration.nix
        {
          nixpkgs.overlays.default = [
            (self: super: {
              inherit (std) router;
            })
          ];
        }
      ];
    });
  };
}
