function dicom_struct=get_dicom_list(folder,optstring)

warning('off','images:dicomread:repeatedAttribute');

warning('off','images:dicominfo:attrWithSameName');

opstruct=parse_arg_line(optstring);

opstruct.dummy=1; %if no args...

if iscell(folder)
    filelist=folder;
    
else
    
    if isfield(opstruct,'r')
        tmp=genpath(folder);
        folderlist=mystrsplit(tmp,':');
    else
        folderlist={folder};
    end
    
    filelist={};
    
    %turn into a file list
    for n=1:length(folderlist)
        cfolder=folderlist{n};
        
        files=dir(cfolder);
        
        isfile=~[files(:).isdir];
        
        filenames={files(isfile).name};
        
        
        
        if ~isempty(filenames)
            
            for ifn=1:length(filenames)
                filenames{ifn}=[cfolder filesep filenames{ifn}];
            end
            
            filelist={ filelist{:} filenames{:}};
        end
        
    end
    
    
end

%for k=1:length(filelist)
dcm_count=0;
%h =waitbar(0,['Scanning Dicoms ...']);

for ifile=1:length(filelist)
    cfile=[filelist{ifile}];
    %disp(num2str(ifile))
    try
        di=dicominfo(cfile);
        if ~isempty(di.Columns) %dicomdir
            dcm_count=dcm_count+1;
            dicom_struct(dcm_count).info=di;
            dicom_struct(dcm_count).position=cfile;
        end
    catch
        %disp([cfile ' not read'])
    end
   % waitbar(ifile/length(filelist),h);
end
%delete(h)
%end
    

