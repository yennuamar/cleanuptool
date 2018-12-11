% renderTextFT example

% % to compile the code uncomment the lines below
% % In Windows it assumes you have freetype in c:\freetype\ 
 %if strcmp(computer('arch'),'win32') || strcmp(computer('arch'),'win64')
 %    mex -IC:\freetype\include -Iinclude -Lc:\freetype\lib -lfreetype renderTextFT.cpp agg_font_freetype.cpp agg_curves.cpp
 %else    
  %   mex -I./include -I/usr/include/freetype2 -lfreetype renderTextFT.cpp agg_font_freetype.cpp agg_curves.cpp
 %end

backgroundColor=[0 0 255];
foregroundColor=[255 255 0];
% notice that we use the decimal encoding of the text. The string must be
% NULL terminated
renderText=[double('Here''s the Greek character ') hex2dec('03C0') double('.') 0];
imageData=renderTextFT(renderText,backgroundColor,foregroundColor,'fonts/LinLibertine_It-4.2.6.ttf',20);
imshow(imageData);