classdef cVesselParticulars < cMySQL & matlab.mixin.Copyable
    %CVESSELPARTICULARS Data relating to vessel particulars
    %   Detailed explanation goes here
    
    properties
        
        IMO_Vessel_Number double = [];
        Name char = '';
        Owner char = '';
        Class = [];
        LBP = [];
        Transverse_Projected_Area_Design = [];
        Length_Overall = [];
        Breadth_Moulded = [];
        Draft_Design = [];
        Anemometer_Height = [];
    end
    
    properties(Hidden)
        
        Wind_Model_ID;
    end
    
    methods
    
       function obj = cVesselParticulars()
       
       end
       
       function obj = insertIntoTable(obj)
           
           tab = 'Vessels';
           insertIntoTable@cMySQL(obj, tab);
       end
    end
end