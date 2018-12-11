function imout=imrescale(imin,rangein,rangeout)

if isempty(rangein)
    rangein(1)=min(imin(:));
    rangein(2)=max(imin(:));
end


imout=(imin-rangein(1))/(rangein(2)-rangein(1));  %now 0-1


imout=imout*(rangeout(2)-rangeout(1))+rangeout(1);


%clamp
imout(imout>rangeout(2))=rangeout(2);
imout(imout<rangeout(1))=rangeout(1);

