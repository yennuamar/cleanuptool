function cellout=mystrsplit(incell,splititem)

if ischar(incell)
    incell={incell};
end
        
 cellout={};
for k=1:length(incell)
    
    indx=regexp(incell{k},splititem);
    
    cindx=1;
    
    tmpcell={};
    for n=1:length(indx)
        cpos=cindx:indx(n)-1;
        
        if ~(isempty(cpos))
            tmpcell{length(tmpcell)+1}=incell{k}(cpos);
        end
        
        cindx=indx(n)+1;
    end
    
    if length(incell{k})>=cindx
        tmpcell{length(tmpcell)+1}=incell{k}(cindx:end);
    end
    
    
    cellout(k,1:length(tmpcell))=tmpcell(1,:);
    
end