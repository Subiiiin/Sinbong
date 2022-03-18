function varargout = homework210527(varargin)
% HOMEWORK210527 MATLAB code for homework210527.fig
%      HOMEWORK210527, by itself, creates a new HOMEWORK210527 or raises the existing
%      singleton*.
%
%      H = HOMEWORK210527 returns the handle to a new HOMEWORK210527 or the handle to
%      the existing singleton*.
%
%      HOMEWORK210527('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HOMEWORK210527.M with the given input arguments.
%
%      HOMEWORK210527('Property','Value',...) creates a new HOMEWORK210527 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before homework210527_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to homework210527_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help homework210527

% Last Modified by GUIDE v2.5 04-Jun-2021 12:25:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @homework210527_OpeningFcn, ...
                   'gui_OutputFcn',  @homework210527_OutputFcn, ...
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


% --- Executes just before homework210527 is made visible.
function homework210527_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to homework210527 (see VARARGIN)

% Choose default command line output for homework210527
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% 초기 설정 - 주파수 스펙트럼 그래프
global f i y h1 ii;
f = [0 150 300 600 1200 2400 4800 9200 18400];                         %% frequency spectrum 주파수 라벨링
i = [0 0.5 1.5 2.5 3.5 4.5 5.5 6.5 7.5 8.5];                           %% 주파수 배열 인덱싱
y = [0 0 0 0 0 0 0 0 0 0];                                             %% 초기 주파수 값 설정
ii = 0:0.1:8.5;                                                        %% spline 간격 설정
f1 = interp1(i, y, ii, 'spline');                                      %% 초기 주파수 스펙트럼 보간법 적용
h1 = plot(handles.axes_FreqSpectrum, ii, f1);                          %% 초기 주파수 스펙트럼 세팅
set(h1, 'LineWidth', 2);                                               %% 주파수 스펙트럼 그래프 굵기 설정
set(handles.axes_FreqSpectrum, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1], 'ylim', [-10 10], 'xlim', [0 8.5], 'XTickLabel', f);      %%주파수 스펙트럼 그래프 모양 설정


% 재생 바 움직일 수 있도록 타이머 콜백 설정
global Timer
Timer = timer('period', 2);                         %% 타이머 함수를 이용하여 2초 주기로 타이머 콜백 호출
set(Timer, 'ExecutionMode', 'fixedrate', 'timerfcn', @(hObject, eventdata)edit_Timer_Callback(hObject, eventdata, handles));



% UIWAIT makes homework210527 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = homework210527_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  초기 설정 끝  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  파일 브라우징 시작  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 브라우징 버튼 콜백
% --- Executes on button press in button_Browse.
function button_Browse_Callback(hObject, eventdata, handles)
% hObject    handle to button_Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 음성 파일 불러오기
global filename X Fs T t
[filename, pathname] = uigetfile('*.wav;*.mp3', 'File Selector');             %% .wav 파일 로드
path = [pathname filename];                                             %% 경로 저장
[X Fs] = audioread(path);                                               %% 음성 파일의 주파수와 파형 저장
X = 0.8 * X;                                                            %% 소리 너무 커지는 것 방지하기 위해 진폭 조절
T = length(X) / Fs;                                                     %% 음성 파일 길이(sec) 저장
set(handles.filepath, 'String', path);                                  %% 텍스트로 경로 출력
t = 0:(1/Fs):(T-1/Fs);                                                  %% 음성 파일의 샘플링 시간(sec)

time = timecheck(T);
set(handles.text_AudioLength, 'String', time);


% 음악 재생 설정
global  player player2 Y Fs point1 point2 R sec1 sec2;
Y = X;                                                                  %% 초기 Y(필터링된 음성)값은 X로 설정
player = audioplayer(Y,Fs);                                             %% 오디오 플레이어 설정

point1 = 1;                                                             %% 반복 구간 시작 점 초기화
point2 = length(X);                                                             %% 반복 구간 끝 점 초기화
R = Y([point1:point2], :);                                              %% 반복 구간 초기화
player2 = audioplayer(R, Fs);                                           %% 반복 구간 플레이어 설정

sec1 = 10;                                                              %% 되감기 시간 초기화
sec2 = 10;                                                              %% 감기 시간 초기화


% 신호 파형 슬라이더 범위 설정(음성 신호에 맞게 설정)
set(handles.slider_OriginSignal, 'Max', T-40);                          %% 그래프가 40초 단위로 볼 수 있으므로 x축 Max는 (음원 길이 - 40) 
set(handles.slider_FiltSignal, 'Max', T);


% 기존 음성 그래프 그리기
global t1
t1 = 0;                                                                                         %% 슬라이더 초기값 0
h3 = plot(handles.axes_OriginSignal, t, X);                                                     %% Original Signal 파형 그리기
xlabel(handles.axes_OriginSignal,'[sec]'); ylabel(handles.axes_OriginSignal, '[Magnitude]');    %% Original Signal 라벨링
set(h3, 'Color', [0.075 0.624 1]);                                                              %% 그래프 색 설정
set(handles.axes_OriginSignal, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1]);         %% Original Signal 그래프 모양 설정
if t1 > 5
    set(handles.axes_OriginSignal, 'ylim', [-1.2 1.2], 'xlim', [t1-5 t1+35]);                   %% Original Signal 그래프 limit 설정
else
    set(handles.axes_OriginSignal, 'ylim', [-1.2 1.2], 'xlim', [t1 t1+40]);                     %% Original Signal 그래프 limit 설정
end

% 필터링 신호 그래프 초기화
global h4
axes(handles.axes_FiltSignal);                                                                  %% FiltSignal 그래프에 접근한다.
delete(h4);                                                                                     %% 기존에 그려져있는 신호 삭제
h4 = plot(handles.axes_FiltSignal, t, Y);                                                       %% 초기 신호 파형 그리기
xlabel(handles.axes_FiltSignal,'[sec]'); ylabel(handles.axes_FiltSignal, '[Magnitude]');        %% Filtered Signal 라벨링
set(h4, 'Color', [0.075 0.624 1]);                                                              %% 그래프 색 설정
set(handles.axes_FiltSignal, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1]);           %% Filtered Signal 그래프 모양 설정
set(handles.axes_FiltSignal, 'ylim', [-1.2 1.2], 'xlim', [0 T]);                                %% Filtered Signal 그래프 limit 설정


% 초기 설정 - 현재 재생 위치 bar
global h2
hold(handles.axes_FiltSignal, 'on')                              %% Filt Signal에 bar와 신호 표시하기 위해 hold on
h2 = plot(handles.axes_FiltSignal, [0 0], [-1.2 1.2], 'w');      %% Output Signal에 현재 위치 표시 bar
set(h2, 'Color', [1 1 0], 'LineWidth', 2);                       %% 현재 위치 표시 bar 색상 설정(노랑)
set(handles.axes_FiltSignal, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1]);    %% 출력 음성 그래프 모양 설정
%현재 재생 위치 표시 bar 움직이는 방법
%delete(h2); h2 = plot([0.6 0.6], [-1 1], 'r');


% 기존 음성 fft
global t3 Z
t3 = 0;                                                          %% 슬라이더 초기값 0
Y1 = fft(X);                                                     %% Y1 푸리에 변환
Mag1 = abs(Y1(1:length(X)/2)) / length(X)*2;                     %% Y1의 Magnitude는 y축 대칭이 아니도록 설정
Z = Fs * ((0:length(X)/2-1)/length(X));                          %% 주파수(0 ~ X길이-1)를 x축으로 설정
semilogy(handles.axes_OriginFreq, Z, Mag1);                      %% 주파수에 대응하는 진폭 그리기
xlabel(handles.axes_OriginFreq,'[Hz]'); ylabel(handles.axes_OriginFreq, '[Magnitude]');    %% Original Freq 라벨링
set(handles.axes_OriginFreq, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1]);      %% Original Freq 그래프 모양 설정
set(handles.axes_OriginFreq, 'xlim', [t3 t3+0.4e4]);                                       %% Original Freq 그래프 limit 설정


% 필터링 음성 fft 초기화
global t4 Y2 Mag2
t4 = 0;                                                          %% 슬라이더 초기값 0
Y2 = fft(X);                                                     %% Y2 푸리에 변환
Mag2 = abs(Y1(1:length(X)/2)) / length(X)*2;                     %% Y2의 Magnitude는 y축 대칭이 아니도록 설정
semilogy(handles.axes_FiltFreq, Z, Mag2);                        %% 주파수에 대응하는 진폭 그리기
xlabel(handles.axes_FiltFreq,'[Hz]'); ylabel(handles.axes_FiltFreq, '[Magnitude]');      %% Original Freq 라벨링
set(handles.axes_FiltFreq, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1]);      %% Original Freq 그래프 모양 설정
set(handles.axes_FiltFreq, 'xlim', [t3 t3+0.4e4]);                                       %% Original Freq 그래프 limit 설정


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over button_Browse.
function button_Browse_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to button_Browse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% 파일 경로 텍스트 창
function filepath_Callback(hObject, eventdata, handles)
% hObject    handle to filepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filepath as text
%        str2double(get(hObject,'String')) returns contents of filepath as a double


% --- Executes during object creation, after setting all properties.
function filepath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filepath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  파일 브라우징 끝  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  주파수 값 슬라이딩 시작  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 150Hz 슬라이더
% --- Executes on slider movement.
function slider_150Hz_Callback(hObject, eventdata, handles)
% hObject    handle to slider_150Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 150Hz - 주파수 스펙트럼 슬라이드
global f i y h1 ii;
y(2) = get(handles.slider_150Hz, 'Value');          %% y(2) 값을 슬라이더에 맞춘다.
f1 = interp1(i, y, ii, 'spline');                   %% 초기 주파수 스펙트럼 보간법 적용
h1 = plot(handles.axes_FreqSpectrum, ii, f1);       %% 초기 주파수 스펙트럼 세팅
set(h1, 'LineWidth', 2);                            %% 주파수 스펙트럼 그래프 굵기 설정
set(handles.axes_FreqSpectrum, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1], 'ylim', [-10 10], 'xlim', [0 8.5], 'XTickLabel', f);      %%주파수 스펙트럼 그래프 모양 설정
set(handles.edit_150Hz, 'String', y(2));            %% edit 창의 값을 y(2)으로 변경

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function slider_150Hz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_150Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% 300Hz 슬라이더
% --- Executes on slider movement.
function slider_300Hz_Callback(hObject, eventdata, handles)
% hObject    handle to slider_300Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 300Hz - 주파수 스펙트 슬라이드
global f i y h1 ii;
y(3) = get(handles.slider_300Hz, 'Value');          %% y(3) 값을 슬라이더에 맞춘다.
f1 = interp1(i, y, ii, 'spline');                   %% 주파수 스펙트럼 보간법 적용
h1 = plot(handles.axes_FreqSpectrum, ii, f1);       %% 주파수 스펙트럼 세팅
set(h1, 'LineWidth', 2);                            %% 주파수 스펙트럼 그래프 굵기 설정
set(handles.axes_FreqSpectrum, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1], 'ylim', [-10 10], 'xlim', [0 8.5], 'XTickLabel', f);      %%주파수 스펙트럼 그래프 모양 설정
set(handles.edit_300Hz, 'String', y(3));            %% edit 창의 값을 y(3)으로 변경

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function slider_300Hz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_300Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% 600Hz 슬라이더
% --- Executes on slider movement.
function slider_600Hz_Callback(hObject, eventdata, handles)
% hObject    handle to slider_600Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 600Hz - 주파수 스펙트럼 슬라이드
global f i y h1 ii;
y(4) = get(handles.slider_600Hz, 'Value');          %% y(4) 값을 슬라이더에 맞춘다.
f1 = interp1(i, y, ii, 'spline');                   %% 주파수 스펙트럼 보간법 적용
h1 = plot(handles.axes_FreqSpectrum, ii, f1);       %% 주파수 스펙트럼 세팅
set(h1, 'LineWidth', 2);                            %% 주파수 스펙트럼 그래프 굵기 설정
set(handles.axes_FreqSpectrum, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1], 'ylim', [-10 10], 'xlim', [0 8.5], 'XTickLabel', f);      %%주파수 스펙트럼 그래프 모양 설정
set(handles.edit_600Hz, 'String', y(4));            %% edit 창의 값을 y(4)으로 변경

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function slider_600Hz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_600Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% 1200Hz 슬라이더
% --- Executes on slider movement.
function slider_1200Hz_Callback(hObject, eventdata, handles)
% hObject    handle to slider_1200Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 1200Hz - 주파수 스펙트럼 슬라이드
global f i y h1 ii;
y(5) = get(handles.slider_1200Hz, 'Value');          %% y(5) 값을 슬라이더에 맞춘다.
f1 = interp1(i, y, ii, 'spline');                    %% 주파수 스펙트럼 보간법 적용
h1 = plot(handles.axes_FreqSpectrum, ii, f1);        %% 주파수 스펙트럼 세팅
set(h1, 'LineWidth', 2);                             %% 주파수 스펙트럼 그래프 굵기 설정
set(handles.axes_FreqSpectrum, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1], 'ylim', [-10 10], 'xlim', [0 8.5], 'XTickLabel', f);      %%주파수 스펙트럼 그래프 모양 설정
set(handles.edit_1200Hz, 'String', y(5));            %% edit 창의 값을 y(5)으로 변경

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function slider_1200Hz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_1200Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% 2400Hz 슬라이더
% --- Executes on slider movement.
function slider_2400Hz_Callback(hObject, eventdata, handles)
% hObject    handle to slider_2400Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 2400Hz - 주파수 스펙트럼 슬라이드
global f i y h1 ii;
y(6) = get(handles.slider_2400Hz, 'Value');          %% y(6) 값을 슬라이더에 맞춘다.
f1 = interp1(i, y, ii, 'spline');                    %% 주파수 스펙트럼 보간법 적용
h1 = plot(handles.axes_FreqSpectrum, ii, f1);        %% 주파수 스펙트럼 세팅
set(h1, 'LineWidth', 2);                             %% 주파수 스펙트럼 그래프 굵기 설정
set(handles.axes_FreqSpectrum, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1], 'ylim', [-10 10], 'xlim', [0 8.5], 'XTickLabel', f);      %%주파수 스펙트럼 그래프 모양 설정
set(handles.edit_2400Hz, 'String', y(6));            %% edit 창의 값을 y(6)으로 변경

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function slider_2400Hz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_2400Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% 4800Hz 슬라이더
% --- Executes on slider movement.
function slider_4800Hz_Callback(hObject, eventdata, handles)
% hObject    handle to slider_4800Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 4800Hz - 주파수 스펙트럼 슬라이드
global f i y h1 ii;
y(7) = get(handles.slider_4800Hz, 'Value');          %% y(7) 값을 슬라이더에 맞춘다.
f1 = interp1(i, y, ii, 'spline');                    %% 주파수 스펙트럼 보간법 적용
h1 = plot(handles.axes_FreqSpectrum, ii, f1);        %% 주파수 스펙트럼 세팅
set(h1, 'LineWidth', 2);                             %% 주파수 스펙트럼 그래프 굵기 설정
set(handles.axes_FreqSpectrum, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1], 'ylim', [-10 10], 'xlim', [0 8.5], 'XTickLabel', f);      %%주파수 스펙트럼 그래프 모양 설정
set(handles.edit_4800Hz, 'String', y(7));            %% edit 창의 값을 y(7)으로 변경

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function slider_4800Hz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_4800Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% 9200Hz 슬라이더
% --- Executes on slider movement.
function slider_9200Hz_Callback(hObject, eventdata, handles)
% hObject    handle to slider_9200Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 9200Hz - 주파수 스펙트럼 슬라이드
global f i y h1 ii;
y(8) = get(handles.slider_9200Hz, 'Value');          %% y(8) 값을 슬라이더에 맞춘다.
f1 = interp1(i, y, ii, 'spline');                    %% 주파수 스펙트럼 보간법 적용
h1 = plot(handles.axes_FreqSpectrum, ii, f1);        %% 주파수 스펙트럼 세팅
set(h1, 'LineWidth', 2);                             %% 주파수 스펙트럼 그래프 굵기 설정
set(handles.axes_FreqSpectrum, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1], 'ylim', [-10 10], 'xlim', [0 8.5], 'XTickLabel', f);      %%주파수 스펙트럼 그래프 모양 설정
set(handles.edit_9200Hz, 'String', y(8));            %% edit 창의 값을 y(8)으로 변경

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function slider_9200Hz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_9200Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% 18400Hz 슬라이더
% --- Executes on slider movement.
function slider_18400Hz_Callback(hObject, eventdata, handles)
% hObject    handle to slider_18400Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 18400Hz - 주파수 스펙트럼 슬라이드
global f i y h1 ii;
y(9) = get(handles.slider_18400Hz, 'Value');          %% y(9) 값을 슬라이더에 맞춘다.
f1 = interp1(i, y, ii, 'spline');                     %% 주파수 스펙트럼 보간법 적용
h1 = plot(handles.axes_FreqSpectrum, ii, f1);         %% 주파수 스펙트럼 세팅
set(h1, 'LineWidth', 2);                              %% 주파수 스펙트럼 그래프 굵기 설정
set(handles.axes_FreqSpectrum, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1], 'ylim', [-10 10], 'xlim', [0 8.5], 'XTickLabel', f);      %%주파수 스펙트럼 그래프 모양 설정
set(handles.edit_18400Hz, 'String', y(9));            %% edit 창의 값을 y(9)으로 변경

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function slider_18400Hz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_18400Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  주파수 값 슬라이딩 끝  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  주파수 값 입력 시작  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 150Hz 텍스트 입력
function edit_150Hz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_150Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 150Hz - 주파수 스펙트럼 입력
global f i y h1 ii;
y(2) = str2double(get(handles.edit_150Hz, 'String'));           %% y(2) 값을 에디터 창 입력값에 맞춘다.
f1 = interp1(i, y, ii, 'spline');                               %% 주파수 스펙트럼 보간법 적용
h1 = plot(handles.axes_FreqSpectrum, ii, f1);                   %% 주파수 스펙트럼 세팅
set(h1, 'LineWidth', 2);                                        %% 주파수 스펙트럼 그래프 굵기 설정
set(handles.axes_FreqSpectrum, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1], 'ylim', [-10 10], 'xlim', [0 8.5], 'XTickLabel', f);      %%주파수 스펙트럼 그래프 모양 설정
set(handles.slider_150Hz, 'Value', y(2));                       %% 슬라이더에 y(2)값을 표시

% Hints: get(hObject,'String') returns contents of edit_150Hz as text
%        str2double(get(hObject,'String')) returns contents of edit_150Hz as a double

% --- Executes during object creation, after setting all properties.
function edit_150Hz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_150Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%300Hz 텍스트 입력
function edit_300Hz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_300Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 300Hz - 주파수 스펙트럼 입력
global f i y h1 ii;
y(3) = str2double(get(handles.edit_300Hz, 'String'));           %% y(3) 값을 에디터 창 입력값에 맞춘다.
f1 = interp1(i, y, ii, 'spline');                               %% 주파수 스펙트럼 보간법 적용
h1 = plot(handles.axes_FreqSpectrum, ii, f1);                   %% 주파수 스펙트럼 세팅
set(h1, 'LineWidth', 2);                                        %% 주파수 스펙트럼 그래프 굵기 설정
set(handles.axes_FreqSpectrum, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1], 'ylim', [-10 10], 'xlim', [0 8.5], 'XTickLabel', f);      %%주파수 스펙트럼 그래프 모양 설정
set(handles.slider_300Hz, 'Value', y(3));                       %% 슬라이더에 y(3)값을 표시

% Hints: get(hObject,'String') returns contents of edit_300Hz as text
%        str2double(get(hObject,'String')) returns contents of edit_300Hz as a double

% --- Executes during object creation, after setting all properties.
function edit_300Hz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_300Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% 600Hz 텍스트 입력
function edit_600Hz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_600Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 600Hz - 주파수 스펙트럼 입력
global f i y h1 ii;
y(4) = str2double(get(handles.edit_600Hz, 'String'));           %% y(4) 값을 에디터 창 입력값에 맞춘다.
f1 = interp1(i, y, ii, 'spline');                               %% 주파수 스펙트럼 보간법 적용
h1 = plot(handles.axes_FreqSpectrum, ii, f1);                   %% 주파수 스펙트럼 세팅
set(h1, 'LineWidth', 2);                                        %% 주파수 스펙트럼 그래프 굵기 설정
set(handles.axes_FreqSpectrum, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1], 'ylim', [-10 10], 'xlim', [0 8.5], 'XTickLabel', f);      %%주파수 스펙트럼 그래프 모양 설정
set(handles.slider_600Hz, 'Value', y(4));                       %% 슬라이더에 y(4)값을 표시

% Hints: get(hObject,'String') returns contents of edit_600Hz as text
%        str2double(get(hObject,'String')) returns contents of edit_600Hz as a double

% --- Executes during object creation, after setting all properties.
function edit_600Hz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_600Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% 1200Hz 텍스트 입력
function edit_1200Hz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_1200Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 1200Hz - 주파수 스펙트럼 입력
global f i y h1 ii;
y(5) = str2double(get(handles.edit_1200Hz, 'String'));          %% y(5) 값을 에디터 창 입력값에 맞춘다.
f1 = interp1(i, y, ii, 'spline');                               %% 주파수 스펙트럼 보간법 적용
h1 = plot(handles.axes_FreqSpectrum, ii, f1);                   %% 주파수 스펙트럼 세팅
set(h1, 'LineWidth', 2);                                        %% 주파수 스펙트럼 그래프 굵기 설정
set(handles.axes_FreqSpectrum, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1], 'ylim', [-10 10], 'xlim', [0 8.5], 'XTickLabel', f);      %%주파수 스펙트럼 그래프 모양 설정
set(handles.slider_1200Hz, 'Value', y(5));                      %% 슬라이더에 y(5)값을 표시

% Hints: get(hObject,'String') returns contents of edit_1200Hz as text
%        str2double(get(hObject,'String')) returns contents of edit_1200Hz as a double

% --- Executes during object creation, after setting all properties.
function edit_1200Hz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_1200Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% 2400Hz 텍스트 입력
function edit_2400Hz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_2400Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 2400Hz - 주파수 스펙트럼 입력
global f i y h1 ii;
y(6) = str2double(get(handles.edit_2400Hz, 'String'));          %% y(6) 값을 에디터 창 입력값에 맞춘다.
f1 = interp1(i, y, ii, 'spline');                               %% 주파수 스펙트럼 보간법 적용
h1 = plot(handles.axes_FreqSpectrum, ii, f1);                   %% 주파수 스펙트럼 세팅
set(h1, 'LineWidth', 2);                                        %% 주파수 스펙트럼 그래프 굵기 설정
set(handles.axes_FreqSpectrum, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1], 'ylim', [-10 10], 'xlim', [0 8.5], 'XTickLabel', f);      %%주파수 스펙트럼 그래프 모양 설정
set(handles.slider_2400Hz, 'Value', y(6));                      %% 슬라이더에 y(6)값을 표시

% Hints: get(hObject,'String') returns contents of edit_2400Hz as text
%        str2double(get(hObject,'String')) returns contents of edit_2400Hz as a double

% --- Executes during object creation, after setting all properties.
function edit_2400Hz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_2400Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called시

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% 4800Hz 텍스트 입력
function edit_4800Hz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_4800Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 4800Hz - 주파수 스펙트럼 입력
global f i y h1 ii;
y(7) = str2double(get(handles.edit_4800Hz, 'String'));          %% y(7) 값을 에디터 창 입력값에 맞춘다.
f1 = interp1(i, y, ii, 'spline');                               %% 주파수 스펙트럼 보간법 적용
h1 = plot(handles.axes_FreqSpectrum, ii, f1);                   %% 주파수 스펙트럼 세팅
set(h1, 'LineWidth', 2);                                        %% 주파수 스펙트럼 그래프 굵기 설정
set(handles.axes_FreqSpectrum, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1], 'ylim', [-10 10], 'xlim', [0 8.5], 'XTickLabel', f);      %%주파수 스펙트럼 그래프 모양 설정
set(handles.slider_4800Hz, 'Value', y(7));                      %% 슬라이더에 y(7)값을 표시

% Hints: get(hObject,'String') returns contents of edit_4800Hz as text
%        str2double(get(hObject,'String')) returns contents of edit_4800Hz as a double

% --- Executes during object creation, after setting all properties.
function edit_4800Hz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_4800Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% 9200Hz 텍스트 입력
function edit_9200Hz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_9200Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 9200Hz - 주파수 스펙트럼 입력
global f i y h1 ii;
y(8) = str2double(get(handles.edit_9200Hz, 'String'));          %% y(8) 값을 에디터 창 입력값에 맞춘다.
f1 = interp1(i, y, ii, 'spline');                               %% 주파수 스펙트럼 보간법 적용
h1 = plot(handles.axes_FreqSpectrum, ii, f1);                   %% 주파수 스펙트럼 세팅
set(h1, 'LineWidth', 2);                                        %% 주파수 스펙트럼 그래프 굵기 설정
set(handles.axes_FreqSpectrum, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1], 'ylim', [-10 10], 'xlim', [0 8.5], 'XTickLabel', f);      %%주파수 스펙트럼 그래프 모양 설정
set(handles.slider_9200Hz, 'Value', y(8));                      %% 슬라이더에 y(8)값을 표시

% Hints: get(hObject,'String') returns contents of edit_9200Hz as text
%        str2double(get(hObject,'String')) returns contents of edit_9200Hz as a double

% --- Executes during object creation, after setting all properties.
function edit_9200Hz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_9200Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% 18400Hz 텍스트 입력
function edit_18400Hz_Callback(hObject, eventdata, handles)
% hObject    handle to edit_18400Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 18400Hz - 주파수 스펙트럼 입력
global f i y h1 ii;
y(9) = str2double(get(handles.edit_18400Hz, 'String'));          %% y(9) 값을 에디터 창 입력값에 맞춘다.
f1 = interp1(i, y, ii, 'spline');                                %% 주파수 스펙트럼 보간법 적용
h1 = plot(handles.axes_FreqSpectrum, ii, f1);                    %% 주파수 스펙트럼 세팅
set(h1, 'LineWidth', 2);                                         %% 주파수 스펙트럼 그래프 굵기 설정
set(handles.axes_FreqSpectrum, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1], 'ylim', [-10 10], 'xlim', [0 8.5], 'XTickLabel', f);      %%주파수 스펙트럼 그래프 모양 설정
set(handles.slider_18400Hz, 'Value', y(9));                      %% 슬라이더에 y(9)값을 표시

% Hints: get(hObject,'String') returns contents of edit_18400Hz as text
%        str2double(get(hObject,'String')) returns contents of edit_18400Hz as a double

% --- Executes during object creation, after setting all properties.
function edit_18400Hz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_18400Hz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  주파수 값 입력 끝  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  주파수 필터링 시작 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --- Executes on button press in button_Apply.
function button_Apply_Callback(hObject, eventdata, handles)
% hObject    handle to button_Apply (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% 주파수 필터링 및 음성 업데이트

global f y X Fs Z Y;

% 필터링 주파수 구간 설정
%c1 = 0.1;
c2 = f(2);
c3 = f(3);
c4 = f(4);
c5 = f(5);
c6 = f(6);
c7 = f(7);
c8 = f(8);
c9 = f(9);

% bandpass1
[b1, a1] = butter(5, c2/(Fs/2), 'low');     %% [c1 c2] 구간을 band 필터링하고 이퀄라이저 설정에 맞게 곱한다.
fX1 = filtfilt(b1, a1, X);
Y1 = y(1)*fX1/10;

% bandpass2
[b2, a2] = butter(5, c2/(Fs/2), 'high');    %% [c2 c3] 구간을 band 필터링하고 이퀄라이저 설정에 맞게 곱한다.
fX2 = filtfilt(b2, a2, X);
[b2, a2] = butter(5, c3/(Fs/2), 'low');
fX2 = filtfilt(b2, a2, fX2);
Y2 = y(2)*fX2/10;

% bandpass3
[b3, a3] = butter(5, c3/(Fs/2), 'high');    %% [c3 c4] 구간을 band 필터링하고 이퀄라이저 설정에 맞게 곱한다.
fX3 = filtfilt(b3, a3, X);
[b3, a3] = butter(5, c4/(Fs/2), 'low');
fX3 = filtfilt(b3, a3, fX3);
Y3 = y(3)*fX3/10;

% bandpass4
[b4, a4] = butter(5, c4/(Fs/2), 'high');    %% [c4 c5] 구간을 band 필터링하고 이퀄라이저 설정에 맞게 곱한다.
fX4 = filtfilt(b4, a4, X);
[b4, a4] = butter(5, c5/(Fs/2), 'low');
fX4 = filtfilt(b4, a4, fX4);
Y4 = y(4)*fX4/10;

% bandpass5
[b5, a5] = butter(5, c5/(Fs/2), 'high');    %% [c5 c6] 구간을 band 필터링하고 이퀄라이저 설정에 맞게 곱한다.
fX5 = filtfilt(b5, a5, X);
[b5, a5] = butter(5, c6/(Fs/2), 'low');
fX5 = filtfilt(b5, a5, fX5);
Y5 = y(5)*fX5/10;

% bandpass6
[b6, a6] = butter(5, c6/(Fs/2), 'high');    %% [c6 c7] 구간을 band 필터링하고 이퀄라이저 설정에 맞게 곱한다.
fX6 = filtfilt(b6, a6, X);
[b6, a6] = butter(5, c7/(Fs/2), 'low');
fX6 = filtfilt(b6, a6, fX6);
Y6 = y(6)*fX6/10;

% bandpass7
[b7, a7] = butter(5, c7/(Fs/2), 'high');    %% [c7 c8] 구간을 band 필터링하고 이퀄라이저 설정에 맞게 곱한다.
fX7 = filtfilt(b7, a7, X);
[b7, a7] = butter(5, c8/(Fs/2), 'low');
fX7 = filtfilt(b7, a7, fX7);
Y7 = y(7)*fX7/10;

% bandpass8
[b8, a8] = butter(5, c8/(Fs/2), 'high');    %% [c8 c9] 구간을 band 필터링하고 이퀄라이저 설정에 맞게 곱한다.
fX8 = filtfilt(b8, a8, X);
[b8, a8] = butter(5, c9/(Fs/2), 'low');
fX8 = filtfilt(b8, a8, fX8);
Y8 = y(8)*fX8/10;


% 필터링된 Y
Y = X + Y1 + Y2 + Y3 + Y4 + Y5 + Y6 + Y7 + Y8;    %% 구간별로 필터링한 값을 원래 신호에 더하거나 빼서 필터링된 신호 Y를 구한다.

fftY = fft(Y);                                    %% Y 푸리에 변환
Mag = abs(fftY(1:length(X)/2)) / length(X)*2;     %% 푸리에 변환된 값을 y축 대칭이 아니도록 설정



% Filtered Signal, FFT의 그래프 그리기
global t t4 h4 T
axes(handles.axes_FiltSignal);                    %% FiltSignal 그래프에 접근한다.
delete(h4);                                       %% 기존에 그려져있는 신호 삭제
h4 = plot(handles.axes_FiltSignal, t, Y);         %% 필터링된 신호 출력
xlabel(handles.axes_FiltSignal,'[sec]'); ylabel(handles.axes_FiltSignal, '[Magnitude]');   %% Filtered Signal 라벨링
set(h4, 'Color', [0.075 0.624 1]);                                                         %% 그래프 색 설정
set(handles.axes_FiltSignal, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1]);      %% Filtered Signal 그래프 모양 설정
set(handles.axes_FiltSignal, 'ylim', [-1.2 1.2], 'xlim', [0 T]);                           %% Filtered Signal 그래프 limit 설정

semilogy(handles.axes_FiltFreq, Z, Mag);                                                   %% 필터링된 신호의 fft 출력
xlabel(handles.axes_FiltFreq,'[Hz]'); ylabel(handles.axes_FiltFreq, '[Magnitude]');        %% Original Freq 라벨링
set(handles.axes_FiltFreq, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1]);        %% Original Freq 그래프 모양 설정
set(handles.axes_FiltFreq, 'xlim', [t4 t4+0.4e4]);                                         %% Filtered Freq 그래프 limit 설정
set(handles.slider_FiltFreq, 'Max', 1.8e4);



% 필터링된 음성 업데이트
global player player2 R point1 point2;
R = Y([point1:point2], :);                        %% R 구간 필터링된 Y로 업데이트

% 전체 구간 재생 시 업데이트
if isplaying(player)
    pause(player);                                %% 재생 중이던 음악 멈춘다.
    position = get(player, 'CurrentSample');      %% 재생 위치 저장
    player = audioplayer(Y, Fs);                  %% 음성 업데이트
    player2 = audioplayer(R, Fs);                 %% 반복 구간 음성 업데이트
    play(player, round(position));                %% 재생 중이던 위치에서 재생 시작

% 반복 구간 재생 시 업데이트
elseif isplaying(player2)
    pause(player2);                               %% 재생 중이던 음악 멈춘다.
    position = get(player2, 'CurrentSample');     %% 재생 위치 저장
    player = audioplayer(Y,Fs);                   %% 전체 구간 음성 업데이트
    player2 = audioplayer(R, Fs);                 %% 음성 업데이트
    play(player2, round(position));               %% 재생 중이던 위치에서 재생 시작
    
% 재생 상황이 아닐 때 업데이트
else 
    player = audioplayer(Y,Fs);                   %% 전체 구간 음성 업데이트
    player2 = audioplayer(R, Fs);                 %% 반복 구간 음성 업데이트
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  주파수 필터링 끝 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  그래프 x축 슬라이더 시작  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 기존 신호 파형 슬라이더
% --- Executes on slider movement.
function slider_OriginSignal_Callback(hObject, eventdata, handles)
% hObject    handle to slider_OriginSignal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global t1
t1 = get(handles.slider_OriginSignal, 'Value');             %% Original Signal Slider 값 읽어서 t1에 저장
set(handles.axes_OriginSignal,'xlim', [t1 t1+40]);          %% Original Signal 그래프 limit 설정

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function slider_OriginSignal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_OriginSignal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% 필터링 신호 주파수 슬라이더
% --- Executes on slider movement.
function slider_FiltSignal_Callback(hObject, eventdata, handles)
% hObject    handle to slider_FiltSignal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global t2 Fs player player2
t2 = get(handles.slider_FiltSignal, 'Value');              %% Filtered Freq Slider 값 읽어서 t2에 저장

point = t2 * Fs;

if isplaying(player)
    stop(player);
    play(player, round(point));
    
elseif isplaying(player2)
    stop(player2);
    play(player, round(point));
    set(handles.button_Repeat, 'Value', 0);                                 %% 반복 구간 재생 버튼 토글
    set(handles.button_Repeat, 'BackgroundColor', [0.259 0.259 0.259]);     %% 반복 구간 재생 버튼 초기화
else
    play(player, round(point));
    pause(player);
end

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function slider_FiltSignal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_FiltSignal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% 기존 신호 주파수 슬라이더
% --- Executes on slider movement.
function slider_OriginFreq_Callback(hObject, eventdata, handles)
% hObject    handle to slider_OriginFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global t3
t3 = get(handles.slider_OriginFreq, 'Value');              %% Original Freq Slider 값 읽어서 t3에 저장
set(handles.axes_OriginFreq, 'xlim', [t3 t3+0.4e4]);       %% Original Freq 그래프 limit 설정

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function slider_OriginFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_OriginFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% 필터링 신호 주파수 슬라이더
% --- Executes on slider movement.
function slider_FiltFreq_Callback(hObject, eventdata, handles)
% hObject    handle to slider_FiltFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global t4
t4 = get(handles.slider_FiltFreq, 'Value');                %% Filtered Signal Slider 값 읽어서 t2에 저장
set(handles.axes_FiltFreq,'xlim', [t4 t4+0.4e4]);          %% Original Signal 그래프 limit 설정

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function slider_FiltFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_FiltFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  그래프 x축 슬라이더 끝  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  음악 재생 버튼 콜백 시작  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% sec = (CurrentSample-1) / Fs;

% 음악 재생 시작
% --- Executes on button press in button_Play.
function button_Play_Callback(hObject, eventdata, handles)
% hObject    handle to button_Play (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global player player2 point1 Timer;

% 반복 구간 재생 중
if isplaying(player2)
    position = get(player2, 'CurrentSample');   %% 반복 구간의 재생 위치 저장
    stop(player2);                              %% 반복 구간 재생 Stop
    play(player, round(position + point1));     %% 반복 구간 재생되던 위치에서 전체 음악 재생 시작
    set(handles.button_Repeat, 'Value', 0);                                 %% 반복 구간 재생 버튼 토글
    set(handles.button_Repeat, 'BackgroundColor', [0.259 0.259 0.259]);     %% 반복 구간 재생 버튼 초기화
    stop(Timer);

% 오디오 재생 없을 때
else
    resume(player);                             %% 음악 Resume
end

start(Timer);                                   %% Play 버튼을 누르면 Callback 시작



% 음악 재생 멈춤
% --- Executes on button press in button_Pause.
function button_Pause_Callback(hObject, eventdata, handles)
% hObject    handle to button_Pause (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global player player2 Timer;

% 전체 구간 Pause
if isplaying(player)
    pause(player);                              %% 전체 구간 재생 시에 player 재생 멈춤
    
% 반복 구간Pause
elseif isplaying(player2)
    pause(player2)                              %% 반복 구간 재생 시에 player2 재생 멈춤
    set(handles.button_Repeat, 'Value', 0);                                 %% 반복 구간 재생 버튼 토글
    set(handles.button_Repeat, 'BackgroundColor', [0.259 0.259 0.259]);     %% 반복 구간 재생 버튼 초기화
end

stop(Timer);                                    %% 타이머 멈춤


% 음악 재생 0:00초로 초기화
% --- Executes on button press in button_Stop.
function button_Stop_Callback(hObject, eventdata, handles)
% hObject    handle to button_Stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global player player2 h2 Timer;

set(handles.slider_FiltSignal, 'Value', 0);                       %% FiltSignal x축 슬라이더 초기화
axes(handles.axes_FiltSignal);
delete(h2);
h2 = plot(handles.axes_FiltSignal, [0 0], [-1.2 1.2], 'w');       %% 재생 위치 bar 초기화
set(h2, 'Color', [1 1 0], 'LineWidth', 2);                        %% 현재 위치 표시 bar 색상 설정(노랑)
set(handles.axes_FiltSignal, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1]);    %% 출력 음성 그래프 모양 설정

time = timecheck(0);
set(handles.text_time, 'String', time);                           %% 재생 시간 초기화

% 전체 구간 Stop
if isplaying(player)
    stop(player);                               %% 전체 구간 재생 시에 player stop

% 반복 구간 Stop
elseif isplaying(player2)
    stop(player2);                              %% 반복 구간 재생 시에 player2 stop
    set(handles.button_Repeat, 'Value', 0);                                 %% 반복 구간 재생 버튼 토글
    set(handles.button_Repeat, 'BackgroundColor', [0.259 0.259 0.259]);     %% 반복 구간 재생 버튼 초기화
    
else
    play(player);                               %% 재생하는 것이 없을 때 재생 위치를 0초로 초기화
    stop(player);
end

stop(Timer);                                    %% 타이머 멈춤



% 앞으로 감기 버튼
% --- Executes on button press in button_Wind.
function button_Wind_Callback(hObject, eventdata, handles)
% hObject    handle to button_Wind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global player point sec1 Y Fs;
point = get(player, 'CurrentSample') + sec1*Fs;             %% 재생할 위치 계산(현재 재생 위치 + 앞으로 감을 시간)
if point > length(Y)                                        %% 재생할 시간이 음성 끝을 넘어가면 재생 위치를 끝으로 설정
    point = length(Y);
end
if isplaying(player)
    stop(player);                                           %% 재생 중이던 노래 멈춤
    play(player, round(point));                             %% 뒤로 감아 노래 다시 재생
else
    stop(player);                                           %% 재생 중이던 노래 멈춤
    play(player, round(point));                             %% 뒤로 감아 노래 다시 재생
    pause(player);
end



% 뒤로 감기 버튼
% --- Executes on button press in button_Rewind.
function button_Rewind_Callback(hObject, eventdata, handles)
% hObject    handle to button_Rewind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global player point sec2 Fs;
point = get(player, 'CurrentSample') - sec2*Fs;            %% 재생할 위치 계산(현재 재생 위치 - 뒤로 감을 시간)
if point < 0                                               %% 재생할 시간이 (-)부호를 띄면 재생 위치를 처음으로 설정
    point = 1;
end
if isplaying(player)
    stop(player);                                          %% 재생 중이던 노래 멈춤
    play(player, round(point));                            %% 뒤로 감아 노래 다시 재생
else
    stop(player);                                          %% 재생 중이던 노래 멈춤
    play(player, round(point));                            %% 뒤로 감아 노래 다시 재생
    pause(player);
end



% 앞으로 감기 시간 설정
function set_Wind_Callback(hObject, eventdata, handles)
% hObject    handle to set_Wind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sec1;
sec1 = str2double(get(handles.set_Wind, 'String'));     %% 앞으로 감을 시간 읽기

% Hints: get(hObject,'String') returns contents of set_Wind as text
%        str2double(get(hObject,'String')) returns contents of set_Wind as a double


% --- Executes during object creation, after setting all properties.
function set_Wind_CreateFcn(hObject, eventdata, handles)
% hObject    handle to set_Wind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% 뒤로 감기 시간 설정
function set_Rewind_Callback(hObject, eventdata, handles)
% hObject    handle to set_Rewind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global sec2;
sec2 = str2double(get(handles.set_Rewind, 'String'));     %% 뒤로 감을 시간 읽기

% Hints: get(hObject,'String') returns contents of set_Rewind as text
%        str2double(get(hObject,'String')) returns contents of set_Rewind as a double


% --- Executes during object creation, after setting all properties.
function set_Rewind_CreateFcn(hObject, eventdata, handles)
% hObject    handle to set_Rewind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% 반복 구간 시작 지점 버튼
% --- Executes on button press in button_Start.
function button_Start_Callback(hObject, eventdata, handles)
% hObject    handle to button_Start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global player player2 Rs Y Fs p1 point1 point2;

% 반복 구간 시작점 버튼 OFF
if get(handles.button_Start, 'Value') == 0
    set(handles.button_Start, 'BackgroundColor', [0.259 0.259 0.259]);                          %% 버튼 색 초기화
    point1 = 1;                                                                                 %% 반복 구간 시작점 초기화
    p1 = point1/Fs;
    axes(handles.axes_FiltSignal);                                                              %% 반복 구간 시작점 bar 삭제
    delete(Rs);
    R = Y([point1:point2], :);                                                                  %% 반복 구간 업데이트
    player2 = audioplayer(R, Fs);                                                               %% 반복 구간 재생 음성 업데이트
    set(handles.button_Repeat, 'Value', 0);                                                     %% 반복 구간 멈춤
    button_Repeat_Callback(hObject, eventdata, handles);
    
% 반복 구간 시작점 버튼 ON
else
    set(handles.button_Start, 'BackgroundColor', [0 0 0]);                                      %% 버튼 색 변경
    point1 = get(player, 'CurrentSample');                                                      %% 현재 재생 지점을 반복 구간 시작점으로 설정
    p1 = point1/Fs;                                                                             %% p1에 구간 반복 시작 시간 저장
    
    if point1 < point2
        hold(handles.axes_FiltSignal, 'on')                                                     %% Filt Signal에 bar와 신호 표시하기 위해 hold on
        Rs = plot(handles.axes_FiltSignal, [p1 p1], [-1.2 1.2]);                                %% Output Signal에 현재 위치 표시 bar
        set(Rs, 'Color', [1 1 1], 'LineWidth', 2);                                              %% 반복 시작점 위치 표시 bar 색상, 두께 설정
        set(handles.axes_FiltSignal, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1]);   %% 출력 음성 그래프 모양 설정
        R = Y([point1:point2], :);                                                              %% 반복 구간 업데이트
        player2 = audioplayer(R, Fs);                                                           %% 반복 구간 재생 음성 업데이트
        
    else
        p1 = 1/Fs;                                                                             %% 반복 구간 시작점, 끝점 예외 처리
    end
end


% 반복 구간 끝 지점 버튼
% --- Executes on button press in button_End.
function button_End_Callback(hObject, eventdata, handles)
% hObject    handle to button_End (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global player player2 Re X Y Fs p2 point1 point2;

% 반복 구간 끝점 버튼 OFF
if get(handles.button_End, 'Value') == 0
    set(handles.button_End, 'BackgroundColor', [0.259 0.259 0.259]);                            %% 버튼 색 초기화
    point2 = length(X);                                                                         %% 반복 구간 끝점 초기화
    p2 = point2/Fs;
    axes(handles.axes_FiltSignal);                                                              %% 반복 구간 끝점 bar 삭제
    delete(Re);        
    R = Y([point1:point2], :);                                                                  %% 반복 구간 업데이트
    player2 = audioplayer(R, Fs);                                                               %% 반복 구간 재생 음성 업데이트
    set(handles.button_Repeat, 'Value', 0);                                                     %% 반복 구간 멈춤
    button_Repeat_Callback(hObject, eventdata, handles);

else
    set(handles.button_End, 'BackgroundColor', [0 0 0]);                                        %% 버튼 색 변경
    point2 = get(player, 'CurrentSample');                                                      %% 현재 재생 지점을 반복 구간 끝점으로 설정
    p2 = point2/Fs;                                                                             %% p2에 반복 구간 끝 시간 저장
    
    if point2 > point1
        hold(handles.axes_FiltSignal, 'on')                                                     %% Filt Signal에 bar와 신호 표시하기 위해 hold on
        Re = plot(handles.axes_FiltSignal, [p2 p2], [-1.2 1.2]);                                %% Output Signal에 현재 위치 표시 bar
        set(Re, 'Color', [1 1 1], 'LineWidth', 2);                                              %% 반복 끝점 위치 표시 bar 색상, 두께 설정
        set(handles.axes_FiltSignal, 'Color', [0 0 0], 'XColor', [1 1 1], 'YColor', [1 1 1]);   %% 출력 음성 그래프 모양 설정
        R = Y([point1:point2], :);                                                              %% 반복 구간 업데이트
        player2 = audioplayer(R, Fs);                                                           %% 반복 구간 재생 음성 업데이트
        
    else
        point2 = length(X);                                                                     %% 반복 구간 시작점, 끝점 예외 처리
        p2 = point2/Fs;
    end
end



% 반복 구간 재생 버튼
% --- Executes on button press in button_Repeat.
function button_Repeat_Callback(hObject, eventdata, handles)
% hObject    handle to button_Repeat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global player player2 Timer;

% 반복 구간 재생 OFF
if get(handles.button_Repeat, 'Value') == 0
    set(handles.button_Repeat, 'BackgroundColor', [0.259 0.259 0.259]);                         %% 버튼 색 초기화
    pause(player2);                                                                             %% 반복 구간 재생 Pause
    stop(Timer);

% 반복 구간 재생 ON
else
    set(handles.button_Repeat, 'BackgroundColor', [0 0 0]);                                     %% 버튼 색 변경
    if isplaying(player)
        pause(player);                                                                          %% 재생 중이던 음성 Pause
    end
    resume(player2);                                                                            %% 반복 구간 재생 시작
    start(Timer);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  음악 재생 버튼 콜백 끝  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 타이머 콜백 함수
function edit_Timer_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Timer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Timer as text
%        str2double(get(hObject,'String')) returns contents of edit_Timer as a double

global player player2 h2 Fs T p1 p2 Timer

% 전체 구간 재생
if isplaying(player)
    position = get(player, 'CurrentSample')/Fs;                              %% 현재 재생위치 저장
    n_pos = position + 2;                                                    %% 다음 위치는 (현재 재생 시간(position/Fs) + Callback Period(2))

    set(handles.slider_FiltSignal, 'Value', n_pos);                          %% 슬라이더 위치 업데이트
    axes(handles.axes_FiltSignal);                                           %% 재생 위치 bar 업데이트
    delete(h2);
    h2 = plot(handles.axes_FiltSignal, [n_pos n_pos], [-1.2 1.2], 'w');      %% Output Signal에 현재 위치 표시 bar
    set(h2, 'Color', [1 1 0], 'LineWidth', 2);                               %% 현재 위치 표시 bar 색상 설정(노랑)
            
    if n_pos >= T                                                            %% 다음 위치가 음악 길이를 넘으면 처음부터 다시 재생
        stop(player);
        play(player);
    end
    
    time = timecheck(n_pos-2);
    set(handles.text_time, 'String', time);
    

% 반복 구간 재생
elseif isplaying(player2)
    position = get(player2, 'CurrentSample')/Fs;                             %% 현재 재생위치 저장
    n_pos = p1 + position + 2;                                               %% 다음 위치는 (현재 재생 시간(p2 + position/Fs) + Callback Period(2))

    set(handles.slider_FiltSignal, 'Value', n_pos);                          %% 슬라이더 위치 업데이트
    axes(handles.axes_FiltSignal);                                           %% 재생 위치 bar 업데이트
    delete(h2);
    h2 = plot(handles.axes_FiltSignal, [n_pos n_pos], [-1.2 1.2], 'w');      %% Output Signal에 현재 위치 표시 bar
    set(h2, 'Color', [1 1 0], 'LineWidth', 2);                               %% 현재 위치 표시 bar 색상 설정(노랑)
    
    if n_pos >= p2                                                           %% 다음 위치가 반복 구간을 넘으면 반복 구간 시작점부터 다시 재생
        stop(player2);  
        play(player2);
    end
    
    time = timecheck(n_pos-2 + p1);
    set(handles.text_time, 'String', time);
    

% 타이머 Period 2초 설정으로 인해 생기는 오류 잡기
else
    position = get(player, 'CurrentSample');                                 %% 현재 재생위치 저장
    n_pos = position/Fs + 2;                                                 %% 다음 위치는 (현재 재생 시간(position/Fs) + Callback Period(2))
    
    if n_pos >= T || position==3                                             %% 다음 위치가 음악 길이를 넘으면 처음부터 다시 재생
        stop(player);
        play(player);
    elseif get(handles.button_Repeat, 'Value') == 1 && n_pos > p2            %% player2가 재생 중이고 현재 위치가 반복 구간을 넘으면 반복 구간 시작점부터 다시 재생
        stop(player2);
        play(player2);
    end   
    
    time = timecheck(n-2);
    set(handles.text_time, 'String', time);
end

% --- Executes during object creation, after setting all properties.
function edit_Timer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Timer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axes_FreqSpectrum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_FreqSpectrum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes_FreqSpectrum


% --- Executes during object creation, after setting all properties.
function axes_FiltSignal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_FreqSpectrum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes_FreqSpectrum
