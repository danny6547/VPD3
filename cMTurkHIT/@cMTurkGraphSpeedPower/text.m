function [html] = text(html)
%bulletPoints Make a bullet point list from cell of strings of html objects
%   Detailed explanation goes here

html = strcat('<p>', html, '</p>');
html = html(:)';
end