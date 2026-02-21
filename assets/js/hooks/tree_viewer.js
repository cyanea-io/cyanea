import { loadWasm, Phylo } from "../wasm.js"

// Parse a Newick string into a tree structure for layout.
// Returns { name, length, children } nodes.
function parseNewick(str) {
  const s = str.trim().replace(/;$/, "")
  let i = 0

  function parseNode() {
    const node = { name: "", length: null, children: [] }

    if (s[i] === "(") {
      i++ // skip '('
      node.children.push(parseNode())
      while (s[i] === ",") {
        i++ // skip ','
        node.children.push(parseNode())
      }
      i++ // skip ')'
    }

    // Parse label (could contain numbers, letters, underscores, dots)
    let label = ""
    while (i < s.length && s[i] !== ":" && s[i] !== "," && s[i] !== ")" && s[i] !== ";") {
      label += s[i]
      i++
    }
    node.name = label.trim()

    // Parse branch length
    if (s[i] === ":") {
      i++ // skip ':'
      let num = ""
      while (i < s.length && (s[i] === "." || s[i] === "-" || s[i] === "e" || s[i] === "E" || (s[i] >= "0" && s[i] <= "9"))) {
        num += s[i]
        i++
      }
      node.length = parseFloat(num)
    }

    return node
  }

  return parseNode()
}

// Compute layout positions for each node.
// Returns { nodes: [{x, y, name, isLeaf}], edges: [{x1, y1, x2, y2}] }
function layoutTree(root, width, height) {
  const padding = { top: 20, right: 120, bottom: 20, left: 40 }
  const plotW = width - padding.left - padding.right
  const plotH = height - padding.top - padding.bottom

  // Count leaves and compute max depth
  let leafCount = 0
  let maxDepth = 0

  function measure(node, depth) {
    const d = depth + (node.length != null ? node.length : 1)
    if (node.children.length === 0) {
      leafCount++
      maxDepth = Math.max(maxDepth, d)
    } else {
      for (const child of node.children) {
        measure(child, d)
      }
    }
  }
  measure(root, 0)

  if (leafCount === 0) return { nodes: [], edges: [] }

  const hasLengths = maxDepth !== leafCount // crude check
  const leafSpacing = plotH / Math.max(leafCount - 1, 1)
  let leafIdx = 0

  const nodes = []
  const edges = []

  function layout(node, xStart) {
    const branchLen = hasLengths && node.length != null ? node.length : 1
    const xEnd = xStart + (branchLen / maxDepth) * plotW

    if (node.children.length === 0) {
      // Leaf node
      const y = padding.top + leafIdx * leafSpacing
      leafIdx++
      nodes.push({ x: padding.left + xEnd, y, name: node.name, isLeaf: true })
      return { x: padding.left + xEnd, y }
    }

    // Internal node -- layout children first
    const childCoords = node.children.map(c => layout(c, xEnd))
    const minY = Math.min(...childCoords.map(c => c.y))
    const maxY = Math.max(...childCoords.map(c => c.y))
    const y = (minY + maxY) / 2
    const x = padding.left + xEnd

    nodes.push({ x, y, name: node.name, isLeaf: false })

    // Horizontal line to this node + vertical connector
    for (const cc of childCoords) {
      // Horizontal branch from child's x back to this node's x
      edges.push({ x1: x, y1: cc.y, x2: cc.x, y2: cc.y })
    }
    // Vertical connector
    edges.push({ x1: x, y1: minY, x2: x, y2: maxY })

    return { x, y }
  }

  const rootCoord = layout(root, 0)

  // Edge from origin to root
  if (root.length != null && root.length > 0) {
    edges.push({ x1: padding.left, y1: rootCoord.y, x2: rootCoord.x, y2: rootCoord.y })
  }

  return { nodes, edges }
}

function renderTree(el, newick, width, height) {
  if (!newick || !newick.trim()) {
    el.innerHTML = `<div class="p-6 text-sm text-slate-500">No tree data</div>`
    return
  }

  let info
  try {
    info = Phylo.newickInfo(newick)
  } catch (err) {
    el.innerHTML = `
      <div class="rounded-lg border border-red-200 dark:border-red-800 bg-red-50 dark:bg-red-900/20 p-4">
        <p class="text-sm text-red-700 dark:text-red-400">Invalid Newick: ${err.message}</p>
      </div>`
    return
  }

  // Auto-adjust height based on leaf count
  const autoHeight = Math.max(height, info.leaf_count * 22 + 40)

  const tree = parseNewick(newick)
  const { nodes, edges } = layoutTree(tree, width, autoHeight)

  // Build SVG
  let svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${autoHeight}" class="block">`

  // Edges
  for (const e of edges) {
    svg += `<line x1="${e.x1}" y1="${e.y1}" x2="${e.x2}" y2="${e.y2}" stroke="currentColor" class="text-slate-400 dark:text-slate-500" stroke-width="1.5"/>`
  }

  // Leaf labels
  for (const n of nodes) {
    if (n.isLeaf && n.name) {
      svg += `<text x="${n.x + 8}" y="${n.y + 4}" class="fill-slate-700 dark:fill-slate-300" font-size="11" font-family="ui-monospace, monospace">${n.name}</text>`
    }
    // Node dot
    svg += `<circle cx="${n.x}" cy="${n.y}" r="${n.isLeaf ? 3 : 2}" class="${n.isLeaf ? "fill-primary" : "fill-slate-400 dark:fill-slate-500"}"/>`
  }

  svg += `</svg>`

  // Stats
  const statsItems = [
    { label: "Leaves", value: info.leaf_count },
    { label: "Internal", value: info.internal_count },
    { label: "Total nodes", value: info.total_nodes },
  ]
  const statsHtml = statsItems.map(s =>
    `<div class="flex items-center gap-1.5">
      <span class="text-xs text-slate-500 dark:text-slate-400">${s.label}:</span>
      <span class="text-xs font-medium text-slate-700 dark:text-slate-200">${s.value}</span>
    </div>`
  ).join("")

  el.innerHTML = `
    <div class="overflow-hidden rounded-lg border border-slate-200 dark:border-slate-700">
      <div class="flex flex-wrap items-center gap-4 border-b border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-800/50 px-4 py-2">
        ${statsHtml}
      </div>
      <div class="overflow-x-auto bg-white dark:bg-slate-900 p-4">
        ${svg}
      </div>
    </div>
  `
}

const TreeViewer = {
  async mounted() {
    try {
      await loadWasm()
    } catch (err) {
      this.el.innerHTML = `<div class="p-4 text-sm text-red-600">Failed to load WASM: ${err.message}</div>`
      return
    }

    const newick = this.el.dataset.newick || ""
    const width = parseInt(this.el.dataset.width) || 600
    const height = parseInt(this.el.dataset.height) || 400
    renderTree(this.el, newick, width, height)

    this.handleEvent("render-tree", ({ newick }) => {
      const w = parseInt(this.el.dataset.width) || 600
      const h = parseInt(this.el.dataset.height) || 400
      renderTree(this.el, newick, w, h)
    })
  },

  updated() {
    const newick = this.el.dataset.newick || ""
    const width = parseInt(this.el.dataset.width) || 600
    const height = parseInt(this.el.dataset.height) || 400
    renderTree(this.el, newick, width, height)
  }
}

export default TreeViewer
