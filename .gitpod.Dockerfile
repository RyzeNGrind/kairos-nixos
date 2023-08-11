FROM gitpod/workspace-base:latest

# Install Nix
ENV USER=gitpod
USER gitpod
RUN sudo sh -c 'mkdir -m 0755 /nix && chown gitpod /nix' \
  && touch .bash_profile \
  && curl https://nixos.org/releases/nix/nix-2.17.0/install | bash -s -- --no-daemon --no-channel-add

COPY gitpod.conf.nix /tmp
RUN echo 'source $HOME/.nix-profile/etc/profile.d/nix.sh' >> /home/gitpod/.bashrc.d/998-nix \
  && mkdir -p $HOME/.config/nixpkgs && echo '{ allowUnfree = true; }' >> $HOME/.config/nixpkgs/config.nix \
  && . $HOME/.nix-profile/etc/profile.d/nix.sh \
  #Enabled Nix Flakes
  && mkdir -p $HOME/.config/nix/ && printf 'experimental-features = nix-command flakes repl-flake\n' >> $HOME/.config/nix/nix.conf \
  && printf 'sandbox = false\n' >> $HOME/.config/nix/nix.conf \
  # Install cachix
  && nix-env -iA cachix -f https://cachix.org/api/v1/install \
  && cachix use cachix \
  # Install git, drenv
  && nix-env -f '<nixpkgs>' -iA git git-lfs direnv \
  # nixos-generate
  && nix-env -f https://github.com/nix-community/nixos-generators/archive/master.tar.gz -i \
  && (cd /tmp && nixos-generate -c ./gitpod.conf.nix -f vm-nogui -o ./dist) \
  # Direnv config
  && mkdir -p $HOME/.config/direnv \
  && printf '%s\n' '[whitelist]' 'prefix = [ "/workspace"] ' >> $HOME/.config/direnv/config.toml \
  && printf '%s\n' 'source <(direnv hook bash)' >> $HOME/.bashrc.d/999-direnv

# Install qemu
RUN sudo install-packages qemu qemu-system-x86 libguestfs-tools sshpass netcat
