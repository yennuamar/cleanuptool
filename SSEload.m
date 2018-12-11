function mymat=SSEload(dicomstruct,ordermatrix)


mymat_tmp=dicomread(dicomstruct(1).info);




mymat=zeros([dicomstruct(1).info.Rows dicomstruct(1).info.Columns size(ordermatrix,2) size(ordermatrix,1) size(mymat_tmp,3)],class(mymat_tmp));

[row,col]=find(ordermatrix==1);
mymat(:,:,col,row,:)=mymat_tmp;

%w=waitbar(0,'Retrieving DICOM data');


%figure
for n=2:length(dicomstruct)
    [row,col]=find(ordermatrix==n);
   % dicomstruct(n).position
    
    mymat(:,:,col,row,:)=dicomread(dicomstruct(n).info);
    %image(dicomread(dicomstruct(n).info)); pause(0.5)
 %   waitbar(n/length(dicomstruct),w)
end

%delete(w)
