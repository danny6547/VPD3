classdef cVesselConfiguration < cMySQL & matlab.mixin.Copyable & cTableObject & cDateConvert
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
        Valid_From char = '';
        Valid_To char = '';
        Default_Configuration logical = [];
        Speed_Power_Source char = [];
        Wind_Reference_Height_Design double = [];
        Displacement_Model_ID double = [];
        Speed_Power_Coefficient_Model_ID double = [];
        Wind_Coefficient_Model_ID double = [];
        Vessel_Configuration_Description char = '';
        Apply_Wind_Calculations logical;
        Fuel_Type char = '';
        Deleted = false;
    end
    
    properties(Hidden)
        
        Wind_Model_ID;
    end
    
    properties(Constant, Hidden)
        
        StartDateProp = 'Valid_From';
        EndDateProp = 'Valid_To';
        DataProperty = {'LBP',...
                        'Transverse_Projected_Area_Design',...
                        'Length_Overall',...
                        'Breadth_Moulded',...
                        'Draft_Design',...
                        'Anemometer_Height',...
                        'Engine_Model_Id',...
                        'Valid_From',...
                        'Valid_To',...
                        'Default_Configuration',...
                        'Speed_Power_Source',...
                        'Wind_Reference_Height_Design',...
                        'Displacement_Model_ID',...
                        'Speed_Power_Coefficient_Model_ID',...
                        'Wind_Coefficient_Model_ID',...
                        'Vessel_Configuration_Description',...
                        'Apply_Wind_Calculations',...
                        'Fuel_Type',...
                        'Deleted'};
    end
    
    
%     properties(Hidden, Constant)
%        
%         ModelTable = 'Vessel';
%         ValueTable = {'VesselConfiguration'};
%         ModelField = 'Vessel_Id';
%     end
    
    methods
    
       function obj = cVesselConfiguration(varargin)
       
           obj = obj@cTableObject(varargin{:});
       end
       
%        function obj = insertIntoTable(obj)
%            
%            tab = 'Vessels';
%            insertIntoTable@cTableObject(obj, tab);
%        end
    end
end