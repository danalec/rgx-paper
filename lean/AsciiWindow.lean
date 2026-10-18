import AsciiWindow.Decode
import AsciiWindow.Match
import AsciiWindow.Window

/-!
# The window rule, formally: byte-mode ≡ codepoint-mode on ASCII windows

`rgx`'s searcher lets a byte-engine match settle a line when the window it
spans is pure ASCII (`crates/rgx-core/src/matcher.rs`, `decides_window`):

> A pure-ASCII window settles the line on the byte engine's word — on ASCII
> bytes a codepoint is a byte, so both engines match there.

This library is that sentence, proved for fixed-width byte-class patterns —
the shape every character class, literal byte and `.` compiles to
(`crates/rgx-core/src/byteclass.rs`).

* `AsciiWindow.Decode` — UTF-8 decoding of a byte window to codepoints and
  the ASCII exactness fact ("on ASCII bytes a codepoint is a byte"), with
  byte-offset/codepoint-offset alignment.
* `AsciiWindow.Match` — byte classes, their lift to codepoints, anchored
  matching at an offset, and the transport lemma: matching commutes with
  decoding whenever re-encoding recovers the element.
* `AsciiWindow.Window` — the window rule itself: on a pure-ASCII window the
  two engines' match verdicts coincide, offset for offset.

Proofs are complete: `lake build` with no `sorry` and the standard axioms
only. Core Lean only — no Mathlib dependency.
-/
