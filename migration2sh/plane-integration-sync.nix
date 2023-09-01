{
  description = "A Nix Flake for syncing Jira, GitHub, and Plane";

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.sync = nixpkgs.stdenv.mkDerivation rec {
      pname = "sync-script";
      version = "1.0.0";
      src = ./sync-script.sh;

      buildInputs = with nixpkgs; [
        curl
        jq
      ];

      installPhase = ''
        mkdir -p $out/bin
        cp $src $out/bin/sync-script
        chmod +x $out/bin/sync-script
      '';

      meta = with nixpkgs.lib; {
        description = "A script to sync Jira, GitHub, and Plane";
        homepage = "https://github.com/RyzeNGrind/kairos-nixos";
        license = licenses.mit;
        maintainers = with maintainers; [ ];
      };
    };
  };
}
