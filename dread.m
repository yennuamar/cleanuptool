function dstruct=dread(folder,varargin)



get_dicom_list_options='-r';

dstruct=struct;

t=strfind(folder,'*');
if ~isempty(t)
    %[d,mm]=system(['ls ' fn]);
    
    ff=dir(folder);
    
    [pp,fn]=fileparts(folder);
    fn=cellsmerge(pp, filesep, {ff.name});
    folder=fn;
end


dicom_struct=get_dicom_list(folder,get_dicom_list_options);


SSEtags='SeriesDescription,Columns,Rows,SeriesInstanceUID';
TST='InstanceNumber,AcquisitionTime,ContentTime';

[SSEcodes,handles.dicom_struct,humanlist]=get_dicom_SSE(dicom_struct,SSEtags); %not needed now as we supply names


unqline=[];
unq_codes=unique(SSEcodes);
for test=1:length(unq_codes)
    infomat=getDCMstructinfo(dicom_struct(SSEcodes==unq_codes(test)),{'SeriesDescription','SeriesNumber','Rows','Columns','SeriesInstanceUID','SliceThickness'});
    infomat_debug=getDCMstructinfo(handles.dicom_struct(SSEcodes==unq_codes(test)),{'AcquisitionDate','AcquisitionTime','InstanceNumber','ContentTime'});

    [sortorder{test},zspacing,zposs]=sse_sort(handles.dicom_struct(SSEcodes==test),TST);
    
   
%     s_o=sortorder{test};
%     ctimes=infomat_debug(:,4)
%     
%     
%     timingshow=0;
%     if timingshow
%         tmp=cellsmerge(infomat_debug(:,1), infomat_debug(:,2));
%         tmp1=infomat_debug(:,4);
%         delta_t_btw_firstslices=tmp(sortorder{test}(1,:)');
%         delta_t_btw_secondslices=tmp(sortorder{test}(2,:)');
%         delta_t_content=tmp1(sortorder{test}(1,:)');
%         t=zeros(1,length(delta_t_btw_firstslices));
%         t2=t;
%         p=1;
%         for k=1:2:length(delta_t_btw_firstslices)-1
%             t(p)=myetime(delta_t_btw_firstslices{k},delta_t_btw_firstslices{k+1} );
%             p=p+1;
%         end
%         p=1;
%         for k=1:2:length(delta_t_btw_secondslices)-1
%             t2(p)=myetime(delta_t_btw_secondslices{k},delta_t_btw_secondslices{k+1} );
%             p=p+1;
%         end
%         disp([t' t2'])
%     end
% 
% 
     unqline{test}=['Description: ' infomat{1,1} ' ' 'SeriesNumber:' num2str(infomat{1,2})  ' num images: ' num2str(size(infomat,1)) '. ' num2str(size(sortorder{test},1)) ' slices, ' .........
        num2str(size(sortorder{test},2)) ' reps'];
     %disp(unqline{test})

     
     cfieldname=['D_' infomat{1,1}]; % '_'  infomat{1,5}];
     
     cfieldname=regexprep(cfieldname,'\.','_');
     cfieldname=regexprep(cfieldname,'\W+','');
     cfieldname=cfieldname(1:min(40,length(cfieldname)));
     ofieldname=cfieldname;
     indx=2;
     while 1
       if isfield(dstruct,cfieldname) %if cfieldname exist, find a new one...
        cfieldname=[ofieldname '_' num2str(indx)];
        indx=indx+1;
       else
        dstruct.(cfieldname).unqline=unqline{test};
        break;
       end
     end
     
     dstruct.(cfieldname).dcms=dicom_struct(SSEcodes==unq_codes(test));
     try
        dstruct.(cfieldname).imgdata=SSEload(dicom_struct(SSEcodes==unq_codes(test)), sortorder{test});
    
            
     catch
         disp(['problem with ' unqline{test}]);
     end
    
     dstruct.(cfieldname).sortorder=sortorder{test};
     dstruct.(cfieldname).zspacing=zspacing;
     dstruct.(cfieldname).zposs=zposs;
     dstruct.(cfieldname).DICOMSliceThicknessTag=infomat{1,6};
end

