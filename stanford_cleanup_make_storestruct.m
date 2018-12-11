function [storestruct,corestack,hypostack]=stanford_cleanup_make_storestruct(data,comments)


storestruct.excludeHYPO=data.excludeHYPO;
storestruct.excludeCORE=data.excludeCORE;





storestruct.COREvol_orig=data.voxvol*sum(data.coreROI(:));
storestruct.HYPOvol_orig=data.voxvol*sum(data.hypoROI(:));
storestruct.HYPOvol10_orig=data.voxvol*sum(data.tmax10(:));

coreROImont=data.coreROI&(~data.excludeCORE);
hypoROImont=data.hypoROI&(~data.excludeHYPO);

%stacks for DICOM export
if strcmp(data.caseflag,'DWIonly')
    fn=fieldnames(data.stacktemplate);
    templateimgdata=data.stacktemplate.(fn{1}).imgdata;
    [mont,im_pr_row,im_pr_col,core_corrected]=mymontage(squeeze(templateimgdata),coreROImont);
    corestack=squeeze(core_corrected);
    hypostack=nan;
     %core_corr_img
     %hypo_corr_img
elseif strcmp(data.caseflag,'DWIandPWI')
    fn=fieldnames(data.stacktemplate);
    templateimgdata=data.stacktemplate.(fn{1}).imgdata;
    [mont,im_pr_row,im_pr_col,core_corrected]=mymontage(squeeze(templateimgdata),coreROImont);
    corestack=squeeze(core_corrected);
    
    [mont,im_pr_row,im_pr_col,hypo_corrected]=mymontage(squeeze(templateimgdata),hypoROImont);
    hypostack=squeeze(hypo_corrected);
    
elseif strcmp(data.caseflag,'CTPonly')
   
    if data.numberofslabs==1
        fn=fieldnames(data.stacktemplate);
        templateimgdata=data.stacktemplate.(fn{1}).imgdata;
        [mont,im_pr_row,im_pr_col,core_corrected]=mymontage(squeeze(templateimgdata),coreROImont);
        corestack=squeeze(core_corrected);
    
        [mont,im_pr_row,im_pr_col,hypo_corrected]=mymontage(squeeze(templateimgdata),hypoROImont);
        hypostack=squeeze(hypo_corrected);
        
    else % 2 slabs
       %slab1
       fn=fieldnames(data.stacktemplate{1});
        templateimgdata=data.stacktemplate{1}.(fn{1}).imgdata;
        [mont,im_pr_row,im_pr_col,core_corrected]=mymontage(squeeze(templateimgdata),coreROImont(:,1:size(coreROImont,2)/2) );
        corestack_s1=squeeze(core_corrected);
    
        [mont,im_pr_row,im_pr_col,hypo_corrected]=mymontage(squeeze(templateimgdata),hypoROImont(:,1:size(hypoROImont,2)/2));
        hypostack_s1=squeeze(hypo_corrected);
        
       %     fn=fieldnames(data.stacktemplate{2});
       % templateimgdata=data.stacktemplate{1}.(fn{1}).imgdata;
        [mont,im_pr_row,im_pr_col,core_corrected]=mymontage(squeeze(templateimgdata),coreROImont(:,size(coreROImont,2)/2:end) );
        corestack_s2=squeeze(core_corrected);
    
        [mont,im_pr_row,im_pr_col,hypo_corrected]=mymontage(squeeze(templateimgdata),hypoROImont(:,size(coreROImont,2)/2:end) );
        hypostack_s2=squeeze(hypo_corrected);
        
        
        corestack={corestack_s1,corestack_s2};
        hypostack={hypostack_s1,hypostack_s2};
        
        
        
       
    end
end
    
    

storestruct.COREvol_corr=data.voxvol*sum(coreROImont(:));
storestruct.HYPOvol_corr=data.voxvol*sum((~data.excludeHYPO(:))&data.hypoROI(:));
storestruct.HYPOvol10_corr=data.voxvol*sum((~data.excludeHYPO(:))&data.tmax10(:));
data.date=char(datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss'));

if data.DWIonly
    storestruct.HYPOvol_orig=NaN;
    storestruct.HYPOvol10_orig=NaN;   
    storestruct.HYPOvol_corr=NaN;
    storestruct.HYPOvol10_corr=NaN;
    data.slabname='DWIonly';
end

identifier=[ data.PatientID '_' data.slabname ];
%identifier=[ data.PatientID ' / '  data.slabname ];

storestruct.identifier=identifier;

[preimg,postimg]=stanford_cleanup_make_imgreport(data,storestruct.identifier,storestruct.COREvol_orig,storestruct.COREvol_corr,......
    storestruct.HYPOvol_orig,storestruct.HYPOvol_corr,storestruct.HYPOvol10_orig,storestruct.HYPOvol10_corr);




storestruct.preimg=preimg;
storestruct.postimg=postimg;
