{
  imports = [
    ./cloud-apps/media/default.nix
    ./cloud-apps/media/debrid/default.nix  # Importing debrid module
  ];
  
  description = "A Nix flake for pyBox media manager: a cloud storage seedbox (Powered by Wildland, GDrive and a Pi-NAS)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux = with nixpkgs; {
      pyBox-media-manager = python3.pkgs.buildPythonApplication {
        pname = "pyBox-media-manager";
        version = "0.1.0";
        src = ./src;  # Your source code directory
        propagatedBuildInputs = [ python3Packages.requests pkgs.debrid ];  # Adding debrid package to the build inputs
      };
    };

    nixosModules.pyBox-media-manager = { ... }: {
      imports = [ ./cloud-apps/media/debrid/default.nix ];  # Importing debrid module in the NixOS module
      # NixOS module definition here
    };

    nixosTests.pyBox-media-manager = { ... }: {
      # NixOS tests here
    };
  };
}
