{ config, pkgs, ... }:
{
  # Enable and configure Tailscale
  services.tailscale = {
    enable = true;
    #advertiseRoutes = [ "10.0.0.0/24" "10.0.1.0/24" ];
  };

  # Enable and configure ZeroTier
  services.zerotierone = {
    enable = true;
    #joinNetworks = [ "your-network-id" ];
  };

  # Add your cloudflared configuration here
  services.cloudflared = {
    enable = true;
    config = let
      cloudflaredInstalled = pkgs ? cloudflared;
      token = if cloudflaredInstalled then pkgs._1password.op read k8s-lab live-nixos-tunnel config token else "";
    in
    ''
      ${if cloudflaredInstalled then "sudo cloudflared service install " + token else ""}
      tunnel: ${pkgs._1password.op read k8s-lab live-nixos-tunnel config tunnel}
      credentials-file: ${pkgs._1password.op read k8s-lab live-nixos-tunnel config <field>}
      ingress:
        - hostname: ${pkgs._1password.op read k8s-lab live-nixos-tunnel config <field>}
          service: ${pkgs._1password.op read k8s-lab live-nixos-tunnel config <field>}
    '';
  };
}