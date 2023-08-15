{
  description = "A simple flake for a NixOS system";

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

      nixosModule = { pkgs, ... }: {
        imports = [ devos.nixosModules.system ];
        networking.hostName = "my-nixos";
        environment.systemPackages = with pkgs; [ hello ];
      };

      defaultPackage.${system} = self.packages.${system}.hello;

      devShell.${system} = devshell.shell {
        packages = with pkgs; [ hello ];
      };
    };
}