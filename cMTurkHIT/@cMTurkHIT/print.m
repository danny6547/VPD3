function html = print(obj)
%print Print all html needed for input web page
%   Detailed explanation goes here

obj = obj.inputPerPage;

html = obj.printHTMLTable;
end