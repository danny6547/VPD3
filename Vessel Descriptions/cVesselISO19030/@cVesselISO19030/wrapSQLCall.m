function proc = wrapSQLCall(obj, proc)
%wrapSQLCall Wrap call to SQL through objects connection
%   Detailed explanation goes here

for pi = 1:numel(proc)
    
    if ~proc(pi).isSQL
        
        continue
    end
    
    bareProc = proc(pi).procedure;
    wrappedProc = strcat('@(x, varargin) x.call(''', bareProc, ''', varargin{:})');
    proc(pi).procedure = wrappedProc;
    proc(pi).input = [{obj.SQL}, proc(pi).input];
end