FROM gitpod/workspace-nix:2023-08-10-20-37-08
USER gitpod
# Remove all channels
RUN nix-channel --remove nixpkgs
# Set Nix to not add any channels
RUN nix-env -iA nixpkgs.nix --option no-channel-add
# Pin the Nix Channel
ENV NIXPKGS_MASTER=https://github.com/NixOS/nixpkgs/archive/master.tar.gz
ENV NIXPKGS_COMMIT_TAG=23.05
ENV NIXPKGS_URL=https://github.com/NixOS/nixpkgs/archive/refs/tags/${NIXPKGS_COMMIT_TAG}.tar.gz
ENV NIX_PATH nixpkgs=${NIXPKGS_URL}
# Copy the Nix configuration file
COPY gitpod.conf.nix /tmp
# Configure Nix
RUN echo 'source $HOME/.nix-profile/etc/profile.d/nix.sh' >> /home/gitpod/.bashrc.d/998-nix \
  && mkdir -p $HOME/.config/nixpkgs $HOME/.config/nix $HOME/.config/direnv \
  && echo '{ allowUnfree = true; }' >> $HOME/.config/nixpkgs/config.nix \
  && printf 'experimental-features = nix-command flakes \nsandbox = false\n' >> $HOME/.config/nix/nix.conf \
  # Install cachix, git, direnv, nixos-generate
  && nix-env -iA cachix -f https://cachix.org/api/v1/install nixpkgs.git nixpkgs.git-lfs nixpkgs.direnv -f https://github.com/nix-community/nixos-generators/archive/master.tar.gz \
  && cachix use cachix \
  && (cd /tmp && nixos-generate -c ./gitpod.conf.nix -f vm-nogui -o ./dist) \
  # Direnv config
  && printf '%s\n' '[whitelist]' 'prefix = [ "/workspace"] ' >> $HOME/.config/direnv/config.toml \
  && printf '%s\n' 'source <(direnv hook bash)' >> $HOME/.bashrc.d/999-direnv
# Install qemu
RUN sudo install-packages qemu qemu-system-x86 libguestfs-tools sshpass netcat