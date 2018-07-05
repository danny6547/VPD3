function copyHTML(obj)
%copyHTML Copy HTML to clipboard
%   Detailed explanation goes here

tab_c = obj.printHTML;
clipboard('copy', [tab_c{:}]);
end