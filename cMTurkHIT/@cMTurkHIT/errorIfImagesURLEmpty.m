function errorIfImagesURLEmpty(obj)
%UNTITLED12 Summary of this function goes here
%   Detailed explanation goes here

url = obj.ImageURL;
errid = 'PrintInput:URLMissing';
errmsg = ['Input CSV file cannot be printed until image locations are '...
    'given in the ''ImageURL'' property.'];

if isempty(url)
    
    error(errid, errmsg);
end 