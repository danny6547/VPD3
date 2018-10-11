function html = encloseDiv(html)
%encloseDiv Enclose HTML in a divider to display elements side by side
%   Detailed explanation goes here

% Input
% validatestring(type, {'left', '100%'}, 'cMTurkGraphSpeedPower.encloseDiv', ...
%     'type', 2);

% % Switch on type
% switch type
%     
%     case 'left'
%         
%         beforeHTML = '<div style="margin-left: 620px;">';
%     case '100%'
        
        beforeHTML = '<div style="border: thin solid currentColor; border-image: none; width: 100%; overflow: hidden;">';
% end
afterHTML = '</div>';

% Enclose
html = [cellstr(beforeHTML); html; cellstr(afterHTML)];