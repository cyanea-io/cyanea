// Web Worker for notebook cell execution.
// Loads cyanea-wasm and interprets a command language with:
//   variable = Namespace.function(args)   |   let variable = expr
//   Namespace.function(args)              |   display(expr) / print(expr)
//   if condition ... else ... end         |   for x in iterable ... end
//   expr |> Namespace.function(args)      |   `backtick strings`
//   // comment or # comment

let wasmReady = false
let api = null

async function initWasm() {
  if (wasmReady) return
  const mod = await import("../vendor/cyanea/cyanea_wasm.js")
  await mod.default("/wasm/cyanea_wasm_bg.wasm")
  api = await import("../vendor/cyanea/index.js")
  wasmReady = true
}

// Namespace registry — maps string names to API namespace objects
function getNamespaces() {
  return {
    Seq: api.Seq,
    Align: api.Align,
    Stats: api.Stats,
    ML: api.ML,
    Chem: api.Chem,
    StructBio: api.StructBio,
    Phylo: api.Phylo,
    IO: api.IO,
    Omics: api.Omics,
    Core: api.Core,
  }
}

// ── Tokenizer ─────────────────────────────────────────────────────────────
// Converts source code into a flat array of tokens with line/column info.

const TokenType = {
  // Literals
  NUMBER: "NUMBER",
  STRING: "STRING",
  BACKTICK_STRING: "BACKTICK_STRING",
  TRUE: "TRUE",
  FALSE: "FALSE",
  NULL: "NULL",
  // Identifiers & keywords
  IDENT: "IDENT",
  LET: "LET",
  IF: "IF",
  ELSE: "ELSE",
  END: "END",
  FOR: "FOR",
  IN: "IN",
  // Operators & punctuation
  ASSIGN: "ASSIGN",    // =
  PIPE: "PIPE",        // |>
  DOT: "DOT",          // .
  COMMA: "COMMA",      // ,
  LPAREN: "LPAREN",    // (
  RPAREN: "RPAREN",    // )
  LBRACKET: "LBRACKET",// [
  RBRACKET: "RBRACKET",// ]
  LBRACE: "LBRACE",    // {
  RBRACE: "RBRACE",    // }
  COLON: "COLON",      // :
  // Comparison (for if conditions)
  EQ: "EQ",            // ==
  NEQ: "NEQ",          // !=
  LT: "LT",            // <
  GT: "GT",             // >
  LTE: "LTE",          // <=
  GTE: "GTE",          // >=
  AND: "AND",          // &&
  OR: "OR",            // ||
  NOT: "NOT",          // !
  PLUS: "PLUS",
  MINUS: "MINUS",
  STAR: "STAR",
  SLASH: "SLASH",
  MOD: "MOD",          // %
  // Control
  NEWLINE: "NEWLINE",
  EOF: "EOF",
}

const KEYWORDS = {
  let: TokenType.LET,
  if: TokenType.IF,
  else: TokenType.ELSE,
  end: TokenType.END,
  for: TokenType.FOR,
  in: TokenType.IN,
  true: TokenType.TRUE,
  false: TokenType.FALSE,
  null: TokenType.NULL,
}

function tokenize(source) {
  const tokens = []
  let i = 0
  let line = 1
  let col = 1

  function advance(n = 1) {
    for (let k = 0; k < n; k++) {
      if (source[i] === "\n") { line++; col = 1 } else { col++ }
      i++
    }
  }

  function peek(offset = 0) { return source[i + offset] }
  function at(ch) { return source[i] === ch }

  function addToken(type, value) {
    tokens.push({ type, value, line, col })
  }

  while (i < source.length) {
    // Skip spaces and tabs (not newlines)
    if (at(" ") || at("\t") || at("\r")) {
      advance()
      continue
    }

    // Newline
    if (at("\n")) {
      addToken(TokenType.NEWLINE, "\n")
      advance()
      continue
    }

    // Comment: // or #
    if ((at("/") && peek(1) === "/") || at("#")) {
      while (i < source.length && !at("\n")) advance()
      continue
    }

    // Backtick string
    if (at("`")) {
      advance() // skip opening backtick
      let str = ""
      while (i < source.length && !at("`")) {
        if (at("\\")) {
          advance()
          const esc = { n: "\n", t: "\t", r: "\r", "\\": "\\", "`": "`" }
          str += esc[source[i]] || source[i]
        } else {
          str += source[i]
        }
        advance()
      }
      advance() // skip closing backtick
      addToken(TokenType.BACKTICK_STRING, str)
      continue
    }

    // String literals
    if (at('"') || at("'")) {
      const quote = source[i]
      advance()
      let str = ""
      while (i < source.length && !at(quote)) {
        if (at("\\")) {
          advance()
          const esc = { n: "\n", t: "\t", r: "\r", "\\": "\\", "'": "'", '"': '"' }
          str += esc[source[i]] || source[i]
        } else {
          str += source[i]
        }
        advance()
      }
      advance() // closing quote
      addToken(TokenType.STRING, str)
      continue
    }

    // Numbers
    if (/[0-9]/.test(source[i]) || (at("-") && /[0-9]/.test(peek(1)) && (tokens.length === 0 || [TokenType.ASSIGN, TokenType.LPAREN, TokenType.COMMA, TokenType.LBRACKET, TokenType.COLON, TokenType.PIPE, TokenType.EQ, TokenType.NEQ, TokenType.LT, TokenType.GT, TokenType.LTE, TokenType.GTE, TokenType.AND, TokenType.OR, TokenType.PLUS, TokenType.MINUS, TokenType.STAR, TokenType.SLASH, TokenType.MOD, TokenType.NEWLINE].includes(tokens[tokens.length - 1]?.type)))) {
      let num = ""
      if (at("-")) { num += "-"; advance() }
      while (i < source.length && /[0-9]/.test(source[i])) { num += source[i]; advance() }
      if (i < source.length && at(".") && /[0-9]/.test(peek(1))) {
        num += "."; advance()
        while (i < source.length && /[0-9]/.test(source[i])) { num += source[i]; advance() }
      }
      addToken(TokenType.NUMBER, parseFloat(num))
      continue
    }

    // Pipe operator |>
    if (at("|") && peek(1) === ">") {
      addToken(TokenType.PIPE, "|>")
      advance(2)
      continue
    }

    // Two-character operators
    if (at("=") && peek(1) === "=") { addToken(TokenType.EQ, "=="); advance(2); continue }
    if (at("!") && peek(1) === "=") { addToken(TokenType.NEQ, "!="); advance(2); continue }
    if (at("<") && peek(1) === "=") { addToken(TokenType.LTE, "<="); advance(2); continue }
    if (at(">") && peek(1) === "=") { addToken(TokenType.GTE, ">="); advance(2); continue }
    if (at("&") && peek(1) === "&") { addToken(TokenType.AND, "&&"); advance(2); continue }
    if (at("|") && peek(1) === "|") { addToken(TokenType.OR, "||"); advance(2); continue }

    // Single-character tokens
    const singleChars = {
      "=": TokenType.ASSIGN,
      ".": TokenType.DOT,
      ",": TokenType.COMMA,
      "(": TokenType.LPAREN,
      ")": TokenType.RPAREN,
      "[": TokenType.LBRACKET,
      "]": TokenType.RBRACKET,
      "{": TokenType.LBRACE,
      "}": TokenType.RBRACE,
      ":": TokenType.COLON,
      "<": TokenType.LT,
      ">": TokenType.GT,
      "!": TokenType.NOT,
      "+": TokenType.PLUS,
      "-": TokenType.MINUS,
      "*": TokenType.STAR,
      "/": TokenType.SLASH,
      "%": TokenType.MOD,
    }

    if (singleChars[source[i]]) {
      addToken(singleChars[source[i]], source[i])
      advance()
      continue
    }

    // Identifiers and keywords
    if (/[a-zA-Z_]/.test(source[i])) {
      let ident = ""
      while (i < source.length && /[a-zA-Z0-9_]/.test(source[i])) {
        ident += source[i]
        advance()
      }
      const kwType = KEYWORDS[ident]
      addToken(kwType || TokenType.IDENT, ident)
      continue
    }

    // Unknown character — skip
    advance()
  }

  addToken(TokenType.EOF, null)
  return tokens
}

// ── Parser ────────────────────────────────────────────────────────────────
// Recursive-descent parser producing an AST from tokens.

function parse(tokens) {
  let pos = 0

  function current() { return tokens[pos] }
  function peek(offset = 0) { return tokens[pos + offset] }
  function at(type) { return current().type === type }
  function atAny(...types) { return types.includes(current().type) }

  function expect(type) {
    if (!at(type)) {
      throw new Error(`Line ${current().line}: Expected ${type}, got ${current().type} (${JSON.stringify(current().value)})`)
    }
    return advance()
  }

  function advance() {
    const tok = tokens[pos]
    pos++
    return tok
  }

  function skipNewlines() {
    while (pos < tokens.length && at(TokenType.NEWLINE)) advance()
  }

  // Program -> Statement*
  function parseProgram() {
    const statements = []
    skipNewlines()
    while (!at(TokenType.EOF)) {
      statements.push(parseStatement())
      skipNewlines()
    }
    return { type: "Program", statements }
  }

  // Statement -> IfElse | ForLoop | Assignment | ExprStatement
  function parseStatement() {
    skipNewlines()

    if (at(TokenType.IF)) return parseIf()
    if (at(TokenType.FOR)) return parseFor()

    // let x = expr
    if (at(TokenType.LET)) {
      const letTok = advance()
      const nameTok = expect(TokenType.IDENT)
      expect(TokenType.ASSIGN)
      const expr = parsePipeExpr()
      return { type: "Assignment", name: nameTok.value, expr, line: letTok.line }
    }

    // Could be assignment (x = expr) or expression statement
    // Lookahead: IDENT ASSIGN
    if (at(TokenType.IDENT) && peek(1)?.type === TokenType.ASSIGN && peek(2)?.type !== TokenType.ASSIGN) {
      const nameTok = advance()
      advance() // skip =
      const expr = parsePipeExpr()
      return { type: "Assignment", name: nameTok.value, expr, line: nameTok.line }
    }

    // Expression statement
    const expr = parsePipeExpr()
    return { type: "ExprStatement", expr, line: expr.line }
  }

  // If -> 'if' Expr NEWLINE Statement* ('else' NEWLINE Statement*)? 'end'
  function parseIf() {
    const ifTok = expect(TokenType.IF)
    const condition = parsePipeExpr()
    skipNewlines()

    const thenBody = []
    while (!at(TokenType.ELSE) && !at(TokenType.END) && !at(TokenType.EOF)) {
      thenBody.push(parseStatement())
      skipNewlines()
    }

    let elseBody = null
    if (at(TokenType.ELSE)) {
      advance()
      skipNewlines()
      elseBody = []
      while (!at(TokenType.END) && !at(TokenType.EOF)) {
        elseBody.push(parseStatement())
        skipNewlines()
      }
    }

    expect(TokenType.END)
    return { type: "IfElse", condition, then: thenBody, else: elseBody, line: ifTok.line }
  }

  // For -> 'for' IDENT 'in' Expr NEWLINE Statement* 'end'
  function parseFor() {
    const forTok = expect(TokenType.FOR)
    const varTok = expect(TokenType.IDENT)
    expect(TokenType.IN)
    const iterable = parsePipeExpr()
    skipNewlines()

    const body = []
    while (!at(TokenType.END) && !at(TokenType.EOF)) {
      body.push(parseStatement())
      skipNewlines()
    }

    expect(TokenType.END)
    return { type: "ForLoop", variable: varTok.value, iterable, body, line: forTok.line }
  }

  // PipeExpr -> CompExpr (|> Call)*
  function parsePipeExpr() {
    let left = parseCompExpr()

    while (at(TokenType.PIPE)) {
      advance()
      skipNewlines()
      const right = parseCompExpr()
      if (right.type !== "Call" && right.type !== "Display") {
        throw new Error(`Line ${right.line}: Pipe target must be a function call`)
      }
      left = { type: "Pipe", left, right, line: left.line }
    }

    return left
  }

  // CompExpr -> AddExpr ((== | != | < | > | <= | >= | && | ||) AddExpr)*
  function parseCompExpr() {
    let left = parseAddExpr()

    while (atAny(TokenType.EQ, TokenType.NEQ, TokenType.LT, TokenType.GT, TokenType.LTE, TokenType.GTE, TokenType.AND, TokenType.OR)) {
      const op = advance()
      const right = parseAddExpr()
      left = { type: "BinOp", op: op.value, left, right, line: op.line }
    }

    return left
  }

  // AddExpr -> MulExpr ((+ | -) MulExpr)*
  function parseAddExpr() {
    let left = parseMulExpr()

    while (atAny(TokenType.PLUS, TokenType.MINUS)) {
      const op = advance()
      const right = parseMulExpr()
      left = { type: "BinOp", op: op.value, left, right, line: op.line }
    }

    return left
  }

  // MulExpr -> UnaryExpr ((* | / | %) UnaryExpr)*
  function parseMulExpr() {
    let left = parseUnaryExpr()

    while (atAny(TokenType.STAR, TokenType.SLASH, TokenType.MOD)) {
      const op = advance()
      const right = parseUnaryExpr()
      left = { type: "BinOp", op: op.value, left, right, line: op.line }
    }

    return left
  }

  // UnaryExpr -> '!' UnaryExpr | Primary
  function parseUnaryExpr() {
    if (at(TokenType.NOT)) {
      const op = advance()
      const expr = parseUnaryExpr()
      return { type: "UnaryOp", op: "!", expr, line: op.line }
    }
    return parsePrimary()
  }

  // Primary -> Literal | Variable | Call | '(' Expr ')' | ArrayLiteral | ObjectLiteral
  function parsePrimary() {
    const tok = current()

    // Grouped expression
    if (at(TokenType.LPAREN)) {
      advance()
      const expr = parsePipeExpr()
      expect(TokenType.RPAREN)
      return expr
    }

    // Array literal
    if (at(TokenType.LBRACKET)) {
      advance()
      const items = []
      while (!at(TokenType.RBRACKET) && !at(TokenType.EOF)) {
        items.push(parsePipeExpr())
        if (at(TokenType.COMMA)) advance()
      }
      expect(TokenType.RBRACKET)
      return { type: "ArrayLiteral", items, line: tok.line }
    }

    // Object literal
    if (at(TokenType.LBRACE)) {
      advance()
      const entries = []
      while (!at(TokenType.RBRACE) && !at(TokenType.EOF)) {
        let key
        if (at(TokenType.STRING) || at(TokenType.BACKTICK_STRING)) {
          key = advance().value
        } else {
          key = expect(TokenType.IDENT).value
        }
        expect(TokenType.COLON)
        const value = parsePipeExpr()
        entries.push({ key, value })
        if (at(TokenType.COMMA)) advance()
      }
      expect(TokenType.RBRACE)
      return { type: "ObjectLiteral", entries, line: tok.line }
    }

    // Number
    if (at(TokenType.NUMBER)) {
      advance()
      return { type: "Literal", value: tok.value, line: tok.line }
    }

    // String
    if (at(TokenType.STRING) || at(TokenType.BACKTICK_STRING)) {
      advance()
      return { type: "Literal", value: tok.value, line: tok.line }
    }

    // Boolean / null
    if (at(TokenType.TRUE)) { advance(); return { type: "Literal", value: true, line: tok.line } }
    if (at(TokenType.FALSE)) { advance(); return { type: "Literal", value: false, line: tok.line } }
    if (at(TokenType.NULL)) { advance(); return { type: "Literal", value: null, line: tok.line } }

    // Negative number (unary minus)
    if (at(TokenType.MINUS)) {
      advance()
      const expr = parsePrimary()
      return { type: "UnaryOp", op: "-", expr, line: tok.line }
    }

    // Identifier — could be variable, function call, or namespaced call
    if (at(TokenType.IDENT)) {
      const ident = advance()

      // display(...) or print(...)
      if ((ident.value === "display" || ident.value === "print") && at(TokenType.LPAREN)) {
        advance() // (
        const args = []
        while (!at(TokenType.RPAREN) && !at(TokenType.EOF)) {
          args.push(parsePipeExpr())
          if (at(TokenType.COMMA)) advance()
        }
        expect(TokenType.RPAREN)
        return { type: "Display", args, line: ident.line }
      }

      // Namespace.function(args)
      if (at(TokenType.DOT) && /^[A-Z]/.test(ident.value)) {
        advance() // .
        const funcTok = expect(TokenType.IDENT)
        expect(TokenType.LPAREN)
        const args = []
        while (!at(TokenType.RPAREN) && !at(TokenType.EOF)) {
          args.push(parsePipeExpr())
          if (at(TokenType.COMMA)) advance()
        }
        expect(TokenType.RPAREN)
        return { type: "Call", namespace: ident.value, func: funcTok.value, args, line: ident.line }
      }

      // Plain function call: ident(args)
      if (at(TokenType.LPAREN)) {
        advance()
        const args = []
        while (!at(TokenType.RPAREN) && !at(TokenType.EOF)) {
          args.push(parsePipeExpr())
          if (at(TokenType.COMMA)) advance()
        }
        expect(TokenType.RPAREN)
        return { type: "Call", namespace: null, func: ident.value, args, line: ident.line }
      }

      // Variable reference
      return { type: "Variable", name: ident.value, line: ident.line }
    }

    throw new Error(`Line ${tok.line}: Unexpected token: ${tok.type} (${JSON.stringify(tok.value)})`)
  }

  return parseProgram()
}

// ── Interpreter ───────────────────────────────────────────────────────────
// Walks the AST and executes statements, maintaining a context Map.

function interpret(ast, context) {
  let lastResult = undefined
  const displayOutputs = []

  function evalNode(node) {
    switch (node.type) {
      case "Literal":
        return node.value

      case "Variable":
        if (context.has(node.name)) return context.get(node.name)
        throw new Error(`Line ${node.line}: Undefined variable: ${node.name}`)

      case "ArrayLiteral":
        return node.items.map(evalNode)

      case "ObjectLiteral": {
        const obj = {}
        for (const { key, value } of node.entries) {
          obj[key] = evalNode(value)
        }
        return obj
      }

      case "BinOp":
        return evalBinOp(node)

      case "UnaryOp":
        if (node.op === "!") return !evalNode(node.expr)
        if (node.op === "-") return -evalNode(node.expr)
        throw new Error(`Line ${node.line}: Unknown unary operator: ${node.op}`)

      case "Call":
        return evalCall(node)

      case "Display": {
        const value = node.args.length > 0 ? evalNode(node.args[0]) : null
        const outputType = node.args.length > 1 ? evalNode(node.args[1]) : null
        displayOutputs.push({ value, outputType })
        return value
      }

      case "Pipe": {
        const leftVal = evalNode(node.left)
        // Prepend leftVal to the right call's args
        const right = node.right
        if (right.type === "Call") {
          const args = right.args.map(evalNode)
          args.unshift(leftVal)
          return executeWasmCall(right.namespace, right.func, args, right.line)
        }
        if (right.type === "Display") {
          const outputType = right.args.length > 0 ? evalNode(right.args[0]) : null
          displayOutputs.push({ value: leftVal, outputType })
          return leftVal
        }
        throw new Error(`Line ${right.line}: Pipe target must be a function call`)
      }

      default:
        throw new Error(`Line ${node.line || "?"}: Unknown node type: ${node.type}`)
    }
  }

  function evalBinOp(node) {
    // Short-circuit for && and ||
    if (node.op === "&&") {
      const l = evalNode(node.left)
      return l ? evalNode(node.right) : l
    }
    if (node.op === "||") {
      const l = evalNode(node.left)
      return l ? l : evalNode(node.right)
    }

    const l = evalNode(node.left)
    const r = evalNode(node.right)
    switch (node.op) {
      case "+": return l + r
      case "-": return l - r
      case "*": return l * r
      case "/":
        if (r === 0) throw new Error(`Line ${node.line}: Division by zero`)
        return l / r
      case "%": return l % r
      case "==": return l === r
      case "!=": return l !== r
      case "<": return l < r
      case ">": return l > r
      case "<=": return l <= r
      case ">=": return l >= r
      default: throw new Error(`Line ${node.line}: Unknown operator: ${node.op}`)
    }
  }

  function evalCall(node) {
    const args = node.args.map(evalNode)
    return executeWasmCall(node.namespace, node.func, args, node.line)
  }

  function executeWasmCall(namespace, funcName, args, line) {
    if (!namespace) {
      throw new Error(`Line ${line}: Unknown function: ${funcName}`)
    }
    const namespaces = getNamespaces()
    const ns = namespaces[namespace]
    if (!ns) {
      throw new Error(`Line ${line}: Unknown namespace: ${namespace}`)
    }
    const fn = ns[funcName]
    if (typeof fn !== "function") {
      throw new Error(`Line ${line}: Unknown function: ${namespace}.${funcName}`)
    }
    return fn(...args)
  }

  function execStatement(stmt) {
    switch (stmt.type) {
      case "Assignment": {
        const value = evalNode(stmt.expr)
        context.set(stmt.name, value)
        lastResult = value
        break
      }

      case "ExprStatement": {
        const value = evalNode(stmt.expr)
        lastResult = value
        break
      }

      case "IfElse": {
        const cond = evalNode(stmt.condition)
        const branch = cond ? stmt.then : (stmt.else || [])
        for (const s of branch) execStatement(s)
        break
      }

      case "ForLoop": {
        const iterable = evalNode(stmt.iterable)
        if (!Array.isArray(iterable)) {
          throw new Error(`Line ${stmt.line}: for..in requires an array, got ${typeof iterable}`)
        }
        for (const item of iterable) {
          context.set(stmt.variable, item)
          for (const s of stmt.body) execStatement(s)
        }
        break
      }

      default:
        throw new Error(`Line ${stmt.line || "?"}: Unknown statement type: ${stmt.type}`)
    }
  }

  for (const stmt of ast.statements) {
    execStatement(stmt)
  }

  return { lastResult, displayOutputs }
}

// ── Auto-detect output type ──────────────────────────────────────────────

function detectOutputType(value) {
  if (value === null || value === undefined) return { type: "text", data: "null" }
  if (typeof value === "string") return { type: "text", data: value }
  if (typeof value === "number") return { type: "text", data: String(value) }
  if (typeof value === "boolean") return { type: "text", data: String(value) }

  if (Array.isArray(value)) {
    if (value.length > 0 && typeof value[0] === "object" && value[0] !== null) {
      return { type: "table", data: value }
    }
    if (value.length > 0 && Array.isArray(value[0])) {
      return { type: "table", data: value }
    }
    return { type: "text", data: JSON.stringify(value, null, 2) }
  }

  if (typeof value === "object") {
    // Alignment result
    if (value.aligned_query && value.aligned_target) {
      return { type: "alignment", data: value }
    }
    // Table-like stats
    if (value.mean !== undefined || value.count !== undefined) {
      return { type: "table", data: [value] }
    }
    return { type: "text", data: JSON.stringify(value, null, 2) }
  }

  return { type: "text", data: String(value) }
}

function buildOutput(value, forcedType) {
  if (forcedType) {
    const data = forcedType === "text" ? String(value) : value
    return { type: forcedType, data }
  }
  return detectOutputType(value)
}

// ── Message handler ──────────────────────────────────────────────────────

self.onmessage = async function (e) {
  const { type, cellId, code, context: contextEntries } = e.data

  if (type !== "execute") return

  try {
    if (!wasmReady) await initWasm()

    // Reconstruct context from entries
    const context = new Map(contextEntries || [])

    const startTime = performance.now()

    // Tokenize -> Parse -> Interpret
    const tokens = tokenize(code)
    const ast = parse(tokens)
    const { lastResult, displayOutputs } = interpret(ast, context)

    const elapsed = Math.round(performance.now() - startTime)

    // Build output: prefer display() outputs, fall back to last result
    let output
    if (displayOutputs.length > 0) {
      const last = displayOutputs[displayOutputs.length - 1]
      output = buildOutput(last.value, last.outputType)
    } else if (lastResult !== undefined) {
      output = detectOutputType(lastResult)
    } else {
      output = { type: "text", data: "(no output)" }
    }

    output.timing_ms = elapsed

    self.postMessage({
      type: "result",
      cellId,
      output,
      context: Array.from(context.entries()),
    })
  } catch (err) {
    // Include line number from error message if available
    self.postMessage({
      type: "error",
      cellId,
      message: err.message || String(err),
    })
  }
}
