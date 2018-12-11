The package helps with rendering true type font text to image.
It uses the Anti-Grain Geometry library v2.4 code (see
www.antigrain.com) by Maxim Shemanarev.

For simplicity, only relevant files from the AGG project have
been included (but left to their original content as in v2.4).

renderTextFT.cpp relies heavily on the freetype_test.cpp demo
provided by AGG.

=== Generating the running code ===

To compile to a mex file in Windows you'll need to use the
Visual Studio compiler and compile FreeType (www.freetype.org)
library for your architecture (the zip file from freetype.org
website has a build solution for VS). Assuming you unzipped the
freetype code to c:\freetype and moved freetype.lib to
c:\freetype\lib then just uncomment the line in runRenderTextFT
to compile renderTextFT using mex.

To compile to a mex file in Linux, you probably already have
FreeType library available ("ldconfig -p | grep freetype"
should tell you that) and the include headers should also be
there ("find / -name ft2build.h" may help). Assuming you set up
Matlab to use the gcc type compiler, then just uncomment the
line in runRenderTextFT to compile renderTextFT using mex.
