{
  description = "Vardis Helm Charts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        helm = pkgs.wrapHelm pkgs.kubernetes-helm {
          plugins = [ pkgs.kubernetes-helmPlugins.helm-unittest ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            helm
            pkgs.just
          ];
        };
      }
    );
}
