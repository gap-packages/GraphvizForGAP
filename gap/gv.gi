#############################################################################
##
##  gv.gi
##  Copyright (C) 2024                                      James Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

###############################################################################
# Family + type
###############################################################################

BindGlobal("GV_NodeType", NewType(GV_ObjectFamily,
                                    IsGraphvizNode and
                                    IsComponentObjectRep and
                                    IsAttributeStoringRep));

BindGlobal("GV_EdgeType", NewType(GV_ObjectFamily,
                                    IsGraphvizEdge and
                                    IsComponentObjectRep and
                                    IsAttributeStoringRep));

BindGlobal("GV_ContextType", NewType(GV_ObjectFamily,
                                    IsGraphvizContext and
                                    IsComponentObjectRep and
                                    IsAttributeStoringRep));

###############################################################################
# Constructors etc
###############################################################################

InstallMethod(GV_Node, "for a string",
[IsGraphvizGraphDigraphOrContext, IsString],
function(graph, name)
  local out;
  Assert(0, not IsEmpty(name));
  out := Objectify(GV_NodeType,
                  rec(
                    Name   := name,
                    Attrs  := rec(),
                    Parent := graph,
                    Idx    := GV_GetCounter(graph)));
  GV_IncCounter(graph);
  return out;
end);

InstallMethod(GV_Edge, "for two graphviz nodes",
[IsGraphvizGraphDigraphOrContext, IsGraphvizNode, IsGraphvizNode],
function(graph, head, tail)
  local out;

  out := Objectify(GV_EdgeType,
                rec(
                  Name   := StringFormatted("({}, {})",
                                            GraphvizName(head),
                                            GraphvizName(tail)),
                  Head   := head,
                  Tail   := tail,
                  Attrs  := rec(),
                  Parent := graph,
                  Idx    := GV_GetCounter(graph)));
  GV_IncCounter(graph);
  return out;
end);

# Graph constructors

InstallMethod(GV_Digraph,
"for a graphviz digraph and a string",
[IsGraphvizDigraph, IsString],
function(parent, name)
  local out;

  out         := GraphvizDigraph(name);
  out!.Parent := parent;
  out!.Idx    := GV_GetCounter(parent);

  GV_IncCounter(parent);
  return out;
end);

InstallMethod(GV_Graph,
"for a graphviz graph and a string",
[IsGraphvizGraphDigraphOrContext, IsString],
function(parent, name)
  local out;

  out         := GraphvizGraph(name);
  out!.Parent := parent;
  out!.Idx    := GV_GetCounter(parent);

  GV_IncCounter(parent);
  return out;
end);

InstallMethod(GV_Context,
"for a string and a positive integer",
[IsGraphvizGraphDigraphOrContext, IsString],
function(parent, name)
  local out;

  out := Objectify(GV_ContextType,
                      rec(
                        Name      := name,
                        Subgraphs := rec(),
                        Contexts  := rec(),
                        Nodes     := rec(),
                        Edges     := [],
                        Attrs     := [],
                        Parent    := parent,
                        Idx       := GV_GetCounter(parent),
                        Counter   := 1));

  GV_IncCounter(parent);
  return out;
end);

# Graph child counter functions

InstallMethod(GV_IncCounter,
"for a graphviz graph",
[IsGraphvizGraphDigraphOrContext],
function(x)
  x!.Counter := x!.Counter + 1;
end);

InstallMethod(GV_GetCounter, "for a graphviz graph",
[IsGraphvizGraphDigraphOrContext],
x -> x!.Counter);

# Nodes

InstallMethod(GV_HasNode,
"for a graphviz graph",
[IsGraphvizGraphDigraphOrContext, IsString],
{g, name} -> name in RecNames(GraphvizNodes(g)));

InstallMethod(GV_GetParent,
"for a graphviz object",
[IsGraphvizObject], graph -> graph!.Parent);

InstallMethod(GV_GraphTreeSearch,
"for a graphviz graph and a predicate",
[IsGraphvizGraphDigraphOrContext, IsFunction],
function(graph, pred)
  local seen, to_visit, g, key, subgraph, context, parent;
  seen     := [graph];
  to_visit := [graph];

  while Length(to_visit) > 0 do
    g := Remove(to_visit, Length(to_visit));

    # Check this graph
    if pred(g) then
      return g;
    fi;

    # add subgraphs to list of to visit if not visited
    for key in RecNames(GraphvizSubgraphs(g)) do
      subgraph := GraphvizSubgraphs(g).(key);
      if not ForAny(seen, s -> IsIdenticalObj(s, subgraph)) then
        Add(seen, subgraph);
        Add(to_visit, subgraph);
      fi;
    od;

    # add contexts to list of to visit if not visited
    for key in RecNames(GraphvizContexts(g)) do
      context := GraphvizContexts(g).(key);
      if not ForAny(seen, s -> IsIdenticalObj(s, context)) then
        Add(seen, context);
        Add(to_visit, context);
      fi;
    od;

    # add parent if not visited
    parent := GV_GetParent(g);
    if not IsGraphvizGraphDigraphOrContext(parent) then
      continue;
    fi;
    if not ForAny(seen, s -> IsIdenticalObj(s, parent)) then
      Add(seen, parent);
      Add(to_visit, parent);
    fi;
  od;

  return fail;
end);

# tree search only on the children of the graph
InstallMethod(GV_GraphSearchChildren,
"for a graphviz graph and a predicate",
[IsGraphvizGraphDigraphOrContext, IsFunction],
function(graph, pred)
  local _, curr, queue, count, nexts, key;

  queue := [graph];
  while Length(queue) > 0 do
    count := Length(queue);

    for _ in [1 .. count] do
      # TODO: make sure this is using a linked list rather than an array list
      curr := Remove(queue, 1);

      # Check this graph (visit)
      if pred(curr) then
        return curr;
      fi;

      # Add children
      nexts := GraphvizSubgraphs(curr);
      for key in RecNames(nexts) do
        Add(queue, nexts.(key));
      od;
      nexts := GraphvizContexts(curr);
      for key in RecNames(nexts) do
        Add(queue, nexts.(key));
      od;
    od;
  od;

  return fail;
end);

InstallMethod(GV_FindGraphWithNode,
"for a graphviz graph and a node",
[IsGraphvizGraphDigraphOrContext, IsString],
{g, n} -> GV_GraphTreeSearch(g, v -> IsBound(GraphvizNodes(v).(n))));

InstallMethod(GV_GetRoot,
"for a graphviz graph",
[IsGraphvizObject],
function(graph)
  while GV_GetParent(graph) <> fail do
    graph := GV_GetParent(graph);
  od;
  return graph;
end);

InstallMethod(GV_EnclosingNonContext,
"for a graphviz object with subobjects",
[IsGraphvizObject],
function(graph)
  local parent;

  repeat
    parent := GV_GetParent(graph);
  until parent = fail or not IsGraphvizContext(parent);
  return parent;
end);

InstallMethod(GV_AddNode,
"for a graphviz graph and node",
[IsGraphvizGraphDigraphOrContext, IsGraphvizNode],
function(x, node)
  local name, nodes;
  name  := GraphvizName(node);
  nodes := GraphvizNodes(x);
  nodes.(name) := node;
  return x;
end);

InstallMethod(GV_AddEdge,
"for a graphviz graph and edge",
[IsGraphvizGraphDigraphOrContext, IsGraphvizEdge],
function(x, edge)
  Add(x!.Edges, edge);
  return x;
end);

InstallMethod(GV_RemoveGraphAttrIfExists,
"for a graphviz graph context or digraph and a string",
[IsGraphvizGraphDigraphOrContext, IsString],
function(obj, attr)
  local attrs, i, match;
  attrs := GraphvizAttrs(obj);
  attr  := String(attr);

  # checks if they attribute names match the one being removed
  match := function(key, str)
    for i in [1 .. Length(key)] do
      if i > Length(str) or key[i] <> str[i] then
        return false;
      fi;
    od;

    i := i + 1;
    while i <= Length(str) do
      if str[i] = '=' then
        return true;
      elif str[i] <> '\s' and str[i] <> '\t' then
        return false;
      fi;
      i := i + 1;
    od;

    # attributes which are not key value or removal by value
    return true;
  end;

  obj!.Attrs := Filtered(attrs, s -> not match(attr, s));
end);

###############################################################################
# Stringifying
###############################################################################

# @ Return DOT graph head line.
InstallMethod(GV_StringifyGraphHead, "for a string",
[IsGraphvizGraphDigraphOrContext],
graph -> StringFormatted("graph {} {{\n", GraphvizName(graph)));

# @ Return DOT digraph head line.
InstallMethod(GV_StringifyDigraphHead, "for a string", [IsGraphvizDigraph],
graph -> StringFormatted("digraph {} {{\n", GraphvizName(graph)));

# @ Return DOT subgraph head line.
InstallMethod(GV_StringifySubgraphHead, "for a string",
[IsGraphvizGraphDigraphOrContext],
graph -> StringFormatted("subgraph {} {{\n", GraphvizName(graph)));

# @ Return DOT subgraph head line.
InstallMethod(GV_StringifyContextHead, "for a string", [IsGraphvizContext],
graph -> StringFormatted("// {} context \n{{\n", GraphvizName(graph)));

BindGlobal("GV_StringifyNodeName",
function(node)
  local name, old;

  Assert(0, IsGraphvizNode(node));
  name  := GraphvizName(node);
  if (ForAny("- .+", x -> x in name)
      or (IsDigitChar(First(name)) and IsAlphaChar(Last(name))))
      and not StartsWith(name, "\"") then
    old  := name;
    name := StringFormatted("\"{}\"", name);
    Info(InfoWarning,
         1,
         "invalid node name ",
         old,
         " using ",
         name,
         " instead");
  fi;
  return name;
end);

# @ Return DOT node statement line.
InstallMethod(GV_StringifyNode, "for string and record",
[IsGraphvizNode],
function(node)
  local name, attrs;
  name  := GV_StringifyNodeName(node);
  attrs := GraphvizAttrs(node);
  return StringFormatted("\t{}{}\n", name, GV_StringifyNodeEdgeAttrs(attrs));
end);

# @ Return DOT graph edge statement line.
BindGlobal("GV_StringifyEdge",
function(edge, edge_str)
  local head, tail, attrs;
  Assert(0, IsGraphvizEdge(edge));
  Assert(0, IsString(edge_str));
  head  := GV_StringifyNodeName(GraphvizHead(edge));
  tail  := GV_StringifyNodeName(GraphvizTail(edge));
  attrs := GraphvizAttrs(edge);

  # handle : syntax
  return StringFormatted("\t{} {} {}{}\n",
                         head,
                         edge_str,
                         tail,
                         GV_StringifyNodeEdgeAttrs(attrs));
end);

InstallMethod(GV_StringifyGraphAttrs,
"for a graphviz graph",
[IsGraphvizGraphDigraphOrContext],
function(graph)
  local result, attrs, kv;
  attrs  := GraphvizAttrs(graph);
  result := "";

  if Length(attrs) <> 0 then
    Append(result, "\t");
    for kv in attrs do
      Append(result,
             StringFormatted("{} ", kv));
    od;
    Append(result, "\n");
  fi;
  return result;
end);

InstallMethod(GV_StringifyNodeEdgeAttrs, "for a record", [IsRecord],
function(attrs)
  local result, keys, key, val, n, i, tmp, format;

  result := "";
  n      := Length(RecNames(attrs));
  keys   := SSortedList(RecNames(attrs));

  # helper for formatting attribute kv pairs
  format := function(format, key, val)
    tmp := Chomp(val);
    if "label" = key and StartsWith(tmp, "<<") and EndsWith(tmp, ">>") then
      val := StringFormatted("{}", val);
    else
      if ' ' in key then
        key := StringFormatted("\"{}\"", key);
      fi;

      if ' ' in val or '>' in val or '^' in val or '#' in val then
        val := StringFormatted("\"{}\"", val);
      fi;
    fi;

    return StringFormatted(format, key, val);
  end;

  if n <> 0 then
    Append(result, " [");
    for i in [1 .. n - 1] do
        key := keys[i];
        val := attrs.(key);

        Append(result, format("{}={}, ", key, val));
    od;
    # handle last element
    key := keys[n];
    val := attrs.(key);
    Append(result, format("{}={}]", key, val));
  fi;

  return result;
end);

InstallMethod(GV_GetIdx,
"for a graphviz object",
[IsGraphvizObject],
x -> x!.Idx);

InstallMethod(GV_ConstructHistory,
"for a graphviz graph",
[IsGraphvizGraphDigraphOrContext],
function(graph)
  local ctxs, nodes, edges, subs,
        ctxs_hist, node_hist, edge_hist, subs_hist, hist;

  nodes := GraphvizNodes(graph);
  edges := GraphvizEdges(graph);
  subs  := GraphvizSubgraphs(graph);
  ctxs  := GraphvizContexts(graph);

  node_hist := List(RecNames(nodes), n -> [GV_GetIdx(nodes.(n)), nodes.(n)]);
  subs_hist := List(RecNames(subs), s -> [GV_GetIdx(subs.(s)), subs.(s)]);
  ctxs_hist := List(RecNames(ctxs), s -> [GV_GetIdx(ctxs.(s)), ctxs.(s)]);
  edge_hist := List(edges, e -> [GV_GetIdx(e), e]);

  hist := Concatenation(node_hist, edge_hist, subs_hist, ctxs_hist);
  SortBy(hist, v -> v[1]);

  Apply(hist, x -> x[2]);
  return hist;
end);

InstallMethod(GV_StringifyGraph,
"for a graphviz graph and a string",
[IsGraphvizGraphDigraphOrContext, IsBool],
function(graph, is_subgraph)
  local result, obj;
  result := "";

  # get the correct head to use
  if is_subgraph then
    if IsGraphvizContext(graph) then
      Append(result, GV_StringifyContextHead(graph));
    else
      Append(result, GV_StringifySubgraphHead(graph));
    fi;
  elif IsGraphvizDigraph(graph) then
    Append(result, "//dot\n");
    Append(result, GV_StringifyDigraphHead(graph));
  elif IsGraphvizGraph(graph) then
    Append(result, "//dot\n");
    Append(result, GV_StringifyGraphHead(graph));
  else
    ErrorFormatted("Unknown graph category, ",
                   "expected a context, digraph or graph.");
  fi;

  Append(result, GV_StringifyGraphAttrs(graph));

  # Add child graphviz objects
  for obj in GV_ConstructHistory(graph) do
    if IsGraphvizGraphDigraphOrContext(obj) then
      Append(result, GV_StringifyGraph(obj, true));
    elif IsGraphvizNode(obj) then
      Append(result, GV_StringifyNode(obj));
    elif IsGraphvizEdge(obj) then
      if IsGraphvizDigraph(GV_GetRoot(graph)) then
        Append(result, GV_StringifyEdge(obj, "->"));
      else
        Append(result, GV_StringifyEdge(obj, "--"));
      fi;
    fi;
  od;

  Append(result, "}\n");
  return result;
end);

BindGlobal("GV_IsValidRGBColor",
function(str)
  local valid, i;

  valid := "0123456789ABCDEFabcdef";

  if Length(str) <> 7 or str[1] <> '#' then
    return false;
  fi;

  for i in [2 .. 7] do
    if not str[i] in valid then
      return false;
    fi;
  od;
  return true;
end);

InstallGlobalFunction(GV_IsValidColor,
c -> IsString(c) and (GV_IsValidRGBColor(c) or c in GV_ValidColorNames));

InstallGlobalFunction(GV_ErrorIfNotNodeColoring,
function(gv, colors)
  local N;
  N := GraphvizNumberOfNodes(gv);
  if Length(colors) <> N then
    ErrorFormatted(
        "the number of node colors must be the same as the number",
        " of nodes, expected {} but found {}", N, Length(colors));
  fi;
  Perform(colors, ErrorIfNotValidColor);
end);

InstallGlobalFunction(GV_ErrorIfNotValidLabel,
function(label)
    local cond;

    if Length(label) = 0 then
        ErrorFormatted("invalid label \"{}\", valid DOT labels ",
                       "cannot be empty strings", label);
    fi;

    # double quoted string
    if StartsWith(label, "\"") and EndsWith(label, "\"")then
        return;
    fi;
    # HTML string
    if StartsWith(label, "<") and EndsWith(label, ">")then
        return;
    fi;

    # numeral
    if Int(label) <> fail then
        return;
    fi;

    cond := not IsDigitChar(label[1]);
    cond := cond and ForAll(label, c -> IsAlphaChar(c) or IsDigitChar(c)
                            or c = '_' or ('\200' <= c and c <= '\377'));
    if cond then
        return;
    fi;

    ErrorFormatted("invalid label \"{}\", valid DOT labels ",
                   "https://graphviz.org/doc/info/lang.html",
                   label);
end);
