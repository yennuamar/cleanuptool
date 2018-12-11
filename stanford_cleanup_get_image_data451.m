function data=stanford_cleanup_get_image_data451(folder,usemask_indices)

data.DWIonly=false;

try %this could be DWI only
    tmax6_S=dread([folder '/*_TMax_lesion_mask' num2str(usemask_indices(1)) '*']);   %NB NB NB
    fn1=fieldnames(tmax6_S);  %seems to vary MR to CT...
    if length(fn1)>1
        error('Unexpected situation - aborting')
    end
catch %is it?
    
    dwimatch=myglob3([folder '/*_DWI_lesion_mask_slice*']);
    if length(dwimatch)>0
        data.DWIonly=true;
    end
    data.modality='MR';
end
    
data.folder=folder;    
    
if ~data.DWIonly

    BL_s=dread([folder '/*_baseline_*dcm']);   %for modality
    Blnames=fieldnames(BL_s);
    data.modality=BL_s.(Blnames{1}).dcms(1).info.Modality;


    %assume square and remove warning label if present
    tmax6=tmax6_S.(fn1{1}).imgdata;
    tmax6=squeeze(tmax6(1:size(tmax6,2),:,:,:));



    tmax10_S=dread([folder '/*_TMax_lesion_mask'  num2str(usemask_indices(2)) '*']);
    fn2=fieldnames(tmax10_S);  %seems to vary MR to CT...
    if length(fn2)>1
        error('Unexpected situation - aborting')
    end
    tmax10=tmax10_S.(fn2{1}).imgdata;
    tmax10=squeeze(tmax10(1:size(tmax10,2),:,:,:));

    %save cstate

    data.PatientID=tmax6_S.(fn1{1}).dcms(1).info.PatientID;

    %check for slicelocations and check what this is
    if strcmp( data.modality,'CT')
    try
        dcminfos={tmax6_S.(fn1{1}).dcms.info};
        zlocations=zeros(1,length(dcminfos))*nan;
        for k=1:length(dcminfos)
            zlocations(k)=dcminfos{k}.SliceLocation;
        end
        
        
        unique_zlocation_steps=unique( round(100*diff(sort(zlocations)))/100);
        if length(unique_zlocation_steps)>1
            disp('Unexpected multiple zlocation increments - will pick the first one...')

        end
        %pich the first one - seems to be what SPM does...
        mytmp=diff(sort(zlocations));
        unique_zlocation_steps=mytmp(1);
        
        if length(unique(zlocations)==1)   %if Toshiba cases with zlocations all the same
            sorted_zposs=round(100*sort(tmax6_S.(fn1{1}).zposs))/100;
            assert(length(unique(diff(sorted_zposs)))==1);
            truncspacing=floor(100*0.5*tmax6_S.(fn1{1}).dcms(1).info.PixelSpacing)/(0.5*100);
            data.voxvol=prod(abs([tmax6_S.(fn1{1}).zspacing   truncspacing']))/1000; 
        else
            tmax6_S.(fn1{1}).zspacing
            w=warning('using zlocations to conform to RAPID!');
            waitfor(w);
            data.voxvol=prod(abs([unique_zlocation_steps tmax6_S.(fn1{1}).dcms(1).info.PixelSpacing']))/1000;
        end
    catch
        data.voxvol=prod(abs([tmax6_S.(fn1{1}).zspacing tmax6_S.(fn1{1}).dcms(1).info.PixelSpacing']))/1000;
    end
    else
        data.voxvol=prod(abs([tmax6_S.(fn1{1}).zspacing tmax6_S.(fn1{1}).dcms(1).info.PixelSpacing']))/1000; %MR default
    end

    [p,data.slabname]=fileparts(folder);
    [p,data.date]=fileparts(p);





    tmax_grayS=dread([folder '/*_tmax_slice*dcm']);
    tmax_gray=tmax_grayS.D_RAPIDTMaxs.imgdata;
    tmax_gray=tmax_gray(1:size(tmax_gray,2),:,:,:);
    data.hypoROI=mymontage(tmax6)>0;
    data.tmax10=mymontage(tmax10)>0;
    %data.hypobl=imrescale(single(mymontage(bl)),[0 150],[0 1]);
    data.hypoBG=uint16(imrescale(single(mymontage(tmax_gray)),[0 200],[0 119]));
    data.hypocolormap=[gray(120) ; 0 1 0 ; 1 0 0 ; 1 0 1];
    %colormap(data.colormap);
    data.excludeHYPO=zeros(size(data.hypoROI))>0;
    data.hypo10=mymontage(tmax10)>0;



    %work out the RAPID version

end


%now core

if strcmp(data.modality,'CT')

        corename='/*_cbf_lesion_mask_slice*';  %tmp override

    
    
    blimg=uint16(imrescale(  single(mymontage(squeeze(BL_s.D_RAPIDAnatomic.imgdata))),[0 100],[0 119]));
    
    %find out if MRI or CT and act accordingly
    core_maskS=dread([folder corename]);
    fn=fieldnames(core_maskS);
    coremask=core_maskS.(fn{1}).imgdata;
    coremask=squeeze(coremask(1:size(coremask,2),:,:,:));
    CBFbgS=dread([folder '/*_cbf_slice*']);
    CBFbg=CBFbgS.D_RAPIDCBF.imgdata;
    CBFbg=squeeze(CBFbg(1:size(CBFbg,2),:,:,:));
    %data.corebl=imrescale(single(mymontage(bl)),[0 150],[0 1]);
    data.coreROI=mymontage(coremask)>0;
    data.coreBG=uint16(imrescale(single(mymontage(CBFbg)),[0 prctile(single(CBFbg( CBFbg>0)),95 )],[0 119]));
    data.corecolormap=[gray(120) ; 1 0 1];
    data.excludeCORE=zeros(size(data.coreROI))>0;
    data.blimg=(blimg);
    

    %colormap(data.colormap);
else %assume MR
    %   data.bl=single(bl);  %RESCALE APPOP
    
    
    core_maskS=dread([folder '/*_DWI_lesion_mask_slice*']);
    fn3=fieldnames(core_maskS);
    coremask=core_maskS.(fn3{1}).imgdata;
    coremask=squeeze(coremask(1:size(coremask,2),:,:,:));
    
    try
        DWIbgS=dread([folder '/*_isoDWI_slice*']);
    catch
        DWIbgS=tmax_grayS;
        disp('BG overrtide')
        %DWIbgS=dread([folder '/isodwi_slice*']);
    end
    dwifn=fieldnames(DWIbgS);
    DWIbg=DWIbgS.(dwifn{1}).imgdata;
    DWIbg=squeeze(DWIbg(1:size(DWIbg,2),:,:,:));
    
    
    data.coreROI=mymontage(coremask)>0;
    data.coreBG=uint16(imrescale(single(mymontage(DWIbg)),[0 prctile(single(DWIbg( DWIbg>0)),98 )],[0 119]));
    data.corecolormap=[gray(120) ; 1 0 1];
    data.excludeCORE=zeros(size(data.coreROI))>0;
    
    
    if data.DWIonly
        data.hypoROI=data.coreROI*0;
        data.tmax10=data.coreROI*0;
        data.hypoBG=data.coreBG*0;
        data.hypocolormap=[gray(120) ; 0 1 0 ; 1 0 0 ; 1 0 1];
        data.excludeHYPO=zeros(size(data.hypoROI))>0;
        data.hypo10=data.coreROI*0;
        data.PatientID=DWIbgS.(dwifn{1}).dcms(1).info.PatientID;
        data.voxvol=prod(abs([DWIbgS.(dwifn{1}).zspacing DWIbgS.(dwifn{1}).dcms(1).info.PixelSpacing']))/1000; %MR default
    end
    
    %data.ROI=
    %data.BG=
    
end
%64.1 (14227)

%