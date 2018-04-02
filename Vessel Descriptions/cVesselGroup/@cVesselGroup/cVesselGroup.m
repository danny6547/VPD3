classdef cVesselGroup < cTableObject
    %CVESSELGROUP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        Name;
        Description;
        Select_Vessels_Query;
        Responsible;
        Report_Id;
        Group_Id;
        Created;
        Created_By;
        Modified;
        Modified_By;
    end
    
%     properties(Hidden, Constant)
%        
%         ModelTable = 'Vessel';
%         ModelField = 'Vessel_Id';
%         ValueTable = {'VesselGroup'};
%     end
    
    methods
    
       function obj = cVesselGroup()
    
       end
    
    end
    
end
