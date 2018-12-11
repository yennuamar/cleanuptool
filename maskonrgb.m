function rgbin=maskonrgb(rgbin,rgbmask)

if size(rgbin,4)>1
     logic=repmat(sum(rgbmask,4)>0,[1 1 1 3]);
     rgbin(logic)=rgbmask(logic);
else
    logic=repmat(sum(rgbmask,3)>0,[1 1 3]);
    rgbin(logic)=rgbmask(logic);
end