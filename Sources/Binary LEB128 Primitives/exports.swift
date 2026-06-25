// Umbrella target. Re-exports every sub-target so a single
// `import Binary_LEB128_Primitives` surfaces the whole LEB128 codec mechanism
// (namespace + Error, decode core, encoder).

@_exported public import Binary_LEB128_Decode_Primitives
@_exported public import Binary_LEB128_Encode_Primitives
@_exported public import Binary_LEB128_Primitive
