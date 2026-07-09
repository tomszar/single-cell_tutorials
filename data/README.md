# Data

Data access instructions, provenance, licensing constraints, and dataset
versions will be documented here.

Downloaded SEA-AD data should not be committed to the repository. Small,
redistributable files used by the tutorials may be placed in `example/`.

## Layout

- `sea-ad/` — downloaded SEA-AD single-cell files (git-ignored). Tutorials read
  from here; for example, tutorial 01 downloads
  `sea-ad/donor_H20.33.001.h5ad` and tutorial 02 reuses the same file. See the
  download instructions in `tutorials/01-read-h5ad/`.

  Tutorial 03a (pseudobulk generation) reuses that same single donor
  (`H20.33.001`). Its closing scale-up exercise—and the planned tutorial 04
  (pseudobulk differential expression)—use a larger, balanced multi-donor PFC
  cohort assembled from `PFC/RNAseq/donors_objects/` (saved as
  `sea-ad/donor_<ID>.h5ad`), chosen from the donor metadata CSV
  `PFC/RNAseq/SEAAD_DFC_RNAseq_final-nuclei_metadata.<date>.csv` to balance sex
  and match age/PMI/RIN across pathology groups. All files are the public
  `..._SEAAD_DFC_RNAseq_final-nuclei.<date>.h5ad` per-donor objects; a 20-donor
  cohort is ~11 GB, git-ignored.
- `example/` — small, redistributable derived data checked into the repo.
