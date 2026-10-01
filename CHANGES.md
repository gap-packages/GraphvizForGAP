This file describes changes in the GraphvizForGAP package.

## Unreleased

- Rename the package from graphviz to GraphvizForGAP (#54)
- Import from the Digraphs package functions for drawing digraphs, such as
  `GraphvizDigraph`, `GraphvizVertexColoredDigraph` and
  `GraphvizHighlightedDigraph`
- Rename `GraphvizFilterEnds` to `GraphvizRemoveEdges` and `GraphvizFindGraph`
  to `GraphvizFindSubgraphRecursive`; remove `GraphvizGetSubgraph`
- Add `GraphvizNumberOfNodes`, `InfoGraphviz` for debugging output (#103) and
  a `PrintObj` method for graphs and digraphs; return plain records instead
  of `GV_IsMap` objects (#113)
- Fix incorrect node and edge numbers (#15), the conflation of subgraphs and
  contexts (#19, #83) and removing attributes from graphs (#23); allow
  `GraphvizAddEdge` to take node objects (#68)
- Raise errors when removing edges between nonexistent nodes or unset
  attributes (#28), and improve error checking when adding nodes and edges
  (#95)
- Return the existing node when adding a node again to the same context,
  instead of raising an error (#79)
- Always quote labels; stop warning about unknown attributes
- Fix `Splash` for paths containing spaces, report failures of dot or
  pdflatex (#88), default the option "directory" to "tmp.viz" when "path" is
  given as documented, report a missing "path" directory clearly, and do not
  fail if the output directory exists (#97)
- Require GAP >= 4.12 and declare graphviz in `NeededSystemPackages` (#87)
- Document `Splash` and add the finite state machine picture to the manual

## 0.0.0 (2022-04-09)

- Initial implementation of the package
