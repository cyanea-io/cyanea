// WASM loader singleton -- initializes the cyanea-wasm module once and
// re-exports the typed namespace API for use by LiveView hooks.

import init from "../vendor/cyanea/cyanea_wasm.js"
import * as api from "../vendor/cyanea/index.js"

let ready = null

/**
 * Initialize the WASM module. Returns a promise that resolves when ready.
 * Subsequent calls return the same promise (singleton).
 */
export function loadWasm() {
  if (!ready) {
    ready = init("/wasm/cyanea_wasm_bg.wasm")
  }
  return ready
}

export const { Seq, Align, Phylo, Stats, ML, Chem, StructBio, IO, Omics, Core } = api
