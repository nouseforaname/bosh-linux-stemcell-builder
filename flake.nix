{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils}:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [  ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
          # new! 👇
          nativeBuildInputs = with pkgs; [ 
            go
            ruby
            solargraph
            debootstrap
            proot
            qemu-user
          ];
          buildInputs = with pkgs; [ 
            openssl
  
          ];
        in
        with pkgs;
        {
          devShells.default = mkShell {
            inherit buildInputs nativeBuildInputs;
          };
        }
      );
}
