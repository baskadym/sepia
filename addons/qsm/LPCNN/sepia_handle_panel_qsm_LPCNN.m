%% h = sepia_handle_panel_qsm_LPCNN(hParent,h,position)
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
% Description: This GUI function creates a panel for NDI method
%
% Kwok-shing Chan @ DCCN
% k.chan@donders.ru.nl
% Date created: 4 October 2022
% Date modified:
%
%
function h = sepia_handle_panel_qsm_LPCNN(hParent,h,position)

%% set default values

%% Tooltips

%% layout of the panel

%% Parent handle of CFS panel children

h.qsm.panel.LPCNN = uipanel(hParent,...
    'Title','LPCNN',...
    'position',position,...
    'backgroundcolor',get(h.fig,'color'),'Visible','off');

%% Children of CFS panel

end