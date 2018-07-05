function prepareOutputFile(obj)
%prepareOutputFile Modify output file to allow easier reading
%   Detailed explanation goes here

filename = obj.outName;
% filename = '';

% Open and read file
fid = fopen(filename,'rt');
X = fread(fid);
fclose(fid);

% Replace strings
X = char(X.') ;
Y = strrep(X, '"', '');

% Delete existing file
recycle('on');
delete(filename);

% Create new file and write modified text
fid2 = fopen(filename,'wt') ;
fwrite(fid2,Y);
fclose(fid2);
end