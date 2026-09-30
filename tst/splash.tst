#############################################################################
##
##  splash.tst
##  Copyright (C) 2026                                           Max Horn
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# Requires the program "dot"; the viewer "true" does nothing.

#@local gv, path
gap> START_TEST("graphviz package: splash.tst");
gap> LoadPackage("GraphvizForGAP", false);;

# Paths containing spaces
gap> path := Filename(DirectoryTemporary(), "a b/");;
gap> CreateDir(path);
true
gap> gv := GraphvizDigraph("G");;
gap> GraphvizAddEdge(gv, "hello", "world");;
gap> Splash(gv, rec(path := path, directory := "c d", viewer := "true"));
gap> IsReadableFile(Concatenation(path, "c d/G.pdf"));
true

# Existing and nested directories
gap> Splash(gv, rec(path := path, directory := "c d/", viewer := "true"));
gap> Splash(gv, rec(path := path, directory := "e f/g h", viewer := "true"));
gap> IsReadableFile(Concatenation(path, "e f/g h/G.pdf"));
true

# The option "directory" defaults to "tmp.viz" if "path" is given
gap> path := Filename(DirectoryTemporary(), "");;
gap> Splash("//dot\ndigraph {}", rec(path := path, viewer := "true"));
gap> IsReadableFile(Concatenation(path, "tmp.viz/vizpicture.pdf"));
true
gap> path := Filename(DirectoryTemporary(), "");;
gap> CreateDir(Concatenation(path, "tmp.viz"));
true
gap> Splash("//dot\ndigraph {}", rec(path := path, viewer := "true"));
gap> IsReadableFile(Concatenation(path, "tmp.viz/vizpicture.pdf"));
true

# The option "path" need not end in a slash
gap> path := Filename(DirectoryTemporary(), "e");;
gap> CreateDir(path);
true
gap> Splash("//dot\ndigraph {}", rec(path := path, directory := "f", viewer := "true"));
gap> IsReadableFile(Concatenation(path, "/f/vizpicture.pdf"));
true

# Failures of the layout engine are reported
gap> Splash("//dot\ndigraph {", rec(viewer := "true"));
Error, the program "dot" failed with exit status 1

#
gap> STOP_TEST("graphviz package: splash.tst", 0);
