let
  pkgs = import <nixpkgs> { };

  hello = pkgs.writeShellScriptBin "hello" ''
    #!/bin/sh
    echo "Hello, World!"
  '';
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    python3 # or any other dependencies you might need for pre-commit
    rustc
    pre-commit
    nixpkgs-fmt
    # ... other dependencies ...
  ];
}

