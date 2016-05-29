function varargout = finalgui(varargin)
% FINALGUI MATLAB code for finalgui.fig
%      FINALGUI, by itself, creates a new FINALGUI or raises the existing
%      singleton*.
%
%      H = FINALGUI returns the handle to a new FINALGUI or the handle to
%      the existing singleton*.
%
%      FINALGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FINALGUI.M with the given input arguments.
%
%      FINALGUI('Property','Value',...) creates a new FINALGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before finalgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to finalgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help finalgui

% Last Modified by GUIDE v2.5 25-Apr-2016 21:33:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @finalgui_OpeningFcn, ...
                   'gui_OutputFcn',  @finalgui_OutputFcn, ...
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


% --- Executes just before finalgui is made visible.
function finalgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to finalgui (see VARARGIN)

% Choose default command line output for finalgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes finalgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = finalgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in segmentImage.
function segmentImage_Callback(hObject, eventdata, handles)
% hObject    handle to segmentImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject)
I = handles.b1
%Adjust Contrast of blue channel of the Original Image
handles.b3 = imadjust(I(:,:,3))
IL = handles.b3

%Get the size and total pixel count of the image
[rows, columns, numberOfColorBands] = size(IL);
[pixelCount, grayLevels] = imhist(IL, 256);

%Divide image in two half and get the total pixel count of the left half
%image
middleColumn = floor(columns/2);
leftHalfImage = IL(:, 1:middleColumn);
[pixelCountL, grayLevelsL] = imhist(leftHalfImage, 256);

%Get the pixel count of the another half right image
rightHalfImage = IL(:, middleColumn+1:end);
[pixelCountR, grayLevelsR] = imhist(rightHalfImage, 256);

%Subtract the two left and right pixelcount and get the subtracted
%histogram
diffHistogram = int16(pixelCountL - pixelCountR);

%Create the threshold level of subtracted histogram value
thresholdLevel = 255 * graythresh(diffHistogram)  % Find Otsu threshold level

%Create mask from the threshold level
mask1 = IL > thresholdLevel;

%Apply Median Filter to the Mask
mask2 = medfilt2(mask1)

%Apply Morphological Operation on the mask which will generate segmented
%Image
SE = strel('disk',2)
mask3 = imerode(mask2,SE)
mask4 = ~imfill(~mask3,'holes')
handles.b2 = mask4
axes(handles.axes2)
imshow(handles.b2)
guidata(hObject,handles)


% --- Executes on button press in extractFeatures.
function extractFeatures_Callback(hObject, eventdata, handles)
% hObject    handle to extractFeatures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject)
IL = handles.b3

%Get the Gradient weightvalue of the Image
weight = mean2(gradientweight(IL))
set(handles.weightValue,'String',weight)

%Get the Major Axis Length
radii = regionprops(handles.b2,'MajorAxisLength')
radii2 = mean2(cat(1,radii.MajorAxisLength))
set(handles.radiiValue,'String',radii2)

%Calculate Volume
volume = (4.0/3.0)*pi*(radii2^3)
set(handles.volumeValue,'String',volume)

%Calculate Area
area=4.0*pi*(radii2^2)
set(handles.areaValue,'String',area)

I = handles.b1
%Get the separate Channels of the Original Image
red = I(:, :, 1)
green = I(:, :, 2)
blue = I(:, :, 3)
%Convert to HSV Image
hsvImage = rgb2hsv(I)
% Extract out the H, S, and V images individually
hImage = hsvImage(:,:,1);
sImage = hsvImage(:,:,2);
vImage = hsvImage(:,:,3);

%Threshold for Yellow Color
YhueThresholdLow = 0.10;
YhueThresholdHigh = 0.14;
YsaturationThresholdLow = 0.4;
YsaturationThresholdHigh = 1;
YvalueThresholdLow = 0.8;
YvalueThresholdHigh = 1.0;

% Now apply each color band's particular thresholds to the color band for
% yellow
YhueMask = (hImage >= YhueThresholdLow) & (hImage <= YhueThresholdHigh);
YsaturationMask = (sImage >= YsaturationThresholdLow) & (sImage <= YsaturationThresholdHigh);
YvalueMask = (vImage >= YvalueThresholdLow) & (vImage <= YvalueThresholdHigh);

YcoloredObjectsMask = uint8(YhueMask & YsaturationMask & YvalueMask);

% Smooth the border using a morphological closing operation, imclose().
YstructuringElement = strel('disk', 4);
YcoloredObjectsMask = imclose(YcoloredObjectsMask, YstructuringElement);

% Fill in any holes in the regions, since they are most likely red also.
YcoloredObjectsMask = imfill(logical(YcoloredObjectsMask), 'holes');
YcoloredObjectsMask = cast(YcoloredObjectsMask, 'like', I); 

% Use the colored object mask to mask out the colored-only portions of the rgb image.
YmaskedImageR = YcoloredObjectsMask .* red;
YmaskedImageG = YcoloredObjectsMask .* green;
YmaskedImageB = YcoloredObjectsMask .* blue;

yellowImage = cat(3, YmaskedImageR, YmaskedImageG, YmaskedImageB);

%Yellow Pixel Count
yel = mean2(yellowImage(find(yellowImage)))

%Threshold for Red Color
RhueThresholdLow = 0.03;
RhueThresholdHigh = 1.5;
RsaturationThresholdLow = 0.18;
RsaturationThresholdHigh = 1.5;
RvalueThresholdLow = 0.05;
RvalueThresholdHigh = 1.8;

% Now apply each color band's particular thresholds to the color band for
% Red
RhueMask = (hImage >= RhueThresholdLow) & (hImage <= RhueThresholdHigh);
RsaturationMask = (sImage >= RsaturationThresholdLow) & (sImage <= RsaturationThresholdHigh);
RvalueMask = (vImage >= RvalueThresholdLow) & (vImage <= RvalueThresholdHigh);

RcoloredObjectsMask = uint8(RhueMask & RsaturationMask & RvalueMask);
% Smooth the border using a morphological closing operation, imclose().
RstructuringElement = strel('disk', 4);
RcoloredObjectsMask = imclose(RcoloredObjectsMask, RstructuringElement);

% Fill in any holes in the regions, since they are most likely red also.
RcoloredObjectsMask = imfill(logical(RcoloredObjectsMask), 'holes');
RcoloredObjectsMask = cast(RcoloredObjectsMask, 'like', I); 

% Use the colored object mask to mask out the colored-only portions of the rgb image.
RmaskedImageR = RcoloredObjectsMask .* red;
RmaskedImageG = RcoloredObjectsMask .* green;
RmaskedImageB = RcoloredObjectsMask .* blue;

redImage = cat(3, RmaskedImageR, RmaskedImageG, RmaskedImageB);

%Red Pixel Count
rel = mean2(redImage(find(redImage)))

%Threshold for Green Color
GhueThresholdLow = 0.15;
GhueThresholdHigh = 0.60;
GsaturationThresholdLow = 0.36;
GsaturationThresholdHigh = 1;
GvalueThresholdLow = 0;
GvalueThresholdHigh = 0.8;

% Now apply each color band's particular thresholds to the color band for
% Green
GhueMask = (hImage >= GhueThresholdLow) & (hImage <= GhueThresholdHigh);
GsaturationMask = (sImage >= GsaturationThresholdLow) & (sImage <= GsaturationThresholdHigh);
GvalueMask = (vImage >= GvalueThresholdLow) & (vImage <= GvalueThresholdHigh);

GcoloredObjectsMask = uint8(GhueMask & GsaturationMask & GvalueMask);
% Smooth the border using a morphological closing operation, imclose().
GstructuringElement = strel('disk', 4);
GcoloredObjectsMask = imclose(GcoloredObjectsMask, GstructuringElement);

% Fill in any holes in the regions, since they are most likely red also.
GcoloredObjectsMask = imfill(logical(GcoloredObjectsMask), 'holes');
GcoloredObjectsMask = cast(GcoloredObjectsMask, 'like', I); 

% Use the colored object mask to mask out the colored-only portions of the rgb image.
GmaskedImageR = GcoloredObjectsMask .* red;
GmaskedImageG = GcoloredObjectsMask .* green;
GmaskedImageB = GcoloredObjectsMask .* blue;

greenImage = cat(3, GmaskedImageR, GmaskedImageG, GmaskedImageB);

%Green Pixel Count
gel = mean2(greenImage(find(greenImage)))

ripe = max([yel rel gel])
if ripe == yel
    ripeVal = 'B'
else if ripe == rel
        ripeVal = 'A'
    else if ripe == gel
        ripeVal = 'C'
        else
            ripeVal = 'Undefined'
        end
    end
end
set(handles.ripenessValue,'String',ripeVal)
guidata(hObject,handles)


% --- Executes on button press in saveFeaturesData.
function saveFeaturesData_Callback(hObject, eventdata, handles)
% hObject    handle to saveFeaturesData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles=guidata(hObject)
RadiiVal = get(handles.radiiValue,'String');
AreaVal = get(handles.areaValue,'String');
VolumeVal = get(handles.volumeValue,'String');
WeightVal = get(handles.weightValue,'String');
RipenessVal = get(handles.ripenessValue,'String');

% Store Values in Local Database
filename = 'FeaturesData.xls'
data = {RadiiVal,AreaVal,VolumeVal,WeightVal,RipenessVal}
if(exist(filename))
%     oldData = xlsread(filename)
%     newData = cat(1,oldData,data)
xlsappend(filename,data)
else
    newData = data
    xlswrite(filename,newData)
end

h = msgbox('Features Data Has Been Saved Successfully!!!','Success');
guidata(hObject,handles)

% --- Executes on button press in loadImage.
function loadImage_Callback(hObject, eventdata, handles)
% hObject    handle to loadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.b1=imread(imgetfile)
axes(handles.axes1)
imshow(handles.b1)
guidata(hObject,handles)
