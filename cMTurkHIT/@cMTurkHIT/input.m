function [html] = input(obj)
%input Operations required to create input for mTurk API
%   Detailed explanation goes here

% Write input file
obj.printCSV();

% Output html and copy to clipboard
html = obj.copyHTML();
end