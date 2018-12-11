function [summaryimg_rgb_orig,summaryimg_rgb_corr]=stanford_cleanup_make_imgreport(data,identifier,COREvol_orig,COREvol_corr,HYPOvol_orig,HYPOvol_corr,HYPOvol10_orig,HYPOvol10_corr)

summaryimg=imrescale(single([data.coreBG data.hypoBG]),[0 119],[0 1]);

summaryimg_rgb_orig=cat(3,summaryimg,summaryimg,summaryimg);
summaryimg_rgb_corr=summaryimg_rgb_orig;

CORE_orig_rgb=cat(3,data.coreROI,0*data.coreROI,data.coreROI);
coreROIcorr=(~data.excludeCORE)&data.coreROI;
CORE_corr_rgb=cat(3,coreROIcorr,0*coreROIcorr,coreROIcorr);

HYPO_orig_rgb=cat(3,data.hypoROI*0,data.hypoROI,data.hypoROI*0);
HYPO10_orig_rgb=cat(3,data.tmax10*1,data.tmax10*0,data.tmax10*0);


hypoROIcorr=(~data.excludeHYPO)&data.hypoROI;
HYPO_corr_rgb=cat(3,hypoROIcorr*0,hypoROIcorr,hypoROIcorr*0);


hypoROI10corr=(~data.excludeHYPO)&data.tmax10;
HYPO10_corr_rgb=cat(3,hypoROI10corr*1,hypoROI10corr*0,hypoROI10corr*0);

%put the tmax10 on the tmax 6:
HYPO_corr_rgb=maskonrgb(HYPO_corr_rgb,HYPO10_corr_rgb);
HYPO_orig_rgb=maskonrgb(HYPO_orig_rgb,HYPO10_orig_rgb);


orig_RGB_mask=cat(2,CORE_orig_rgb, HYPO_orig_rgb);
corr_RGB_mask=cat(2,CORE_corr_rgb, HYPO_corr_rgb);



summaryimg_rgb_orig=maskonrgb(summaryimg_rgb_orig,orig_RGB_mask);
summaryimg_rgb_corr=maskonrgb(summaryimg_rgb_corr,corr_RGB_mask);

orig_string=['Original Core: ' num2str(COREvol_orig,'%2.1f')  ' mL.  Original TMAX>6: '  num2str(HYPOvol_orig,'%2.1f') ' mL.  Original Tmax>10: '  num2str(HYPOvol10_orig,'%2.1f') '  ' identifier  ];
corr_string=['Corrected Core: ' num2str(COREvol_corr,'%2.1f')  ' mL.  Corrected TMAX>6: '  num2str(HYPOvol_corr,'%2.1f')  ' mL.  Corrected Tmax>10: '  num2str(HYPOvol10_corr,'%2.1f') '  ' identifier ];
[size_x, size_y, size_z]=size(summaryimg_rgb_orig);

try 
summaryimg_rgb_orig=insertText(summaryimg_rgb_orig,[30,size_x-40],orig_string,'FontSize',20,'BoxColor','black','BoxOpacity',0,'TextColor','white');
summaryimg_rgb_corr=insertText(summaryimg_rgb_corr,[30,size_x-40],corr_string,'FontSize',20,'BoxColor','black','BoxOpacity',0,'TextColor','white');
catch
summaryimg_rgb_orig=textonrgb(summaryimg_rgb_orig,orig_string,[1 1 1],[0 0 0],0,20);
summaryimg_rgb_corr=textonrgb(summaryimg_rgb_corr,corr_string,[1 1 1],[0 0 0],0,20);
end