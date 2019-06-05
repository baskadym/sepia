%% h = sepia_handle_panel_qsm_NDI(hParent,h,position)
%
% Input
% --------------
% hParent       : parent handle of this panel
% h             : global structure contains all handles
% position      : position of this panel
%
% Output
% --------------
% h             : global structure contains all new and other handles
%
% Description: This GUI function creates a panel for iLSQR method
%
% Kwok-shing Chan @ DCCN
% k.chan@donders.ru.nl
% Date created: 5 June 2019
% Date last modified: 
%
%
function h = sepia_handle_panel_qsm_NDI(hParent,h,position)

% define maximum level of options and spacing between options
nlevel = 4;
spacing = 0.02;
height = (1-(nlevel+1)*spacing)/nlevel;
bottom = (height+spacing:height+spacing:(height+spacing)*nlevel) - height;

%% set default values
defaultTol      = 0.5;
defaultMaxIter  = 200;
defaultStepSize = 1;

%% Parent handle of CFS panel children

h.qsm.panel.NDI = uipanel(hParent,...
    'Title','Non-linear Dipole Inversion (NDI)',...
    'position',position,...
    'backgroundcolor',get(h.fig,'color'),'Visible','off');

%% Children of CFS panel
    
    % text|edit field pair: tolerance
     h.qsm.NDI.text.tol = uicontrol('Parent',h.qsm.panel.NDI,'Style','text',...
        'String','Tolerance:',...
        'units','normalized','position',[0.01 bottom(4) 0.2 height],...
        'HorizontalAlignment','left',...
        'backgroundcolor',get(h.fig,'color'),...
        'tooltip','Relative tolerance to stop LSQR iteration');
    h.qsm.NDI.edit.tol = uicontrol('Parent',h.qsm.panel.NDI,'Style','edit',...
        'String',num2str(defaultTol),...
        'units','normalized','position',[0.25 bottom(4) 0.2 height],...
        'backgroundcolor','white');

    % text|edit field pair: maximum iterations
    h.qsm.NDI.text.maxIter = uicontrol('Parent',h.qsm.panel.NDI,'Style','text',...
        'String','Max. iterations:',...
        'units','normalized','position',[0.01 bottom(3) 0.2 height],...
        'HorizontalAlignment','left',...
        'backgroundcolor',get(h.fig,'color'),...
        'tooltip','Maximum iterations allowed');
    h.qsm.NDI.edit.maxIter = uicontrol('Parent',h.qsm.panel.NDI,'Style','edit',...
        'String',num2str(defaultMaxIter),...
        'units','normalized','position',[0.25 bottom(3) 0.2 height],...
        'backgroundcolor','white');

    % text|edit field pair: gradient step size
    h.qsm.NDI.text.stepSize = uicontrol('Parent',h.qsm.panel.NDI,'Style','text',...
        'String','Step size:',...
        'units','normalized','position',[0.01 bottom(2) 0.2 height],...
        'HorizontalAlignment','left',...
        'backgroundcolor',get(h.fig,'color'),...
        'tooltip','Gradient descent step size');
    h.qsm.NDI.edit.stepSize = uicontrol('Parent',h.qsm.panel.NDI,'Style','edit',...
        'String',num2str(defaultStepSize),...
        'units','normalized','position',[0.25 bottom(2) 0.2 height],...
        'backgroundcolor','white');


%% set callbacks
% edit fields
set(h.qsm.NDI.edit.stepSize,	'Callback',	{@EditInputMinMax_Callback,defaultStepSize,	0,0});
set(h.qsm.NDI.edit.maxIter, 	'Callback',	{@EditInputMinMax_Callback,defaultMaxIter,  1,1});
set(h.qsm.NDI.edit.tol,       	'Callback',	{@EditInputMinMax_Callback,defaultTol,      0,0});

end