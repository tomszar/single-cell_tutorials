{
  description = "R + Quarto dev environment for the single-cell tutorials";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        # Not on CRAN/Bioconductor; pulled straight from its GitHub repo, the
        # same source the tutorials point to via `remotes::install_github()`.
        schard = pkgs.rPackages.buildRPackage {
          name = "schard";
          src = pkgs.fetchFromGitHub {
            owner = "cellgeni";
            repo = "schard";
            rev = "4bd52b4ff01447fd48919f2b43ca6039d25e54c6";
            hash = "sha256-RgX1zMp3+eWwaBvl7PzvwPQdbuBxPJJu1BVC7sPt6ZI=";
          };
          propagatedBuildInputs = with pkgs.rPackages; [
            Matrix
            rhdf5
            SingleCellExperiment
          ];
        };

        rEnv = pkgs.rWrapper.override {
          packages = with pkgs.rPackages; [
            tidyverse
            BiocManager
            rhdf5
            SingleCellExperiment
            Matrix
            schard
          ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            rEnv
            pkgs.quarto
          ];
        };
      }
    );
}