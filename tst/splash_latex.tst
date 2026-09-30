#############################################################################
##
##  splash_latex.tst
##  Copyright (C) 2026                                           Max Horn
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

# Requires the program "pdflatex"; the viewer "true" does nothing.

#@local path
gap> START_TEST("graphviz package: splash_latex.tst");
gap> LoadPackage("GraphvizForGAP", false);;

# Paths containing spaces
gap> path := Filename(DirectoryTemporary(), "a b/");;
gap> CreateDir(path);
true
gap> Splash("%latex\n\\documentclass{article}\\begin{document}Hi\\end{document}\n",
>           rec(path := path, directory := "c d", viewer := "true"));
gap> IsReadableFile(Concatenation(path, "c d/vizpicture.pdf"));
true

# Failures of pdflatex are reported
gap> Splash("%latex\n\\documentclass{article}\\begin{document}\\undefined\\end{document}\n",
>           rec(viewer := "true"));
Error, the program "pdflatex" failed with exit status 1

#
gap> STOP_TEST("graphviz package: splash_latex.tst", 0);
