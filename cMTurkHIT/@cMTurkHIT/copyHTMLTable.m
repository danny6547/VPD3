function copyHTMLTable(obj)
%copyHTMLTable Copy HTML table to clipboard
%   Detailed explanation goes here

tab_c = obj.printHTMLTable;
clipboard('copy', [tab_c{:}]);
end