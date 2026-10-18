# AGENTS.md

Preprint source for *"The Diodic Search Architecture: Regex Search without Per-File Metadata Cost"*.
Single-source LaTeX manuscript — `tesla-valve.tex` is canonical; the PDF is **generated, never tracked**
(published as a 2026 Zenodo preprint, DOI [10.5281/zenodo.23318461](https://doi.org/10.5281/zenodo.23318461)).
Canonical read-only mirror: <https://github.com/danalec/rgx-paper>.

## Setup

- TeX Live (full) or MiKTeX (full). The preamble uses `newpxtext`, `newpxmath`, `booktabs`,
  `cleveref`, `hyperref`, `tikz`, `listings` — a stock install has all of them; nothing extra is needed.
- No `package.json`, no `Cargo.toml`, no `pyproject.toml`. There is nothing to install.

## Build

- Build: `pdflatex -interaction=nonstopmode tesla-valve.tex` — **three times**.
  Pass 1 writes cross-references, pass 2 reads them, pass 3 settles page breaks.
  Float placement and reference format are unstable without the third pass.
- Output: `tesla-valve.pdf` at the repo root. It is `.gitignore`d; **do not commit**.
  Re-snap locally if you need a copy; the canonical PDF lives on Zenodo.
- Build into a separate directory with `pdflatex -output-directory=out` if you want a clean tree,
  but **delete any stale `tesla-valve.aux` / `.log` / `.out` from the source directory first** —
  `pdflatex` still reads the source-dir `.aux` and a leftover one keeps every cross-reference
  undefined no matter how many passes you run.

## Verify (replaces "test")

There is no automated test suite; the verification gate is a clean build with no undefined references.

- Build ×3 as above.
- `grep -E 'Warning|undefined|Reference .* undefined' tesla-valve.log` — must return nothing material.
  Page-size warnings and one-time microtype warnings are expected on the first pass; ignore them.
- Spot-check that every `\cref{...}`, `\ref{...}`, `\cite{...}` resolves. `cleveref` is loaded last
  on purpose — do not move `\usepackage{cleveref}` before `\usepackage{hyperref}`.

## Project layout

Flat single-source tree. No `tests/`, no `docs/`, no `figures/`, no CI workflows.

- `tesla-valve.tex` — the manuscript source (canonical, complete)
- `README.md` — author, abstract, build instructions, citation, license note
- `LICENSE` — CC BY 4.0 for the manuscript
- `.gitignore` — excludes `tesla-valve.pdf` and every LaTeX build artifact
- `.gitattributes` — pins LF line endings; marks `*.pdf` and other binaries as binary so autocrlf never rewrites them

## Manuscript style

- Single-column 11pt article, classic preprint look (NeurIPS / arXiv): one column, 1in margins,
  Times-like Newpx text and math, centred title block, unboxed abstract, bold size-contrast
  section headings. Keep that look; do not introduce a two-column or institutional-masthead template.
- One colour (`rgxblue` = `#1F4E79`) is used for figures and code rules so they read as a set.
- Listings use the `rust` style defined in the preamble; it has its own `lstdefinelanguage{Rust}{...}`.
  Do not pull in `minted` or `listingsutf8` — the existing preamble already covers what the paper needs.
- Every theorem environment (`theorem`, `lemma`, `proposition`, `definition`, `corollary`, `remark`)
  is declared in the preamble with `amsthm`'s plain style. Match the plain italic body / upright
  label when adding any new one.
- Code listings inside the paper are illustrative excerpts of `rgx` (separate repo, MIT OR Apache-2.0);
  their license follows the code, not the paper.

## Branch hygiene

- Branch from `main`. Merge to `main` when ready and delete the branch in the same step
  (local and remote). Long-lived topic branches are not kept.
- Tracked file: commit `AGENTS.md`, `README.md`, `tesla-valve.tex`, `LICENSE`, `.gitignore`,
  `.gitattributes`. Untracked: every `tesla-valve.*` build artifact and the PDF.
- Origin is the local gitea at `http://192.168.0.10:3000/danalec/rgx-paper` (sync only);
  docs and citations point to the GitHub mirror.

## Security

- No secrets, no API keys, no build-time credentials. The manuscript is plain text.
- `LICENSE` is CC BY 4.0 for the paper text; do not change the licence without updating the README
  and the Zenodo metadata. Code listings are excerpts of the `rgx` repository (MIT OR Apache-2.0)
  and follow that licence even when embedded.