#############################################################################
##
##  gv.tst
##  Copyright (C) 2026                                      James Mitchell
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

#@local m
gap> START_TEST("graphviz package: gv.tst");
gap> LoadPackage("GraphvizForGAP", false);;

# Issue 109
gap> m := GV_Map();
rec(  )
gap> Size(m);
0
gap> m["a"] := 1;;
gap> Size(m);
1
gap> Unbind(m["a"]);
gap> Size(m);
0

#
gap> STOP_TEST("graphviz package: gv.tst");
