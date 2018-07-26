function [html] = bulletPoints(html)
%bulletPoints Make a bullet point list from cell of strings of html objects
%   Detailed explanation goes here

html = strcat('<li>', html, '</li>');
html = html(:)';
end