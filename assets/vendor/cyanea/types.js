// ---------------------------------------------------------------------------
// @cyanea/bio -- TypeScript type definitions for the cyanea-wasm WASM bindings
// ---------------------------------------------------------------------------
// Every raw WASM function returns a JSON string with either:
//   { "ok": T }   on success
//   { "error": string }  on failure
//
// The typed wrapper in index.ts unwraps this envelope so callers receive T
// directly or get a thrown CyaneaError.
// ---------------------------------------------------------------------------
export {};
//# sourceMappingURL=types.js.map