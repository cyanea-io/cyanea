#!/usr/bin/env bash
set -euo pipefail

# Build and vendor WASM artifacts from labs/cyanea-wasm into the Phoenix app.
#
# Usage: bin/build_wasm.sh [--skip-build]
#   --skip-build  Skip wasm-pack + tsc, just copy existing artifacts

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(dirname "$SCRIPT_DIR")"
LABS_DIR="$(cd "$APP_DIR/../labs" && pwd)"
WASM_CRATE="$LABS_DIR/cyanea-wasm"

SKIP_BUILD=false
for arg in "$@"; do
  case "$arg" in
    --skip-build) SKIP_BUILD=true ;;
  esac
done

if [ "$SKIP_BUILD" = false ]; then
  echo "==> Building WASM (wasm-pack)..."
  cd "$WASM_CRATE"
  wasm-pack build --target web --features wasm

  echo "==> Compiling TypeScript..."
  npx tsc --project tsconfig.json
fi

echo "==> Vendoring artifacts into Phoenix app..."

# WASM binary
mkdir -p "$APP_DIR/priv/static/wasm"
cp "$WASM_CRATE/pkg/cyanea_wasm_bg.wasm" "$APP_DIR/priv/static/wasm/cyanea_wasm_bg.wasm"

# JS glue and typed wrappers
mkdir -p "$APP_DIR/assets/vendor/cyanea"
cp "$WASM_CRATE/pkg/cyanea_wasm.js" "$APP_DIR/assets/vendor/cyanea/cyanea_wasm.js"
cp "$WASM_CRATE/ts/index.js"        "$APP_DIR/assets/vendor/cyanea/index.js"
cp "$WASM_CRATE/ts/types.js"        "$APP_DIR/assets/vendor/cyanea/types.js"

echo "==> Done. Vendored files:"
echo "    priv/static/wasm/cyanea_wasm_bg.wasm"
echo "    assets/vendor/cyanea/cyanea_wasm.js"
echo "    assets/vendor/cyanea/index.js"
echo "    assets/vendor/cyanea/types.js"
