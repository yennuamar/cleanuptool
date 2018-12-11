function cellout=cellsmerge(varargin)
%get max dims
myargs=varargin;


for k=1:length(varargin)
    ccell=myargs{k};
    if ~iscell(ccell)
        myargs{k}={ccell};
        
        
    end
    clength(k)=length(myargs{k});
end

nrep=max(clength);

cellout{nrep}=[];
for k=1:nrep
    
    
    tmp='';
    for n=1:length(myargs)
        ccell=myargs{n};
        cstr=ccell{min(k,length(ccell))};
        tmp=[tmp  cstr];
    end
    
    cellout{k}=tmp;
    
  
end