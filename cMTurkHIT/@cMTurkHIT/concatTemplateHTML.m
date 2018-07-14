function [html] = concatTemplateHTML(obj, html)
%concatTemplateHTML Concatenate HTML from template site to HTML of table
%   Detailed explanation goes here

% Find file containing html
sitename = obj.TemplateSite;
atpath = fileparts(fileparts(mfilename('fullpath')));
sitepath = fullfile(atpath, 'Template Site HTML', sitename);

file_st = dir([sitepath, '\*.html']);
filename = fullfile(sitepath, file_st(1).name);

% Read file
file_c = {};
fid = fopen(filename, 'r');
while ~feof(fid)
    
    newline = fgetl(fid);
    file_c(end+1) = {newline};
end
fclose(fid);

% Insert html at appropriate line
insert_ch = '<!-- End Instructions --><!-- Image Transcription Layout -->';
insert_i = find(contains(file_c, insert_ch), 1);
html = [file_c(1:insert_i-1)'; html; file_c(insert_i:end)'];
end