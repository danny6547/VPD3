classdef cVesselAnalysis < handle
    %CVESSELANALYSIS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Abstract)
        
        Procedure;
        
    end
    
    properties
        
        Report = true;
    end
    
    methods
    
       function obj = cVesselAnalysis()
           
       end
    end
    
end