{
  nixnas0 =
    { config, pkgs, lib, ... }:
    {
      deployment.targetHost = "192.168.1.103";  # Replace with your machine's IP address
      deployment.targetUser = "root";  # Replace with your SSH username
      deployment.keyFile = "/path/to/your/private/key";  # Replace with the path to your private SSH key
    };
}