function [indx_codes,dicom_struct,myhumanlist]=get_dicom_SSE(dicom_struct,SSEtags)


%security check for shared content times - to detect duplicates
% 
indx_codes=zeros(length(dicom_struct),1);
doublet_check=0;


if doublet_check

    simil=zeros(length(dicom_struct),3);
    for k=1:length(dicom_struct)
        simil(k,:)=[str2num( dicom_struct(k).info.ContentTime)  str2num( dicom_struct(k).info.AcquisitionTime) dicom_struct(k).info.InstanceNumber] ;
    end
    duplicateflag=zeros(1,size(simil,1));
    [unqs,uindxs]=unique(simil,'rows');
    if length(unqs)~=size(simil,1)
        disp('Repeated Unique Markers')
        
        for k=1:size(simil,1)
            matches=sum(repmat(simil(k,:),[size(simil,1) 1])==simil,2)==size(simil,2);
            if sum(matches)>1
                mlist=find(matches);
                
                for mf=1:length(mlist)-1
                    
                    for kf=(mf+1):length(mlist)
                        disp(['Content+Acqtime Time match between: '  dicom_struct(mlist(mf)).position ' and ' dicom_struct(mlist(kf)).position ' performing binary diff test...' ])
                        
                        dat1=dicomread(dicom_struct(mlist(mf)).info);
                        dat2=dicomread(dicom_struct(mlist(kf)).info);
                        if isequal(dat1,dat2)
                            disp('Binary match!!!')
                            duplicateflag( mlist(kf) ) =1;              %ideally there would be a preference as to which is considered duplicate if other tags differ, but not sure what should be preferenced
                            
                        end
                        
                        
                    end
                end
            end
        end
    end
    
    dicom_struct_tmp=dicom_struct;
    dicom_struct(duplicateflag>0)=[];
    


end

%optstruct=parse_arg_line(SSE_options);
%isfield(optstruct,'SSEtags')
%     SSEtags=optstruct.(SSEtags);
% else
if isempty(SSEtags)    

    SSEtags='SeriesDate,SeriesDescription,Columns,Rows';
end

SSEtags_cell=mystrsplit(SSEtags,',');

%dcmname_to_code(SSEtags,dicomdict('get'))  %assume for now SSE list will
%be same type as dicom_struct lookup type 

maxlength=0;
bytecode_length=zeros(1,length(dicom_struct));
for k=1:length(dicom_struct)
    
    
    myarr=char(zeros(1,5000));
   
    cindx=1;

    for itag=1:length(SSEtags_cell)
        try
        fieldcontent=dicom_struct(k).info.(SSEtags_cell{itag});
        
        catch
           msgbox([SSEtags_cell{itag} ' is not present in on or more DICOMs, aborting.. (change SSE definition)'],'Failed','modal') 
           return
        end
        
        if isnumeric(fieldcontent)
            fieldcontent=num2str(fieldcontent);
            myarr(cindx:(cindx+length(fieldcontent)-1))=fieldcontent;
        else
            myarr(cindx:(cindx+length(fieldcontent)-1))=fieldcontent;
        end
        
        
        
        cindx=cindx+length(fieldcontent);
        
        myhumanlist{k,itag}=dicom_struct(k).info.(SSEtags_cell{itag});
    end
    
    mymachinelist{k}=myarr(1:cindx-1);
    
    bytecode_length(k)=cindx-1;
    maxlength=max(cindx-1,maxlength);
    
      
end






%guess that mymachinelist entries may be of different length so sorting is
%not trivial. what about sorting through by thos that have the same length?


unq_lengths=unique(bytecode_length);





offset=0;
for k=1:length(unq_lengths)                         %for each uniq length seens
    ctodologic=(bytecode_length==unq_lengths(k));   %which entries are we talking into the orig vector?
    
    
    
    clist=mymachinelist(ctodologic);                %the bytecodes in a cell    

    mycharmat=char(zeros(length(clist),unq_lengths(k)));
    for p=1:length(clist)                           %convert to a matrix
        mycharmat(p,:)=clist{p};
    end   %convert celll to uinmat
    

    [y,d,indx]=unique(mycharmat,'rows');             %which are the uniques and where
    
    %debug
%     indx_global=zeros(length(dicom_struct),1);
%     indx_global(ctodologic)=indx;
%     myhumanlist(indx_global==4,:)
%     
    
    
    indx_codes(ctodologic)=offset+indx;             %put them into output
    
    offset=offset+max(indx);
    
end

