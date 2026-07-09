# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Hands-on tutorials for learning single-cell analysis in R, using data from the
Seattle Alzheimer's Disease Brain Cell Atlas (SEA-AD). The primary audience is
students; the material should also be understandable to a broader scientific
audience. Content is written as Quarto (`.qmd`) documents and published as a
Quarto website.

## Commands

```sh
quarto preview        # live-reload local preview of the website
quarto render          # build the static site (output goes to _site/, gitignored)
```

On NixOS (or any machine with Nix installed), `nix develop` (or `direnv
allow`, since `.envrc` runs `use flake`) drops you into a shell with R,
Quarto, and the packages tutorials currently need (tidyverse, BiocManager,
rhdf5, SingleCellExperiment, Matrix, schard) already built — this sidesteps
`install.packages`, which doesn't work out of the box on NixOS. `flake.nix`
is a convenience for Nix users only; it is not the canonical dependency list.
When a tutorial's setup step starts requiring a new package, add it to
`flake.nix`'s `rEnv` package list too so the two stay in sync.

There is no package manager manifest (e.g. `renv`) yet — R package
dependencies are installed ad hoc via `install.packages` / `BiocManager` /
`remotes` inside the tutorial `.qmd` files themselves. When adding a tutorial,
document its package requirements in its own setup step rather than in a
central file.

There are no automated tests. "Correctness" for a tutorial means: it renders
cleanly and runs top-to-bottom in a clean R session without hidden state.
Before considering a tutorial complete, actually run its code chunks in a
fresh R session (not just visually inspect them).

## Architecture

- `_quarto.yml` — site config (nav, HTML format options, `execute: freeze: auto`).
  Every new tutorial directory must be added to the `navbar` here or it won't
  appear on the site.
- `index.qmd` — landing page; links to each tutorial. Update alongside `_quarto.yml`
  when adding a tutorial.
- `tutorials/NN-slug/index.qmd` — one directory per tutorial, numeric prefix
  controls ordering, slug is the readable/descriptive part. Each has its own
  `images/` subdirectory for figures referenced by that tutorial only.
- `R/helpers.R` — shared helper functions intended for reuse across tutorials
  (currently empty/placeholder).
- `data/` — everything except `README.md` and `data/example/` is gitignored.
  `data/example/` is for small, redistributable derived data checked into the
  repo; full/raw SEA-AD downloads must never be committed (see Data rules
  below). `data/README.md` documents access/provenance/licensing per dataset.
- `outputs/` — generated analysis outputs; gitignored except `.gitkeep`. Do not
  commit generated artifacts here.

Downloaded SEA-AD data lives in the shared `data/` folder (e.g.
`data/sea-ad/donor_H20.33.001.h5ad`), not in individual tutorial directories.
This is the canonical home so a file downloaded once can be reused across
tutorials (tutorials 01 and 02 both read the same donor file from there).
Tutorials set the R working directory to their own folder ("Set Working
Directory > To Source File Location" in RStudio) and reach the data with a
relative path from there (`../../data/sea-ad/...`). There is still no central
data-loading module — each tutorial repeats the load step explicitly so it
remains a standalone, runnable notebook; only the file's location is shared.

## Writing and content rules

These come from `AGENTS.md` and apply to any tutorial content you write or edit:

- Write in R; use Quarto (`.qmd`), not legacy R Markdown (`.Rmd`).
- Tutorials must be interactive/notebook-style: readers run code, inspect
  intermediate results, and modify parameters. Keep code cells self-contained
  enough to support that iterative workflow.
- Introduce concepts and biological questions before specialized terminology
  — explain the *why* (biology), not just the *how* (code).
- State learning objectives, prerequisites, and expected outcomes per tutorial.
- Use realistic SEA-AD examples, but keep runtimes practical for a class
  (e.g. tutorial 01 deliberately uses a single donor file instead of the
  ~35 GB all-cohort file, both for runtime and to avoid a known
  integer-overflow limitation when reading very large `.h5ad` files this way).
- Distinguish required vs. optional/advanced exercises.
- Design for student autonomy: fully scaffold the mechanical plumbing (loading,
  QC, aggregation, tool syntax) but leave the *scientific* decisions —
  cohort/experimental design, the contrast, cell-type choice, confounders,
  interpretation — to the reader. Ending at a genuine open question (including a
  null result) is an honest, valuable endpoint, not a failure to fix.
- Split an expensive generation step from the analysis it feeds: have the costly
  step (e.g. loading many large donor files) save a small object that the
  analysis loads, so readers can iterate on the science quickly. This is why the
  pseudobulk track is 03a (generation) + 04 (differential expression).
- Set random seeds for anything depending on randomness.
- Prefer small, readable analysis steps over dense pipelines; comment on
  reasoning, not on syntax that's already obvious.
- Treat warnings and changed package behavior explicitly rather than
  suppressing them, unless the tutorial explains why it's safe to do so.
- Never commit restricted SEA-AD data, credentials, tokens, or large
  generated artifacts — rely on the `.gitignore` rules for `data/` and
  `outputs/`, and document access instructions in `data/README.md` instead.

## Data access pattern (SEA-AD)

Per-donor RNA-seq `.h5ad` files are downloaded manually from the public
SEA-AD S3 browser (no account/CLI needed) under `PFC/RNAseq/` (prefrontal
cortex / DLPFC) or `MTG/RNAseq/` (middle temporal gyrus), and are read into R
via `schard::h5ad2sce()` (pure R, no Python dependency), which returns a
Bioconductor `SingleCellExperiment` object. This is the established pattern
for any future tutorial that needs to load SEA-AD single-cell data.