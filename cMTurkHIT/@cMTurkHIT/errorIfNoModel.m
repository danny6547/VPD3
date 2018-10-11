function errorIfNoModel(obj)
%errorIfNoModel Error if no model name given
%   Detailed explanation goes here

errid = 'CannotInsert:ModelNotGiven';
errmsg = 'Property ''ModelName'' must be given before SQL can be written';

if isempty(obj.ModelName)
    
    error(errid, errmsg);
end

end