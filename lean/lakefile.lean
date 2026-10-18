import Lake
open Lake DSL

package AsciiWindow where
  version := v!"0.1.0"

/-- The window rule: byte-mode and codepoint-mode matching coincide on
pure-ASCII windows. Root module `AsciiWindow` plus its submodules. -/
@[default_target]
lean_lib AsciiWindow where
  globs := #[Glob.andSubmodules `AsciiWindow]
