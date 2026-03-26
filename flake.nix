{
  description = "Vardis Helm Charts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        helm = pkgs.wrapHelm pkgs.kubernetes-helm {
          plugins = [ pkgs.kubernetes-helmPlugins.helm-unittest ];
        };
      in
      with pkgs;
      {
        formatter = nixfmt;

        devShells.default = mkShell {
          buildInputs = [
            helm
            just
          ];
        };
      }
    );
}
