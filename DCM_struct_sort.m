function  [ordered,newmat]=DCM_struct_sort(DCM,tag_cell)
%ordered will index how to select from DCM sequentially 
%assumes nummerical content only

ordered=zeros(length(DCM),1)*nan;



infomat=getDCMstructinfo(DCM,tag_cell);

infomat_num=zeros(size(infomat));

for n=1:size(infomat,1)
    for k=1:size(infomat,2)
        if isempty(infomat{n,k})
            infomat_num(n,k)=0;
        elseif ischar( infomat{n,k})
            infomat_num(n,k)=str2num(  infomat{n,k} );
        elseif isnumeric( infomat{n,k})
            infomat_num(n,k)=infomat{n,k};
        else
            infomat_num(n,k)=0;
        end
            
    end
end



[dum,ordered]=sortrows(infomat_num);


newmat=infomat(ordered,:);
% 
% cellstrs=mycell2cellstr(infomat);
% 
% 
% [unq_strs,d,cc]=unique(cellstrs(:)); %extract uniques only
% 
% [dum,unq_sort]=sortrows(unq_strs(:));
% 
% for k=1:length(unq_sort)
%     ordered(cc==k)=unq_sort(k);
% end
% 




%NBNB to change to a nummerical sort by priority lists 