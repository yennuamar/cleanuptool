function data = stanford_cleanup_get_image_data_rapid46(folder)
close all
if (size(dir([folder '/*DWI*']),1)>0)||(size(dir([folder '/*PWI*']),1)>0) %MR modality      

     all_files=dir([folder '/*.mhd'])
    
    for i=1:size(all_files,1)
    path(path, all_files(i).folder)
    data1_CT(i).filedata=mha_read_volume(all_files(i).name)
    data1_CT(i).filename=all_files(i).name
    end   
 all_files_results=dir([folder '/results/*_tmax_*.dcm'])
 for i=1:size(all_files_results,1)
      path(path,all_files_results(i).folder)
 data2_CT(i).filename=all_files_results(i).name
 data2_CT(i).filedata=dicomread(all_files_results(i).name)
 data2_CT(i).fileinfo=dicominfo(all_files_results(i).name)
 end 
 data.modality=data2_CT(1).fileinfo.Modality 
 data.PatientID=data2_CT(1).fileinfo.PatientID  
 for j=1:size(data2_CT,2)
 for i=1:size(data2_CT(j).filedata,3)
     img{j}(:,:,1,i)=squeeze(data2_CT(j).filedata(:,:,i));
     
 end
%  montage(img{j})
%      figure
 end
    
elseif size(dir([folder '/*CTP*']),1)>0 %CT modality 
 
    all_files=dir([folder '/*mask_view1_Thresholded_Tmax_Parameter*.mhd'])
    
    for i=1:size(all_files,1)
    path(path, all_files(i).folder)
    data1_CT(i).filedata=mha_read_volume(all_files(i).name)
    data1_CT(i).filename=all_files(i).name
    end   
 for j=1:size(data1_CT,2)
    for i=1:size(data1_CT(j).filedata,3)
         img{j}(:,:,1,i)=squeeze(data1_CT(j).filedata(:,:,i));
    end
    data.tmax10=mymontage(uint16(img{j}))>=4
    figure
    imshow((data.tmax10))
    data.tmax6=mymontage(uint16(img{j}))>=2
    figure
    imshow((data.tmax6))
    
    %  figure
 end  
    
 rcbf_struct=dread([folder '/results/*_rcbf_*.dcm'])
 all_files_results=dir([folder '/results/*.dcm'])
 for i=1:size(all_files_results,1)
      path(path,all_files_results(i).folder)
 data2_CT(i).filename=all_files_results(i).name
 data2_CT(i).filedata=dread(all_files_results(i).name)
 data2_CT(i).fileinfo=dicominfo(all_files_results(i).name)
 end 
 data.modality=data2_CT(1).fileinfo.Modality 
 data.PatientID=data2_CT(1).fileinfo.PatientID  

%   y=squeeze(uint16(img{36}(:,:,1,7)))
%  imagesc(y)
%  figure
%  z=squeeze(uint16(img{37}(:,:,1,7)))
%  imagesc(z>2)
%  figure
%  
 

end

return

