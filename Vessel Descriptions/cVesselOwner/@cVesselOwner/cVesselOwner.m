classdef cVesselOwner < cTableObject & cDateConvert
    %CVESSELOWNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        Ownership_Start;
        Ownership_End;
        Deleted = false;
    end
    
    properties(Constant, Hidden)
        
        StartDateProp = 'Ownership_Start';
        EndDateProp = 'Ownership_End';
    end
    
    methods
    
       function obj = cVesselOwner(varargin)
           
           obj = obj@cTableObject(varargin{:});
       end
    end
end