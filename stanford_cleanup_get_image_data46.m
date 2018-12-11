function data = stanford_cleanup_get_image_data46(folder)
data.dicomfiles={}   %cell of cells, for 2 slab cases it is the slabs in order
data.DWIonly=false;
data.folder=folder;
jsonflag=loadjson(strcat(data.folder,'/','output.json'));
% if (size(dir([folder '/*dwi*']),1)>0)&&(size(dir([folder '/*perf*']),1)==0)
%     data.DWIonly=true;
%     data.caseflag='DWIonly';
%     disp('Dataset contains only DWI')
% elseif (size(dir([folder '/*dwi*']),1)>0)&&(size(dir([folder '/*perf*']),1)>0)
%     data.caseflag='DWIandPWI';
%     disp('Dataset contains DWI and PWI')
%     
% elseif (size(dir([folder '/*CBF*']),1)>0)&&(size(dir([folder '/*perf*']),1)>0)
%     data.caseflag='CTPonly';
%     disp('Dataset contains only CTP')
% end

data.folder=folder;
try
x=jsonflag.DICOMHeaderInfo.DiffusionSeries{1, 1};
disp('Diffusion series exists')
catch
disp('Diffusion series does not exist')
x=0;
end
   
try
y=jsonflag.DICOMHeaderInfo.PerfusionSeries{1, 1};
disp('perfusion series exists')
catch
disp('perfusion series does not exist')
y=0;
end

if isstruct(x)  && isstruct(y) && strcmp(x.Modality,'MR') && strcmp(y.Modality,'MR')
    data.caseflag='DWIandPWI';
    disp('Dataset contains DWI and PWI')
elseif isstruct(y) && strcmp(y.Modality,'CT')
    data.caseflag='CTPonly';
    disp('Dataset contains only CTP')
elseif isstruct(x) && ~isstruct(y)
    data.DWIonly=true;
    data.caseflag='DWIonly';
    disp('Dataset contains only DWI')
end  

% [ ~, ~, zspacing ] = slicethickness(folder,data);
switch data.caseflag
    case 'DWIonly'
        %%%%%%% %MR(DWI only) modality
        
        ADC_mask=dir([folder '/*mask_view0_Thresholded_ADC_Parameter_View_slab0.mhd']);
        
        
        [data2.filedata]=mha_read_volume(strcat(folder,'/',ADC_mask.name));
        data2.filename=ADC_mask.name;
        data.coreROI=mymontage(uint16(data2.filedata))>0;
        data.dicoms=[folder '/results/*_adc_slab0*.dcm'];      % DICOM
        ADCbgS=dread([folder '/results/*_adc_slab0*.dcm']);
        data.stacktemplate=ADCbgS;  %for later inverting the 
        fn=fieldnames(ADCbgS); assert(length(fn)==1)
        ADCbg=ADCbgS.(fn{1}).imgdata  ;
        data.modality=ADCbgS.(fn{1}).dcms(1).info.Modality;
        data.PatientID=ADCbgS.(fn{1}).dcms(1).info.PatientID;
        ADCbg=squeeze(ADCbg(1:size(ADCbg,2),:,:,:));
        
        %zspacing=ADCbgS.(fn{1}).zspacing;
        zspacing=ADCbgS.(fn{1}).DICOMSliceThicknessTag; %.(fn{1}).DICOMSliceThicknessTag;
        
        B1000=dir([folder '/*dwi_volume01.mhd']);
        [B1000bg.filedata]=mha_read_volume(strcat(folder,'/',B1000.name));
        data.coreBG=uint16(imrescale(single(mymontage(B1000bg.filedata)),[0 prctile(single(B1000bg.filedata( B1000bg.filedata>0)),99 )],[0 119]));
        %         data.coreBG=uint16(imrescale(single(mymontage(ADCbg)),[0 prctile(single(ADCbg( ADCbg>0)),95 )],[0 119]));
        data.corecolormap=[gray(120) ; 1 0 1];
        data.excludeCORE=zeros(size(data.coreROI))>0;
        
        data.tmax10=mymontage(uint16(zeros(size(data.coreBG))));
        data.tmax6=mymontage(uint16(zeros(size(data.coreBG))));
        data.hypoROI=mymontage(uint16(zeros(size(data.coreBG))));
        
        data.hypoBG=mymontage(uint16(zeros(size(data.coreBG))));
        data.hypocolormap=[gray(120) ; 0 1 0 ; 1 0 0 ; 1 0 1];
        data.excludeHYPO=zeros(size(data.hypoROI))>0;
        data.hypo10=data.tmax10;
        
        
        data.blimg=mymontage(uint16(zeros(size(data.coreBG))));
        if strcmp( data.modality,'MR')
            fn1=fieldnames( ADCbgS);
            data.voxvol=prod(abs([zspacing ADCbgS.(fn1{1}).dcms(1).info.PixelSpacing']))/1000;
        end
        data.folder=folder;
        [p,data.slabname]=fileparts(folder);
        %TODO - should not be current date - see 4.5.1 implementation
        data.date=char(datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss'));
        %%%%%
    case 'DWIandPWI'
        %%%% %MR(DWI and PWI) modality
        
        Tmax_file=dir([folder '/*mask_view1_Thresholded_Tmax_Parameter_View_slab0.mhd']);
        
        data1.filedata=mha_read_volume(strcat(folder,'/',Tmax_file.name));
        data1.filename=Tmax_file.name;
        data.tmax10=mymontage(uint16(data1.filedata))>=4;
        data.tmax6=mymontage(uint16(data1.filedata))>=2;
        data.hypoROI=mymontage(data.tmax6)>0;
        
        
        tmax_grayS=dread([folder '/results/*_tmax_slab0*.dcm']);
        data.dicoms={[folder '/results/*_tmax_slab0*.dcm']};      % DICOM
        data.stacktemplate=tmax_grayS;  %for later inverting the 
        fn=fieldnames(tmax_grayS); assert(length(fn)==1)
        tmax_gray=tmax_grayS.(fn{1}).imgdata;
        tmax_gray=tmax_gray(1:min( size(tmax_gray,2),size(tmax_gray,1)),:,:,:);
        zspacing=tmax_grayS.(fn{1}).DICOMSliceThicknessTag;
        data.hypoBG=uint16(imrescale(single(mymontage(tmax_gray)),[0 2000],[0 119]));
        data.modality=tmax_grayS.(fn{1}).dcms(1).info.Modality;
        data.PatientID=tmax_grayS.(fn{1}).dcms(1).info.PatientID;
        data.hypocolormap=[gray(120) ; 0 1 0 ; 1 0 0 ; 1 0 1];
        data.excludeHYPO=zeros(size(data.hypoROI))>0;
        data.hypo10=data.tmax10;
        
        %zspacing=tmax_grayS.(fn{1}).zspacing; %nasty RAPID bug here so cannot use this
        %disp('Using slice distance because of RAPID bug');
        %zspacing=tmax_grayS.(fn{1}).dcms(1).info.SliceThickness;
        
        %zspacing=getRAPIDzspacing('DWIandPWI',folder );
        
        
        ADC_mask=dir([folder '/*mask_view0_Thresholded_ADC_Parameter_View_slab0.mhd']);
        
        data2.filedata=mha_read_volume(strcat(folder,'/',ADC_mask.name));
        data2.filename=ADC_mask.name;
        data.coreROI=mymontage(uint16(data2.filedata))>0;
        
        ADCbgS=dread([folder '/results/*_adc_slab0*.dcm']);
        fn=fieldnames(ADCbgS); assert(length(fn)==1)
        ADCbg=ADCbgS.(fn{1}).imgdata  ;
        data.modality=ADCbgS.(fn{1}).dcms(1).info.Modality;
        data.PatientID=ADCbgS.(fn{1}).dcms(1).info.PatientID;
        ADCbg=squeeze(ADCbg(1:size(ADCbg,2),:,:,:));
        
        %         B1000=dir([folder '/*dwi_volume01.mhd']);
        %         [B1000bg.filedata]=mha_read_volume(strcat(folder,'/',B1000.name));
        %         data.coreBG=uint16(imrescale(single(mymontage(B1000bg.filedata)),[0 prctile(single(B1000bg.filedata( B1000bg.filedata>0)),95 )],[0 119]));
        data.coreBG=uint16(imrescale(single(mymontage(ADCbg)),[0 prctile(single(ADCbg( ADCbg>0)),95 )],[0 119]));
        data.corecolormap=[gray(120) ; 1 0 1];
        data.excludeCORE=zeros(size(data.coreROI))>0;
        
        
        BL_s=dread([folder '/results/*_baseline_slab0_*dcm']);   %for modality
        fn=fieldnames(BL_s); assert(length(fn)==1)
        BL=BL_s.(fn{1}).imgdata;
        blimg=squeeze(BL(1:min(size(BL,2),size(BL,1)),:,:,:));
        data.blimg=uint16(imrescale(  single(mymontage(blimg)),[],[0 119]));
        data.coreBG=data.blimg;
        
        if strcmp( data.modality,'MR')
            fn1=fieldnames(tmax_grayS);
            data.voxvol=prod(abs([zspacing tmax_grayS.(fn1{1}).dcms(1).info.PixelSpacing']))/1000;
        end
        data.folder=folder;
        [p,data.slabname]=fileparts(folder);
        data.date=char(datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss'));
        
        %%%%%
        %     case 'PWIonly'
        % %%%%5PWI only case
        %         Tmax_file=dir([folder '/*mask_view1_Thresholded_Tmax_Parameter_View_slab0.mhd']);
        %
        %         data1.filedata=mha_read_volume(strcat(folder,'/',Tmax_file.name));
        %         data1.filename=Tmax_file.name;
        %         data.tmax10=mymontage(uint16(data1.filedata))>=4;
        %         data.tmax6=mymontage(uint16(data1.filedata))>=2;
        %         data.hypoROI=mymontage(data.tmax6)>0;
        %
        %
        %         tmax_grayS=dread([folder '/results/*_tmax_slab0*.dcm']);
        %         tmax_gray=tmax_grayS.D_RAPIDTmax.imgdata;
        %         tmax_gray=tmax_gray(1:size(tmax_gray,2),:,:,:);
        %         data.hypoBG=uint16(imrescale(single(mymontage(tmax_gray)),[0 2000],[0 119]));
        %         data.modality=tmax_grayS.D_RAPIDTmax.dcms(1).info.Modality;
        %         data.PatientID=tmax_grayS.D_RAPIDTmax.dcms(1).info.PatientID;
        %         data.hypocolormap=[gray(120) ; 0 1 0 ; 1 0 0 ; 1 0 1];
        %         data.excludeHYPO=zeros(size(data.hypoROI))>0;
        %         data.hypo10=data.tmax10;
        %
        %         data.coreROI=mymontage(uint16(zeros(size(data.hypoBG))));
        %         data.coreBG=mymontage(uint16(zeros(size(data.hypoBG))));
        %         data.corecolormap=[gray(120) ; 1 0 1];
        %         data.excludeCORE=zeros(size(data.coreROI))>0;
        %
        %         BL_s=dread([folder '/results/*_baseline_slab0_*dcm']);   %for modality
        %         BL=BL_s.D_RAPIDPrebolusBaseline.imgdata;
        %         blimg=squeeze(BL(1:size(BL,2),:,:,:));
        %         data.blimg=uint16(imrescale(  single(mymontage(blimg)),[],[0 119]));
        %         data.coreBG=data.blimg;
        %
        %         if strcmp( data.modality,'MR')
        %         fn1=fieldnames(tmax_grayS);
        %         data.voxvol=prod(abs([zspacing tmax_grayS.(fn1{1}).dcms(1).info.PixelSpacing']))/1000;
        %         end
        %         data.folder=folder;
        %         [p,data.slabname]=fileparts(folder);
        %         data.date=char(datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss'));
        
    case 'CTPonly'
        
        data.numberofslabs=size(dir([folder '/*mask_view1_Thresholded_Tmax_Parameter*.mhd']),1);
        %zspacing=getRAPIDzspacing('CTPonly',folder );
        switch data.numberofslabs
            
            case 1
                
                %%% One slab case %%%
                Tmax_file=dir([folder '/*mask_view1_Thresholded_Tmax_Parameter_View_slab0.mhd']);
                
                
                data1_CT.filedata=mha_read_volume(strcat(folder,'/',Tmax_file.name));
                data1_CT.filename=Tmax_file.name;
                data.tmax10=mymontage(uint16(data1_CT.filedata))>=4;
                data.tmax6=mymontage(uint16(data1_CT.filedata))>=2;
                data.hypoROI=mymontage(data.tmax6)>0;
                
                
                tmax_grayS=dread([folder '/results/*_tmax_slab0*.dcm']);
                data.stacktemplate=tmax_grayS;
                fn=fieldnames(tmax_grayS); assert(length(fn)==1)
                tmax_gray=tmax_grayS.(fn{1}).imgdata;
                tmax_gray=tmax_gray(1:size(tmax_gray,2),:,:,:);
                zspacing=tmax_grayS.(fn{1}).DICOMSliceThicknessTag;
                data.hypoBG=uint16(imrescale(single(mymontage(tmax_gray)),[0 2000],[0 119]));
                data.modality=tmax_grayS.(fn{1}).dcms(1).info.Modality;
                data.PatientID=tmax_grayS.(fn{1}).dcms(1).info.PatientID;
                data.hypocolormap=[gray(120) ; 0 1 0 ; 1 0 0 ; 1 0 1];
                data.excludeHYPO=zeros(size(data.hypoROI))>0;
                data.hypo10=data.tmax10;
                
                %zspacing=tmax_grayS.(fn{1}).zspacing;
                
                cbf_mask=dir([folder '/*mask_view0_Thresholded_CBF_Parameter_View_slab0.mhd']);
                
                data2_CT.filedata=mha_read_volume(strcat(folder,'/',cbf_mask.name));
                data2_CT.filename=cbf_mask.name;
                data.coreROI=mymontage(uint16(data2_CT.filedata))>0;
                
                
                CBFbgS=dread([folder '/results/*_rcbf_slab0*.dcm']);
                fn=fieldnames(CBFbgS); assert(length(fn)==1)
                CBFbg=CBFbgS.(fn{1}).imgdata;
                CBFbg=squeeze(CBFbg(1:size(CBFbg,2),:,:,:));
                %data.corebl=imrescale(single(mymontage(bl)),[0 150],[0 1]);
                data.coreBG=uint16(imrescale(single(mymontage(CBFbg)),[0 prctile(single(CBFbg( CBFbg>0)),95 )],[0 119]));
                data.corecolormap=[gray(120) ; 1 0 1];
                data.excludeCORE=zeros(size(data.coreROI))>0;
                
                
                BL_s=dread([folder '/results/*_baseline_slab0_*dcm']);   %for modality
                fn=fieldnames(BL_s); assert(length(fn)==1)
                data.blimg=uint16(imrescale(  single(mymontage(squeeze(BL_s.(fn{1}).imgdata))),[],[0 119]));
                
                if strcmp( data.modality,'CT')
                    fn1=fieldnames(tmax_grayS);
                    data.voxvol=prod(abs([zspacing tmax_grayS.(fn1{1}).dcms(1).info.PixelSpacing']))/1000;
                end
                data.folder=folder;
                [p,data.slabname]=fileparts(folder);
                data.date=char(datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss'));
                
                
            case 2
                
                %%%% two slabs case%%%case
                
                disp('two slabs')
                
                %%%%reading 1st slab %%%%
                Tmax_file=dir([folder '/*mask_view1_Thresholded_Tmax_Parameter_View_slab0.mhd']);
                
                data1_CT.filedata=mha_read_volume( strcat(folder,'/',Tmax_file.name));
                data1_CT.filename=Tmax_file.name;
                data.tmax10=mymontage(uint16(data1_CT.filedata))>=4;
                data.tmax6=mymontage(uint16(data1_CT.filedata))>=2;
                data.hypoROI=mymontage(data.tmax6)>0;
                
                
                tmax_grayS=dread([folder '/results/*_tmax_slab0*.dcm']);
                data.stacktemplate={tmax_grayS};
                
                fn=fieldnames(tmax_grayS); assert(length(fn)==1)
                tmax_gray=tmax_grayS.(fn{1}).imgdata;
                tmax_gray=tmax_gray(1:min(size(tmax_gray,2),size(tmax_gray,1)),:,:,:);
                zspacing=tmax_grayS.(fn{1}).DICOMSliceThicknessTag;
                data.hypoBG=uint16(imrescale(single(mymontage(tmax_gray)),[0 2000],[0 119]));
                data.modality=tmax_grayS.(fn{1}).dcms(1).info.Modality;
                data.PatientID=tmax_grayS.(fn{1}).dcms(1).info.PatientID;
                data.hypocolormap=[gray(120) ; 0 1 0 ; 1 0 0 ; 1 0 1];
                data.excludeHYPO=zeros(size(data.hypoROI))>0;
                data.hypo10=data.tmax10;
                
                %zspacing=tmax_grayS.(fn{1}).zspacing;
                
                cbf_mask=dir([folder '/*mask_view0_Thresholded_CBF_Parameter_View_slab0.mhd']);
                
                data2_CT.filedata=mha_read_volume( strcat(folder,'/',cbf_mask.name));
                data2_CT.filename=cbf_mask.name;
                data.coreROI=mymontage(uint16(data2_CT.filedata))>0;
                
                
                CBFbgS=dread([folder '/results/*_rcbf_slab0*.dcm']);
                fn=fieldnames(CBFbgS); assert(length(fn)==1)
                CBFbg=CBFbgS.(fn{1}).imgdata;
                CBFbg=squeeze(CBFbg(1:min(size(CBFbg,2),size(CBFbg,1)),:,:,:));
                %data.corebl=imrescale(single(mymontage(bl)),[0 150],[0 1]);
                data.coreBG=uint16(imrescale(single(mymontage(CBFbg)),[0 prctile(single(CBFbg( CBFbg>0)),95 )],[0 119]));
                data.corecolormap=[gray(120) ; 1 0 1];
                data.excludeCORE=zeros(size(data.coreROI))>0;
                
                BL_s=dread([folder '/results/*_baseline_slab0_*dcm']);   %for modality
                fn=fieldnames(BL_s); assert(length(fn)==1)
                data.blimg=uint16(imrescale(  single(mymontage(squeeze(BL_s.(fn{1}).imgdata))),[],[0 119]));
                [p,data.slabname]=fileparts(folder);
                [p,data.date]=fileparts(p);
                
                data_slab0=data;
                datacaseflag=data.caseflag;
                
                
                %%%% Reading 2nd slab%%%%
                
                Tmax_file=dir([folder '/*mask_view1_Thresholded_Tmax_Parameter_View_slab1.mhd']);
                
                data1_CT.filedata=mha_read_volume(  strcat(folder,'/',Tmax_file.name));
                data1_CT.filename=Tmax_file.name;
                data.tmax10=mymontage(uint16(data1_CT.filedata))>=4;
                data.tmax6=mymontage(uint16(data1_CT.filedata))>=2;
                data.hypoROI=mymontage(data.tmax6)>0;
                
                
                tmax_grayS=dread([folder '/results/*_tmax_slab1*.dcm']);
                data.stacktemplate{2}=tmax_grayS;
                fn=fieldnames(tmax_grayS); assert(length(fn)==1)
                tmax_gray=tmax_grayS.(fn{1}).imgdata;
                tmax_gray=tmax_gray(1:min(size(tmax_gray,2),size(tmax_gray,1)),:,:,:);
                data.hypoBG=uint16(imrescale(single(mymontage(tmax_gray)),[0 2000],[0 119]));
                data.modality=tmax_grayS.(fn{1}).dcms(1).info.Modality;
                data.PatientID=tmax_grayS.(fn{1}).dcms(1).info.PatientID;
                data.hypocolormap=[gray(120) ; 0 1 0 ; 1 0 0 ; 1 0 1];
                data.excludeHYPO=zeros(size(data.hypoROI))>0;
                data.hypo10=data.tmax10;
                
                %zspacing=tmax_grayS.(fn{1}).zspacing;
                
                cbf_mask=dir([folder '/*mask_view0_Thresholded_CBF_Parameter_View_slab1.mhd']);
                
                data2_CT.filedata=mha_read_volume( strcat(folder,'/',cbf_mask.name));
                data2_CT.filename=cbf_mask.name;
                data.coreROI=mymontage(uint16(data2_CT.filedata))>0;
                
                
                CBFbgS=dread([folder '/results/*_rcbf_slab1*.dcm']);
                fn=fieldnames(CBFbgS); assert(length(fn)==1)
                CBFbg=CBFbgS.(fn{1}).imgdata;
                CBFbg=squeeze(CBFbg(1:min(size(CBFbg,2),size(CBFbg,1)),:,:,:));
                %data.corebl=imrescale(single(mymontage(bl)),[0 150],[0 1]);
                data.coreBG=uint16(imrescale(single(mymontage(CBFbg)),[0 prctile(single(CBFbg( CBFbg>0)),95 )],[0 119]));
                data.corecolormap=[gray(120) ; 1 0 1];
                data.excludeCORE=zeros(size(data.coreROI))>0;
                
                BL_s=dread([folder '/results/*_baseline_slab1_*dcm']);   %for modality
                fn=fieldnames(BL_s); assert(length(fn)==1)
                BL=squeeze(BL_s.(fn{1}).imgdata);
                data.blimg=uint16(imrescale(  single(mymontage(BL)),[] ,[0 119]));
                
                
                if strcmp(data.modality,'CT')
                    fn1=fieldnames(tmax_grayS);
                    data.voxvol=prod(abs([zspacing  tmax_grayS.(fn1{1}).dcms(1).info.PixelSpacing']))/1000;
                end
                
                data.folder=folder;
                
                [p,data.slabname]=fileparts(folder);
                data.date=char(datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss'));
                
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








