/-!
# UTF-8 decoding of a byte window

The window rule (`crates/rgx-core/src/matcher.rs`, `decides_window`) rests on
one fact: *on ASCII bytes a codepoint is a byte*. This module models the
codepoint view of a byte window and proves that fact.

A codepoint is modeled as its scalar value (`Nat`): the window rule talks
about Unicode values, and keeping the model in `List`/`Nat` land leaves Lean's
`Char` validity proof out of the statements.

The decode is total and exact on pure-ASCII windows. Outside them it is
shape-only — one codepoint per UTF-8 lead-length sequence, junk `0xFFFD` —
and nothing below claims otherwise: the window rule hands this decode a
pure-ASCII window and nothing else.
-/

namespace AsciiWindow

/-- A Unicode codepoint, as its scalar value. -/
abbrev Cp : Type := Nat

/-- Bytes in the UTF-8 sequence whose lead byte is `b`.

Shape only outside ASCII: `0x80..0xBF` is a stray continuation (consumed as a
junk singleton), `0xF5..0xFF` an invalid lead (likewise). See the module
docstring — the decode is exact where the theorems say, and shape-only
elsewhere. -/
def utf8SeqLen (b : UInt8) : Nat :=
  if b.toNat < 0x80 then 1
  else if b.toNat < 0xC0 then 1
  else if b.toNat < 0xE0 then 2
  else if b.toNat < 0xF0 then 3
  else if b.toNat < 0xF8 then 4
  else 1

/-- Consume the `n` bytes of a UTF-8 sequence after its lead byte. -/
def dropSeq : List UInt8 → Nat → List UInt8
  | l, 0 => l
  | [], _ + 1 => []
  | _ :: l, n + 1 => dropSeq l n

/-- `dropSeq` never grows its input. -/
theorem dropSeq_length (l : List UInt8) (n : Nat) :
    (dropSeq l n).length ≤ l.length := by
  induction l generalizing n with
  | nil => cases n <;> simp [dropSeq]
  | cons b l ih =>
    cases n with
    | zero => simp [dropSeq]
    | succ n =>
      have h := ih n
      simp only [dropSeq, List.length_cons]
      omega

/-- Total UTF-8 decode of a byte window to codepoints.

An ASCII byte decodes to its own value; any other sequence decodes to junk
`0xFFFD` and consumes its UTF-8 length in bytes. Malformed input is not
rejected — this is a window model, not a validator. -/
def decodeUTF8 : List UInt8 → List Cp
  | [] => []
  | b :: rest =>
    (if b.toNat < 0x80 then b.toNat else 0xFFFD)
      :: decodeUTF8 (dropSeq rest (utf8SeqLen b - 1))
termination_by bs => bs.length
decreasing_by
  exact Nat.lt_of_le_of_lt
    (dropSeq_length rest (utf8SeqLen b - 1)) (Nat.lt_succ_self _)

/-- **On ASCII bytes a codepoint is a byte.** A pure-ASCII window decodes to
one codepoint per byte — the byte's own value. This is the sentence the
window rule cites, and the point where ASCII enters every theorem below. -/
theorem decodeUTF8_eq_map_toNat_of_ascii (w : List UInt8)
    (hw : ∀ b ∈ w, b.toNat < 0x80) :
    decodeUTF8 w = w.map UInt8.toNat := by
  induction w with
  | nil => simp [decodeUTF8]
  | cons b rest ih =>
    have hb : b.toNat < 0x80 := hw b (by simp)
    have hrest : ∀ x ∈ rest, x.toNat < 0x80 := fun x hx ↦ hw x (by simp [hx])
    have hlen : utf8SeqLen b = 1 := by simp [utf8SeqLen, hb]
    simp [decodeUTF8, hb, hlen, dropSeq]
    rw [ih hrest]

/-- Byte offsets and codepoint offsets coincide on a pure-ASCII window: the
decode has one codepoint per byte, index for index. -/
theorem length_decodeUTF8_of_ascii (w : List UInt8)
    (hw : ∀ b ∈ w, b.toNat < 0x80) :
    (decodeUTF8 w).length = w.length := by
  rw [decodeUTF8_eq_map_toNat_of_ascii w hw]
  simp only [List.length_map]

/-- The codepoint at offset `i` of a pure-ASCII window is the byte at `i`,
as a codepoint: a byte offset and a codepoint offset name the same place. -/
theorem getElem?_decodeUTF8_of_ascii (w : List UInt8)
    (hw : ∀ b ∈ w, b.toNat < 0x80) (i : Nat) :
    (decodeUTF8 w)[i]? = (w[i]?).map UInt8.toNat := by
  rw [decodeUTF8_eq_map_toNat_of_ascii w hw]
  simp only [List.getElem?_map]

end AsciiWindow
