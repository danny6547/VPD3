classdef cVesselClass < handle
    %CSHIPCLASS Weight class of ship.
    %   Detailed explanation goes here
    
    properties
        
        WeightTEU = [];
        LBP = [];
        Engine = cVesselEngine();
        Transverse_Projected_Area_Design = [];
        Block_Coefficient = [];
        Length_Overall = [];
        Breadth_Moulded = [];
        Draft_Design = [];
        Anemometer_Height = [];
        
    end
    
    methods
    
       function obj = cVesselClass()
    
       end
    
    end
    
end
