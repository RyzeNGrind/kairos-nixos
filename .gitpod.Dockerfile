FROM gitpod/workspace-nix:2023-08-10-20-37-08
USER gitpod

# Pin the Nix Channel
ENV NIXPKGS_MASTER=https://github.com/NixOS/nixpkgs/archive/master.tar.gz
ENV NIXPKGS_COMMIT_TAG=23.05
ENV NIXPKGS_URL=https://github.com/NixOS/nixpkgs/archive/refs/tags/${NIXPKGS_COMMIT_TAG}.tar.gz
ENV NIX_PATH nixpkgs=${NIXPKGS_URL}
# Copy the Nix configuration file and the helper script
COPY gitpod.conf.nix /tmp
COPY nix_run.sh /home/gitpod/
# Configure Nix
RUN /home/gitpod/nix_run.sh echo 'source $HOME/.nix-profile/etc/profile.d/nix.sh' >> /home/gitpod/.bashrc.d/998-nix \
  && /home/gitpod/nix_run.sh mkdir -p $HOME/.config/nixpkgs $HOME/.config/nix $HOME/.config/direnv \
  && echo '{ allowUnfree = true; }' > $HOME/.config/nixpkgs/config.nix \
  && /home/gitpod/nix_run.sh printf 'experimental-features = nix-command flakes \nsandbox = false\n' >> $HOME/.config/nix/nix.conf \
    # Install cachix
  && /home/gitpod/nix_run.sh nix-env -iA cachix -f https://cachix.org/api/v1/install \
  && /home/gitpod/nix_run.sh cachix use cachix
# Set Nix to not add any channels
RUN /home/gitpod/nix_run.sh nix-env -iA nixpkgs.nix --option no-channel-add
# More stable packages
RUN /home/gitpod/nix_run.sh nix-env -I ${NIX_PATH} -f ${NIXPKGS_URL} -iA \
  git \
  git-lfs \
  direnv \
  nix-linter \
  rustc

# Packages that might change more often
RUN /home/gitpod/nix_run.sh nix-env -I ${NIX_PATH} -f ${NIXPKGS_URL} -iA \
  nixops_Unstable \
  nixops-dns \
  nixpkgs-fmt \
  pre-commit

# Security or sensitive tools
RUN /home/gitpod/nix_run.sh nix-env -I ${NIX_PATH} -f ${NIXPKGS_URL} -iA \
  _1password \
  git-credential-1password

  # nixos-generate
RUN /home/gitpod/nix_run.sh nix-env -f https://github.com/nix-community/nixos-generators/archive/master.tar.gz -i \
  && /home/gitpod/nix_run.sh (cd /tmp && nixos-generate -c ./gitpod.conf.nix -f vm-nogui -o ./dist) \
  # Direnv config
  && /home/gitpod/nix_run.sh printf '%s\n' '[whitelist]' 'prefix = [ "/workspace"] ' >> $HOME/.config/direnv/config.toml \
  && /home/gitpod/nix_run.sh printf '%s\n' 'source <(direnv hook bash)' >> $HOME/.bashrc.d/999-direnv
# Install qemu
RUN sudo install-packages qemu qemu-system-x86 libguestfs-tools sshpass netcat
