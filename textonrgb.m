function rgbout=textonrgb(rgb_in,mytxt,mycol,bgcol,frombottom,siz)


myimg=renderTextFT([double(mytxt) 0],bgcol,255*mycol,'/usr/share/fonts/truetype/ubuntu-font-family/Ubuntu-B.ttf',siz);

myimg=myimg(  : ,1:min(size(myimg,2),size(rgb_in,2)),: );
rgb_in( ((end-frombottom)-siz+1):(end-frombottom),1:size(myimg,2),:)=myimg/255;


rgbout=rgb_in;