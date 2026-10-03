#############################################################################
##
##  gv.gd
##  Copyright (C) 2024                                      James Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

## This file contains declarations of the internal/private functions for the
## graphviz package.

DeclareOperation("GV_GetCounter", [IsGraphvizGraph]);

DeclareOperation("GV_StringifyGraph",
                 [IsGraphvizGraph, IsBool]);

DeclareOperation("GV_FindNode", [IsGraphvizGraph, IsObject]);

DeclareOperation("GV_Node", [IsGraphvizGraph, IsString]);
DeclareOperation("GV_Edge",
[IsGraphvizGraph, IsGraphvizNode, IsGraphvizNode]);
DeclareOperation("GV_Graph", [IsString, IsBool]);
DeclareOperation("GV_Subgraph", [IsGraphvizGraph, IsString]);
DeclareOperation("GV_Context", [IsGraphvizGraph, IsString]);

DeclareOperation("GV_GetParent", [IsGraphvizObject]);
DeclareOperation("GV_GraphTreeSearch",
[IsGraphvizGraph, IsFunction]);
DeclareOperation("GV_GraphSearchChildren",
[IsGraphvizGraph, IsFunction]);
DeclareOperation("GV_GetRoot", [IsGraphvizObject]);
DeclareOperation("GV_EnclosingNonContext", [IsGraphvizObject]);
DeclareOperation("GV_AddNode",
[IsGraphvizGraph, IsGraphvizNode]);
DeclareOperation("GV_AddEdge",
[IsGraphvizGraph, IsGraphvizEdge]);

DeclareOperation("GV_RemoveGraphAttrIfExists",
[IsGraphvizGraph, IsString]);

DeclareGlobalFunction("GV_IsValidColor");
DeclareGlobalFunction("GV_ErrorIfNotNodeColoring");
