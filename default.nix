let
  pkgs = import <nixpkgs> {};

  hello = pkgs.writeShellScriptBin "hello" ''
    #!/bin/sh
    echo "Hello, World!"
  '';
in
{
  # This attribute set can be used to define multiple build jobs.
  # For example, you could have one job for each package in your project.
  buildJobs = {
    x86_64-linux = {
      combined = hello;
    };
/*     x86_64-darwin = {
      combined = hello;
    }; */
  };
}