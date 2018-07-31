classdef cVesselInfo < cModelID & cDateConvert
    %CVESSELINFO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
%         Valid_From;
        Vessel_Name;
%         Deleted = false;
%         Vessel_Id;
    end
    
    properties(Constant, Hidden)
        
        StartDateProp = 'Valid_From';
        EndDateProp = 'Valid_To';
        DataProperty = {'Valid_From', 'Vessel_Name', 'Deleted',...
                        'Model_ID', 'Vessel_Info_Id'};
        
        ModelTable = '';
        ValueTable = {};
        ValueObject = {};
        ModelField = {};
        TableIdentifier = 'Vessel_Id';
        NameAlias = 'Vessel_Name';
        OtherTable = '';
        OtherTableIdentifier = '';
        EmptyIgnore = {'Deleted'};
    end
    
    properties(Hidden)
        
%         Valid_To; % All cDateConvert subclasses must implement two 
%         % properties which will be assigned to, even if they don't use them
        
        Vessel_Info_Id;
        Vessel_Id;
    end
    
%     properties(Hidden, Constant)
%        
%         ModelTable = 'Vessel';
%         ValueTable = {'VesselInfo'};
%         ModelField = 'Vessel_Id';
%     end
    
    methods
    
       function obj = cVesselInfo(varargin)
            
           obj@cModelID(varargin{:});
%            obj.DateStrFormat = 'yyyy-mm-dd';
           obj.Valid_From = '2000-01-01';
       end
       
%        function obj = assignDates(obj, varargin)
%            
%           assignDates@cDateConvert(obj, varargin{:});
%            
%           obj.Valid_From = obj.StartDate;
%        end
       
    end
end