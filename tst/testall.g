# This file runs package tests. It is also referenced in the package metadata
# in PackageInfo.g.

LoadPackage("GraphvizForGAP");

# compute packages not loaded and thus tests not run
# todo: check if loading other packages without erroring if it fails is possible
excl := [];
if not IsPackageLoaded("Digraphs", "1.10.0") then
  Add(excl, "digraphs.tst");
fi;
if Filename(DirectoriesSystemPrograms(), "dot") = fail then
  Add(excl, "splash.tst");
fi;
if Filename(DirectoriesSystemPrograms(), "pdflatex") = fail then
  Add(excl, "splash_latex.tst");
fi;

Print(excl);

TestDirectory(DirectoriesPackageLibrary("GraphvizForGAP", "tst"),
  rec(exitGAP := true, compareFunction := "uptowhitespace", exclude := excl));

FORCE_QUIT_GAP(1);  # if we ever get here, there was an error
