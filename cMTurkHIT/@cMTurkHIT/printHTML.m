function html = printHTML(obj)
%printHTML Print all HTML for web page
%   Detailed explanation goes here

% Print instructions
htmlIns = obj.printInstructions();

% Print table
htmlTab = obj.printHTMLTable();

% Concat
html = [htmlIns; htmlTab];

% Insert
html = obj.concatTemplateHTML(html);
end