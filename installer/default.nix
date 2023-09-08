{
  description = "My NixOS liveUSB installer with custom cfg";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # Add other inputs as needed
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      systems = [ "x86_64-linux" ];  # Replace with your target system
    in
    flake-utils.lib.eachDefaultSystem systems (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        nixosConfigurations = {
          installer = pkgs.lib.nixosSystem {
            system = system;
            modules = [
              # Add other modules as needed
              ({ config, pkgs, ... }: {
                # Add the overlay patch to fix https://github.com/NixOS/nix/issues/3271#issuecomment-922263815
                nixpkgs.overlays.default = [
                  (self: super: {
                    nixUnstable = super.nixUnstable.override {
                      patches = [ ./unset-is-mach0.patch ];
                    };
                  })
                ];
                # Call the script before the config for tunnels are created
                system.activationScripts.checkCreateTunnel = { text = ''
                  ${pkgs.bash}/bin/bash ${./installer/tunnels/precreate-check_tunnel-op.sh}
                ''; };
                imports = [
                  # Add other imports as needed
                  ./installer/tunnels/config.nix
                ];
                # Configure SSH settings
                services.openssh.enable = true;
                services.openssh.permitRootLogin = "yes";
                services.openssh.passwordAuthentication = true;
                # Add other SSH configurations as needed
                
                # Add cloudflared and other git-ops relevant tools to the system packages
                environment.systemPackages = with pkgs; [
                  cloudflared
                  tailscale
                  zerotierone
                  _1password
                  git-credential-1password
                  nixFlakes
                  #nixops_unstable
                  #nixops-dns
                  nixpkgs-fmt
                  #nix-linter
                  pre-commit
                  rustc
                  curl
                  gitAndTools.gitFull
                  htop
                  sudo
                  tmux
                ];
              })
            ];
          };
        };
      });
}