classdef cWanHai
    %CWANHAI Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
    end
    
    methods
    
       function obj = cWanHai()
    
       end
    end
    
    methods(Static)
        
        tbl = writeImportFile(noonFile, noonType, highFile, highType, varargin);
        tbl = loadHigh(file, type)
        tbl = processNoon(tbl, type)
        tbl = processHigh(tbl, type, varargin)
        [tbl] = removeNonStandard(tbl, spec)
        [spec, timeName] = specification(freq, type)
        [tbl] = standardiseTable(tbl, freq, type)
        [var, stdVar] = varFromSpec(freq, type)
        [spec, timeName] = noonSpecification(type)
        tbl = loadNoon(obj, file, type)
        [in, name] = noon2TimeOpt()
        tbl = appendOtherSpecVars(tbl, freq, type)
        vars = fileVarsHigh(type)
    end
end
