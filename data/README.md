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
- `example/` — small, redistributable derived data checked into the repo.
