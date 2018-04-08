classdef cVesselInfo < cTableObject & cDateConvert
    %CVESSELINFO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        Valid_From;
        Vessel_Name;
        Deleted = false;
    end
    
    properties(Constant, Hidden)
        
        StartDateProp = 'Valid_From';
        EndDateProp = 'Valid_To';
    end
    
    properties(Hidden)
        
        Valid_To; % All cDateConvert subclasses must implement two 
        % properties which will be assigned to, even if they don't use them
    end
    
%     properties(Hidden, Constant)
%        
%         ModelTable = 'Vessel';
%         ValueTable = {'VesselInfo'};
%         ModelField = 'Vessel_Id';
%     end
    
    methods
    
       function obj = cVesselInfo()
            
           obj.DateStrFormat = 'yyyy-mm-dd';
           obj.Valid_From = '2000-01-01';
       end
       
       function obj = assignDates(obj, varargin)
           
          assignDates@cDateConvert(obj, varargin{:});
           
          obj.Valid_From = obj.StartDate;
       end
    end
end