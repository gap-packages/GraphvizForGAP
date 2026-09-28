#############################################################################
##
##  PackageInfo.g
##  Copyright (C) 2024                                      Matthew Pancer
##
##  Licensing information can be found in the README file of this package.
##
#############################################################################
##

SetPackageInfo(rec(

PackageName := "GraphvizForGAP",
Subtitle    := "GAP representations of graphviz objects",
Version     := "0.0.0",
Date        := "09/04/2022",  # dd/mm/yyyy format
License     := "GPL-2.0-or-later",

Persons := [
  rec(
    FirstNames    := "James D.",
    LastName      := "Mitchell",
    WWWHome       := "https://jdbm.me",
    Email         := "jdm3@st-andrews.ac.uk",
    IsAuthor      := true,
    IsMaintainer  := true,
    PostalAddress := Concatenation("Mathematical Institute, North Haugh,",
                     " St Andrews, Fife, KY16 9SS, Scotland"),
    Place       := "St Andrews",
    Institution := "University of St Andrews"),
  rec(
    FirstNames    := "Matthew",
    LastName      := "Pancer",
    WWWHome       := "https://github.com/mpan322",
                     # TODO make personal website
    Email         := "mp322@st-andrews.ac.uk",
    IsAuthor      := true,
    IsMaintainer  := true,
    PostalAddress := Concatenation("Mathematical Institute, North Haugh,",
                     " St Andrews, Fife, KY16 9SS, Scotland"),
                     # TODO correct? Or should be cs?
    Place       := "St Andrews",
    Institution := "University of St Andrews")],

Status := "dev",

SourceRepository := rec(Type := "git",
                        URL  := "https://github.com/gap-packages/GraphvizForGAP"),
IssueTrackerURL := Concatenation(~.SourceRepository.URL, "/issues"),
PackageWWWHome  := "https://gap-packages.github.io/GraphvizForGAP/",

PackageInfoURL := Concatenation(~.PackageWWWHome, "PackageInfo.g"),
README_URL     := Concatenation(~.PackageWWWHome, "README.md"),
ArchiveURL     := Concatenation(~.SourceRepository.URL,
                                "/releases/download/v", ~.Version,
                                "/", ~.PackageName, "-", ~.Version),
ArchiveFormats := ".tar.gz",

PackageDoc := rec(
  BookName  := ~.PackageName,
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := ~.Subtitle,
),

Dependencies := rec(
  GAP := ">= 4.12.0",
  NeededOtherPackages := [],
  SuggestedOtherPackages := [],
  ExternalConditions := [],
),

AvailabilityTest := ReturnTrue,

TestFile := "tst/testall.g",

AutoDoc := rec(
    TitlePage := rec(
        Copyright := """&copyright; by J. D. Mitchell and M. Pancer.<P/>
        &GAPGraphviz; is free software; you can redistribute it and/or modify
        it, under the terms of the GNU General Public License, version 2 of
        the License, or (at your option) any later version.""",
        Abstract := """
        This package facilitates the creation and rendering of graph
        descriptions in the &DOT; language of the &Graphviz; graph drawing
        software from &GAP;.
        <P/>

        Create a graphviz object, assemble the graph by adding nodes and
        edges, and retrieve its &DOT; source code string. Save the source
        code to a file and render it with the &Graphviz; installation of your
        system.
        <P/>

        Use the <Ref Func="Splash"/> function to directly inspect the resulting
        graph.
        <P/>

        This package was inspired by the python package of the same name
        &PyGraphviz;.""")),

AbstractHTML := ~.AutoDoc.TitlePage.Abstract));
