{
  description = "A simple flake for managing devices";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devos.url = "github:divnix/devos";
    devshell.url = "github:numtide/devshell";
    std.url = "github:divnix/std";
    liminix.url = "github:liminix/liminix";
  };

  outputs = { self, nixpkgs, flake-utils, devos, devshell, std, liminix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; overlays = [ self.overlay ]; };
    in
    {
      overlay = final: prev: {
        hello = with final; stdenv.mkDerivation {
          name = "hello";
        };
      };

      defaultPackage.${system} = self.packages.${system}.hello;

      devShell.${system} = devshell.shell {
        packages = with pkgs; [ hello ];
      };
    };
}
