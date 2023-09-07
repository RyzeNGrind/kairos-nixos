#!/bin/bash

# Load 1Password secrets
#export OP_SESSION_my="$(op signin my.1password.com --output=raw)"
if ! op signin my.1password.com --output=raw; then
  echo "Failed to sign in to 1Password."
  exit 1
fi

 # Check if the tunnel exists in 1Password
 tunnel_name=$(op get item 'Cloudflared Tunnel' | jq -r '.details.sections[] | select(.title=="tunnel") | .fields[] | select(.t=="name") | .v')

 # Check if the tunnel exists in Cloudflare
 cloudflare_tunnels=$(cloudflared tunnel list --json | jq -r '.[] | .name')
 if [[ $cloudflare_tunnels =~ $tunnel_name ]]; then
   echo "Tunnel already exists in Cloudflare"
 else
   echo "Tunnel does not exist in Cloudflare"
 fi

# If the tunnel doesn't exist, create a new one with an iterated pattern
if [ -z "$tunnel_name" ]; then
  # Generate a new tunnel name with an iterated pattern
  new_tunnel_name="live-nix-iso_$(date +%s)"  # This uses the current timestamp for iteration

  # Store the new tunnel name in 1Password with a tag
  op create item Login title='Cloudflared Tunnel' username="$new_tunnel_name" password='dummy' url='https://cloudflared.com' --tags="tname:$new_tunnel_name,cloudflare,opsec,hw-infra,network:vlan5,env:dev"
fi