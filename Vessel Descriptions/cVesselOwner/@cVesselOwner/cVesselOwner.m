classdef cVesselOwner < cTableObject
    %CVESSELOWNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        Ownership_Start;
        Ownership_End;
        Deleted = false;
    end
    
%     properties(Hidden, Constant)
%        
%         ModelTable = 'Vessel';
%         ModelField = 'Vessel_Id';
%         ValueTable = {'VesselOwner'};
%     end
    
    methods
    
       function obj = cVesselOwner()
    
       end
    
    end
    
end
