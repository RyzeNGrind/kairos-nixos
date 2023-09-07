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
    config = ''
      tunnel: ${pkgs._1password.op read <vault> <item> <section> <field>}
      credentials-file: ${pkgs._1password.op read <vault> <item> <section> <field>}
      ingress:
        - hostname: ${pkgs._1password.op read <vault> <item> <section> <field>}
          service: ${pkgs._1password.op read <vault> <item> <section> <field>}
    '';
  };
}