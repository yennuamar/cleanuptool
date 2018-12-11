function  [slicepos_numbered,temppos,messages]=SSEsort(cstructs,tag_cell)



messages={};

slicepos_cell=getDCMstructinfo(cstructs,{'SliceLocation'});


slicepos=cell2mat(slicepos_cell);


temppos=zeros(size(slicepos))*nan;

legals=~isnan(slicepos);




unique_slices=unique(slicepos(legals));


slicepos_numbered=zeros(length(cstructs),1)*nan;

for k=1:length(unique_slices)
    cpos_legal=(unique_slices(k)==slicepos);
    
    sliceorder=DCM_struct_sort(cstructs(cpos_legal),tag_cell);   %should be ok
    
    temppos(cpos_legal)=sliceorder;
    slicepos_numbered(cpos_legal)=k;
end



%does this add up??

