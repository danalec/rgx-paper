# The Diodic Search Architecture: Regex Search without Per-File Metadata Cost

Preprint — not peer reviewed; comments welcome.

**Author.** Dan Alec Yamaguchi (Independent Researcher)
ORCID [0009-0002-9725-7779](https://orcid.org/0009-0002-9725-7779) · danalec@gmail.com

**Preprint.** Hosted on Zenodo as a 2026 preprint.
DOI [10.5281/zenodo.23453407](https://doi.org/10.5281/zenodo.23453407)

**Repository.** [github.com/danalec/rgx-paper](https://github.com/danalec/rgx-paper).

**Code.** [github.com/danalec/rgx](https://github.com/danalec/rgx) — the search tool the
paper measures. Every number in the paper comes from that repository's benchmark harness.

---

## Abstract

We present a prepared-corpus regex search system that reduces repeated-query latency by
amortizing per-file filesystem metadata costs into a one-time packing and indexing phase.
A SIMD candidate filter reduces exact-match work but introduces no false negatives. On
stable corpora with many small files the system achieves substantial end-to-end speedups —
2.79–3.38× over ripgrep 15 on a fixed 20,000-file corpus and 6.66–12.41× on a live
95,942-file, 1.94 GB registry across the patterns whose result sets coincide, breaking even at
Q\* ≈ 24 queries — and the advantage
diminishes for one-shot searches or frequently changing corpora. An in-process timer
reports a phantom 53.9% win for a leaked unmap that the external wall clock refuses, and
every end-to-end performance claim in this paper rests on external wall-clock
measurements; the in-process timings are reported separately as diagnostics, for the
segments they explain and nothing more. Count parity holds on every comparison
reported here except the two live-registry patterns marked † in the live-registry table,
where the store
returned a strict subset of the direct engine's answer; no ratio is claimed for them, and both
endpoints of the registry range come from coinciding patterns. Even there the store arm of that
snapshot did not extract container text, so the range is a property of that historical
configuration — the missing work could have lowered the store's cost without changing its answer —
and this paper reports no full-pipeline registry measurement. The
Tesla valve serves as an architectural inspiration for asymmetric cost, not as a physical
model or performance explanation.

**Keywords.** search, regular expressions, SIMD, storage architecture, filesystem metadata,
amortisation, AVX2, bitmask, multiscale modelling, queueing, Bloom filters.

## What the physics is doing here

The Tesla valve and the semiconductor diode organise the *design*: they supply the
vocabulary for asymmetric cost — vanes, throat, forward/reverse flow, diodicity, threshold
and breakdown — and the derivation procedure in §12 (a calculus of five questions that
produces the shipped prefilter, a rule-set scanner, and the store/pool/caps layers). They
never predict performance. Every speed claim in the paper is a measurement: external wall
clock, exact match-count parity, and a verdict that can refuse. §2.2 states the
demarcation and §12.6 states what the calculus does not do.

## Repository contents

| File | What it is |
|---|---|
| `diodic-search.tex` | The manuscript source — canonical and complete |
| `diodic-search.pdf` | **The rendered paper, 49 pages.** Download or read it here without a TeX install; the Zenodo preprint above is the citable record |
| `LICENSE` | CC BY 4.0 for the paper; see the note on code listings below |

## Building

```sh
pdflatex -interaction=nonstopmode diodic-search.tex   # x3: the first two settle
```

The preamble is self-contained: `newpxtext`/`newpxmath` (Times-like text and math),
`booktabs`, `cleveref`, `hyperref`, `tikz`, `listings` — a stock TeX Live or MiKTeX
install has all of them.

> **One trap worth knowing.** `pdflatex -output-directory=<dir>` still reads a stale
> `diodic-search.aux` from the *source* directory first, so a leftover `.aux`/`.log`/`.out`
> from an earlier in-source build makes every new cross-reference stay undefined no matter
> how many passes you run. Delete those three files before building into a separate
> output directory.

## Citation

```bibtex
@article{yamaguchi2026diodic,
  author  = {Yamaguchi, Dan Alec},
  title   = {The Diodic Search Architecture: Regex Search without
             Per-File Metadata Cost},
  journal = {Zenodo preprint},
  year    = {2026},
  doi     = {10.5281/zenodo.23453407},
  note    = {Not peer reviewed}
}
```

## License

The manuscript (this repository) is licensed under
[CC BY 4.0](LICENSE) — share and adapt with attribution.

Code listings inside the paper are illustrative excerpts of `rgx`, which is separately
licensed **MIT OR Apache-2.0** at [github.com/danalec/rgx](https://github.com/danalec/rgx).
They are reproduced here for illustration; the license of the listings follows the code.
