function save_imgreport(data,savefolder)

storestruct=stanford_cleanup_make_storestruct(data);

if data.DWIonly==1
    data.date='' ; %char(datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss'));
    data.slabname='DWIonly';
end

%[preimg,postimg]=make_imgreport(handles.figure1)
imwrite(storestruct.preimg,[savefolder filesep data.PatientID  '_' data.slabname '_corelab_orig.png'])
imwrite(storestruct.postimg,[savefolder filesep data.PatientID  '_' data.slabname '_corelab_corr.png'])

