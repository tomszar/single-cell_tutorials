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
| 03b | Trajectory track                                                               | Planned |
| 04  | Pseudobulk — differential expression across AD pathology                        | Planned |

Tutorials 00 and 01 both load data and orient the reader in the SCE. The two
analysis tracks named at the end of tutorial 01 (pseudobulk, trajectory) both
assume a clean, normalized object. Tutorial 02 produces it and is the shared
prerequisite for both tracks.

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

### 04 — Pseudobulk differential expression (Planned)

Take the stacked multi-donor pseudobulk (the 03a scale-up exercise), pick a cell
type, and run an `edgeR` quasi-likelihood test for genes that change between low-
and high-pathology donors, adjusting for sex. Structured as **core demo → open
extensions** so students own the scientific decisions (cell type, contrast,
covariates, interpretation), not just parameter tweaks.

_Sketch:_ load cohort pseudobulk → filter (`filterByExpr`) / TMM
(`calcNormFactors`) / `glmQLFit` + `glmQLFTest` → `topTags` / `decideTests`,
MA/volcano → interpret with caveats.

**Key finding to design around (already tested on a 20-donor PFC cohort):** a
class-scale binary ADNC contrast yields **no genome-wide-significant genes in any
cell type** — confirmed across binary low/high, extremes (`Not AD` vs `High`),
and Braak-stage-as-continuous designs (closest was Pvalb interneurons, min FDR
≈ 0.05). This is expected — SEA-AD's own significant hits lean on MTG, the full
84-donor cohort, and their continuous pseudo-progression score. So tutorial 04
should **treat the null as the payoff**, not a bug: the honest lesson is that
class-sized cohorts are underpowered, and the open extensions (more donors, MTG
vs PFC, a continuous severity score, interpreting near-hits) are where students
go looking for signal.

**Data-handoff decision (open):** the full 20-donor pseudobulk object is only
~27 MB as an RDS, small enough to commit to `data/example/` so tutorial 04 runs
top-to-bottom without the ~11 GB download. For now we are **not** committing it;
revisit when 04 is drafted (commit the object vs. have 04's setup regenerate it
from the 03a scale-up loop).

**Cohort used for the above test (a candidate 03a-scale-up answer key):** 20 PFC
donors, 10 low / 10 high ADNC, 5 F + 5 M per group, all RIN ≥ 8.3, focus cell
type astrocyte (min ~140 nuclei/donor). Residual confound: ~9-year age gap
(low median 82.5 vs high 91.5), which 04 can address by adding age to the model.

### 03b — Trajectory track

On a single chosen cell type, use the PCA/UMAP from tutorial 02 to fit a
`slingshot` trajectory, anchoring it in low-pathology cells, and interpret the
inferred progression against the pathology axis.

_Sketch:_ subset one cell type → embedding from tutorial 02 → `slingshot`
lineage/pseudotime with a defined starting cluster → interpret against the
continuous pathology score. Package and data requirements to be pinned when
drafted.

## Open questions

- Whether feature selection + dimensionality reduction stay in 02 or split into
  their own tutorial if 02 gets too long for one session.
