function write_dicoms_using_template(img_corr,savefolder,series_description,series_number,template_dcm)
    
    fn=fieldnames(template_dcm);
    templateseries=template_dcm.(fn{1});
    dcms=templateseries.dcms;
    order=templateseries.sortorder;
    
    assert(length(order)==size(img_corr,3));
    seriesUID=dicomuid();
    for cindx=1:length(order)
        cstruct=dcms( order(cindx) );
        cinfo=cstruct.info;
        cinfo.SeriesDescription=series_description;
        cinfo.SeriesNumber=series_number;
        cinfo.SOPInstanceUID=dicomuid();
        cinfo.SeriesInstanceUID=seriesUID;
        cinfo.SeriesInstanceUID;
       % cinfo.SOPClassUID='1.2.840.10008.5.1.4.1.1.4';
       % cinfo.MediaStorageSOPClassUID='1.2.840.10008.5.1.4.1.1.4';
        dicomwrite(uint16(img_corr(:,:,cindx)),[savefolder series_description '_' sprintf('%03u',cindx) '.dcm'],cinfo, 'CreateMode', 'copy')
    end
        
        