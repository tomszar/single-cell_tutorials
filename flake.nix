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

        # nixpkgs currently pairs quarto 1.9.37 with pandoc 3.7.0.2, but
        # quarto 1.9 emits a `syntax-highlighting` pandoc option that only
        # pandoc >= 3.8 understands, so `quarto render` dies with
        #   Aeson exception: Error in $: Unknown option "syntax-highlighting"
        # Pandoc 3.8 isn't in nixpkgs yet (even nixos-unstable still ships
        # 3.7.0.2). The quarto release tarball bundles the exact pandoc it was
        # built against (a statically linked pandoc 3.8.3) under
        # bin/tools/x86_64/pandoc; nixpkgs deletes it and substitutes its own.
        # Extract that bundled pandoc and hand it back to quarto so the two
        # match. Re-check whether this is still needed after a `nix flake
        # update` bumps quarto or pandoc.
        quartoBundledPandoc =
          pkgs.runCommandLocal "pandoc-quarto-${pkgs.quarto.version}"
            { meta.mainProgram = "pandoc"; }
            ''
              mkdir -p "$out/bin"
              tar -xzf ${pkgs.quarto.src} -C "$out/bin" --strip-components=4 \
                "quarto-${pkgs.quarto.version}/bin/tools/x86_64/pandoc"
              chmod +x "$out/bin/pandoc"
            '';

        quarto = pkgs.quarto.override { pandoc = quartoBundledPandoc; };

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
          # Tutorial 02 preprocessing: QC, normalization, feature selection,
          # and PCA/UMAP (uwot backs runUMAP).
          scuttle
          scran
          scater
          uwot
          # Tutorial 03b trajectory: fit a principal-curve pseudotime through
          # a lineage (bluster backs the graph clustering slingshot needs a
          # start cluster from).
          slingshot
          # slingshot Imports DelayedMatrixStats; BiocManager pulls it in
          # automatically for students, but Nix needs it listed explicitly.
          DelayedMatrixStats
          bluster
          # Tutorial 04 pseudobulk differential expression: count-based DE
          # (edgeR pulls in limma, but list it too for clarity). Tutorial 03a
          # only generates pseudobulk and does not need these.
          edgeR
          limma
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
            quarto
          ];
        };
      }
    );
}