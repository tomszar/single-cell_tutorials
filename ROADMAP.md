# Roadmap

Planned sequence for the SEA-AD single-cell tutorial series. This file records
_intent and ordering_; it is not a spec. Each tutorial's authoritative content
lives in its own `tutorials/NN-slug/index.qmd`. Update this file when the plan
changes, and keep `_quarto.yml` and `index.qmd` in sync as tutorials land.

Conventions (see `CLAUDE.md` / `AGENTS.md`): one directory per tutorial with a
numeric prefix, written in R as Quarto `.qmd`, notebook-style and runnable
top-to-bottom in a clean session, using a single-donor SEA-AD file to keep
runtimes practical for a class.

## Status

| #   | Tutorial                                                                       | Status  |
| --- | ------------------------------------------------------------------------------ | ------- |
| 00  | Setup — install R, RStudio, Quarto, Git; run a notebook                        | Done    |
| 01  | Read H5AD — load one donor into a `SingleCellExperiment`, locate metadata      | Done    |
| 02  | Preprocessing — QC, normalization, feature selection, dimensionality reduction | Done    |
| 03a | Pseudobulk — generation (aggregate one donor's cells to per-cell-type profiles) | Done    |
| 03b | Trajectory track — pseudotime through one donor's oligodendrocyte lineage      | Done    |
| 04  | Pseudobulk — differential expression across AD pathology                        | Done    |

Tutorial 00 sets up the toolchain; tutorial 01 loads data and orients the reader
in the SCE. The two analysis tracks named at the end of tutorial 01 (pseudobulk,
trajectory) both assume a clean, normalized object. Tutorial 02 produces it and
is the shared prerequisite for both tracks.

## 02 — Preprocessing

Take the raw single-donor `SingleCellExperiment` from tutorial 01 and turn it
into a QC'd, normalized object with reduced dimensions, ready for downstream
analysis. Stay on one donor so it runs in a class session.

**Learning objectives**

- Understand _why_ single-cell data needs QC and normalization before analysis.
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

The trajectory track starts from the tutorial-02 embedding; the pseudobulk track
reuses tutorial 02's QC *logic* but works from raw counts, not its normalized
object. They can be written in either order.

The pseudobulk track is split into two tutorials, so the fiddly, fully-scaffolded
plumbing (generation) is separated from the open-ended analysis (DE). This keeps
each concept self-contained and — because DE runs off a small saved pseudobulk
object rather than the ~11 GB of raw donor files — lets students iterate on the
analysis (cell type, contrast, model) in seconds instead of re-loading everything.

### 03a — Pseudobulk generation (Done)

Aggregate **one** donor's single cells into per-cell-type pseudobulk profiles.
Deliberately single-donor: it reuses the donor already downloaded in tutorial 01
(`H20.33.001`), runs in ~a minute, and produces a clean, always-working
deliverable (a genes × cell-type count table). The core teaching point is the
unit of replication / pseudoreplication argument that motivates summing to the
donor level. Scaling the same step across a whole cohort is posed as the closing
autonomous exercise (choose a balanced cohort from the SEA-AD donor metadata,
loop `load_donor` + `aggregateAcrossCells`, `cbind` on common genes) — that
cohort matrix is the input to tutorial 04.

_Built:_ `schard` load + tutorial-02 QC wrapped in `load_donor` → per-`Subclass`
aggregation (`aggregateAcrossCells`) → save to `outputs/`. Packages: `schard`,
`SingleCellExperiment`, `scuttle` (no `edgeR` here).

### 04 — Pseudobulk differential expression (Done)

Take the stacked multi-donor pseudobulk (the 03a scale-up exercise), pick a cell
type, and run an `edgeR` quasi-likelihood test for genes that change between low-
and high-pathology donors, adjusting for sex. Structured as **core demo → open
extensions** so students own the scientific decisions (cell type, contrast,
covariates, interpretation), not just parameter tweaks.

_Built:_ load cohort pseudobulk → pick cell type + `ncells >= 10` filter → binary
low/high ADNC contrast with a sex-adjusted design → `filterByExpr` / TMM
(`normLibSizes`, the current name for `calcNormFactors`) / `estimateDisp` /
`glmQLFit` + `glmQLFTest` → `topTags` / `decideTests`, MA + volcano → **null as
the payoff** → frontier extensions (more donors, continuous severity, age,
MTG vs PFC, reading near-misses). Packages: `edgeR` (+ `limma`),
`SingleCellExperiment`.

**The null was re-confirmed when 04 was drafted** on the committed 20-donor PFC
cohort: astrocyte, `Immune` (microglia), and `Pvalb` all give **min FDR = 1, zero
genes at FDR < 0.05** under the binary contrast; top-ranked astrocyte genes are
unannotated loci with no coherent biology (a textbook null). Diagnostics were
clean (balanced 5F+5M × 10 low/10 high, norm factors 0.86–1.13). Expected —
SEA-AD's own hits lean on MTG, the full 84-donor cohort, and their continuous
pseudo-progression score; the tutorial treats the null as the honest lesson that
class-sized cohorts are underpowered. (The Pvalb near-hit, min FDR ≈ 0.05, was
under a *continuous Braak* design, not this binary one — posed in 04 as the
"use the gradient" frontier lever.)

**Data-handoff decision (resolved — hybrid):** 04 loads the reader's own
`outputs/pseudobulk_cohort.rds` (the 03a scale-up output) as the headline path,
and a committed ~28 MB copy at `data/example/pseudobulk_cohort.rds` is the
fallback so 04 runs top-to-bottom without the ~11 GB download. The committed
object is genes × donor-cell-type summed UMI counts, derived purely from public
per-donor `.h5ad` files (documented in `data/README.md`).

**Cohort committed (the 03a-scale-up answer key):** 20 PFC donors, 10 low / 10
high ADNC, 5 F + 5 M per group, all RIN ≥ 8.3; demo cell type astrocyte. Residual
confound: ~9-year age gap, which 04's frontier addresses by adding age to the
model.

### 03b — Trajectory track (Done)

Fit a pseudotime through the **oligodendrocyte lineage** (OPCs → mature
oligodendrocytes) of the single donor from tutorials 01–02, reloading the
preprocessed object saved at the end of tutorial 02. The teaching point is a
continuous process *within* one cell type, as the deliberate contrast to 03a's
discrete group comparison — and that pseudotime's **direction is imposed, not
discovered**, so the reader must supply the biology (marker genes) that says
which end is the start.

_Built:_ reload `outputs/sce_preprocessed.rds` → subset the OPC + oligodendrocyte
lineage → **re-embed the lineage on its own** (its own HVGs/PCA/UMAP, because the
global embedding is the wrong space for within-lineage structure) → cluster and
pick a start cluster from an OPC marker → `slingshot` lineage/pseudotime →
rank genes by Spearman correlation with pseudotime (myelin genes rise, OPC genes
fall) → save to `outputs/`. Packages: `slingshot` (plus the tutorial-02 stack).
The pathology comparison is posed as the closing frontier exercise, not the core.

## Open questions

- Whether feature selection + dimensionality reduction stay in 02 or split into
  their own tutorial if 02 gets too long for one session.
