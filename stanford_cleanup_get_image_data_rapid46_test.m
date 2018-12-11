function data = stanford_cleanup_get_image_data_rapid46(folder)

[ xspacing, yspacing, zspacing ] = slicethickness(folder);
if (size(dir([folder '/*DWI*']),1)>0)||(size(dir([folder '/*PWI*']),1)>0) %MR modality      

        Tmax_file=dir([folder '/*mask_view1_Thresholded_Tmax_Parameter_View_slab0.mhd']);
   
    data.folder=Tmax_file.folder;
    data1_CT.filedata=mha_read_volume(strcat(folder,'/',Tmax_file.name));
    data1_CT.filename=Tmax_file.name;
    data.tmax10=mymontage(uint16(data1_CT.filedata))>=4;
    data.tmax6=mymontage(uint16(data1_CT.filedata))>=2;
    data.hypoROI=mymontage(data.tmax6)>0;
    
 
    tmax_grayS=dread([folder '/results/*_tmax_slab0*.dcm'])
    tmax_gray=tmax_grayS.D_RAPIDTmax.imgdata;
    tmax_gray=tmax_gray(1:size(tmax_gray,2),:,:,:);
    data.hypoBG=uint16(imrescale(single(mymontage(tmax_gray)),[0 2000],[0 119]));
    data.modality=tmax_grayS.D_RAPIDTmax.dcms(1).info.Modality;
    data.PatientID=tmax_grayS.D_RAPIDTmax.dcms(1).info.PatientID;
    data.hypocolormap=[gray(120) ; 0 1 0 ; 1 0 0 ; 1 0 1];
    data.excludeHYPO=zeros(size(data.hypoROI))>0;
    data.hypo10=data.tmax10;

    cbf_mask=dir([folder '/*mask_view0_Thresholded_ADC_Parameter_View_slab0.mhd']);

    data2_CT.filedata=mha_read_volume(strcat(folder,'/',cbf_mask.name));
    data2_CT.filename=cbf_mask.name;
    data.coreROI=mymontage(uint16(data2_CT.filedata))>0;
    

    CBFbgS=dread([folder '/results/*_adc_slab0*.dcm']);
    CBFbg=CBFbgS.D_RAPIDGrayscaleADC.imgdata  ;
    CBFbg=squeeze(CBFbg(1:size(CBFbg,2),:,:,:));
    %data.corebl=imrescale(single(mymontage(bl)),[0 150],[0 1]);
    data.coreBG=uint16(imrescale(single(mymontage(CBFbg)),[0 prctile(single(CBFbg( CBFbg>0)),95 )],[0 119]));
    data.corecolormap=[gray(120) ; 1 0 1];
    data.excludeCORE=zeros(size(data.coreROI))>0;
    
    
    BL_s=dread([folder '/results/*_baseline_slab0_*dcm']);   %for modality
    BL=BL_s.D_RAPIDPrebolusBaseline.imgdata;
    blimg=squeeze(BL(1:size(BL,2),:,:,:));
    data.blimg=uint16(imrescale(  single(mymontage(blimg)),[],[0 119]));
    data.coreBG=data.blimg;
    if strcmp( data.modality,'CT')
    fn1=fieldnames(tmax_grayS); 
    data.voxvol=prod(abs([zspacing tmax_grayS.(fn1{1}).dcms(1).info.PixelSpacing']))/1000;
    
    else
    fn1=fieldnames(tmax_grayS); 
    data.voxvol=prod(abs([zspacing tmax_grayS.(fn1{1}).dcms(1).info.PixelSpacing']))/1000; %MR default
    end
    data.folder=folder;



elseif size(dir([folder '/*CBF*']),1)>0 %CT modality 
    
    if size(dir([folder '/*mask_view1_Thresholded_Tmax_Parameter*.mhd']),1)==1
    
 %%% One slab case %%%
    Tmax_file=dir([folder '/*mask_view1_Thresholded_Tmax_Parameter_View_slab0.mhd']);
   
    data.folder=Tmax_file.folder;
    data1_CT.filedata=mha_read_volume(strcat(folder,'/',Tmax_file.name));
    data1_CT.filename=Tmax_file.name;
    data.tmax10=mymontage(uint16(data1_CT.filedata))>=4;
    data.tmax6=mymontage(uint16(data1_CT.filedata))>=2;
    data.hypoROI=mymontage(data.tmax6)>0;
    
 
    tmax_grayS=dread([folder '/results/*_tmax_slab0*.dcm'])
    tmax_gray=tmax_grayS.D_RAPIDTmax.imgdata;
    tmax_gray=tmax_gray(1:size(tmax_gray,2),:,:,:);
    data.hypoBG=uint16(imrescale(single(mymontage(tmax_gray)),[0 2000],[0 119]));
    data.modality=tmax_grayS.D_RAPIDTmax.dcms(1).info.Modality;
    data.PatientID=tmax_grayS.D_RAPIDTmax.dcms(1).info.PatientID;
    data.hypocolormap=[gray(120) ; 0 1 0 ; 1 0 0 ; 1 0 1];
    data.excludeHYPO=zeros(size(data.hypoROI))>0;
    data.hypo10=data.tmax10;

    cbf_mask=dir([folder '/*mask_view0_Thresholded_CBF_Parameter_View_slab0.mhd']);

    data2_CT.filedata=mha_read_volume(strcat(folder,'/',cbf_mask.name));
    data2_CT.filename=cbf_mask.name;
    data.coreROI=mymontage(uint16(data2_CT.filedata))>0;
    

    CBFbgS=dread([folder '/results/*_rcbf_slab0*.dcm']);
    CBFbg=CBFbgS.D_RAPIDrCBF  .imgdata;
    CBFbg=squeeze(CBFbg(1:size(CBFbg,2),:,:,:));
    %data.corebl=imrescale(single(mymontage(bl)),[0 150],[0 1]);
    data.coreBG=uint16(imrescale(single(mymontage(CBFbg)),[0 prctile(single(CBFbg( CBFbg>0)),95 )],[0 119]));
    data.corecolormap=[gray(120) ; 1 0 1];
    data.excludeCORE=zeros(size(data.coreROI))>0;
    
    
    BL_s=dread([folder '/results/*_baseline_slab0_*dcm']);   %for modality
    data.blimg=uint16(imrescale(  single(mymontage(squeeze(BL_s.D_RAPIDPrebolusBaseline.imgdata))),[],[0 119]));

    if strcmp( data.modality,'CT')
        fn1=fieldnames(tmax_grayS); 
    data.voxvol=prod(abs([zspacing tmax_grayS.(fn1{1}).dcms(1).info.PixelSpacing']))/1000;
    
    else
    data.voxvol=prod(abs([zspacing tmax_grayS.(fn1{1}).dcms(1).info.PixelSpacing']))/1000; %MR default
    end
    data.folder=folder;
    [p,data.slabname]=fileparts(folder);
    [p,data.date]=fileparts(p);

%%%% two slabs case%%%%
        elseif size(dir([folder '/*mask_view1_Thresholded_Tmax_Parameter*.mhd']),1)==2
        disp('two slabs')
        
        %%%%reading 1st slab %%%%
        Tmax_file=dir([folder '/*mask_view1_Thresholded_Tmax_Parameter_View_slab0.mhd']);
    
        data.folder=Tmax_file.folder;
        data1_CT.filedata=mha_read_volume( strcat(folder,'/',Tmax_file.name));
        data1_CT.filename=Tmax_file.name;
        data.tmax10=mymontage(uint16(data1_CT.filedata))>=4;
        data.tmax6=mymontage(uint16(data1_CT.filedata))>=2;
        data.hypoROI=mymontage(data.tmax6)>0;
    
 
        tmax_grayS=dread([folder '/results/*_tmax_slab0*.dcm']);
        tmax_gray=tmax_grayS.D_RAPIDTmax.imgdata;
        tmax_gray=tmax_gray(1:size(tmax_gray,2),:,:,:);
        data.hypoBG=uint16(imrescale(single(mymontage(tmax_gray)),[0 2000],[0 119]));
        data.modality=tmax_grayS.D_RAPIDTmax.dcms(1).info.Modality;
        data.PatientID=tmax_grayS.D_RAPIDTmax.dcms(1).info.PatientID;
        data.hypocolormap=[gray(120) ; 0 1 0 ; 1 0 0 ; 1 0 1];
        data.excludeHYPO=zeros(size(data.hypoROI))>0;
        data.hypo10=data.tmax10;

        cbf_mask=dir([folder '/*mask_view0_Thresholded_CBF_Parameter_View_slab0.mhd']);
  
        data2_CT.filedata=mha_read_volume( strcat(folder,'/',cbf_mask.name));
        data2_CT.filename=cbf_mask.name;
        data.coreROI=mymontage(uint16(data2_CT.filedata))>0;
    

        CBFbgS=dread([folder '/results/*_rcbf_slab0*.dcm']);
        CBFbg=CBFbgS.D_RAPIDrCBF  .imgdata;
        CBFbg=squeeze(CBFbg(1:size(CBFbg,2),:,:,:));
        %data.corebl=imrescale(single(mymontage(bl)),[0 150],[0 1]);
        data.coreBG=uint16(imrescale(single(mymontage(CBFbg)),[0 prctile(single(CBFbg( CBFbg>0)),95 )],[0 119]));
        data.corecolormap=[gray(120) ; 1 0 1];
        data.excludeCORE=zeros(size(data.coreROI))>0;

        BL_s=dread([folder '/results/*_baseline_slab0_*dcm']);   %for modality
        data.blimg=uint16(imrescale(  single(mymontage(squeeze(BL_s.D_RAPIDPrebolusBaseline.imgdata))),[],[0 119]));
        [p,data.slabname]=fileparts(folder);
        [p,data.date]=fileparts(p);
        
        data_slab0=data;
        clear data
        
%%%% Reading 2nd slab%%%%


        Tmax_file=dir([folder '/*mask_view1_Thresholded_Tmax_Parameter_View_slab1.mhd']);
  
        data.folder=Tmax_file.folder;
        data1_CT.filedata=mha_read_volume(  strcat(folder,'/',Tmax_file.name));
        data1_CT.filename=Tmax_file.name;
        data.tmax10=mymontage(uint16(data1_CT.filedata))>=4;
        data.tmax6=mymontage(uint16(data1_CT.filedata))>=2;
        data.hypoROI=mymontage(data.tmax6)>0;
    
 
        tmax_grayS=dread([folder '/results/*_tmax_slab1*.dcm']);
        tmax_gray=tmax_grayS.D_RAPIDTmax.imgdata;
        tmax_gray=tmax_gray(1:size(tmax_gray,2),:,:,:);
        data.hypoBG=uint16(imrescale(single(mymontage(tmax_gray)),[0 2000],[0 119]));
        data.modality=tmax_grayS.D_RAPIDTmax.dcms(1).info.Modality;
        data.PatientID=tmax_grayS.D_RAPIDTmax.dcms(1).info.PatientID;
        data.hypocolormap=[gray(120) ; 0 1 0 ; 1 0 0 ; 1 0 1];
        data.excludeHYPO=zeros(size(data.hypoROI))>0;
        data.hypo10=data.tmax10;

        cbf_mask=dir([folder '/*mask_view0_Thresholded_CBF_Parameter_View_slab1.mhd']);
 
        data2_CT.filedata=mha_read_volume( strcat(folder,'/',cbf_mask.name));
        data2_CT.filename=cbf_mask.name;
        data.coreROI=mymontage(uint16(data2_CT.filedata))>0;
    

        CBFbgS=dread([folder '/results/*_rcbf_slab1*.dcm']);
        CBFbg=CBFbgS.D_RAPIDrCBF  .imgdata;
        CBFbg=squeeze(CBFbg(1:size(CBFbg,2),:,:,:));
        %data.corebl=imrescale(single(mymontage(bl)),[0 150],[0 1]);
        data.coreBG=uint16(imrescale(single(mymontage(CBFbg)),[0 prctile(single(CBFbg( CBFbg>0)),95 )],[0 119]));
        data.corecolormap=[gray(120) ; 1 0 1];
        data.excludeCORE=zeros(size(data.coreROI))>0;
        
        BL_s=dread([folder '/results/*_baseline_slab1_*dcm']);   %for modality
        data.blimg=uint16(imrescale(  single(mymontage(squeeze(BL_s.D_RAPIDPrebolusBaseline.imgdata))),[] ,[0 119]));
        
       
        if strcmp( data.modality,'CT')
        fn1=fieldnames(tmax_grayS); 
     
        data.voxvol=prod(abs([zspacing tmax_grayS.(fn1{1}).dcms(1).info.PixelSpacing']))/1000;
       
        else
        fn1=fieldnames(tmax_grayS); 
        data.voxvol=prob(abs([zspacing  tmax_grayS.(fn1{1}).dcms(1).info.PixelSpacing']))/1000; %MR default
        end
        
        data.folder=folder;

        [p,data.slabname]=fileparts(folder);
        [p,data.date]=fileparts(p);

        data_slab1=data;   
        data.hypoROI=cat(2, data_slab0.hypoROI, data_slab1.hypoROI);
        data.tmax10=cat(2, data_slab0.tmax10, data_slab1.tmax10);
        data.hypoBG=cat(2, data_slab0.hypoBG, data_slab1.hypoBG);
        data.hypo10=cat(2, data_slab0.hypo10, data_slab1.hypo10);
        data.coreROI=cat(2, data_slab0.coreROI, data_slab1.coreROI);
        data.coreBG=cat(2, data_slab0.coreBG, data_slab1.coreBG);
        data.blimg=cat(2, data_slab0.blimg, data_slab1.blimg);
        data.excludeHYPO=cat(2, data_slab0.excludeHYPO, data_slab1.excludeHYPO); 
        data.excludeCORE=cat(2, data_slab0.excludeCORE, data_slab1.excludeCORE);
    end
   

end


