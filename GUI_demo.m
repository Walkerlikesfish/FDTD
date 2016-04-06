function varargout = GUI_demo_DDFMonline_data(varargin)
% GUI_DEMO_DDFMONLINE_DATA MATLAB code for GUI_demo_DDFMonline_data.fig
%      GUI_DEMO_DDFMONLINE_DATA, by itself, creates a new GUI_DEMO_DDFMONLINE_DATA or raises the existing
%      singleton*.
%
%      H = GUI_DEMO_DDFMONLINE_DATA returns the handle to a new GUI_DEMO_DDFMONLINE_DATA or the handle to
%      the existing singleton*.
%
%      GUI_DEMO_DDFMONLINE_DATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_DEMO_DDFMONLINE_DATA.M with the given input arguments.
%
%      GUI_DEMO_DDFMONLINE_DATA('Property','Value',...) creates a new GUI_DEMO_DDFMONLINE_DATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_demo_DDFMonline_data_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_demo_DDFMonline_data_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_demo_DDFMonline_data

% Last Modified by GUIDE v2.5 06-Apr-2016 16:56:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_demo_DDFMonline_data_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_demo_DDFMonline_data_OutputFcn, ...
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


% --- Executes just before GUI_demo_DDFMonline_data is made visible.
function GUI_demo_DDFMonline_data_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_demo_DDFMonline_data (see VARARGIN)

% Choose default command line output for GUI_demo_DDFMonline_data
handles.output = hObject;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI_demo_DDFMonline_data wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_demo_DDFMonline_data_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in push_start.
function push_start_Callback(hObject, eventdata, handles)

xdim=100;
ydim=100;

% Total no of time steps
time_tot=200;

% Position of the source (center of the field domain)
xsource=50;
ysource=50;

% Courant stability factor
S=1/(2^0.5);

% Parameters of free space (permittivity and permeability and speed of
% light) are all 1 since the domain is unitless
epsilon0=1;
mu0=1;
c=1;

% Spatial and temporal grid step lengths
delta=1;
deltat=S*delta/c;

% Initialization of field matrices
Ez=zeros(xdim,ydim);
Hy=zeros(xdim,ydim);
Hx=zeros(xdim,ydim);

% Initialization of permittivity and permeability matrices
epsilon=epsilon0*ones(xdim,ydim);
mu=mu0*ones(xdim,ydim);

% Choice of form of source
gaussian=0;
sine=0;
impulse=1;
% Choose any one as 1 and rest as 0. The variable names for forms are self-
% explanatory.
% Default form (i.e when all above variables are 0) is Unit time step

% Temporal update loop begins
for n=1:1:time_tot
    
    % Condition if source is impulse or unit-time step 
    if gaussian==0 && sine==0 && n==1
        Ez(xsource,ysource)=1;
    end
    
    % Spatial update loops for Hy and Hx fields begin
    % Here we assume that at the boarder, it is always(Hy=0 Hx=0), which 
    % indicates a PMC. Which would result in reflection of E.
    for i=1:1:xdim-1
        for j=1:1:ydim-1
            Hy(i,j)=Hy(i,j)+(deltat/(delta*mu(i,j)))*(Ez(i+1,j)-Ez(i,j));
            Hx(i,j)=Hx(i,j)-(deltat/(delta*mu(i,j)))*(Ez(i,j+1)-Ez(i,j));
        end
    end
    % Spatial update loops for Hy and Hx fields end
    
    % Spatial update loop for Ez field begins
    for i=2:1:xdim
        for j=2:1:ydim
            Ez(i,j)=Ez(i,j)+(deltat/(delta*epsilon(i,j)))*(Hy(i,j)-Hy(i-1,j)-Hx(i,j)+Hx(i,j-1));
        end
    end
    % Spatial update loop for Ez field ends
    
    % Source conditions
    if impulse==0
        % If unit-time step
        if gaussian==0 && sine==0
            Ez(xsource,ysource)=1;
        end
        % If sinusoidal
        if sine==1
            tstart=1;
            N_lambda=20;
            Ez(xsource,ysource)=sin(((2*pi*(1/N_lambda)*(n-tstart)*deltat)));
        end
        % If gaussian
        if gaussian==1
            if n<=42
                Ez(xsource,ysource)=(10-15*cos(n*pi/20)+6*cos(2*n*pi/20)-cos(3*n*pi/20))/32;
            else
                Ez(xsource,ysource)=0;
            end
        end
    else
        % If impulse
        Ez(xsource,ysource)=0;
    end
%     figure(1)
%     % Movie type colour scaled image plot of Ez
%     imagesc(Ez',[-1,1]);colorbar;
%     title(['\fontsize{20}Colour-scaled image plot of Ez for 2D FDTD (TM) in a unitless domain at timestep = ',num2str(n)]);
%     xlabel('x (in spacesteps)','FontSize',20);
%     ylabel('y (in spacesteps)','FontSize',20);
%     set(gca,'FontSize',20);
%     getframe;
%     figure(2)
    % Movie type colour scaled image plot of Ez
    %contourf(Ez,[-1 1]); colorbar
    %imagesc(Ez',[-1,1]);colorbar;
    pcolor(Ez');colorbar;
    % choose shading or not 
    shading interp;
    caxis([-0.5 5])
    %title(['\fontsize{20}Colour-scaled image plot of Ez for 2D FDTD (TM) in a unitless domain at timestep = ',num2str(n)]);
    xlabel('x (in spacesteps)','FontSize',20);
    ylabel('y (in spacesteps)','FontSize',20);
    set(gca,'FontSize',20);
    %getframe(handles.axes1);
    drawnow
    if get(handles.toggle_pause,'Value')==1
    else
       uiwait
    end
end


% hObject    handle to push_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over push_start.
function push_start_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to push_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in toggle_pause.
function toggle_pause_Callback(hObject, eventdata, handles)
% hObject    handle to toggle_pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume;
% Hint: get(hObject,'Value') returns toggle state of toggle_pause

% --- Executes during object creation, after setting all properties.
function toggle_pause_CreateFcn(hObject, eventdata, handles)
% hObject    handle to toggle_pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
