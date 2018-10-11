function errorIfImagesMissing(obj)
%errorIfNoData Error if no data given
%   Detailed explanation goes here

files = obj.imageFiles();
errid = 'UI:FilesMissing';
errmsg = 'No image files found';

if isempty(files)
    
    error(errid, errmsg);
end 