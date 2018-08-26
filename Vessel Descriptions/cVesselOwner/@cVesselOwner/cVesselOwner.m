classdef cVesselOwner < cModelID & cDateConvert
    %CVESSELOWNER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        Vessel_Owner_Name;
    end
    
    properties(Dependent)
        
        Ownership_Start;
        Ownership_End;
    end
    
    properties(Constant, Hidden)
        
        StartDateProp = 'Ownership_Start';
        EndDateProp = 'Ownership_End';
        DataProperty = {'Vessel_Owner_Id',...
                        'Vessel_Owner_Name',...
                        'Vessel_Id',...
                        'Ownership_Start',...
                        'Ownership_End',...
                        'Model_ID',...
                        'Deleted'};
        TableIdentifier = 'Vessel_Owner_Id';
        ModelTable = 'VesselOwner';
        ValueTable = {'VesselToVesselOwner'};
        ModelField = {'Vessel_Owner_Id'};
        ValueObject = {};
        NameAlias = 'Vessel_Owner_Name';
        OtherTable = '';
        OtherTableIdentifier = '';
        EmptyIgnore = {'Deleted'};
    end
    
    properties(Hidden)
        
        Vessel_Owner_Id;
        Vessel_To_Vessel_Owner_Id;
        Vessel_Id;
    end
    
    methods
    
       function obj = cVesselOwner(varargin)
           
           obj = obj@cModelID(varargin{:});
       end
    end
    
    methods
        
        function obj = set.Ownership_Start(obj, start)
            
            obj.Valid_From = start;
        end
        
        function start = get.Ownership_Start(obj)
            
            start = obj.Valid_From;
        end
        
        function obj = set.Ownership_End(obj, endd)
            
            obj.Valid_To = endd;
        end
        
        function endd = get.Ownership_End(obj)
            
            endd = obj.Valid_To;
        end
        
        function void = get.Vessel_Owner_Id(obj)
            
            void = obj.Model_ID;
        end
    end
end