#############################################################################
##
##  cluster.tst
##  Copyright (C) 2024                                      James Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# https://graphviz.readthedocs.io/en/stable/examples.html

#@local cluster0, cluster1, graph
gap> START_TEST("graphviz package: examples/cluster.tst");
gap> LoadPackage("GraphvizForGAP");
true
gap> graph := GraphvizDigraph("G");
<graphviz digraph "G" with 0 nodes and 0 edges>

#
gap> cluster0 := GraphvizAddSubgraph(graph, "cluster_0");
<graphviz digraph "cluster_0" with 0 nodes and 0 edges>
gap> GraphvizSetAttrs(cluster0, rec(color := "lightgrey"));
<graphviz digraph "cluster_0" with 0 nodes and 0 edges>
gap> GraphvizSetAttrs(cluster0, rec(style := "filled"));
<graphviz digraph "cluster_0" with 0 nodes and 0 edges>
gap> GraphvizSetAttrs(cluster0, rec(node := rec(color := "white", style := "filled")));
<graphviz digraph "cluster_0" with 0 nodes and 0 edges>
gap> GraphvizAddEdge(cluster0, "a0", "a1");
<graphviz edge (a0, a1)>
gap> GraphvizAddEdge(cluster0, "a1", "a2");
<graphviz edge (a1, a2)>
gap> GraphvizAddEdge(cluster0, "a2", "a3");
<graphviz edge (a2, a3)>
gap> GraphvizSetAttrs(cluster0, rec(label := "process #1"));
<graphviz digraph "cluster_0" with 4 nodes and 3 edges>

#
gap> cluster1 := GraphvizAddSubgraph(graph, "cluster_1");
<graphviz digraph "cluster_1" with 0 nodes and 0 edges>
gap> GraphvizSetAttrs(cluster1, rec(color := "blue"));
<graphviz digraph "cluster_1" with 0 nodes and 0 edges>
gap> GraphvizSetAttrs(cluster1, rec(node := rec(style := "filled")));
<graphviz digraph "cluster_1" with 0 nodes and 0 edges>
gap> GraphvizAddEdge(cluster1, "b0", "b1");
<graphviz edge (b0, b1)>
gap> GraphvizAddEdge(cluster1, "b1", "b2");
<graphviz edge (b1, b2)>
gap> GraphvizAddEdge(cluster1, "b2", "b3");
<graphviz edge (b2, b3)>
gap> GraphvizSetAttrs(cluster1, rec(label := "process #2"));
<graphviz digraph "cluster_1" with 4 nodes and 3 edges>

#
gap> GraphvizAddEdge(graph, "start", "a0");
<graphviz edge (start, a0)>
gap> GraphvizAddEdge(graph, "start", "b0");
<graphviz edge (start, b0)>
gap> GraphvizAddEdge(graph, "a1", "b3");
<graphviz edge (a1, b3)>
gap> GraphvizAddEdge(graph, "b2", "a3");
<graphviz edge (b2, a3)>
gap> GraphvizAddEdge(graph, "a3", "a0");
<graphviz edge (a3, a0)>
gap> GraphvizAddEdge(graph, "a3", "end");
<graphviz edge (a3, end)>
gap> GraphvizAddEdge(graph, "b3", "end");
<graphviz edge (b3, end)>

#
gap> GraphvizSetAttr(GraphvizNode(graph, "start"), "shape", "Mdiamond");
<graphviz node "start">
gap> GraphvizSetAttr(GraphvizNode(graph, "end"), "shape", "Msquare");
<graphviz node "end">

#
gap> AsString(graph);
"//dot\ndigraph G {\nsubgraph cluster_0 {\ngraph  [color=\"lightgrey\", label=\
\"process #1\", style=\"filled\"]\nnode  [color=\"white\", style=\"filled\"]\n\
\ta0\n\ta1\n\ta0 -> a1\n\ta2\n\ta1 -> a2\n\ta3\n\ta2 -> a3\n}\nsubgraph cluste\
r_1 {\ngraph  [color=\"blue\", label=\"process #2\"]\nnode  [style=\"filled\"]\
\n\tb0\n\tb1\n\tb0 -> b1\n\tb2\n\tb1 -> b2\n\tb3\n\tb2 -> b3\n}\n\tstart [shap\
e=\"Mdiamond\"]\n\tstart -> a0\n\tstart -> b0\n\ta1 -> b3\n\tb2 -> a3\n\ta3 ->\
 a0\n\tend [shape=\"Msquare\"]\n\ta3 -> end\n\tb3 -> end\n}\n"

#
gap> STOP_TEST("graphviz package: examples/cluster.tst");
