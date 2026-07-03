# Single-cell analysis tutorials

Hands-on tutorials for learning single-cell analysis in R using data from the
Seattle Alzheimer's Disease Brain Cell Atlas (SEA-AD).

The tutorials are written as Quarto documents and organized as a Quarto
website. They are intended primarily for students, while remaining useful to a
broader scientific audience.

## Tutorial sequence

1. **Tutorial 00 — Setup:** install R, RStudio, and Quarto, then verify the
   environment.
2. **Tutorial 01 — Read an H5AD file:** open an H5AD file in R and inspect its
   contents.

## Repository structure

```text
.
├── _quarto.yml                 # Quarto website configuration
├── index.qmd                   # Website landing page
├── R/
│   └── helpers.R               # Shared helper functions
├── tutorials/
│   ├── 00-setup/
│   │   ├── index.qmd
│   │   └── images/
│   └── 01-read-h5ad/
│       ├── index.qmd
│       └── images/
├── data/
│   ├── README.md               # Data access and provenance notes
│   └── example/                # Small, redistributable example data
└── outputs/                    # Generated analysis outputs
```

Each tutorial has its own numbered directory. The number controls the tutorial
order, while the descriptive directory name keeps paths readable.

## Rendering the website

From the repository root, run:

```sh
quarto preview
```

The tutorial pages currently contain placeholders; analysis content and package
requirements will be added in subsequent development.
