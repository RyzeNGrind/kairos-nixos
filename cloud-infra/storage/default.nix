{
  # This flake initializes Cloud Storage.
  # It checks if rclone has already mounted Google Drive as a local filesystem and uses Wildland to manage the files.
  # If not, it initializes rclone, mounts Google Drive, and uses Wildland to manage the files.
  imports = [
    ./cloud-infra/default.nix
    # Add other cloud app integrations here
  ];
    # Toggle for enabling/disabling cloud storage
  options = {
    services.cloudInfra.storage.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable or disable storage in cloud-infra";
    };
  };
  # Inputs for the flake, including pinned versions of dependencies
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05"; # Pin to a stable version for production
    flake-utils.url = "github:numtide/flake-utils";
    divnix.url = "github:divnix/std";
    divnix.inputs.nixpkgs.follows = "nixpkgs";
  };
  # Main logic for initializing cloud storage
  outputs = { self, nixpkgs, flake-utils, divnix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
        std = pkgs.stdenv.lib;
        rclone = pkgs.rclone;
        wildland-client = pkgs.wildland-client;
        mountPoint = "/mnt/gdrive";
        secrets = if builtins.pathExists ./secrets.nix then import ./secrets.nix else throw "Please provide a ./secrets.nix file or set the 1PASSWORD_ENV environment variable.";
        op-cli = if builtins.hasAttr "_1password" pkgs then pkgs._1password else throw "1pass-cli is not available in your nixpkgs. Please provide a secrets.nix file.";
        client_id = if builtins.hasAttr "client_id" secrets then secrets.client_id else throw "client_id is not available in your secrets. Please provide a secrets.nix file or set the 1PASSWORD_ENV environment variable.";
        client_secret = if builtins.hasAttr "client_secret" secrets then secrets.client_secret else throw "client_secret is not available in your secrets. Please provide a secrets.nix file or set the 1PASSWORD_ENV environment variable.";
        root_folder_id = if builtins.hasAttr "root_folder_id" secrets then secrets.root_folder_id else throw "root_folder_id is not available in your secrets. Please provide a secrets.nix file or set the 1PASSWORD_ENV environment variable.";
        service_account_file = if builtins.hasAttr "service_account_file" secrets then secrets.service_account_file else throw "service_account_file is not available in your secrets. Please provide a secrets.nix file or set the 1PASSWORD_ENV environment variable.";
        token = if builtins.hasAttr "token" secrets then secrets.token else throw "token is not available in your secrets. Please provide a secrets.nix file or set the 1PASSWORD_ENV environment variable.";
      in
      {
        # Function to initialize cloud storage with user-specified parameters
        initCloudStorageFn = { mountPoint, client_id, client_secret, root_folder_id, service_account_file, token }: pkgs.runCommand "init-cloud-storage" { } ''
          set -e # Exit on error
          export OP_SESSION_my=$(op signin my.1password.com --output=raw)
          export client_id=$(op get item clientidSecretName | jq -r '.details.fields[] | select(.name == "clientid").value')
          export client_secret=$(op get item clientsecretSecretName | jq -r '.details.fields[] | select(.name == "clientsecret").value')
          export root_folder_id=$(op get item rootfolderidSecretName | jq -r '.details.fields[] | select(.name == "rootfolderid").value')
          export service_account_file=$(op get item serviceaccountfileSecretName | jq -r '.details.fields[] | select(.name == "serviceaccountfile").value')
          export token=$(op get item tokenSecretName | jq -r '.details.fields[] | select(.name == "token").value')
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
              secretsFile = lib.mkOption {
                type = lib.types.path;
                default = secrets;
                description = "The path to the secrets file.";
              };
            };
          };
          config = lib.mkIf config.services.cloudInfra.storage.enable {
            # Initialize cloud storage with user-specified mount point
            services.initCloudStorage = {
              enable = true;
              mountPoint = userMountPoint;
              secretsFile = secrets;
            };
            # Systemd service configuration for initializing cloud storage on system startup
            systemd.services.initCloudStorage = {
              wantedBy = [ "multi-user.target" ];
              after = [ "network.target" ]; # Add dependencies
              requires = [ "network.target" ];
              restartTriggers = [ secrets ]; # Restart on failure
              script = ''
                ${packages.initCloudStorage}/bin/init-cloud-storage
              '';
            };
          };
        };
      }
    );
}
