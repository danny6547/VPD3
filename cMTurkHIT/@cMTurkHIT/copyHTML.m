function html = copyHTML(obj)
%copyHTML Copy HTML to clipboard
%   Detailed explanation goes here

tab_c = obj.printHTML;
html = [tab_c{:}];
clipboard('copy', html);
end