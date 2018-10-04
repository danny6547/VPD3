classdef cVesselInfo < cModelID & cDateConvert
    %CVESSELINFO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        Vessel_Name;
    end
    
    properties(Constant, Hidden)
        
        StartDateProp = 'Valid_From';
        EndDateProp = 'Valid_To';
        DataProperty = {'Valid_From', 'Vessel_Name', 'Deleted',...
                        'Model_ID', 'Vessel_Info_Id'};
        ModelTable = 'VesselInfo';
        ValueTable = {};
        ValueObject = {};
        ModelField = {'Vessel_Info_Id'};
        TableIdentifier = 'Vessel_Info_Id';
        NameAlias = 'Vessel_Name';
        OtherTable = '';
        OtherTableIdentifier = '';
        EmptyIgnore = {'Deleted'};
    end
    
    properties(Hidden)
        
        Vessel_Info_Id;
        Vessel_Id;
    end
    
    methods
    
       function obj = cVesselInfo(varargin)
            
           obj@cModelID(varargin{:});
           obj.Valid_From = '2000-01-01';
       end
    end
end