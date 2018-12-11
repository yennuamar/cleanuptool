function infomat=getDCMstructinfo(cstructs,tag_cell)



for k=1:length(cstructs)
    
    for t=1:length(tag_cell)
        %infomat{k,t}=cstructs(k).info.(tag_cell{t});
        
        try
            infomat{k,t}=cstructs(k).info.(tag_cell{t});
            %sc(dicomread(cstructs(k).info))
        catch
            infomat{k,t}='nan';
        end
    end
end

