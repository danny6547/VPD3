classdef cVesselConfiguration < cMySQL & matlab.mixin.Copyable & cTableObject
    %CVESSELPARTICULARS Data relating to vessel particulars
    %   Detailed explanation goes here
    
    properties
        
        LBP = [];
        Transverse_Projected_Area_Design = [];
        Length_Overall = [];
        Breadth_Moulded = [];
        Draft_Design = [];
        Anemometer_Height = [];
        
        Engine_Model_Id double = [];
        Valid_From double = [];
        Valid_To double = [];
        Default_Configuration logical = [];
        Speed_Power_Source char = [];
        Wind_Reference_Height_Design double = [];
        Displacement_Model_ID double = [];
        Speed_Power_Coefficient_Model_ID double = [];
        Wind_Coefficient_Model_ID double = [];
        Vessel_Configuration_Description char = '';
        Apply_Wind_Calculations char = '';
        Fuel_Type char = '';
        Deleted = false;
    end
    
    properties(Hidden)
        
        Wind_Model_ID;
    end
    
%     properties(Hidden, Constant)
%        
%         ModelTable = 'Vessel';
%         ValueTable = {'VesselConfiguration'};
%         ModelField = 'Vessel_Id';
%     end
    
    methods
    
       function obj = cVesselConfiguration()
       
       end
       
%        function obj = insertIntoTable(obj)
%            
%            tab = 'Vessels';
%            insertIntoTable@cMySQL(obj, tab);
%        end
    end
end