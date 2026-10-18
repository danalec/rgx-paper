import AsciiWindow.Decode

/-!
# Fixed-width byte-class patterns and anchored matching

Every character class, literal byte and `.` in a byte-mode regex compiles to
one byte set (`crates/rgx-core/src/byteclass.rs`); a fixed-width pattern is
one class per matched byte. This module gives the semantics the two engines
share: an anchored match at an offset, and the lift of a byte class to
codepoints.

The lift views a codepoint as its low byte. It is exact below 256 — every
codepoint of an ASCII window — and junk beyond, which the window rule never
reaches; a total function with documented junk, not a subtype.
-/

namespace AsciiWindow

/-- A byte class: the semantics of one character class over bytes. -/
abbrev ByteClass : Type := UInt8 → Prop

/-- A codepoint class: the same class over codepoints. -/
abbrev CpClass : Type := Cp → Prop

/-- Lift a byte class to codepoints by viewing a codepoint as its low byte. -/
def lift (q : ByteClass) : CpClass := fun n ↦ q (UInt8.ofNat n)

/-- A fixed-width byte-class pattern: one class per matched byte. -/
abbrev BytePat : Type := List ByteClass

/-- A fixed-width codepoint-class pattern. -/
abbrev CpPat : Type := List CpClass

/-- Lift a pattern classwise. -/
def liftPat (p : BytePat) : CpPat := p.map lift

/-- A match of `p` in `w` anchored at offset `i`: for every class below the
width there is a class and a byte at the position the class sits at, and the
class holds of the byte. A past-the-end offset simply fails — the definition
is total, and a window too short has no match there.

An empty pattern matches at every offset in both views. `rgx`'s matcher
declines empty needles by guard (`matcher.rs`), identically in both engines,
so the equivalence below is unaffected. -/
def MatchesAt {α : Type} (p : List (α → Prop)) (w : List α) (i : Nat) : Prop :=
  ∀ k < p.length, ∃ q x, p[k]? = some q ∧ w[i + k]? = some x ∧ q x

/-- Inverting `Option.map` over `some`: a mapped value comes from a mapped
element. -/
private theorem map_eq_some_iff {γ δ : Type} (f : γ → δ) (o : Option γ)
    (y : δ) : Option.map f o = some y ↔ ∃ x, o = some x ∧ y = f x := by
  cases o with
  | none =>
    constructor
    · intro h
      have h' : none = some y := h
      cases h'
    · intro h
      obtain ⟨x, hx, _⟩ := h
      cases hx
  | some x =>
    constructor
    · intro h
      have h' : some (f x) = some y := h
      exact ⟨x, rfl, (Option.some.inj h').symm⟩
    · intro h
      obtain ⟨x', hx', hy'⟩ := h
      have hxx' : x = x' := Option.some.inj hx'
      subst hxx'
      exact congrArg some hy'.symm

/-- Matching commutes with decoding when re-encoding recovers the element:
the lifted class sees through the retraction. This transport step is
unconditional — the ASCII hypothesis lives entirely in the decode
(`AsciiWindow.Decode.decodeUTF8_eq_map_toNat_of_ascii`). -/
theorem matchesAt_map_iff {α β : Type} (r : β → α) (d : α → β)
    (hr : ∀ x, r (d x) = x) (p : List (α → Prop)) (w : List α) (i : Nat) :
    MatchesAt p w i
      ↔ MatchesAt (p.map (fun q y ↦ q (r y))) (w.map d) i := by
  constructor
  · intro h k hk
    obtain ⟨q, x, hq, hx, hqx⟩ :=
      h k (by simpa [List.length_map] using hk)
    refine ⟨fun y ↦ q (r y), d x, ?_, ?_, ?_⟩
    · simp only [List.getElem?_map, hq]
      rfl
    · simp only [List.getElem?_map, hx]
      rfl
    · show q (r (d x))
      rw [hr x]
      exact hqx
  · intro h k hk
    obtain ⟨q', y, hq', hy, hq'y⟩ :=
      h k (by simpa [List.length_map] using hk)
    simp only [List.getElem?_map] at hq' hy
    rcases (map_eq_some_iff _ _ q').mp hq' with ⟨q, hq, rfl⟩
    rcases (map_eq_some_iff _ _ y).mp hy with ⟨x, hx, rfl⟩
    refine ⟨q, x, hq, hx, ?_⟩
    simpa [hr x] using hq'y

/-- A match consumes exactly the pattern's width: a match at `i` needs the
window to hold `p.length` bytes from `i`. This is the fixed width the window
rule slices spans by. The `0 < p.length` premise is the matcher's own empty-
needle guard (`matcher.rs`, `n == 0 → false`): an empty pattern vacuously
matches at every offset, including past the end of the window. -/
theorem matchesAt_width_le {α : Type} (p : List (α → Prop)) (w : List α)
    (i : Nat) (hp : 0 < p.length) (h : MatchesAt p w i) :
    i + p.length ≤ w.length := by
  apply Nat.le_of_not_lt
  intro hlt
  have hk : w.length - i < p.length := by omega
  obtain ⟨q, x, _, hx, _⟩ := h (w.length - i) hk
  have hge : w.length ≤ i + (w.length - i) := by omega
  have hnone : w[i + (w.length - i)]? = none := by simp [hge]
  rw [hnone] at hx
  cases hx

end AsciiWindow
