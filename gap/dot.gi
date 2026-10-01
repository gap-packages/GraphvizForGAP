#############################################################################
##
##  dot.gi
##  Copyright (C) 2024                                      Matthew Pancer
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

#############################################################################
# Constructors
#############################################################################

InstallMethod(GraphvizGraph, "for a string", [IsString],
function(name)
  return Objectify(GV_GraphType,
                      rec(
                        Name      := name,
                        Subgraphs := rec(),
                        Contexts  := rec(),
                        Nodes     := rec(),
                        Edges     := [],
                        Attrs     := [],
                        Parent    := fail,
                        Idx       := 1,
                        Counter   := 1));
end);

InstallMethod(GraphvizGraph, "for an object", [IsObject],
obj -> GraphvizGraph(String(obj)));

InstallMethod(GraphvizGraph, "for no args", [], {} -> GraphvizGraph(""));

InstallMethod(GraphvizDigraph, "for a string", [IsString],
function(name)
  return Objectify(GV_DigraphType,
                      rec(
                        Name      := name,
                        Subgraphs := rec(),
                        Contexts  := rec(),
                        Nodes     := rec(),
                        Edges     := [],
                        Attrs     := [],
                        Parent    := fail,
                        Idx       := 1,
                        Counter   := 1));
end);

InstallMethod(GraphvizDigraph, "for no args", [], {} -> GraphvizDigraph(""));

InstallMethod(GraphvizDigraph, "for an object", [IsObject],
obj -> GraphvizDigraph(String(obj)));

#############################################################################
# ViewString
#############################################################################

InstallMethod(PrintString, "for a graphviz node", [IsGraphvizNode],
n -> StringFormatted("<graphviz node \"{}\">", GraphvizName(n)));

InstallMethod(PrintString, "for a graphviz edge", [IsGraphvizEdge],
e -> StringFormatted("<graphviz edge {}>", GraphvizName(e)));

InstallMethod(PrintString, "for a graphviz (di)graph or context",
[IsGraphvizGraphDigraphOrContext],
function(g)
  local result, edges, nodes, kind;

  result := "";
  edges  := 0;
  nodes  := 0;

  GV_GraphSearchChildren(g, function(s)
    nodes := nodes + Length(RecNames(GraphvizNodes(s)));
    edges := edges + Length(GraphvizEdges(s));
    return false;
  end);

  if IsGraphvizDigraph(g) then
    kind := "digraph";
  elif IsGraphvizContext(g) then
    kind := "context";
  else
    kind := "graph";
  fi;

  Append(result, StringFormatted("<graphviz {} ", kind));

  if GraphvizName(g) <> "" then
    Append(result, StringFormatted("\"{}\" ", GraphvizName(g)));
  fi;

  Append(result, StringFormatted("with {} ", Pluralize(nodes, "node")));
  Append(result, StringFormatted("and {}>", Pluralize(edges, "edge")));
  # TODO add more info like that about number of subgraphs + contexts

  return result;
end);

#############################################################################
# Getters
#############################################################################

InstallMethod(GraphvizName, "for a graphviz object", [IsGraphvizObject],
x -> x!.Name);

InstallMethod(GraphvizAttrs, "for a graphviz object", [IsGraphvizObject],
x -> x!.Attrs);

InstallMethod(GraphvizNodes, "for a graphviz (di)graph or context",
[IsGraphvizGraphDigraphOrContext], x -> x!.Nodes);

InstallMethod(GraphvizNumberOfNodes, "for a graphviz (di)graph or context",
[IsGraphvizGraphDigraphOrContext], x -> Length(RecNames(GraphvizNodes(x))));

InstallMethod(GraphvizEdges, "for a graphviz (di)graph or context",
[IsGraphvizGraphDigraphOrContext], x -> x!.Edges);

InstallMethod(GraphvizEdges,
"for a graphviz (di)graph or context, object, and object",
[IsGraphvizGraphDigraphOrContext, IsObject, IsObject],
function(gv, head, tail)
  local nodes;

    nodes := GraphvizNodes(gv);
    head  := String(head);
    if not IsBound(nodes.(head)) then
      ErrorFormatted("the 2nd argument \"{}\" (head of an edge) is not a ",
                     "node of the 1st argument (a graphviz graph or digraph)",
                     head);
    fi;
    tail := String(tail);
    if not IsBound(nodes.(tail)) then
      ErrorFormatted("the 3rd argument \"{}\" (tail of an edge) is not a ",
                     "node of the 1st argument (a graphviz graph or digraph)",
                     tail);
    fi;
    head := nodes.(head);
    tail := nodes.(tail);
    return Filtered(GraphvizEdges(gv),
                    x -> GraphvizHead(x) = head and GraphvizTail(x) = tail);
end);

InstallMethod(GraphvizSubgraphs, "for a graphviz (di)graph or context",
[IsGraphvizGraphDigraphOrContext], x -> x!.Subgraphs);

InstallMethod(GraphvizContexts, "for a graphviz (di)graph or context",
[IsGraphvizGraphDigraphOrContext], x -> x!.Contexts);

InstallMethod(GraphvizTail, "for a graphviz edge", [IsGraphvizEdge],
x -> x!.Tail);

InstallMethod(GraphvizHead, "for a graphviz edge", [IsGraphvizEdge],
x -> x!.Head);

# Operators for nodes

InstallMethod(\=, "for graphviz nodes",
[IsGraphvizNode, IsGraphvizNode], IsIdenticalObj);

# Accessing edge attributes

# TODO Remove this, and just use GraphvizAttr(edge) directly?
InstallMethod(\[\], "for a graphviz edge and a string",
[IsGraphvizEdge, IsString],
function(edge, key)
  if IsBound(GraphvizAttrs(edge).(key)) then
    return GraphvizAttrs(edge).(key);
  fi;
  return fail;
end);

# TODO Remove this, and just use GraphvizAttr(edge) directly?
InstallMethod(\[\], "for a graphviz edge and an object",
[IsGraphvizEdge, IsObject],
{edge, key} -> edge[String(key)]);

# TODO Remove this, and just use GraphvizAttr(edge) directly?
InstallMethod(\[\]\:\=, "for a graphviz edge and a string",
[IsGraphvizEdge, IsString, IsString],
function(edge, key, val)
  GraphvizAttrs(edge).(key) := val;
end);

# TODO Remove this, and use GraphvizSetAttr(edge) instead?
InstallMethod(\[\]\:\=, "for a graphviz edge and an object",
[IsGraphvizEdge, IsObject, IsObject],
function(edge, key, val)
  edge[String(key)] := String(val);
end);

InstallMethod(\=, "for graphviz edges",
[IsGraphvizEdge, IsGraphvizEdge], IsIdenticalObj);

# Accessor for graphs and digraphs

# TODO Remove this, and use GraphvizAttrs(graph) instead?
InstallMethod(\[\], "for a graphviz (di)graph or context and string",
[IsGraphvizGraphDigraphOrContext, IsString],
function(graph, node)
  if IsBound(GraphvizNodes(graph).(node)) then
    return GraphvizNodes(graph).(node);
  fi;
  return fail;
end);

# TODO Remove this, and use GraphvizAttrs(graph) instead?
InstallMethod(\[\], "for a graphviz (di)graph or context and object",
[IsGraphvizGraphDigraphOrContext, IsObject],
{g, o} -> g[String(o)]);

InstallMethod(GraphvizFindSubgraphRecursive,
"for a graphviz (di)graph or context and a string",
[IsGraphvizGraphDigraphOrContext, IsString],
{g, s} -> GV_GraphTreeSearch(g, v -> GraphvizName(v) = s and
                                     not IsGraphvizContext(v)));

InstallMethod(GraphvizFindSubgraphRecursive,
"for a graphviz (di)graph or context and a string",
[IsGraphvizGraphDigraphOrContext, IsObject],
{g, o} -> GraphvizFindSubgraphRecursive(g, String(o)));

#############################################################################
# GraphvizSetName
#############################################################################

InstallMethod(GraphvizSetName, "for a graphviz (di)graph or context and string",
[IsGraphvizGraphDigraphOrContext, IsString],
function(x, name)
  x!.Name := name;
  return x;
end);

InstallMethod(GraphvizSetName, "for a graphviz (di)graph or context and string",
[IsGraphvizGraphDigraphOrContext, IsObject],
{g, o} -> GraphvizSetName(g, String(o)));

#############################################################################
# GraphvizSetAttr(s)
#############################################################################

InstallMethod(GraphvizSetAttrs, "for a graphviz object and record",
[IsGraphvizObject, IsRecord],
function(x, attrs)
  local name;
  for name in RecNames(attrs) do
    GraphvizSetAttr(x, name, attrs.(name));
  od;
  return x;
end);

InstallMethod(GraphvizSetAttr,
"for a graphviz node or edge, object, and object",
[IsGraphvizNodeOrEdge, IsObject, IsObject],
function(x, name, value)
  GraphvizAttrs(x).(String(name)) := String(value);
  return x;
end);

InstallMethod(GraphvizSetAttr,
"for a graphviz object with subobjects, object, and object",
[IsGraphvizGraphDigraphOrContext, IsObject, IsObject],
function(x, name, value)
  local attrs, string;

  name := String(name);
  GV_RemoveGraphAttrIfExists(x, name);
  attrs := GraphvizAttrs(x);
  value := String(value);
  if ' ' in value then
    # Replace with call to GV_QuoteName or whatever TODO
    value := StringFormatted("\"{}\"", value);
  fi;

  string := StringFormatted("{}={}", name, value);
  Add(attrs, string);
  return x;
end);

InstallMethod(GraphvizSetAttr, "for a graphviz (di)graph or context and object",
[IsGraphvizGraphDigraphOrContext, IsObject],
function(x, value)
  local attrs, match, pred;

  match := function(lookup, target)
      local idx, pred;
      idx := 1;

      pred := function(i)
          return i <= Length(target) and i <= Length(lookup)
                 and lookup[i] = target[i] and lookup[i] <> '=';
      end;

      while pred(idx) do
        idx := idx + 1;
      od;
      if idx > Length(lookup) or idx > Length(lookup) then
        return false;
      elif lookup[idx] = '=' and target[idx] = '=' then
        return true;
      fi;
      return false;
  end;

  attrs := GraphvizAttrs(x);
  x!.Attrs := Filtered(attrs, attr -> not match(attr, value));
  attrs := GraphvizAttrs(x);
  Add(attrs, String(value));
  return x;
end);

#############################################################################
# GraphvizAddNode
#############################################################################

InstallMethod(GraphvizAddNode, "for a graphviz (di)graph or context and string",
[IsGraphvizGraphDigraphOrContext, IsString],
function(x, name)
  local node;

  # Reuse existing node if available
  node := GV_FindNode(x, name);
  if node <> fail then
    if not IsIdenticalObj(GV_GetParent(node), x) then
      ErrorFormatted("The 2nd argument \"{}\" is the name of a node in a ",
                     "(di)graph or context named \"{}\" which is an ",
                     "ancestor, sibling or descendant of the 1st argument ",
                     "(a graphviz (di)graph / context) named \"{}\" (",
                     "adding the node \"{}\" to the 1st argument would ",
                     "silently change the enclosing context of \"{}\")",
                     name,
                     GraphvizName(GV_GetParent(node)),
                     GraphvizName(x),
                     name,
                     GraphvizName(x),
                     name);
    fi;
    return node;
  fi;

  node := GV_Node(x, name);
  GV_AddNode(x, node);
  return node;
end);

InstallMethod(GraphvizAddNode, "for a graphviz (di)graph or context and string",
[IsGraphvizGraphDigraphOrContext, IsGraphvizNode],
function(gv, name)  # gaplint: disable=unused-func-args
  ErrorNoReturn("it is not currently possible to add Graphviz node ",
                "objects directly to Graphviz graphs or digraphs, use ",
                "the node's name instead");
end);

InstallMethod(GraphvizAddNode,
"for a graphviz (di)graph or context and string",
[IsGraphvizGraphDigraphOrContext, IsObject],
{x, name} -> GraphvizAddNode(x, String(name)));

#############################################################################
# GraphvizAddEdge
#############################################################################

InstallMethod(GraphvizAddEdge,
"for a graphviz (di)graph or context and two graphviz nodes",
[IsGraphvizGraphDigraphOrContext, IsGraphvizNode, IsGraphvizNode],
function(x, head, tail)
  local edge, root_x, root_head, root_tail;

  root_x := GV_GetRoot(x);
  root_head := GV_GetRoot(head);
  root_tail := GV_GetRoot(tail);
  if not IsIdenticalObj(root_x, root_head) then
    ErrorFormatted("The 2nd argument (head) named \"{}\" does not belong to ",
                   "the root digraph containing the 1st argument named \"{}\" ",
                   "(adding the edge would silently change the enclosing ",
                   "context of \"{}\")",
                   GraphvizName(head),
                   GraphvizName(x),
                   GraphvizName(head));
  fi;
  if not IsIdenticalObj(root_x, root_tail) then
    ErrorFormatted("The 3rd argument (tail) named \"{}\" does not belong to ",
                   "the root digraph containing the 1st argument named \"{}\" ",
                   "(adding the edge would silently change the enclosing ",
                   "context of \"{}\")",
                   GraphvizName(tail),
                   GraphvizName(x),
                   GraphvizName(tail));
  fi;

  edge := GV_Edge(x, head, tail);
  GV_AddEdge(x, edge);
  return edge;
end);

InstallMethod(GraphvizAddEdge,
"for a graphviz (di)graph or context and two strings",
[IsGraphvizGraphDigraphOrContext, IsString, IsString],
function(x, head, tail)
  local head_node, tail_node;

  head_node := GV_FindNode(x, head);
  if head_node = fail then
    Info(InfoGraphviz, 3, "the head of the edge \"", head,
         "\" is not an existing node, adding node \"", head, "\"");
    head_node := GV_Node(x, head);
    GV_AddNode(x, head_node);
  fi;

  tail_node := GV_FindNode(x, tail);
  if tail_node = fail then
    Info(InfoGraphviz, 3, "the tail of the edge \"", tail,
         "\" is not an existing node, adding node \"", tail, "\"");
    tail_node := GV_Node(x, tail);
    GV_AddNode(x, tail_node);
  fi;

  return GraphvizAddEdge(x, head_node, tail_node);
end);

InstallMethod(GraphvizAddEdge,
"for a graphviz (di)graph or context and two objects",
[IsGraphvizGraphDigraphOrContext, IsObject, IsObject],
function(gv, head, tail)
  local head_name, tail_name;
  if IsGraphvizNode(head) then
    head_name := GraphvizName(head);
  else
    head_name := String(head);
  fi;
  if IsGraphvizNode(tail) then
    tail_name := GraphvizName(tail);
  else
    tail_name := String(tail);
  fi;
  return GraphvizAddEdge(gv, head_name, tail_name);
end);

#############################################################################
# GraphvizAddSubgraph
#############################################################################

InstallMethod(GraphvizAddSubgraph,
"for a graphviz (di)graph or context and string",
[IsGraphvizGraphDigraphOrContext, IsString],
function(gv, name)
  local subgraphs, root, subgraph;

  subgraphs := GraphvizSubgraphs(gv);
  if IsBound(subgraphs.(name)) then
    ErrorFormatted("the 1st argument (a graphviz (di)graph/context) ",
                   "already has a subgraph with name \"{}\"", name);
  fi;

  if IsGraphvizContext(gv) then
    root := GV_EnclosingNonContext(gv);
  else
    root := gv;
  fi;

  if IsGraphvizDigraph(root) then
    subgraph := GV_Digraph(root, name);
  elif IsGraphvizGraph(root) then
    subgraph := GV_Graph(root, name);
  fi;

  subgraphs.(name) := subgraph;
  return subgraph;
end);

InstallMethod(GraphvizAddSubgraph,
"for a graphviz (di)graph or context and an object",
[IsGraphvizGraphDigraphOrContext, IsObject],
{g, o} -> GraphvizAddSubgraph(g, String(o)));

InstallMethod(GraphvizAddSubgraph, "for a graphviz (di)graph or context",
[IsGraphvizGraphDigraphOrContext],
graph -> GraphvizAddSubgraph(graph,
                             StringFormatted("no_name_{}",
                                             GV_GetCounter(graph))));

InstallMethod(GraphvizAddContext,
"for a graphviz (di)graph or context and a string",
[IsGraphvizGraphDigraphOrContext, IsString],
function(graph, name)
  local contexts, ctx;

  contexts := GraphvizContexts(graph);
  if IsBound(contexts.(name)) then
    ErrorFormatted("the 1st argument (a graphviz (di)graph/context) ",
                   "already has a context with name \"{}\"",
                   name);
  fi;

  ctx             := GV_Context(graph, name);
  contexts.(name) := ctx;
  return ctx;
end);

InstallMethod(GraphvizAddContext,
"for a graphviz (di)graph or context",
[IsGraphvizGraphDigraphOrContext],
g -> GraphvizAddContext(g, StringFormatted("no_name_{}", GV_GetCounter(g))));

InstallMethod(GraphvizAddContext,
"for a graphviz (di)graph or context and an object",
[IsGraphvizGraphDigraphOrContext, IsObject],
{g, o} -> GraphvizAddContext(g, String(o)));

InstallMethod(GraphvizRemoveNode,
"for a graphviz (di)graph or context and node",
[IsGraphvizGraphDigraphOrContext, IsGraphvizNode],
{g, node} -> GraphvizRemoveNode(g, GraphvizName(node)));

InstallMethod(GraphvizRemoveNode,
"for a graphviz (di)graph or context and a string",
[IsGraphvizGraphDigraphOrContext, IsString],
function(g, name)
  local nodes;
  nodes := GraphvizNodes(g);
  if IsBound(nodes.(name)) then
    Unbind(nodes.(name));
  else
    ErrorFormatted("the 2nd argument (node name string) \"{}\"",
                   " is not a node of the 1st argument (a graphviz",
                   " (di)graph/context)",
                   name);
  fi;

  # remove incident edges
  GraphvizFilterEdges(g,
    function(e)
      local head, tail;
      head := GraphvizHead(e);
      tail := GraphvizTail(e);
      return name <> GraphvizName(tail) and name <> GraphvizName(head);
    end);

  return g;
end);

InstallMethod(GraphvizRemoveNode,
"for a graphviz (di)graph or context and a string",
[IsGraphvizGraphDigraphOrContext, IsObject],
{g, o} -> GraphvizRemoveNode(g, String(o)));

InstallMethod(GraphvizFilterEdges,
"for a graphviz (di)graph or context and edge filter",
[IsGraphvizGraphDigraphOrContext, IsFunction],
function(g, filter)
  local edge, idx, edges;

  edges := GraphvizEdges(g);
  idx   := Length(edges);
  while idx > 0 do
    edge := edges[idx];
    if not filter(edge) then
      Remove(edges, idx);
    fi;
    idx := idx - 1;
  od;

  return g;
end);

InstallMethod(GraphvizRemoveEdges,
"for a graphviz (di)graph or context, string, and string",
[IsGraphvizGraphDigraphOrContext, IsString, IsString],
function(g, hn, tn)
  local lh, lt, len;

  # if no such nodes exist -> error out
  lh := GV_FindNode(g, hn) = fail;
  lt := GV_FindNode(g, tn) = fail;
  if lh and lt then
    ErrorFormatted("no nodes with names \"{}\" or \"{}\"", hn, tn);
  elif lh then
    ErrorFormatted("no node with name \"{}\"", hn);
  elif lt then
    ErrorFormatted("no node with name \"{}\"", tn);
  fi;

  len := Length(GraphvizEdges(g));
  GraphvizFilterEdges(g,
    function(e)
      local head, tail, tmp;
      head := GraphvizHead(e);
      tail := GraphvizTail(e);
      if IsGraphvizDigraph(g) then
        return tn <> GraphvizName(tail) or hn <> GraphvizName(head);
      else
        tmp := tn <> GraphvizName(tail) or hn <> GraphvizName(head);
        return tmp and (hn <> GraphvizName(tail) or tn <> GraphvizName(head));
      fi;
    end);
  if len - Length(GraphvizEdges(g)) = 0 then
    ErrorFormatted("no edges exist from \"{}\" to \"{}\"",
                   tn, hn);
  fi;

  return g;
end);

InstallMethod(GraphvizRemoveEdges,
"for a graphviz (di)graph or context, object, and object",
[IsGraphvizGraphDigraphOrContext, IsObject, IsObject],
{gv, o1, o2} -> GraphvizRemoveEdges(gv, String(o1), String(o2)));

InstallMethod(GraphvizRemoveAttr, "for a graphviz object and an object",
[IsGraphvizObject, IsObject],
function(obj, attr)
  local attrs;
  attrs := GraphvizAttrs(obj);
  attr  := String(attr);

  if not IsBound(attrs.(attr)) then
    ErrorFormatted("the 2nd argument (attribute name) \"{}\" ",
                   "is not set on the provided object.",
                   attr);
  fi;

  Unbind(attrs.(attr));
  return obj;
end);

InstallMethod(GraphvizRemoveAttr,
"for a graphviz (di)graph or context and an object",
[IsGraphvizGraphDigraphOrContext, IsObject],
function(obj, attr)
  local attrs, len;
  attrs := GraphvizAttrs(obj);
  len := Length(attrs);

  GV_RemoveGraphAttrIfExists(obj, attr);
  # error if no attributes were removed i.e. did not exist
  if Length(obj!.Attrs) - len = 0 then
    ErrorFormatted("the 2nd argument (attribute name or attribute) \"{}\" ",
                   "is not set on the provided object.",
                   attr);
  fi;
  return obj;
end);

#############################################################################
# Stringify
#############################################################################

# It might be more natural for the next method to be one for String rather than
# AsString, but unfortunately String is an attribute, which means it is
# immutable, and hence cannot be changed after it is first set.

InstallMethod(AsString, "for a graphviz (di)graph",
[IsGraphvizGraphDigraphOrContext], graph -> GV_StringifyGraph(graph, false));

# Can't do the following because it conflicts with the PrintString above, we
# leave this here as a reminder.

# InstallMethod(PrintObj, "for a graphviz object with subobjects",
# [IsGraphvizGraphDigraphOrContext],
# function(gv)
#   Print(String(gv));
# end);

InstallMethod(GraphvizSetNodeLabels,
"for a graphviz (di)graph or context and list of colors",
[IsGraphvizGraphDigraphOrContext, IsList],
function(gv, labels)
  local nodes, i;
  if GraphvizNumberOfNodes(gv) <> Size(labels) then
    ErrorFormatted("the 2nd argument (list of node labels) ",
                   "has incorrect length, expected {}, but ",
                   "found {}", GraphvizNumberOfNodes(gv), Size(labels));
  fi;

  nodes := GraphvizNodes(gv);
  for i in [1 .. GraphvizNumberOfNodes(gv)] do
    labels[i] := String(labels[i]);
    if not StartsWith(labels[i], "\"") or not EndsWith(labels[i], "\"") then
      labels[i] := Concatenation("\"", labels[i], "\"");
    fi;
    GraphvizSetAttr(nodes.(i), "label", labels[i]);
  od;
  return gv;
end);

InstallMethod(GraphvizSetNodeColors,
"for a graphviz (di)graph or context and list of colors",
[IsGraphvizGraphDigraphOrContext, IsList],
function(gv, colors)
  local nodes, i;

  GV_ErrorIfNotNodeColoring(gv, colors);

  nodes := GraphvizNodes(gv);

  for i in [1 .. GraphvizNumberOfNodes(gv)] do
    GraphvizSetAttr(nodes.(i), "color", colors[i]);
    GraphvizSetAttr(nodes.(i), "style", "filled");
  od;
  return gv;
end);

InstallGlobalFunction(ErrorIfNotValidColor,
function(c)
  if not GV_IsValidColor(c) then
    if IsString(c) then
      c := StringFormatted("\"{}\"", c);
    fi;
    ErrorFormatted("invalid color {} ({}), valid colors are RGB values ",
                   "or names from the GraphViz 2.44.1 X11 Color Scheme",
                   " http://graphviz.org/doc/info/colors.html",
                   c,
                   TNAM_OBJ(c));
  fi;
end);
