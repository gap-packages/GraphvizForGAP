#############################################################################
##
##  fsm.tst
##  Copyright (C) 2024                                      James Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# https://graphviz.readthedocs.io/en/stable/examples.html
# https://graphviz.org/Gallery/directed/fsm.html

#@local f, nodes, terminals
gap> START_TEST("graphviz package: examples/fsm.tst");
gap> LoadPackage("GraphvizForGAP");
true

#
gap> f := GraphvizDigraph("finite_state_machine");
<graphviz digraph "finite_state_machine" with 0 nodes and 0 edges>
gap> GraphvizSetAttrs(f, rec(rankdir := "LR"));
<graphviz digraph "finite_state_machine" with 0 nodes and 0 edges>
gap> GraphvizSetAttrs(f, rec(size := "8,5"));
<graphviz digraph "finite_state_machine" with 0 nodes and 0 edges>

#
gap> terminals := GraphvizAddContext(f, "terminals");
<graphviz context "terminals" with 0 nodes and 0 edges>
gap> GraphvizSetAttrs(terminals, rec(node := rec(shape := "doublecircle")));
<graphviz context "terminals" with 0 nodes and 0 edges>
gap> GraphvizAddNode(terminals, "LR_0");
<graphviz node "LR_0">
gap> GraphvizAddNode(terminals, "LR_3");
<graphviz node "LR_3">
gap> GraphvizAddNode(terminals, "LR_4");
<graphviz node "LR_4">
gap> GraphvizAddNode(terminals, "LR_8");
<graphviz node "LR_8">

#
gap> nodes := GraphvizAddContext(f, "nodes");
<graphviz context "nodes" with 0 nodes and 0 edges>
gap> GraphvizSetAttrs(nodes, rec(node := rec(shape := "circle")));
<graphviz context "nodes" with 0 nodes and 0 edges>
gap> GraphvizSetAttr(GraphvizAddEdge(nodes, "LR_0", "LR_2"), "label", "\"SS(B)\"");
<graphviz edge (LR_0, LR_2)>
gap> GraphvizSetAttr(GraphvizAddEdge(nodes, "LR_0", "LR_1"), "label", "\"SS(S)\"");
<graphviz edge (LR_0, LR_1)>
gap> GraphvizSetAttr(GraphvizAddEdge(nodes, "LR_1", "LR_3"), "label", "\"S($end)\"");
<graphviz edge (LR_1, LR_3)>
gap> GraphvizSetAttr(GraphvizAddEdge(nodes, "LR_2", "LR_6"), "label", "\"SS(b)\"");
<graphviz edge (LR_2, LR_6)>
gap> GraphvizSetAttr(GraphvizAddEdge(nodes, "LR_2", "LR_5"), "label", "\"SS(a)\"");
<graphviz edge (LR_2, LR_5)>
gap> GraphvizSetAttr(GraphvizAddEdge(nodes, "LR_2", "LR_4"), "label", "\"S(A)\"");
<graphviz edge (LR_2, LR_4)>
gap> GraphvizSetAttr(GraphvizAddEdge(nodes, "LR_5", "LR_7"), "label", "\"S(b)\"");
<graphviz edge (LR_5, LR_7)>
gap> GraphvizSetAttr(GraphvizAddEdge(nodes, "LR_5", "LR_5"), "label", "\"S(a)\"");
<graphviz edge (LR_5, LR_5)>
gap> GraphvizSetAttr(GraphvizAddEdge(nodes, "LR_6", "LR_6"), "label", "\"S(b)\"");
<graphviz edge (LR_6, LR_6)>
gap> GraphvizSetAttr(GraphvizAddEdge(nodes, "LR_6", "LR_5"), "label", "\"S(a)\"");
<graphviz edge (LR_6, LR_5)>
gap> GraphvizSetAttr(GraphvizAddEdge(nodes, "LR_7", "LR_8"), "label", "\"S(b)\"");
<graphviz edge (LR_7, LR_8)>
gap> GraphvizSetAttr(GraphvizAddEdge(nodes, "LR_7", "LR_5"), "label", "\"S(a)\"");
<graphviz edge (LR_7, LR_5)>
gap> GraphvizSetAttr(GraphvizAddEdge(nodes, "LR_8", "LR_6"), "label", "\"S(b)\"");
<graphviz edge (LR_8, LR_6)>
gap> GraphvizSetAttr(GraphvizAddEdge(nodes, "LR_8", "LR_5"), "label", "\"S(a)\"");
<graphviz edge (LR_8, LR_5)>

#
gap> AsString(f);
"//dot\ndigraph finite_state_machine {\ngraph  [rankdir=\"LR\", size=\"8,5\"]\
\n// terminals context \n{\nnode  [shape=\"doublecircle\"]\n\tLR_0\n\tLR_3\n\t\
LR_4\n\tLR_8\n}\n// nodes context \n{\nnode  [shape=\"circle\"]\n\tLR_2\n\tLR_\
0 -> LR_2 [label=\"SS(B)\"]\n\tLR_1\n\tLR_0 -> LR_1 [label=\"SS(S)\"]\n\tLR_1 \
-> LR_3 [label=\"S($end)\"]\n\tLR_6\n\tLR_2 -> LR_6 [label=\"SS(b)\"]\n\tLR_5\
\n\tLR_2 -> LR_5 [label=\"SS(a)\"]\n\tLR_2 -> LR_4 [label=\"S(A)\"]\n\tLR_7\n\
\tLR_5 -> LR_7 [label=\"S(b)\"]\n\tLR_5 -> LR_5 [label=\"S(a)\"]\n\tLR_6 -> LR\
_6 [label=\"S(b)\"]\n\tLR_6 -> LR_5 [label=\"S(a)\"]\n\tLR_7 -> LR_8 [label=\"\
S(b)\"]\n\tLR_7 -> LR_5 [label=\"S(a)\"]\n\tLR_8 -> LR_6 [label=\"S(b)\"]\n\tL\
R_8 -> LR_5 [label=\"S(a)\"]\n}\n}\n"

#
gap> STOP_TEST("graphviz package: examples/fsm.tst");
