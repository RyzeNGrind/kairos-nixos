{
  description = "A not so simple flake for enabling a NixOS cloud lab at home";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devos.url = "github:divnix/devos";
    devshell.url = "github:numtide/devshell";
  };

  outputs = { self, nixpkgs, flake-utils, devos, devshell, ... }@inputs:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = import nixpkgs {
        inherit system;
        overlays = builtins.attrValues self.overlays;
      };
    in
    {
      overlays.default = final: prev: {
        hello = with final; stdenv.mkDerivation {
          name = "hello";
          src = fetchurl {
            url = "mirror://gnu/hello/hello-2.10.tar.gz";
            sha256 = "0ssi1wpaf7plaswqqjwigppsg5fyh99vdlb9kzl7c9lng89ndq1i";
          };
          buildInputs = [ gcc ];
        };
      };

      nixosModules = {
        cloud-infra = import ./cloud-infra/default.nix;
        cloud-apps = import ./cloud-apps/default.nix;
        # Add other cloud app integrations here
      };

      nixosModules.default = { pkgs, ... }: {
        imports = [ devos.nixosModules.system ];
        networking.hostName = "my-nixos";
        environment.systemPackages = with pkgs; [ hello ];
      };

      packages = {
        ${system} = {
          default = pkgs.hello;
        };
      };

      devShell.${system} = devshell.shell {
        packages = with pkgs; [ hello ];
      };

      nixosConfigurations = {
        nixnas0 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ({ pkgs, ... }: {
              system.stateVersion = "23.05";
            })
            ./devices/arm64/network/nixnas0/default.nix
          ];
        };
      };
    };
}