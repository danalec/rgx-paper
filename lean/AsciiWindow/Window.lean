import AsciiWindow.Decode
import AsciiWindow.Match

/-!
# The window rule

`crates/rgx-core/src/matcher.rs`, `decides_window`: a byte-engine match
spanning a window settles the line when the window is pure ASCII —

> A pure-ASCII window settles the line on the byte engine's word — on ASCII
> bytes a codepoint is a byte, so both engines match there.

This module is that sentence, proved for fixed-width byte-class patterns.
-/

namespace AsciiWindow

/-- **The window rule.** On a pure-ASCII window, byte-mode matching and
codepoint-mode matching of a fixed-width byte-class pattern coincide, offset
for offset. -/
theorem matchesAt_byte_iff_cp (p : BytePat) (w : List UInt8) (i : Nat)
    (hw : ∀ b ∈ w, b.toNat < 0x80) :
    MatchesAt p w i ↔ MatchesAt (liftPat p) (decodeUTF8 w) i := by
  rw [decodeUTF8_eq_map_toNat_of_ascii w hw]
  exact matchesAt_map_iff UInt8.ofNat UInt8.toNat
    (fun x ↦ UInt8.ofNat_toNat (x := x)) p w i

/-- The byte engine's verdict on the window is the codepoint engine's: the
window holds a match of one engine iff it holds a match of the other. This is
what lets a byte-engine match settle the line without asking the codepoint
delegate. -/
theorem exists_matchesAt_iff_of_ascii (p : BytePat) (w : List UInt8)
    (hw : ∀ b ∈ w, b.toNat < 0x80) :
    (∃ i, MatchesAt p w i) ↔ (∃ i, MatchesAt (liftPat p) (decodeUTF8 w) i) := by
  constructor
  · intro ⟨i, hi⟩
    exact ⟨i, (matchesAt_byte_iff_cp p w i hw).mp hi⟩
  · intro ⟨i, hi⟩
    exact ⟨i, (matchesAt_byte_iff_cp p w i hw).mpr hi⟩

end AsciiWindow
