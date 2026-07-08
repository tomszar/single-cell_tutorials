# Roadmap

Planned sequence for the SEA-AD single-cell tutorial series. This file records
*intent and ordering*; it is not a spec. Each tutorial's authoritative content
lives in its own `tutorials/NN-slug/index.qmd`. Update this file when the plan
changes, and keep `_quarto.yml` and `index.qmd` in sync as tutorials land.

Conventions (see `CLAUDE.md` / `AGENTS.md`): one directory per tutorial with a
numeric prefix, written in R as Quarto `.qmd`, notebook-style and runnable
top-to-bottom in a clean session, using a single-donor SEA-AD file to keep
runtimes practical for a class.

## Status

| # | Tutorial | Status |
|---|----------|--------|
| 00 | Setup — install R, RStudio, Quarto, Git; run a notebook | Done |
| 01 | Read H5AD — load one donor into a `SingleCellExperiment`, locate metadata | Done |
| 02 | Preprocessing — QC, normalization, feature selection, dimensionality reduction | Done |
| 03a | Pseudobulk track | Planned |
| 03b | Trajectory track | Planned |

Tutorials 00 and 01 both load data and orient the reader in the SCE. The two
analysis tracks named at the end of tutorial 01 (pseudobulk, trajectory) both
assume a clean, normalized object. Tutorial 02 produces it and is the shared
prerequisite for both tracks.

## 02 — Preprocessing

Take the raw single-donor `SingleCellExperiment` from tutorial 01 and turn it
into a QC'd, normalized object with reduced dimensions, ready for downstream
analysis. Stay on one donor so it runs in a class session.

**Learning objectives**

- Understand *why* single-cell data needs QC and normalization before analysis.
- Compute and interpret per-cell QC metrics; filter low-quality cells with
  thresholds the reader can justify rather than accept blindly.
- Normalize counts and select highly variable genes.
- Reduce dimensionality (PCA → UMAP) and read the resulting embedding.

**Prerequisites:** tutorials 00 and 01; a loaded single-donor SCE.

**Outline**

1. QC metrics — library size, genes detected, % mitochondrial reads
   (`scater` / `scuttle`).
2. Filtering low-quality cells, with explicit, defended thresholds (and a note
   on fixed vs. adaptive/MAD-based cutoffs).
3. Normalization — log-normalization, with `scran` pooling shown as the
   principled alternative.
4. Highly variable gene selection.
5. Dimensionality reduction — PCA, then UMAP; set a seed for UMAP.

**Package requirements (document in the tutorial's setup step):** `scater`,
`scuttle`, `scran`, `SingleCellExperiment` (and its UMAP dependency, e.g.
`uwot`). Add any new package to `flake.nix`'s `rEnv` list too.

**Expected outcome:** a filtered, normalized SCE carrying `logcounts`, a set of
highly variable genes, and `PCA` / `UMAP` in `reducedDims()`.

## After 02: the two tracks

Both start from the tutorial-02 output and can be written in either order.

### 03a — Pseudobulk track

Repeat loading across multiple donors, aggregate counts per donor × cell type
into pseudobulk profiles, and run a donor-level differential expression
comparison across AD pathology. Emphasize why pseudobulk (donor as the unit of
replication) is the statistically honest approach for cross-condition
comparisons, versus per-cell tests.

*Sketch:* multi-donor loading → per-donor/per-subclass aggregation
(`aggregateAcrossCells`) → DE with an established bulk method (e.g. `edgeR` /
`limma-voom`). Package and data requirements to be pinned when drafted.

### 03b — Trajectory track

On a single chosen cell type, use the PCA/UMAP from tutorial 02 to fit a
`slingshot` trajectory, anchoring it in low-pathology cells, and interpret the
inferred progression against the pathology axis.

*Sketch:* subset one cell type → embedding from tutorial 02 → `slingshot`
lineage/pseudotime with a defined starting cluster → interpret against the
continuous pathology score. Package and data requirements to be pinned when
drafted.

## Open questions

- Whether feature selection + dimensionality reduction stay in 02 or split into
  their own tutorial if 02 gets too long for one session.
