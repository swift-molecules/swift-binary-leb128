# Changelog

All notable changes to `swift-binary-leb128-primitives` are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Shared LEB128 decode core** — `Binary.LEB128.Decode.{unsigned,signed}`, the single bit-width-parameterized, step-based decode arithmetic (`Binary LEB128 Decode Primitives`). Width-general precise-fit overflow contract; the step shape is callable from the zero-copy borrowed interpreter (scalar params, no cursor). Becomes the one source of truth that the canonical parser structs and the binary `Machine`/`Borrowed` interpreters route through (replacing three drifted copies).
- Initial split from `swift-binary-primitives` per `swift-institute/Research/binary-primitives-package-decomposition.md` (RECOMMENDATION, 2026-05-07).
- `Binary.LEB128` namespace + `Binary.LEB128.Error` type (`.overflow(bitWidth:)`, `.unterminated`).
- Unsigned/signed LEB128 serialization via `[Byte].init(leb128:)`.

### Changed

- **Scope expanded from serialization-only to the LEB128 codec mechanism** (`[MOD-035]`): the package now owns both encode and the shared decode arithmetic. The `Parser.\`Protocol\``/`Serializer.\`Protocol\`` conformances remain on their respective sides.
- **`[MOD-031]` decomposition**: split into `Binary LEB128 Primitive` (namespace + `Error` root), `Binary LEB128 Decode Primitives`, `Binary LEB128 Encode Primitives`, and the `Binary LEB128 Primitives` umbrella. The umbrella product is unchanged, so existing `import Binary_LEB128_Primitives` consumers are unaffected.
- Added a direct `swift-byte-primitives` dependency for the encoder (previously reached transitively via `Binary Primitive`).

### Notes

- Parsing-side LEB128 (`Parser.\`Protocol\`` structs) lives in `swift-binary-parser-primitives/Sources/Binary LEB128 Parser Primitives/`; those structs and the binary interpreters will be re-pointed onto `Binary.LEB128.Decode` in a follow-up (Phases 2–3). The Parser/Serializer protocol split is intentional and symmetric with the institute's `Parser.Protocol` / `Serializer.Protocol` separation.
- The root `Binary LEB128 Primitive` depends only on `swift-binary-primitives`'s `Binary Primitive` namespace anchor — it does NOT pull in the broader binary substrate.
