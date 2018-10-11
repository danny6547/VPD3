function errorIfNoOutFile(obj)
%errorIfNoOutFile Error if output file not found
%   Detailed explanation goes here

errid = 'ParseError:FileNotFound';
errmsg = 'Output CSV file is expected to be found in ''Output'' sub-folder';

filename = obj.outName;
if exist(filename, 'file') ~= 2
    
    error(errid, errmsg);
end