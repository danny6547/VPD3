function checkVarname( perStruct, varname )
%checkVarname Error if varname is not found in struct or invalid
%   Detailed explanation goes here

    validateattributes(varname, {'char'}, {'vector'}, ...
        'inServicePerformance', 'varname', 2);
    
    if ~ismember(varname, fieldnames(perStruct))

        errid = 'DB:NameUnknown';
        errmsg = 'Input VARNAME must be a field name of input struct PERSTRUCT';
        error(errid, errmsg);
    end

end

