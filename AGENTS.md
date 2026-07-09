# Repository guidance

## Purpose

This repository contains a series of hands-on tutorials for single-cell
analysis using data from the Seattle Alzheimer's Disease Brain Cell Atlas
(SEA-AD).

The primary audience is students learning single-cell analysis. The material
should also be useful and understandable to a broader scientific audience.

## Tutorial format

- Write tutorials in R.
- Prefer Quarto (`.qmd`) documents as the source format.
- Make tutorials interactive: readers should be able to run code, inspect
  intermediate results, modify parameters, and reproduce the analysis.
- Render tutorials to HTML for distribution and browser-based reading.
- Keep source files compatible with RStudio.
- Keep code cells self-contained enough to support an iterative,
  notebook-style workflow.

Quarto is preferred over legacy R Markdown (`.Rmd`) because it provides a
modern publishing workflow while retaining R and `knitr` support. Quarto
files are plain text and can be edited in JupyterLab, although notebook-style
cell execution in JupyterLab may require Quarto/Jupyter extensions and an R
kernel. If native execution in both RStudio and JupyterLab becomes a strict
requirement, evaluate R-based Jupyter notebooks (`.ipynb`) separately rather
than duplicating every tutorial.

## Writing principles

- Introduce concepts before using specialized terminology.
- Explain the biological question as well as the computational operation.
- State learning objectives, prerequisites, and expected outcomes.
- Use realistic SEA-AD examples while keeping runtimes practical for a class.
- Distinguish required exercises from optional or advanced material.
- Design for student autonomy. Fully scaffold the mechanical plumbing (loading,
  QC, aggregation, tool syntax), but leave the *scientific* decisions to the
  reader — experimental/cohort design, the contrast, cell-type choice,
  confounders, and interpretation. Those decisions are where a sense of
  accomplishment comes from; tutorials that leave only parameters to tweak do
  not.
- Prefer ending a tutorial at a genuine open question over a pre-cooked answer.
  A null or ambiguous result is an honest, valuable endpoint that invites the
  reader's own analysis, not a failure to fix.
- Split an expensive generation step from the analysis it feeds: have the costly
  step (e.g. loading many large donor files) save a small object that the
  analysis loads, so readers can iterate on the science in seconds instead of
  re-running the plumbing.
- Favor reproducible code over manual, undocumented steps.
- Set random seeds when results depend on randomness.
- Record package and data requirements.
- Do not commit restricted data, credentials, tokens, or large generated
  artifacts.

## Code quality

- Use clear object and function names.
- Prefer small, readable analysis steps over dense pipelines.
- Add comments that explain reasoning, not syntax that is already obvious.
- Check that each tutorial runs from a clean R session before considering it
  complete.
- Treat warnings and changed package behavior explicitly; do not hide them
  unless the tutorial explains why doing so is safe.

## Data handling

- Document the SEA-AD dataset, release, and source used by each tutorial.
- Include download or access instructions when redistribution is not allowed.
- Use small derived or example datasets where the full dataset is impractical.
- Preserve participant privacy and comply with the source dataset's terms of
  use.
