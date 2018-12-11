function varargout = stanford_cleanup(varargin)
% STANFORD_CLEANUP MATLAB code for stanford_cleanup.fig
%      STANFORD_CLEANUP, by itself, creates a new STANFORD_CLEANUP or raises the existing
%      singleton*.
%
%      H = STANFORD_CLEANUP returns the handle to a new STANFORD_CLEANUP or the handle to
%      the existing singleton*.
%
%      STANFORD_CLEANUP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STANFORD_CLEANUP.M with the given input arguments.
%
%      STANFORD_CLEANUP('Property','Value',...) creates a new STANFORD_CLEANUP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before stanford_cleanup_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to stanford_cleanup_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help stanford_cleanup

% Last Modified by GUIDE v2.5 11-Dec-2014 16:00:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @stanford_cleanup_OpeningFcn, ...
    'gui_OutputFcn',  @stanford_cleanup_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before stanford_cleanup is made visible.
function stanford_cleanup_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to stanford_cleanup (see VARARGIN)

% Choose default command line output for stanford_cleanup
handles.output = hObject;
%handles.mode=varargin{1};
set(handles.thold1,'value',3);
set(handles.thold2,'value',5);


set(handles.togglebutton,'userdata',1);
set(handles.togglebutton,'String','Showing Hypoperfusion');
set(handles.input_maindir,'string','.')


handles.imref=image(zeros(100),'parent',handles.axes1);
axes(handles.axes1);
axis off
axis equal
% Update handles structure
guidata(hObject, handles);


if nargin==4
    item=varargin{1}{1};
    if isstruct(item)
        error('deprecated')
        %loadfromstruct(handles,item); %not supported..
    else
        folder=varargin{1}{1};
        loadfolder( handles,['/titanhome/sorenc/WORKBENCH/JOHNTTP/DEFUSE2_rerun/' folder]);
        readedits(handles,['/titanhome/sorenc/WORKBENCH/JOHNTTP/DEFUSE2_rerun/' folder '/corelab.mat'])
        save_imgreport(handles.data,['/titanhome/sorenc/WORKBENCH/JOHNTTP/DEFUSE2_rerun/' folder])
    end
end
% UIWAIT makes stanford_cleanup wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = stanford_cleanup_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_openfolder.
function pushbutton_openfolder_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_openfolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tmp=hObject;
if 1
    handles=guidata(handles.figure1);
    %folder=uigetdir('/research/CRISP/CORELAB_IMAGEDATA/RAPID_PROCESSING/');
    %folder=uigetdir('/titanhome/sorenc/WORKBENCH/JMdata/');
    folder=uigetdir(get(handles.input_maindir,'string')); % uigetdir('/titanhome/anke/');
    if isnumeric(folder)
        return;
    end
else
    load cstate
    handles=guidata(tmp);
end
loadfolder(handles,folder)

%
% function loadfromstruct(handles,mystruct)
% handles=guidata(handles.figure1);
%
% %usemask_indices=[2 4];
%
%
% %this one is global
% % tmax6_S=dread([folder '/*_TMax_lesion_mask' num2str(usemask_indices(1)) '*']);   %NB NB NB
% % fn1=fieldnames(tmax6_S);  %seems to vary MR to CT...
% % if length(fn1)>1
% %     error('Unexpected situation - aborting')
% % end
% % %work around
% % tmax6=tmax6_S.(fn1{1}).imgdata;
% %tmax6=squeeze(tmax6(1:size(tmax6,2),:,:,:));
%
% tmax6=squeeze(mystruct.tmaxroi1);
%
%
% % tmax10_S=dread([folder '/*_TMax_lesion_mask'  num2str(usemask_indices(2)) '*']);
% % fn2=fieldnames(tmax10_S);  %seems to vary MR to CT...
% % if length(fn2)>1
% %     error('Unexpected situation - aborting')
% % end
% % tmax10=tmax10_S.(fn2{1}).imgdata;
% % tmax10=squeeze(tmax10(1:size(tmax10,2),:,:,:));
% tmax10=squeeze(mystruct.tmaxroi2);
% %save cstate
%
% % handles.modality=tmax6_S.(fn1{1}).dcms(1).info.Modality;
% % handles.PatientID=tmax6_S.(fn1{1}).dcms(1).info.PatientID;
% % handles.voxvol=prod(abs([tmax6_S.(fn1{1}).zspacing tmax6_S.(fn1{1}).dcms(1).info.PixelSpacing']))/1000;
%
% % handles.folder=folder;
% %
% % [p,handles.slabname]=fileparts(folder);
% % [p,handles.date]=fileparts(p);
% %
% handles.folder=mystruct.location;
% handles.modality='MR';
% handles.PatientID=mystruct.ID;
% handles.voxvol=mystruct.voxvol;
% set(handles.figure1,'name',[handles.folder ' Patient ID: ' handles.PatientID] );
%
% %
% % tmax_grayS=dread([folder '/*_tmax_slice*dcm']);
% % tmax_gray=tmax_grayS.D_RAPIDTMaxs.imgdata;
% % tmax_gray=tmax_gray(1:size(tmax_gray,2),:,:,:);
% % handles.hypoROI=mymontage(tmax6)>0;
% % handles.tmax10=mymontage(tmax10)>0;
% % %handles.hypobl=imrescale(single(mymontage(bl)),[0 150],[0 1]);
% % handles.hypoBG=uint16(imrescale(single(mymontage(tmax_gray)),[0 200],[0 119]));
% % handles.hypocolormap=[gray(120) ; 0 1 0 ; 1 0 0 ; 1 0 1];
% % %colormap(handles.colormap);
% % handles.excludeHYPO=zeros(size(handles.hypoROI))>0;
% % handles.hypo10=mymontage(tmax10)>0;
%
%
% tmax_gray=mystruct.tmaximg;
% handles.hypoROI=mymontage(tmax6)>0;
% handles.tmax10=mymontage(tmax10)>0;
% handles.hypo10=mymontage(tmax10)>0;
% handles.excludeHYPO=zeros(size(handles.hypoROI))>0;
% handles.hypocolormap=[gray(120) ; 0 1 0 ; 1 0 0 ; 1 0 1];
% handles.hypoBG=uint16(imrescale(single(mymontage(tmax_gray)),[0 200],[0 119]));
%
% if strcmp(handles.modality,'CT')
%     %find out if MRI or CT and act accordingly
%     %     core_maskS=dread([folder '/*_core_mask_slice*']);
%     %     coremask=core_maskS.(fn{1}).imgdata;
%     %     coremask=squeeze(coremask(1:size(coremask,2),:,:,:));
%     %     CBFbgS=dread([folder '/*_cbf_slice*']);
%     %     CBFbg=CBFbgS.D_RAPIDCBF.imgdata;
%     %     CBFbg=squeeze(CBFbg(1:size(CBFbg,2),:,:,:));
%     %     %handles.corebl=imrescale(single(mymontage(bl)),[0 150],[0 1]);
%     %     handles.coreROI=mymontage(coremask)>0;
%     %     handles.coreBG=uint16(imrescale(single(mymontage(CBFbg)),[0 prctile(single(CBFbg( CBFbg>0)),95 )],[0 119]));
%     %     handles.corecolormap=[gray(120) ; 1 0 1];
%     %     handles.excludeCORE=zeros(size(handles.coreROI))>0;
%     %colormap(handles.colormap);
% else %assume MR
%     %   handles.bl=single(bl);  %RESCALE APPOP
%
%     %     core_maskS=dread([folder '/*_DWI_lesion_mask_slice*']);
%     %     fn3=fieldnames(core_maskS);
%     %     coremask=core_maskS.(fn3{1}).imgdata;
%     %     coremask=squeeze(coremask(1:size(coremask,2),:,:,:));
%     %
%     %     try
%     %     DWIbgS=dread([folder '/*_isoDWI_slice*']);
%     %     catch
%     %         DWIbgS=tmax_grayS;
%     %         disp('BG overrtide')
%     %         %DWIbgS=dread([folder '/isodwi_slice*']);
%     %     end
%     %     dwifn=fieldnames(DWIbgS);
%     %     DWIbg=DWIbgS.(dwifn{1}).imgdata;
%     %     DWIbg=squeeze(DWIbg(1:size(DWIbg,2),:,:,:));
%     coremask=mystruct.coreroi;
%     DWIbg=mystruct.coreimg;
%
%     handles.coreROI=mymontage(coremask)>0;
%     handles.coreBG=uint16(imrescale(single(mymontage(DWIbg)),[0 prctile(single(DWIbg( DWIbg>0)),98 )],[0 119]));
%     handles.corecolormap=[gray(120) ; 1 0 1];
%     handles.excludeCORE=zeros(size(handles.coreROI))>0;
%
%     %handles.ROI=
%     %handles.BG=
%
% end
%
% handles.date='';
% handles.slabname='';
% guidata(handles.figure1,handles);
%
% initGUI(handles.figure1);


function loadfolder(handles,folder)
handles=guidata(handles.figure1);

% try
%     bl_S=dread([folder '/*_pwi_data*']);
% catch
%     w=errordlg('Files not found - Are you pointing to the correct folder? - program aborting');
%     waitfor(w)
%     close(handles.figure1)
%
% end
% bl=squeeze(bl_S.D_RAPIDDWIandPWIMismatchLesionSizescolor.imgdata);
% bl(1:size(bl,2),:,:,:);


%Tmax6 and 10 var names are really just place holders for the indices used in the
%colormap - not to be interpreted litterally (legacy naming)



%usemask_indices=[2 4];

%usemask_indices=[2 4];

usemask_indices=[get(handles.thold1,'value')-1 get(handles.thold2,'value')-1];

%test for RAPID 4.5.1 or RAPID 4.6 in folder

if exist(myglob2([folder '/*_protocol.txt']),'file')
    data=stanford_cleanup_get_image_data451(folder,usemask_indices);
elseif exist(myglob2([folder '/*output.json']),'file')
    data=stanford_cleanup_get_image_data46(folder);
else
    warning('Could not find any relevant data in this folder...')
    return
end



handles.data=data;


guidata(handles.figure1,handles);
initGUI(handles.figure1);

function remapROI(fighandle)
handles=guidata(fighandle);

if get(handles.togglebutton,'userdata')==1  %HYPO
    handles.gui.ROI=handles.data.hypoROI;
    handles.gui.colormap=handles.data.hypocolormap;
    handles.gui.exclude=handles.data.excludeHYPO;
    
    if get(handles.checkbox1,'value')
        handles.gui.BG=handles.data.blimg;
    else
        handles.gui.BG=handles.data.hypoBG;
    end
    
else
    handles.gui.ROI=handles.data.coreROI;
    handles.gui.colormap=handles.data.corecolormap;
    handles.gui.exclude=handles.data.excludeCORE;
    if get(handles.checkbox1,'value')
        handles.gui.BG=handles.data.blimg;
    else
        handles.gui.BG=handles.data.coreBG;
        
    end
    
end
colormap(handles.gui.colormap);
guidata(fighandle,handles);


function initGUI(fighandle)


remapROI(fighandle);
handles=guidata(fighandle);
set(handles.figure1,'name',[handles.data.folder ' Patient ID: ' handles.data.PatientID] );

if handles.data.DWIonly
    set(handles.togglebutton,'userdata',2);
    set(handles.togglebutton,'String','Showing Core');
end
%handles.excludeCORE=zeros(size(handles.ROI))>0;
%handles.excludeHYPO=zeros(size(handles.ROI))>0;
delete(handles.imref)

handles.imref=image(zeros(size(handles.gui.ROI)),'parent',handles.axes1);
axes(handles.axes1);

set(handles.comments,'string',{});

axis image
axis off

guidata(fighandle,handles);
remapROI(handles.figure1);
update(fighandle)


function update(fighandle)
handles=guidata(fighandle);

%redraw
effectiveROI=handles.gui.ROI&(~handles.gui.exclude);

bgimg=handles.gui.BG;
bgimg(effectiveROI)=120;

%if PWI mode then also color tmax10:
if get(handles.togglebutton,'userdata')==1
    tmax10ROI= handles.data.tmax10&(~handles.data.excludeHYPO);
    bgimg(tmax10ROI)=121;
    
    %oh if alpha is more than 0 - then also mix in a core image...
    
    alp=get(handles.slider1,'value');
    if (alp>0)
        core_corrected=handles.data.coreROI&(~handles.data.excludeCORE);
        bgimg(core_corrected)=122;
        
        
        
    end
    
    
end
%update volume
set(handles.imref,'cdata',bgimg);

tmax10vol=handles.data.voxvol*sum( handles.data.tmax10(:)&(~handles.data.excludeHYPO(:)) );
tmax6vol=handles.data.voxvol*sum( handles.data.hypoROI(:)&(~handles.data.excludeHYPO(:)) );
corevol=handles.data.voxvol*sum( handles.data.coreROI(:)&(~handles.data.excludeCORE(:)) );


%volume=handles.voxvol*sum(effectiveROI(:));
set(handles.text_volume,'string',[num2str(tmax6vol,'%2.2f') ' mL']);
set(handles.text_volume10,'string',[num2str(tmax10vol,'%2.2f') ' mL']);
set(handles.text_volume_core,'string',[num2str(corevol,'%2.2f') ' mL']);


% --- Executes on button press in pushbutton_cleanup.
function pushbutton_cleanup_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cleanup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(handles.figure1);

axes(handles.axes1);
try
    currentROI=roipoly;
catch %do not store change - no change...
    update(handles.figure1);
    return;
end

handles.gui.exclude=handles.gui.exclude|currentROI;

%store it immediately into it's real parent

if get(handles.togglebutton,'userdata')==1  %HYPO
    
    handles.data.excludeHYPO=handles.gui.exclude;
else
    
    handles.data.excludeCORE=handles.gui.exclude;
end


guidata(handles.figure1,handles);
update(handles.figure1);



% --- Executes on button press in pushbutton_reset.
function pushbutton_reset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(handles.figure1);
handles.data.excludeCORE=handles.data.excludeCORE*0;
handles.data.excludeHYPO=handles.data.excludeHYPO*0;
handles.gui.exclude=handles.gui.exclude*0;
guidata(handles.figure1,handles);
update(handles.figure1);



% --- Executes on button press in pushbutton_done.
function pushbutton_done_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Store a GUI restore structure, a clean mask and a summary image of this
%case
handles=guidata(handles.figure1);
[fname,savefolder]=uiputfile([handles.data.folder '/corelab.mat'],'Select Storage location');

comments=get(handles.comments,'string');

[storestruct,core_corrected,hypo_corrected]=stanford_cleanup_make_storestruct(handles.data,comments);

save([savefolder filesep fname],'storestruct');
struct_json=struct('identifier',storestruct.identifier,'COREvol_orig',storestruct.COREvol_orig,'HYPOvol_orig',storestruct.HYPOvol_orig,'HYPOvol10_orig',storestruct.HYPOvol10_orig,'COREvol_corr',storestruct.COREvol_corr,'HYPOvol_corr',storestruct.HYPOvol_corr, 'HYPOvol10_corr',storestruct.HYPOvol10_corr);   
savejson('volumes',struct_json,strcat(savefolder,'corelab.json'));
save_imgreport(handles.data,savefolder);

%finally save DICOMs 

switch handles.data.caseflag
    case 'DWIandPWI'
        series_description='MRcore_corelab';
        series_number=2011;
        write_dicoms_using_template(core_corrected,savefolder,series_description,series_number,handles.data.stacktemplate)
        
        series_description='MRhypo_corelab';
        series_number=2012;
        write_dicoms_using_template(hypo_corrected,savefolder,series_description,series_number,handles.data.stacktemplate)
    case 'DWIonly'
        series_description='MRcore_corelab';
        series_number=2011;
        write_dicoms_using_template(core_corrected,savefolder,series_description,series_number,handles.data.stacktemplate)
    case 'CTPonly'
        if handles.data.numberofslabs==1
            series_description='CTPcore_corelab';
            series_number=2011;
            write_dicoms_using_template(core_corrected,savefolder,series_description,series_number,handles.data.stacktemplate)
            
            series_description='CTPhypo_corelab';
            series_number=2012;
            write_dicoms_using_template(hypo_corrected,savefolder,series_description,series_number,handles.data.stacktemplate)
        else %2 slabs
            series_description='CTPcore_corelab_slab1';
            series_number=2011;
            write_dicoms_using_template(core_corrected{1},savefolder,series_description,series_number,handles.data.stacktemplate{1})
            
            series_description='CTPhypo_corelab_slab1';
            series_number=2012;
            write_dicoms_using_template(hypo_corrected{1},savefolder,series_description,series_number,handles.data.stacktemplate{1})
            
            
            series_description='CTPcore_corelab_slab2';
            series_number=2011;
            write_dicoms_using_template(core_corrected{2},savefolder,series_description,series_number,handles.data.stacktemplate{2})
            
            series_description='CTPhypo_corelab_slab2';
            series_number=2012;
            write_dicoms_using_template(hypo_corrected{2},savefolder,series_description,series_number,handles.data.stacktemplate{2})
            
        end
end




        



% preimg=fra1.cdata;
% postimg=fra2.cdata;


% --- Executes on button press in togglebutton.
function togglebutton_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton
%1 is is hypoperfusion, 2 is CORE
if get(hObject,'userdata')==1
    set(handles.togglebutton,'userdata',2);
    set(handles.togglebutton,'String','Showing Core');
else
    set(handles.togglebutton,'userdata',1);
    set(handles.togglebutton,'String','Showing Hypoperfusion');
end
remapROI(handles.figure1);
update(handles.figure1);


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
update(handles.figure1);



% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on button press in pushbutton_readedits.
function pushbutton_readedits_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_readedits (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(handles.figure1);
[myfile,p]=uigetfile(handles.data.folder,'Select Mat file');

%stanford_cleanup_readedits([p myfile]);
edits=stanford_cleanup_readedits([p myfile]);

handles.data.excludeCORE=edits.excludeCORE;
handles.data.excludeHYPO=edits.excludeHYPO;

guidata(handles.figure1,handles);

remapROI(handles.figure1)
update(handles.figure1);




% --- Executes on button press in setworkfolder.
function setworkfolder_Callback(hObject, eventdata, handles)
% hObject    handle to setworkfolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(handles.figure1);
[p]=uigetdir('Select folder');
%handles.mainfolder=p;
set(handles.input_maindir,'string',p)
guidata(handles.figure1,handles);
set(hObject,'tooltipstring',p)



function input_maindir_Callback(hObject, eventdata, handles)
% hObject    handle to input_maindir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of input_maindir as text
%        str2double(get(hObject,'String')) returns contents of input_maindir as a double


% --- Executes during object creation, after setting all properties.
function input_maindir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to input_maindir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in thold1.
function thold1_Callback(hObject, eventdata, handles)
% hObject    handle to thold1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns thold1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from thold1


% --- Executes during object creation, after setting all properties.
function thold1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thold1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in thold2.
function thold2_Callback(hObject, eventdata, handles)
% hObject    handle to thold2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns thold2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from thold2


% --- Executes during object creation, after setting all properties.
function thold2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to thold2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function comments_Callback(hObject, eventdata, handles)
% hObject    handle to comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of comments as text
%        str2double(get(hObject,'String')) returns contents of comments as a double


% --- Executes during object creation, after setting all properties.
function comments_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comments (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

remapROI(handles.figure1);
update(handles.figure1);

