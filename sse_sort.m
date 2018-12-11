function [ordermat,zspacing,unq_slices]=sse_sort(SSEstruct,tagoptions)
%will return the sorted temporal indices relative to the input structure
%array. The Input data must provide an integer number of sets of unique
%slice position (rectangular time-volume set)
zspacing='';
tagoptions=mystrsplit(tagoptions,',');
unq_slices=[];

%is this a mosaic?


zpos=zeros(length(SSEstruct),1);

for k=1:length(SSEstruct)
    try
        zpos(k)=get_zlocation(SSEstruct(k).info.ImagePositionPatient,SSEstruct(k).info.ImageOrientationPatient);
    catch
        %warning(['Missing Position data for ' SSEstruct(k).position '. using SliceLocation tag if available..'] )
        try
            
            zpos(k)=SSEstruct(k).info.SliceLocation;
        catch
            %warning(['Defaulting to zpos=-2000 as no info available'] )
            zpos(k)=-2000;
        end
        
    end
end 
    
[dum,sliceorder]=sort(zpos);

[unq_slices,firstindx,indx]=unique(zpos);
    
nslices=length(unq_slices);

for zz=1:nslices
    num(zz)=sum(zpos==unq_slices(zz));
end

if any(abs(num-num(1)))
    no_d4rectangle=1;
    ordermat=sliceorder;  %zeros(size(zpos));
    
    warning('no_d4rectangle');
    return
else
    no_d4rectangle=0;
    zspacing=unique(round(100*diff(unq_slices))/100);
end
%rem(length(SSEstruct),nslices);



%zpos
%create a slice-by-time matrix containing an index to the structure
%containing data at this time point

%disp('unq slices  ');
%disp(n2s(unq_slices))

%delta_dists=diff(sort(unq_slices));
%disp(['Interslice gaps: ' n2s(delta_dists')])
dim4=length(SSEstruct)/nslices;

ordermat=zeros(nslices,dim4);
allnums=1:length(SSEstruct);

for k=1:length(unq_slices)                                                       %for each unique slice staring with the lowest
    clogic=(indx==k);
    [order,newmat]=DCM_struct_sort(SSEstruct(clogic),tagoptions);                        %get the order relative to clogic
    
    %disp(newmat);
    %[dum,indxorder]=sort(order);
    
    cnums=allnums(clogic);
    %debug tmpd=SSEstruct(clogic); infomat=getDCMstructinfo(tmpd(indxorder),{'AcquisitionTime'})
    
    
    ordermat(k,:)=cnums(order);
    
end




