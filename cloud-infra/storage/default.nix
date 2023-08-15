{
  # This flake initializes Cloud Storage.
  # It checks if rclone has already mounted Google Drive as a local filesystem and uses Wildland to manage the files. 
  # If not, it initializes rclone, mounts Google Drive, and uses Wildland to manage the files.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    divnix.url = "github:divnix/std";
    divnix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, divnix }: 
    flake-utils.lib.eachDefaultSystem (system: 
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
        std = pkgs.stdenv.lib;
        rclone = pkgs.rclone;
        wildland-client = pkgs.wildland-client;
        mountPoint = "/mnt/gdrive";
      in
      rec {
        # The actual function
        initCloudStorageFn = { mountPoint, client_id, client_secret, root_folder_id, service_account_file, token }: pkgs.runCommand "init-cloud-storage" {} ''
          ${rclone}/bin/rclone config create gdrive drive client_id ${client_id} client_secret ${client_secret} scope drive root_folder_id ${root_folder_id} service_account_file ${service_account_file} token ${token}
          ${rclone}/bin/rclone mount gdrive: ${mountPoint} --daemon
          ${wildland-client}/bin/wildland-client setup
          ${wildland-client}/bin/wildland-client add-storage --container ${mountPoint} --backend-id gdrive
          ${wildland-client}/bin/wildland-client mount
        '';

        # A package with a default mount point
        packages.initCloudStorage = initCloudStorageFn { inherit mountPoint client_id client_secret root_folder_id service_account_file token; };

        # Optionally expose the function for users who want to specify a different mount point
        nixosModules.initCloudStorageWithMount = userMountPoint: {
          options = {
            services.initCloudStorage = {
              enable = lib.mkEnableOption "cloud storage service";
              mountPoint = lib.mkOption {
                type = lib.types.str;
                default = "/mnt/gdrive";
                description = "The mount point for the cloud storage service.";
              };
            };
          };
          config = {
            # Initialize cloud storage with user-specified mount point
            services.initCloudStorage = {
              enable = true;
              mountPoint = userMountPoint;
            };
            systemd.services.initCloudStorage = {
              wantedBy = [ "multi-user.target" ];
              script = ''
                ${packages.initCloudStorage}/bin/init-cloud-storage
              '';
            };
          };
        };
      }
    );
}