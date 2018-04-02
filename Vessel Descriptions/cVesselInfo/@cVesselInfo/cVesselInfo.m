classdef cVesselInfo < cTableObject
    %CVESSELINFO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        Valid_From;
        Vessel_Name;
        Deleted = false;
    end
    
%     properties(Hidden, Constant)
%        
%         ModelTable = 'Vessel';
%         ValueTable = {'VesselInfo'};
%         ModelField = 'Vessel_Id';
%     end
    
    methods
    
       function obj = cVesselInfo()
    
       end
    end
end