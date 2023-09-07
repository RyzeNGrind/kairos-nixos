{ config, pkgs, ... }:
{
  # Add your cloudflared configuration here
  # Example:
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