function storestruct=stanford_cleanup_make_storestruct(data,comments)


storestruct.excludeHYPO=data.excludeHYPO;
storestruct.excludeCORE=data.excludeCORE;

storestruct.COREvol_orig=data.voxvol*sum(data.coreROI(:));
storestruct.HYPOvol_orig=data.voxvol*sum(data.hypoROI(:));
storestruct.HYPOvol10_orig=data.voxvol*sum(data.tmax10(:));

storestruct.COREvol_corr=data.voxvol*sum((~data.excludeCORE(:))&data.coreROI(:));
storestruct.HYPOvol_corr=data.voxvol*sum((~data.excludeHYPO(:))&data.hypoROI(:));
storestruct.HYPOvol10_corr=data.voxvol*sum((~data.excludeHYPO(:))&data.tmax10(:));
identifier=[ data.PatientID '-' data.date '-' data.slabname ];
storestruct.identifier=identifier;


[preimg,postimg]=stanford_cleanup_make_imgreport(data,storestruct.identifier,storestruct.COREvol_orig,storestruct.COREvol_corr,......
    storestruct.HYPOvol_orig,storestruct.HYPOvol_corr,storestruct.HYPOvol10_orig,storestruct.HYPOvol10_corr);




storestruct.preimg=preimg;
storestruct.postimg=postimg;
