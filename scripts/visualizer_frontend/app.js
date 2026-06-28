(function () {
  var model = null
  var moduleByName = new Map()
  var parentIndex = new Map()
  var state = null

  var svg = document.getElementById("diagram")
  var moduleList = document.getElementById("moduleList")
  var moduleSearch = document.getElementById("moduleSearch")
  var traceInput = document.getElementById("traceInput")
  var NS = "http://www.w3.org/2000/svg"
  var elk = typeof ELK !== "undefined" ? new ELK() : null
  var netlistLayoutCache = new Map()

  function exprToText(expr) {
    if (expr == null) return ""
    if (typeof expr !== "object") return String(expr)
    for (var i = 0; i < ["ref", "literal", "value", "name"].length; i++) {
      var k = ["ref", "literal", "value", "name"][i]
      if (k in expr) return String(expr[k])
    }
    if (expr.type === "bit_select" || expr.type === "select") {
      var source = exprToText(expr.source || expr.base)
      if (expr.index) return source + "[" + exprToText(expr.index) + "]"
      if (expr.range && typeof expr.range === "object") {
        return source + "[" + exprToText(expr.range.msb) + ":" + exprToText(expr.range.lsb) + "]"
      }
      return source
    }
    if (expr.type === "concat") return "{" + (expr.parts || []).map(exprToText).join(", ") + "}"
    if (expr.type === "cond") return exprToText(expr.condition) + " ? " + exprToText(expr.true_expr) + " : " + exprToText(expr.false_expr)
    if ("left" in expr && "right" in expr) return exprToText(expr.left) + " " + (expr.op || "?") + " " + exprToText(expr.right)
    if ("operand" in expr) return (expr.op || "") + exprToText(expr.operand)
    return JSON.stringify(expr)
  }

  function widthToText(width) {
    if (width && typeof width === "object") return exprToText(width)
    if (width === null || width === undefined || width === "") return "1"
    return String(width)
  }

  function portSignature(port) {
    var dir = port.direction || ""
    var w = widthToText(port.width)
    var name = port.name || ""
    return w !== "1" ? dir + " [" + w + "] " + name : dir + " " + name
  }

  function buildVisualModel(design) {
    var modules = design.modules || []
    var moduleNames = new Set(modules.map(function (m) { return m.name }))
    var topName = (design.design_hierarchy && design.design_hierarchy.top) || (modules[0] && modules[0].name) || ""

    var visualModules = []

    modules.forEach(function (mod) {
      var modName = mod.name || "unknown"
      var ports = mod.ports || []
      var signals = mod.signals || []
      var instances = mod.instances || []
      var assignments = mod.assignments || []
      var signalNames = new Set(signals.map(function (s) { return s.name }))

      var nodes = ports.map(function (p) {
        return {
          id: "port:" + p.name,
          label: p.name || "",
          kind: "port " + (p.direction || ""),
          type: "port",
          direction: p.direction || "",
          width: widthToText(p.width),
          summary: portSignature(p),
          raw: p,
        }
      })

      instances.forEach(function (inst, index) {
        nodes.push({
          id: "inst:" + index + ":" + inst.name,
          label: inst.name || "",
          subtitle: inst.module || "",
          kind: "instance",
          type: "instance",
          isKnownModule: moduleNames.has(inst.module),
          summary: (inst.name || "") + ": " + (inst.module || ""),
          raw: inst,
        })
      })

      var edges = []
      var usedSignals = new Set()

      instances.forEach(function (inst, index) {
        var instId = "inst:" + index + ":" + inst.name
        ;(inst.port_connections || []).forEach(function (conn) {
          var connText = exprToText(conn.connection)
          if (!connText) return
          usedSignals.add(connText)
          var sourceId = signalNames.has(connText) ? "signal:" + connText : "external:" + connText
          edges.push({
            source: sourceId,
            target: instId,
            label: conn.port || "",
            signal: connText,
            kind: "connection",
          })
        })
      })

      assignments.forEach(function (assign) {
        var lhs = exprToText(assign.lhs)
        var rhs = exprToText(assign.rhs)
        if (lhs && rhs) {
          usedSignals.add(lhs)
          usedSignals.add(rhs)
          edges.push({
            source: signalNames.has(rhs) ? "signal:" + rhs : "external:" + rhs,
            target: signalNames.has(lhs) ? "signal:" + lhs : "external:" + lhs,
            label: "assign",
            signal: rhs + " -> " + lhs,
            kind: "assign",
          })
        }
      })

      var signalNodes = []
      signals.forEach(function (sig) {
        var name = sig.name || ""
        if (usedSignals.has(name) || signals.length <= 60) {
          signalNodes.push({
            id: "signal:" + name,
            label: name,
            kind: sig.type || "signal",
            type: "signal",
            width: widthToText(sig.width),
            summary: (sig.type || "signal") + " [" + widthToText(sig.width) + "] " + name,
            raw: sig,
          })
        }
      })

      var existingIds = new Set()
      nodes.concat(signalNodes).forEach(function (n) { existingIds.add(n.id) })

      var externalSet = new Set()
      edges.forEach(function (edge) {
        if (!existingIds.has(edge.source)) externalSet.add(edge.source)
        if (!existingIds.has(edge.target)) externalSet.add(edge.target)
      })
      var externalNodes = Array.from(externalSet).sort()

      nodes = nodes.concat(signalNodes)
      externalNodes.slice(0, 80).forEach(function (ext) {
        nodes.push({
          id: ext,
          label: ext.split(":")[1],
          kind: "external/literal",
          type: "external",
          summary: ext.split(":")[1],
          raw: { value: ext.split(":")[1] },
        })
      })

      var allowedIds = new Set(nodes.map(function (n) { return n.id }))
      edges = edges.filter(function (e) { return allowedIds.has(e.source) && allowedIds.has(e.target) })

      visualModules.push({
        name: modName,
        description: mod.description || "",
        isTop: modName === topName,
        counts: {
          ports: ports.length,
          signals: signals.length,
          instances: instances.length,
          assignments: assignments.length,
          alwaysBlocks: (mod.always_blocks || []).length,
        },
        ports: ports,
        signals: signals,
        instances: instances,
        nodes: nodes,
        edges: edges,
        raw: mod,
      })
    })

    return {
      project: design.project || {},
      top: topName,
      moduleCount: modules.length,
      modules: visualModules,
    }
  }

  function initVisualizer(visualModel) {
    model = visualModel
    moduleByName = new Map(model.modules.map(function (m) { return [m.name, m] }))
    parentIndex = buildParentIndex(model.modules)
    var initialIndex = Math.max(0, model.modules.findIndex(function (m) { return m.isTop }))
    state = {
      moduleIndex: initialIndex,
      navStack: [{ moduleName: (model.modules[initialIndex] || {}).name || model.top || "", via: "" }],
      view: "hierarchy",
      selected: null,
      scale: 1,
      tx: 60,
      ty: 60,
      needsFit: false,
      dragging: false,
      dragStart: null,
      didDrag: false,
      trace: "",
      expanded: new Set(),
      allExpanded: false,
    }

    document.getElementById("topName").textContent = model.top || "unknown"
    document.getElementById("moduleCount").textContent = model.moduleCount
    document.getElementById("uploadOverlay").style.display = "none"
    resetHierarchyExpansion()
    render()
  }

  function handleFile(file) {
    var reader = new FileReader()
    reader.onload = function (e) {
      try {
        var design = JSON.parse(e.target.result)
        var visualModel = buildVisualModel(design)
        initVisualizer(visualModel)
      } catch (err) {
        alert("Failed to parse JSON: " + err.message)
      }
    }
    reader.readAsText(file)
  }

  function currentModule() {
    var current = state.navStack[state.navStack.length - 1]
    return moduleByName.get(current && current.moduleName) || model.modules[state.moduleIndex] || emptyModule()
  }

  function emptyModule() {
    return { nodes: [], edges: [], counts: {}, instances: [], ports: [], signals: [] }
  }

  function el(name, attrs, parent) {
    if (attrs === undefined) attrs = {}
    if (parent === undefined) parent = null
    var node = document.createElementNS(NS, name)
    Object.keys(attrs).forEach(function (key) { node.setAttribute(key, attrs[key]) })
    if (parent) parent.appendChild(node)
    return node
  }

  function makeNode(id, label, type, detail, raw) {
    if (raw === undefined) raw = null
    return { id: id, label: label, type: type, detail: detail, raw: raw || { label: label, type: type, detail: detail } }
  }

  function buildParentIndex(modules) {
    var index = new Map()
    modules.forEach(function (parent) {
      ;(parent.instances || []).forEach(function (inst, instIndex) {
        if (!inst.module || !moduleByName.has(inst.module)) return
        if (!index.has(inst.module)) index.set(inst.module, [])
        index.get(inst.module).push({
          parentName: parent.name,
          instanceName: inst.name || "(unnamed)",
          instanceIndex: instIndex,
          instance: inst,
        })
      })
    })
    return index
  }

  function graphForHierarchy(mod) {
    var rootId = rootNodeId(mod)
    var nodes = []
    var edges = []
    var path = findPathFromTop(mod.name)

    path.slice(0, -1).forEach(function (entry, index) {
      var id = ancestorNodeId(entry, index)
      var nextId = index === path.length - 2 ? rootId : ancestorNodeId(path[index + 1], index + 1)
      var node = makeNode(id, entry.moduleName, "parent", entry.via || (index === 0 ? "root" : "parent"), entry)
      node.depth = index
      node.expandable = false
      node.expanded = false
      node.pathIndex = index
      nodes.push(node)
      edges.push({ source: id, target: nextId, label: path[index + 1].via || "", kind: "parent-link" })
    })

    var root = makeNode(rootId, mod.name, "module", mod.isTop ? "top module" : "current module", mod.raw)
    root.depth = Math.max(0, path.length - 1)
    root.expandable = hasVisibleChildren(mod)
    root.expanded = state.expanded.has(rootId)
    nodes.push(root)

    if (state.expanded.has(rootId)) {
      appendHierarchyChildren(mod, rootId, mod.name, root.depth + 1, nodes, edges)
    }
    return layoutHierarchyGraph(nodes, edges)
  }

  function findPathFromTop(targetModuleName) {
    var topName = model.top || (model.modules[0] && model.modules[0].name) || targetModuleName
    if (targetModuleName === topName) return [{ moduleName: topName, via: "" }]
    var queue = [{ moduleName: topName, via: "", path: [{ moduleName: topName, via: "" }] }]
    var seen = new Set([topName])
    while (queue.length) {
      var current = queue.shift()
      var mod = moduleByName.get(current.moduleName)
      if (!mod) continue
      for (var i = 0; i < (mod.instances || []).length; i++) {
        var inst = mod.instances[i]
        if (!inst.module || !moduleByName.has(inst.module)) continue
        var nextPath = current.path.concat({ moduleName: inst.module, via: inst.name || "(unnamed)" })
        if (inst.module === targetModuleName) return nextPath
        var seenKey = current.moduleName + "->" + inst.name + "->" + inst.module
        if (seen.has(seenKey)) continue
        seen.add(seenKey)
        queue.push({ moduleName: inst.module, via: inst.name || "(unnamed)", path: nextPath })
      }
    }
    var parents = parentIndex.get(targetModuleName) || []
    if (parents.length) {
      return [
        { moduleName: parents[0].parentName, via: "" },
        { moduleName: targetModuleName, via: parents[0].instanceName },
      ]
    }
    return [{ moduleName: targetModuleName, via: "" }]
  }

  function ancestorNodeId(entry, index) {
    return "ancestor:" + index + ":" + entry.moduleName + ":" + (entry.via || "root")
  }

  function appendHierarchyChildren(mod, parentId, path, depth, nodes, edges) {
    var instances = mod.instances || []
    if (instances.length > 50) {
      var byType = new Map()
      instances.forEach(function (inst) {
        var type = inst.module || "unknown"
        if (!byType.has(type)) byType.set(type, [])
        byType.get(type).push(inst)
      })
      ;[...byType.entries()].sort(function (a, b) {
        return b[1].length - a[1].length || a[0].localeCompare(b[0])
      }).forEach(function (pair) {
        var type = pair[0]
        var list = pair[1]
        var id = path + "/group:" + type
        var known = moduleByName.has(type)
        var node = makeNode(id, type, known ? "module" : "group", list.length + " instances", { module: type, instances: list })
        node.depth = depth
        node.expandable = known && hasVisibleChildren(moduleByName.get(type))
        node.expanded = state.expanded.has(id)
        nodes.push(node)
        edges.push({ source: parentId, target: id, label: String(list.length), kind: "hierarchy" })
        if (node.expanded) appendHierarchyChildren(moduleByName.get(type), id, id, depth + 1, nodes, edges)
      })
      return
    }

    instances.forEach(function (inst, index) {
      var id = path + "/inst:" + index + ":" + (inst.name || "unnamed")
      var targetMod = moduleByName.get(inst.module || "")
      var node = makeNode(id, inst.name || "(unnamed)", "instance", inst.module || "instance", inst)
      node.depth = depth
      node.expandable = Boolean(targetMod && hasVisibleChildren(targetMod))
      node.expanded = state.expanded.has(id)
      nodes.push(node)
      edges.push({ source: parentId, target: id, label: inst.module || "", kind: "hierarchy" })
      if (node.expanded) appendHierarchyChildren(targetMod, id, id, depth + 1, nodes, edges)
    })
  }

  function hasVisibleChildren(mod) {
    return Boolean(mod && Array.isArray(mod.instances) && mod.instances.length)
  }

  function rootNodeId(mod) {
    return "module:" + (mod && mod.name ? mod.name : "unknown")
  }

  function layoutHierarchyGraph(nodes, edges) {
    var positions = new Map()
    var depthCounts = new Map()
    var maxDepth = 0
    var maxY = 0
    nodes.forEach(function (node) {
      var depth = node.depth || 0
      var index = depthCounts.get(depth) || 0
      depthCounts.set(depth, index + 1)
      maxDepth = Math.max(maxDepth, depth)
      var x = 60 + depth * 430
      var y = 40 + index * 82
      var w = node.type === "instance" ? 240 : 230
      positions.set(node.id, { x: x, y: y, w: w, h: 58 })
      maxY = Math.max(maxY, y + 100)
    })
    return { nodes: nodes, edges: edges, positions: positions, width: Math.max(1280, 60 + (maxDepth + 1) * 430 + 280), height: Math.max(620, maxY + 80) }
  }

  function graphForModule(mod) {
    var nodes = []
    var edges = []
    var instances = mod.instances || []
    nodes.push(makeNode("group:inputs", "Inputs", "group", String((mod.ports || []).filter(function (p) { return p.direction === "input" }).length)))
    nodes.push(makeNode("group:outputs", "Outputs", "group", String((mod.ports || []).filter(function (p) { return p.direction === "output" }).length)))
    nodes.push(makeNode("group:signals", "Internal signals", "group", String((mod.signals || []).length)))
    instances.forEach(function (inst, index) {
      nodes.push(makeNode("inst:" + index + ":" + inst.name, inst.name || "(unnamed)", "instance", inst.module || "instance", inst))
    })

    var signalNames = new Set((mod.signals || []).map(function (s) { return s.name }))
    instances.forEach(function (inst, index) {
      var target = "inst:" + index + ":" + inst.name
      var inputCount = 0
      var internalCount = 0
      ;(inst.port_connections || []).forEach(function (conn) {
        var value = exprToText(conn.connection)
        if (!value) return
        if (signalNames.has(value)) internalCount += 1
        else inputCount += 1
      })
      if (inputCount) edges.push({ source: "group:inputs", target: target, label: String(inputCount), kind: "summary" })
      if (internalCount) edges.push({ source: "group:signals", target: target, label: String(internalCount), kind: "summary" })
    })
    if ((mod.assignments || []).length) {
      edges.push({ source: "group:signals", target: "group:outputs", label: String(mod.assignments.length), kind: "summary" })
    }
    return layoutGraph(nodes, edges, "columns")
  }

  function graphForTrace(mod) {
    var term = state.trace.trim().toLowerCase()
    if (!term) {
      var node = makeNode("trace-empty", "Enter a trace query", "group", "signal, port, or instance")
      node.traceLane = "center"
      return layoutTraceGraph([node], [])
    }
    var nodes = new Map()
    var edges = []
    var signalNames = new Set((mod.signals || []).map(function (s) { return s.name }))
    var add = function (node) { nodes.set(node.id, node) }

    ;(mod.instances || []).forEach(function (inst, index) {
      var instId = "inst:" + index + ":" + inst.name
      var instMatches = [inst.name, inst.module].join(" ").toLowerCase().includes(term)
      ;(inst.port_connections || []).forEach(function (conn) {
        var value = exprToText(conn.connection)
        var hit = instMatches || String(conn.port || "").toLowerCase().includes(term) || value.toLowerCase().includes(term)
        if (!hit) return
        var sigId = (signalNames.has(value) ? "signal:" : "external:") + value
        var portId = "port:" + index + ":" + conn.port
        var sigNode = makeNode(sigId, value || "(open)", signalNames.has(value) ? "signal" : "external", "signal/expression", conn)
        sigNode.traceLane = "source"
        var instNode = makeNode(instId, inst.name || "(unnamed)", "instance", inst.module || "instance", inst)
        instNode.traceLane = "instance"
        var portNode = makeNode(portId, conn.port || "(port)", "group", "port", conn)
        portNode.traceLane = "port"
        add(sigNode)
        add(instNode)
        add(portNode)
        edges.push({ source: sigId, target: instId, label: "", kind: "trace" })
        edges.push({ source: instId, target: portId, label: conn.port || "", kind: "trace" })
      })
    })

    ;(mod.assignments || []).forEach(function (assign) {
      var lhs = exprToText(assign.lhs)
      var rhs = exprToText(assign.rhs)
      if (![lhs, rhs, assign.id].join(" ").toLowerCase().includes(term)) return
      var lhsId = (signalNames.has(lhs) ? "signal:" : "external:") + lhs
      var rhsId = (signalNames.has(rhs) ? "signal:" : "external:") + rhs
      var assignId = "assign:" + (assign.id || lhs + ":" + rhs)
      var rhsNode = makeNode(rhsId, rhs, signalNames.has(rhs) ? "signal" : "external", "rhs", assign)
      rhsNode.traceLane = "source"
      var assignNode = makeNode(assignId, assign.id || "assign", "group", "assign", assign)
      assignNode.traceLane = "instance"
      var lhsNode = makeNode(lhsId, lhs, signalNames.has(lhs) ? "signal" : "external", "lhs", assign)
      lhsNode.traceLane = "port"
      add(rhsNode)
      add(assignNode)
      add(lhsNode)
      edges.push({ source: rhsId, target: assignId, label: "rhs", kind: "trace" })
      edges.push({ source: assignId, target: lhsId, label: "lhs", kind: "trace" })
    })

    if (!nodes.size) {
      var node = makeNode("trace-empty", "No trace result", "group", state.trace)
      node.traceLane = "center"
      add(node)
    }
    return layoutTraceGraph([...nodes.values()], edges)
  }

  function layoutTraceGraph(nodes, edges) {
    var positions = new Map()
    var lanes = { source: [], instance: [], port: [], center: [] }
    nodes.forEach(function (node) { (lanes[node.traceLane || "center"] || lanes.center).push(node) })
    var xByLane = { source: 70, instance: 500, port: 930, center: 420 }
    var maxY = 0
    Object.keys(lanes).forEach(function (lane) {
      lanes[lane].forEach(function (node, index) {
        var y = 50 + index * 86
        positions.set(node.id, { x: xByLane[lane], y: y, w: lane === "center" ? 280 : 260, h: 58 })
        maxY = Math.max(maxY, y + 92)
      })
    })
    return { nodes: nodes, edges: edges, positions: positions, width: 1260, height: Math.max(620, maxY + 80) }
  }

  function layoutGraph(nodes, edges, mode) {
    var positions = new Map()
    if (mode === "radial") {
      positions.set(nodes[0].id, { x: 520, y: 280, w: 230, h: 64 })
      var rest = nodes.slice(1)
      var radiusX = Math.max(360, Math.min(780, rest.length * 34))
      var radiusY = Math.max(220, Math.min(520, rest.length * 18))
      rest.forEach(function (node, i) {
        var angle = (Math.PI * 2 * i) / Math.max(1, rest.length)
        positions.set(node.id, { x: 520 + Math.cos(angle) * radiusX, y: 280 + Math.sin(angle) * radiusY, w: 230, h: 58 })
      })
      return { nodes: nodes, edges: edges, positions: positions, width: radiusX * 2 + 1000, height: radiusY * 2 + 760 }
    }

    var columns = { group: [], module: [], instance: [], signal: [], external: [] }
    nodes.forEach(function (node) { (columns[node.type] || columns.group).push(node) })
    ;[
      ["group", 60],
      ["module", 60],
      ["instance", 360],
      ["signal", 700],
      ["external", 1000],
    ].forEach(function (pair) {
      var type = pair[0]
      var x = pair[1]
      columns[type].forEach(function (node, i) { positions.set(node.id, { x: x, y: 40 + i * 82, w: type === "instance" ? 240 : 220, h: 58 }) })
    })
    var maxCount = Math.max.apply(null, Object.keys(columns).map(function (k) { return columns[k].length }).concat([1]))
    return { nodes: nodes, edges: edges, positions: positions, width: 1280, height: Math.max(620, 40 + maxCount * 82 + 80) }
  }

  function graphForNetlist(mod) {
    var cacheKey = "netlist:" + mod.name
    var cached = netlistLayoutCache.get(cacheKey)
    if (cached && cached.status === "done") return graphFromElk(cached.layout, cached.meta)
    if (cached && cached.status === "pending") return loadingGraph("ELK layout running", "netlist schematic")
    if (!elk) return loadingGraph("ELK unavailable", "cannot layout netlist")

    var netlist = buildNetlistElkGraph(mod)
    netlistLayoutCache.set(cacheKey, { status: "pending", meta: netlist.meta })
    elk.layout(netlist.graph).then(function (layout) {
      netlistLayoutCache.set(cacheKey, { status: "done", layout: layout, meta: netlist.meta })
      if (state.view === "netlist" && currentModule().name === mod.name) {
        state.needsFit = true
        renderDiagram()
      }
    }).catch(function (error) {
      netlistLayoutCache.set(cacheKey, { status: "error", error: error, meta: netlist.meta })
    })
    return loadingGraph("ELK layout running", "netlist schematic")
  }

  function loadingGraph(label, detail) {
    var node = makeNode("loading", label, "group", detail)
    node.traceLane = "center"
    return layoutTraceGraph([node], [])
  }

  function safeId(value) {
    return String(value || "unnamed").replace(/[^a-zA-Z0-9_$:.-]/g, "_")
  }

  function inferPortDirection(portName) {
    var name = String(portName || "").toLowerCase()
    if (/(^|_)(out|o|result|resp|data_o|valid_o|ready_o|addr_o|value_o)($|_)/.test(name)) return "output"
    return "input"
  }

  function buildNetlistElkGraph(mod) {
    var children = []
    var edges = []
    var meta = { nodes: new Map(), edges: new Map() }
    var nets = new Map()
    var nodeIds = new Set()

    function ensureNet(name) {
      var key = String(name || "(open)")
      if (!nets.has(key)) nets.set(key, { name: key, drivers: [], riders: [] })
      return nets.get(key)
    }
    function portTextWidth(port) {
      return Math.min(230, Math.max(48, String(port.name || "").length * 7 + 16))
    }
    function nodeSize(label, ports) {
      var inputs = ports.filter(function (p) { return p.direction !== "output" })
      var outputs = ports.filter(function (p) { return p.direction === "output" })
      var leftWidth = inputs.reduce(function (max, p) { return Math.max(max, portTextWidth(p)) }, 72)
      var rightWidth = outputs.reduce(function (max, p) { return Math.max(max, portTextWidth(p)) }, 72)
      var titleWidth = String(label || "").length * 9 + 70
      return {
        width: Math.max(260, Math.min(640, Math.max(titleWidth, leftWidth + rightWidth + 72))),
        height: Math.max(86, 64 + Math.max(inputs.length, outputs.length, 1) * 18),
      }
    }
    function addNode(id, label, kind, raw, ports) {
      if (nodeIds.has(id)) return
      nodeIds.add(id)
      var size = nodeSize(label, ports)
      var sideCounts = { input: 0, output: 0 }
      var indexedPorts = ports.map(function (port) {
        var side = port.direction === "output" ? "output" : "input"
        var sideIndex = sideCounts[side]++
        return { name: port.name, direction: port.direction, sideIndex: sideIndex, raw: port.raw || port }
      })
      var child = {
        id: id,
        width: size.width,
        height: size.height,
        ports: indexedPorts.map(function (port) {
          var side = port.direction === "output" ? "output" : "input"
          var y = 64 + (port.sideIndex || 0) * 18
          return {
            id: id + "." + safeId(port.name),
            x: side === "output" ? size.width : -8,
            y: y,
            width: 8,
            height: 8,
            layoutOptions: {
              "elk.port.side": side === "output" ? "EAST" : "WEST",
              "elk.port.index": port.sideIndex,
            },
            hwMeta: port,
          }
        }),
        layoutOptions: { "elk.portConstraints": "FIXED_POS" },
      }
      children.push(child)
      meta.nodes.set(id, { id: id, label: label, kind: kind, raw: raw, ports: indexedPorts })
    }
    function portRef(nodeId, portName) {
      return nodeId + "." + safeId(portName)
    }
    function addEndpoint(netName, endpoint, role) {
      var net = ensureNet(netName)
      net[role].push(endpoint)
    }

    var modulePorts = mod.ports || []
    var topInPorts = modulePorts.filter(function (p) { return p.direction === "input" })
    var topOutPorts = modulePorts.filter(function (p) { return p.direction === "output" })
    if (topInPorts.length) addNode("$inputs", "Module inputs", "io", topInPorts, topInPorts.map(function (p) { return { name: p.name, direction: "output", raw: p } }))
    if (topOutPorts.length) addNode("$outputs", "Module outputs", "io", topOutPorts, topOutPorts.map(function (p) { return { name: p.name, direction: "input", raw: p } }))
    topInPorts.forEach(function (p) { addEndpoint(p.name, { nodeId: "$inputs", portName: p.name }, "drivers") })
    topOutPorts.forEach(function (p) { addEndpoint(p.name, { nodeId: "$outputs", portName: p.name }, "riders") })

    ;(mod.instances || []).forEach(function (inst, index) {
      var instId = "inst:" + index + ":" + safeId(inst.name)
      var moduleDef = moduleByName.get(inst.module || "")
      var conns = inst.port_connections || []
      var ports = conns.map(function (conn) {
        var defPort = moduleDef && (moduleDef.ports || []).find(function (p) { return p.name === conn.port })
        return { name: conn.port || "port", direction: defPort ? defPort.direction : inferPortDirection(conn.port), raw: conn }
      })
      addNode(instId, inst.name || "(unnamed)", "instance", inst, ports)
      conns.forEach(function (conn) {
        var netName = exprToText(conn.connection)
        if (!netName) return
        var p = ports.find(function (x) { return x.name === conn.port }) || { direction: "input" }
        addEndpoint(netName, { nodeId: instId, portName: conn.port || "port" }, p.direction === "output" ? "drivers" : "riders")
      })
    })

    ;(mod.assignments || []).forEach(function (assign, index) {
      var rhs = exprToText(assign.rhs)
      var lhs = exprToText(assign.lhs)
      if (!rhs || !lhs) return
      var assignId = "assign:" + safeId(assign.id || index)
      addNode(assignId, assign.id || "assign", "assign", assign, [
        { name: "rhs", direction: "input", raw: assign.rhs },
        { name: "lhs", direction: "output", raw: assign.lhs },
      ])
      addEndpoint(rhs, { nodeId: assignId, portName: "rhs" }, "riders")
      addEndpoint(lhs, { nodeId: assignId, portName: "lhs" }, "drivers")
    })

    var edgeIndex = 0
    nets.forEach(function (net) {
      if (!net.drivers.length || !net.riders.length) return
      net.drivers.forEach(function (driver) {
        net.riders.forEach(function (rider) {
          if (!nodeIds.has(driver.nodeId) || !nodeIds.has(rider.nodeId)) return
          var edgeId = "netedge:" + edgeIndex++
          edges.push({
            id: edgeId,
            sources: [portRef(driver.nodeId, driver.portName)],
            targets: [portRef(rider.nodeId, rider.portName)],
            labels: [{ text: net.name, width: Math.max(24, net.name.length * 7 + 14), height: 14 }],
          })
          meta.edges.set(edgeId, { id: edgeId, label: net.name, driver: driver, rider: rider })
        })
      })
    })

    return {
      meta: meta,
      graph: {
        id: "netlist:" + mod.name,
        layoutOptions: {
          "elk.algorithm": "layered",
          "elk.direction": "RIGHT",
          "elk.edgeRouting": "ORTHOGONAL",
          "elk.layered.spacing.nodeNodeBetweenLayers": "90",
          "elk.spacing.nodeNode": "50",
          "elk.layered.nodePlacement.favorStraightEdges": "true",
          "elk.layered.crossingMinimization.strategy": "LAYER_SWEEP",
        },
        children: children,
        edges: edges,
      },
    }
  }

  function graphFromElk(layout, meta) {
    var nodes = (layout.children || []).map(function (child) {
      var info = meta.nodes.get(child.id) || {}
      var detail = info.kind === "instance" && info.raw && info.raw.module ? info.raw.module : (info.kind || "netlist")
      var node = makeNode(child.id, info.label || child.id, info.kind || "instance", detail, info.raw || {})
      node.elk = child
      node.ports = (info.ports || []).map(function (port, index) { return { name: port.name, direction: port.direction, sideIndex: port.sideIndex, elk: (child.ports || [])[index] || null } })
      return node
    })
    var positions = new Map()
    nodes.forEach(function (node) {
      positions.set(node.id, { x: node.elk.x || 0, y: node.elk.y || 0, w: node.elk.width || 160, h: node.elk.height || 70 })
    })
    var elkEdges = (layout.edges || []).map(function (edge) {
      var info = meta.edges.get(edge.id) || {}
      return {
        id: edge.id,
        kind: "netlist",
        label: info.label || (edge.labels && edge.labels[0] ? edge.labels[0].text : "") || "",
        elk: edge,
        source: edge.sources && edge.sources[0],
        target: edge.targets && edge.targets[0],
        driver: info.driver || null,
        rider: info.rider || null,
      }
    })
    return { nodes: nodes, edges: elkEdges, positions: positions, width: (layout.width || 1000) + 80, height: (layout.height || 620) + 80, elk: true }
  }

  function isSelectedEdge(edge) {
    return Boolean(state.selected && state.selected.type === "edge" && state.selected.data && state.selected.data.id === edge.id)
  }

  function isSelectedPort(node, port) {
    if (!state.selected || state.selected.type !== "edge" || !state.selected.data) return false
    var edge = state.selected.data
    return Boolean(
      (edge.driver && edge.driver.nodeId === node.id && edge.driver.portName === port.name) ||
      (edge.rider && edge.rider.nodeId === node.id && edge.rider.portName === port.name)
    )
  }

  function edgeLabelAnchor(points) {
    var best = points[Math.floor(points.length / 2)] || points[0]
    var bestLength = -1
    for (var i = 0; i < points.length - 1; i += 1) {
      var a = points[i]
      var b = points[i + 1]
      var length = Math.abs(b.x - a.x) + Math.abs(b.y - a.y)
      if (length > bestLength) {
        bestLength = length
        best = { x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 }
      }
    }
    return best
  }

  function renderNetlistPorts(group, node, pos) {
    el("line", { x1: 12, y1: 52, x2: pos.w - 12, y2: 52, class: "port-divider" }, group)
    node.ports.forEach(function (port) {
      var side = port.direction === "output" ? "output" : "input"
      var elkPort = port.elk || {}
      var portCenterX = Number.isFinite(elkPort.x) ? elkPort.x + (elkPort.width || 8) / 2 : (side === "output" ? pos.w : 0)
      var portCenterY = Number.isFinite(elkPort.y) ? elkPort.y + (elkPort.height || 8) / 2 : 64 + (port.sideIndex || 0) * 18
      var textY = portCenterY + 4
      var textX = side === "output" ? pos.w - 16 : 16
      var maxWidth = Math.max(56, pos.w / 2 - 30)
      var selected = isSelectedPort(node, port)
      var portGroup = el("g", { class: "port-row " + side + (selected ? " selected" : "") }, group)
      el("title", {}, portGroup).textContent = (port.direction || "input") + " " + (port.name || "port")
      el("circle", { cx: portCenterX, cy: portCenterY, r: selected ? 4.5 : 3.2, class: "port-dot " + side }, portGroup)
      var text = el("text", { x: textX, y: textY, class: "port-label " + side, "text-anchor": side === "output" ? "end" : "start" }, portGroup)
      text.textContent = fitTextToWidth(port.name || "port", maxWidth, 10)
    })
  }

  function activeGraph() {
    var mod = currentModule()
    if (state.view === "netlist") return graphForNetlist(mod)
    if (state.view === "module") return graphForModule(mod)
    if (state.view === "trace") return graphForTrace(mod)
    return graphForHierarchy(mod)
  }

  function renderModuleList() {
    var term = moduleSearch.value.trim().toLowerCase()
    moduleList.innerHTML = ""
    model.modules.forEach(function (mod, index) {
      var haystack = [mod.name].concat(mod.instances.map(function (i) { return i.name })).concat(mod.instances.map(function (i) { return i.module })).join(" ").toLowerCase()
      if (term && !haystack.includes(term)) return
      var item = document.createElement("button")
      item.className = "module-item" + (index === state.moduleIndex ? " active" : "")
      item.innerHTML = '<div><div class="module-name">' + escapeHtml(mod.name) + (mod.isTop ? ' <span class="badge">top</span>' : "") + '</div><div class="module-meta">' + mod.counts.instances + " instances &middot; " + mod.counts.signals + " signals</div></div><span class=\"badge\">" + mod.counts.ports + " ports</span>"
      item.addEventListener("click", function () {
        navigateToModule(index)
        render()
      })
      moduleList.appendChild(item)
    })
  }

  function renderDiagram() {
    var graph = activeGraph()
    if (state.needsFit) {
      var w = Math.max(1, svg.clientWidth || 900)
      var h = Math.max(1, svg.clientHeight || 620)
      var pad = state.view === "netlist" ? 36 : 54
      var s = Math.min(1, Math.max(0.035, Math.min((w - pad * 2) / Math.max(1, graph.width), (h - pad * 2) / Math.max(1, graph.height))))
      state.scale = s
      state.tx = Math.max(10, (w - graph.width * s) / 2)
      state.ty = Math.max(10, (h - graph.height * s) / 2)
      state.needsFit = false
    }
    svg.innerHTML = ""
    svg.setAttribute("viewBox", "0 0 " + svg.clientWidth + " " + svg.clientHeight)
    var defs = el("defs", {}, svg)
    var marker = el("marker", { id: "arrow", viewBox: "0 0 10 10", refX: "9", refY: "5", markerWidth: "7", markerHeight: "7", orient: "auto-start-reverse" }, defs)
    el("path", { d: "M 0 0 L 10 5 L 0 10 z", fill: "#7d8da1" }, marker)
    var selMarker = el("marker", { id: "arrow-selected", viewBox: "0 0 10 10", refX: "9", refY: "5", markerWidth: "8", markerHeight: "8", orient: "auto-start-reverse" }, defs)
    el("path", { d: "M 0 0 L 10 5 L 0 10 z", fill: "#f97316" }, selMarker)
    var root = el("g", { transform: "translate(" + state.tx + " " + state.ty + ") scale(" + state.scale + ")" }, svg)
    el("rect", { x: 0, y: 0, width: graph.width, height: graph.height, fill: "rgba(255,255,255,.48)", stroke: "#d7dde5", rx: 8 }, root)
    var edgePathLayer = el("g", { class: "edge-path-layer" }, root)
    var edgeLabelLayer = el("g", { class: "edge-label-layer" }, root)
    var selEdgeLabelLayer = el("g", { class: "edge-label-layer selected-label-layer" }, root)
    var nodeLayer = el("g", {}, root)

    function onEdgeSelect(evt, edge) {
      evt.stopPropagation()
      evt.preventDefault()
      state.selected = { type: "edge", data: edge }
      renderDiagram()
    }

    graph.edges.forEach(function (edge) {
      var edgeSelected = isSelectedEdge(edge)
      if (graph.elk && edge.elk && edge.elk.sections && edge.elk.sections.length) {
        var section = edge.elk.sections[0]
        var points = [section.startPoint].concat(section.bendPoints || [], [section.endPoint])
        var d = points.map(function (p, i) { return (i === 0 ? "M" : "L") + " " + p.x + " " + p.y }).join(" ")
        var p = el("path", {
          d: d,
          class: "edge " + (edge.kind || "") + (edgeSelected ? " selected" : ""),
          "marker-end": edgeSelected ? "url(#arrow-selected)" : "url(#arrow)",
        }, edgePathLayer)
        var hit = el("path", { d: d, class: "edge-hit" }, edgePathLayer)
        p.addEventListener("pointerdown", function (e) { onEdgeSelect(e, edge) })
        hit.addEventListener("pointerdown", function (e) { onEdgeSelect(e, edge) })
        p.addEventListener("click", function (e) { e.stopPropagation() })
        hit.addEventListener("click", function (e) { e.stopPropagation() })
        if (edge.label && points.length >= 2) {
          var lp = edgeLabelAnchor(points)
          drawEdgeLabel(edgeSelected ? selEdgeLabelLayer : edgeLabelLayer, edge.label, lp.x, lp.y, 140, { selected: edgeSelected, onSelect: function (e) { onEdgeSelect(e, edge) } })
        }
        return
      }
      var a = graph.positions.get(edge.source)
      var b = graph.positions.get(edge.target)
      if (!a || !b) return
      var x1 = a.x + a.w
      var y1 = a.y + a.h / 2
      var x2 = b.x
      var y2 = b.y + b.h / 2
      var mid = Math.max(x1 + 34, (x1 + x2) / 2)
      var p = el("path", {
        d: "M " + x1 + " " + y1 + " C " + mid + " " + y1 + ", " + mid + " " + y2 + ", " + x2 + " " + y2,
        class: "edge " + (edge.kind || "") + (edgeSelected ? " selected" : ""),
        "marker-end": edgeSelected ? "url(#arrow-selected)" : "url(#arrow)",
      }, edgePathLayer)
      var hit = el("path", { d: "M " + x1 + " " + y1 + " C " + mid + " " + y1 + ", " + mid + " " + y2 + ", " + x2 + " " + y2, class: "edge-hit" }, edgePathLayer)
      p.addEventListener("pointerdown", function (e) { onEdgeSelect(e, edge) })
      hit.addEventListener("pointerdown", function (e) { onEdgeSelect(e, edge) })
      p.addEventListener("click", function (e) { e.stopPropagation() })
      hit.addEventListener("click", function (e) { e.stopPropagation() })
      if (edge.label) {
        var gap = Math.max(34, x2 - x1)
        var maxWidth = Math.max(28, Math.min(180, gap - 70))
        var labelX = x1 + 18 + maxWidth / 2
        var labelY = (y1 + y2) / 2
        drawEdgeLabel(edgeSelected ? selEdgeLabelLayer : edgeLabelLayer, edge.label, labelX, labelY, maxWidth, { selected: edgeSelected, onSelect: function (e) { onEdgeSelect(e, edge) } })
      }
    })

    graph.nodes.forEach(function (node) {
      var pos = graph.positions.get(node.id)
      if (!pos) return
      var selected = state.selected && state.selected.data && state.selected.data.id === node.id
      var g = el("g", { class: "node " + node.type + (selected ? " selected" : ""), transform: "translate(" + pos.x + " " + pos.y + ")", tabindex: "0" }, nodeLayer)
      el("rect", { width: pos.w, height: pos.h }, g)
      el("title", {}, g).textContent = [node.label, node.detail].filter(Boolean).join(" &middot; ")
      var title = el("text", { x: 13, y: 22, class: "node-title" }, g)
      title.textContent = fitTextToWidth(node.label, pos.w - (node.expandable ? 48 : 26), 13)
      var kind = el("text", { x: 13, y: 42, class: "node-kind" }, g)
      kind.textContent = fitTextToWidth(node.detail || node.type, pos.w - (node.expandable ? 48 : 26), 11)
      if (graph.elk && Array.isArray(node.ports) && node.ports.length) {
        renderNetlistPorts(g, node, pos)
      }
      if (node.expandable) {
        var control = el("g", { class: "expand-control", transform: "translate(" + (pos.w - 25) + " 12)", tabindex: "0" }, g)
        el("circle", { cx: 9, cy: 9, r: 9 }, control)
        var symbol = el("text", { x: 9, y: 13, "text-anchor": "middle" }, control)
        symbol.textContent = node.expanded ? "−" : "+"
        control.addEventListener("pointerdown", function (evt) { evt.stopPropagation() })
        control.addEventListener("click", function (evt) {
          evt.stopPropagation()
          toggleExpanded(node.id)
        })
        control.addEventListener("keydown", function (evt) {
          if (evt.key === "Enter" || evt.key === " ") {
            evt.preventDefault()
            evt.stopPropagation()
            toggleExpanded(node.id)
          }
        })
      }
      g.addEventListener("pointerdown", function (evt) { evt.stopPropagation() })
      g.addEventListener("click", function (evt) {
        evt.stopPropagation()
        handleNodeActivation(node)
      })
      g.addEventListener("keydown", function (evt) {
        if (evt.key === "Enter" || evt.key === " ") {
          evt.preventDefault()
          handleNodeActivation(node)
        }
      })
    })

    updateOverview()
    updateInspector()
  }

  function drawEdgeLabel(parent, label, x, y, maxWidth, options) {
    if (options === undefined) options = {}
    var textValue = String(label || "")
    var estimatedWidth = Math.max(24, textValue.length * 6.2 + 14)
    var labelGroup = el("g", { class: "edge-label-group" + (options.selected ? " selected" : "") }, parent)
    el("rect", { x: x - estimatedWidth / 2, y: y - 10, width: estimatedWidth, height: 20, rx: 5, ry: 5, class: "edge-label-bg" }, labelGroup)
    var text = el("text", { x: x, y: y, class: "edge-label", "text-anchor": "middle" }, labelGroup)
    text.textContent = textValue
    el("title", {}, labelGroup).textContent = String(label || "")
    if (options.onSelect) {
      labelGroup.addEventListener("pointerdown", options.onSelect)
      labelGroup.addEventListener("click", function (e) { e.stopPropagation() })
    }
  }

  function handleNodeActivation(node) {
    if (canDrillInto(node)) {
      drillInto(node)
      return
    }
    state.selected = { type: "node", data: node }
    updateInspector()
    renderDiagram()
  }

  function fitTextToWidth(value, maxWidth, fontSize) {
    var text = String(value || "")
    var avg = fontSize * 0.58
    var maxChars = Math.max(4, Math.floor(maxWidth / avg))
    if (text.length <= maxChars) return text
    return text.slice(0, Math.max(1, maxChars - 1)) + "…"
  }

  function drillInto(node) {
    var moduleName = ""
    var via = ""
    if (node.type === "instance") {
      moduleName = node.detail
      via = node.label
    } else if (node.type === "group" && moduleByName.has(node.label)) {
      moduleName = node.label
      via = node.raw && Array.isArray(node.raw.instances) ? node.raw.instances.length + "x" : ""
    } else if (node.type === "parent") {
      var parentIndex = model.modules.findIndex(function (m) { return m.name === node.label })
      if (parentIndex >= 0) {
        navigateToModule(parentIndex)
        render()
      }
      return
    }
    if (!moduleName || !moduleByName.has(moduleName)) return
    pushModule(moduleName, via)
    resetViewPosition()
    render()
  }

  function canDrillInto(node) {
    var current = currentModule().name
    if (!node) return false
    if (node.type === "instance") return moduleByName.has(node.detail) && node.detail !== current
    if (node.type === "group") return moduleByName.has(node.label) && node.label !== current
    if (node.type === "parent") return moduleByName.has(node.label) && node.label !== current
    return false
  }

  function pushModule(moduleName, via) {
    var nextIndex = model.modules.findIndex(function (m) { return m.name === moduleName })
    if (nextIndex < 0) return
    state.moduleIndex = nextIndex
    state.navStack.push({ moduleName: moduleName, via: via || "" })
    resetHierarchyExpansion()
  }

  function navigateToModule(index) {
    var mod = model.modules[index]
    if (!mod) return
    state.moduleIndex = index
    state.navStack = [{ moduleName: mod.name, via: "" }]
    resetHierarchyExpansion()
    resetViewPosition()
  }

  function goToCrumb(index) {
    state.navStack = state.navStack.slice(0, index + 1)
    var mod = currentModule()
    state.moduleIndex = Math.max(0, model.modules.findIndex(function (m) { return m.name === mod.name }))
    resetHierarchyExpansion()
    resetViewPosition()
    render()
  }

  function toggleExpanded(nodeId) {
    if (state.expanded.has(nodeId)) state.expanded.delete(nodeId)
    else state.expanded.add(nodeId)
    state.selected = null
    renderDiagram()
  }

  function expandAllTrees() {
    var btn = document.getElementById("expandAll")
    if (state.allExpanded) {
      resetHierarchyExpansion()
      state.allExpanded = false
      btn.textContent = "Expand All"
    } else {
      var mod = currentModule()
      var rootId = rootNodeId(mod)
      state.expanded.clear()
      state.expanded.add(rootId)
      var visited = new Set()
      visited.add(mod.name)
      expandAllRecursive(mod, mod.name, visited)
      state.allExpanded = true
      btn.textContent = "Collapse All"
    }
    state.selected = null
    renderDiagram()
  }

  function expandAllRecursive(mod, path, visited) {
    var instances = mod.instances || []
    if (instances.length > 50) {
      var byType = new Map()
      instances.forEach(function (inst) {
        var type = inst.module || "unknown"
        if (!byType.has(type)) byType.set(type, [])
        byType.get(type).push(inst)
      })
      byType.forEach(function (list, type) {
        var id = path + "/group:" + type
        var targetMod = moduleByName.get(type)
        if (targetMod && hasVisibleChildren(targetMod) && !visited.has(type)) {
          state.expanded.add(id)
          visited.add(type)
          expandAllRecursive(targetMod, id, visited)
        }
      })
    } else {
      instances.forEach(function (inst, index) {
        var id = path + "/inst:" + index + ":" + (inst.name || "unnamed")
        var targetMod = moduleByName.get(inst.module || "")
        if (targetMod && hasVisibleChildren(targetMod) && !visited.has(inst.module)) {
          state.expanded.add(id)
          visited.add(inst.module)
          expandAllRecursive(targetMod, id, visited)
        }
      })
    }
  }

  function resetHierarchyExpansion() {
    state.expanded = new Set()
    state.allExpanded = false
    var mod = currentModule()
    if (mod && mod.name) state.expanded.add(rootNodeId(mod))
    var btn = document.getElementById("expandAll")
    if (btn) btn.textContent = "Expand All"
  }

  function updateHeader() {
    var mod = currentModule()
    var mode = state.view[0].toUpperCase() + state.view.slice(1)
    document.getElementById("activeTitle").textContent = mod.name || "No module"
    renderBreadcrumb()
    document.getElementById("activeMeta").textContent = mode + " &middot; " + (mod.counts.ports || 0) + " ports &middot; " + (mod.counts.instances || 0) + " instances &middot; " + (mod.counts.signals || 0) + " signals"
    document.querySelectorAll(".tab-btn").forEach(function (btn) { btn.classList.toggle("active", btn.dataset.view === state.view) })
  }

  function renderBreadcrumb() {
    var box = document.getElementById("breadcrumb")
    box.innerHTML = ""
    state.navStack.forEach(function (entry, index) {
      if (index > 0) {
        box.appendChild(textSpan("/", "crumb-sep"))
        if (entry.via) {
          var via = textSpan(entry.via, "")
          via.title = entry.via
          box.appendChild(via)
          box.appendChild(textSpan("/", "crumb-sep"))
        }
      }
      var btn = document.createElement("button")
      btn.className = "crumb"
      btn.textContent = entry.moduleName
      btn.title = entry.moduleName
      btn.disabled = index === state.navStack.length - 1
      btn.addEventListener("click", function () { goToCrumb(index) })
      box.appendChild(btn)
    })
  }

  function textSpan(text, className) {
    var span = document.createElement("span")
    span.textContent = text
    if (className) span.className = className
    return span
  }

  function updateOverview() {
    var mod = currentModule()
    var graph = activeGraph()
    var stats = [
      ["Visible nodes", graph.nodes.length],
      ["Visible edges", graph.edges.length],
      ["Instances", mod.counts.instances],
      ["Signals", mod.counts.signals],
    ]
    document.getElementById("overview").innerHTML = stats.map(function (s) { return '<div class="stat"><strong>' + (s[1] || 0) + '</strong><span>' + s[0] + "</span></div>" }).join("")
  }

  function updateInspector() {
    var selected = state.selected
    var mod = currentModule()
    var summary = document.getElementById("summary")
    var jsonPanel = document.getElementById("jsonPanel")
    var hint = document.getElementById("inspectorHint")
    var connections = document.getElementById("connectionsPanel")

    if (!selected) {
      hint.textContent = "Module overview"
      summary.innerHTML = rows([
        ["module", mod.name],
        ["view", state.view],
        ["top", mod.isTop ? "yes" : "no"],
      ])
      connections.innerHTML = moduleConnectionSummary(mod)
      jsonPanel.textContent = JSON.stringify({ name: mod.name, counts: mod.counts, ports: mod.ports.slice(0, 20), instances: mod.instances.slice(0, 20) }, null, 2)
      return
    }

    if (selected.type === "edge") {
      var e = selected.data
      hint.textContent = "Connection"
      summary.innerHTML = rows([
        ["source", e.source],
        ["target", e.target],
        ["label", e.label || "-"],
        ["kind", e.kind || "-"],
      ])
      connections.innerHTML = '<div class="empty">Select an instance for port-level connections.</div>'
      jsonPanel.textContent = JSON.stringify(e, null, 2)
      return
    }

    var n = selected.data
    hint.textContent = n.type
    summary.innerHTML = rows([
      ["name", n.label],
      ["type", n.type],
      ["detail", n.detail || "-"],
    ])
    connections.innerHTML = instanceConnections(n.raw)
    jsonPanel.textContent = JSON.stringify(n.raw || n, null, 2)
  }

  function moduleConnectionSummary(mod) {
    var body = (mod.instances || []).slice(0, 18).map(function (inst) {
      var count = (inst.port_connections || []).filter(function (c) { return c.connection }).length
      return "<tr><td>" + escapeHtml(inst.name || "") + "</td><td>" + escapeHtml(inst.module || "") + "</td><td>" + count + "</td></tr>"
    }).join("")
    if (!body) return '<div class="empty">No instances in this module.</div>'
    return '<table class="conn-table"><thead><tr><th>Instance</th><th>Module</th><th>Conns</th></tr></thead><tbody>' + body + "</tbody></table>"
  }

  function instanceConnections(raw) {
    if (!raw || !Array.isArray(raw.port_connections)) return '<div class="empty">No port connections.</div>'
    var body = raw.port_connections.map(function (conn) {
      return "<tr><td>" + escapeHtml(conn.port || "") + "</td><td>" + escapeHtml(exprToText(conn.connection) || "-") + "</td></tr>"
    }).join("")
    return body ? '<table class="conn-table"><thead><tr><th>Port</th><th>Signal / Expr</th></tr></thead><tbody>' + body + "</tbody></table>" : '<div class="empty">No port connections.</div>'
  }

  function rows(items) {
    return items.map(function (pair) { return "<div>" + escapeHtml(pair[0]) + "</div><div>" + escapeHtml(String(pair[1] || "")) + "</div>" }).join("")
  }

  function escapeHtml(value) {
    return String(value).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#39;")
  }

  function resetViewPosition() {
    state.selected = null
    state.scale = 1
    state.tx = 60
    state.ty = 60
    state.needsFit = true
  }

  function render() {
    renderModuleList()
    updateHeader()
    renderDiagram()
  }

  function zoom(factor) {
    state.scale = Math.max(0.35, Math.min(2.6, state.scale * factor))
    renderDiagram()
  }

  document.querySelectorAll(".tab-btn").forEach(function (btn) { btn.addEventListener("click", function () {
    state.view = btn.dataset.view
    if (state.view === "trace") traceInput.focus()
    resetViewPosition()
    render()
  })})
  document.getElementById("zoomIn").addEventListener("click", function () { zoom(1.16) })
  document.getElementById("zoomOut").addEventListener("click", function () { zoom(0.86) })
  document.getElementById("fitView").addEventListener("click", function () {
    resetViewPosition()
    renderDiagram()
  })
  document.getElementById("expandAll").addEventListener("click", function () {
    expandAllTrees()
  })

  document.getElementById("exportSvg").addEventListener("click", function () {
    var graph = activeGraph()
    var clone = svg.cloneNode(true)
    clone.setAttribute("xmlns", NS)
    clone.setAttribute("viewBox", "0 0 " + graph.width + " " + graph.height)
    clone.setAttribute("width", graph.width)
    clone.setAttribute("height", graph.height)

    var rootG = clone.querySelector("g")
    if (rootG) rootG.setAttribute("transform", "translate(0, 0) scale(1)")

    var styleEl = document.createElement("style")
    var cssText = ""
    try {
      for (var i = 0; i < document.styleSheets.length; i++) {
        try {
          var sheet = document.styleSheets[i]
          for (var j = 0; j < sheet.cssRules.length; j++) {
            cssText += sheet.cssRules[j].cssText + "\n"
          }
        } catch (_) {}
      }
    } catch (_) {}
    styleEl.textContent = cssText
    clone.insertBefore(styleEl, clone.firstChild)

    var svgString = new XMLSerializer().serializeToString(clone)
    var svgBlob = new Blob([svgString], { type: "image/svg+xml;charset=utf-8" })
    var url = URL.createObjectURL(svgBlob)

    var img = new Image()
    img.onload = function () {
      var scale = 2
      var canvas = document.createElement("canvas")
      canvas.width = graph.width * scale
      canvas.height = graph.height * scale
      var ctx = canvas.getContext("2d")
      ctx.fillStyle = "#f9fbfd"
      ctx.fillRect(0, 0, canvas.width, canvas.height)
      ctx.scale(scale, scale)
      ctx.drawImage(img, 0, 0)

      canvas.toBlob(function (blob) {
        var a = document.createElement("a")
        a.href = URL.createObjectURL(blob)
        a.download = (currentModule().name || "diagram") + "-" + state.view + ".png"
        a.click()
        URL.revokeObjectURL(a.href)
        URL.revokeObjectURL(url)
      }, "image/png")
    }
    img.onerror = function () {
      URL.revokeObjectURL(url)
      alert("Failed to export PNG. The diagram may be too large.")
    }
    img.src = url
  })
  moduleSearch.addEventListener("input", renderModuleList)
  traceInput.addEventListener("input", function () {
    state.trace = traceInput.value
    if (state.trace && state.view !== "trace") state.view = "trace"
    resetViewPosition()
    render()
  })
  svg.addEventListener("click", function () {
    if (state.didDrag) return
    state.selected = null
    updateInspector()
    renderDiagram()
  })
  svg.addEventListener("wheel", function (evt) {
    evt.preventDefault()
    zoom(evt.deltaY < 0 ? 1.08 : 0.92)
  }, { passive: false })
  svg.addEventListener("pointerdown", function (evt) {
    state.dragging = true
    state.didDrag = false
    state.dragStart = { x: evt.clientX, y: evt.clientY, tx: state.tx, ty: state.ty }
    svg.classList.add("dragging")
    svg.setPointerCapture(evt.pointerId)
  })
  svg.addEventListener("pointermove", function (evt) {
    if (!state.dragging) return
    var dx = evt.clientX - state.dragStart.x
    var dy = evt.clientY - state.dragStart.y
    if (Math.abs(dx) + Math.abs(dy) > 3) state.didDrag = true
    state.tx = state.dragStart.tx + dx
    state.ty = state.dragStart.ty + dy
    renderDiagram()
  })
  svg.addEventListener("pointerup", function (evt) {
    state.dragging = false
    svg.classList.remove("dragging")
    if (svg.hasPointerCapture(evt.pointerId)) svg.releasePointerCapture(evt.pointerId)
    setTimeout(function () { state.didDrag = false }, 0)
  })
  window.addEventListener("resize", function () {
    state.needsFit = true
    renderDiagram()
  })

  if (window.__VISUALIZER_MODEL__) {
    initVisualizer(window.__VISUALIZER_MODEL__)
  }

  var rawDesign = null
  var previewOriginalDesign = null
  var SAVE_KEY = "llm_saved_design"
  var MAX_SAVED_SIZE = 500000

  function storeRawDesign(design) { rawDesign = design }

  function saveDesignToLocal(fileName, jsonData) {
    try {
      var str = JSON.stringify(jsonData)
      if (str.length > MAX_SAVED_SIZE) return
      localStorage.setItem(SAVE_KEY, JSON.stringify({ fileName: fileName || "design.json", data: jsonData }))
    } catch (_) {}
  }

  window.getSavedDesign = function () {
    try {
      var raw = localStorage.getItem(SAVE_KEY)
      return raw ? JSON.parse(raw) : null
    } catch (_) { return null }
  }

  window.clearSavedDesign = function () {
    try { localStorage.removeItem(SAVE_KEY) } catch (_) {}
  }

  window.loadModelFromJson = function (jsonData, fileName) {
    rawDesign = jsonData
    saveDesignToLocal(fileName || "design.json", jsonData)
    var visualModel = buildVisualModel(jsonData)
    initVisualizer(visualModel)
  }

  window.handleFileUpload = function (file) {
    handleFile(file)
  }

  // ========== LLM Chat Module ==========
  var chatState = {
    config: { url: "", key: "", model: "" },
    messages: [],
    isProcessing: false,
    pendingModification: null,
  }

  function initChat() {
    try {
      var saved = localStorage.getItem("llm_chat_config")
      if (saved) chatState.config = JSON.parse(saved)
    } catch (_) {}
    applyConfigToUI()
  }

  function applyConfigToUI() {
    var c = chatState.config
    setVal("apiUrl", c.url)
    setVal("apiKey", c.key)
    setVal("apiModel", c.model)
  }

  function readConfigFromUI() {
    chatState.config.url = getVal("apiUrl")
    chatState.config.key = getVal("apiKey")
    chatState.config.model = getVal("apiModel")
  }

  function saveConfig() {
    readConfigFromUI()
    chatState.config.url = normalizeApiUrl(chatState.config.url)
    setVal("apiUrl", chatState.config.url)
    localStorage.setItem("llm_chat_config", JSON.stringify(chatState.config))
    var st = document.getElementById("configStatus")
    if (st) { st.textContent = "Saved (URL normalized)"; setTimeout(function () { if (st) st.textContent = "" }, 2000) }
  }

  function setVal(id, v) { var e = document.getElementById(id); if (e) e.value = v || "" }
  function getVal(id) { var e = document.getElementById(id); return e ? e.value.trim() : "" }

  function addChatMessage(role, content, extra) {
    chatState.messages.push({ role: role, content: content, extra: extra || null })
    renderChatMessages()
  }

  function renderChatMessages() {
    var container = document.getElementById("chatMessages")
    if (!container) return
    container.innerHTML = ""
    chatState.messages.forEach(function (msg) {
      var div = document.createElement("div")
      div.className = "chat-msg chat-msg-" + (msg.role === "user" ? "user" : msg.role === "assistant" ? "assistant" : "system")

      var label = document.createElement("div")
      label.className = "msg-label"
      label.textContent = msg.role === "user" ? "You" : msg.role === "assistant" ? "Assistant" : "System"
      div.appendChild(label)

      var text = document.createElement("div")
      text.textContent = msg.content
      div.appendChild(text)

      if (msg.extra && msg.extra.type === "modification") {
        var acts = document.createElement("div")
        acts.className = "diff-actions"
        var previewBtn = document.createElement("button")
        previewBtn.className = "btn-accept"
        previewBtn.textContent = "Preview modified design"
        previewBtn.addEventListener("click", function () { previewModification(msg.extra.modified) })
        var downloadBtn = document.createElement("button")
        downloadBtn.className = "btn-download"
        downloadBtn.textContent = "Download JSON"
        downloadBtn.addEventListener("click", function () { downloadJson(msg.extra.modified) })
        var cancelBtn = document.createElement("button")
        cancelBtn.className = "btn-cancel"
        cancelBtn.textContent = "Dismiss"
        cancelBtn.addEventListener("click", function () { cancelModification(msg) })
        acts.appendChild(previewBtn)
        acts.appendChild(downloadBtn)
        acts.appendChild(cancelBtn)
        div.appendChild(acts)
      }

      container.appendChild(div)
    })
    container.scrollTop = container.scrollHeight
  }

  function generateDiffItems(original, modified, maxItems) {
    var items = []
    try {
      if (window.jsondiffpatch) {
        var delta = window.jsondiffpatch.diff(original, modified)
        if (delta) {
          var html = window.jsondiffpatch.formatters.html.format(delta, original)
          var tmp = document.createElement("div")
          tmp.innerHTML = html
          var lis = tmp.querySelectorAll("li")
          lis.forEach(function (li, i) {
            if (i >= maxItems) return
            items.push({ type: li.classList.contains("added") ? "added" : "removed", text: li.textContent.trim().slice(0, 120) })
          })
        }
      }
    } catch (_) {}
    if (!items.length) {
      var oStr = JSON.stringify(original).slice(0, 80)
      var mStr = JSON.stringify(modified).slice(0, 80)
      if (oStr !== mStr) {
        items.push({ type: "removed", text: "Original: " + oStr + (oStr.length >= 80 ? "..." : "") })
        items.push({ type: "added", text: "Modified: " + mStr + (mStr.length >= 80 ? "..." : "") })
      }
    }
    return items
  }

  function acceptModification(modified) {
    rawDesign = modified
    previewOriginalDesign = null
    hidePreviewBanner()
    downloadJson(modified)
    var visualModel = buildVisualModel(modified)
    initVisualizer(visualModel)
    chatState.pendingModification = null
  }

  function previewModification(modified) {
    previewOriginalDesign = rawDesign
    rawDesign = modified
    var visualModel = buildVisualModel(modified)
    initVisualizer(visualModel)
    showPreviewBanner()
    chatState.pendingModification = null
  }

  function exitPreview() {
    if (!previewOriginalDesign) return
    rawDesign = previewOriginalDesign
    previewOriginalDesign = null
    var visualModel = buildVisualModel(rawDesign)
    initVisualizer(visualModel)
    hidePreviewBanner()
  }

  function showPreviewBanner() {
    var banner = document.getElementById("previewBanner")
    if (banner) banner.style.display = "flex"
  }

  function hidePreviewBanner() {
    var banner = document.getElementById("previewBanner")
    if (banner) banner.style.display = "none"
  }

  var exitBtn = document.getElementById("exitPreviewBtn")
  if (exitBtn) exitBtn.addEventListener("click", exitPreview)

  function downloadJson(data) {
    var blob = new Blob([JSON.stringify(data, null, 2)], { type: "application/json" })
    var a = document.createElement("a")
    a.href = URL.createObjectURL(blob)
    a.download = "design_modified.json"
    a.click()
    URL.revokeObjectURL(a.href)
  }

  function cancelModification(msg) {
    msg.extra = null
    chatState.pendingModification = null
    renderChatMessages()
  }

  function buildDesignContext(design) {
    if (!design) return "(no design loaded)"
    var modules = design.modules || []
    var currentMod = currentModule()
    var currentName = currentMod && currentMod.name

    // Top-level metadata (compact)
    var ctx = {
      version: design.version,
      metadata: design.metadata,
    }
    if (design.includes && design.includes.length) ctx.includes = design.includes
    if (design.defines && design.defines.length) ctx.defines = design.defines
    if (design.design_hierarchy) ctx.design_hierarchy = design.design_hierarchy

    // Full current module + summaries of others
    ctx.modules = modules.map(function (m) {
      if (m.name === currentName) {
        return m // full detail
      }
      // Summary: name, ports (names only), instances (names + module type), signal count
      return {
        name: m.name,
        description: m.description,
        ports: (m.ports || []).map(function (p) { return { name: p.name, direction: p.direction, width: p.width } }),
        instances: (m.instances || []).map(function (i) { return { name: i.name, module: i.module } }),
        signalCount: (m.signals || []).length,
        assignmentCount: (m.assignments || []).length,
      }
    })

    var jsonStr = JSON.stringify(ctx, null, 2)
    // Hard cap at 50000 chars as safety net
    if (jsonStr.length > 50000) {
      jsonStr = jsonStr.slice(0, 50000) + "\n  // ... (truncated, remaining " + (jsonStr.length - 50000) + " chars omitted)"
    }
    return jsonStr
  }

  function normalizeApiUrl(url) {
    url = url.trim()
    if (!url) return url
    // Strip trailing slash
    url = url.replace(/\/+$/, "")
    // Already has the right path
    if (/\/chat\/completions$/.test(url)) return url
    if (/\/v1\/chat\/completions$/.test(url)) return url
    // Ends with /v1  ->  append /chat/completions
    if (/\/v1$/.test(url)) return url + "/chat/completions"
    // Otherwise append /chat/completions (works for deepseek, openai, etc.)
    return url + "/chat/completions"
  }

  function sendChatMessage() {
    var input = document.getElementById("chatInput")
    if (!input) return
    var text = input.value.trim()
    if (!text || chatState.isProcessing) return
    input.value = ""
    if (!chatState.config.url) {
      addChatMessage("system", "Please configure your API URL first.")
      return
    }

    // Normalize URL on every send so user gets correct behavior immediately
    var normalized = normalizeApiUrl(chatState.config.url)
    if (normalized !== chatState.config.url) {
      chatState.config.url = normalized
      setVal("apiUrl", normalized)
      localStorage.setItem("llm_chat_config", JSON.stringify(chatState.config))
    }

    addChatMessage("user", text)
    chatState.isProcessing = true
    updateChatSendBtn()

    var systemPrompt = "You are an EDA expert specializing in Verilog and digital design. The user has loaded a design in JSON format. Respond helpfully and concisely.\n\nIf the user asks a question, answer directly.\n\nIf the user requests a modification, return a JSON object with two fields:\n1. \"modified_json\": the complete modified design JSON (include ALL modules, not just the focused one)\n2. \"explanation\": a brief description of what changed\n\nWrap the JSON in ```json ... ``` markers."

    var designContext = buildDesignContext(rawDesign)
    var userMsg = "Current design JSON:\n```json\n" + designContext + "\n```\n\nUser instruction: " + text

    var messages = [
      { role: "system", content: systemPrompt },
      { role: "user", content: userMsg },
    ]

    // Try same-origin proxy first (used with --serve mode), fallback to direct
    callViaProxy(messages)
  }

  function callViaProxy(messages) {
    var body = {
      api_url: chatState.config.url,
      api_key: chatState.config.key,
      model: chatState.config.model || "gpt-4o",
      messages: messages,
      temperature: 0.2,
    }

    fetch("/api/chat", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body),
    })
    .then(function (res) {
      if (res.status === 404) {
        // Proxy not available, fall back to direct API call (handles its own cleanup)
        callDirect(messages)
        throw new Error("__PROXY_FALLBACK__")
      }
      if (!res.ok) return res.json().then(function (j) { throw new Error(j.error || "HTTP " + res.status) })
      return res.json()
    })
    .then(function (data) {
      chatState.isProcessing = false
      updateChatSendBtn()
      handleLLMResponse(data)
    })
    .catch(function (err) {
      if (err.message === "__PROXY_FALLBACK__") return
      if (err.message === "Failed to fetch" || err.name === "TypeError") {
        callDirect(messages)
        return
      }
      chatState.isProcessing = false
      updateChatSendBtn()
      addChatMessage("assistant", "Error: " + err.message)
    })
  }

  function callDirect(messages) {
    var body = {
      model: chatState.config.model || "gpt-4o",
      messages: messages,
      temperature: 0.2,
    }

    fetch(chatState.config.url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer " + chatState.config.key,
      },
      body: JSON.stringify(body),
    })
    .then(function (res) {
      if (!res.ok) return res.text().then(function (t) { throw new Error("HTTP " + res.status + ": " + t.slice(0, 200)) })
      return res.json()
    })
    .then(function (data) {
      chatState.isProcessing = false
      updateChatSendBtn()
      handleLLMResponse(data)
    })
    .catch(function (err) {
      chatState.isProcessing = false
      updateChatSendBtn()
      var hint = ""
      if (err.message.indexOf("HTTP 404") >= 0) {
        hint = "\n\nHint: Check your API URL. OpenAI endpoint: https://api.openai.com/v1/chat/completions"
      } else if (err.message.indexOf("HTTP 401") >= 0 || err.message.indexOf("HTTP 403") >= 0) {
        hint = "\n\nHint: Check your API Key."
      } else if (err.message.indexOf("Failed to fetch") >= 0) {
        hint = "\n\nHint: CORS issue — use 'python scripts/visualize_block.py --serve' to enable the proxy."
      }
      addChatMessage("assistant", "Error: " + err.message + hint)
    })
  }

  function handleLLMResponse(data) {
    chatState.isProcessing = false
    updateChatSendBtn()
    var reply = data.choices && data.choices[0] && data.choices[0].message && data.choices[0].message.content
    if (!reply) {
      addChatMessage("assistant", "(empty response)")
      return
    }
    processLLMReply(reply)
  }

  function processLLMReply(reply) {
    try {
      // Show raw response start for debugging
      var preview = reply.slice(0, 300).replace(/```/g, "`").replace(/</g, "&lt;")
      var hasCodeBlock = /```/.test(reply)
      var hasModifiedJson = /modified_json/.test(reply)

      // Strip all ```...``` blocks from display text
      var cleanReply = reply.replace(/```[\s\S]*?```/g, "").trim()

      // Collect ALL code block contents
      var blocks = []
      var re = /```(?:json|JSON)?\s*([\s\S]*?)```/g
      var m
      while ((m = re.exec(reply)) !== null) {
        var content = m[1].trim()
        if (content.charAt(0) === "{" || content.charAt(0) === "[") {
          blocks.push(content)
        }
      }

      // If no code blocks found but reply contains {…}, try direct JSON parse
      var trimmed = reply.trim()
      if (blocks.length === 0 && (trimmed.charAt(0) === "{" || trimmed.charAt(0) === "[")) {
        blocks.push(trimmed)
      }

      for (var i = 0; i < blocks.length; i++) {
        try {
          var parsed = JSON.parse(blocks[i])
          if (parsed && typeof parsed === "object") {
            // Case 1: standard format { modified_json: {...}, explanation: "..." }
            var mod = parsed.modified_json
            if (typeof mod === "string") {
              try { mod = JSON.parse(mod) } catch (_e) {}
            }
            if (mod && typeof mod === "object") {
              var explanation = parsed.explanation || "Modified."
              var displayText = cleanReply || explanation
              addChatMessage("assistant", displayText, {
                type: "modification",
                original: rawDesign,
                modified: mod,
              })
              chatState.pendingModification = mod
              return
            }
            // Case 2: bare design JSON { modules: [...], metadata: {...} }
            if (parsed.modules && Array.isArray(parsed.modules)) {
              addChatMessage("assistant", cleanReply || "Design modified.", {
                type: "modification",
                original: rawDesign,
                modified: parsed,
              })
              chatState.pendingModification = parsed
              return
            }
          }
        } catch (_e) {}
      }

      // Fallback: show cleaned text or minimal notice
      if (cleanReply && cleanReply.length > 10) {
        addChatMessage("assistant", cleanReply)
      } else {
        addChatMessage("assistant", "Done (use buttons below to preview or download).")
      }
    } catch (e) {
      addChatMessage("assistant", "Error: " + e.message)
    }
  }

  function updateChatSendBtn() {
    var btn = document.getElementById("sendChatBtn")
    if (btn) btn.disabled = chatState.isProcessing
  }

  function switchInspectorTab(tab) {
    document.querySelectorAll(".inspector-tab").forEach(function (b) { b.classList.toggle("active", b.dataset.panel === tab) })
    document.querySelectorAll(".inspector-content").forEach(function (c) { c.style.display = c.dataset.content === tab ? "" : "none" })
  }

  // Chat event bindings
  document.querySelectorAll(".inspector-tab").forEach(function (btn) {
    btn.addEventListener("click", function () { switchInspectorTab(btn.dataset.panel) })
  })

  var sendBtn = document.getElementById("sendChatBtn")
  var chatInput = document.getElementById("chatInput")
  if (sendBtn) sendBtn.addEventListener("click", sendChatMessage)
  if (chatInput) chatInput.addEventListener("keydown", function (e) {
    if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); sendChatMessage() }
  })

  var saveCfgBtn = document.getElementById("saveApiConfig")
  if (saveCfgBtn) saveCfgBtn.addEventListener("click", saveConfig)

  var clearBtn = document.getElementById("clearChat")
  if (clearBtn) clearBtn.addEventListener("click", function () {
    chatState.messages = []
    chatState.pendingModification = null
    renderChatMessages()
  })

  // Auto-resize textarea
  if (chatInput) chatInput.addEventListener("input", function () {
    chatInput.style.height = "auto"
    chatInput.style.height = Math.min(chatInput.scrollHeight, 100) + "px"
  })

  // Override handleFile to store raw design and save to localStorage
  handleFile = function (file) {
    var reader = new FileReader()
    reader.onload = function (e) {
      try {
        var design = JSON.parse(e.target.result)
        rawDesign = design
        saveDesignToLocal(file.name, design)
        var visualModel = buildVisualModel(design)
        initVisualizer(visualModel)
      } catch (err) { alert("Failed to parse JSON: " + err.message) }
    }
    reader.readAsText(file)
  }

  initChat()
})()
