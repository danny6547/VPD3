function errorIfNoData(obj)
%errorIfNoData Error if no data given
%   Detailed explanation goes here

errid = 'NoData:FileNotRead';
errmsg = 'Data must be read from file before output can be processed';

if isempty(obj.FileData)
    
    error(errid, errmsg);
end