function [mont,im_pr_row,im_pr_col,invertedstack]=mymontage(stack,varargin)

%stack=squeeze(stack);

if ndims(stack)==3   %lets reshape to 4 dims
    newstack=reshape(stack,[size(stack,1) size(stack,2) 1 size(stack,3)]);
    stack=newstack; %repmat(newstack,[1 1 3 1]);
    isgray=true;
elseif ndims(stack==4)
    multivolume=true;
else
    msgbox('unsupported dimension','modal');
end
    
    
    

rows=size(stack,1);
cols=size(stack,2);
numims=size(stack,4);
numframes=size(stack,3);
sqval=sqrt(numims);
sqval=ceil(sqval);
rownum=sqval;
if (sqval-1)*sqval>=numims
    rownum=sqval-1;
end


if nargin==2  %invert mode mode
    invertedstack=zeros(size(newstack))*nan;
    invertmont=varargin{1};
end


mont=zeros(rows*rownum,cols*sqval,numframes);
for iframe=1:numframes
for nim=1:numims
    rowstart=floor((nim-1)/sqval)*rows+1;
    colstart=round(((sqval*(((nim)/sqval)-floor((nim-1)/sqval)))-1)*cols+1);
    rowend=rowstart+rows-1;
    colend=colstart+cols-1;
    %disp([num2str(rowstart) ' ' num2str(colstart) ' ' num2str(rowend) ' ' num2str(colend)]);
    mont(rowstart:rowend,colstart:colend,iframe)=stack(:,:,iframe,nim);
    
    if nargin==2  %invert mode mode
        invertedstack(:,:,iframe,nim)=invertmont(rowstart:rowend,colstart:colend,iframe);
    end    
end
end


im_pr_col=rownum;
im_pr_row=sqval;


