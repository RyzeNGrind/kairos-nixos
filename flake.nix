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
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; };
    in
    {
      overlay = final: prev: {
        hello = with final; stdenv.mkDerivation {
          name = "hello";
          src = hello.src;
          buildInputs = [ gcc ];
        };
      };

      nixosModules = {
        cloud-infra = import ./cloud-infra/default.nix;
        cloud-apps = import ./cloud-apps/default.nix;
        # Add other cloud app integrations here
      };

      nixosModule = { pkgs, ... }: {
        imports = [ devos.nixosModules.system ];
        networking.hostName = "my-nixos";
        environment.systemPackages = with pkgs; [ hello ];
      };

      defaultPackage.${system} = self.packages.${system}.hello;

      devShell.${system} = devshell.shell {
        packages = with pkgs; [ hello ];
      };

      nixosConfigurations = {
        nixnas0 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ({ pkgs, ... }: {
              system.stateVersion = "21.05";
            })
            ./devices/arm64/network/nixnas0/default.nix
          ];
        };
      };
    };
}