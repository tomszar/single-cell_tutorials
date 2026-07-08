{
  description = "R + Quarto dev environment for the single-cell tutorials";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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

        # Single source of truth for the R packages, shared by the plain-R
        # and RStudio wrappers below so the two can't drift apart.
        rPkgs = with pkgs.rPackages; [
          tidyverse
          BiocManager
          rhdf5
          SingleCellExperiment
          Matrix
          schard
        ];

        rEnv = pkgs.rWrapper.override { packages = rPkgs; };

        # rstudioWrapper is the RStudio-specific counterpart to rWrapper: it
        # bundles the same R packages so RStudio finds them natively, without
        # any RSTUDIO_WHICH_R / R_LIBS_SITE juggling. Launch `rstudio` from
        # inside this shell (not the desktop app launcher, which is the
        # unwrapped system RStudio).
        rstudioEnv = pkgs.rstudioWrapper.override { packages = rPkgs; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            rEnv
            rstudioEnv
            pkgs.quarto
          ];
        };
      }
    );
}